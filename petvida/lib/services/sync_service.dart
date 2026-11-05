import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Sincronização Offline-First com backup no Firebase apenas via Wi-Fi
/// (RF10, RF11, RNF02).
///
/// Os dados ficam sempre no cache local do Firestore, então a carteira de
/// vacinação continua acessível sem internet. A rede do Firestore só é
/// liberada quando o aparelho está em Wi-Fi; em dados móveis ou sem conexão
/// ela fica pausada e as alterações são enviadas na próxima vez que o Wi-Fi
/// voltar.
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  /// `true` enquanto o Firestore está conectado ao servidor (em Wi-Fi).
  final ValueNotifier<bool> backupAtivo = ValueNotifier(false);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _redeForcada = false;

  /// Estado real da rede do Firestore; `null` até a primeira verificação
  /// (o Firestore começa online por padrão).
  bool? _redeHabilitada;

  /// Configura o cache local e começa a acompanhar o tipo de conexão.
  /// Deve ser chamado logo após `Firebase.initializeApp`, antes de qualquer
  /// leitura ou escrita no Firestore.
  Future<void> initialize() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    try {
      final conexoes = await Connectivity().checkConnectivity();
      await _aplicarPolitica(conexoes);
      _subscription = Connectivity().onConnectivityChanged.listen(
        _aplicarPolitica,
      );
    } catch (e) {
      // Sem como saber o tipo de rede, mantém o comportamento padrão do
      // Firestore (online quando houver conexão).
      debugPrint('SyncService: falha ao verificar conectividade: $e');
      _redeHabilitada = true;
      backupAtivo.value = true;
    }
  }

  Future<void> _aplicarPolitica(List<ConnectivityResult> conexoes) async {
    if (_redeForcada) return;
    final emWifi =
        conexoes.contains(ConnectivityResult.wifi) ||
        conexoes.contains(ConnectivityResult.ethernet);
    if (emWifi == _redeHabilitada) return;
    if (emWifi) {
      await FirebaseFirestore.instance.enableNetwork();
    } else {
      await FirebaseFirestore.instance.disableNetwork();
    }
    _redeHabilitada = emWifi;
    backupAtivo.value = emWifi;
  }

  /// Grava no cache local sem ficar esperando o servidor quando o backup
  /// está pausado. O Firestore aplica a escrita localmente na hora, mas o
  /// `Future` só completa quando o servidor confirma, o que fora do Wi-Fi
  /// só acontece na próxima sincronização.
  Future<void> gravar(Future<void> escrita) async {
    if (backupAtivo.value) {
      await escrita;
      return;
    }
    unawaited(
      escrita.catchError((Object e) {
        debugPrint('SyncService: escrita pendente falhou: $e');
      }),
    );
  }

  /// Libera a rede temporariamente para uma ação explícita do tutor que
  /// exige o servidor (ex.: exclusão definitiva da conta, RF12), mesmo fora
  /// do Wi-Fi. Depois volta a seguir a política de Wi-Fi.
  Future<T> comRedeLiberada<T>(Future<T> Function() acao) async {
    _redeForcada = true;
    await FirebaseFirestore.instance.enableNetwork();
    try {
      return await acao();
    } finally {
      _redeForcada = false;
      _redeHabilitada = true;
      backupAtivo.value = true;
      try {
        await _aplicarPolitica(await Connectivity().checkConnectivity());
      } catch (_) {
        // Se não der para checar a rede, deixa o Firestore online.
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}

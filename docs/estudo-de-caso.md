# Análise do Estudo de Caso — PetVida

## 1. Problema
O aplicativo busca combater dois problemas centrais na causa animal e na saúde pública: o abandono de animais e a proliferação de doenças zoonóticas. A principal causa desses problemas é o esquecimento ou a falta de controle na imunização e vermifugação contínua de cães e gatos, além da dificuldade de acesso a serviços públicos de saúde animal.

O PetVida atende à necessidade primária de centralizar, simplificar e tornar acessível a gestão de saúde preventiva dos pets. A solução é altamente relevante por conectar o cuidado individual (vacinação e vermifugação) com o impacto coletivo em saúde pública (controle de zoonoses como a Raiva e a Leishmaniose).


## 2. Público e Usuários
* **Tutores de Cães e Gatos**:
  * *Relação:* Usuários finais diretos da carteira e diário.
  * *Perfis e Necessidades:*
    * *Tutores Ansiosos:* Alto engajamento; buscam acompanhamento rigoroso e histórico exportável para consultas.
    * *Tutores Esquecidos:* Baixo engajamento espontâneo; necessitam de intervenção ativa da aplicação através de notificações push.
    * *Tutores de SRD (vira-latas):* Necessitam de categorização simplificada (ex: porte ao invés de raça específica).
* **ONGs e Protetores de Animais**:
  * *Relação:* Parceiros de divulgação e usuários em feiras de adoção.
  * *Necessidades:* Garantir que animais adotados mantenham o ciclo vacinal em dia e facilidade de orientação para novos tutores.
* **Médicos Veterinários e Agentes de Zoonoses (CCZ)**:
  * *Relação:* Receptores dos dados gerados pelo app.
  * *Necessidades:* Leitura rápida do histórico do animal durante consultas ou campanhas públicas, por meio do documento exportado em PDF ou visualização da linha do tempo.


## 3. Contexto de Uso
O aplicativo será operado em ambientes dinâmicos e por vezes caóticos, como clínicas veterinárias, pet shops, feiras de adoção e campanhas públicas de vacinação.

* **Conectividade:** Frequentemente utilizado em locais sem sinal de internet ou com cobertura instável. *Implicação:* Exige operação **offline-first**, garantindo leitura e gravação da carteira localmente, reservando a internet apenas para backup/sincronização via Firebase em conexões Wi-Fi.
* **Nível de Atenção e Urgência:** O tutor ou veterinário pode estar segurando o pet ou enfrentando uma situação de mal-estar do animal. *Implicação:* Necessidade de botões grandes, telas coloridas e de rápida interpretação visual. A funcionalidade principal de adicionar vacina deve exigir no máximo **3 interações** (Abrir > Tocar no pet > Tocar em "Adicionar Vacina").
* **Dispositivo:** Dispositivos móveis rodando Android 8.0 ou superior.


## 4. Objetivo e Proposta de Valor
O **PetVida** pretende oferecer uma carteira de vacinação e monitoramento de saúde digital, segura e acessível no bolso do tutor.

**Proposta de valor:** Proporcionar ao tutor a tranquilidade de manter o pet protegido sem complicação, garantindo alertas preventivos, histórico médico à mão e acesso facilitado aos serviços públicos de castração e saúde animal.


## 5. Personalidade, Identidade e Experiência
* **Palavras Conceituais:** Zoonoses, V8, V10, Raiva Animal, Vermifugação, Castração, Microchipagem, CCZ, Leishmaniose .
* **Personalidade:** Amorosa, lúdica, porém tecnicamente responsável .
* **Tom da Interface e UX:** Acolhedora e protetora . A experiência é estruturada para incentivar a guarda responsável, fazendo com que o tutor se sinta eficiente no cuidado, sem usar tom punitivo ou induzir culpa por atrasos .
* **Âncora Emocional e Visual:** Uso de cores quentes (laranja e amarelo), tipografia arredondada e o elemento visual de "patinhas" (em formulários e *loadings*) para gerar identificação imediata com o universo pet sem parecer infantil .
* **Lembrança Desejada:** *"A carteirinha de vacinas que todo pet merece ter no bolso do tutor."* 


## 6. Funcionalidades e Características Definidas
1. **Cadastro do Pet (Perfil com Foto)**
   * *Necessidade Atendida:* Registro dos dados do animal (nome, porte/raça, idade, peso, foto da galeria via ImagePicker) para identificação rápida .
2. **Carteira de Vacinação Digital (Linha do Tempo e Alertas)**
   * *Necessidade Atendida:* Prevenção contra doenças . Gera lembretes automáticos para vacinas futuras e envia notificações *push* 7 dias antes do vencimento .
3. **Mapa de Clínicas e Campanhas públicas**
   * *Necessidade Atendida:* Democratização do acesso à saúde animal, localizando clínicas públicas e campanhas de castração gratuitas integradas com mapas (Google Maps) .
4. **Diário de Sintomas**
   * *Necessidade Atendida:* Acompanhamento clínico . Permite registrar alterações (como vômito, diarreia e falta de apetite) para que o tutor apresente um histórico preciso ao veterinário .
5. **Geração de PDF do Histórico**
   * *Necessidade Atendida:* Praticidade e portabilidade de dados para consultas presenciais com profissionais .


## 7. Restrições e Condições do Projeto
* **Navegação e Telas:** O protótipo deve possuir no máximo **4 telas principais** (Perfil, Linha do Tempo, Clínicas/Campanhas e Diário de Sintomas) .
* **Interações:** O fluxo principal (adicionar vacina) deve ser concluído em até **3 toques** .
* **Sistema Operacional:** Suporte a Android 8.0 ou superior .
* **Conectividade:** A carteira deve funcionar sem internet . Sincronização com o Firebase permitida somente em Wi-Fi .
* **Privacidade e Proteção de Dados:** Como os dados do pet podem revelar a identidade do tutor, o app deve oferecer **Modo Anônimo** e **Exclusão Total dos Dados** a qualquer momento .
* **Recursos do Dispositivo:** Integração restrita e pontual com a Galeria de Fotos (`ImagePicker`) e Serviços de Mapas (`Google Maps`) .


## 8. Pontos de Atenção Críticos para o Sucesso
1. **Funcionamento Offline da Carteira de Vacinação**

   * *Motivo:* As consultas, feiras e atendimentos no CCZ frequentemente ocorrem em locais sem sinal estável . Se a carteira falhar sem internet, o app perde sua utilidade primária no momento da necessidade .


2. **Eficiência da Jornada em 3 Toques e Lembretes Automáticos (7 dias antes)**
   * *Motivo:* Tutores esquecidos precisam de baixíssima fricção no uso e de proatividade do sistema . Se o processo de cadastro de doses for longo ou se a notificação não disparar com antecedência, a taxa de adesão à imunização cairá .


3. Privacidade, Anonimato e Conformidade com Dados Sensíveis
   * *Motivo:* Garantir o modo anônimo e a opção de apagar dados transmite confiança ao tutor, assegurando que o app protege a privacidade da família/tutor ao tratar dados de localização e perfil .

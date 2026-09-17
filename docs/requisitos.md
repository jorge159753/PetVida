# Requisitos e Funcionalidades do Sistema PetVida

## 1. Funcionalidades

Esta seção apresenta as principais funcionalidades previstas para o sistema **PetVida**, considerando os objetivos de gestão da saúde animal, prevenção de doenças, acessibilidade das informações e promoção da guarda responsável.

### F1 — Gestão de Contas e Acesso Controlado

**Descrição:**  
Permitir o cadastro, a autenticação, a edição e a exclusão da conta do tutor, disponibilizando também a possibilidade de utilização do sistema em **Modo Anônimo**.

**Necessidade:**  
Garantir a privacidade das informações fornecidas pelo tutor, conciliando proteção de dados e flexibilidade de acesso ao sistema.

**Justificativa:**  
A funcionalidade contribui para a proteção de dados pessoais e sensíveis, bem como para a adequação do sistema aos princípios e às diretrizes estabelecidos pela **Lei Geral de Proteção de Dados Pessoais (LGPD)**.

### F2 — Gestão do Perfil do Pet

**Descrição:**  
Permitir o cadastro e o gerenciamento das informações individuais do animal, incluindo fotografia, nome, espécie, porte ou raça, idade e peso.

**Necessidade:**  
Centralizar e organizar as informações básicas e de saúde de cada animal de maneira individualizada.

**Justificativa:**  
O cadastro constitui a base estrutural para a personalização da carteira de vacinação, do acompanhamento preventivo e do diário de saúde do pet.

### F3 — Carteira Digital de Vacinação e Vermifugação

**Descrição:**  
Permitir o registro das doses de vacinas e vermífugos aplicados ao animal, bem como o planejamento das respectivas aplicações futuras.

**Necessidade:**  
Disponibilizar uma alternativa digital ao cartão físico de vacinação, proporcionando maior acessibilidade, organização e durabilidade das informações.

**Justificativa:**  
A manutenção adequada do histórico vacinal contribui para a prevenção de atrasos em imunizações relevantes, incluindo vacinas como V8, V10 e antirrábica.

### F4 — Notificações e Lembretes Preventivos

**Descrição:**  
Emitir notificações automáticas com antecedência de sete dias em relação ao vencimento ou à data prevista para uma nova dose de vacina.

**Necessidade:**  
Auxiliar tutores que possam esquecer ou perder os prazos de vacinação e imunização de seus animais.

**Justificativa:**  
A automatização dos lembretes busca reduzir a descontinuidade do calendário vacinal e contribuir para a prevenção de doenças infecciosas e zoonóticas.

### F5 — Diário de Sintomas e Acompanhamento

**Descrição:**  
Permitir o registro de ocorrências relacionadas à saúde do animal, tais como vômito, diarreia, apatia e falta de apetite, acompanhadas de informações temporais e observações.

**Necessidade:**  
Auxiliar o tutor na manutenção de um histórico organizado dos sinais apresentados pelo animal.

**Justificativa:**  
O histórico registrado pode auxiliar o tutor durante consultas veterinárias, fornecendo informações cronológicas que contribuam para a avaliação clínica realizada pelo profissional.

### F6 — Localizador de Clínicas Públicas e Campanhas

**Descrição:**  
Disponibilizar um mapa interativo contendo a localização de Centros de Controle de Zoonoses (CCZ), serviços públicos relacionados à saúde animal e pontos de campanhas de vacinação e castração.

**Necessidade:**  
Facilitar a localização e o acesso dos tutores a serviços públicos e gratuitos voltados à saúde e ao bem-estar animal.

**Justificativa:**  
A funcionalidade pode contribuir para ampliar o acesso a serviços de prevenção e controle populacional, favorecendo práticas de guarda responsável e ações de saúde pública veterinária.

### F7 — Exportação do Histórico de Saúde em PDF

**Descrição:**  
Permitir a geração de um documento em formato PDF contendo informações relevantes do histórico de saúde do animal, incluindo registros de vacinação e sintomas.

**Necessidade:**  
Possibilitar que o tutor apresente ou armazene as informações do animal em formato digital ou impresso, inclusive em situações nas quais o aplicativo não esteja disponível.

**Justificativa:**  
A exportação proporciona maior portabilidade, compartilhamento e disponibilidade das informações de saúde do pet.

### F8 — Sincronização e Backup em Nuvem

**Descrição:**  
Armazenar os dados localmente no dispositivo e realizar o backup automático das informações no Firebase quando houver conexão com uma rede Wi-Fi.

**Necessidade:**  
Reduzir o risco de perda de informações durante trocas ou falhas do dispositivo, mantendo simultaneamente a possibilidade de utilização do sistema sem conexão.

**Justificativa:**  
A estratégia contribui para a resiliência e a disponibilidade dos dados, além de evitar o consumo desnecessário de dados móveis durante os processos de sincronização.

---

## 2. Requisitos Funcionais (RF)

Os requisitos funcionais especificam os serviços, comportamentos e operações que o sistema deverá disponibilizar aos seus usuários.

| Código | Requisito |
|---|---|
| **RF01** | O sistema deve permitir que o usuário realize o cadastro, o login, a edição e a exclusão de sua conta, além de disponibilizar a opção de navegação em **Modo Anônimo**. |
| **RF02** | O sistema deve permitir cadastrar, visualizar, editar e excluir as informações do perfil do pet, incluindo foto, nome, espécie, porte/raça, idade e peso. |
| **RF03** | O sistema deve permitir registrar vacinas e vermífugos aplicados ao animal, contemplando, no mínimo, nome, data de aplicação, lote e responsável pelo procedimento. |
| **RF04** | O sistema deve calcular e agendar automaticamente a data prevista para a próxima dose após o registro de uma nova vacina, conforme as regras definidas para o respectivo imunizante. |
| **RF05** | O sistema deve emitir alertas ou notificações locais com antecedência de sete dias em relação à data prevista para a aplicação da vacina. |
| **RF06** | O sistema deve permitir o registro de episódios de sintomas, como vômito, diarreia, apatia e falta de apetite, contendo data, hora e observações. |
| **RF07** | O sistema deve disponibilizar um mapa interativo contendo a localização de clínicas veterinárias públicas, CCZ e pontos de campanhas de castração e vacinação. |
| **RF08** | O sistema deve permitir a filtragem dos pontos exibidos no mapa por categoria, incluindo, no mínimo, CCZ, vacinação gratuita e castração. |
| **RF09** | O sistema deve permitir a exportação do histórico vacinal do pet em formato PDF. |
| **RF10** | O sistema deve possibilitar a consulta dos dados cadastrais do pet e de sua carteira de vacinação em modo offline. |
| **RF11** | O sistema deve realizar o backup dos dados no Firebase quando o dispositivo estiver conectado a uma rede Wi-Fi. |
| **RF12** | O sistema deve permitir a exclusão definitiva dos dados relacionados ao tutor e ao pet mediante solicitação, observando os procedimentos aplicáveis à LGPD. |

---

## 3. Requisitos Não Funcionais (RNF)

Os requisitos não funcionais estabelecem características de qualidade, restrições técnicas e critérios de operação que deverão ser observados durante o desenvolvimento do sistema.

| Código | Categoria | Requisito |
|---|---|---|
| **RNF01** | Usabilidade | O usuário deve conseguir iniciar o processo de registro de uma nova vacina em, no máximo, três interações principais a partir do acesso ao aplicativo: **Abrir → Selecionar o Pet → Adicionar Vacina**. |
| **RNF02** | Conectividade e Armazenamento | O aplicativo deve adotar uma arquitetura **Offline-First**, armazenando os dados localmente e realizando a sincronização com o Firebase preferencialmente quando houver conexão Wi-Fi. |
| **RNF03** | Segurança e Privacidade | O aplicativo deve observar os princípios e requisitos aplicáveis da LGPD, disponibilizando o uso anônimo e mecanismos para exclusão dos dados mediante solicitação do titular, conforme as regras de retenção aplicáveis. |
| **RNF04** | Compatibilidade | O aplicativo deve ser desenvolvido utilizando **Flutter/Dart** e possuir compatibilidade com dispositivos Android 8.0 (API Level 26) ou versões superiores. |
| **RNF05** | Acessibilidade e Interface | A interface deve priorizar botões de dimensões adequadas, elementos visuais arredondados, contraste suficiente, cores de destaque em tonalidades quentes, como amarelo e laranja, e ícones de fácil reconhecimento, incluindo elementos gráficos relacionados à temática animal. |
| **RNF06** | Desempenho | As notificações relacionadas ao vencimento das vacinas devem ser programadas por meio dos mecanismos de notificação local do sistema operacional, utilizando, por exemplo, a biblioteca `flutter_local_notifications`, de modo que possam ser apresentadas mesmo quando o aplicativo estiver fechado, respeitadas as limitações e permissões do sistema operacional. |

---

## 4. Mapeamento CRUD

O mapeamento CRUD identifica as operações de **Create (C)**, **Read (R)**, **Update (U)** e **Delete (D)** previstas para cada entidade do sistema.

| Entidade | C — Create | R — Read | U — Update | D — Delete | Justificativa / Observação |
|---|:---:|:---:|:---:|:---:|---|
| **Usuário** | Sim | Sim | Sim | Sim | Permite o gerenciamento da conta e a exclusão dos dados mediante solicitação, observando os requisitos aplicáveis da LGPD. |
| **Pet** | Sim | Sim | Sim | Sim | Permite a criação e atualização das informações do animal, incluindo alterações de peso e demais dados cadastrais, bem como sua exclusão quando necessário. |
| **Vacinas** | Sim | Sim | Sim | Sim | Permite registrar novas doses e corrigir ou excluir registros inseridos incorretamente, conforme as regras de integridade do sistema. |
| **Sintomas** | Sim | Sim | Não | Sim | O histórico de sintomas não deverá ser editado após seu registro, preservando a integridade cronológica do diário. Caso necessário, o registro poderá ser excluído ou uma nova ocorrência poderá ser cadastrada. |
| **Clínicas/Campanhas** | Não | Sim | Não | Não | Os dados serão disponibilizados e mantidos por uma fonte administrativa ou API externa. O tutor terá apenas acesso à consulta das informações. |

### 4.1 Legenda

- **C — Create:** criação ou inserção de registros;
- **R — Read:** consulta ou visualização de registros;
- **U — Update:** alteração ou atualização de registros;
- **D — Delete:** exclusão de registros.

---

## 5. Priorização das Funcionalidades

A priorização das funcionalidades foi organizada considerando sua relevância para a primeira versão do sistema, sua contribuição para a proposta central e sua dependência em relação a outros componentes.

### 5.1 Funcionalidades Essenciais — MVP

As funcionalidades a seguir compõem o núcleo mínimo necessário para disponibilizar uma primeira versão funcional do sistema:

- **F2 — Gestão do Perfil do Pet**
- **F3 — Carteira Digital de Vacinação e Vermifugação**
- **F4 — Notificações e Lembretes Preventivos**

Essas funcionalidades estabelecem o fluxo central do sistema: cadastrar o animal, registrar suas informações de saúde e acompanhar os prazos de vacinação.

### 5.2 Funcionalidades Importantes

Após a implementação do núcleo do MVP, as seguintes funcionalidades ampliam a capacidade de acompanhamento e utilidade do sistema:

- **F5 — Diário de Sintomas e Acompanhamento**
- **F6 — Localizador de Clínicas Públicas e Campanhas**
- **F7 — Exportação do Histórico de Saúde em PDF**

### 5.3 Funcionalidades Secundárias

As seguintes funcionalidades podem ser incorporadas ou ampliadas de acordo com a evolução do projeto e os resultados obtidos durante a validação:

- **F1 — Gestão de Contas e Acesso Controlado, incluindo Modo Anônimo**
- **F8 — Sincronização e Backup em Nuvem via Wi-Fi**

---

## 6. Funcionalidade de Maior Relevância e Justificativa

### F4 / RF04 / RF05 — Notificações e Lembretes de Vacinação

A funcionalidade relacionada às **notificações e aos lembretes preventivos de vacinação**, associada aos requisitos **RF04** e **RF05**, constitui um dos elementos centrais da proposta do PetVida.

Sua finalidade é automatizar o acompanhamento dos prazos de vacinação, calculando ou registrando a próxima data prevista para aplicação e emitindo um lembrete com sete dias de antecedência.

A justificativa para sua centralidade está relacionada ao problema que o sistema busca solucionar: a dificuldade de alguns tutores em acompanhar adequadamente os períodos de vacinação dos animais. Nesse contexto, a utilização de lembretes automatizados reduz a dependência exclusiva da memória do usuário e transforma o acompanhamento do calendário vacinal em um processo sistematizado.

Do ponto de vista da saúde animal e da saúde pública, a manutenção de um calendário vacinal atualizado constitui uma medida preventiva relevante. O sistema, portanto, busca contribuir para a continuidade da imunização dos animais e para a promoção da guarda responsável, especialmente em relação a doenças de importância sanitária, como a raiva.

É importante destacar que o aplicativo possui caráter **informativo e preventivo**, não substituindo a avaliação, orientação ou prescrição realizada por médico-veterinário. As datas e recomendações apresentadas pelo sistema devem ser configuradas de acordo com critérios técnicos e fontes veterinárias adequadas.

---

## 7. Síntese dos Requisitos

De forma consolidada, o PetVida propõe uma solução digital voltada ao **gerenciamento preventivo da saúde de animais domésticos**, reunindo cadastro individualizado, carteira digital de vacinação, lembretes automatizados, diário de sintomas, localização de serviços públicos, exportação de informações e mecanismos de armazenamento local e sincronização em nuvem.

A arquitetura proposta deverá priorizar a disponibilidade das informações mesmo em situações de conectividade limitada, adotando o conceito **Offline-First**, ao mesmo tempo em que deverá observar requisitos de segurança, privacidade, usabilidade e proteção de dados.

O conjunto de requisitos apresentado neste documento deverá servir como referência para as etapas posteriores de **modelagem, desenvolvimento, testes e validação do sistema**, permitindo verificar se as funcionalidades implementadas atendem aos objetivos estabelecidos para o projeto.

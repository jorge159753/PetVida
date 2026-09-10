# Pesquisa de Mercado e Usuários — PetVida

Este documento apresenta a fundamentação teórica, análise de contexto, dados estatísticos e os principais insights obtidos para o desenvolvimento da plataforma **PetVida**, focada no gerenciamento da saúde animal e guarda responsável.

---

## 1. O Problema

O **PetVida** foi idealizado para auxiliar tutores no acompanhamento contínuo e na gestão da saúde de cães e gatos. Um dos gargalos mais recorrentes identificados é a perda ou dispersão de dados essenciais — como histórico de vacinação, aplicação de vermífugos, exames e consultas médicas — em múltiplos locais e papéis fáceis de perder.

Apesar de parecer uma questão meramente organizacional, o acompanhamento veterinário interfere diretamente na **saúde pública**:

* **Prevenção da Raiva e Zoonoses:** A vacinação regular de animais domésticos é o principal pilar de contenção da raiva. Dados do Ministério da Saúde apontam que a cobertura da campanha antirrábica no Brasil atingiu **78% em 2025**, enfatizando a importância de manter altos índices vacinais para evitar a recirculação do vírus.
* **Guarda Responsável x Abandono:** O Conselho Federal de Medicina Veterinária (CFMV) ratifica que a guarda responsável exige prover condições adequadas de saúde, nutrição e bem-estar, minimizando riscos à sociedade e ao meio ambiente. O abandono e a falta de controle preventivo agravam problemas socioambientais e favorecem o surto de zoonoses.

Assim, o PetVida visa **descentralizar a dependência da memória humana**, provendo uma ferramenta ágil, intuitiva e estruturada para acompanhamento preventivo.

---

## 2. Público e Usuários

O sistema engloba perfis com dinâmicas e necessidades distintas:

### 2.1. Tutores
* **Tutores Engajados / Preventivos:** Acompanham rigorosamente os prazos e utilizam a plataforma principalmente para centralização do histórico médico e controle preventivo.
* **Tutores Ocupados / Desorganizados:** Possuem rotinas intensas e dependem fortemente de automações, alertas e notificações ativas para evitar atrasos em doses e retornos.
* **Tutores de Primeira Viagem / Recém-Adotantes:** Necessitam de orientações simplificadas e facilidade no onboarding para cadastrar um pet sem histórico prévio estruturado.

### 2.2. Parceiros e Ecossistema
* **ONGs e Protetores Independente:** Agilidade na transferência do histórico de saúde durante feiras e processos de adoção.
* **Veterinários e Clínicas:** Agilidade no diagnóstico ao consultar diários de sintomas e carteiras vacinais prévias.
* **Agentes de Zoonoses:** Suporte na comprovação vacinal em ações comunitárias e de fiscalização.

---

## 3. Contexto de Uso e Requisitos Operacionais

O aplicativo foi projetado para operar em cenários adversos de mobilidade e conectividade:

* **Ambientes de Uso:** Clínicas veterinárias, pet shops, feiras de adoção e postos volantes de vacinação.
* **Design Centrado na Agilidade:** Interfaces limpas, de alta legibilidade e acesso direto às informações críticas em poucos toques.
* **Acesso Offline (*Offline-First*):** A carteira sanitária e os registros essenciais do pet ficam armazenados no próprio dispositivo local, garantindo que a ausência de sinal de internet em clínicas ou campanhas de rua não impeça a consulta dos dados.

---

## 4. Proposta de Valor do Aplicativo

O PetVida atua como uma **carteira digital completa de saúde animal**, oferecendo:

1. **Centralização de Histórico:** Vacinas, vermifugação, exames e diário de sintomas em um único local.
2. **Alertas e Notificações Inteligentes:** Lembretes automatizados para evitar o esquecimento de prazos epidemiológicos.
3. **Mapeamento de Serviços:** Geolocalização de clínicas públicas, postos de saúde animal e campanhas de castração/vacinação.
4. **Fomento à Guarda Responsável:** Alinhamento às diretrizes do CRMV-SP para promoção do bem-estar e controle populacional.

---

## 5. Levantamento de Necessidades (Requirements)

A partir das pesquisas de campo e análise do estudo de caso, foram elencadas as seguintes necessidades funcionais:

* [x] Organização estruturada do histórico de saúde do pet
* [x] Sistema de lembretes e notificações para ciclo vacinal
* [x] Cronograma e alertas para aplicação de vermífugos e antipulgas
* [x] Registro pontual em diário de sintomas para apoio a diagnósticos futuros
* [x] Rápida visualização do histórico durante consultas presenciais
* [x] Mapeamento e consulta a serviços públicos e campanhas comunitárias
* [x] Armazenamento e consulta da carteira de vacinação em modo *offline*
* [x] Experiência de uso fluida para tutores com pouco tempo disponível
* [x] Controle total do usuário sobre a privacidade e propriedade dos dados salvos

---

## 6. Dados Estatísticos da Pesquisa

De acordo com levantamentos da Pesquisa Nacional de Saúde (PNS / IBGE) e dados governamentais:

| Indicador | Dado Estatístico | Fonte |
| :--- | :--- | :--- |
| **Presença de Cães nos Domicílios** | 46,1% (~33,8 milhões de lares) | IBGE (2019) |
| **Presença de Gatos nos Domicílios** | 19,3% (~14,1 milhões de lares) | IBGE (2019) |
| **Taxa Nacional de Vacinação Antirrábica** | 72,0% dos lares com pets vacinados | IBGE (2019) |
| **Taxa de Vacinação Antirrábica (Região Nordeste)** | 67,3% dos lares com pets vacinados | IBGE (2019) |
| **Cobertura da Campanha Antirrábica** | 78,0% de alcance nacional | Min. da Saúde (2025) |

---

## 7. Principais Descobertas (*Key Insights*)

### Insight 1: A vacinação animal é um pilar direto de Saúde Pública
* **Achado:** A imunização de cães e gatos não beneficia apenas o indivíduo, mas impede a circulação de zoonoses letais como a raiva humana.
* **Impacto no Projeto:** A carteira sanitária e o módulo de vacinas recebem prioridade máxima na navegação (*core feature*).

### Insight 2: Lacunas vacinais podem ser mitigadas por automação
* **Achado:** A taxa de vacinação plena nos lares caiu de 75,4% (2013) para 72% (2019), apresentando queda acentuada em regiões específicas.
* **Impacto no Projeto:** Implementação de alertas preventivos configurados por padrão para **7 dias antes do vencimento** da dose, permitindo planejamento do tutor.

### Insight 3: Guarda responsável exige suporte à rotina contínua
* **Achado:** O CRMV-SP e CFMV destacam que a posse responsável envolve prevenções constantes (parasitas, higiene, alimentação e exames).
* **Impacto no Projeto:** O ecossistema estende-se além de vacinas, integrando calendário parasitário, diário de sintomas e guia de serviços locais.

---

## 8. Referências e Fontes Consultadas

1. **Ministério da Saúde** — *Raiva Animal: Informações sobre vacinação, vigilância e controle da raiva em cães e gatos.*
2. **Ministério da Saúde** — *Dados sobre as campanhas de vacinação antirrábica e cobertura nacional.*
3. **Instituto Brasileiro de Geografia e Estatística (IBGE)** — *Pesquisa Nacional de Saúde (PNS) 2019: Acesso ao serviço de saúde, condições de saúde e cobertura vacinal.*
4. **Conselho Regional de Medicina Veterinária de São Paulo (CRMV-SP)** — *Guarda Responsável e Impactos do Abandono na Saúde Pública.*
5. **Conselho Federal de Medicina Veterinária (CFMV)** — *Manual de Guarda Responsável e Prevenção às Zoonoses.*

# Documento de Justificativas de Design e Arquitetura — Sistema PetVida

**Especificações de interface, experiência do usuário e fundamentação da arquitetura técnica.**

---

## 1. Escolha das Cores (Paleta e Contraste)

### Paleta Quente e Acolhedora (Warm Soft Palette)

- **Laranja / Terracota Primário (`#E65100` / `#D84315`):**
  Utilizado nos botões de ação principal ("Adicionar Pet", "Adicionar Vacina", "Novo Evento", "Saiba Mais"), headers de cards em destaque e ícones de marca. Transmite energia, cuidado e atenção.

- **Amarelo Quente / Tons de Milho e Bege (`#FFF8E1`, `#FFE082`, `#FFB74D`):**
  Utilizado como fundo de cards ("Meus Pets", "Linha do Tempo", "Diário de Sintomas") e no gradiente suave do topo/cabeçalho. Cria uma atmosfera amigável, acolhedora e menos hospitalar.

- **Fundo Off-White Quente (`#FFFDF7` / `#FAF6EE`):**
  Substitui o branco puro frio, reduzindo o cansaço visual e mantendo a suavidade do aplicativo.

### Cores de Status e Alertas

- **Verde Menta / Esmeralda (`#2E7D32` / `#00C853`):**
  Utilizado em badges de confirmação como "Vacina OK", "Carteira Completa", "Peso Ideal" e "Check-up em Dia".

- **Vermelho Vivo / Alerta (`#D32F2F` / `#E53935`):**
  Utilizado em badges que requerem ação imediata como "Próxima Vacina" e "Falta Diário".

- **Escala de Gravidade do Diário de Sintomas:**
  Gradiente visual contínuo indo do Verde (Baixo) ao Amarelo (Médio) e Vermelho (Alto) no indicador slider.

### Contraste e Legibilidade

Texto principal em **Marrom Escuro / Café (`#3E2723` / `#4E342E`)**, oferecendo contraste superior a 4.5:1 (padrão WCAG 2.1 AA) sobre os fundos claros e amarelados, sem a rigidez do preto puro.

---

## 2. Tipografia (Hierarquia e Legibilidade)

### Família Tipográfica

Tipo de letra **Sans-Serif arredondada/moderna** (estilo Outfit, Fredoka ou Nunito), reforçando a identidade amigável do universo pet.

### Hierarquia Visual Baseada nas Telas

- **Logo e Marca (PetVida):**
  Tipografia estilizada com pata de pet integrada na letra "V".

- **Títulos de Tela (H1):**
  24px – 28px, Bold / Semi-Bold em Marrom Escuro ("Meus Pets", "Linha do Tempo", "Diário de Sintomas", "Clínicas e Campanhas").

- **Nomes de Pets e Subtítulos (H2):**
  18px – 22px, Bold em Laranja/Marrom (ex.: "Fofo", "Mago", "Amarelo", "Bolo").

- **Texto de Corpo e Descrições:**
  14px – 16px, Regular, com bom espaçamento entre linhas (`line-height: 1.4`).

- **Rótulos de Badges e Menus (Bottom Nav):**
  11px – 13px, Medium / Bold, mantendo clareza mesmo em tamanhos reduzidos.

### Design Modular por Cartões

Cards com **Border-Radius Acentuado**, utilizando cantos arredondados para reforçar a identidade visual amigável do aplicativo.

---

## 3. Organização das Informações (Disposição e Fluxo Visual)

### Tela Inicial

Carrossel/grid superior de acesso rápido às fotos e status de cada pet ("Fofo", "Mago", "Amarelo") ao lado do botão **"+ Adicionar Pet"**, seguido por grid 2x2 com grandes cartões para os 4 módulos principais:

- **Meus Pets**
- **Linha do Tempo**
- **Clínicas e Campanhas**
- **Diário de Sintomas**

### Tela "Meus Pets"

Lista vertical de cards contendo:

- Foto circular do pet à esquerda;
- Nome/espécie no centro;
- Badges de status à direita.

### Tela "Linha do Tempo"

Conectores verticais de timeline unindo cards de eventos:

- Vacinação;
- Check-up;
- Chegada em casa.

Cada evento possui ícone circular à esquerda e foto do pet/evento à direita.

### Tela "Diário de Sintomas"

- Seletor de ícones de sintomas no topo:
  - Febre;
  - Apetite;
  - Letargia;
  - Vômito;
  - Tosse.
- Seletor de severidade:
  - Baixo;
  - Médio;
  - Alto.
- Histórico cronológico em lista.

### Tela "Clínicas e Campanhas"

Mapa interativo integrado na parte superior e listagem de clínicas/campanhas em cards na parte inferior, com:

- Distância;
- Telefone.

---

## 4. Navegação (Fluxos, Menus e Facilidade de Localização)

### Navegação Inferior Fixa (Bottom Navigation Bar)

Presente em todas as telas com 4 abas claras:

1. **Início** — ícone de patinha;
2. **Clínicas** — ícone de mapa/livro;
3. **Linha do Tempo** — ícone de calendário;
4. **Perfil** —

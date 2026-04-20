# ShortFlow

> Aplicativo iOS de encurtamento de URLs construído com **Clean Architecture**, **Unidirectional Data Flow (UDF)** e zero dependências externas.

---

## Sumário

- [Visão Geral](#visão-geral)
- [Requisitos](#requisitos)
- [Arquitetura](#arquitetura)
  - [Por que Clean Architecture?](#por-que-clean-architecture)
  - [Por que UDF no Presentation Layer?](#por-que-udf-no-presentation-layer)
  - [Camadas e Responsabilidades](#camadas-e-responsabilidades)
  - [Fluxo de Dados](#fluxo-de-dados)
  - [Diagrama de Dependências](#diagrama-de-dependências)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Componentes em Detalhe](#componentes-em-detalhe)
  - [Data Layer](#data-layer)
  - [Domain Layer](#domain-layer)
  - [Presentation Layer](#presentation-layer)
- [Testes](#testes)
  - [Estratégia de Testes](#estratégia-de-testes)
  - [Test Doubles](#test-doubles)
  - [Cobertura por Camada](#cobertura-por-camada)
- [Localização](#localização)
- [Como Contribuir](#como-contribuir)
- [Decisões Técnicas e Trade-offs](#decisões-técnicas-e-trade-offs)

---

## Visão Geral

**ShortFlow** é um aplicativo iOS nativo que permite ao usuário encurtar URLs de forma rápida e direta. O app se comunica com uma API externa para gerar aliases de URLs (links curtos), valida as entradas do usuário localmente antes de qualquer requisição de rede e apresenta o resultado de forma reativa.

O projeto foi construído como um **challenge técnico**, priorizando:

- **Testabilidade máxima** em todas as camadas
- **Separação rigorosa de responsabilidades**
- **Ausência total de dependências externas** (zero SPM packages, zero CocoaPods)
- **Arquitetura escalável e previsível**

---

## Requisitos

| Item | Versão |
|------|--------|
| iOS | 26.1+ |
| Xcode | 26.1.1+ |
| Swift | 5.0 |
| Dependências externas | Nenhuma |

> **Nota:** O deployment target em iOS 26.1 indica uso de Xcode beta / APIs de próxima geração. Certifique-se de estar com o toolchain correto antes de compilar.

---

## Arquitetura

### Por que Clean Architecture?

A **Clean Architecture** (Robert C. Martin) foi escolhida porque impõe uma regra fundamental: **dependências apontam apenas para dentro** — do framework em direção ao domínio, nunca o contrário.

Em termos práticos para um projeto iOS, isso significa:

1. **O Domain Layer não conhece UIKit, SwiftUI, URLSession ou qualquer framework de plataforma.** É Swift puro. Pode ser testado sem simular nada do sistema.
2. **O Data Layer conhece o Domain, mas o Domain nunca conhece o Data.** A inversão de dependência via protocolos garante que qualquer implementação de rede pode ser trocada sem alterar uma linha de regra de negócio.
3. **O Presentation Layer conhece apenas o Domain (Use Cases).** A UI nunca toca diretamente em repositórios ou clientes de rede.

Para um aplicativo de encurtamento de URLs, esse nível de separação pode parecer overengineering à primeira vista — mas os benefícios se materializam imediatamente na **suíte de testes**: cada camada é testada de forma completamente isolada, sem stubs de rede, sem simuladores de UI.

### Por que UDF no Presentation Layer?

O padrão **Unidirectional Data Flow** (UDF), implementado via `Store` + `Reducer`, foi escolhido para o Presentation Layer pelos seguintes motivos:

**Previsibilidade de estado:** Todo o estado da UI vive em uma única `struct` imutável (`State`). Não existe estado espalhado em `@State`, propriedades de ViewController ou singletons. Em qualquer ponto da execução, o estado da tela é completamente observável e determinístico.

**Testabilidade da lógica de apresentação:** O `Reducer` é uma função pura: `(State, Action) -> State`. Isso significa que testar toda a lógica de apresentação — inclusive casos de erro, loading states e validações — não requer instanciar uma view, um coordinator ou qualquer objeto de UI. É matemática aplicada a structs Swift.

**Rastreabilidade:** Toda mutação de estado passa obrigatoriamente por uma `Action`. Isso cria um log auditável de tudo que aconteceu na tela, similar a um event sourcing local — útil para debugging e para implementar funcionalidades como desfazer ações no futuro.

**Implementação própria vs TCA:** O projeto implementa o padrão UDF do zero, sem utilizar o framework [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture). Essa decisão elimina uma dependência pesada e demonstra compreensão profunda do padrão, não apenas uso de biblioteca.

### Camadas e Responsabilidades

```
┌─────────────────────────────────────────────┐
│            Presentation Layer               │
│   HomeStore · HomeReducer · HomeView(UI)    │
│   Conhece: Domain (Use Cases)               │
├─────────────────────────────────────────────┤
│              Domain Layer                   │
│   CreateAliasUseCase · URLValidator         │
│   Conhece: Abstrações próprias (protocolos) │
├─────────────────────────────────────────────┤
│               Data Layer                    │
│   URLRepository · NetworkClient             │
│   CreateAliasResponseDTO                    │
│   Conhece: Domain (implementa protocolos)   │
└─────────────────────────────────────────────┘
```

| Camada | Responsabilidade | Frameworks iOS permitidos |
|--------|-----------------|--------------------------|
| **Domain** | Regras de negócio puras | Nenhum |
| **Data** | Acesso a dados e rede | Foundation (URLSession) |
| **Presentation** | Estado e lógica de UI | SwiftUI / UIKit, Combine/async |

### Fluxo de Dados

```
[User Action]
      │
      ▼
[HomeStore.send(action)]
      │
      ▼
[HomeReducer.reduce(state, action)] ──► [Novo State]
      │                                       │
      │ (side effect: useCase)                ▼
      │                               [View re-renderiza]
      ▼
[CreateAliasUseCase.execute(url)]
      │
      ├── [URLValidator.validate(url)] ──► Error (domínio)
      │
      └── [URLRepository.createAlias(url)]
                │
                ▼
          [NetworkClient.request(...)]
                │
                ▼
          [CreateAliasResponseDTO] ──► [Domain Model]
                │
                ▼
          [Action de resposta enviada de volta ao Store]
```

**Princípio:** nenhum dado desce pela árvore de views. A view apenas envia ações e observa o estado. O estado sempre flui de cima para baixo, e as ações sempre sobem de baixo para cima.

### Diagrama de Dependências

```
Presentation ──depends on──► Domain ◄──depends on── Data
                                │
                         (defines protocols)
                                │
                    ┌───────────┴───────────┐
              URLRepository          URLValidator
              (protocol)             (protocol)
                    │                      │
              URLRepositoryImpl      URLValidatorImpl
              (Data Layer)           (Domain Layer)
```

A seta de dependência nunca aponta para fora do Domain. Isso é o **Dependency Rule** da Clean Architecture em prática.

---

## Estrutura do Projeto

```
ShortFlow/
├── App/
│   ├── ShortFlowApp.swift          # Entry point (@main)
│   └── ContentView.swift           # Root view / Composition Root
│
├── Domain/
│   ├── UseCases/
│   │   └── CreateAliasUseCase.swift    # Protocolo + implementação
│   ├── Validators/
│   │   └── URLValidator.swift          # Regra de validação de URL
│   └── Models/
│       └── (domain models)
│
├── Data/
│   ├── Repositories/
│   │   └── URLRepository.swift         # Implementação de acesso à API
│   ├── Network/
│   │   └── NetworkClient.swift         # Abstração de URLSession
│   └── DTOs/
│       └── CreateAliasResponseDTO.swift # Decodificação + mapeamento
│
├── Presentation/
│   ├── Home/
│   │   ├── HomeView.swift              # UI declarativa
│   │   ├── HomeStore.swift             # Observable state container
│   │   └── HomeReducer.swift           # Função pura de transição de estado
│   └── (outras telas futuras)
│
└── Tests/
    ├── Data/
    │   ├── CreateAliasResponseDTOMappingTests.swift
    │   └── URLRepositoryTests.swift
    ├── Domain/
    │   ├── CreateAliasUseCaseTests.swift
    │   └── URLValidatorTests.swift
    ├── Presentation/
    │   ├── HomeReducerTests.swift
    │   └── HomeStoreTests.swift
    ├── UI/
    │   └── ShortFlowUITests.swift
    ├── Doubles/
    │   ├── MockCreateAliasUseCase.swift
    │   ├── MockNetworkClient.swift
    │   ├── URLRepositorySpy.swift
    │   └── URLValidatorStub.swift
    └── Helpers/
        └── XCTestCase.swift            # Extensions utilitárias
```

---

## Componentes em Detalhe

### Data Layer

#### `NetworkClient`

Abstrai completamente o `URLSession` do sistema. Definido como protocolo, permitindo substituição total por um `MockNetworkClient` em testes sem nenhuma interceptação de rede real.

**Responsabilidades:**
- Executar requisições HTTP genéricas
- Serializar/deserializar dados brutos
- Propagar erros de rede como tipos de erro do domínio

```swift
// Contrato (protocolo) — o Domain depende disso, não da implementação
protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
```

#### `CreateAliasResponseDTO`

Data Transfer Object (DTO) que representa a resposta bruta da API. Mantém separados os modelos de API (que podem mudar a qualquer momento) dos modelos de domínio (que representam conceitos estáveis do negócio).

**O mapeamento DTO → Domain Model é testado de forma independente** em `CreateAliasResponseDTOMappingTests`, garantindo que mudanças na API não passem silenciosamente para o domínio.

#### `URLRepository`

Implementa o protocolo de repositório definido no Domain Layer. É o único componente que conhece tanto a estrutura da API quanto os modelos de domínio.

**Responsabilidades:**
- Chamar o `NetworkClient` com os parâmetros corretos
- Converter o DTO de resposta em modelos de domínio
- Traduzir erros de infraestrutura em erros de domínio

### Domain Layer

#### `URLValidator`

Encapsula a regra de negócio de validação de uma URL antes de enviá-la para a API. Ao manter essa lógica no Domain Layer (em vez de na View ou no Use Case), ela se torna:

- **Reutilizável**: qualquer outra tela ou use case pode validar URLs com a mesma regra
- **Testável isoladamente**: `URLValidatorTests` verifica edge cases sem qualquer dependência de UI ou rede
- **Substituível**: `URLValidatorStub` nos testes de Use Case permite controlar o comportamento de validação independentemente

#### `CreateAliasUseCase`

Orquestra o fluxo completo de criação de um alias. Contém a única lógica de coordenação entre validação e persistência/rede.

```
CreateAliasUseCase.execute(rawURL):
  1. Delega para URLValidator.validate(rawURL)
     → Se inválido: lança erro de domínio sem fazer requisição de rede
  2. Chama URLRepository.createAlias(validatedURL)
     → Retorna o alias criado como modelo de domínio
```

**Por que o Use Case chama o Validator?** Porque a regra "só chamar a API com URLs válidas" é uma **regra de negócio**, não uma regra de apresentação. Se amanhã o app ganhar um widget ou uma extensão de Share Sheet, ambos herdarão essa proteção automaticamente.

### Presentation Layer

#### `HomeReducer`

Função pura que define todas as transições de estado possíveis na tela Home.

```swift
// Assinatura conceitual
func reduce(state: HomeState, action: HomeAction) -> HomeState
```

**Por ser uma função pura:**
- Não tem efeitos colaterais
- Retorna sempre o mesmo output para o mesmo input
- É completamente testável sem instanciar nenhum objeto de UI (`HomeReducerTests`)

#### `HomeStore`

Container de estado observável. É o único objeto que a View conhece. Recebe ações, delega ao Reducer para calcular o novo estado e dispara side effects (chamadas de Use Case) de forma assíncrona.

```swift
// Fluxo simplificado
func send(_ action: HomeAction) {
    state = reducer.reduce(state: state, action: action)
    // side effects baseados na action/state
}
```

**`HomeStoreTests`** verifica o comportamento **integrado** do Store — incluindo side effects assíncronos — enquanto `HomeReducerTests` verifica apenas as transições de estado de forma síncrona.

---

## Testes

### Estratégia de Testes

O projeto adota uma pirâmide de testes clássica com nomenclatura precisa dos test doubles, seguindo a taxonomia de Gerard Meszaros:

```
           ┌─────────────┐
           │  UI Tests   │  ← ShortFlowUITests (integração end-to-end)
           └──────┬──────┘
        ┌─────────┴──────────┐
        │  Integration Tests  │  ← HomeStoreTests (Store + UseCase real)
        └─────────┬──────────┘
   ┌──────────────┴───────────────┐
   │       Unit Tests             │  ← Reducer, UseCase, Validator, DTO
   └──────────────────────────────┘
```

**Princípio:** cada teste testa **exatamente uma coisa**. O isolamento é garantido por test doubles, não por ordem de execução ou estado compartilhado.

### Test Doubles

| Arquivo | Tipo | Propósito |
|---------|------|-----------|
| `MockCreateAliasUseCase` | **Mock** | Verifica *que* o Use Case foi chamado e *com quais argumentos* |
| `MockNetworkClient` | **Mock** | Verifica chamadas de rede sem tráfego real |
| `URLRepositorySpy` | **Spy** | Registra chamadas ao repositório; retorna valor configurável |
| `URLValidatorStub` | **Stub** | Retorna resultado pré-configurado (válido/inválido) sem lógica |

**Por que a distinção importa?**

- Um **Stub** apenas fornece respostas pré-definidas. Não verifica se foi chamado.
- Um **Spy** registra as chamadas que recebeu, permitindo assertions posteriores.
- Um **Mock** tem expectativas pré-programadas e falha se não forem atendidas.

Usar o double errado mascara bugs: um Stub no lugar de um Spy não detecta que o código deixou de chamar o repositório; um Mock no lugar de um Stub gera falsos positivos quando a ordem de chamada não importa.

### Cobertura por Camada

| Camada | Arquivo de Teste | O que é verificado |
|--------|-----------------|-------------------|
| **Data/DTO** | `CreateAliasResponseDTOMappingTests` | Parsing de JSON válido, JSON malformado, campos ausentes |
| **Data/Repository** | `URLRepositoryTests` | Delegação correta ao NetworkClient; mapeamento de erros de rede |
| **Domain/UseCase** | `CreateAliasUseCaseTests` | Fluxo feliz; rejeição de URL inválida; propagação de erro do repositório |
| **Domain/Validator** | `URLValidatorTests` | URLs válidas, inválidas, edge cases (vazio, só espaços, sem scheme) |
| **Presentation/Reducer** | `HomeReducerTests` | Cada `Action` produz o `State` correto |
| **Presentation/Store** | `HomeStoreTests` | Side effects assíncronos, sequências de ações, estado final |
| **UI** | `ShortFlowUITests` | Fluxo completo do usuário na UI real |

#### Helpers de Teste (`XCTestCase.swift`)

Extensões sobre `XCTestCase` que encapsulam patterns repetitivos como:
- Assertions assíncronas com timeout configurável
- Helpers para criar fixtures de dados de teste
- Wrappers para testar código `async throws` de forma ergonômica

---

## Localização

O projeto suporta dois idiomas nativos:

| Código | Idioma |
|--------|--------|
| `en` | English (padrão) |
| `pt-BR` | Português do Brasil |

As strings localizáveis estão organizadas em arquivos `.strings` padrão do Xcode. A adição de novos idiomas não requer mudança de código — apenas novos arquivos de localização.

---

## Como Contribuir

### Setup do Ambiente

```bash
# Clone o repositório
git clone <repo-url>
cd ShortFlow

# Abra o projeto
open ShortFlow.xcodeproj
```

Não há `pod install`, `swift package resolve` ou qualquer etapa adicional. O projeto compila imediatamente após o clone.

### Executando os Testes

```
Cmd + U  →  Executa todos os testes (Unit + UI)
```

Para executar apenas testes unitários sem o simulador:

```
Product → Test Plan → ShortFlowTests
```

### Adicionando uma Nova Feature

Siga a sequência de desenvolvimento de **fora para dentro** (Outside-In TDD):

1. **Domain primeiro:** Defina o protocolo do Use Case e os modelos de domínio
2. **Data depois:** Implemente o repositório e os DTOs; teste o mapeamento
3. **Presentation por último:** Adicione Actions e State ao Reducer; teste-os; conecte à View

Nunca deixe o Presentation Layer conhecer tipos do Data Layer diretamente.

---

## Decisões Técnicas e Trade-offs

### Zero dependências externas

**Vantagem:** Builds determinísticos, sem atualizações forçadas de biblioteca, sem superfície de ataque de supply chain, compilação mais rápida.

**Trade-off:** Funcionalidades que bibliotecas fornecem (logging estruturado, injeção de dependência automatizada) precisam ser implementadas manualmente. Para o escopo atual do app, o custo é insignificante.

### Nenhum framework de DI

A injeção de dependência é feita via **inicializadores** (constructor injection), sem containers automáticos. Isso é deliberado: containers mágicos ocultam o grafo de dependências, dificultando a compreensão do sistema. Com constructor injection, o grafo é explícito no Composition Root.

### UDF customizado vs TCA

O TCA (The Composable Architecture) é uma excelente biblioteca, mas traz conceitos avançados (reducers compostos, efeitos explícitos via `Effect`, `TestStore`) que podem ser difíceis de onboarding para times novos. A implementação própria de UDF mantém o mesmo poder conceitual com código 100% sob controle do time.

### DTO separado do modelo de domínio

Alguns projetos fazem o modelo de domínio implementar `Decodable` diretamente. Isso parece conveniente, mas cria um acoplamento silencioso: uma mudança no campo JSON (ex: `alias` → `short_url`) força uma mudança no modelo de domínio, o que pode quebrar lógica de negócio de forma inesperada. O DTO age como uma camada anticorrupção.

### `URLRepositorySpy` em vez de Mock para testes de Use Case

Nos testes do `CreateAliasUseCase`, o repositório é um Spy (não um Mock). Isso porque o Use Case não precisa que o repositório seja chamado de uma forma específica — precisa apenas do resultado. Um Mock com expectativas de chamada tornaria o teste frágil a refatorações internas do Use Case.

---

## Licença

Projeto de challenge técnico. Todos os direitos reservados.

---

*Documentação gerada com base na análise estática do projeto `ShortFlow.xcodeproj` (Xcode 26.1.1, Swift 5.0, iOS 26.1+).*

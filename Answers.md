
---

## 1. Gestión de Memoria

### Automatic Reference Counting (ARC)

**ARC** es el sistema de gestión automática de memoria de Swift que rastrea y gestiona automáticamente las referencias a objetos en memoria. Funciona contando las referencias fuertes a cada instancia de clase:

```swift
class User {
    var name: String
    init(name: String) {
        self.name = name
        print("User \(name) created")
    }
    deinit {
        print("User \(name) deallocated")
    }
}

// ARC automáticamente libera la memoria cuando no hay referencias
var user1: User? = User(name: "John") // Referencia count: 1
var user2 = user1 // Referencia count: 2
user1 = nil // Referencia count: 1
user2 = nil // Referencia count: 0 -> deinit llamado
```

### Strong, Weak y Unowned

#### Strong (por defecto)
- Incrementa el reference count
- Previene la deallocación del objeto referenciado
- Puede causar ciclos de retención

```swift
class Person {
    var name: String
    var dog: Dog? // Strong reference
    
    init(name: String) {
        self.name = name
    }
}

class Dog {
    var name: String
    var owner: Person? // Strong reference -> CICLO DE RETENCIÓN
    
    init(name: String) {
        self.name = name
    }
}
```

#### Weak
- No incrementa el reference count
- Se convierte en `nil` cuando el objeto referenciado se dealloca
- Siempre es opcional

```swift
class Person {
    var name: String
    var dog: Dog?
    
    init(name: String) {
        self.name = name
    }
}

class Dog {
    var name: String
    weak var owner: Person? // Weak reference -> NO CICLO
    
    init(name: String) {
        self.name = name
    }
}
```

#### Unowned
- No incrementa el reference count
- Asume que el objeto referenciado nunca será `nil`
- Si se accede después de dealloc, causa crash

```swift
class CreditCard {
    let number: String
    unowned let customer: Person // Unowned - asume que Person siempre existe
    
    init(number: String, customer: Person) {
        self.number = number
        self.customer = customer
    }
}
```

### Ciclos de Retención y Depuración

Un **ciclo de retención** ocurre cuando dos o más objetos se referencian mutuamente con referencias fuertes, impidiendo que ARC los libere.

#### Ejemplo de Ciclo:
```swift
class ViewController: UIViewController {
    var networkService: NetworkService?
}

class NetworkService {
    var viewController: ViewController? // CICLO!
}
```

#### Depuración:
1. **Instruments - Leaks**: Detecta memory leaks automáticamente
2. **Debug Memory Graph**: En Xcode, Debug → Debug Memory Graph
3. **deinit logs**: Agregar prints en deinit para verificar liberación

```swift
// Solución usando weak
class NetworkService {
    weak var viewController: ViewController? // NO CICLO
}
```

---

## 2. Tipos de Datos y Estructuras

### Class vs Struct

#### Class (Reference Type)
- Se pasa por referencia
- Puede heredar
- Puede tener deinit
- Mutable por defecto

```swift
class User {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

var user1 = User(name: "John", age: 30)
var user2 = user1 // Misma referencia
user2.name = "Jane" // user1.name también cambia
```

#### Struct (Value Type)
- Se pasa por valor (copia)
- No puede heredar
- Inmutable por defecto
- Más eficiente en memoria

```swift
struct Point {
    var x: Double
    var y: Double
}

var point1 = Point(x: 0, y: 0)
var point2 = point1 // Copia
point2.x = 10 // point1.x no cambia
```

#### Cuándo usar cada uno:

**Usar Struct cuando:**
- Datos simples (Point, Size, Color)
- No necesitas herencia
- Quieres comportamiento de valor
- Modelos de datos inmutables

**Usar Class cuando:**
- Necesitas herencia
- Necesitas deinit
- Quieres comportamiento de referencia
- UIViewController, NetworkService, etc.

### Copy-on-Write

**Copy-on-Write** es una optimización donde las estructuras solo se copian cuando se modifican:

```swift
struct LargeArray {
    private var storage: [Int] = Array(0..<1000000)
    
    mutating func append(_ element: Int) {
        // Solo aquí se crea una copia real
        storage.append(element)
    }
}

var array1 = LargeArray()
var array2 = array1 // No se copia, comparten storage
array2.append(42) // Ahora sí se copia
```

---

## 3. Programación Funcional y Concurrencia

### Closures

Los **closures** son bloques de código autocontenidos que pueden capturar valores de su contexto:

```swift
// Non-escaping (por defecto)
func fetchData(completion: (String) -> Void) {
    // completion se ejecuta antes de que la función termine
    completion("Data loaded")
}

// Escaping
func fetchDataAsync(completion: @escaping (String) -> Void) {
    DispatchQueue.global().async {
        // completion se ejecuta después de que la función termine
        completion("Data loaded")
    }
}
```

### Async/Await y GCD

#### Async/Await (iOS 13+)
```swift
func fetchUserData() async throws -> User {
    let url = URL(string: "https://api.example.com/user")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

// Uso
Task {
    do {
        let user = try await fetchUserData()
        print(user.name)
    } catch {
        print(error)
    }
}
```

#### Grand Central Dispatch
```swift
// Serial Queue
let serialQueue = DispatchQueue(label: "com.app.serial")

// Concurrent Queue
let concurrentQueue = DispatchQueue(label: "com.app.concurrent", attributes: .concurrent)

// Async execution
concurrentQueue.async {
    // Background work
    DispatchQueue.main.async {
        // UI updates
    }
}
```

### Higher-Order Functions

```swift
let numbers = [1, 2, 3, 4, 5]

// Map
let doubled = numbers.map { $0 * 2 } // [2, 4, 6, 8, 10]

// Filter
let evenNumbers = numbers.filter { $0 % 2 == 0 } // [2, 4]

// Reduce
let sum = numbers.reduce(0, +) // 15

// Chaining
let result = numbers
    .filter { $0 % 2 == 0 }
    .map { $0 * 2 }
    .reduce(0, +) // 12
```

---

## 4. Protocolos y Genéricos

### Programación Orientada a Protocolos (POP)

**POP** es un paradigma donde los protocolos definen contratos que las implementaciones deben cumplir:

```swift
// Protocolo como contrato
protocol NetworkServiceProtocol {
    func fetchData(completion: @escaping (Result<Data, Error>) -> Void)
}

// Implementación concreta
class NetworkService: NetworkServiceProtocol {
    func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
        // Implementación real
    }
}

// Mock para testing
class MockNetworkService: NetworkServiceProtocol {
    func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
        // Datos de prueba
    }
}
```

**Ventajas sobre POO:**
- Mejor testabilidad
- Menor acoplamiento
- Composición sobre herencia
- Flexibilidad en implementaciones

### Genéricos

Los **genéricos** permiten escribir código reutilizable que funciona con múltiples tipos:

```swift
// Función genérica
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

// Tipo genérico
struct Stack<Element> {
    private var items: [Element] = []
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
}

// Uso
var intStack = Stack<Int>()
var stringStack = Stack<String>()
```

---

## 5. Principios SOLID

### S - Principio de Responsabilidad Única

**Definición**: Una clase debe tener una sola responsabilidad.

#### Ejemplo de Violación:
```swift
class UserViewController: UIViewController {
    // VIOLA SRP - Múltiples responsabilidades
    
    func fetchUserData() {
        // Responsabilidad 1: Networking
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Responsabilidad 2: Parsing JSON
            let user = try? JSONDecoder().decode(User.self, from: data)
            
            // Responsabilidad 3: UI Updates
            DispatchQueue.main.async {
                self.updateUI(with: user)
            }
        }.resume()
    }
    
    func updateUI(with user: User?) {
        // Responsabilidad 4: UI Logic
    }
}
```

#### Refactorización:
```swift
// Responsabilidad 1: Networking
protocol NetworkServiceProtocol {
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void)
}

// Responsabilidad 2: Data Parsing
protocol DataParserProtocol {
    func parseUser(from data: Data) throws -> User
}

// Responsabilidad 3: UI Updates
protocol UserViewProtocol {
    func displayUser(_ user: User)
    func displayError(_ error: Error)
}

// ViewModel con responsabilidad única
class UserViewModel {
    private let networkService: NetworkServiceProtocol
    private let parser: DataParserProtocol
    
    init(networkService: NetworkServiceProtocol, parser: DataParserProtocol) {
        self.networkService = networkService
        self.parser = parser
    }
    
    func loadUser() {
        networkService.fetchUser { [weak self] result in
            // Solo maneja la lógica de negocio
        }
    }
}
```

### L - Principio de Sustitución de Liskov

**Definición**: Los objetos de una superclase deben poder ser reemplazados por objetos de sus subclases sin afectar la funcionalidad.

#### Ejemplo:
```swift
protocol Bird {
    func fly()
}

class Sparrow: Bird {
    func fly() {
        print("Sparrow flying")
    }
}

class Penguin: Bird {
    func fly() {
        // VIOLA LSP - Penguin no puede volar
        fatalError("Penguins can't fly!")
    }
}
```

#### Solución:
```swift
protocol Bird {
    func move()
}

protocol FlyingBird: Bird {
    func fly()
}

class Sparrow: FlyingBird {
    func move() { fly() }
    func fly() { print("Sparrow flying") }
}

class Penguin: Bird {
    func move() { print("Penguin walking") }
}
```

### D - Principio de Inversión de Dependencias

**Definición**: Los módulos de alto nivel no deben depender de módulos de bajo nivel. Ambos deben depender de abstracciones.

#### Implementación con Inyección de Dependencias:

```swift
// Abstracción
protocol NetworkServiceProtocol {
    func fetchArticles(completion: @escaping (Result<[Article], Error>) -> Void)
}

// Implementación concreta
class NetworkService: NetworkServiceProtocol {
    func fetchArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        // Implementación real
    }
}

// Mock para testing
class MockNetworkService: NetworkServiceProtocol {
    func fetchArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        // Datos de prueba
    }
}

// ViewModel que depende de abstracción
class ArticlesViewModel {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func loadArticles() {
        networkService.fetchArticles { [weak self] result in
            // Maneja el resultado
        }
    }
}

// Uso
let realService = NetworkService()
let mockService = MockNetworkService()
let viewModel = ArticlesViewModel(networkService: realService) // o mockService
```

---

## 6. Arquitectura y Patrones de Diseño

### Arquitectura Modular

**Arquitectura modular** divide la aplicación en módulos independientes y reutilizables.

#### Beneficios:
- **Reutilización**: Módulos pueden usarse en otras apps
- **Testabilidad**: Cada módulo se puede testear independientemente
- **Mantenibilidad**: Cambios en un módulo no afectan otros
- **Escalabilidad**: Fácil agregar nuevos módulos

#### Implementación con Swift Packages:

```swift
// Package.swift
let package = Package(
    name: "MyApp",
    products: [
        .library(name: "NetworkLayer", targets: ["NetworkLayer"]),
        .library(name: "DataLayer", targets: ["DataLayer"]),
        .library(name: "PresentationLayer", targets: ["PresentationLayer"])
    ],
    dependencies: [],
    targets: [
        .target(name: "NetworkLayer"),
        .target(name: "DataLayer", dependencies: ["NetworkLayer"]),
        .target(name: "PresentationLayer", dependencies: ["DataLayer"])
    ]
)
```

### Estrategias de Persistencia

#### UserDefaults
```swift
// Para configuraciones simples
UserDefaults.standard.set("John", forKey: "userName")
let userName = UserDefaults.standard.string(forKey: "userName")
```

#### Core Data
```swift
// Para datos complejos y relaciones
class CoreDataManager {
    static let shared = CoreDataManager()
    
    func saveUser(_ user: User) {
        let context = persistentContainer.viewContext
        let userEntity = UserEntity(context: context)
        userEntity.name = user.name
        userEntity.age = Int16(user.age)
        
        try? context.save()
    }
}
```

#### Realm
```swift
// Alternativa a Core Data
class User: Object {
    @Persisted var name: String
    @Persisted var age: Int
}

let realm = try! Realm()
try! realm.write {
    realm.add(user)
}
```

### Patrón Coordinator

**Coordinator** maneja la navegación entre pantallas, separando la lógica de navegación de los ViewControllers.

```swift
protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let articlesVC = ArticlesListViewController()
        articlesVC.coordinator = self
        navigationController.pushViewController(articlesVC, animated: false)
    }
    
    func showArticleDetail(_ article: Article) {
        let detailVC = ArticleDetailViewController(article: article)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
```

### Patrones de Diseño GoF

#### Singleton
```swift
class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchData() {
        // Implementación
    }
}

// Uso
NetworkManager.shared.fetchData()
```

**Cuándo usar:**
- Configuraciones globales
- Servicios compartidos (URLSession.shared)
- Logging

**Peligros:**
- Difícil de testear
- Estado global mutable
- Acoplamiento fuerte

#### Factory Method
```swift
protocol CellFactory {
    func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
}

class ArticleCellFactory: CellFactory {
    func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        }
    }
}

// Uso en ViewController
class ArticlesViewController: UIViewController {
    private let cellFactory: CellFactory = ArticleCellFactory()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory.createCell(for: indexPath, in: tableView)
    }
}
```

---

## 7. Arquitectura MVVM

### Componentes y Responsabilidades

#### Model
- Representa los datos y la lógica de negocio
- No conoce la UI

```swift
struct Article {
    let id: String
    let title: String
    let content: String
    let publishedDate: Date
}
```

#### View
- Responsable solo de la presentación
- No contiene lógica de negocio
- Se comunica con ViewModel a través de bindings

```swift
class ArticlesViewController: UIViewController {
    private let viewModel: ArticlesViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.$articles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}
```

#### ViewModel
- Contiene la lógica de presentación
- No conoce la UI
- Maneja el estado de la vista

```swift
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func loadArticles() {
        isLoading = true
        networkService.fetchArticles { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let articles):
                    self?.articles = articles
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
```

### Mecanismos de Data Binding

#### Combine (iOS 13+)
```swift
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    
    func loadArticles() {
        // Lógica de carga
    }
}

// En ViewController
viewModel.$articles
    .receive(on: DispatchQueue.main)
    .sink { [weak self] articles in
        self?.updateUI(with: articles)
    }
    .store(in: &cancellables)
```

#### RxSwift
```swift
class ArticlesViewModel {
    let articles = BehaviorRelay<[Article]>(value: [])
    
    func loadArticles() {
        // Lógica de carga
    }
}

// En ViewController
viewModel.articles
    .observe(on: MainScheduler.instance)
    .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: ArticleCell.self)) { row, article, cell in
        cell.configure(with: article)
    }
    .disposed(by: disposeBag)
```

#### KVO (Key-Value Observing)
```swift
class ArticlesViewModel: NSObject {
    @objc dynamic var articles: [Article] = []
    
    func loadArticles() {
        // Lógica de carga
    }
}

// En ViewController
viewModel.observe(\.articles, options: [.new]) { [weak self] _, change in
    guard let articles = change.newValue else { return }
    self?.updateUI(with: articles)
}
```

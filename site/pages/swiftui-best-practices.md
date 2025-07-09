---
title: "SwiftUI Best Practices"
created: 2024-01-15
updated: 2025-01-09
description: "A living guide to SwiftUI patterns, practices, and common pitfalls"
changelog:
  - date: 2024-03-20
    summary: "Added section on @StateObject vs @ObservedObject"
  - date: 2024-06-15
    summary: "Updated performance tips with new Xcode 15 features"
  - date: 2024-11-01
    summary: "Added examples for custom view modifiers"
  - date: 2025-01-09
    summary: "Expanded section on navigation patterns"
---

This page documents SwiftUI best practices that I've learned through experience. It's updated regularly as new patterns emerge and the framework evolves.

## State Management

### @State vs @StateObject

Use `@State` for simple value types:

```swift
struct ContentView: View {
    @State private var count = 0
    
    var body: some View {
        Button("Count: \(count)") {
            count += 1
        }
    }
}
```

Use `@StateObject` for reference types that your view owns:

```swift
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        // ...
    }
}
```

### Avoid Capturing Self in Closures

When passing closures to child views, be careful about capturing self:

```swift
// ❌ Bad - captures self
struct ParentView: View {
    @State private var items: [Item] = []
    
    var body: some View {
        ChildView(onTap: { item in
            items.append(item) // Captures self
        })
    }
}

// ✅ Good - use weak self or extract the action
struct ParentView: View {
    @State private var items: [Item] = []
    
    var body: some View {
        ChildView(onTap: addItem)
    }
    
    func addItem(_ item: Item) {
        items.append(item)
    }
}
```

## Performance

### Use Equatable for Complex Views

For views with expensive body computations, conform to Equatable:

```swift
struct ExpensiveView: View, Equatable {
    let data: ComplexData
    
    var body: some View {
        // Expensive computation
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.data.id == rhs.data.id
    }
}
```

### Avoid AnyView When Possible

`AnyView` erases type information and can hurt performance:

```swift
// ❌ Bad
var body: some View {
    AnyView(
        condition ? Text("A") : Text("B")
    )
}

// ✅ Good
var body: some View {
    if condition {
        Text("A")
    } else {
        Text("B")
    }
}
```

## Navigation

### NavigationStack Best Practices

Use value-based navigation with NavigationStack:

```swift
struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Settings", value: Route.settings)
                NavigationLink("Profile", value: Route.profile)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .settings: SettingsView()
                case .profile: ProfileView()
                }
            }
        }
    }
}
```

## Custom View Modifiers

Create reusable view modifiers for consistent styling:

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Usage
Text("Hello")
    .cardStyle()
```

## Common Pitfalls

### Don't Create Views in Computed Properties

```swift
// ❌ Bad - creates new view instance each time
var headerView: some View {
    HStack {
        Text("Title")
        Spacer()
        Button("Action") { }
    }
}

// ✅ Good - use @ViewBuilder or func
@ViewBuilder
var headerView: some View {
    HStack {
        Text("Title")
        Spacer()
        Button("Action") { }
    }
}
```

## Testing

Test your view models separately from views:

```swift
class ContentViewModelTests: XCTestCase {
    func testItemAddition() {
        let vm = ContentViewModel()
        vm.addItem("Test")
        XCTAssertEqual(vm.items.count, 1)
        XCTAssertEqual(vm.items[0], "Test")
    }
}
```

---

*This document is actively maintained. Last major update: January 2025*
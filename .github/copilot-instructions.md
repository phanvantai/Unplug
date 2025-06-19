# Unplug - SwiftUI Project Instructions

## Project Overview
This is a SwiftUI application called "Unplug" designed to help users manage their screen time and digital wellness.

## Development Guidelines

### Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **Framework**: SwiftUI
- **Language**: Swift

### Development Approach
- **Test-Driven Development (TDD)**: Write tests first, then implement functionality
- Follow the Red-Green-Refactor cycle:
  1. Red: Write a failing test
  2. Green: Write minimal code to make the test pass
  3. Refactor: Improve code while keeping tests green

### Project Structure
```
Unplug/
├── Views/              # SwiftUI Views
├── ViewModels/         # MVVM ViewModels (ObservableObject)
├── Models/             # Data models and business logic
├── Services/           # External services and utilities
├── Tests/              # Unit and integration tests
└── Assets.xcassets/    # App resources
```

### Code Guidelines

#### Views (SwiftUI)
- Keep views focused and composable
- Extract complex views into separate components
- Use `@StateObject`, `@ObservedObject`, and `@EnvironmentObject` appropriately
- Follow SwiftUI naming conventions

#### ViewModels
- Conform to `ObservableObject`
- Use `@Published` for properties that trigger UI updates
- Handle business logic and state management
- Keep ViewModels testable and platform-independent

#### Models
- Use structs for simple data models
- Implement `Codable` when needed for persistence
- Keep models focused on data representation

#### Testing
- Write unit tests for ViewModels and Models
- Use XCTest framework
- Mock external dependencies
- Test edge cases and error conditions
- Maintain high test coverage

### Naming Conventions
- Use descriptive names for classes, methods, and variables
- Follow Swift naming guidelines
- Use PascalCase for types and camelCase for instances

### Best Practices
- Keep functions small and focused
- Use dependency injection for testability
- Handle errors gracefully
- Follow iOS Human Interface Guidelines
- Implement accessibility features
- Use async/await for asynchronous operations

### Development Workflow
1. Create failing test
2. Implement minimal code to pass test
3. Refactor if needed
4. Repeat for next feature
5. Review and integrate changes

### Key Features
- Screen time monitoring
- App usage tracking
- Digital wellness dashboard
- User-friendly SwiftUI interface
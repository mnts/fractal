# Fractal

A powerful Dart package for creating dynamic, interconnected data models with automatic database table generation for PostgreSQL or SQLite. The `fractal` package simplifies building complex data structures for applications, including AI-driven systems, by providing a flexible object model where each object corresponds to a database table with attributes so its all easily programmable.

## Features

- **Automatic Table Generation**: Define data models as Dart classes, and `fractal` automatically creates corresponding tables in PostgreSQL or SQLite.
- **Interconnected Object Model**: Objects like `NodeFractal`, `Attr`, `EventFractal`, and `Catalog` are hierarchically linked, enabling rich relationships and extensibility.
- **Attribute System**: Define attributes that map directly to database columns with customizable formats, constraints, and defaults.
- **Extensibility**: Extend base classes like `Fractal`, `EventFractal`, and `NodeFractal` to create custom models tailored to your application.
- **AI-Friendly**: Designed for easy integration into AI applications with flexible data linking and cataloging.
- **Cross-Platform**: Supports both web (WebSqlite) and native environments, as well as PostgreSQL.
- **Companion Package**: Pair with `fractal_socket` (not covered here) for seamless data synchronization between devices.

## Installation

Add `fractal` to your `pubspec.yaml`:

```yaml
dependencies:
  fractal: ^<latest_version>
```

## Simple example
```dart
import 'package:fractal/index.dart';

Future<void> main() async {
  // Initialize SQLite (WebSqlite for web, NativeSqlite for native)
  await DBF.initiate(constructDb('fractal'));

  // Or initialize PostgreSQL
  await DBF.initiate(PostgresFDBA(
    'fractal',
    username: 'name',
    password: 'psw',
  ));

  // Set up core models and system
  await SignedFractal.init(); // Basic model
  await DeviceFractal.initMy(); // Associate current device
  await FSys.setup(); // Initialize the system

    await UserFractal.init();

  // Create a new user
  final user = UserFractal(
    name: 'john_doe',
    email: 'john@example.com',
    domain: 'example.com',
    password: 'secure123',
  );

  // Persist to database
  await user.synch();
}
```

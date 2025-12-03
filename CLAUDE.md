# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About Kodi

Kodi is an award-winning free and open source software media player and entertainment hub that runs on multiple platforms (Windows, Linux, macOS, Android, iOS, tvOS, and more). It's written primarily in C++20 with a CMake build system and supports extensibility through binary addons and scripts.

## Build System and Development Commands

### Building Kodi
Kodi can only be built on Windows. Don't build it.


**Build targets:**
- `kodi` - Main executable
- `kodi-test` - Unit test executable
- `doc` - Generate Doxygen documentation
- `check` - Run all tests
- `check-valgrind` - Run tests with Valgrind (if available)
- `binary-addons` - Build binary addons

### Code Formatting

Kodi uses clang-format for code formatting. The configuration is in `.clang-format` (version 9.0+ required). Run clang-format on new files to meet style guidelines:

```bash
# Format a specific file
clang-format -i YourFile.cpp

# Format all changed files in a PR (Jenkins will check this)
```

**Key formatting rules:**
- Line length: 100 characters
- Indentation: 2 spaces
- Braces: Always on new lines
- Namespaces: Not indented (except for anonymous namespaces)
- Pointer/reference types: Left-aligned (`char* ptr;`, `const std::string& ref`)

### Dependency Management

Kodi uses a sophisticated dependency system with both internal and external dependencies:

**Internal dependencies** (built with Kodi):
- Most core dependencies are enabled by default via `ENABLE_INTERNAL_*` options
- Use `-DENABLE_INTERNAL_DEPENDENCY=OFF` to use system versions

**Key CMake options:**
- `ENABLE_TESTING=ON` - Build tests (default: ON)
- `ENABLE_PYTHON=ON` - Python support (default: ON)
- `ENABLE_DVDCSS=ON` - DVD CSS support (default: ON)
- `ENABLE_UPNP=ON` - UPnP support (default: ON)

## Code Architecture Overview

Kodi follows a **layered service-oriented architecture** with these key patterns:

### Service Broker Pattern
The central `CServiceBroker` class provides dependency injection and access to all core services:

```cpp
// Access core services
CServiceBroker::GetAddonMgr()        // Addon management
CServiceBroker::GetGUI()              // GUI components
CServiceBroker::GetSettingsComponent() // Settings system
CServiceBroker::GetJobManager()       // Background jobs
CServiceBroker::GetPlaylistPlayer()   // Playlist management
```

### Interface-Based Design
Extensive use of abstract base classes enables polymorphism and testability:

- `IPlayer` - Media player interface
- `IFile`, `IDirectory` - Filesystem abstraction
- `IWindow` - GUI window interface
- `IApplicationComponent` - Application components

### Key Architectural Layers

1. **Application Layer** (`xbmc/application/`) - Core application orchestration
2. **Service Layer** (`ServiceBroker.h`) - Dependency injection and service registry
3. **GUI Layer** (`xbmc/guilib/`) - Component-based GUI framework
4. **Media Core** (`xbmc/cores/`) - Audio/video playback engines
5. **Filesystem Layer** (`xbmc/filesystem/`) - Cross-platform file system abstraction
6. **Input System** (`xbmc/input/`) - Hardware input abstraction
7. **Addon System** (`xbmc/addons/`) - Plugin-based extensibility

### Directory Structure

**Core directories:**
- `xbmc/` - Main application code
- `xbmc/addons/` - Addon system and binary addons
- `xbmc/cores/` - Media playback engines
- `xbmc/guilib/` - GUI framework and rendering
- `xbmc/filesystem/` - Filesystem abstraction layer
- `xbmc/input/` - Input handling system
- `xbmc/platform/` - Platform-specific implementations

**Feature directories:**
- `xbmc/video/` - Video playback, dialogs, metadata
- `xbmc/music/` - Audio playback, library, tags
- `xbmc/pictures/` - Image handling and display
- `xbmc/games/` - Game support and controllers
- `xbmc/pvr/` - Personal Video Recording
- `xbmc/weather/` - Weather service integration

### Naming Conventions

- **Classes**: PascalCase with prefix:
  - `C` prefix for concrete classes (`CFileItem`, `CApplication`)
  - `I` prefix for interfaces (`IPlayer`, `IFile`)
  - `GUI` prefix for GUI controls (`GUIWindow`, `GUILabelControl`)
  - `Addon` prefix for addon-related classes
- **Variables**: camelCase, prefixed with scope:
  - `m_` for member variables
  - `ms_` for static member variables
  - `g_` for global variables
- **Functions**: PascalCase (methods), camelCase (parameters)
- **Constants**: UPPER_SNAKE_CASE
- **Namespaces**: UPPER_SNAKE_CASE (e.g., `KODI`, `XFILE`)

### Key Design Patterns

1. **Factory Pattern** - Used extensively for player implementations, filesystem protocols, GUI controls
2. **Observer Pattern** - Announcement system for component communication
3. **Service Locator Pattern** - `ServiceBroker` as central service registry
4. **Plugin Architecture** - Binary addon system for extensibility

## Development Guidelines

### Code Style
Follow the guidelines in `docs/CODE_GUIDELINES.md`:

- **Language Standard**: C++20 (avoid C++23 features)
- **Headers**: Use `#pragma once`, organize includes alphabetically by category
- **Pointers**: Use `nullptr` instead of `NULL`, prefer smart pointers
- **Constants**: Use `constexpr` over `const` when possible
- **String handling**: Prefer `std::string_view` over `std::string` for parameters
- **Loops**: Use range-based for loops when possible
- **Casting**: Use C++ style casts (`static_cast`, `dynamic_cast`, etc.)

### File Organization

**Header order** (from `docs/CODE_GUIDELINES.md`):
1. Own header file
2. Other Kodi includes (platform independent)
3. Other Kodi includes (platform specific)
4. C and C++ system files
5. Other libraries' header files
6. Special Kodi headers (PlatformDefs.h, system.h, system_gl.h)

**Anonymous namespaces**: Use for functions local to a compilation unit instead of `static`.

### Logging

Use Kodi's logging system (`xbmc/utils/log.h`):

```cpp
#include "utils/log.h"

// Basic logging
CLog::Log(LOGDEBUG, "Window size: {}x{}", width, height);

// With function name
CLog::LogF(LOGERROR, "Failed to load resource: {}", resourceName);
```

**Logging levels**: `LOGDEBUG`, `LOGINFO`, `LOGWARNING`, `LOGERROR`, `LOGFATAL`

### Error Handling

- Use exceptions sparingly, prefer return codes
- For functions that can fail, use appropriate return types
- Follow RAII principles for resource management
- Use `override` keyword when overriding virtual functions
- Mark functions `const` when they don't modify object state

## Testing

Kodi uses Google Test for unit testing:

**Test structure:**
- Test files are placed alongside source files they test
- Use descriptive test names with TEST_F for fixtures
- Mock external dependencies using Google Mock

**Running tests:**
```bash
# Build and run all tests
cmake --build . --target kodi-test
./kodi-test

# Run with specific filters
./kodi-test --gtest_filter="Filesystem*:*Test"
```

## Common Development Tasks

### Adding New Features

1. **Create topic branch** from master
2. **Follow naming conventions** and code guidelines
3. **Add appropriate tests** if testing is enabled
4. **Document new interfaces** with Doxygen comments
5. **Run clang-format** before committing
6. **Submit pull request** with descriptive commit messages

### Working with Files

Use Kodi's filesystem abstraction (`xbmc/filesystem/`):

```cpp
#include "filesystem/File.h"

// Reading files
XFILE::CFile file;
if (file.Open(filename))
{
  std::string content = file.ReadFile();
  file.Close();
}
```

### Adding GUI Components

```cpp
// Example: Adding a new control
class CGUIMyControl : public CGUIControl
{
public:
  CGUIMyControl(int parentID, int controlID, const CGUITextureInfo& textureInfo);
  void Process(unsigned int currentTime, CDirtyRegionList &dirtyregions) override;
  void Render() override;
};
```

### Adding Addons

Kodi supports both binary addons and script addons:

- **Binary addons**: Native C++ code with interface bindings
- **Script addons**: Python, JavaScript, or other scripting languages
- **Interface definitions**: Use `xbmc/addons/kodi-dev-kit/include/`

## Platform-Specific Notes

### Windows
- MSVC 2022 or later required
- Platform-specific code in `xbmc/platform/win32/`
- Use `WIN32` preprocessor definitions for Windows-only code

### Linux
- GCC 8+ or Clang 8+ required
- Platform-specific code in `xbmc/platform/linux/`
- Dependencies available through system package managers

### macOS
- Xcode 12+ required
- Platform-specific code in `xbmc/platform/darwin/`
- Uses system frameworks where available

## Addon Development

Kodi's addon system allows extending functionality:

**Add-on types:**
- PVR clients (Live TV and recordings)
- Audio decoders and visualizations
- Video decoders and players
- Game clients and input
- Weather providers
- Screensavers
- Skin themes
- Language packs
- Script addons (Python, JavaScript)

**Binary addon structure:**
```
my-addon/
├── addon.xml
├── CMakeLists.txt
├── src/
│   └── MyAddon.cpp
└── resources/
    └── ...
```

## Key Contact Points for Code Navigation

When exploring the codebase, these are common entry points:

- **`xbmc/main.cpp`** - Application entry point
- **`xbmc/application/Application.cpp`** - Core application logic
- **`xbmc/ServiceBroker.cpp`** - Service registry
- **`xbmc/guilib/WindowingFactory.cpp`** - GUI system setup
- **`xbmc/cores/playercorefactory/PlayerCoreFactory.cpp`** - Player selection logic
- **`xbmc/filesystem/FileFactory.cpp`** - Filesystem protocol registration
- **`xbmc/addons/AddonManager.cpp`** - Addon management
- **`xbmc/settings/SettingsComponent.cpp`** - Settings system
- **`xbmc/input/InputManager.cpp`** - Input handling coordination

This architecture provides a solid foundation for understanding how different parts of Kodi interact, making it easier to navigate and work with the codebase effectively.
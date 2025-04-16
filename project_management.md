# UltraHDR Image Generator Project Management

This document serves as the central hub for project management information, tracking progress, and documenting architecture decisions for the UltraHDR Image Generator project.

## Project Structure

```
ultrahdr-image-generator-apple/
├── README.md                  # Project overview and documentation
├── project_management.md      # This file - project tracking
├── LICENSE                    # Project license
├── .gitignore                 # Git ignore file
├── UltraHDRGenerator/         # Main app source code
│   ├── ultrahdr-image-generator/       # App source code
│   │   ├── Sources/           # Core app code
│   │   │   ├── App.swift      # App entry point
│   │   │   ├── Models/        # Data models
│   │   │   ├── Views/         # SwiftUI views
│   │   │   ├── Controllers/   # Business logic
│   │   │   └── Utils/         # Helper utilities
│   │   ├── Assets.xcassets    # Images and app icons
│   │   ├── Preview Content/   # SwiftUI preview assets
│   │   └── ultrahdr_image_generator.entitlements  # App entitlements
│   ├── ultrahdr-image-generator.xcodeproj/  # Xcode project file
│   ├── ultrahdr-image-generatorTests/       # Unit tests
│   └── ultrahdr-image-generatorUITests/     # UI tests
├── UltraHDRCore/              # Core processing module
│   ├── Sources/               # Core source code
│   │   ├── Wrapper/           # C++ wrapper for libultrahdr
│   │   ├── Processors/        # Image processing logic
│   │   └── ImageConverters/   # Format conversion utilities
│   └── CMakeLists.txt         # CMake build file
└── Vendor/                    # Third-party dependencies
    └── libultrahdr/           # Google's libultrahdr library
```

## Timeline and Milestones

| Phase | Description | Status | Target Date | Responsible |
|-------|-------------|--------|-------------|-------------|
| 1 | Project setup and architecture design | Completed | - | - |
| 2 | libultrahdr integration | Completed | - | - |
| 3 | Image acquisition implementation | Completed | - | - |
| 4 | UltraHDR processing pipeline | Completed | - | - |
| 5 | User interface development | Completed | - | - |
| 6 | Testing and refinement | Not Started | - | - |
| 7 | Release preparation | Not Started | - | - |

## Technical Decisions

### Architecture Decisions

| ID | Decision | Context | Alternatives Considered | Date |
|----|----------|---------|-------------------------|------|
| AD-1 | Modular architecture with separation between UI and processing layers | Need for clean separation of concerns and potential for code reuse | Monolithic design | 2023-06-15 |
| AD-2 | SwiftUI for user interface | Modern declarative UI framework with better support for multiplatform | UIKit/AppKit | 2023-06-15 |
| AD-3 | C++ wrapper for libultrahdr | Efficient bridging to the C++ library | Direct FFI calls | 2023-06-15 |
| AD-4 | Objective-C++ bridge between Swift and C++ | Better Swift interoperability | Swift C++ interop | 2023-06-15 |
| AD-5 | CIImage as primary image representation | Native Apple image format with better HDR support | UIImage/CGImage | 2023-06-15 |

### Implementation Challenges

| ID | Challenge | Description | Status | Resolution |
|----|-----------|-------------|--------|------------|
| IC-1 | CIImage HDR extraction | Extracting proper HDR data from CIImage | Implemented | Used CIImage color space detection and appropriate conversion |
| IC-2 | libultrahdr integration | Integrating C++ library into Swift project | Implemented | Created C++ wrapper with Objective-C++ bridge |
| IC-3 | Memory management | Handling large image data efficiently | Addressed | Used proper buffer management and cleanup |

## Development Log

### 2023-06-15 - Initial Project Setup and Implementation

* Created project repository and directory structure
* Designed overall architecture 
* Set up project management document
* Completed README with project details
* Downloaded and integrated libultrahdr from Google
* Implemented C++ wrapper for libultrahdr
* Created Objective-C++ bridge for Swift
* Implemented Swift UltraHDRImageProcessor
* Implemented ImageAcquisition for CIImage handling
* Created controller class to coordinate the workflow
* Implemented SwiftUI interface for the app
* Created necessary support files (Info.plist, Xcode project, etc.)

### 2025-04-17 - Project Structure Update

* Updated project directory structure
* Organized source code into modular components
* Added Utils directory for helper functions
* Configured proper test directories for unit and UI tests
* Updated project documentation to reflect current structure

## Lessons Learned

### Working with HDR Images on Apple Platforms

* Apple's HDR image support is primarily through CIImage with extended color spaces
* Extracting raw pixel data from CIImage requires understanding color spaces and formats
* SDR conversion from HDR requires proper tone mapping

### libultrahdr Integration

* The library has multiple API paths depending on input types
* Wrapping C++ code for Swift requires careful memory management
* Understanding the gain map concept is crucial for generating proper UltraHDR images

### SwiftUI for Image Processing Apps

* PhotosPicker works well for HDR image selection
* Need to handle async operations properly with Task and continuation
* UI state management is important for showing processing status

## References

1. [libultrahdr GitHub Repository](https://github.com/google/libultrahdr)
2. [Apple CIImage Documentation](https://developer.apple.com/documentation/coreimage/ciimage)
3. [UltraHDR Format Guide](https://developer.android.com/guide/topics/media/platform/hdr-image-format)
4. [SwiftUI PhotosPicker Documentation](https://developer.apple.com/documentation/photokit/photospicker)
5. [HDR Image Processing in CoreImage](https://developer.apple.com/documentation/coreimage/processing_hdr_images)

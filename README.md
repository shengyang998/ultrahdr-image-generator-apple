# UltraHDR Image Generator for Apple Platforms

This application generates UltraHDR images on iOS/macOS platforms by leveraging Apple's native CIImage capabilities and integrating Google's libultrahdr library.

## Project Overview

UltraHDR Image Generator allows users to:
1. Capture or select HDR and SDR image pairs or HDR and gainmap image pairs using native Apple frameworks
2. Process these images through the libultrahdr library
3. Generate and save standards-compliant UltraHDR images to the user's desired location

## Architecture

The project is organized into the following core components:

### 1. Image Acquisition Module
- Utilizes `CIImage` APIs to obtain HDR/SDR image pairs
- Provides options for camera capture or photo library selection
- Supports both HDR+SDR and HDR+gainmap input workflows

### 2. UltraHDR Processing Module
- Integrates Google's libultrahdr library
- Processes image inputs through the appropriate encoding API based on input type:
  - API-0/1: When providing raw HDR and SDR intents
  - API-4: When providing compressed SDR and gainmap inputs
- Manages memory for large image processing tasks

### 3. File Output Module
- Handles saving of generated UltraHDR images
- Provides file naming and destination selection
- Ensures proper file metadata and permissions

### 4. User Interface Layer
- Presents simple, intuitive controls for input selection
- Displays processing status and preview of results
- Provides output location selection

## Implementation Plan

1. **Setup libultrahdr Integration**
   - Add libultrahdr as a dependency
   - Create Objective-C/Swift bridging as needed
   - Implement wrapper interfaces for the encoding/decoding APIs

2. **Implement Image Acquisition**
   - Create interfaces for CIImage access
   - Implement HDR/SDR image pair handling
   - Add support for gainmap generation or input

3. **Develop Processing Pipeline**
   - Create processing queue for image transformation
   - Implement appropriate encoding route based on input type
   - Add progress monitoring and error handling

4. **Build User Interface**
   - Design simple, effective UI for input selection
   - Add output preview capabilities
   - Implement directory selection and saving

## Dependencies

- Apple platforms (iOS 15+/macOS 12+)
- libultrahdr (Google's UltraHDR reference implementation)
- Swift/Objective-C for platform integration

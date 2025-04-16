cmake_minimum_required(VERSION 3.10)
project(UltraHDRCore VERSION 1.0.0 LANGUAGES CXX C)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Add libultrahdr
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../Vendor/libultrahdr ${CMAKE_BINARY_DIR}/libultrahdr)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/Sources/Wrapper
    ${CMAKE_CURRENT_SOURCE_DIR}/../Vendor/libultrahdr
)

# Source files
set(SOURCES
    Sources/Wrapper/UltraHDRWrapper.cpp
)

# Add library
add_library(UltraHDRCore SHARED ${SOURCES})

# Link libraries
target_link_libraries(UltraHDRCore PUBLIC uhdr)

# Install library
install(TARGETS UltraHDRCore
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install header files
install(FILES 
    Sources/Wrapper/UltraHDRWrapper.h 
    DESTINATION include/UltraHDRCore
)

# Enable testing
enable_testing() 
#ifndef ULTRAHDR_WRAPPER_H
#define ULTRAHDR_WRAPPER_H

#include <stdio.h>
#include <memory>
#include <vector>
#include <string>

// Forward declarations to avoid including ultrahdr headers in the header
namespace ultrahdr {
    class JpegR;
}

// C++ wrapper class for UltraHDR operations
class UltraHDRWrapper {
public:
    UltraHDRWrapper();
    ~UltraHDRWrapper();
    
    // Encoding methods
    
    // API-0: Generate UltraHDR from HDR image only
    bool encodeFromHDROnly(
        const void* hdrData, size_t hdrDataSize, int width, int height, int hdrPixelFormat,
        int quality, std::vector<uint8_t>& outputData);
    
    // API-1: Generate UltraHDR from HDR and SDR raw images
    bool encodeFromHDRAndSDR(
        const void* hdrData, size_t hdrDataSize, int hdrPixelFormat,
        const void* sdrData, size_t sdrDataSize, int sdrPixelFormat,
        int width, int height, int quality,
        std::vector<uint8_t>& outputData);
    
    // API-3: Generate UltraHDR from HDR raw and SDR compressed (JPEG) images
    bool encodeFromHDRAndCompressedSDR(
        const void* hdrData, size_t hdrDataSize, int hdrPixelFormat,
        const void* sdrJpegData, size_t sdrJpegDataSize,
        int width, int height, std::vector<uint8_t>& outputData);
    
    // API-4: Generate UltraHDR from compressed SDR and gainmap
    bool encodeFromCompressedSDRAndGainmap(
        const void* sdrJpegData, size_t sdrJpegDataSize,
        const void* gainmapJpegData, size_t gainmapJpegDataSize,
        std::vector<uint8_t>& outputData);
    
    // Decoding methods
    bool decodeToHDR(
        const void* jpegrData, size_t jpegrDataSize,
        void*& outputData, size_t& outputDataSize,
        int& width, int& height, int outputPixelFormat, 
        float maxDisplayBoost = 1.0f);
    
    // Utility methods
    bool isUltraHDRImage(const void* jpegData, size_t jpegSize);
    
    // Error handling
    const char* getLastError() const;

private:
    // Pointer to ultrahdr implementation
    std::unique_ptr<ultrahdr::JpegR> jpegr_;
    std::string lastError_;
    
    // Helper methods
    void setError(const std::string& error);
};

// Constants for pixel formats (match ultrahdr's constants)
enum UltraHDRPixelFormat {
    UHDR_PIXEL_FORMAT_RGBA_8888 = 0,
    UHDR_PIXEL_FORMAT_RGBA_1010102 = 1,
    UHDR_PIXEL_FORMAT_RGBA_F16 = 2,
    UHDR_PIXEL_FORMAT_YUV420 = 3,
    UHDR_PIXEL_FORMAT_P010 = 4
};

#endif // ULTRAHDR_WRAPPER_H 
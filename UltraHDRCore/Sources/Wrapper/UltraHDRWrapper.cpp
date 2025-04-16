#include "UltraHDRWrapper.h"
#include "ultrahdr/jpegr.h"
#include "ultrahdr/gainmapmetadata.h"
#include <iostream>

UltraHDRWrapper::UltraHDRWrapper() {
    jpegr_ = std::make_unique<ultrahdr::JpegR>();
}

UltraHDRWrapper::~UltraHDRWrapper() {
    // Smart pointer will handle cleanup
}

bool UltraHDRWrapper::encodeFromHDROnly(
    const void* hdrData, size_t hdrDataSize, int width, int height, int hdrPixelFormat,
    int quality, std::vector<uint8_t>& outputData) {
    
    try {
        ultrahdr::Status status;
        std::unique_ptr<uint8_t[]> compressedJpegR;
        unsigned int compressedJpegRSize = 0;
        
        status = jpegr_->encodeJPEGR(
            static_cast<const uint8_t*>(hdrData),
            static_cast<unsigned int>(hdrDataSize),
            width, height,
            static_cast<ultrahdr::PixelFormat>(hdrPixelFormat),
            quality,
            nullptr, 0, // No EXIF
            &compressedJpegR,
            &compressedJpegRSize);
        
        if (status != ultrahdr::Status::OK) {
            setError("Failed to encode JPEGR: " + std::to_string(static_cast<int>(status)));
            return false;
        }
        
        // Copy the result to output buffer
        outputData.resize(compressedJpegRSize);
        std::memcpy(outputData.data(), compressedJpegR.get(), compressedJpegRSize);
        
        return true;
    } catch (const std::exception& e) {
        setError(std::string("Exception during encoding: ") + e.what());
        return false;
    }
}

bool UltraHDRWrapper::encodeFromHDRAndSDR(
    const void* hdrData, size_t hdrDataSize, int hdrPixelFormat,
    const void* sdrData, size_t sdrDataSize, int sdrPixelFormat,
    int width, int height, int quality,
    std::vector<uint8_t>& outputData) {
    
    try {
        ultrahdr::Status status;
        std::unique_ptr<uint8_t[]> compressedJpegR;
        unsigned int compressedJpegRSize = 0;
        
        status = jpegr_->encodeJPEGR(
            static_cast<const uint8_t*>(hdrData),
            static_cast<unsigned int>(hdrDataSize),
            static_cast<const uint8_t*>(sdrData),
            static_cast<unsigned int>(sdrDataSize),
            width, height,
            static_cast<ultrahdr::PixelFormat>(hdrPixelFormat),
            static_cast<ultrahdr::PixelFormat>(sdrPixelFormat),
            quality,
            nullptr, 0, // No EXIF
            &compressedJpegR,
            &compressedJpegRSize);
        
        if (status != ultrahdr::Status::OK) {
            setError("Failed to encode JPEGR: " + std::to_string(static_cast<int>(status)));
            return false;
        }
        
        // Copy the result to output buffer
        outputData.resize(compressedJpegRSize);
        std::memcpy(outputData.data(), compressedJpegR.get(), compressedJpegRSize);
        
        return true;
    } catch (const std::exception& e) {
        setError(std::string("Exception during encoding: ") + e.what());
        return false;
    }
}

bool UltraHDRWrapper::encodeFromHDRAndCompressedSDR(
    const void* hdrData, size_t hdrDataSize, int hdrPixelFormat,
    const void* sdrJpegData, size_t sdrJpegDataSize,
    int width, int height, std::vector<uint8_t>& outputData) {
    
    try {
        ultrahdr::Status status;
        std::unique_ptr<uint8_t[]> compressedJpegR;
        unsigned int compressedJpegRSize = 0;
        
        status = jpegr_->encodeJPEGR(
            static_cast<const uint8_t*>(hdrData),
            static_cast<unsigned int>(hdrDataSize),
            width, height,
            static_cast<ultrahdr::PixelFormat>(hdrPixelFormat),
            static_cast<const uint8_t*>(sdrJpegData),
            static_cast<unsigned int>(sdrJpegDataSize),
            &compressedJpegR,
            &compressedJpegRSize);
        
        if (status != ultrahdr::Status::OK) {
            setError("Failed to encode JPEGR: " + std::to_string(static_cast<int>(status)));
            return false;
        }
        
        // Copy the result to output buffer
        outputData.resize(compressedJpegRSize);
        std::memcpy(outputData.data(), compressedJpegR.get(), compressedJpegRSize);
        
        return true;
    } catch (const std::exception& e) {
        setError(std::string("Exception during encoding: ") + e.what());
        return false;
    }
}

bool UltraHDRWrapper::encodeFromCompressedSDRAndGainmap(
    const void* sdrJpegData, size_t sdrJpegDataSize,
    const void* gainmapJpegData, size_t gainmapJpegDataSize,
    std::vector<uint8_t>& outputData) {
    
    try {
        ultrahdr::Status status;
        std::unique_ptr<uint8_t[]> compressedJpegR;
        unsigned int compressedJpegRSize = 0;
        
        // Create default metadata for the gain map
        ultrahdr::GainMapMetadata metadata;
        
        status = jpegr_->encodeJPEGR(
            static_cast<const uint8_t*>(sdrJpegData),
            static_cast<unsigned int>(sdrJpegDataSize),
            static_cast<const uint8_t*>(gainmapJpegData),
            static_cast<unsigned int>(gainmapJpegDataSize),
            metadata,
            &compressedJpegR,
            &compressedJpegRSize);
        
        if (status != ultrahdr::Status::OK) {
            setError("Failed to encode JPEGR: " + std::to_string(static_cast<int>(status)));
            return false;
        }
        
        // Copy the result to output buffer
        outputData.resize(compressedJpegRSize);
        std::memcpy(outputData.data(), compressedJpegR.get(), compressedJpegRSize);
        
        return true;
    } catch (const std::exception& e) {
        setError(std::string("Exception during encoding: ") + e.what());
        return false;
    }
}

bool UltraHDRWrapper::decodeToHDR(
    const void* jpegrData, size_t jpegrDataSize,
    void*& outputData, size_t& outputDataSize,
    int& width, int& height, int outputPixelFormat,
    float maxDisplayBoost) {
    
    try {
        ultrahdr::Status status;
        std::unique_ptr<uint8_t[]> decodedHdr;
        unsigned int decodedHdrSize = 0;
        
        status = jpegr_->decodeJPEGR(
            static_cast<const uint8_t*>(jpegrData),
            static_cast<unsigned int>(jpegrDataSize),
            maxDisplayBoost,
            static_cast<ultrahdr::PixelFormat>(outputPixelFormat),
            &decodedHdr,
            &decodedHdrSize,
            &width,
            &height);
        
        if (status != ultrahdr::Status::OK) {
            setError("Failed to decode JPEGR: " + std::to_string(static_cast<int>(status)));
            return false;
        }
        
        // Allocate and copy the decoded data
        outputDataSize = decodedHdrSize;
        outputData = malloc(outputDataSize);
        if (!outputData) {
            setError("Failed to allocate memory for decoded data");
            return false;
        }
        
        std::memcpy(outputData, decodedHdr.get(), decodedHdrSize);
        
        return true;
    } catch (const std::exception& e) {
        setError(std::string("Exception during decoding: ") + e.what());
        return false;
    }
}

bool UltraHDRWrapper::isUltraHDRImage(const void* jpegData, size_t jpegSize) {
    try {
        ultrahdr::Status status = jpegr_->isJPEGR(
            static_cast<const uint8_t*>(jpegData),
            static_cast<unsigned int>(jpegSize));
        
        return status == ultrahdr::Status::OK;
    } catch (const std::exception& e) {
        setError(std::string("Exception during isUltraHDRImage: ") + e.what());
        return false;
    }
}

const char* UltraHDRWrapper::getLastError() const {
    return lastError_.c_str();
}

void UltraHDRWrapper::setError(const std::string& error) {
    lastError_ = error;
    std::cerr << "UltraHDRWrapper error: " << error << std::endl;
} 
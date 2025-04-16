import Foundation
import CoreImage

/// Errors that can occur during UltraHDR image processing
enum UltraHDRProcessorError: Error {
    case encodingFailed(String)
    case decodingFailed(String)
    case invalidImage
    case ciImageConversionFailed
    case invalidPixelFormat
    case dataExtractionFailed
}

/// Class for processing UltraHDR images using the UltraHDRWrapperObjC
class UltraHDRImageProcessor {
    private let wrapper = UltraHDRWrapperObjC()
    
    /// Generate UltraHDR image from HDR image only
    /// - Parameters:
    ///   - hdrImage: The HDR CIImage
    ///   - quality: JPEG quality (0-100)
    /// - Returns: Data containing the encoded UltraHDR image
    func generateUltraHDRFromHDROnly(hdrImage: CIImage, quality: Int = 90) throws -> Data {
        guard let pixelFormat = getPixelFormat(from: hdrImage) else {
            throw UltraHDRProcessorError.invalidPixelFormat
        }
        
        guard let hdrData = extractImageData(from: hdrImage) else {
            throw UltraHDRProcessorError.dataExtractionFailed
        }
        
        let width = Int(hdrImage.extent.width)
        let height = Int(hdrImage.extent.height)
        
        var outputData: NSMutableData?
        let success = wrapper.encodeFromHDROnly(
            hdrData,
            width: width,
            height: height,
            hdrPixelFormat: pixelFormat.rawValue,
            quality: quality,
            output: &outputData
        )
        
        if success, let data = outputData {
            return data as Data
        } else {
            throw UltraHDRProcessorError.encodingFailed(wrapper.lastError() ?? "Unknown error")
        }
    }
    
    /// Generate UltraHDR image from HDR and SDR images
    /// - Parameters:
    ///   - hdrImage: The HDR CIImage
    ///   - sdrImage: The SDR CIImage
    ///   - quality: JPEG quality (0-100)
    /// - Returns: Data containing the encoded UltraHDR image
    func generateUltraHDRFromHDRAndSDR(hdrImage: CIImage, sdrImage: CIImage, quality: Int = 90) throws -> Data {
        guard let hdrPixelFormat = getPixelFormat(from: hdrImage),
              let sdrPixelFormat = getPixelFormat(from: sdrImage) else {
            throw UltraHDRProcessorError.invalidPixelFormat
        }
        
        guard let hdrData = extractImageData(from: hdrImage),
              let sdrData = extractImageData(from: sdrImage) else {
            throw UltraHDRProcessorError.dataExtractionFailed
        }
        
        let width = Int(hdrImage.extent.width)
        let height = Int(hdrImage.extent.height)
        
        var outputData: NSMutableData?
        let success = wrapper.encodeFromHDRAndSDR(
            hdrData,
            hdrPixelFormat: hdrPixelFormat.rawValue,
            sdrData: sdrData,
            sdrPixelFormat: sdrPixelFormat.rawValue,
            width: width,
            height: height,
            quality: quality,
            output: &outputData
        )
        
        if success, let data = outputData {
            return data as Data
        } else {
            throw UltraHDRProcessorError.encodingFailed(wrapper.lastError() ?? "Unknown error")
        }
    }
    
    /// Generate UltraHDR image from HDR and compressed SDR image
    /// - Parameters:
    ///   - hdrImage: The HDR CIImage
    ///   - sdrJpegData: Data containing a compressed JPEG SDR image
    /// - Returns: Data containing the encoded UltraHDR image
    func generateUltraHDRFromHDRAndCompressedSDR(hdrImage: CIImage, sdrJpegData: Data) throws -> Data {
        guard let hdrPixelFormat = getPixelFormat(from: hdrImage) else {
            throw UltraHDRProcessorError.invalidPixelFormat
        }
        
        guard let hdrData = extractImageData(from: hdrImage) else {
            throw UltraHDRProcessorError.dataExtractionFailed
        }
        
        let width = Int(hdrImage.extent.width)
        let height = Int(hdrImage.extent.height)
        
        var outputData: NSMutableData?
        let success = wrapper.encodeFromHDRAndCompressedSDR(
            hdrData,
            hdrPixelFormat: hdrPixelFormat.rawValue,
            sdrJpegData: sdrJpegData,
            width: width,
            height: height,
            output: &outputData
        )
        
        if success, let data = outputData {
            return data as Data
        } else {
            throw UltraHDRProcessorError.encodingFailed(wrapper.lastError() ?? "Unknown error")
        }
    }
    
    /// Generate UltraHDR image from compressed SDR and gain map
    /// - Parameters:
    ///   - sdrJpegData: Data containing a compressed JPEG SDR image
    ///   - gainmapJpegData: Data containing a compressed JPEG gain map
    /// - Returns: Data containing the encoded UltraHDR image
    func generateUltraHDRFromCompressedSDRAndGainmap(sdrJpegData: Data, gainmapJpegData: Data) throws -> Data {
        var outputData: NSMutableData?
        let success = wrapper.encodeFromCompressedSDRAndGainmap(
            sdrJpegData,
            gainmapJpegData: gainmapJpegData,
            output: &outputData
        )
        
        if success, let data = outputData {
            return data as Data
        } else {
            throw UltraHDRProcessorError.encodingFailed(wrapper.lastError() ?? "Unknown error")
        }
    }
    
    /// Check if data represents an UltraHDR image
    /// - Parameter jpegData: JPEG image data to check
    /// - Returns: true if the image is an UltraHDR image, false otherwise
    func isUltraHDRImage(jpegData: Data) -> Bool {
        return wrapper.isUltraHDRImage(jpegData)
    }
    
    // MARK: - Private helpers
    
    private func getPixelFormat(from image: CIImage) -> UltraHDRPixelFormat? {
        // Check the color space and bit depth of the CIImage to determine the pixel format
        // Note: This is a simplified implementation and would need to be expanded based on
        // the actual properties of CIImage in your application
        
        if let colorSpace = image.colorSpace {
            if colorSpace.name == CGColorSpace.extendedLinearSRGB {
                // HDR image with linear color space, likely F16
                return .UltraHDRPixelFormatRGBAF16
            } else if colorSpace.name == CGColorSpace.extendedSRGB {
                // HDR image with non-linear color space, likely 1010102
                return .UltraHDRPixelFormatRGBA1010102
            } else {
                // Standard SDR image
                return .UltraHDRPixelFormatRGBA8888
            }
        }
        
        // Default to RGBA8888 if we can't determine
        return .UltraHDRPixelFormatRGBA8888
    }
    
    private func extractImageData(from image: CIImage) -> Data? {
        // This is a placeholder implementation - in a real app, you would need to
        // convert the CIImage to raw pixel data in the correct format
        
        let context = CIContext()
        let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        
        // Create a bitmap representation
        if let pixelFormat = getPixelFormat(from: image) {
            switch pixelFormat {
            case .UltraHDRPixelFormatRGBA8888:
                return context.tiffRepresentation(of: image, format: .RGBA8, colorSpace: colorSpace)
                
            case .UltraHDRPixelFormatRGBA1010102, .UltraHDRPixelFormatRGBAF16:
                // Note: In a real implementation, you would need to handle these formats specifically
                // This is just a placeholder that needs to be replaced with actual conversion code
                if let cgImage = context.createCGImage(image, from: image.extent) {
                    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
                    let width = Int(image.extent.width)
                    let height = Int(image.extent.height)
                    
                    let bytesPerRow = width * 4 // 4 bytes per pixel for RGBA8888
                    let data = NSMutableData(length: height * bytesPerRow)
                    
                    if let data = data, let context = CGContext(
                        data: data.mutableBytes,
                        width: width,
                        height: height,
                        bitsPerComponent: 8,
                        bytesPerRow: bytesPerRow,
                        space: colorSpace,
                        bitmapInfo: bitmapInfo.rawValue) {
                        
                        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
                        return data as Data
                    }
                }
                return nil
                
            default:
                return nil
            }
        }
        
        return nil
    }
} 
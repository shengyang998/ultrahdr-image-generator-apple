import Foundation
import CoreImage
import AVFoundation
import PhotosUI

/// Errors that can occur during image acquisition
enum ImageAcquisitionError: Error {
    case imageLoadFailed
    case hdrNotSupported
    case imageConversionFailed
    case metadataExtractionFailed
}

/// Class responsible for acquiring HDR and SDR images using CIImage
class ImageAcquisition {
    
    private let ciContext = CIContext()
    
    /// Load an image from a URL
    /// - Parameter url: URL of the image file
    /// - Returns: CIImage of the loaded image
    func loadImage(from url: URL) throws -> CIImage {
        guard let image = CIImage(contentsOf: url) else {
            throw ImageAcquisitionError.imageLoadFailed
        }
        return image
    }
    
    /// Load an image from data
    /// - Parameter data: Data containing the image
    /// - Returns: CIImage of the loaded image
    func loadImage(from data: Data) throws -> CIImage {
        guard let image = CIImage(data: data) else {
            throw ImageAcquisitionError.imageLoadFailed
        }
        return image
    }
    
    /// Get HDR image from a PHAsset
    /// - Parameter asset: The PHAsset to load
    /// - Returns: A tuple containing the HDR image and possibly the SDR image if available
    func getHDRImage(from asset: PHAsset) async throws -> (hdr: CIImage, sdr: CIImage?) {
        // Check if asset supports HDR
        if !asset.supportsDynamicRange {
            throw ImageAcquisitionError.hdrNotSupported
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.version = .current
            
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, orientation, info in
                guard let data = data else {
                    continuation.resume(throwing: ImageAcquisitionError.imageLoadFailed)
                    return
                }
                
                do {
                    // Load HDR image
                    var ciImage = try self.loadImage(from: data)
                    
                    // Apply orientation if needed
                    if orientation != .up {
                        ciImage = ciImage.oriented(forExifOrientation: orientation.rawValue)
                    }
                    
                    // Create SDR version if needed
                    let sdrImage = self.createSDRVersion(from: ciImage)
                    
                    continuation.resume(returning: (hdr: ciImage, sdr: sdrImage))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Create SDR version from an HDR image
    /// - Parameter hdrImage: The HDR image to convert
    /// - Returns: SDR version of the image or nil if conversion failed
    func createSDRVersion(from hdrImage: CIImage) -> CIImage? {
        // Create a tone mapping filter to convert HDR to SDR
        if let filter = CIFilter(name: "CIToneCurve") {
            filter.setValue(hdrImage, forKey: kCIInputImageKey)
            
            // Configure tone mapping parameters - these would need to be adjusted
            // for optimal tone mapping based on your requirements
            filter.setValue(0.0, forKey: "inputPoint0")
            filter.setValue(0.25, forKey: "inputPoint1")
            filter.setValue(0.5, forKey: "inputPoint2")
            filter.setValue(0.75, forKey: "inputPoint3")
            filter.setValue(1.0, forKey: "inputPoint4")
            
            return filter.outputImage
        }
        return nil
    }
    
    /// Extract gain map from an HDR image and its SDR version
    /// - Parameters:
    ///   - hdrImage: The HDR image
    ///   - sdrImage: The SDR image
    /// - Returns: A CIImage containing the gain map
    func extractGainMap(from hdrImage: CIImage, sdrImage: CIImage) -> CIImage? {
        // This is a simplified implementation - in reality, computing a gain map
        // requires more sophisticated algorithms that compute the ratio between
        // HDR and SDR images and apply various transformations
        
        // For now, we'll use a simple division filter to estimate the ratio
        if let divideFilter = CIFilter(name: "CIDivideBlendMode") {
            divideFilter.setValue(hdrImage, forKey: kCIInputImageKey)
            divideFilter.setValue(sdrImage, forKey: kCIInputBackgroundImageKey)
            
            if let gainMap = divideFilter.outputImage {
                // Apply some post-processing to the gain map
                if let gammaFilter = CIFilter(name: "CIGammaAdjust") {
                    gammaFilter.setValue(gainMap, forKey: kCIInputImageKey)
                    gammaFilter.setValue(0.5, forKey: "inputPower") // Adjust as needed
                    return gammaFilter.outputImage
                }
            }
        }
        
        return nil
    }
    
    /// Convert CIImage to JPEG data
    /// - Parameters:
    ///   - image: The CIImage to convert
    ///   - quality: JPEG quality (0.0-1.0)
    /// - Returns: JPEG Data
    func convertToJPEG(image: CIImage, quality: CGFloat = 0.9) -> Data? {
        guard let cgImage = ciContext.createCGImage(image, from: image.extent) else {
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.jpegData(compressionQuality: quality)
    }
    
    /// Check if a CIImage is HDR
    /// - Parameter image: The image to check
    /// - Returns: true if the image is HDR, false otherwise
    func isHDRImage(_ image: CIImage) -> Bool {
        if let colorSpace = image.colorSpace {
            return colorSpace.name == CGColorSpace.extendedLinearSRGB ||
                   colorSpace.name == CGColorSpace.extendedSRGB
        }
        return false
    }
} 
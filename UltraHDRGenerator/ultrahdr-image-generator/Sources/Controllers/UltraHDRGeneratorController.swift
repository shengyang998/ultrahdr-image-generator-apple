import Foundation
import CoreImage
import PhotosUI

/// Errors that can occur during the UltraHDR generation process
enum UltraHDRGeneratorError: Error {
    case processingFailed(String)
    case invalidInputImage
    case saveError(String)
}

/// Callback type for when UltraHDR generation completes
typealias UltraHDRGenerationCompletion = (Result<URL, Error>) -> Void

/// Controller class that orchestrates the UltraHDR generation workflow
class UltraHDRGeneratorController {
    
    private let imageAcquisition = ImageAcquisition()
    private let imageProcessor = UltraHDRImageProcessor()
    
    /// Generate an UltraHDR image from a PHAsset
    /// - Parameters:
    ///   - asset: The PHAsset to use as input
    ///   - outputDirectory: Directory where the output file should be saved
    ///   - completion: Callback with the result of the operation
    func generateUltraHDRFromAsset(asset: PHAsset, outputDirectory: URL, completion: @escaping UltraHDRGenerationCompletion) {
        Task {
            do {
                // Get HDR image from asset
                let (hdrImage, maybeSdrImage) = try await imageAcquisition.getHDRImage(from: asset)
                
                var outputURL: URL
                
                // Generate UltraHDR based on available images
                if let sdrImage = maybeSdrImage {
                    // We have both HDR and SDR images
                    outputURL = try generateUltraHDRFromHDRAndSDR(
                        hdrImage: hdrImage,
                        sdrImage: sdrImage,
                        outputDirectory: outputDirectory
                    )
                } else {
                    // We only have the HDR image
                    outputURL = try generateUltraHDRFromHDROnly(
                        hdrImage: hdrImage,
                        outputDirectory: outputDirectory
                    )
                }
                
                // Complete with success result on the main thread
                DispatchQueue.main.async {
                    completion(.success(outputURL))
                }
            } catch {
                // Complete with error result on the main thread
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Generate an UltraHDR image from an HDR image and optionally an SDR image
    /// - Parameters:
    ///   - hdrURL: URL of the HDR image file
    ///   - sdrURL: Optional URL of the SDR image file
    ///   - outputDirectory: Directory where the output file should be saved
    ///   - completion: Callback with the result of the operation
    func generateUltraHDRFromFiles(hdrURL: URL, sdrURL: URL? = nil, outputDirectory: URL, completion: @escaping UltraHDRGenerationCompletion) {
        Task {
            do {
                // Load HDR image
                let hdrImage = try imageAcquisition.loadImage(from: hdrURL)
                
                var outputURL: URL
                
                if let sdrURL = sdrURL {
                    // Load SDR image if provided
                    let sdrImage = try imageAcquisition.loadImage(from: sdrURL)
                    
                    // Generate UltraHDR from HDR and SDR
                    outputURL = try generateUltraHDRFromHDRAndSDR(
                        hdrImage: hdrImage,
                        sdrImage: sdrImage,
                        outputDirectory: outputDirectory
                    )
                } else {
                    // Generate UltraHDR from HDR only
                    outputURL = try generateUltraHDRFromHDROnly(
                        hdrImage: hdrImage,
                        outputDirectory: outputDirectory
                    )
                }
                
                // Complete with success result on the main thread
                DispatchQueue.main.async {
                    completion(.success(outputURL))
                }
            } catch {
                // Complete with error result on the main thread
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Generate UltraHDR from a compressed SDR and gain map
    /// - Parameters:
    ///   - sdrJpegData: JPEG data of the SDR image
    ///   - gainmapJpegData: JPEG data of the gain map
    ///   - outputDirectory: Directory where the output file should be saved
    ///   - completion: Callback with the result of the operation
    func generateUltraHDRFromCompressedSDRAndGainmap(
        sdrJpegData: Data,
        gainmapJpegData: Data,
        outputDirectory: URL,
        completion: @escaping UltraHDRGenerationCompletion
    ) {
        Task {
            do {
                // Process the images
                let ultraHDRData = try imageProcessor.generateUltraHDRFromCompressedSDRAndGainmap(
                    sdrJpegData: sdrJpegData,
                    gainmapJpegData: gainmapJpegData
                )
                
                // Save the output file
                let outputURL = try saveUltraHDRDataToFile(
                    ultraHDRData: ultraHDRData,
                    outputDirectory: outputDirectory
                )
                
                // Complete with success result on the main thread
                DispatchQueue.main.async {
                    completion(.success(outputURL))
                }
            } catch {
                // Complete with error result on the main thread
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func generateUltraHDRFromHDROnly(hdrImage: CIImage, outputDirectory: URL) throws -> URL {
        // Generate UltraHDR data
        let ultraHDRData = try imageProcessor.generateUltraHDRFromHDROnly(hdrImage: hdrImage)
        
        // Save to file
        return try saveUltraHDRDataToFile(ultraHDRData: ultraHDRData, outputDirectory: outputDirectory)
    }
    
    private func generateUltraHDRFromHDRAndSDR(hdrImage: CIImage, sdrImage: CIImage, outputDirectory: URL) throws -> URL {
        // Generate UltraHDR data
        let ultraHDRData = try imageProcessor.generateUltraHDRFromHDRAndSDR(
            hdrImage: hdrImage,
            sdrImage: sdrImage
        )
        
        // Save to file
        return try saveUltraHDRDataToFile(ultraHDRData: ultraHDRData, outputDirectory: outputDirectory)
    }
    
    private func saveUltraHDRDataToFile(ultraHDRData: Data, outputDirectory: URL) throws -> URL {
        // Create a unique filename
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "UltraHDR_\(timestamp).jpg"
        let outputURL = outputDirectory.appendingPathComponent(filename)
        
        // Write the data to file
        do {
            try ultraHDRData.write(to: outputURL)
            return outputURL
        } catch {
            throw UltraHDRGeneratorError.saveError("Failed to save UltraHDR image: \(error.localizedDescription)")
        }
    }
} 
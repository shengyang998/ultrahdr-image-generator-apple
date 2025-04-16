import SwiftUI
import PhotosUI
import CoreImage

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var hdrImage: UIImage?
    @State private var sdrImage: UIImage?
    @State private var isProcessing = false
    @State private var outputURL: URL?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingSuccess = false
    
    private let generator = UltraHDRGeneratorController()
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("UltraHDR Image Generator")
                    .font(.largeTitle)
                    .padding()
                
                // Images preview section
                HStack(spacing: 20) {
                    // HDR Image preview
                    VStack {
                        Text("HDR Image")
                            .font(.headline)
                        
                        if let hdrImage {
                            Image(uiImage: hdrImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .cornerRadius(10)
                                .overlay(
                                    Text("No HDR Image")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    
                    // SDR Image preview (if available)
                    VStack {
                        Text("SDR Version")
                            .font(.headline)
                        
                        if let sdrImage {
                            Image(uiImage: sdrImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .cornerRadius(10)
                                .overlay(
                                    Text("Auto-generated")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
                .padding()
                
                // Image selection and processing controls
                VStack(spacing: 20) {
                    // Image picker
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Select HDR Image")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { item in
                        loadImage(from: item)
                    }
                    
                    // Generate button
                    Button(action: generateUltraHDR) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        } else {
                            Text("Generate UltraHDR Image")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(hdrImage == nil ? Color.blue.opacity(0.5) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(hdrImage == nil || isProcessing)
                }
                .padding()
                
                Spacer()
                
                // Status text
                if isProcessing {
                    Text("Processing image...")
                        .foregroundColor(.gray)
                        .padding()
                } else if let outputURL = outputURL {
                    VStack {
                        Text("UltraHDR image saved to:")
                            .foregroundColor(.green)
                        Text(outputURL.lastPathComponent)
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Button("Share Image") {
                            shareImage(url: outputURL)
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .alert("Success", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("UltraHDR image created successfully!")
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        // Reset images
        hdrImage = nil
        sdrImage = nil
        outputURL = nil
        
        // Load the selected image
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.hdrImage = uiImage
                        
                        // Create SDR version (in a real app, you'd use the image acquisition class)
                        self.sdrImage = uiImage.copy() as? UIImage
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                    self.showingError = true
                }
            }
        }
    }
    
    private func generateUltraHDR() {
        guard let hdrImage = hdrImage else { return }
        
        isProcessing = true
        
        // Get the Documents directory for saving the output
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Convert UIImage to CIImage
        if let ciImage = CIImage(image: hdrImage) {
            // In a real app, this should use the asset's actual data
            // For this demo, we'll just generate from the HDR image only
            generator.generateUltraHDRFromHDROnly(
                hdrImage: ciImage,
                outputDirectory: documentsDirectory
            ) { result in
                DispatchQueue.main.async {
                    isProcessing = false
                    
                    switch result {
                    case .success(let url):
                        outputURL = url
                        showingSuccess = true
                    case .failure(let error):
                        errorMessage = "Failed to generate UltraHDR image: \(error.localizedDescription)"
                        showingError = true
                    }
                }
            }
        } else {
            isProcessing = false
            errorMessage = "Failed to convert image to CIImage"
            showingError = true
        }
    }
    
    private func shareImage(url: URL) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Helper Extensions

extension UltraHDRGeneratorController {
    /// Simplified version for the demo that doesn't use the actual asset data
    func generateUltraHDRFromHDROnly(
        hdrImage: CIImage,
        outputDirectory: URL,
        completion: @escaping UltraHDRGenerationCompletion
    ) {
        // This is a simplified mock implementation for the UI demo
        // In a real app, this would use the actual implementation from UltraHDRGeneratorController
        
        // Simulate processing delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            do {
                // Create a random file to simulate output
                let timestamp = Int(Date().timeIntervalSince1970)
                let filename = "UltraHDR_\(timestamp).jpg"
                let outputURL = outputDirectory.appendingPathComponent(filename)
                
                // Convert CIImage to JPEG data and save
                if let context = CIContext(),
                   let cgImage = context.createCGImage(hdrImage, from: hdrImage.extent),
                   let data = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.9) {
                    try data.write(to: outputURL)
                    
                    DispatchQueue.main.async {
                        completion(.success(outputURL))
                    }
                } else {
                    throw UltraHDRGeneratorError.processingFailed("Failed to convert image")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
//
//  ViewModel.swift
//  CoreMLImagePrediction
//
//  Created by Minyoung Yoo on 10/11/24.
//

import Foundation
import CoreML
import Observation

//MARK: Model
@Observable
final class PredictionModel {
    
    private(set) var model: MLModel? = nil //replace MLModel to your model.
    private(set) var predictedImage: UIImage? = nil
    private(set) var resultString: String = ""
    
    init() {
        do {
            self.model = try NoonBody(configuration: MLModelConfiguration())
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    func prediction(urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data),
              let resizedImage = image.resizeImage(targetSize: .init(width: 360, height: 360)),
              let buffer = resizedImage.convertToBuffer() else {
            print("Failed to resize image or convert to buffer.")
            return
        }
        
        guard let output = try? model?.prediction(image: buffer) else {
            print("Failed to predict.")
            return
        }
        
        print(output.targetProbability)
        
        let results = output.targetProbability.sorted{ $0.1 > $1.1 }
        let result = results.map { (key, value) in
            return "\(key) = \(String(format: "%.2f", value * 100))%"
        }.joined(separator: "\n")
        
        await MainActor.run {
            self.predictedImage = resizedImage
            self.resultString = result
        }
    }
    
    func reset() {
        predictedImage = nil
        resultString = ""
    }
}

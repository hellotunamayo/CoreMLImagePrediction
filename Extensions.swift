//
//  Extensions.swift
//  CoreMLImagePrediction
//
//  Created by Minyoung Yoo on 10/11/24.
//

import Foundation
import UIKit

extension UIImage {
    func convertToBuffer() -> CVPixelBuffer? {
        
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor that preserves the aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Calculate the new size
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Resize the image
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

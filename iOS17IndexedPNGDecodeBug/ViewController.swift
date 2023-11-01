//
//  ViewController.swift
//  iOS17IndexedPNGDecodeBug
//
//  Created by lizhuoli on 2023/11/1.
//

import UIKit

class ViewController: UIViewController {
    
    func loadPNGBitmap(_ data: Data) {
        let options: CFDictionary? = nil
        let source = CGImageSourceCreateWithData(data as CFData, options)!
        let frameOptions: CFDictionary? = nil
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, frameOptions)!
        let alphaInfo = cgImage.alphaInfo
        
        // The returned CGImage Alpha Info is `.last` on both iOS 16/iOS 17
        // But on iOS 17, actually the bitmap data vector is always **premultiplied**
        assert(alphaInfo == .last)
        
        // Let's check whether it's premultiplied or not
        let bitmapData = cgImage.dataProvider?.data!
        let length = CFDataGetLength(bitmapData)
        var rawData = [UInt8].init(repeating: 0, count: length)
        CFDataGetBytes(bitmapData, CFRange(location: 0, length: length), &rawData)
        // Check first 1 pixels one by one
        assert(length == 1 * 4)
        
        // The I tested is RGBA(50, 50, 50, 50), non-premultiplied
        let R = rawData[0]
        let G = rawData[1]
        let B = rawData[2]
        let A = rawData[3]
        // assert failed on >= iOS 17, success on iOS 16
        assert(R == 50)
        assert(G == 50)
        assert(B == 50)
        assert(A == 50)
        
        print("Success load one pixel indexed PNG")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "IndexedOnePixelImage", withExtension: "png")!
        let pngData = try! Data(contentsOf: url)
        loadPNGBitmap(pngData)
    }


}


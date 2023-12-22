//
//  ViewController.swift
//  iOS17IndexedPNGDecodeBug
//
//  Created by lizhuoli on 2023/11/1.
//

import UIKit

class ViewController: UIViewController {
    
    func loadPNGBitmap(_ data: Data, assertable: Bool = true) {
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
        if assertable {
            assert(R == 50)
            assert(G == 50)
            assert(B == 50)
            assert(A == 50)
        }
        
        print("Success load one pixel indexed PNG")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "IndexedOnePixelImage", withExtension: "png")!
        let pngData = try! Data(contentsOf: url)
        loadPNGBitmap(pngData, assertable: false)
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(imageView1)
        view.addSubview(imageView2)
    }
    
    override func viewDidLayoutSubviews() {
        imageView1.frame = CGRect(
            x: 0,
            y: 200,
            width: view.bounds.size.width,
            height: view.bounds.size.width * 460.0 / 750.0
        )
        imageView2.frame = CGRect(
            x: 0,
            y: imageView1.frame.maxY + 8.0,
            width: imageView1.frame.size.width,
            height: imageView1.frame.size.height
        )
    }
    
    // On Xcode 14.3, iOS 16.*, the visual effect of the picture is correct
    // On Xcode 15.1, iOS 17.2, parts of the image that are transparent appear black
    // Is there any solution to quick fix it?
    
    private lazy var imageView1: UIImageView = {
        let view = UIImageView(image: UIImage(named: "bg_three_ball"))
        view.contentMode = .scaleToFill
        return view
    }()
    
    private lazy var imageView2: UIImageView = {
        let path = Bundle.main.path(forResource: "bg_three_ball", ofType: "png")!
        let view = UIImageView(image: UIImage(contentsOfFile: path))
        view.contentMode = .scaleToFill
        return view
    }()
}


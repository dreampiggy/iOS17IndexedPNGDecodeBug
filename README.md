### Radar FB13322459

Related issue report:

https://github.com/SDWebImage/SDWebImage/issues/3605

### Title

iOS 17 Indexed PNG decode wrong which report alpha info to non-premultiplied RGBA, but bitmap array is premultiplied

### Description

From iOS 17/macOS 14, there is one serious problem on ImageIO PNG plugin. The decode result for indexed color PNG use the wrong CGImageAlphaInfo

The returned CGImageAlphaInfo is alpha last, but the actual bitmap data is premultiplied alpha last, which cause many runtime render bug.

I already submit a radar FB13196663 to UIKit team, but seems iOS 17.2 still contains this issue. After digging into details, I think this radar should reported to ImageIO team.

### Steps to reproduce

1. Just download my “iOS17IndexedPNGDecodeBug.zip” in attachment, which provide a one pixel PNG image
2. Open “iOS17IndexedPNGDecodeBug.xcodeproj”
3. Run with destination on iOS 16 device or simulator, no assertion failed. The pixel value (50, 50, 50, 50)
4. Run with destination on iOS 17 device or simulator, hit assertion, because the pixel value (10, 10, 10, 50), which looks like the premultiplied result 

### Excepted behavior
Both iOS 17 and iOS 16 decode result for that indexed color PNG should match. Well ImageIO team can use premultiplied RGBA, but please, you at least should create `CGImage` with the correct CGImageAlphaInfo.

Currently we have no good workaround to solve this, this break many render pipeline when convert the ImageIO decoded CGImage into other pixel buffers.

### Screenshot

#### iOS 16

![iOS 16 Screenshot](assets/iOS%2016%20Screenshot.png)


#### iOS 17

![iOS 17 Screenshot](assets/iOS%2017%20Screenshot.png)


import UIKit

internal struct SnapFont {
    let fileName: String
    let postScriptName: String
}

open class SnapFonts: NSObject {
    
    private static func loadFont(font: SnapFont) {
        
        let clazz: AnyClass = SnapFonts.classForCoder()
        guard let bundleURL = Bundle(for: clazz).url(forResource: "Fonts", withExtension: "bundle") else {
            return
        }
        
        guard let fontURL = Bundle(url: bundleURL)?.url(forResource: font.fileName, withExtension: "otf") else {
            return
        }
        
        let fontData = try? Data(contentsOf: fontURL)
        let fontDataProvider = CGDataProvider(data: fontData! as CFData)
        
        let font = CGFont(fontDataProvider!)
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
        
        if error != nil {
            print(error.debugDescription)
        }
    }
    
    static let gothamRoundedBold = SnapFont(fileName: "GothamRnd-Bold", postScriptName: "GothamRounded-Bold")
    static let gothamRoundedBoldItalic = SnapFont(fileName: "GothamRnd-BoldIta", postScriptName: "GothamRounded-BoldItalic")
    static let gothamRoundedBook = SnapFont(fileName: "GothamRnd-Book", postScriptName: "GothamRounded-Book")
    static let gothamRoundedBookItalic = SnapFont(fileName: "GothamRnd-BookIta", postScriptName: "GothamRounded-BookItalic")
    static let gothamRoundedLight = SnapFont(fileName: "GothamRnd-Light", postScriptName: "GothamRounded-Light")
    static let gothamRoundedLightItalic = SnapFont(fileName: "GothamRnd-LightIta", postScriptName: "GothamRounded-LightItalic")
    static let gothamRoundedMedium = SnapFont(fileName: "GothamRnd-Medium", postScriptName: "GothamRounded-Medium")
    static let gothamRoundedMediumItalic = SnapFont(fileName: "GothamRnd-MedIta", postScriptName: "GothamRounded-MediumItalic")
    
    open static func gothamRoundedBold(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedBold, size: size)
    }
    
    open static func gothamRoundedBoldItalic(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedBoldItalic, size: size)
    }
    
    open static func gothamRoundedBook(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedBook, size: size)
    }
    
    open static func gothamRoundedBookItalic(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedBookItalic, size: size)
    }
    
    open static func gothamRoundedLight(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedLight, size: size)
    }
    
    open static func gothamRoundedLightItalic(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedLightItalic, size: size)
    }
    
    open static func gothamRoundedMedium(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedMedium, size: size)
    }
    
    open static func gothamRoundedMediumItalic(ofSize size: CGFloat) -> UIFont? {
        return loadFontOnce(gothamRoundedMediumItalic, size: size)
    }
    
    fileprivate static var loadedFonts = [String]()
    internal static func loadFontOnce(_ font: SnapFont, size: CGFloat) -> UIFont? {
        if loadedFonts.contains(font.postScriptName) == false {
            loadFont(font: font)
            loadedFonts.append(font.postScriptName)
        }
        
        return UIFont(name: font.postScriptName, size: size)
    }
    
}

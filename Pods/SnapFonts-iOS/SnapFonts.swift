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
    
    open static func gothamRoundedBoldOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedBold, size: size, token: &Token.token)
    }
    
    open static func gothamRoundedBoldItalicOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedBoldItalic, size: size, token: &Token.token)
    }
    
    open static func gothamRoundedBookOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedBook, size: size, token: &Token.token)
    }
    
    open static func gothamRoundedBookItalicOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedBookItalic, size: size, token: &Token.token)
    }
    
    open static func gothamRoundedLightOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedLight, size: size, token: &Token.token)
    }
    
    open static func gothamRoundedLightItalicOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedLightItalic, size: size, token: &Token.token)
    }
    
    open static func gothamRoundedMediumOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedMedium, size: size, token: &Token.token)
    }
    
    open static func gothamRoundedMediumItalicOfSize(_ size: CGFloat) -> UIFont? {
        struct Token { static var token = Int() }
        return loadFontOnce(gothamRoundedMediumItalic, size: size, token: &Token.token)
    }
    
    fileprivate static var loadedFonts = [String]()
    internal static func loadFontOnce(_ font: SnapFont, size: CGFloat, token: inout Int) -> UIFont? {
        if loadedFonts.contains(font.postScriptName) {
            return nil
        }
        
        loadFont(font: font)
        
        return UIFont(name: font.postScriptName, size: size)
    }
    
}

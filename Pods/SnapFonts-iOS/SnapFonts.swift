import UIKit

internal struct SnapFont {
    let fileName: String
    let postScriptName: String
}

public class SnapFonts: NSObject {
    static let gothamRoundedBold = SnapFont(fileName: "GothamRnd-Bold", postScriptName: "GothamRounded-Bold")
    static let gothamRoundedBoldItalic = SnapFont(fileName: "GothamRnd-BoldIta", postScriptName: "GothamRounded-BoldItalic")
    static let gothamRoundedBook = SnapFont(fileName: "GothamRnd-Book", postScriptName: "GothamRounded-Book")
    static let gothamRoundedBookItalic = SnapFont(fileName: "GothamRnd-BookIta", postScriptName: "GothamRounded-BookItalic")
    static let gothamRoundedLight = SnapFont(fileName: "GothamRnd-Light", postScriptName: "GothamRounded-Light")
    static let gothamRoundedLightItalic = SnapFont(fileName: "GothamRnd-LightIta", postScriptName: "GothamRounded-LightItalic")
    static let gothamRoundedMedium = SnapFont(fileName: "GothamRnd-Medium", postScriptName: "GothamRounded-Medium")
    static let gothamRoundedMediumItalic = SnapFont(fileName: "GothamRnd-MedIta", postScriptName: "GothamRounded-MediumItalic")
    
    public static func gothamRoundedBoldOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedBold, size: size, token: &Token.token)
    }
    
    public static func gothamRoundedBoldItalicOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedBoldItalic, size: size, token: &Token.token)
    }
    
    public static func gothamRoundedBookOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedBook, size: size, token: &Token.token)
    }
    
    public static func gothamRoundedBookItalicOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedBookItalic, size: size, token: &Token.token)
    }
    
    public static func gothamRoundedLightOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedLight, size: size, token: &Token.token)
    }
    
    public static func gothamRoundedLightItalicOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedLightItalic, size: size, token: &Token.token)
    }
    
    public static func gothamRoundedMediumOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedMedium, size: size, token: &Token.token)
    }
    
    public static func gothamRoundedMediumItalicOfSize(size: CGFloat) -> UIFont? {
        struct Token { static var token = dispatch_once_t() }
        return loadFontOnce(gothamRoundedMediumItalic, size: size, token: &Token.token)
    }
    
    internal static func loadFontOnce(font: SnapFont, size: CGFloat, inout token: dispatch_once_t) -> UIFont? {
        dispatch_once(&token) {
            loadFontWithFileName(font.fileName)
        }
        
        return UIFont(name: font.postScriptName, size: size)
    }
    
    private static func loadFontWithFileName(fileName: String) {
        guard let bundleURL = NSBundle(forClass: self.classForCoder()).URLForResource("Fonts", withExtension: "bundle") else {
            return
        }
        
        guard let fontURL = NSBundle(URL: bundleURL)?.URLForResource(fileName, withExtension: "otf") else {
            return
        }
        
        let fontData = NSData(contentsOfURL: fontURL)
        let fontDataProvider = CGDataProviderCreateWithCFData(fontData)
        
        if let font = CGFontCreateWithDataProvider(fontDataProvider) {
            var error: Unmanaged<CFError>?
            CTFontManagerRegisterGraphicsFont(font, &error)
            
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
    
}
import Darwin

/**
    A simple structure that represents the color of a pixel.
 */
public struct Color: Equatable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var alpha: UInt8
}

public func==(lhs: Color, rhs: Color) -> Bool {
    return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue && lhs.alpha == rhs.alpha
}

public extension Color {
    /// Initializes a `Color` structure with `UInt8` (0-255) red/green/blue/alpha values
    init(_ r: UInt8 = 0, _ g: UInt8 = 0, _ b: UInt8 = 0, _ a: UInt8 = 255) {
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    /// Initializes a `Color` structure with `Float` (0-1) red/green/blue/alpha values
    init(RGB: (Float, Float, Float), alpha: Float = 1) {
        let (r, g, b) = RGB
        self.init(red: UInt8(r * 255), green: UInt8(g * 255), blue: UInt8(b * 255), alpha: UInt8(alpha * 255))
    }

    /// Normalized (0-1) RGB components
    var RGB: (Float, Float, Float) {
        return (Float(red)/255, Float(green)/255, Float(blue)/255)
    }

    /**
        Create a new color with the given alpha value
     
        - Parameter alpha: Normalized alpha value (0-1)
        - Returns: A new `Color` with the new alpha
     */
    func scaled(alpha a: Float) -> Color {
        return Color(red, green, blue, UInt8(a * 255))
    }

    /**
     Set the alpha value to the given normalized alpha value
     
     - Parameter alpha: Normalized alpha value (0-1)
     */
    mutating func scale(alpha a: Float) {
        self = scaled(alpha: a)
    }
}

public extension Color {
    /// Initializes a `Color` structure with HSV values
    init(HSV: (Float, Float, Float), alpha: Float = 1) {
        let (h, s, v) = HSV
        self.init(hue: h, saturation: s, brightness: v, alpha: alpha)
    }
    
    /// Initializes a `Color` structure with HSV values
    init(hue: Float, saturation: Float, brightness: Float, alpha: Float = 1) {
        guard saturation != 0 else {
            self.init(RGB: (brightness, brightness, brightness), alpha: alpha)
            return
        }
        
        let h = hue / 60
        let s = saturation
        let v = brightness
        
        let i = floor(h)
        let f = h - i
        let p = v * (1 - s)
        let q = v * (1 - s * f)
        let t = v * (1 - s * (1 - f))
        
        switch i {
        case 0:
            self.init(RGB: (v, t, p), alpha: alpha)
        case 1:
            self.init(RGB: (q, v, p), alpha: alpha)
        case 2:
            self.init(RGB: (p, v, t), alpha: alpha)
        case 3:
            self.init(RGB: (p, q, v), alpha: alpha)
        case 4:
            self.init(RGB: (t, p, v), alpha: alpha)
        default:
            self.init(RGB: (v, p, q), alpha: alpha)
        }
    }
    
    /// The HSV (hue, saturation, brightness) values
    var HSV: (Float, Float, Float) {
        let (r, g, b) = self.RGB
        
        let maximum = max(r, g, b)
        let v = maximum
        
        guard maximum != 0 else {
            return (-1, 0, v)
        }
        
        let minimum = min(r, g, b)
        let delta = maximum - minimum
        let s = delta / maximum
        var h: Float
        
        if r == maximum {
            h = (g - b) / delta
        } else if (g == maximum) {
            h = 2 + (b - r) / delta
        } else {
            h = 4 + (r - g) / delta
        }
        
        h *= 60
        
        if h < 0 {
            h += 360
        }
        
        return (h, s, v)
    }
    
    /// Make a new color by shifting the hue
    func shifted(hue hshift: Float) -> Color {
        let (h, s, v) = HSV
        return Color(HSV: (h + hshift, s, v), alpha: Float(alpha)/255)
    }

    /// Shifts the color's hue
    mutating func shift(hue hshift: Float) {
        self = shifted(hue: hshift)
    }

    /// Makes a new color by scaling the saturation and/ brightness
    func scaled(saturation sscale: Float = 1, brightness vscale: Float = 1) -> Color {
        let (h, s, v) = HSV
        return Color(HSV: (h, s * sscale, v * vscale), alpha: Float(alpha)/255)
    }
    
    /// Scales the saturation and/ brightness of this color
    mutating func scale(saturation sscale: Float = 1, brightness vscale: Float = 1) {
        self = scaled(saturation: sscale, brightness: vscale)
    }
}

public extension Color {
    static let clear = Color(0,0,0,0)
    static let black = Color(0,0,0)
    static let white = Color(255,255,255)
    static let red = Color(255,0,0)
    static let green = Color(0,255,0)
    static let blue = Color(0,0,255)
    static let darkRed = Color(191,0,0)
    static let darkBlue = Color(0,0,191)
    static let lightGray = Color(159,159,159)
    static let darkGray = Color(95,95,95)
    static let darkerGray = Color(63,63,63)
    static let darkestGray = Color(31,31,31)
    static let lightViolet = Color(185,115,255)
    static let desaturatedGreen = Color(64,128,64)
    static let darkerGreen = Color(0,128,0)
    static let darkOrange = Color(191,95,0)
    static let violet = Color(127,0,255)
    static let sky = Color(0,191,255)
    static let lightGreen = Color(115,255,115)
    static let lightYellow = Color(255,255,115)
    static let lightestYellow = Color(255,255,191)
    static let yellow = Color(255,255,0)
    static let darkYellow = Color(191,191,0)
    static let crimson = Color(255,0,63)
    static let pink = Color(255,0,127)
    static let flame = Color(255,63,0)
    static let darkFlame = Color(191,47,0)
    static let orange = Color(255,127,0)
}

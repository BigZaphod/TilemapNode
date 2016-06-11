/**
    Holds the information necessary to render a specific tile with a specific style.
 
    There are also `IntegerLiteralConvertible` and `UnicodeScalarLiteralConvertible` to make it easy to create `Tile`s in
    code for certain kinds of atlases:
 
        var tile1: Tile = 42
        var tile2: Tile = "A"
 
 */
public struct Tile: Equatable, Hashable {
    /**
        - Parameters:
            - identifier: The numerical tile id or number within the atlas
            - color: A color to tint the tile
            - backgroundColor: A color to tint transparent parts of the tile
            - alpha: An opacity (0-1) of the whole tile that is independent of the tint colors
     
     */
    public init(_ identifier: Int, color fg: Color = .white, backgroundColor bg: Color = .clear, alpha opacity: Float = 1) {
        id = identifier
        color = fg
        backgroundColor = bg
        alpha = opacity
        hidden = false
    }
    
    public var hashValue: Int { return id }

    /// The id number of the tile within an atlas
    public var id: Int
    
    /// Tint color
    public var color: Color
    
    /// Background tint color
    public var backgroundColor: Color
    
    /// Opacity of the tile
    public var alpha: Float
    
    /// Determines if the tile is rendered or not
    public var hidden: Bool
}

public func ==(lhs: Tile, rhs: Tile) -> Bool {
    return lhs.id == rhs.id && lhs.color == rhs.color && lhs.backgroundColor == rhs.backgroundColor && lhs.alpha == rhs.alpha
}

extension Tile: IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Tile: UnicodeScalarLiteralConvertible {
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(Int(value.value))
    }
}

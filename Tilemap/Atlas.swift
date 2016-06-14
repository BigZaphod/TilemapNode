import SpriteKit

/**
    Supplies an `SKTexture` to an `Atlas`

    There is an extension for `SKTexture` that returns `self` and an extension for `String` which returnes `SKTexture(imageNamed: self)`

    If Swift had a way to specify types such as `(SKTexture | String)` where the type could be either a texture or a string, this might not
    be necessary. Of course it isn't necessary anyway because I could have just made the `Atlas` take an `SKTexture`, too. :P
 */
public protocol AtlasTextureSource {
    var atlasTexture: SKTexture { get }
}

extension SKTexture: AtlasTextureSource {
    public var atlasTexture: SKTexture { return self }
}

extension String: AtlasTextureSource {
    public var atlasTexture: SKTexture { return SKTexture(imageNamed: self) }
}

/// Describes how a single texture is split into individual tiles.
public struct Atlas {
    
    /**
        Initializes a tile atlas from a source.
     
        - Parameters:
            - source: Something that knows how to supply an SKTexture.
            - tileSize: The size of a single tile within the source in pixels (ex. 16x16)
            - tileSpacing: This is the number of pixels between individual tiles horizontally and vertically. If the tiles in the texture are tightly packed, this would be (0, 0)
            - offset: This is the origin of the first tile in the texture - normally this is (0,0), but if the whole texture has a border around it or something, this may need to change
            - width: The number of horizontal tiles in the texture - use `nil` to automatically compute based on the `source` texture's size, `tileSize`, and `tileSpacing`
            - height: The number of vertical tiles in the texture - `nil` for default calculation
            - transparent: If specified, this color is replaced with a clear color when the texture is loaded - useful for old school tilesets that might use a specific color to indicate transparency
     
        - Returns: An initialized `Atlas` that is ready to be used by a `TilemapNode`
     */
    public init(_ source: AtlasTextureSource, tileSize: CGSize, tileSpacing: CGSize = .zero, offset: CGPoint = .zero, width: Int? = nil, height: Int? = nil, transparent color: Color? = nil) {
        let texture: SKTexture
        
        if let mask = color {
            let img = source.atlasTexture.cgImage()
            let (w, h) = (img.width, img.height)
            let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            let pixels = UnsafeMutablePointer<Color>(ctx?.data)
            ctx?.draw(in: CGRect(x: 0, y: 0, width: w, height: h), image: img)
            for index in 0..<(w * h) where pixels?[index] == mask { pixels?[index] = .clear }
            texture = SKTexture(cgImage: (ctx?.makeImage()!)!)
        } else {
            texture = source.atlasTexture
        }
        
        self.texture = texture
        self.tileSize = tileSize
        self.tileSpacing = tileSpacing
        self.offset = offset
        self.width = width ?? Int(floor(texture.size().width + tileSpacing.width) / (tileSize.width + tileSpacing.width))
        self.height = height ?? Int(floor(texture.size().height + tileSpacing.height) / (tileSize.height + tileSpacing.height))
    }
    
    /**
        Fetch a `Tile` from using a column and row for a specified tile within the atlas.
     
        This is just a handy utility in case you want to fetch tiles using their relative placement within the atlas.
     
        - Parameters:
            - x: Column of the tile that you want
            - y: Row of the tile that you want
     
        - Returns: A `Tile` that refers to the given input.
     */
    public subscript(x: Int, y: Int) -> Tile {
        precondition(x >= 0 && y >= 0)
        precondition(x < width && y < height)
        return Tile(x + y * width)
    }
    
    /// Source texture
    public let texture: SKTexture
    
    /// The size of an individual tile
    public let tileSize: CGSize
    
    /// The spacing between tiles
    public let tileSpacing: CGSize
    
    /// The offset/origin of the first tile within the texture
    public let offset: CGPoint
    
    /// The number of columns of tiles within the atlas
    public let width: Int
    
    /// The number of rows of tiles within the atlas
    public let height: Int
}

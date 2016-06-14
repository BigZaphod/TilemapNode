import SpriteKit

/**
    Container of `Tile`s that represent the map for a `TilemapNode` to render.
 */
public class Tilemap {
    /**
        Initializes a `Tilemap` of a given size.
     
        A single `Tilemap` can be referenced by multiple `TilemapNode`'s without issue. In theory this could be used to render the same map with multiple "views"
        such as for a minimap or something else by using two nodes that share the same tilemap but with different atlases or whatever.
     
        - Parameters:
            - width: Width of the map in tiles
            - height: Height of the map in tiles
     
        - Returns: A brand new `Tilemap` with every tile set to `nil`
    */
    public init(width x: Int, height y: Int) {
        width = x
        height = y
        
        dataTexture = SKMutableTexture(size: CGSize(width: x * 3, height: y))
        tiles = Array(repeating: nil, count: width * height)
        
        dataTexture.modifyPixelData { (voidptr, len) in
            let bytes = UnsafeMutablePointer<UInt8>(voidptr)
            for index in 0..<len { bytes?[index] = 0 }
        }
    }
    
    /**
        Set and get tiles within the map.
     
        A `nil` tile is "empty" and will not be rendered. The map considers `nil` tiles to be holes.
    */
    public subscript(x: Int, y: Int) -> Tile? {
        get { return tiles[x + y * width] }
        set {
            tiles[x + y * width] = newValue
            setDataTile(newValue ?? Tile(0, alpha: 0), at: x + y * width * 3)
        }
    }

    /// Width of the map in tiles
    public let width: Int
    
    /// Height of the map in tiles
    public let height: Int

    internal let dataTexture: SKMutableTexture

    private var tiles: [Tile?]
    private var tileUpdates = [Int : Tile]()
}

private extension Tilemap {
    func setDataTile(_ tile: Tile, at index: Int) {
        
        // this cleverness prevents updating the SKMutableTexture's pixels *too* often within a single frame
        // it essentially batches the changes which the hardware very much appreciates and is the difference between handling
        // something like 1,000 tile updates per frame to more like 10,000.
        if tileUpdates.isEmpty {
            DispatchQueue.main.async(execute: self.updateDataTexture)
        }

        // ensure that when we do actually update the mutable texture, we only update the pixels that matter by caching the changes here
        tileUpdates[index] = tile
    }
    
    func updateDataTexture() {
        dataTexture.modifyPixelData { [changes = tileUpdates, stride = width] (voidptr, len) in
            let tileptr = UnsafeMutablePointer<(UInt8, UInt8, UInt8, UInt8)>(voidptr)
            for (index, tile) in changes {
                let alpha = tile.hidden ? 0 : tile.alpha * 255
                tileptr?[0 * stride + index] = (UInt8(alpha), UInt8(truncatingBitPattern: tile.id >> 16), UInt8(truncatingBitPattern: tile.id >> 8), UInt8(truncatingBitPattern: tile.id >> 0))
                tileptr?[1 * stride + index] = (tile.color.red, tile.color.green, tile.color.blue, tile.color.alpha)
                tileptr?[2 * stride + index] = (tile.backgroundColor.red, tile.backgroundColor.green, tile.backgroundColor.blue, tile.backgroundColor.alpha)
            }
        }
        
        tileUpdates.removeAll()
    }
}

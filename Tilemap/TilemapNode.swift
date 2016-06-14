import SpriteKit

/**
    A SpriteKit node which renders a specific `Tilemap` using a specific `Atlas`
 */
public class TilemapNode: SKSpriteNode {
    /**
        Initializes a `TilemapNode`
     
        - Parameters:
            - tilemap: The map to render
            - atlas: The atlas of actual tile graphics to use when rendering
     
        - Returns: An initialized `TilemapNode` that is ready to be inserted into a scene. The node's `size` is set based on the `tilemap`'s size and the `atlas`'s `tileSize`
    */
    required public init(tilemap: Tilemap, atlas: Atlas) {
        self.tilemap = tilemap
        self.atlas = atlas
        
        let mapSize = CGSize(width: tilemap.width, height: tilemap.height)

        super.init(texture: atlas.texture,
                   color: .white(),
                   size: CGSize(width: atlas.tileSize.width * mapSize.width, height: atlas.tileSize.height * mapSize.height))

        // precomputing some things here since it's cheaper than doing it in the shader over and over
        let atlasSize = atlas.texture.size()
        let atlasColumns = Float(atlas.width)
        let tileStride = CGSize(width: atlas.tileSize.width + atlas.tileSpacing.width, height: atlas.tileSize.height + atlas.tileSpacing.height)
        
        shader = SKShader(fileNamed: "TilemapShader.fsh")
        shader!.uniforms = [
            SKUniform(name: "u_offset", vectorFloat2: float2(atlas.offset)),
            SKUniform(name: "u_tile_size", vectorFloat2: float2(atlas.tileSize)),
            SKUniform(name: "u_tile_stride", vectorFloat2: float2(tileStride)),
            SKUniform(name: "u_atlas_size", vectorFloat2: float2(atlasSize)),
            SKUniform(name: "u_atlas_columns", float: atlasColumns),
            SKUniform(name: "u_map_size", vectorFloat2: float2(mapSize)),
            SKUniform(name: "u_data", texture: tilemap.dataTexture),
        ]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public let tilemap: Tilemap
    public let atlas: Atlas
}

private extension float2 {
    init(_ size: CGSize) { self.init(Float(size.width), Float(size.height)) }
    init(_ point: CGPoint) { self.init(Float(point.x), Float(point.y)) }
}

//
//  GameScene.swift
//  Tilemap
//
//  Created by Sean on 6/11/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

import SpriteKit
import GameplayKit

// this is easier to use, IMO
private func randomFloat(min: Float, _ max: Float) -> Float {
    precondition(min <= max)
    let d = GKRandomSource.sharedRandom().nextUniform()
    return min + d * (max - min)
}

// this seems dumb...
private func randomFloat(min: CGFloat, _ max: CGFloat) -> CGFloat {
    return CGFloat(randomFloat(Float(min), Float(max)))
}

// this is too clever for its own good
private let randomInt = GKRandomSource.sharedRandom().nextIntWithUpperBound

// this is probably fine
private func randomHue(brightness: Float = 1) -> Color {
    return Color(hue: randomFloat(0, 360), saturation: 1, brightness: brightness)
}

class GameScene: SKScene {
    let mainCamera = SKCameraNode()
    
    let node = TilemapNode(
        tilemap: Tilemap(width: 512, height: 512),
        //atlas: Atlas("roguelikeSheet_transparent", tileSize: CGSize(width: 16, height: 16), tileSpacing: CGSize(width: 1, height: 1))
        atlas: Atlas("terminal16x16_gs_ro", tileSize: CGSize(width: 16, height: 16))
        //atlas: Atlas("Oreslam_1920x1200_20x20", tileSize: CGSize(width: 20, height: 20), transparent: Color(255, 0, 255))
        //atlas: Atlas("Oreslam_1920x1200_20x20", tileSize: CGSize(width: 19, height: 19), tileSpacing: CGSize(width: 1, height: 1), offset: CGPoint(x: 1, y: 1), transparent: Color(255, 0, 255))
        //atlas: Atlas("Oreslam_1920x1200_20x20", tileSize: CGSize(width: 19, height: 19), tileSpacing: CGSize(width: 1, height: 1), offset: CGPoint(x: 1, y: 1), width: 16, height: 1, transparent: Color(255, 0, 255))
    )

    override func didMoveToView(view: SKView) {
        generateMap()
        
        addChild(node)
        addChild(mainCamera)

        backgroundColor = .blackColor()

        camera = mainCamera
        mainCamera.setScale(0.5)

        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture)))
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture)))
        
        randomPan()
    }
   
    override func update(currentTime: CFTimeInterval) {
        randomizeTiles(50)
    }
    
    func generateMap() {
        let tilemap = node.tilemap
        let atlas = node.atlas
        
        for y in 0..<tilemap.height {
            for x in 0..<tilemap.width {
                tilemap[x, y] = atlas[randomInt(atlas.width), randomInt(atlas.height)]
            }
        }
    }
    
    func randomizeTiles(max: Int) {
        let tilemap = node.tilemap
        let atlas = node.atlas
        
        for _ in 1...max {
            var tile = atlas[randomInt(atlas.width), randomInt(atlas.height)]
            tile.color = randomHue()
            tile.backgroundColor = randomHue(0.4)
            
            tilemap[randomInt(tilemap.width), randomInt(tilemap.height)] = tile
        }
    }
    
    func randomPan() {
        let frame = node.frame
        
        let pan = SKAction.moveTo(CGPoint(x: randomFloat(frame.minX, frame.maxX), y: randomFloat(frame.minY, frame.maxY)), duration: 10)
        pan.timingMode = .EaseInEaseOut
        
        let wait = SKAction.waitForDuration(2)
        
        let runPan = SKAction.runBlock(randomPan, queue: dispatch_get_main_queue())
        
        mainCamera.runAction(.sequence([wait, pan, runPan]), withKey: "pan")
    }
    
    func panGesture(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            mainCamera.removeActionForKey("pan")
            
        case .Changed:
            let delta = gestureRecognizer.translationInView(view)
            mainCamera.position.x -= delta.x * mainCamera.xScale
            mainCamera.position.y += delta.y * mainCamera.yScale
            gestureRecognizer.setTranslation(.zero, inView: view)
            
        default:
            randomPan()
        }
    }
    
    func zoomGesture(gestureRecognizer: UIPinchGestureRecognizer) {
        guard gestureRecognizer.state == .Changed else { return }
        
        let before = convertPointFromView(gestureRecognizer.locationInView(view))
        
        // these limits prevent a lot of visual artifacting, plus they're probably pragmatic (at least with the 16x16 tiles I've been playing with)
        let scale = max(min(1 / gestureRecognizer.scale * mainCamera.xScale, 3), 0.2)
        
        mainCamera.setScale(scale)
        let after = convertPointFromView(gestureRecognizer.locationInView(view))
        
        mainCamera.position.x -= after.x - before.x
        mainCamera.position.y -= after.y - before.y
        
        gestureRecognizer.scale = 1
    }
}

# TilemapNode
A tile map node for SpriteKit written in Swift.

Using a custom shader, this SpriteKit node will render an almost arbitrarily large tilemap
using a single quad and a single draw call. Each tile in the map can have an indepdenent
tint color, background color, and alpha value.

This performs extremely well on modern iOS devices such as the iPad Pro and iPhone 6s, but
not nearly so well on anything older than that due to the shader relying on dependent texture
reads which older mobile GPUs are terrible at. As far as I can tell, I cannot work around this
limitation using this technique due in part to the design of SpriteKit. If SpriteKit had a node
that allowed for arbitrary geometry or something like that, then perhaps some cleverness could
be made to work. Maybe we'll get something like that soon - WWDC16 is mere days away!

# Features

In addition to the per-tile features, it also supports loading tilesheets that have padding,
spacing between tiles, and tiles positioned at offsets from the origin. There is even support
for old-school color transparancy masking.

On my first-gen iPad Pro, I can update well over 10,000 tiles per frame even on maps of
4096x4096 tiles. Your results may vary.

# Missing Features

* No loading functions for things like Tiled maps, although this doesn't seem very difficult.
* No function to "lift" a tile out of the map and into a standalone SKSprite for special effects and whatnot. This also doesn't seem like it'd be very hard.

# Notes

While developing this, I discovered that the auto brightness feature of iOS has a surprisingly
large impact on framerate when it adjusts itself.

For the best tile updating performance, be sure to compile with optimizations enabled - Swift
is not so swift without them.

# Tilesheets

The project currently includes a couple of basic tilesheet image files. I have unfortunately forgotten the origin of them. If you know, let me know.
The larger graphical sheet came from [Kenny](http://kenney.nl/assets/roguelike-rpg-pack).
// snaps a pixel position to the nearest "center" pixel
// this exists because (currently) SpriteKit seems to ignore an SKTexture's filtering mode when using a custom shader and
// we need a way to sample the texture using "nearest" for any of this to work in a sane way
vec2 nearest(vec2 pos) {
    vec2 snapped = floor(pos - 0.5) + 0.5;
    return (snapped + step(0.5, pos - snapped));
}

// translates a normalized uv into a normalized uv that has been "snapped" to the center of a pixel
vec2 nearest_uv(vec2 uv, vec2 size) {
    return nearest(uv * size) / size;
}

void main() {
    // compute the relevant locations in the "data" texture for this fragment
    const float data_layers = 3.;
    vec2 data_size = vec2(u_map_size.x * data_layers, u_map_size.y);
    vec2 uv = vec2(v_tex_coord.x, 1. - v_tex_coord.y);
    vec2 tile_uv = nearest_uv(vec2(0./data_layers + uv.x / data_layers, uv.y), data_size);
    vec2 color_uv = nearest_uv(vec2(1./data_layers + uv.x / data_layers, uv.y), data_size);
    vec2 background_color_uv = nearest_uv(vec2(2./data_layers + uv.x / data_layers, uv.y), data_size);
    
    //  fetch the data values
    vec4 packed_data = texture2D(u_data, tile_uv);
    vec4 color = texture2D(u_data, color_uv);
    vec4 background_color = texture2D(u_data, background_color_uv);

    // unpack the tile id and alpha values from each other and denormalize the tile id's bytes
    vec3 packed_tile_id = vec3(packed_data[1], packed_data[2], packed_data[3]) * 256.;
    float alpha = packed_data[0];
    
    // decode the tile id's bytes back into the tile's actual index number
    float tile_id = packed_tile_id[0] * 65536. + packed_tile_id[1] * 256. + packed_tile_id[2];
    
    // decode the col/row in the atlas from the tile's index
    vec2 tile_pos = floor(vec2(mod(tile_id, u_atlas_columns), tile_id / u_atlas_columns));
    
    // convert col/row to the pixel origin of the tile within the atlas
    vec2 pos = u_offset + (tile_pos * u_tile_stride);

    // compute the fractional offset from the tile's origin in pixels
    vec2 delta = nearest(fract(uv * u_map_size) * u_tile_size);
    
    // get the exact pixel that we need for this fragment from the atlas (needs to be flipped)
    vec2 atlas_pixel_uv = (pos + delta) / u_atlas_size;
    atlas_pixel_uv.y = 1. - atlas_pixel_uv.y;
    
    // WARNING - this is a huge performance hit on older iOS devices (which, at the time of this writing seems to be all
    // devices prior the iPhone 6s/6s+ and iPad Pro generation). It causes what is termed a "dependent texture read"
    // because the GPU cannot anticipate where in the texture we are going to sample and so it has almost certainly pre-
    // cached pixels that are totally incorrect and that slows things WAY WAY down. On newer hardware this isn't an issue
    // due to changes in GPU architicture - which is great - but it is unfortunate that on the millions of existing devices
    // out there, it utterly destroys performance (we're talking the difference between 60fps and barely 30fps)
    vec4 atlas_pixel = texture2D(u_texture, nearest_uv(atlas_pixel_uv, u_atlas_size));

    // blend the foreground and background with the pixel ("destination over" blending) and apply the tile's alpha
    vec4 S = background_color;
    vec4 D = atlas_pixel * color;
    gl_FragColor = (S * (1. - D.a) + D) * alpha;
}

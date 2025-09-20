shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D source_palette;

void fragment() {
    // Sample the sprite's color using the correct UV coordinates
    vec4 sprite_color = texture(TEXTURE, UV);

    // Sample the color from the screen (if needed for comparison)
    vec4 screen_color = texture(screen_texture, SCREEN_UV);

    // Get the size of the palette (assuming it's a 1D palette)
    ivec2 pal_size = textureSize(source_palette, 0);

    // Variables to track the closest color in the palette
    float color_diff = 1.0;
    int nearest_swatch = 0;

    // Loop through the palette to find the closest color
    for (int swatch = 0; swatch < pal_size.x; swatch++) {
        vec4 sampled_color = texelFetch(source_palette, ivec2(swatch, 0), 0);

        // Compare the RGB values only (ignore alpha for distance calculation)
        float new_color_diff = distance(sampled_color.rgb, screen_color.rgb);

        if (new_color_diff < color_diff) {
            color_diff = new_color_diff;
            nearest_swatch = swatch;
        }
    }

    // Get the target color (darker shade from the palette)
    int target_swatch = clamp(nearest_swatch + 1, 0, pal_size.x - 1);
    vec4 new_color = texelFetch(source_palette, ivec2(target_swatch, 0), 0);

    // Preserve the original sprite's alpha value
    new_color.a = sprite_color.a;

    // Output the final color, applying the palette logic while keeping alpha intact
    COLOR = new_color;
}

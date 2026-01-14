// Pixelation/mosaic effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    // Pixel size
    float pixels = 80.0;

    // Snap to pixel grid
    vec2 uv = v_texcoord;
    uv = floor(uv * pixels) / pixels;

    vec3 c = texture2D(tex, uv).rgb;

    // Slight color quantization for retro feel
    c = floor(c * 16.0) / 16.0;

    gl_FragColor = vec4(c, 1.0);
}

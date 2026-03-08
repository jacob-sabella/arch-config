// Anaglyph 3D (red/cyan glasses effect)
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;

    // Offset for 3D effect
    float offset = 0.005;

    // Red channel from left
    float r = texture2D(tex, uv - vec2(offset, 0.0)).r;

    // Cyan (green + blue) from right
    vec2 gb = texture2D(tex, uv + vec2(offset, 0.0)).gb;

    vec3 c = vec3(r, gb.x, gb.y);

    gl_FragColor = vec4(c, 1.0);
}

// Synthwave/outrun aesthetic
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Synthwave color grading: pink/purple/cyan
    c.r = pow(c.r, 0.85) * 1.3;
    c.g = pow(c.g, 1.0) * 0.85;
    c.b = pow(c.b, 0.9) * 1.2;

    // Add gradient overlay (sun gradient)
    float gradient = smoothstep(0.0, 0.6, uv.y);
    vec3 sunset = mix(vec3(1.0, 0.3, 0.6), vec3(0.3, 0.1, 0.4), gradient);
    c = mix(c, c * sunset, 0.25);

    // Glow on highlights
    vec3 glow = smoothstep(0.7, 1.0, c) * vec3(1.0, 0.2, 0.8) * 0.3;
    c += glow;

    // Boost contrast
    c = (c - 0.5) * 1.25 + 0.5;

    // Scanline grid (subtle)
    float scanline = sin(uv.y * 200.0) * 0.02;
    c -= scanline;

    gl_FragColor = vec4(c, 1.0);
}

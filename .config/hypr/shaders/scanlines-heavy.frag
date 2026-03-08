// Heavy scanlines old TV effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Heavy scanlines
    float scanline = sin(uv.y * 300.0) * 0.5 + 0.5;
    scanline = smoothstep(0.3, 0.7, scanline);
    c *= scanline * 0.5 + 0.5;

    // Curvature
    vec2 curve = (uv - 0.5) * 2.0;
    c *= 1.0 - 0.2 * dot(curve, curve);

    // Slight flicker
    c *= 0.95 + 0.05 * sin(time * 100.0);

    // Desaturate slightly
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 0.85);

    gl_FragColor = vec4(c, 1.0);
}

// Retro CRT monitor effect with scanlines and chromatic aberration
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

void main() {
    vec2 uv = v_texcoord;

    // Chromatic aberration
    float aberration = 0.002;
    vec2 distortion = (uv - 0.5) * 2.0;
    float r = texture2D(tex, uv - distortion * aberration).r;
    float g = texture2D(tex, uv).g;
    float b = texture2D(tex, uv + distortion * aberration).b;
    vec3 c = vec3(r, g, b);

    // Scanlines
    float scanline = sin(uv.y * 800.0) * 0.04;
    c -= scanline;

    // Vignette
    float vignette = smoothstep(0.8, 0.2, length(distortion));
    c *= vignette * 0.9 + 0.1;

    // Slight flicker
    c *= 0.97 + 0.03 * sin(time * 50.0);

    // CRT curve (subtle)
    float curve = 1.0 - 0.15 * dot(distortion, distortion);
    c *= curve;

    gl_FragColor = vec4(c, 1.0);
}

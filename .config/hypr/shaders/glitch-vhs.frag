// VHS glitch effect with color distortion
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

// Simple pseudo-random
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = v_texcoord;

    // Random horizontal glitch lines
    float glitchLine = floor(uv.y * 100.0);
    float glitch = step(0.98, rand(vec2(glitchLine, floor(time * 2.0))));

    // Offset UV on glitch lines
    if (glitch > 0.5) {
        uv.x += (rand(vec2(glitchLine, time)) - 0.5) * 0.05;
    }

    // Color channel separation
    float offset = 0.003 * (1.0 + glitch * 3.0);
    float r = texture2D(tex, uv + vec2(offset, 0.0)).r;
    float g = texture2D(tex, uv).g;
    float b = texture2D(tex, uv - vec2(offset, 0.0)).b;
    vec3 c = vec3(r, g, b);

    // VHS horizontal blur
    c += texture2D(tex, uv + vec2(0.001, 0.0)).rgb * 0.3;
    c += texture2D(tex, uv - vec2(0.001, 0.0)).rgb * 0.3;
    c /= 1.6;

    // Scanlines
    c -= 0.05 * sin(uv.y * 400.0);

    // Slight desaturation
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 0.9);

    gl_FragColor = vec4(c, 1.0);
}

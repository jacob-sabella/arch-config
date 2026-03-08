// Underwater caustics effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

void main() {
    vec2 uv = v_texcoord;

    // Wavy distortion
    float wave = sin(uv.y * 10.0 + time * 2.0) * 0.005;
    wave += sin(uv.x * 15.0 + time * 1.5) * 0.003;
    uv.x += wave;

    vec3 c = texture2D(tex, uv).rgb;

    // Blue-green tint
    c.r *= 0.6;
    c.g *= 0.9;
    c.b *= 1.3;

    // Add caustic light patterns
    float caustic = sin(uv.x * 20.0 + time * 2.0) * sin(uv.y * 20.0 + time * 1.5);
    caustic = smoothstep(0.0, 1.0, caustic * 0.5 + 0.5);
    c += vec3(0.1, 0.15, 0.2) * caustic * 0.3;

    // Depth fade (darker at bottom)
    c *= 1.0 - uv.y * 0.3;

    // Soft blur effect
    vec3 blur = c;
    blur += texture2D(tex, uv + vec2(0.002, 0.0)).rgb;
    blur += texture2D(tex, uv - vec2(0.002, 0.0)).rgb;
    blur /= 3.0;
    c = mix(c, blur, 0.2);

    gl_FragColor = vec4(c, 1.0);
}

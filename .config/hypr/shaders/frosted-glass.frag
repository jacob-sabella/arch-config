// Frosted glass blur effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = v_texcoord;
    vec3 c = vec3(0.0);

    // Random offset blur for frosted glass
    float samples = 12.0;
    for(float i = 0.0; i < samples; i++) {
        float angle = (i / samples) * 6.28318;
        float dist = 0.008;
        vec2 offset = vec2(cos(angle), sin(angle)) * dist;

        // Add randomness
        offset *= 0.5 + rand(uv + vec2(i)) * 0.5;

        c += texture2D(tex, uv + offset).rgb;
    }
    c /= samples;

    // Slight brightness boost
    c *= 1.05;

    gl_FragColor = vec4(c, 1.0);
}

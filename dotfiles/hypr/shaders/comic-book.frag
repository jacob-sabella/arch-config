// Comic book halftone effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Edge detection
    vec3 n = texture2D(tex, uv + vec2(0.0, 0.003)).rgb;
    vec3 s = texture2D(tex, uv - vec2(0.0, 0.003)).rgb;
    vec3 e = texture2D(tex, uv + vec2(0.003, 0.0)).rgb;
    vec3 w = texture2D(tex, uv - vec2(0.003, 0.0)).rgb;

    vec3 edge = abs(n - s) + abs(e - w);
    float edgeStrength = length(edge);

    // Darken edges (ink lines)
    c -= edgeStrength * 0.8;

    // Boost saturation
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 1.4);

    // High contrast
    c = (c - 0.5) * 1.4 + 0.5;

    // Quantize colors slightly
    c = floor(c * 12.0) / 12.0;

    gl_FragColor = vec4(c, 1.0);
}

// Neon glow effect with enhanced edges
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Edge detection for glow
    vec3 n = texture2D(tex, uv + vec2(0.0, 0.002)).rgb;
    vec3 s = texture2D(tex, uv - vec2(0.0, 0.002)).rgb;
    vec3 e = texture2D(tex, uv + vec2(0.002, 0.0)).rgb;
    vec3 w = texture2D(tex, uv - vec2(0.002, 0.0)).rgb;

    vec3 edge = abs(n - s) + abs(e - w);
    float edgeStrength = length(edge);

    // Neon color boost
    c.r = pow(c.r, 0.8) * 1.2;
    c.g = pow(c.g, 0.85) * 1.15;
    c.b = pow(c.b, 0.8) * 1.3;

    // Add neon glow on edges and bright areas
    vec3 neon = c * (1.0 + edgeStrength * 3.0);
    c = mix(c, neon, 0.5);

    // Bloom on bright areas
    vec3 bloom = smoothstep(0.6, 1.0, c) * c * 0.4;
    c += bloom;

    // Boost saturation
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 1.4);

    // High contrast
    c = (c - 0.5) * 1.3 + 0.5;

    gl_FragColor = vec4(c, 1.0);
}

// Arctic/icy cold filter
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Cold color grading
    c.r = pow(c.r, 1.1) * 0.85;
    c.g = pow(c.g, 0.95) * 1.05;
    c.b = pow(c.b, 0.85) * 1.25;

    // Add icy cyan tint
    vec3 ice = vec3(0.7, 0.9, 1.0);
    c = mix(c, c * ice, 0.3);

    // Boost highlights (snow/ice shimmer)
    vec3 shimmer = smoothstep(0.7, 1.0, c) * vec3(0.8, 1.0, 1.0) * 0.2;
    c += shimmer;

    // Slight brightness boost
    c *= 1.05;

    gl_FragColor = vec4(c, 1.0);
}

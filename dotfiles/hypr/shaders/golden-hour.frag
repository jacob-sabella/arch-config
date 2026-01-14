// Warm golden hour / sunset filter
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Warm color grade
    c.r = pow(c.r, 0.9) * 1.15;
    c.g = pow(c.g, 0.95) * 1.05;
    c.b = pow(c.b, 1.1) * 0.85;

    // Add warm golden tint
    vec3 golden = vec3(1.0, 0.85, 0.6);
    c = mix(c, c * golden, 0.3);

    // Soft glow on highlights
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    vec3 glow = smoothstep(0.6, 1.0, c) * vec3(1.0, 0.8, 0.5) * 0.2;
    c += glow;

    // Gentle vignette
    vec2 distortion = (v_texcoord - 0.5) * 2.0;
    float vignette = 1.0 - 0.3 * dot(distortion, distortion);
    c *= vignette;

    gl_FragColor = vec4(c, 1.0);
}

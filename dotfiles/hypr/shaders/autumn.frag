// Autumn/fall color palette
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Warm autumn tones
    c.r = pow(c.r, 0.85) * 1.2;
    c.g = pow(c.g, 0.95) * 1.0;
    c.b = pow(c.b, 1.15) * 0.75;

    // Add orange/brown tint
    vec3 autumn = vec3(1.0, 0.7, 0.4);
    c = mix(c, c * autumn, 0.35);

    // Slight desaturation for muted fall colors
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 0.9);

    // Warm glow
    vec3 glow = smoothstep(0.6, 1.0, c) * vec3(1.0, 0.6, 0.3) * 0.15;
    c += glow;

    gl_FragColor = vec4(c, 1.0);
}

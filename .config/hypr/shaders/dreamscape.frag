// Dreamy soft focus with pastel color shift
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Simple multi-sample blur
    vec3 blur = c;
    blur += texture2D(tex, uv + vec2(0.002, 0.0)).rgb;
    blur += texture2D(tex, uv - vec2(0.002, 0.0)).rgb;
    blur += texture2D(tex, uv + vec2(0.0, 0.002)).rgb;
    blur += texture2D(tex, uv - vec2(0.0, 0.002)).rgb;
    blur /= 5.0;

    // Mix original with blur
    c = mix(c, blur, 0.4);

    // Pastel color shift
    c = pow(c, vec3(0.9));
    c = c * 1.1;

    // Add dreamy color tint
    vec3 dream = vec3(1.05, 1.0, 1.1);
    c *= dream;

    // Reduce contrast
    c = mix(vec3(0.5), c, 0.85);

    // Soft glow
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c += smoothstep(0.5, 1.0, c) * 0.15;

    gl_FragColor = vec4(c, 1.0);
}

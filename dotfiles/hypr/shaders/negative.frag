// Color negative/inversion
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Invert colors
    vec3 neg = vec3(1.0) - c;

    // Slight adjustment to preserve some luminance
    neg = pow(neg, vec3(0.95));

    gl_FragColor = vec4(neg, 1.0);
}

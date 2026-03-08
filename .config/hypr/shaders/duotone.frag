// Duotone effect - cyan and magenta
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Calculate luminance
    float luma = dot(c, vec3(0.299, 0.587, 0.114));

    // Map to two colors
    vec3 shadow = vec3(0.1, 0.2, 0.3);   // Deep cyan
    vec3 highlight = vec3(1.0, 0.4, 0.7); // Bright magenta

    vec3 duo = mix(shadow, highlight, luma);

    // Add slight contrast curve
    duo = pow(duo, vec3(0.9));

    gl_FragColor = vec4(duo, 1.0);
}

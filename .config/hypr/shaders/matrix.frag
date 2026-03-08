// Matrix-style green tint with subtle digital rain effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Convert to grayscale preserving luminance
    float luma = dot(c, vec3(0.299, 0.587, 0.114));

    // Matrix green tint
    vec3 matrix = vec3(0.0, luma * 1.2, luma * 0.5);

    // Add slight green glow to bright areas
    float glow = smoothstep(0.7, 1.0, luma) * 0.3;
    matrix += vec3(0.0, glow, glow * 0.3);

    // Boost contrast
    matrix = (matrix - 0.5) * 1.2 + 0.5;

    gl_FragColor = vec4(matrix, 1.0);
}

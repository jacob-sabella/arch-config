// X-ray vision effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Invert
    c = vec3(1.0) - c;

    // Edge detection for bone/structure emphasis
    vec2 uv = v_texcoord;
    vec3 n = texture2D(tex, uv + vec2(0.0, 0.002)).rgb;
    vec3 s = texture2D(tex, uv - vec2(0.0, 0.002)).rgb;
    vec3 e = texture2D(tex, uv + vec2(0.002, 0.0)).rgb;
    vec3 w = texture2D(tex, uv - vec2(0.002, 0.0)).rgb;

    vec3 edge = abs(n - s) + abs(e - w);
    float edgeStrength = length(edge);

    // Grayscale
    float gray = dot(c, vec3(0.299, 0.587, 0.114));

    // Add edges
    gray += edgeStrength * 0.5;

    // High contrast
    gray = (gray - 0.5) * 2.0 + 0.5;

    // Blue tint for X-ray look
    vec3 xray = vec3(gray * 0.8, gray * 0.9, gray * 1.0);

    gl_FragColor = vec4(xray, 1.0);
}

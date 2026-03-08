// Emboss/relief effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;

    // Sample neighboring pixels
    vec3 tl = texture2D(tex, uv + vec2(-0.002, -0.002)).rgb;
    vec3 br = texture2D(tex, uv + vec2(0.002, 0.002)).rgb;

    // Calculate difference
    vec3 diff = tl - br;

    // Convert to grayscale emboss
    float gray = dot(diff, vec3(0.299, 0.587, 0.114));

    // Center on gray and boost
    gray = gray + 0.5;

    // Add slight color tint
    vec3 emboss = vec3(gray * 0.95, gray, gray * 1.05);

    gl_FragColor = vec4(emboss, 1.0);
}

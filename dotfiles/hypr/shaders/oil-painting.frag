// Oil painting artistic effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = vec3(0.0);

    // Multi-sample with varying weights for painterly look
    float total = 0.0;
    for(float x = -2.0; x <= 2.0; x += 1.0) {
        for(float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * 0.003;
            float weight = 1.0 - length(vec2(x, y)) * 0.15;
            c += texture2D(tex, uv + offset).rgb * weight;
            total += weight;
        }
    }
    c /= total;

    // Boost saturation for oil paint look
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 1.3);

    // Increase contrast
    c = (c - 0.5) * 1.2 + 0.5;

    // Slight color quantization for paint strokes
    c = floor(c * 20.0) / 20.0;

    gl_FragColor = vec4(c, 1.0);
}

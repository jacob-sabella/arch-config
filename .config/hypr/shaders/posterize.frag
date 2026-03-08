// Posterize - reduce color levels
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Reduce to 6 levels per channel
    float levels = 6.0;
    c = floor(c * levels) / levels;

    // Boost saturation
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 1.3);

    // Increase contrast
    c = (c - 0.5) * 1.3 + 0.5;

    gl_FragColor = vec4(c, 1.0);
}

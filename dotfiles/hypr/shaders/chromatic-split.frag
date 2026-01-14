// Heavy chromatic aberration RGB split
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec2 offset = (uv - 0.5) * 2.0;

    // Strong RGB channel separation
    float strength = length(offset) * 0.02;

    float r = texture2D(tex, uv - offset * strength).r;
    float g = texture2D(tex, uv).g;
    float b = texture2D(tex, uv + offset * strength).b;

    vec3 c = vec3(r, g, b);

    // Boost saturation from the split
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 1.3);

    gl_FragColor = vec4(c, 1.0);
}

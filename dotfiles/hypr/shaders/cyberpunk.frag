precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;
    c = vec3(c.r * 1.1, c.g * 0.9, c.b * 1.2);
    c = mix(c, vec3(0.7, 0.2, 1.0), 0.2);
    float contrast = 1.3;
    c = (c - 0.5) * contrast + 0.5;
    gl_FragColor = vec4(c, 1.0);
}


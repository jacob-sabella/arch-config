precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;
    float g = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(g), c, 0.6);
    c *= vec3(0.95, 0.98, 1.0);
    gl_FragColor = vec4(c, 1.0);
}


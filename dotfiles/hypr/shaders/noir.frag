precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;
    float g = dot(c, vec3(0.299, 0.587, 0.114));
    gl_FragColor = vec4(vec3(g), 1.0);
}


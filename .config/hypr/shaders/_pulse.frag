precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;
    float p = 0.5 + 0.5*sin(time*2.0);
    // obvious, high-contrast pulsing
    c = mix(c, vec3(1.0, 0.2, 0.6), p*0.7);
    gl_FragColor = vec4(c, 1.0);
}


precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;
    c.r = pow(c.r * 1.2, 0.9);
    c.g = pow(c.g * 0.9, 1.1);
    c.b = pow(c.b * 1.3, 0.8);
    vec3 glow = smoothstep(0.6, 1.0, c) * 0.25;
    c += glow * vec3(1.0, 0.2, 0.6);
    gl_FragColor = vec4(c, 1.0);
}


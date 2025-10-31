precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord - 0.5;
    float dist = length(uv);
    float vignette = smoothstep(0.7, 0.3, dist);
    vec3 c = texture2D(tex, v_texcoord).rgb * vignette;
    c += vec3(0.1) * sin(uv.y * 200.0 + uv.x * 300.0);
    gl_FragColor = vec4(c, 1.0);
}


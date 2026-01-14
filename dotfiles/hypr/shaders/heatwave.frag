// Heat wave distortion effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

void main() {
    vec2 uv = v_texcoord;

    // Wavy distortion
    float wave1 = sin(uv.y * 15.0 + time * 3.0) * 0.01;
    float wave2 = sin(uv.x * 10.0 + time * 2.0) * 0.008;
    uv.x += wave1;
    uv.y += wave2;

    vec3 c = texture2D(tex, uv).rgb;

    // Warm color shift
    c.r *= 1.1;
    c.b *= 0.95;

    // Add heat shimmer (chromatic aberration)
    float shimmer = 0.003;
    c.r = texture2D(tex, uv + vec2(shimmer, 0.0)).r;
    c.b = texture2D(tex, uv - vec2(shimmer, 0.0)).b;

    gl_FragColor = vec4(c, 1.0);
}

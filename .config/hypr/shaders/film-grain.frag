// Analog film grain with subtle color shift
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Film grain
    float grain = rand(uv * time) * 0.08 - 0.04;
    c += grain;

    // Subtle warm film tint
    c.r *= 1.05;
    c.b *= 0.98;

    // Reduce contrast slightly for analog feel
    c = mix(vec3(0.5), c, 0.95);

    // Very subtle vignette
    vec2 dist = (uv - 0.5) * 2.0;
    float vignette = 1.0 - 0.2 * dot(dist, dist);
    c *= vignette;

    gl_FragColor = vec4(c, 1.0);
}

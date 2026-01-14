// Night vision goggles effect
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

    // Brightness boost
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    luma = pow(luma * 1.5, 0.8);

    // Green phosphor color
    vec3 nvg = vec3(0.0, luma * 1.3, luma * 0.4);

    // Add bloom to bright areas
    float bloom = smoothstep(0.6, 1.0, luma);
    nvg += vec3(0.0, bloom * 0.5, bloom * 0.2);

    // Noise/static
    float noise = rand(uv * time) * 0.05;
    nvg += noise;

    // Circular vignette (goggles view)
    vec2 center = uv - 0.5;
    float dist = length(center);
    float vignette = smoothstep(0.5, 0.3, dist);
    nvg *= vignette;

    // Scanlines
    nvg *= 0.95 + 0.05 * sin(uv.y * 300.0);

    gl_FragColor = vec4(nvg, 1.0);
}

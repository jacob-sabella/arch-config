// Watercolor painting effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;

    // Soft blur
    vec3 c = vec3(0.0);
    c += texture2D(tex, uv).rgb * 0.4;
    c += texture2D(tex, uv + vec2(0.003, 0.0)).rgb * 0.15;
    c += texture2D(tex, uv - vec2(0.003, 0.0)).rgb * 0.15;
    c += texture2D(tex, uv + vec2(0.0, 0.003)).rgb * 0.15;
    c += texture2D(tex, uv - vec2(0.0, 0.003)).rgb * 0.15;

    // Reduce saturation slightly
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(luma), c, 0.85);

    // Soften highlights (watercolor wash)
    c = pow(c, vec3(1.1));

    // Reduce contrast
    c = mix(vec3(0.5), c, 0.85);

    // Add paper texture simulation
    float paper = fract(sin(dot(uv * 300.0, vec2(12.9898, 78.233))) * 43758.5453);
    c += (paper - 0.5) * 0.02;

    gl_FragColor = vec4(c, 1.0);
}

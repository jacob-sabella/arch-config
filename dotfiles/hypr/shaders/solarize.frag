// Solarization/Sabattier effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Solarize: invert colors above threshold
    vec3 solar;
    solar.r = c.r < 0.5 ? c.r * 2.0 : 2.0 - c.r * 2.0;
    solar.g = c.g < 0.5 ? c.g * 2.0 : 2.0 - c.g * 2.0;
    solar.b = c.b < 0.5 ? c.b * 2.0 : 2.0 - c.b * 2.0;

    // Boost contrast
    solar = (solar - 0.5) * 1.4 + 0.5;

    // Slight color tint
    solar.r *= 1.1;
    solar.b *= 0.95;

    gl_FragColor = vec4(solar, 1.0);
}

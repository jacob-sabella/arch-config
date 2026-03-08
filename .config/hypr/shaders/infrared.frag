// Infrared/thermal vision effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

// Thermal color mapping
vec3 thermalColor(float t) {
    t = clamp(t, 0.0, 1.0);

    // Heat map: black -> purple -> red -> orange -> yellow -> white
    vec3 cold = vec3(0.0, 0.0, 0.2);
    vec3 purple = vec3(0.5, 0.0, 0.5);
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 orange = vec3(1.0, 0.5, 0.0);
    vec3 yellow = vec3(1.0, 1.0, 0.0);
    vec3 white = vec3(1.0, 1.0, 1.0);

    if (t < 0.2) return mix(cold, purple, t * 5.0);
    else if (t < 0.4) return mix(purple, red, (t - 0.2) * 5.0);
    else if (t < 0.6) return mix(red, orange, (t - 0.4) * 5.0);
    else if (t < 0.8) return mix(orange, yellow, (t - 0.6) * 5.0);
    else return mix(yellow, white, (t - 0.8) * 5.0);
}

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Calculate "heat" based on luminance
    float heat = dot(c, vec3(0.299, 0.587, 0.114));

    // Apply thermal color mapping
    vec3 thermal = thermalColor(heat);

    // Add slight scan line effect
    thermal *= 0.95 + 0.05 * sin(v_texcoord.y * 200.0);

    gl_FragColor = vec4(thermal, 1.0);
}

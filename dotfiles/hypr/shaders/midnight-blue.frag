// Cool midnight blue filter for late night coding
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Reduce overall brightness
    c *= 0.85;

    // Strong blue tint with reduced red
    c.r = pow(c.r, 1.3) * 0.7;
    c.g = pow(c.g, 1.1) * 0.9;
    c.b = pow(c.b, 0.9) * 1.2;

    // Add cool blue overlay
    vec3 midnight = vec3(0.15, 0.2, 0.35);
    c = mix(c, midnight, 0.15);

    // Preserve luminance to keep text readable
    float origLuma = dot(texture2D(tex, v_texcoord).rgb, vec3(0.299, 0.587, 0.114));
    float newLuma = dot(c, vec3(0.299, 0.587, 0.114));
    if (newLuma > 0.01) {
        c *= origLuma / newLuma * 0.9;
    }

    gl_FragColor = vec4(c, 1.0);
}

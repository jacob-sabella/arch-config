// Fractal Ripples - by kishimisu
// https://www.shadertoy.com/view/mtyGWy
// Tutorial: https://youtu.be/f4s1h2YETNY

// Luminance threshold: pixels above this are considered terminal text/content
const float threshold = 0.15;

// Cosine palette: https://iquilezles.org/articles/palettes/
vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    return a + b * cos(6.28318 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);

    for (float i = 0.0; i < 4.0; i++) {
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 col = palette(length(uv0) + i * .4 + iTime * .4);

        d = sin(d * 8. + iTime) / 8.;
        d = abs(d);
        d = pow(0.01 / d, 1.2);

        finalColor += col * d;
    }

    // Sample terminal content and preserve text/foreground pixels
    vec2 texUV = fragCoord / iResolution.xy;
    vec4 terminalColor = texture(iChannel0, texUV);
    float lum = dot(terminalColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    float mask = 1.0 - step(threshold, lum);
    vec3 blended = mix(terminalColor.rgb, finalColor, mask);

    fragColor = vec4(blended, terminalColor.a);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;

    vec4 center = texture(iChannel0, uv);

    // Animated pastel gradient
    float t = iTime * 0.4;

    vec3 pink = vec3(1.0, 0.7, 0.85);
    vec3 blue = vec3(0.7, 0.85, 1.0);
    vec3 purple = vec3(0.8, 0.6, 1.0);
    vec3 lavender = vec3(0.85, 0.7, 1.0);
    vec3 mint = vec3(0.7, 1.0, 0.85);

    float wave1 = sin(uv.y * 4.0 + uv.x * 2.0 + t) * 0.5 + 0.5;
    float wave2 = cos(uv.x * 3.0 - uv.y * 2.0 + t * 0.7) * 0.5 + 0.5;
    float wave3 = sin(uv.x * 2.5 + uv.y * 3.0 + t * 0.5) * 0.5 + 0.5;

    vec3 color1 = mix(pink, blue, wave1);
    vec3 color2 = mix(purple, lavender, wave2);
    vec3 color3 = mix(color1, color2, wave3);
    vec3 pastel = mix(color3, mint, sin(t * 0.2) * 0.3 + 0.2);

    // Text renders as-is
    if (center.a > 0.1) {
        fragColor = center;
        return;
    }

    // Check for nearby text - wider and stronger
    float textNear = 0.0;
    for (float x = -6.0; x <= 6.0; x += 1.0) {
        for (float y = -6.0; y <= 6.0; y += 1.0) {
            float dist = length(vec2(x, y));
            if (dist < 7.0) {
                float weight = 1.0 - (dist / 7.0);
                weight = weight * weight;
                textNear += texture(iChannel0, uv + pixel * vec2(x, y)).a * weight;
            }
        }
    }
    textNear = clamp(textNear / 8.0, 0.0, 1.0);

    // Subtle pastel
    vec3 subtlePastel = pastel * 0.2;

    // Stronger dark shadow
    vec3 finalColor = mix(subtlePastel, vec3(0.0), textNear);
    float finalAlpha = mix(0.06, min(textNear * 1.3, 1.0), textNear);

    fragColor = vec4(finalColor, finalAlpha);
}

// Vaporwave - subtle glow, readable text

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;

    vec4 center = texture(iChannel0, uv);

    // Text renders clean
    if (center.a > 0.5) {
        fragColor = center;
        return;
    }

    // Dark shadow behind text for readability
    float shadow = 0.0;
    shadow += texture(iChannel0, uv + pixel * vec2(-1.0, -1.0)).a;
    shadow += texture(iChannel0, uv + pixel * vec2(0.0, -1.0)).a;
    shadow += texture(iChannel0, uv + pixel * vec2(1.0, -1.0)).a;
    shadow += texture(iChannel0, uv + pixel * vec2(-1.0, 0.0)).a;
    shadow += texture(iChannel0, uv + pixel * vec2(1.0, 0.0)).a;
    shadow += texture(iChannel0, uv + pixel * vec2(-1.0, 1.0)).a;
    shadow += texture(iChannel0, uv + pixel * vec2(0.0, 1.0)).a;
    shadow += texture(iChannel0, uv + pixel * vec2(1.0, 1.0)).a;
    shadow = shadow / 8.0;

    // Outer glow - further out
    float glow = 0.0;
    glow += texture(iChannel0, uv + pixel * vec2(-5.0, 0.0)).a;
    glow += texture(iChannel0, uv + pixel * vec2(5.0, 0.0)).a;
    glow += texture(iChannel0, uv + pixel * vec2(0.0, -5.0)).a;
    glow += texture(iChannel0, uv + pixel * vec2(0.0, 5.0)).a;
    glow += texture(iChannel0, uv + pixel * vec2(-4.0, -4.0)).a;
    glow += texture(iChannel0, uv + pixel * vec2(4.0, -4.0)).a;
    glow += texture(iChannel0, uv + pixel * vec2(-4.0, 4.0)).a;
    glow += texture(iChannel0, uv + pixel * vec2(4.0, 4.0)).a;
    glow = glow / 8.0;

    // Vaporwave colors - subtle
    vec3 pink = vec3(1.0, 0.2, 0.6);
    vec3 cyan = vec3(0.2, 0.8, 1.0);

    float wave = sin(uv.y * 6.28 + iTime * 0.5) * 0.5 + 0.5;
    vec3 glowColor = mix(pink, cyan, wave);

    // Dark backing first, then subtle color glow
    float darkAlpha = shadow * 0.95;
    vec3 finalColor = glowColor * glow * 0.3;
    float finalAlpha = max(darkAlpha, glow * 0.15);

    fragColor = vec4(finalColor, finalAlpha);
}

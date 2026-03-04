// Text shadow for readable transparent backgrounds
// Adds a subtle dark glow behind text

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;

    vec4 center = texture(iChannel0, uv);

    // Sample 8 neighbors for edge detection
    float shadow = 0.0;
    shadow += texture(iChannel0, uv + vec2(-pixel.x, -pixel.y)).a;
    shadow += texture(iChannel0, uv + vec2(0.0, -pixel.y)).a;
    shadow += texture(iChannel0, uv + vec2(pixel.x, -pixel.y)).a;
    shadow += texture(iChannel0, uv + vec2(-pixel.x, 0.0)).a;
    shadow += texture(iChannel0, uv + vec2(pixel.x, 0.0)).a;
    shadow += texture(iChannel0, uv + vec2(-pixel.x, pixel.y)).a;
    shadow += texture(iChannel0, uv + vec2(0.0, pixel.y)).a;
    shadow += texture(iChannel0, uv + vec2(pixel.x, pixel.y)).a;

    // Normalize and create shadow intensity
    shadow = shadow / 8.0;

    // Dark background behind text areas
    vec3 shadowColor = vec3(0.0, 0.0, 0.0);
    float shadowAlpha = shadow * 0.5 * (1.0 - center.a);

    // Composite: shadow underneath, then original on top
    vec3 finalColor = mix(shadowColor, center.rgb, center.a);
    float finalAlpha = max(center.a, shadowAlpha);

    fragColor = vec4(finalColor, finalAlpha);
}

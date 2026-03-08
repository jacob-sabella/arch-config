// Readable Transparent - adds subtle text shadow/outline for readability on transparent backgrounds

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);

    // Sample neighboring pixels to detect text edges
    float pixelSize = 1.0 / iResolution.y;

    vec4 left = texture(iChannel0, uv + vec2(-pixelSize, 0.0));
    vec4 right = texture(iChannel0, uv + vec2(pixelSize, 0.0));
    vec4 up = texture(iChannel0, uv + vec2(0.0, pixelSize));
    vec4 down = texture(iChannel0, uv + vec2(0.0, -pixelSize));

    // Calculate edge intensity from neighboring alpha values
    float neighborAlpha = max(max(left.a, right.a), max(up.a, down.a));

    // Add dark shadow behind text (where neighbors have content but current pixel is transparent)
    float shadow = neighborAlpha * (1.0 - color.a) * 0.6;

    // Blend shadow with original
    vec3 finalColor = mix(vec3(0.0), color.rgb, color.a);
    float finalAlpha = max(color.a, shadow);

    fragColor = vec4(finalColor, finalAlpha);
}

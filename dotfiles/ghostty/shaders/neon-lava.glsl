void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;

    vec4 terminal = texture(iChannel0, uv);

    // Neon colors
    vec3 hotPink = vec3(1.0, 0.0, 0.5);
    vec3 magenta = vec3(1.0, 0.0, 0.8);
    vec3 purple = vec3(0.6, 0.0, 1.0);
    vec3 deepPurple = vec3(0.3, 0.0, 0.6);
    vec3 cyan = vec3(0.0, 1.0, 1.0);
    vec3 violet = vec3(0.8, 0.2, 1.0);
    vec3 coral = vec3(1.0, 0.4, 0.6);

    float t = iTime * 0.4;

    // Metaball positions - slow organic movement
    vec2 blob1 = vec2(
        0.3 + sin(t * 0.7) * 0.2,
        0.4 + cos(t * 0.5) * 0.3
    );
    vec2 blob2 = vec2(
        0.7 + sin(t * 0.5 + 2.0) * 0.2,
        0.6 + cos(t * 0.6 + 1.0) * 0.25
    );
    vec2 blob3 = vec2(
        0.5 + sin(t * 0.8 + 4.0) * 0.3,
        0.3 + cos(t * 0.4 + 3.0) * 0.2
    );
    vec2 blob4 = vec2(
        0.4 + sin(t * 0.6 + 1.5) * 0.25,
        0.7 + cos(t * 0.7 + 2.5) * 0.2
    );
    vec2 blob5 = vec2(
        0.6 + sin(t * 0.9 + 3.5) * 0.2,
        0.5 + cos(t * 0.55 + 0.5) * 0.3
    );

    // Aspect ratio correction
    vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);

    // Calculate metaball field
    float field = 0.0;
    field += 0.08 / length((uv - blob1) * aspect);
    field += 0.06 / length((uv - blob2) * aspect);
    field += 0.07 / length((uv - blob3) * aspect);
    field += 0.05 / length((uv - blob4) * aspect);
    field += 0.06 / length((uv - blob5) * aspect);

    // Smooth threshold for lava lamp effect
    float lava = smoothstep(0.8, 1.2, field);
    float glow = smoothstep(0.4, 1.0, field) * 0.5;

    // Color based on position and time
    float colorCycle1 = sin(t * 0.3 + uv.x * 3.0) * 0.5 + 0.5;
    float colorCycle2 = sin(t * 0.4 + uv.y * 2.0 + 1.0) * 0.5 + 0.5;
    float colorCycle3 = sin(t * 0.5 + uv.x + uv.y) * 0.5 + 0.5;

    // Mix neon colors
    vec3 lavaColor = mix(hotPink, magenta, colorCycle1);
    lavaColor = mix(lavaColor, purple, colorCycle2 * 0.6);
    lavaColor = mix(lavaColor, violet, colorCycle3 * 0.4);
    lavaColor = mix(lavaColor, cyan, sin(t * 0.2) * 0.15 + 0.15);

    vec3 glowColor = mix(deepPurple, purple, colorCycle2);
    glowColor = mix(glowColor, coral, colorCycle1 * 0.3);

    // Text shadow for readability
    float textShadow = 0.0;
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x + 1.5, y + 1.5) * pixel;
            textShadow += texture(iChannel0, uv - offset).a;
        }
    }
    textShadow = clamp(textShadow / 15.0, 0.0, 1.0);

    // Background gradient
    vec3 bgColor = mix(vec3(0.02, 0.0, 0.05), vec3(0.05, 0.0, 0.1), uv.y);

    // Build result
    vec3 result = terminal.rgb;

    // Add background and lava effects
    result += bgColor;
    result += glowColor * glow * 0.25;
    result += lavaColor * lava * 0.2;

    // Darken behind text for readability
    if (terminal.a < 0.1) {
        result = mix(result, vec3(0.0), textShadow * 0.6);
    }

    // Subtle scanlines
    float scan = 0.97 + 0.03 * sin(fragCoord.y * 0.8);
    result *= scan;

    fragColor = vec4(result, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;

    vec4 center = texture(iChannel0, uv);

    // Colors
    vec3 cyan = vec3(0.0, 1.0, 1.0);
    vec3 magenta = vec3(1.0, 0.0, 0.8);
    vec3 purple = vec3(0.5, 0.0, 1.0);
    vec3 pink = vec3(1.0, 0.3, 0.6);
    vec3 orange = vec3(1.0, 0.45, 0.0);
    vec3 red = vec3(1.0, 0.15, 0.25);
    vec3 deepPurple = vec3(0.2, 0.0, 0.3);

    vec3 pastelPink = vec3(1.0, 0.7, 0.85);
    vec3 pastelMint = vec3(0.7, 1.0, 0.9);
    vec3 pastelLavender = vec3(0.85, 0.7, 1.0);
    vec3 pastelPeach = vec3(1.0, 0.8, 0.7);
    vec3 pastelCoral = vec3(1.0, 0.7, 0.7);

    float t = iTime * 0.3;
    float gridSpeed = t * 3.0;

    float horizonY = 0.65;

    // Depth gradient
    float skyGrad = smoothstep(horizonY, 0.0, uv.y);
    vec3 depthColor = deepPurple * skyGrad * 0.2;

    // Color cycling
    float cycle1 = sin(t * 0.5 + uv.x * 2.0) * 0.5 + 0.5;
    float cycle2 = sin(t * 0.3 + uv.y * 3.0) * 0.5 + 0.5;
    float cycle3 = sin(t * 0.7 + uv.x + uv.y) * 0.5 + 0.5;

    float cycle4 = sin(t * 0.4 + uv.x * 1.5 - uv.y) * 0.5 + 0.5;

    vec3 gridColor = mix(cyan, magenta, cycle1);
    gridColor = mix(gridColor, purple, cycle2 * 0.4);
    gridColor = mix(gridColor, orange, cycle3 * 0.35);
    gridColor = mix(gridColor, red, cycle4 * 0.25);
    gridColor = mix(gridColor, pastelMint, cycle2 * 0.15);

    vec3 horizonColor = mix(magenta, pastelPink, cycle1);
    horizonColor = mix(horizonColor, orange, cycle3 * 0.3);
    horizonColor = mix(horizonColor, pastelLavender, cycle2 * 0.25);

    // Perspective grid
    float grid = 0.0;
    if (uv.y > horizonY) {
        float depth = (uv.y - horizonY) / (1.0 - horizonY);
        float perspX = (uv.x - 0.5) / (depth + 0.1);

        float gridX = perspX * 8.0;
        float gridY = 1.0 / (depth + 0.05) + gridSpeed;

        float lineThickness = 0.1 + (1.0 - depth) * 0.15;
        float lineX = 1.0 - smoothstep(0.0, lineThickness, abs(fract(gridX) - 0.5));
        float lineY = 1.0 - smoothstep(0.0, lineThickness, abs(fract(gridY) - 0.5));

        grid = max(lineX, lineY);
        grid *= smoothstep(0.0, 0.25, depth);
        grid *= 1.0 - depth * 0.3;
    }

    // Horizon
    float horizonLine = 1.0 - smoothstep(0.0, 0.006, abs(uv.y - horizonY));
    float horizonGlow = exp(-pow(abs(uv.y - horizonY) * 4.0, 2.0));

    // Sun
    vec2 sunPos = vec2(0.5, horizonY - 0.18);
    float sunDist = length((uv - sunPos) * vec2(1.0, 1.8));
    float sun = exp(-pow(sunDist * 6.0, 2.0));
    float sunGlow = exp(-pow(sunDist * 2.5, 2.0)) * 0.5;
    float stripes = smoothstep(0.4, 0.6, sin(uv.y * 60.0));
    float sunWithStripes = sun * (0.6 + 0.4 * stripes);
    vec3 sunColor = mix(pastelPeach, pastelCoral, cycle1);
    sunColor = mix(sunColor, orange, cycle4 * 0.4);
    sunColor = mix(sunColor, magenta, smoothstep(sunPos.y - 0.1, sunPos.y + 0.1, uv.y));

    // Text shadow
    float textShadow = 0.0;
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x + 1.5, y + 1.5) * pixel;
            textShadow += texture(iChannel0, uv - offset).a;
        }
    }
    textShadow = clamp(textShadow / 15.0, 0.0, 1.0);

    // Build result
    vec3 result = center.rgb;

    result += depthColor;
    result += gridColor * grid * 0.26;
    result += horizonColor * horizonGlow * 0.27;
    result += gridColor * horizonLine * 0.35;
    result += sunColor * sunWithStripes * 0.2;
    result += mix(pastelPeach, pastelPink, 0.5) * sunGlow * 0.11;

    if (center.a < 0.1) {
        result = mix(result, vec3(0.0), textShadow * 0.5);
    }

    float scan = 0.98 + 0.02 * sin(fragCoord.y * 0.5);
    result *= scan;

    fragColor = vec4(result, 1.0);
}

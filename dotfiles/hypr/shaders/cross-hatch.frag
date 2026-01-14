// Cross-hatch pen drawing effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Convert to luminance
    float luma = dot(c, vec3(0.299, 0.587, 0.114));

    // Cross-hatch patterns
    float hatch1 = sin((uv.x + uv.y) * 100.0);
    float hatch2 = sin((uv.x - uv.y) * 100.0);
    float hatch = (hatch1 + hatch2) * 0.5;

    // Apply hatching based on luminance
    float hatched = mix(hatch, 1.0, luma);
    hatched = smoothstep(0.3, 0.7, hatched);

    // Convert to ink drawing
    vec3 drawing = vec3(hatched);

    // Slight paper color
    drawing = mix(vec3(0.95, 0.93, 0.90), drawing, 0.9);

    gl_FragColor = vec4(drawing, 1.0);
}

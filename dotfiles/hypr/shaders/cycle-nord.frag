// Hyprland screen shader — Nord ⇄ Vaporwave Pastel Pulse
// Whole-screen color phase with optional animated gradient modulation.
// Luminance-preserving so it won't get dark.

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

/* ----- Knobs ----- */
const float SPEED_PHASE = 0.06;   // how fast the palette cycles (0.03 slow … 0.15 fast)
const float STRENGTH    = 0.35;   // overall tint amount (0.2 subtle … 0.6 bold)
const float GRAD_AMT    = 0.20;   // 0.0 = no gradient, 0.2 gentle “breathing” across screen
const float GRAD_FREQ   = 0.25;   // gradient waves across screen (0.15–0.4 nice)
const float SPEED_GRAD  = 0.10;   // gradient drift speed
const float PHASE_SPREAD= 0.15;   // 0.0 = same hue everywhere; >0 adds slight phase offset over screen
/* ------------------ */

/* cosine-smooth mix */
vec3 cosslerp(vec3 a, vec3 b, float t){
    float k = 0.5 - 0.5 * cos(3.14159265 * clamp(t, 0.0, 1.0));
    return mix(a, b, k);
}

/* 4-stop palettes (pastel-friendly) */
// Nord-ish (cool, soft)
vec3 N0 = vec3(0.18, 0.20, 0.25);  // #2E3440
vec3 N1 = vec3(0.23, 0.26, 0.32);  // #3B4252
vec3 N2 = vec3(0.62, 0.76, 0.92);  // #9EC2EB (pastel of #5E81AC)
vec3 N3 = vec3(0.74, 0.88, 0.94);  // #BDDFF0 (pastel of #88C0D0)

// Vaporwave (pastel variants to keep things gentle)
vec3 V0 = vec3(1.00, 0.62, 0.88);  // #FF9FDF
vec3 V1 = vec3(0.72, 0.90, 1.00);  // #B7E5FF
vec3 V2 = vec3(0.86, 0.70, 1.00);  // #DBB3FF
vec3 V3 = vec3(1.00, 0.96, 0.72);  // #FFF5B8

vec3 paletteSample(vec3 c0, vec3 c1, vec3 c2, vec3 c3, float t){
    t = clamp(t, 0.0, 1.0);
    if (t < 1.0/3.0) {
        float u = t * 3.0;                 return cosslerp(c0, c1, u);
    } else if (t < 2.0/3.0) {
        float u = (t - 1.0/3.0) * 3.0;     return cosslerp(c1, c2, u);
    } else {
        float u = (t - 2.0/3.0) * 3.0;     return cosslerp(c2, c3, u);
    }
}

/* blend Nord and Vaporwave palettes at phase t */
vec3 paletteBlend(float t){
    vec3 nord = paletteSample(N0, N1, N2, N3, t);
    vec3 vap  = paletteSample(V0, V1, V2, V3, t);
    return cosslerp(nord, vap, 0.5 + 0.5 * sin(6.2831853 * t)); // smooth back-and-forth
}

void main(){
    vec2 uv   = v_texcoord;
    vec3 base = texture2D(tex, uv).rgb;

    // global palette phase + slight spatial phase offset (optional)
    float phase = fract(time * SPEED_PHASE);
    float phOffset = PHASE_SPREAD * (uv.x + uv.y - 1.0); // tiny, keeps “whole screen” feel
    float t = fract(phase + phOffset);

    // color to tint toward (pastel)
    vec3 tint = paletteBlend(t);

    // luminance-preserving normalization so the image never darkens
    const vec3 W = vec3(0.299, 0.587, 0.114);
    float Ltint = max(dot(tint, W), 1e-6);
    vec3  tintN = tint / Ltint;  // average luma ≈ 1

    // animated gradient that modulates strength (not brightness)
    float grad = 1.0 + GRAD_AMT * sin(6.2831853 * (GRAD_FREQ * (uv.x + uv.y) + time * SPEED_GRAD));
    float k = clamp(STRENGTH * grad, 0.0, 1.0);

    // apply the luminance-safe tint
    vec3 outc = mix(base, base * tintN, k);

    gl_FragColor = vec4(outc, 1.0);
}


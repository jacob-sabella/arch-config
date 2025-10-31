// Hyprland screen shader — Hue Cycle (Muted Basic)
// Rotates hue globally, then clamps saturation to a soft level so colors stay muted.

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

/* Knobs */
const float SPEED     = 0.05;  // rotation speed (0.05 = slower, 0.2 = faster)
const float SAT_LEVEL = 0.55;  // 0.3–0.7: how saturated the final look is
const float BLEND     = 0.90;  // 0–1: how much of the muted-rotated color to use

// Stable hue rotation around gray axis (Rodrigues)
mat3 hueRotation(float a){
    const float invsqrt3 = 0.5773502691896258; // 1/sqrt(3)
    vec3 n = vec3(invsqrt3);
    float s = sin(a), c = cos(a), t = 1.0 - c;
    mat3 nn = mat3(
        n.x*n.x, n.x*n.y, n.x*n.z,
        n.y*n.x, n.y*n.y, n.y*n.z,
        n.z*n.x, n.z*n.y, n.z*n.z
    );
    mat3 nx = mat3(
         0.0,   -n.z,   n.y,
         n.z,    0.0,  -n.x,
        -n.y,    n.x,   0.0
    );
    return mat3(c) + t*nn + s*nx;
}

void main(){
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Rotate hues continuously
    float a = time * SPEED;
    vec3 r = hueRotation(a) * c;

    // Preserve original luminance to avoid brightness pumping
    float Y  = dot(c, vec3(0.299, 0.587, 0.114));
    float Y2 = max(dot(r, vec3(0.299, 0.587, 0.114)), 1e-6);
    r *= (Y / Y2);

    // Desaturate to a muted level
    vec3 muted = mix(vec3(Y), r, SAT_LEVEL);

    // Final mix with the original (so it never feels heavy-handed)
    vec3 outc = mix(c, muted, BLEND);

    gl_FragColor = vec4(outc, 1.0);
}


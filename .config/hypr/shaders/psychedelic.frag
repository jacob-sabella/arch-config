// Psychedelic color cycling
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

void main() {
    vec2 uv = v_texcoord;
    vec3 c = texture2D(tex, uv).rgb;

    // Get luminance
    float luma = dot(c, vec3(0.299, 0.587, 0.114));

    // Rainbow color cycling based on luminance and time
    float hue = fract(luma + time * 0.1 + uv.x * 0.1 + uv.y * 0.1);

    // HSV to RGB (simplified)
    vec3 psyche;
    float h = hue * 6.0;
    float s = 0.8;
    float v = luma * 1.2;

    int i = int(floor(h));
    float f = h - float(i);
    float p = v * (1.0 - s);
    float q = v * (1.0 - s * f);
    float t = v * (1.0 - s * (1.0 - f));

    if (i == 0) psyche = vec3(v, t, p);
    else if (i == 1) psyche = vec3(q, v, p);
    else if (i == 2) psyche = vec3(p, v, t);
    else if (i == 3) psyche = vec3(p, q, v);
    else if (i == 4) psyche = vec3(t, p, v);
    else psyche = vec3(v, p, q);

    // Boost saturation
    float newLuma = dot(psyche, vec3(0.299, 0.587, 0.114));
    psyche = mix(vec3(newLuma), psyche, 1.5);

    gl_FragColor = vec4(psyche, 1.0);
}

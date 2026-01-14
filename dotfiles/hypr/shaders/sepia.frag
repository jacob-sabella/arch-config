// Classic sepia tone old photograph effect
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Convert to grayscale
    float gray = dot(c, vec3(0.299, 0.587, 0.114));

    // Sepia tone matrix
    vec3 sepia;
    sepia.r = gray * 1.2;
    sepia.g = gray * 1.0;
    sepia.b = gray * 0.8;

    // Slight contrast boost
    sepia = (sepia - 0.5) * 1.1 + 0.5;

    // Vintage fade
    sepia = mix(vec3(0.9, 0.85, 0.7), sepia, 0.85);

    gl_FragColor = vec4(sepia, 1.0);
}

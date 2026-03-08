// Classic Game Boy green palette
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec3 c = texture2D(tex, v_texcoord).rgb;

    // Convert to grayscale
    float gray = dot(c, vec3(0.299, 0.587, 0.114));

    // Game Boy 4-color palette
    vec3 color0 = vec3(0.06, 0.22, 0.06);  // Darkest
    vec3 color1 = vec3(0.19, 0.38, 0.19);
    vec3 color2 = vec3(0.55, 0.67, 0.06);
    vec3 color3 = vec3(0.61, 0.73, 0.06);  // Lightest

    // Quantize to 4 levels
    vec3 gb;
    if (gray < 0.25) gb = color0;
    else if (gray < 0.5) gb = color1;
    else if (gray < 0.75) gb = color2;
    else gb = color3;

    gl_FragColor = vec4(gb, 1.0);
}

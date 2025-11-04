#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec3 color = texture(tex, v_texcoord).rgb;
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    fragColor = vec4(vec3(gray), 1.0);
}


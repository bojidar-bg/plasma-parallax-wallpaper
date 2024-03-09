#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};
layout(binding = 1) uniform sampler2D source;
layout(binding = 1) uniform sampler2D mask;
void main() {
    vec4 tex = texture(source, qt_TexCoord0);
    vec4 mtex = texture(mask, qt_TexCoord0);
    fragColor = tex * mtex.a * dot(mtex.rgb, vec3(0.344, 0.5, 0.156)) * qt_Opacity;
}

// For textureSize2D
#extension GL_EXT_gpu_shader4 : enable

varying vec2 texCoord;

uniform sampler2D m_Texture;

//XXX sample shaders https://code.fluendo.com/pigment/trac/browser/trunk/plugins/opengl/pgmrendergl1window.c?rev=239#L408
//XXX uses fract() to figure out which pixel to choose

const int Y = 0;
const int Cb = 1;
const int Cr = 2;

// BT.601 matrix from http://www.equasys.de/colorconversion.html
const vec3 BT601_bias = vec3 (-0.0625, -0.5, -0.5);
const mat3 BT601 = mat3(1.1640,  0.0000,  1.5960,
                        1.1640, -0.3920, -0.8130,
                        1.1640,  2.0170,  0.0000);

void main(){
    float texWidth = float(textureSize2D(m_Texture, 0).x);
    vec4 macropixel = texture2D(m_Texture, texCoord);
    vec3 color;
    color[Y] = (fract(texCoord.s * texWidth) < 0.5
                ? macropixel.g
                : macropixel.a) + BT601_bias.x;
    color[Cb] = macropixel.r + BT601_bias.y;
    color[Cr] = macropixel.b + BT601_bias.z;
    gl_FragColor = vec4(color * BT601, 1.0);
}

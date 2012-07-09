varying vec2 texCoord;
#ifdef SOURCE_TEX
uniform sampler2D m_SourceTex;
#endif
#ifdef TARGET_TEX
uniform sampler2D m_TargetTex;
#endif
uniform float m_Time;

void main() {
#ifdef SOURCE_TEX
    vec4 sourceColor = texture2D(m_SourceTex, texCoord);
#else
    vec4 sourceColor = vec4(0.0);
#endif
#ifdef TARGET_TEX
    vec4 targetColor = texture2D(m_TargetTex, texCoord);
#else
    vec4 targetColor = vec4(0.0);
#endif
    gl_FragColor = mix(sourceColor, targetColor, m_Time);
}

#include <AutoLight.cginc>
#include <UnityCG.cginc>
#include <UnityLightingCommon.cginc>

struct v2f_base
{
    float2 uv : TEXCOORD0;
    SHADOW_COORDS(1) // put shadows data into TEXCOORD1
    UNITY_FOG_COORDS(2)
    fixed3 diff : COLOR0;
    fixed3 ambient : COLOR1;
    float4 pos : SV_POSITION;
    fixed4 color : COLOR2;
};

v2f_base applyLighting(v2f_base o, float3 normal)
{
    half3 worldNormal = UnityObjectToWorldNormal(normal);
    half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
    o.diff = nl * _LightColor0.rgb;
    o.ambient = ShadeSH9(half4(worldNormal, 1));

    return o;
}

fixed3 getLighting(v2f_base i)
{
    // compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
    fixed shadow = SHADOW_ATTENUATION(i);
    // darken light's illumination with shadow, keep ambient intact
    return i.diff * shadow + i.ambient;
}
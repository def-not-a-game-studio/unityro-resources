#include <AutoLight.cginc>
#include <UnityCG.cginc>
#include <UnityLightingCommon.cginc>

half4 bilinearSample(sampler2D indexT, sampler2D LUT, float2 uv, float4 indexT_TexelSize)
{
    float2 TextInterval = 1.0 / indexT_TexelSize.zw;

    float tlLUT = tex2D(indexT, uv).x;
    float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;
    float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;
    float brLUT = tex2D(indexT, uv + TextInterval).x;

    float4 transparent = float4(0.0, 0.0, 0.0, 0.0);

    float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);
    float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);
    float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);
    float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);

    float2 f = frac(uv.xy * indexT_TexelSize.zw);
    float4 tA = lerp(tl, tr, f.x);
    float4 tB = lerp(bl, br, f.x);

    return lerp(tA, tB, f.y);
}

float4 billboardMeshTowardsCamera(float4 vertex)
{
    // billboard mesh towards camera
    float3 vpos = mul((float3x3)unity_ObjectToWorld, vertex.xyz);
    float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23,
                               1);
    float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
    float4 outPos = mul(UNITY_MATRIX_P, viewPos);

    return outPos;
}
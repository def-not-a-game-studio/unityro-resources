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

float rayPlaneIntersection(float3 rayDir, float3 rayPos, float3 planeNormal, float3 planePos)
{
    float denom = dot(planeNormal, rayDir);
    denom = max(denom, 0.000001);
    float3 diff = planePos - rayPos;
    return dot(diff, planeNormal) / denom;
}

float4 billboardMeshTowardsCamera(float3 vertex, float4 offset, float4 uv, bool isShadow = false)
{
    float3 vpos = mul((float3x3)unity_ObjectToWorld, vertex.xyz);
    float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
    float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);

    float4 pos = mul(UNITY_MATRIX_P, viewPos + offset / 32);

    // calculate distance to vertical billboard plane seen at this vertex's screen position
    float3 planeNormal = normalize(float3(UNITY_MATRIX_V._m20, 0.0, UNITY_MATRIX_V._m22));
    float3 planePoint = unity_ObjectToWorld._m03_m13_m23;
    float3 rayStart = _WorldSpaceCameraPos.xyz;
    float3 rayDir = -normalize(mul(UNITY_MATRIX_I_V, float4(viewPos.xyz, 1.0)).xyz - rayStart);
    // convert view to world, minus camera pos
    float dist = rayPlaneIntersection(rayDir, rayStart, planeNormal, planePoint);

    // calculate the clip space z for vertical plane
    float4 planeOutPos = mul(UNITY_MATRIX_VP, float4(rayStart + rayDir * dist, 1.0));
    float newPosZ = planeOutPos.z / planeOutPos.w * pos.w;

    // use the closest clip space z
    if (!isShadow)
    {
#if defined(UNITY_REVERSED_Z)
        pos.z = max(pos.z, newPosZ) + uv.z;
#else
        pos.z = min(pos.z, newPosZ) + uv.z;
#endif
    }
    return pos;
}

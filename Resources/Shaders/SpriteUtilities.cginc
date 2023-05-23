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

float rayPlaneIntersection(float3 rayDir, float3 rayPos, float3 planeNormal, float3 planePos)
{
    float denom = dot(planeNormal, rayDir);
    denom = max(denom, 0.000001);
    float3 diff = planePos - rayPos;
    return dot(diff, planeNormal) / denom;
}

float4 rotate(float4 vert, float rotation)
{
    float4 vOut = vert;
    vOut.x = vert.x * cos(radians(rotation)) - vert.y * sin(radians(rotation));
    vOut.y = vert.x * sin(radians(rotation)) + vert.y * cos(radians(rotation));
    return vOut;
}

half angle(float3 center, float3 pos1, float3 pos2)
{
    float3 dir1 = normalize(pos1 - center);
    float3 dir2 = normalize(pos2 - center);
    return degrees(acos(dot(dir1, dir2)));
}

float4x4 verticalBillboard()
{
    #if defined(USING_STEREO_MATRICES)
    float3 cameraPos = lerp(unity_StereoWorldSpaceCameraPos[0], unity_StereoWorldSpaceCameraPos[1], 0.5);
    #else
    float3 cameraPos = _WorldSpaceCameraPos;
    #endif

    float3 forward = normalize(cameraPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz);
    float3 right = cross(forward, float3(0, 1, 0));
    float yawCamera = atan2(right.x, forward.x) - UNITY_PI / 2; //Add 90 for quads to face towards camera
    float s, c;
    sincos(yawCamera, s, c);

    float3x3 transposed = transpose((float3x3)unity_ObjectToWorld);
    float3 scale = float3(length(transposed[0]), length(transposed[1]), length(transposed[2]));

    float3x3 newBasis = float3x3(
        float3(c * scale.x, 0, s * scale.z),
        float3(0, scale.y, 0),
        float3(-s * scale.x, 0, c * scale.z)
    ); //Rotate yaw to point towards camera, and scale by transform.scale

    float4x4 objectToWorld = unity_ObjectToWorld;
    //Overwrite basis vectors so the object rotation isn't taken into account
    objectToWorld[0].xyz = newBasis[0];
    objectToWorld[1].xyz = newBasis[1];
    objectToWorld[2].xyz = newBasis[2];

    return objectToWorld;
}

float4 cameraDistanceBillboard(float4 vertex, float offset)
{
    float4x4 objectToWorld = unity_ObjectToWorld;
    float2 pos = vertex.xy;

    float3 worldPos = mul(objectToWorld, float4(pos.x, pos.y, 0, 1)).xyz;
    float3 originPos = mul(objectToWorld, float4(pos.x, 0, 0, 1)).xyz; //world position of origin
    float3 upPos = originPos + float3(0, 1, 0); //up from origin

    float outDist = abs(pos.y); //distance from origin should always be equal to y

    float angleA = angle(originPos, upPos, worldPos); //angle between vertex position, origin, and up
    float angleB = angle(worldPos, _WorldSpaceCameraPos.xyz, originPos);
    //angle between vertex position, camera, and origin

    float camDist = distance(_WorldSpaceCameraPos.xyz, worldPos.xyz);

    if (pos.y > 0)
    {
        angleA = 90 - (angleA - 90);
        angleB = 90 - (angleB - 90);
    }

    float angleC = 180 - angleA - angleB; //the third angle

    float fixDist = 0;
    if (pos.y > 0)
        fixDist = outDist / sin(radians(angleC)) * sin(radians(angleA)); //supposedly basic trigonometry

    //determine move as a % of the distance from the point to the camera
    float decRate = (fixDist * 0.7 - offset / 2) / camDist; //where does the 4 come from? Who knows!

    float4 view = mul(UNITY_MATRIX_V, float4(worldPos, 1));
    float4 pro = mul(UNITY_MATRIX_P, view);

    #if UNITY_UV_STARTS_AT_TOP
    pro.z -= abs(UNITY_NEAR_CLIP_VALUE - pro.z) * decRate;
    #else
    pro.z += abs(UNITY_NEAR_CLIP_VALUE) * decRate;
    #endif

    return pro;
}

float getDecRate(float4 vertex, float offset)
{
    float2 pos = vertex.xy;

    float3 world_pos = mul(unity_ObjectToWorld, float4(pos.x, pos.y, 0, 1)).xyz;
    const float3 origin_pos = mul(unity_ObjectToWorld, float4(pos.x, 0, 0, 1)).xyz; //world position of origin
    const float3 up_pos = origin_pos + float3(0, 1, 0); //up from origin
    const float out_dist = abs(pos.y); //distance from origin should always be equal to y

    float angle_a = angle(origin_pos, up_pos, world_pos); //angle between vertex position, origin, and up
    float angle_b = angle(world_pos, _WorldSpaceCameraPos.xyz, origin_pos);
    //angle between vertex position, camera, and origin

    float cam_dist = distance(_WorldSpaceCameraPos.xyz, world_pos.xyz);

    if (pos.y > 0)
    {
        angle_a = 90 - (angle_a - 90);
        angle_b = 90 - (angle_b - 90);
    }

    const float angle_c = 180 - angle_a - angle_b; //the third angle

    float fix_dist = 0;
    if (pos.y > 0)
        fix_dist = out_dist / sin(radians(angle_c)) * sin(radians(angle_a)); //supposedly basic trigonometry

    //determine move as a % of the distance from the point to the camera
    return (fix_dist * 0.7 - offset / 2) / cam_dist;
}

float4 billboardMeshTowardsCamera(float4 vertex)
{
    // billboard mesh towards camera
    float3 vpos = mul((float3x3)unity_ObjectToWorld, vertex.xyz);
    float4 worldCoord = float4(unity_ObjectToWorld._m03_m13_m23, 1);
    float4 viewPivot = mul(UNITY_MATRIX_V, worldCoord);

    // Temporary ignoring shaders billboard rotation, handled by cs script until we join all quads sprites in one
    float4 viewPos = float4(viewPivot + mul(vpos, (float3x3)unity_ObjectToWorld), 1.0);
    // float4 pos = mul(UNITY_MATRIX_P, viewPos);
    float4 pos = UnityObjectToClipPos(vertex);

    // calculate distance to vertical billboard plane seen at this vertex's screen position
    const float3 planeNormal = normalize((_WorldSpaceCameraPos.xyz - unity_ObjectToWorld._m03_m13_m23) * float3(1, 0, 1));
    const float3 planePoint = unity_ObjectToWorld._m03_m13_m23;
    const float3 rayStart = _WorldSpaceCameraPos.xyz;
    const float3 rayDir = -normalize(mul(UNITY_MATRIX_I_V, float4(viewPos.xyz, 1.0)).xyz - rayStart); // convert view to world, minus camera pos
    float dist = rayPlaneIntersection(rayDir, rayStart, planeNormal, planePoint);

    // added check to get distance to an arbitrary ground plane
    float groundDist = rayPlaneIntersection(rayDir, rayStart, float3(0, 1, 0), planePoint);
    // use "min" distance to either plane (I think the distances are actually negative)
    dist = max(dist, groundDist);

    // calculate the clip space z for vertical plane
    float4 planeOutPos = mul(UNITY_MATRIX_VP, float4(rayStart + rayDir * dist, 1.0));
    float newPosZ = planeOutPos.z / planeOutPos.w * pos.w;

    // use the closest clip space z
    #if defined(UNITY_REVERSED_Z)
    pos.z = max(pos.z, newPosZ);
    #else
    pos.z = min(pos.z, newPosZ);
    #endif

    return pos;
}

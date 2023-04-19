Shader "Ragnarok/EffectShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("BlendSource", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("BlendDestination", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 0
        [Toggle] _ZWrite("ZWrite", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent+10"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
            "ForceNoShadowCasting" = "True"
            "DisableBatching" = "true"
        }
        LOD 100

        Cull[_Cull]
        Lighting Off
        ZWrite[_ZWrite]
        ZTest False
        Blend [_SrcBlend] [_DstBlend]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag keepalpha
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            float rayPlaneIntersection(float3 rayDir, float3 rayPos, float3 planeNormal, float3 planePos)
            {
                float denom = dot(planeNormal, rayDir);
                denom = max(denom, 0.000001);
                float3 diff = planePos - rayPos;
                return dot(diff, planeNormal) / denom;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv.xy;

                // billboard mesh towards camera
                float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                float4 worldCoord = float4(unity_ObjectToWorld._m03_m13_m23, 1);
                float4 viewPivot = mul(UNITY_MATRIX_V, worldCoord);

                // Temporary ignoring shaders billboard rotation, handled by cs script until we join all quads sprites in one
                float4 viewPos = float4(viewPivot + mul(vpos, (float3x3)unity_ObjectToWorld), 1.0);
                o.vertex = UnityObjectToClipPos(v.vertex);

                // calculate distance to vertical billboard plane seen at this vertex's screen position
                const float3 planeNormal = normalize(
                    (_WorldSpaceCameraPos.xyz - unity_ObjectToWorld._m03_m13_m23) * float3(1, 0, 1));
                const float3 planePoint = unity_ObjectToWorld._m03_m13_m23;
                const float3 rayStart = _WorldSpaceCameraPos.xyz;
                const float3 rayDir = -normalize(mul(UNITY_MATRIX_I_V, float4(viewPos.xyz, 1.0)).xyz - rayStart);
                // convert view to world, minus camera pos
                const float dist = rayPlaneIntersection(rayDir, rayStart, planeNormal, planePoint);

                // calculate the clip space z for vertical plane
                float4 planeOutPos = mul(UNITY_MATRIX_VP, float4(rayStart + rayDir * dist, 1.0));
                float newPosZ = planeOutPos.z / planeOutPos.w * o.vertex.w;

                // use the closest clip space z
                #if defined(UNITY_REVERSED_Z)
                o.vertex.z = max(o.vertex.z, newPosZ);
                #else
                        o.pos.z = min(o.pos.z, newPosZ);
                #endif

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                if (col.a == 0) discard;

                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
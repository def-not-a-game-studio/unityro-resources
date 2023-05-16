Shader "Custom/GroundShader"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Lightmap ("Lightmap", 2D) = "white" {}
        _Tintmap ("Tintmap", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            // compile shader into multiple variants, with and without shadows
            // (we don't care about any lightmaps yet, so skip these variants)
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            // shadow helper functions and macros
            #include "AutoLight.cginc"

            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1_lightmap : TEXCOORD1;
                float2 uv2_tintmap : TEXCOORD2;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1_lightmap : TEXCOORD1;
                float2 uv2_tintmap : TEXCOORD2;
                SHADOW_COORDS(3) // put shadows data into TEXCOORD1
                UNITY_FOG_COORDS(4)
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _Lightmap;
            sampler2D _Tintmap;

            float4 _MainTex_ST;
            float4 _Lightmap_ST;
            float4 _Tintmap_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1_lightmap = TRANSFORM_TEX(v.uv1_lightmap, _Lightmap);
                o.uv2_tintmap = TRANSFORM_TEX(v.uv2_tintmap, _Tintmap);

                o.pos = UnityObjectToClipPos(v.vertex);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0.rgb;
                o.ambient = ShadeSH9(half4(worldNormal, 1));

                TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
                fixed shadow = SHADOW_ATTENUATION(i);
                // darken light's illumination with shadow, keep ambient intact
                fixed3 lighting = i.diff * shadow + i.ambient;

                fixed4 base = tex2D(_MainTex, i.uv);
                fixed4 lightmap = tex2D(_Lightmap, i.uv1_lightmap);

                if (base.a == 0) discard;

                base.rgb *= lighting;

                if (length(i.uv2_tintmap))
                {
                    fixed4 tintmap = tex2D(_Tintmap, i.uv2_tintmap);
                    base *= fixed4(tintmap.bgr, 1.0);
                }

                base.rgb += lightmap.rgb;

                UNITY_APPLY_FOG(i.fogCoord, base);

                return base;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
Shader "UnityRO/SpriteShaderCustomLight"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Offset("Offset", Vector) = (0,0,0,0)
        _Alpha("Alpha", Range(0.0, 1.0)) = 1.0
        _Color("Color", Color) = (1,1,1,1)
        _Cutoff("Cutoff", Float) = 0
        _AttenuateAmbient("Attenuate Ambient", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="LODFading"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }

        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off

            HLSLPROGRAM
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "SpriteUtilities.cginc"

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 shadowCoords : TEXCOORD3;
                float2 uv : TEXCOORD0;
                float3 diff : COLOR0;
                float3 ambient : COLOR1;
                float4 color : COLOR2;
                float2 lightmapUV : TEXCOORD4;
                float3 normalWS   : TEXCOORD5;
                float3 sh         : TEXCOORD6;
            };

            struct Attributes
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
                float4 texcoord3 : TEXCOORD3;
                float4 color : COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                float _Alpha;
                float4 _Offset;
                float4 _Color;
                float _Cutoff;
                float _AttenuateAmbient;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.uv = IN.texcoord;
                OUT.color = IN.color;
                OUT.positionHCS = billboardMeshTowardsCamera(IN.vertex, _Offset, IN.texcoord);

                VertexPositionInputs positions = GetVertexPositionInputs(IN.vertex.xyz);
                // Convert the vertex position to a position on the shadow map
                float4 shadowCoordinates = GetShadowCoord(positions);
                // Pass the shadow coordinates to the fragment shader
                OUT.shadowCoords = shadowCoordinates;

                // The lightmap UV is usually in TEXCOORD1
                // If lightmaps are disabled, OUTPUT_LIGHTMAP_UV does nothing
                float3 normal = GetVertexNormalInputs(IN.normal).normalWS;

                OUTPUT_LIGHTMAP_UV(IN.texcoord1, unity_LightmapST, OUT.lightmapUV);
                OUTPUT_SH(normal, OUT.sh);
                OUT.normalWS = normal;

                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 col = tex2D(_MainTex, IN.uv);
                // col *= _Color;
                col.a *= IN.color.a * _Alpha;
                if (col.a == 0) discard;

                // ensures we never get too dark neither too bright
                half shadowAmount = clamp(GetMainLight(IN.shadowCoords).shadowAttenuation, 0.4, 1.0);
                float3 indiff = SAMPLE_GI(IN.lightmapUV, IN.sh, IN.normalWS);
                float3 diff = max(float3(0.1, 0.1, 0.1), min(float3(0.6, 0.6, 0.6), indiff));
                float3 lighting = diff * shadowAmount + (_MainLightColor * 0.55);
                // TODO: figure this out
                // if (_AttenuateAmbient)
                // {
                //     col.rgb *= lighting / 0.3;
                // }
                // else
                // {
                    col.rgb *= lighting;
                // }

                return col;
            }
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode"="ShadowCaster"
            }
            Cull Off
            ZTest LEqual
            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            #define _ALPHATEST_ON 1
            #define USE_UNITY_CROSSFADE 1

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "SpriteUtilities.cginc"

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR2;
            };

            struct Attributes
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 color : COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                float _Alpha;
                float4 _Offset;
                float4 _Color;
                float _Cutoff;
            CBUFFER_END


            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.uv = IN.texcoord;
                OUT.color = IN.color;
                // OUT.positionHCS = TransformObjectToHClip(IN.vertex.xyz);
                OUT.positionHCS = billboardMeshTowardsCamera(IN.vertex, _Offset, IN.texcoord, true);

                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                if (_Alpha < 1.0) discard;
                
                float4 col = tex2D(_MainTex, IN.uv);
                col.a *= IN.color.a * _Alpha;
                if (col.a == 0) discard;

                return col;
            }
            ENDHLSL
        }
    }
}
Shader "UnityRO/BillboardSpriteShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _PaletteTex("Texture", 2D) = "white" {}
        _Alpha("Alpha", Range(0.0, 1.0)) = 1.0
        _UsePalette("Use Palette", Float) = 0
        _Offset("Offset", Vector) = (0,0,0,0)

        _Color("Color", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
        }

        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Off
            Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include <UnityCG.cginc>
            #include <AutoLight.cginc>
            #include "SpriteUtilities.cginc"

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                // SHADOW_COORDS (                1                ) // put shadows data into TEXCOORD1
                // UNITY_FOG_COORDS(2)
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
                fixed4 color : COLOR2;
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
                fixed4 color : COLOR;
                // UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                sampler2D _PaletteTex;

                float4 _MainTex_TexelSize;
                float _Alpha;
                float _UsePalette;
                float4 _Offset;
                float _Rotation;
                float4 _Color;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.uv = IN.texcoord;
                OUT.color = IN.color;
                // OUT = applyLighting(OUT, v.normal);
                OUT.positionHCS = billboardMeshTowardsCamera(IN.vertex, _Offset, IN.texcoord);

                // UNITY_TRANSFER_FOG(o, o.pos);
                TRANSFER_SHADOW(OUT);

                return OUT;
            }

            fixed4 frag(Varyings IN) : SV_Target
            {
                // const fixed3 lighting = getLighting(i);

                fixed4 col = _UsePalette ? bilinearSample(_MainTex, _PaletteTex, IN.uv, _MainTex_TexelSize) : tex2D(_MainTex, IN.uv);

                col *= IN.color * _Color;
                // col.rgb *= lighting;

                if (col.a == 0.0) discard;
                col.a *= _Alpha;

                // UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDHLSL
        }

        Pass
        {
            Name "Caster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders

            #include <UnityCG.cginc>
            #include "SpriteUtilities.cginc"

            struct Varyings
            {
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                sampler2D _PaletteTex;

                uniform float4 _MainTex_ST;
                float4 _MainTex_TexelSize;
                float _Alpha;
                float _UsePalette;
                float4 _Offset;
                float _Rotation;
                float4 _Color;
                uniform fixed _Cutoff;
            CBUFFER_END

            Varyings vert(appdata_base v)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(OUT);
                OUT.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.pos = billboardMeshTowardsCamera(v.vertex, float4(0, 0, 0, 0), float4(0, 0, 0, 0));

                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                fixed4 col = _UsePalette
                         ? bilinearSample(_MainTex, _PaletteTex, IN.uv, _MainTex_TexelSize)
                         : tex2D(_MainTex, IN.uv);

                clip(col.a * _Color.a - _Cutoff);

                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDHLSL
        }
    }
}
Shader "UnityRO/PaletteShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _PaletteTex("Texture", 2D) = "white" {}
        _UsePalette("Use Palette", Float) = 0
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
            Name "Palette"

            HLSLPROGRAM
            #include <UnityCG.cginc>
            #include "SpriteUtilities.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                sampler2D _PaletteTex;

                float4 _MainTex_TexelSize;
                float _UsePalette;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = UnityObjectToClipPos(input.positionOS);
                output.uv = input.uv;
                return output;
            }

            float4 frag(Varyings input) : SV_TARGET
            {
                fixed4 col = _UsePalette ? bilinearSample(_MainTex, _PaletteTex, input.uv, _MainTex_TexelSize) : tex2D(_MainTex, input.uv);
                if (col.a == 0.0) discard;
                return col;
            }
            ENDHLSL
        }
    }
}
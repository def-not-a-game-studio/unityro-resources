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
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "DisableBatching" = "True"
        }

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "SpriteUtilities.cginc"

        sampler2D _MainTex;
        sampler2D _PaletteTex;

        float4 _MainTex_TexelSize;
        float  _Alpha;
        float  _UsePalette;
        float4 _Offset;
        float  _Rotation;
        float4 _Color;

        //from our globals
        float4 _RoAmbientColor;
        float4 _RoDiffuseColor;
        ENDCG

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            // compile shader into multiple variants, with and without shadows
            // (we don't care about any lightmaps yet, so skip these variants)
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            // shadow helper functions and macros
            #include "AutoLight.cginc"
            #include "LightUtilities.cginc"

            v2f_base vert(appdata_full v)
            {
                v2f_base o;

                o.uv = v.texcoord;
                o.color = v.color;
                o.pos = billboardMeshTowardsCamera(v.vertex, _Offset);

                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }

            fixed4 frag(v2f_base i) : SV_Target
            {
                fixed4 col = _UsePalette
                                 ? bilinearSample(_MainTex, _PaletteTex, i.uv, _MainTex_TexelSize)
                                 : tex2D(_MainTex, i.uv);
                float4 env = 1 - ((1 - _RoDiffuseColor) * (1 - _RoAmbientColor));
                env = env * 0.5 + 0.5;

                col *= i.color * _Color * float4(env.rgb, 1);

                if (col.a == 0.0) discard;
                col.a *= _Alpha;

                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG
        }
    }
}
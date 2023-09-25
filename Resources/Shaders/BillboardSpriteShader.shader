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
        ENDCG

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
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
                o = applyLighting(o, v.normal);
                o.pos = billboardMeshTowardsCamera(v.vertex, _Offset, v.texcoord, false);

                UNITY_TRANSFER_FOG(o, o.pos);
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f_base i) : SV_Target
            {
                const fixed3 lighting = getLighting(i);

                fixed4 col = _UsePalette
                 ? bilinearSample(_MainTex, _PaletteTex, i.uv, _MainTex_TexelSize)
                 : tex2D(_MainTex, i.uv);

                col *= i.color * _Color;
                col.rgb *= lighting;

                if (col.a == 0.0) discard;
                col.a *= _Alpha;

                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "Caster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders

            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uniform float4 _MainTex_ST;

            v2f vert(appdata_base v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.pos = billboardMeshTowardsCamera(v.vertex, (0, 0, 0, 0), (0,0,0,0), true);

                return o;
            }

            uniform fixed _Cutoff;

            float4 frag(v2f i) : SV_Target
            {
                fixed4 col = _UsePalette
                                    ? bilinearSample(_MainTex, _PaletteTex, i.uv, _MainTex_TexelSize)
                                    : tex2D(_MainTex, i.uv);

                clip(col.a * _Color.a - _Cutoff);

                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
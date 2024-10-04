Shader "Ragnarok/EffectShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        [PerRendererData] [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("BlendSource", Float) = 1
        [PerRendererData] [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("BlendDestination", Float) = 0
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
            "DisableBatching" = "False"
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
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag keepalpha

            #include "UnityCG.cginc"
            #include "SpriteUtilities.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            v2f vert(appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                
                o.uv = v.uv.xy;
                o.vertex = billboardMeshTowardsCamera(v.vertex, float4(0,0,0,0), float4(0,0,0,0));
                o.color = v.color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;

                // if (distance(col.rgb, float3(0,0,0)) < 0.1) discard;
                if (col.a == 0) discard;

                return col;
            }
            ENDCG
        }
    }
}
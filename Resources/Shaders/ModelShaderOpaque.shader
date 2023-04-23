Shader "Custom/ModelShaderOpaque"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "Queue" = "Transparent" "PreviewType" = "Plane"
        }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_Cull]

        CGPROGRAM
        #pragma surface surf Lambert alpha addshadow

        sampler2D _MainTex;
        float _Alpha;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D(_MainTex, IN.uv_MainTex);

            clip(c.a - 0.5f);

            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }

    Fallback "Mobile/VertexLit"
}
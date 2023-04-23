Shader "Custom/GroundShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Lightmap ("Base (RGB)", 2D) = "white" {}
        _Tintmap ("Base (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _Lightmap;
        sampler2D _Tintmap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv2_Lightmap;
            float2 uv3_Tintmap;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        //UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        //UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 lightmap = tex2D(_Lightmap, IN.uv2_Lightmap);

            //clip(c.a - 0.5f);
            if (c.a == 0.0)
            {
                discard;
            }

            if (length(IN.uv3_Tintmap))
            {
                fixed4 tintmap = tex2D(_Tintmap, IN.uv3_Tintmap);
                //tintmap *= 1.2;
                c *= fixed4(tintmap.bgr, 1.0);
            }

            //lightmap *= 1.2;

            o.Albedo = c.rgb + lightmap.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
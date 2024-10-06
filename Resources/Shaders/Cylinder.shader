Shader "Custom/Cylinder"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TopSize("Top Size", float) = 0.5
        _BottomSize("Bottom Size", float) = 0.5
        _Height("Height", float) = 1.0
        [HDR] _Color("Color", Color) = (1, 1, 1, 1)
        _Position("Position", Vector) = (0,0,0,0)
        _Rotate("Rotate", Range(0,2)) = 0
        _Angle("Angle", Float) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("BlendSource", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("BlendDestination", Float) = 10
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching" = "True"
        }

        Blend[_SrcBlend][_DstBlend]
        ZTest On
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _TopSize;
            float _BottomSize;
            float _Height;
            float4 _Color;
            float4 _Position;
            float _Rotate;
            float _Angle;
            float4x4 _RotationMatrix;

            float4 RotateAroundYInDegrees(float4 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float4(mul(m, vertex.xz), vertex.yw).xzyw;
            }

            v2f vert(appdata v)
            {
                v2f o;
                float size, height;
                if (v.vertex.z == 1.0)
                {
                    size = _TopSize;
                    height = _Height;
                }
                else
                {
                    size = _BottomSize;
                    height = 0.0;
                }

                float3 position = float3(_Position.x, -_Position.y, _Position.z);

                if (_Rotate == 2)
                {
                    position += mul(float3(v.vertex.x * size, height, v.vertex.y * size), _RotationMatrix);
                }
                else if (_Rotate == 1)
                {
                    position += RotateAroundYInDegrees(float4(v.vertex.x * size, height, v.vertex.y * size, 0.0), _Time * 500);
                }
                else
                {
                    position += float4(v.vertex.x * size, height, v.vertex.y * size, 0.0);
                }

                o.vertex = UnityObjectToClipPos(position);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                if (_Color.a == 0) discard;
                fixed4 col = tex2D(_MainTex, i.uv) * (_Color * 1.25);
                return col;
            }
            ENDCG
        }

        //UsePass "Mobile/Particles/Additive"
    }
}
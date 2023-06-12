Shader "Custom/Cylinder"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TopSize("Top Size", float) = 0.5
        _BottomSize("Bottom Size", float) = 0.5
        _Height("Height", float) = 1.0
        _Color("Color", Color) = (1, 1, 1, 1)
        _Position("Position", Vector) = (0,0,0,0)
        _Rotate("Rotate", Range(0,1)) = 0

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
            float4x4 _RotationMatrix;

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

                if (_Rotate)
                {
                    position += mul(float3(v.vertex.x * size, height, v.vertex.y * size), _RotationMatrix);
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
                //i.uv.y = 1 - i.uv.y;
                if (_Color.a == 0)
                {
                    discard;
                }
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                if (col.r < 0.01 && col.g < 0.01 && col.b < 0.01)
                {
                    discard;
                }
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col * _Color;
            }
            ENDCG
        }

        //UsePass "Mobile/Particles/Additive"
    }
}
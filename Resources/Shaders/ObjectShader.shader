Shader "Custom/ObjectShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _AmbientTex("Ambient (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Specular("Specular", Range(0,1)) = 0.0
        _Cutoff("Cutoff", Range(0,1)) = 0.5
        _AmbientIntensity("Ambient Intensity", Range(0,1)) = 1
        _LightmapIntensity("Lightmap Intensity", Range(0,1)) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Int) = 2
    }
    SubShader
    {
            Tags {"Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "BW" = "TrueProbes" "LightMode" = "ForwardBase"}

        LOD 200
                //Lighting Off

        //     Pass
        //    {
        //        Name "ShadowCaster"
        //        Tags { "LightMode" = "ShadowCaster" }

        //        Fog {Mode Off}
        //        ZWrite On ZTest Less Cull Off
        //        Offset 1, 1

        //        CGPROGRAM
        //    // Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it does not contain a surface program or both vertex and fragment programs.
        //    #pragma exclude_renderers gles
        //    #pragma vertex vert
        //    #pragma fragment frag
        //    #pragma fragmentoption ARB_precision_hint_fastest
        //    #pragma multi_compile_shadowcaster

        //    #include "UnityCG.cginc"

        //    float4 _Color;
        //    sampler2D _MainTex;
        //    fixed _Cutoff;


        //    struct v2f
        //    {
        //        V2F_SHADOW_CASTER;
        //        float2 uv : TEXCOORD1;
        //    };


        //    v2f vert(appdata_full v)
        //    {
        //        v2f o;
        //        //UNITY_INITIALIZE_OUTPUT(v,o);
        //        TRANSFER_SHADOW_CASTER(o)

        //      return o;
        //    }

        //    float4 frag(v2f i) : COLOR
        //    {
        //        fixed4 texcol = tex2D(_MainTex, i.uv);
        //        //clip(texcol.a - _Cutoff);
        //        SHADOW_CASTER_FRAGMENT(i)
        //    }
        //    ENDCG
        //}

        Pass
        {
            Cull [_CullMode]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma target 2.0
            #pragma multi_compile_fog




            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color    : COLOR;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;


            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 color    : COLOR;
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD2;
                float3 lightDir : TEXCOORD3;

                UNITY_FOG_COORDS(4)
                LIGHTING_COORDS(5, 6)

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _Cutoff;
            fixed _AmbientIntensity;
            fixed _LightmapIntensity;
            

#ifdef DIRLIGHTMAP_COMBINED
            SamplerState samplerunity_LightmapInd;
#endif



            //unity defined variables
            uniform float4 _LightColor0;

            //from our globals
            float4 _RoAmbientColor;
            float4 _RoDiffuseColor;
            float _RoLightmapAOStrength;
            float _Opacity;


            float4 Screen(float4 a, float4 b)
            {
                return 1 - (1 - a) * (1 - b);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.normal = normalize(v.normal).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
                o.uv2 = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                //o.worldpos = mul(unity_ObjectToWorld, v.vertex);


                UNITY_TRANSFER_FOG(o, o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 diffuse = tex2D(_MainTex, i.uv);
                

                clip(diffuse.a - _Cutoff);
                
#if LIGHTMAP_ON
                float4 lm = float4(DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2)), 1) * _LightmapIntensity;
                lm = clamp(lm, 0, 0.5);
#else
                float4 lm = float4(ShadeSH9(float4(i.normal, 1)),1);
                lm = clamp(lm, 0, 0.5);
                
#endif
                float4 ambienttex = float4(1, 1, 1, 1);

#ifdef DIRLIGHTMAP_COMBINED
                ///float4 lm2 = float4(DecodeLightmap(UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, i.uv2)), 1);

                fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_LightmapInd, i.uv2);
                //return float4(bakedDirTex.r, 1, 1, 1);
                ambienttex = bakedDirTex.rrrr;

#endif
                //lm = clamp(lm, 0, 0.4);

                //lm = floor(lm * 32) / 32;

                float3 L = normalize(i.lightDir);
                float3 N = normalize(i.normal);

                float attenuation = LIGHT_ATTENUATION(i);
                float4 ambient = _RoAmbientColor;


                float shadowStr = saturate(attenuation * _Opacity + (1 - _Opacity));

                float NdotL = saturate(dot(N, L));
                float4 diffuseTerm = NdotL * shadowStr; //* _DiffuseTint 

                //return attenuation;


                lm *= (0.5 + saturate(NdotL * 2) * 0.5);



                fixed ambientStrength = _RoLightmapAOStrength * _AmbientIntensity;

                ambienttex = ambienttex * ambientStrength + (1 - ambientStrength);
                
                
                //diffuse = diffuse * (_RoAmbientColor+lm * 2 * _RoOpacity);
                

                //diffuse = diffuse * lerp(0.5, 1, saturate(diffuseTerm));
                

                float4 finalColor = diffuse; // *(ambient + diffuseTerm);

                float env = 1 - ((1 - _RoDiffuseColor) * (1 - _RoAmbientColor));

                //this code here matches the original game and adds lightmaps the same as it does ground
                //because it wasn't built with lightmapping in mind it doesn't look great in most cases
                // finalColor *= (_RoAmbientColor + NdotL * _RoDiffuseColor) * ambienttex;
                // finalColor *= env;
                // finalColor += lm * 0.5 * _LightmapIntensity;
                // return finalColor;
                
                finalColor = saturate(NdotL * _RoDiffuseColor + clamp(_RoAmbientColor, 0, 0.5)) * shadowStr * diffuse * env + lm * 2 * (diffuse) * _LightmapIntensity * 0.8;
                finalColor *= ambienttex;
                finalColor *= 1 + (ambientStrength / 10);

                UNITY_APPLY_FOG(i.fogCoord, finalColor);

                return finalColor;

            }

            ENDCG
        }

		Pass
	        {
	            Tags { "LightMode" = "ForwardAdd" }
	            Blend SrcAlpha One
	            Fog { Color (0,0,0,0) } // in additive pass fog should be black
	            ZWrite Off
	            ZTest LEqual

	            CGPROGRAM
	            #pragma target 3.0

	            // -------------------------------------


	            #pragma shader_feature_local _NORMALMAP
	            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
	            #pragma shader_feature_local _METALLICGLOSSMAP
	            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
	            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
	            #pragma shader_feature_local _DETAIL_MULX2
	            #pragma shader_feature_local _PARALLAXMAP

	            #pragma multi_compile_fwdadd_fullshadows
	            #pragma multi_compile_fog
	            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
	            //#pragma multi_compile _ LOD_FADE_CROSSFADE

	            #pragma vertex vertAdd
	            #pragma fragment fragAdd
	            #include "UnityStandardCoreForward.cginc"

	            ENDCG
	        }

        //Tags { "RenderType" = "AlphaTest" }
        //LOD 200

        //CGPROGRAM
        //// Physically based Standard lighting model, and enable shadows on all light types
        //#pragma surface surf StandardSpecular fullforwardshadows alphatest:_Cutoff

        //#pragma target 3.0

        //sampler2D _MainTex;

        //struct Input
        //{
        //    float2 uv_MainTex;
        //    float4 color : COLOR;
        //};

        //half _Glossiness;
        //half _Specular;
        //fixed4 _Color;

        //// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        //// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        //// #pragma instancing_options assumeuniformscaling
        //UNITY_INSTANCING_BUFFER_START(Props)
        //    // put more per-instance properties here
        //UNITY_INSTANCING_BUFFER_END(Props)

        //void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        //{
        //    fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
        //    o.Albedo = c;
        //    o.Specular = _Specular;
        //    o.Smoothness = _Glossiness;
        //    o.Alpha = c.a;
        //}
        //ENDCG
    }
    FallBack "Legacy Shaders/Transparent/Cutout/VertexLit"
}

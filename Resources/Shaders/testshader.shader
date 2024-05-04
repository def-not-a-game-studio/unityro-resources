Shader "UnityRO/SuperCustom"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        [NoScaleOffset]_PaletteTex("PaletteTex", 2D) = "white" {}
        _Offset("Offset", Vector) = (0, 0, 0, 0)
        _Alpha("Alpha", Float) = 0
        _Color("Color", Color) = (1, 1, 1, 0)
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="LODFading"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
            Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex MYvert
        #pragma fragment frag

            // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float4 tangentWS;
                float4 texCoord0 : TEXCOORD0;
                float4 color;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
                float3 sh;
            #endif
                float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float4 uv0;
                float4 VertexColor;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
                float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
                float4 tangentWS : INTERP4;
                float4 texCoord0 : INTERP5;
                float4 color : INTERP6;
                float4 fogFactorAndVertexLight : INTERP7;
                float3 positionWS : INTERP8;
                float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            float rayPlaneIntersection(float3 rayDir, float3 rayPos, float3 planeNormal, float3 planePos)
            {
                float denom = dot(planeNormal, rayDir);
                denom = max(denom, 0.000001);
                float3 diff = planePos - rayPos;
                return dot(diff, planeNormal) / denom;
            }

            float4 billboardMeshTowardsCamera(float3 vertex, float4 offset, float4 uv)
            {
                // billboard mesh towards camera
                float3 vpos = mul((float3x3)UNITY_MATRIX_M, vertex.xyz);
                float4 worldCoord = float4(UNITY_MATRIX_M._m03_m13_m23, 1);
                float4 viewPivot = mul(UNITY_MATRIX_V, worldCoord);

                // Temporary ignoring shaders billboard rotation, handled by cs script until we join all quads sprites in one
                float4 viewPos = float4(viewPivot + mul(vpos, (float3x3)UNITY_MATRIX_M), 1.0);
                float4 pos = mul(UNITY_MATRIX_P, viewPos + offset);

                // calculate distance to vertical billboard plane seen at this vertex's screen position
                const float3 planeNormal = normalize((_WorldSpaceCameraPos.xyz - UNITY_MATRIX_M._m03_m13_m23) * float3(1, 0, 1));
                const float3 planePoint = UNITY_MATRIX_M._m03_m13_m23;
                const float3 rayStart = _WorldSpaceCameraPos.xyz;
                const float3 rayDir = -normalize(mul(UNITY_MATRIX_I_V, float4(viewPos.xyz, 1.0)).xyz - rayStart);
                // convert view to world, minus camera pos

                float dist = rayPlaneIntersection(rayDir, rayStart, planeNormal, planePoint);

                // added check to get distance to an arbitrary ground plane
                float groundDist = rayPlaneIntersection(rayDir, rayStart, float3(0, 1, 0), planePoint);

                // use "min" distance to either plane (I think the distances are actually negative)
                dist = max(dist, groundDist);

                // calculate the clip space z for vertical plane
                float4 planeOutPos = mul(UNITY_MATRIX_VP, float4(rayStart + rayDir * dist, 1.0));
                float newPosZ = planeOutPos.z / planeOutPos.w * pos.w;

                // use the closest clip space z
    #if defined(UNITY_REVERSED_Z)
                pos.z = max(pos.z, newPosZ) + uv.z;
    #else
	            pos.z = min(pos.z, newPosZ) + uv.z;
    #endif

                return pos;
            }

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.color.xyzw = input.color;
                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.color = input.color.xyzw;
                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            // --------------------------------------------------
            // Graph


            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                OUT = tex2D(indexT, uv);
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4 = _Color;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                                                                                    .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                                  texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                               texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
                                _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
                                _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
                                _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
                                _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
                                _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                                                                                              _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                                                                                              (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.xy),
                                                                                              _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                                                                              _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float4 _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4;
                Unity_Multiply_float4_float4(IN.VertexColor,
                                                                            _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4,
                                                                            _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4);
                float4 _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4,
                                                                                    _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4,
                                                                                    _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
                             _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
                             _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.BaseColor = (_Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
                output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

            PackedVaryings MYvert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output = BuildVaryings(input);
                output.positionCS = billboardMeshTowardsCamera(input.positionOS, _Offset, input.uv0);
                PackedVaryings packedOutput = (PackedVaryings)0;
                packedOutput = PackVaryings(output);
                return packedOutput;
            }
            
            
            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Off
            Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag

            // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float4 tangentWS;
                float4 texCoord0;
                float4 color;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
                float3 sh;
            #endif
                float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float4 uv0;
                float4 VertexColor;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
                float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
                float4 tangentWS : INTERP4;
                float4 texCoord0 : INTERP5;
                float4 color : INTERP6;
                float4 fogFactorAndVertexLight : INTERP7;
                float3 positionWS : INTERP8;
                float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.color.xyzw = input.color;
                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.color = input.color.xyzw;
                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                float2 TextInterval = 1.0 / indexT_TexelSize.zw;



                float tlLUT = tex2D(indexT, uv).x;

                float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;

                float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;

                float brLUT = tex2D(indexT, uv + TextInterval).x;



                float4 transparent = float4(0.0, 0.0, 0.0, 0.0);



                float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);

                float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);

                float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);

                float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);



                float2 f = frac(uv.xy * indexT_TexelSize.zw);

                float4 tA = lerp(tl, tr, f.x);

                float4 tB = lerp(bl, br, f.x);



                OUT = lerp(tA, tB, f.y);
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4 = _Color;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                         texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                          texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
                _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
                _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
                _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
                _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
                _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                    _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                    (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.xy),
                    _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                    _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float4 _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4;
                Unity_Multiply_float4_float4(IN.VertexColor,
                                       _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4,
                                       _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4);
                float4 _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4,
                             _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4,
                             _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
              _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
              _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.BaseColor = (_Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
                output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
            ZTest LEqual
            ZWrite On
            ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS;
                float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float4 uv0;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0 : INTERP0;
                float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
                output.texCoord0.xyzw = input.texCoord0;
                output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.texCoord0.xyzw;
                output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                float2 TextInterval = 1.0 / indexT_TexelSize.zw;



                float tlLUT = tex2D(indexT, uv).x;

                float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;

                float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;

                float brLUT = tex2D(indexT, uv + TextInterval).x;



                float4 transparent = float4(0.0, 0.0, 0.0, 0.0);



                float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);

                float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);

                float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);

                float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);



                float2 f = frac(uv.xy * indexT_TexelSize.zw);

                float4 tA = lerp(tl, tr, f.x);

                float4 tB = lerp(bl, br, f.x);



                OUT = lerp(tA, tB, f.y);
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                         texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
                    _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
                    _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
                    _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
                    _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                    _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
                    _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                                       _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                                       (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.xy),
                                       _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                       _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
                            _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
                            _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
            ZTest LEqual
            ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // Keywords
        #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS;
                float4 tangentWS;
                float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float4 uv0;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 tangentWS : INTERP0;
                float4 texCoord0 : INTERP1;
                float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }


            // --------------------------------------------------
            // Graph


            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                float2 TextInterval = 1.0 / indexT_TexelSize.zw;



                float tlLUT = tex2D(indexT, uv).x;

                float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;

                float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;

                float brLUT = tex2D(indexT, uv + TextInterval).x;



                float4 transparent = float4(0.0, 0.0, 0.0, 0.0);



                float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);

                float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);

                float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);

                float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);



                float2 f = frac(uv.xy * indexT_TexelSize.zw);

                float4 tA = lerp(tl, tr, f.x);

                float4 tB = lerp(bl, br, f.x);



                OUT = lerp(tA, tB, f.y);
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 NormalTS;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                         texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
        texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
                                                        _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
                                                        _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
                                                        _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
                                                        _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                                        _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
                                                        _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                                            _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                                            (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.xy),
                                            _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                            _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
                                             _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
                                             _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

            // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"


            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0;
                float4 texCoord1;
                float4 texCoord2;
                float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float4 uv0;
                float4 VertexColor;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0 : INTERP0;
                float4 texCoord1 : INTERP1;
                float4 texCoord2 : INTERP2;
                float4 color : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
                output.texCoord0.xyzw = input.texCoord0;
                output.texCoord1.xyzw = input.texCoord1;
                output.texCoord2.xyzw = input.texCoord2;
                output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.texCoord0.xyzw;
                output.texCoord1 = input.texCoord1.xyzw;
                output.texCoord2 = input.texCoord2.xyzw;
                output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }


            // --------------------------------------------------
            // Grap

            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                float2 TextInterval = 1.0 / indexT_TexelSize.zw;



                float tlLUT = tex2D(indexT, uv).x;

                float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;

                float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;

                float brLUT = tex2D(indexT, uv + TextInterval).x;



                float4 transparent = float4(0.0, 0.0, 0.0, 0.0);



                float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);

                float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);

                float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);

                float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);



                float2 f = frac(uv.xy * indexT_TexelSize.zw);

                float4 tA = lerp(tl, tr, f.x);

                float4 tB = lerp(bl, br, f.x);



                OUT = lerp(tA, tB, f.y);
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 Emission;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4 = _Color;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                         texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                          texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
                                    _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
                                    _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
                                    _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
                                    _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                    _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
                                    _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                                                            _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                                                            (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.xy),
                                                            _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                                            _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float4 _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4;
                Unity_Multiply_float4_float4(IN.VertexColor,
   _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4,
   _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4);
                float4 _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4,
                     _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4,
                     _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
                    _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
                    _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.BaseColor = (_Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4.xyz);
                surface.Emission = float3(0, 0, 0);
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
                output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
            ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"


            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float4 uv0;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
                output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                float2 TextInterval = 1.0 / indexT_TexelSize.zw;



                float tlLUT = tex2D(indexT, uv).x;

                float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;

                float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;

                float brLUT = tex2D(indexT, uv + TextInterval).x;



                float4 transparent = float4(0.0, 0.0, 0.0, 0.0);



                float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);

                float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);

                float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);

                float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);



                float2 f = frac(uv.xy * indexT_TexelSize.zw);

                float4 tA = lerp(tl, tr, f.x);

                float4 tB = lerp(bl, br, f.x);



                OUT = lerp(tA, tB, f.y);
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                         texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                          texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
             _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
             _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
             _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
             _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
             _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
             _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                                                                                                _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                                                                                                (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.xy),
                                                                                                _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                                                                                _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
                                                          _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
                                                          _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
            ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"


            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float4 uv0;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
                output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }


            // --------------------------------------------------
            // Graph


            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                float2 TextInterval = 1.0 / indexT_TexelSize.zw;



                float tlLUT = tex2D(indexT, uv).x;

                float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;

                float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;

                float brLUT = tex2D(indexT, uv + TextInterval).x;



                float4 transparent = float4(0.0, 0.0, 0.0, 0.0);



                float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);

                float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);

                float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);

                float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);



                float2 f = frac(uv.xy * indexT_TexelSize.zw);

                float4 tA = lerp(tl, tr, f.x);

                float4 tB = lerp(bl, br, f.x);



                OUT = lerp(tA, tB, f.y);
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                         texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                          texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
                           _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
                           _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
                           _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
                           _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                           _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
                           _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                                                                                             _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                                                                                             (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.
                                                                                                 xy),
                                                                                             _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                                                                             _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
                                                       _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
                                                       _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
            // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"


            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0;
                float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            struct SurfaceDescriptionInputs
            {
                float4 uv0;
                float4 VertexColor;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0 : INTERP0;
                float4 color : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            };

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _PaletteTex_TexelSize;
                float4 _Offset;
                float _Alpha;
                float4 _Color;
            CBUFFER_END

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                // output.positionCS = billboardMeshTowardsCamera(input.positionCS, _Offset, input.texCoord0);
                output.texCoord0.xyzw = input.texCoord0;
                output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.texCoord0.xyzw;
                output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PaletteTex);
            SAMPLER(sampler_PaletteTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

            // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

            // Graph Functions

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void bilinearSample_float(UnityTexture2D indexT, UnityTexture2D LUT, float2 uv, float4 indexT_TexelSize, out float4 OUT)
            {
                float2 TextInterval = 1.0 / indexT_TexelSize.zw;



                float tlLUT = tex2D(indexT, uv).x;

                float trLUT = tex2D(indexT, uv + float2(TextInterval.x, 0.0)).x;

                float blLUT = tex2D(indexT, uv + float2(0.0, TextInterval.y)).x;

                float brLUT = tex2D(indexT, uv + TextInterval).x;



                float4 transparent = float4(0.0, 0.0, 0.0, 0.0);



                float4 tl = tlLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(tlLUT, 1.0)).rgb, 1.0);

                float4 tr = trLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(trLUT, 1.0)).rgb, 1.0);

                float4 bl = blLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(blLUT, 1.0)).rgb, 1.0);

                float4 br = brLUT == 0.0 ? transparent : float4(tex2D(LUT, float2(brLUT, 1.0)).rgb, 1.0);



                float2 f = frac(uv.xy * indexT_TexelSize.zw);

                float4 tA = lerp(tl, tr, f.x);

                float4 tB = lerp(bl, br, f.x);



                OUT = lerp(tA, tB, f.y);
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
                return output;
            }

        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4 = _Color;
                UnityTexture2D _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                UnityTexture2D _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PaletteTex);
                float4 _UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4 = IN.uv0;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize.
                z;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.texelSize
                .w;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                                                                                         texelSize.x;
                float _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float = _Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D.
                texelSize.y;
                float4 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4;
                float3 _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3;
                float2 _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2;
                Unity_Combine_float(_TextureSize_705c6de57af744c09920eb32ef1e8c43_Width_0_Float,
                                  _TextureSize_705c6de57af744c09920eb32ef1e8c43_Height_2_Float,
                                  _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelWidth_3_Float,
                                  _TextureSize_705c6de57af744c09920eb32ef1e8c43_TexelHeight_4_Float,
                                  _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                  _Combine_0dfccca8e35f443f83c0e53f826031f3_RGB_5_Vector3,
                                  _Combine_0dfccca8e35f443f83c0e53f826031f3_RG_6_Vector2);
                float4 _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4;
                bilinearSample_float(_Property_734d739da6d24634b1d178f5c907206e_Out_0_Texture2D,
                                          _Property_19bcb818dc7c4c1b8aff3420aba22df3_Out_0_Texture2D,
                                          (_UV_464e77c2f0bd4dd1abaee8f81165ff84_Out_0_Vector4.xy),
                                          _Combine_0dfccca8e35f443f83c0e53f826031f3_RGBA_4_Vector4,
                                          _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4);
                float4 _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4;
                Unity_Multiply_float4_float4(IN.VertexColor,
                                                                                         _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4,
                                                                                         _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4);
                float4 _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Property_be6fc00126664bf0bbd08e24444650f2_Out_0_Vector4,
                                                         _Multiply_18e044683deb4cebbe2d77fa69ecf8ae_Out_2_Vector4,
                                                         _Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4);
                float _Split_683c419e73534c349ed64eac95c38d37_R_1_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    0];
                float _Split_683c419e73534c349ed64eac95c38d37_G_2_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    1];
                float _Split_683c419e73534c349ed64eac95c38d37_B_3_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    2];
                float _Split_683c419e73534c349ed64eac95c38d37_A_4_Float = _bilinearSampleCustomFunction_af4b6ac5e4824fce82c7b7091c2d8898_OUT_4_Vector4[
                    3];
                float _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float = _Alpha;
                float _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                Unity_Multiply_float_float(_Split_683c419e73534c349ed64eac95c38d37_A_4_Float,
                                                                           _Property_c039ca64edc24793861c8c7e8b83f77f_Out_0_Float,
                                                                           _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float);
                surface.BaseColor = (_Multiply_316c836b137442f0a362bf0d0a093e1e_Out_2_Vector4.xyz);
                surface.Alpha = _Multiply_e7098b4c6cd944299db3a1f5ae67cdee_Out_2_Float;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


                output.uv0 = input.texCoord0;
                output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
            ENDHLSL
        }
    }
    //    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    //    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    //    FallBack "Hidden/Shader Graph/FallbackError"
}
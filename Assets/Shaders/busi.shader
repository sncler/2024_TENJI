Shader "Custom/DoubleSidedTextureWithTilingAndOffset"
{
    Properties
    {
        _FrontTex ("Front Texture", 2D) = "white" {}
        _BackTex ("Back Texture", 2D) = "white" {}
        _SideColor ("Side Color", Color) = (1,1,1,1)
        
        // Tiling and Offset properties
        _FrontTexTiling ("Front Texture Tiling", Vector) = (1, 1, 0, 0)
        _BackTexTiling ("Back Texture Tiling", Vector) = (1, 1, 0, 0)
        _FrontTexOffset ("Front Texture Offset", Vector) = (0, 0, 0, 0)
        _BackTexOffset ("Back Texture Offset", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _FrontTex;
            sampler2D _BackTex;
            fixed4 _SideColor;
            float4 _FrontTexTiling; // (TilingX, TilingY)
            float4 _BackTexTiling;  // (TilingX, TilingY)
            float4 _FrontTexOffset; // (OffsetX, OffsetY)
            float4 _BackTexOffset;  // (OffsetX, OffsetY)

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_ObjectToWorld));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 表面か背面か側面かの判定
                float frontBack = dot(i.worldNormal, float3(0, 0, 1));
                
                if (frontBack > 0.5)
                {
                    // 表面 (TilingとOffsetを適用)
                    float2 tiledUV = i.uv * _FrontTexTiling.xy + _FrontTexOffset.xy;
                    return tex2D(_FrontTex, tiledUV);
                }
                else if (frontBack < -0.5)
                {
                    // 背面 (TilingとOffsetを適用)
                    float2 tiledUV = i.uv * _BackTexTiling.xy + _BackTexOffset.xy;
                    return tex2D(_BackTex, tiledUV);
                }
                else
                {
                    // 側面
                    return _SideColor;
                }
            }
            ENDCG
        }
    }
}

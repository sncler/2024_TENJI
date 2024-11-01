Shader "Unlit/360"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainTex3 ("Texture3", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off //<-
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
            sampler2D _MainTex3;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v.uv.x = 1 - v.uv.x; // UV反転
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i, bool isFrontFace : SV_IsFrontFace) : SV_Target
            {
                // 表面か裏面かを判定する
                if (isFrontFace)
                {
                    // 表面ならメインテクスチャ
                    return tex2D(_MainTex, i.uv);
                }
                else
                {
                    // 裏面なら別のテクスチャ
                    return tex2D(_MainTex3, i.uv);
                }
            }
            ENDCG
        }
    }
}

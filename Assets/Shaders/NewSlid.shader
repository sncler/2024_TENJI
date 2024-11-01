Shader "Custom/SpriteAspectRatioWithPadding"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _PaddingColor ("Padding Color", Color) = (1, 1, 1, 1)  // 余白の色
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;  // テクスチャのサイズ情報
            fixed4 _PaddingColor;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 画面の縦横比
                float screenAspectRatio = _ScreenParams.x / _ScreenParams.y;

                // テクスチャの縦横比
                float textureAspectRatio = _MainTex_TexelSize.x / _MainTex_TexelSize.y;

                // UV座標の調整
                float2 uv = i.uv;
                float2 adjustedUV = uv;

                // 縦横比を保って中央に画像を表示
                if (textureAspectRatio > screenAspectRatio)
                {
                    float scale = screenAspectRatio / textureAspectRatio;
                    adjustedUV.y = (uv.y - 0.5) * scale + 0.5;

                    // UVが範囲外なら余白として扱う
                    if (adjustedUV.y < 0.0 || adjustedUV.y > 1.0)
                    {
                        return _PaddingColor;
                    }
                }
                else
                {
                    float scale = textureAspectRatio / screenAspectRatio;
                    adjustedUV.x = (uv.x - 0.5) * scale + 0.5;

                    // UVが範囲外なら余白として扱う
                    if (adjustedUV.x < 0.0 || adjustedUV.x > 1.0)
                    {
                        return _PaddingColor;
                    }
                }

                // 画像のピクセル色を取得
                return tex2D(_MainTex, adjustedUV);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

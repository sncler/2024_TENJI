Shader "glassShader_Normalmap_Occlusion"
{
    Properties
    {
        _Mask("Mask", Int) = 1
        _MainTex("Main Texture", 2D) = "white" {}
        _Blur("Blur", Float) = 10
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Float) = 1.0
        _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }

        GrabPass {}

        Pass
        {
            Stencil
            {
                Ref [_Mask]
                Comp Always
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
                float4 vertColor : COLOR;
            };

            sampler2D _GrabTexture;
            sampler2D _NormalMap;
            sampler2D _OcclusionMap;

            float4 _GrabTexture_TexelSize;
            float _Blur;
            float _NormalStrength;
            float _OcclusionStrength;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.uv = v.uv; // Normalmap & OcclusionMap用のUV
                o.vertColor = v.color;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float blur = max(1.0, _Blur);
                float weight_total = 0.0;
                fixed4 blurCol = fixed4(0, 0, 0, 0);

                // Normalmapをサンプリングして視線方向を歪ませる
                float3 normal = tex2D(_NormalMap, i.uv).rgb * 2.0 - 1.0; // -1～1範囲
                normal.xy *= _NormalStrength; // Normal Strengthを適用
                float2 distortion = normal.xy * _GrabTexture_TexelSize.xy; // UV歪みを計算

                // OcclusionMapをサンプリング
                float occlusion = tex2D(_OcclusionMap, i.uv).r; // 遮蔽値 (赤チャンネル)
                occlusion = lerp(1.0, occlusion, _OcclusionStrength); // 強度を調整

                // x方向とy方向のブラー処理
                [loop]
                for (float y = -blur; y <= blur; y += 1.0)
                {
                    [loop]
                    for (float x = -blur; x <= blur; x += 1.0)
                    {
                        float2 offset = float2(x * _GrabTexture_TexelSize.x, y * _GrabTexture_TexelSize.y);
                        float distance_normalized = length(offset / (blur * _GrabTexture_TexelSize.xy));
                        float weight = exp(-0.5 * pow(distance_normalized, 2) * 5.0);

                        weight_total += weight;
                        blurCol += tex2Dproj(_GrabTexture, i.grabPos + float4(offset + distortion, 0, 0)) * weight;
                    }
                }

                // ブラー結果を正規化し、Occlusionを掛け算で適用
                blurCol /= weight_total;
                blurCol.rgb *= occlusion; // 遮蔽効果を乗算

                return blurCol;
            }
            ENDCG
        }
    }
}

Shader "Custom/RenderTextureLerpAuto"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _RenderTexture1 ("Render Texture 1", 2D) = "white" {}
        _RenderTexture2 ("Render Texture 2", 2D) = "black" {}
        _Speed ("Lerp Speed", float) = 1.0
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _RenderTexture1;
            sampler2D _RenderTexture2;
            float _Speed;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 時間を利用してLerpFactorを自動的に変化させる
                float time = _Time.y * _Speed;
                float lerpFactor = (sin(time) + 1.0) * 0.5; // 0から1の範囲で振動するように変換

                // RenderTextureから色を取得
                fixed4 color1 = tex2D(_RenderTexture1, i.uv);
                fixed4 color2 = tex2D(_RenderTexture2, i.uv);

                // 2つの色をLerpで補間
                fixed4 lerpedColor = lerp(color1, color2, lerpFactor);

                return lerpedColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

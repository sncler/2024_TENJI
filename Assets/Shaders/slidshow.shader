Shader "Effect/slidshow"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _BlurTex("Blurred Texture", 2D) = "white" {}
        _GlassColor("Glass Color", Color) = (1,1,1,0.5)
        _PixShape("Pixel Shape Texture", 2D) = "white" {}
        _UV_X("Pixel num x", Range(10,1600)) = 960
        _UV_Y("Pixel num y", Range(10,1600)) = 360
        _Intensity("intensity", float) = 1
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _Tex1 ("Texture 1", 2D) = "white" {}
        _Tex2 ("Texture 2", 2D) = "white" {}
        _Tex3 ("Texture 3", 2D) = "white" {}
        _Tex4 ("Texture 4", 2D) = "white" {}
        _TimeBetweenSlides ("Time Between Slides", Float) = 2.0
        _FadeDuration ("Fade Duration", Float) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _BlurTex;
            sampler2D _PixShape;
            sampler2D _Tex1;
            sampler2D _Tex2;
            sampler2D _Tex3;
            sampler2D _Tex4;

            float4 _GlassColor;
            float4 _MainTex_ST;
            float _UV_X, _UV_Y, _Intensity, _Cutoff;
            float _TimeBetweenSlides;
            float _FadeDuration;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time = _Time.y; // Unity provides a built-in _Time variable
                float totalTime = (_TimeBetweenSlides + _FadeDuration * 2.0) * 4.0;
                float slideTime = fmod(time, totalTime) / (totalTime / 4.0);

                fixed4 col1 = tex2D(_Tex1, i.uv);
                fixed4 col2 = tex2D(_Tex2, i.uv);
                fixed4 col3 = tex2D(_Tex3, i.uv);
                fixed4 col4 = tex2D(_Tex4, i.uv);

                fixed4 currentTex;
                fixed4 nextTex;
                float alpha = 0.0;

                if (slideTime < 1.0)
                {
                    currentTex = col1;
                    nextTex = col2;
                    alpha = saturate((slideTime * 4.0 - _TimeBetweenSlides) / _FadeDuration);
                }
                else if (slideTime < 2.0)
                {
                    currentTex = col2;
                    nextTex = col3;
                    alpha = saturate((slideTime - 1.0) * 4.0 / _FadeDuration);
                }
                else if (slideTime < 3.0)
                {
                    currentTex = col3;
                    nextTex = col4;
                    alpha = saturate((slideTime - 2.0) * 4.0 / _FadeDuration);
                }
                else
                {
                    currentTex = col4;
                    nextTex = col1;
                    alpha = saturate((slideTime - 3.0) * 4.0 / _FadeDuration);
                }

                fixed4 baseColor = tex2D(_MainTex, i.uv);
                fixed4 blurredColor = tex2D(_BlurTex, i.uv);

                // Blend base color with blurred color
                fixed4 color = lerp(baseColor, blurredColor, _GlassColor.a) * _GlassColor;

                // Pixelation and cutoff logic from the test shader
                float2 uv_res = float2(_UV_X, _UV_Y);
                float2 pixUV = i.uv * uv_res;
                fixed4 pixColor = tex2D(_PixShape, pixUV);

                if (color.a < _Cutoff || pixColor.a < _Cutoff)
                    discard;

                fixed4 finalColor = color * pixColor * _Intensity;

                return lerp(currentTex, nextTex, alpha) * finalColor;
            }
            ENDCG
        }
    }
}
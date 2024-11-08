Shader "Custom/noribennn4"
{
    Properties 
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _FloorTex("Floor Texture", 2D) = "white" {}
        _CeilTex("Ceiling Texture", 2D) = "white" {}
        _LeftWallTex("Left Wall Texture", 2D) = "white" {}
        _RightWallTex("Right Wall Texture", 2D) = "white" {}
        _BackWallTex("Back Wall Texture", 2D) = "white" {}
        _FrontTex("Front Wall Texture", 2D) = "white" {}
        _MidTex("Middle Texture", 2D) = "white" {}
        _DistanceBetweenFloors("Distance Between Floors", Float) = 0.25
        _DistanceBetweenWalls("Distance Between Walls", Float) = 0.25
        _FloorTexSizeAndOffset("Floor Texture Size And Offset", Vector) = (0.5, 0.5, 0.0, 0.0)
        _CeilTexSizeAndOffset("Ceil Texture Size And Offset", Vector) = (0.5, 0.5, 0.0, 0.5)
        _WallTexSizeAndOffset("Wall Texture Size And Offset", Vector) = (0.5, 0.5, 0.5, 0.0)
        _MidTexSizeAndOffset("Mid Texture Size And Offset", Vector) = (0.5, 0.5, 0.0, 0.0)
        _MidTexHeight("Middle Texture Height", Float) = 0.125
        _MidEdge("Middle Texture Edge", Float) = 0.01
        _Brightness("Brightness", Float) = 1.0 // 明るさ調整プロパティを追加
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #define INTERSECT_INF 9999999

    sampler2D _MainTex;
    sampler2D _FloorTex;
    sampler2D _CeilTex;
    sampler2D _LeftWallTex;
    sampler2D _RightWallTex;
    sampler2D _BackWallTex;
    sampler2D _FrontTex;
    sampler2D _MidTex;

    float _Brightness; // 明るさの変数

    // 残りのシェーダーコードは省略
    struct v2f
    {
        float4 pos : SV_POSITION;
        float3 objectViewDir : TEXCOORD0;
        float3 objectPos : TEXCOORD1;
    };

    float4 _FloorTexSizeAndOffset;
    float4 _CeilTexSizeAndOffset;
    float4 _WallTexSizeAndOffset;
    float4 _MidTexSizeAndOffset; // 中間平面用のサイズとオフセット
    float _MidTexHeight; // 中間平面の高さ
    float _MidEdge;

    float GetIntersectLength(float3 rayPos, float3 rayDir, float3 planePos, float3 planeNormal)
    {
        return dot(planePos - rayPos, planeNormal) / dot(rayDir, planeNormal);
    }

    float2 GetMidPlaneUV(float3 uvw)
    {
        uvw.x = (uvw.x) * _MidTexSizeAndOffset.x + _MidTexSizeAndOffset.z;
        uvw.y = (uvw.y) * _MidTexSizeAndOffset.y + _MidTexSizeAndOffset.w;
        return uvw.xy;
    }

    float2 GetCeilUV(float3 uvw)
    {
        uvw.x = (uvw.x - 1.0) * _CeilTexSizeAndOffset.x - _CeilTexSizeAndOffset.z;
        uvw.y = (uvw.y) * _CeilTexSizeAndOffset.y - _CeilTexSizeAndOffset.w;
        return float2(-uvw.x, uvw.y);
    }

    float2 GetFloorUV(float3 uvw)
    {
        uvw.x = (uvw.x) * _FloorTexSizeAndOffset.x + _FloorTexSizeAndOffset.z;
        uvw.y = (uvw.y) * _FloorTexSizeAndOffset.y + _FloorTexSizeAndOffset.w;
        return uvw.xy;
    }

    float2 GetLeftWallUV(float3 uvw)
    {
        uvw.x = (uvw.x) * _WallTexSizeAndOffset.x + _WallTexSizeAndOffset.z;
        uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
        return uvw.xy;
    }

    float2 GetRightWallUV(float3 uvw)
    {
        uvw.x = (uvw.x - 1.0) * _WallTexSizeAndOffset.x - _WallTexSizeAndOffset.z;
        uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
        return float2(-uvw.x, uvw.y);
    }

    float2 GetBackWallUV(float3 uvw)
    {
        uvw.x = (uvw.x - 1.0) * _WallTexSizeAndOffset.x - _WallTexSizeAndOffset.z;
        uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
        return float2(-uvw.x, uvw.y);
    }

    float2 GetFrontWallUV(float3 uvw)
    {
        uvw.x = (uvw.x) * _WallTexSizeAndOffset.x + _WallTexSizeAndOffset.z;
        uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
        return uvw.xy;
    }

    //---------------------------------------------------

    v2f vert(appdata_base i)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(i.vertex);
        o.objectViewDir = -ObjSpaceViewDir(i.vertex);
        o.objectPos = i.vertex;
            
        return o;
    }

    float _DistanceBetweenFloors;
    float _DistanceBetweenWalls;

    // レイの位置に微小なオフセットを追加
    float3 ApplySmallOffset(float3 position, float3 direction)
    {
        float offset = 1e-4; // 小さなオフセット
        return position + direction * offset;
    }

    half4 frag(v2f i) : SV_TARGET
    {
        float3 rayDir = normalize(i.objectViewDir);
        float3 rayPos = ApplySmallOffset(i.objectPos, rayDir);
        float3 planePos = float3(0, 0, 0);
        float3 planeNormal = float3(0, 0, 0);
        float intersect = INTERSECT_INF;
        float4 color = float4(0, 0, 0, 1);

        // 残りのコード...
        const float3 UpVec = float3(0, 1, 0);
        const float3 RightVec = float3(1, 0, 0);
        const float3 FrontVec = float3(0, 0, 1);

        // 床と天井
        {
            float which = step(0.0, dot(rayDir, UpVec));
            planeNormal = float3(0, lerp(1, -1, which), 0);
            planePos.xyz = 0.0;
            planePos.y = ceil(rayPos.y / _DistanceBetweenFloors);
            planePos.y -= lerp(1.0, 0.0, which);
            planePos.y *= _DistanceBetweenFloors;

            float i = GetIntersectLength(rayPos, rayDir, planePos, planeNormal);
            if (i < intersect)
            {
                intersect = i;

                float3 pos = rayPos + rayDir * i + 0.5;
                float3 uvw = pos.xzy;
                if (which == 0.0)
                    color = tex2D(_FloorTex, GetFloorUV(uvw));
                else
                    color = tex2D(_CeilTex, GetCeilUV(uvw));
            }
        }

        // 左右の壁
        {
            float which = step(0.0, dot(rayDir, RightVec));
            planeNormal = float3(lerp(1, -1, which), 0, 0);
            planePos.xyz = 0.0;
            planePos.x = ceil(rayPos.x / _DistanceBetweenWalls);
            planePos.x -= lerp(1.0, 0.0, which);
            planePos.x *= _DistanceBetweenWalls;

            float i = GetIntersectLength(rayPos, rayDir, planePos, planeNormal);
            if (i < intersect)
            {
                intersect = i;

                float3 pos = rayPos + rayDir * i + 0.5;
                float3 uvw = pos.zyx;
                if (which == 0.0)
                    color = tex2D(_LeftWallTex, GetLeftWallUV(uvw));
                else
                    color = tex2D(_RightWallTex, GetRightWallUV(uvw));
            }
        }

        // 奥と手前の壁
        {
            float which = step(0.0, dot(rayDir, FrontVec));
            planeNormal = float3(0, 0, lerp(1, -1, which));
            planePos.xyz = 0.0;
            planePos.z = ceil(rayPos.z / _DistanceBetweenWalls);
            planePos.z -= lerp(1.0, 0.0, which);
            planePos.z *= _DistanceBetweenWalls;

            float i = GetIntersectLength(rayPos, rayDir, planePos, planeNormal);
            if (i < intersect)
            {
                intersect = i;

                float3 pos = rayPos + rayDir * i + 0.5;
                float3 uvw = pos.xyz;
                if (which == 0.0)
                    color = tex2D(_BackWallTex, GetBackWallUV(uvw));
                else
                    color = tex2D(_FrontTex, GetFrontWallUV(uvw)); // 手前の壁を追加
            }
        }

                // **床と天井の間の中間平面を追加**
        {
            planeNormal = UpVec;
            planePos.y = _MidTexHeight; // プロパティで設定した高さ

            float i = GetIntersectLength(rayPos, rayDir, planePos, planeNormal);
            if (i < intersect)
            {
                intersect = i;
                float3 pos = rayPos + rayDir * i + 0.5;
                float3 uvw = pos.xzy;
                float4 midTexColor = tex2D(_MidTex, GetMidPlaneUV(uvw)); // 中間平面用のテクスチャを取得

                // アルファ値が0未満なら描画しない
                if (midTexColor.a > _MidEdge)
                {
                    color = midTexColor; // アルファ値がある部分のみ描画
                }
            }
        }
        // 最後に明るさを適用
        color.rgb *= _Brightness;

        return half4(color.rgb, color.a);
    }
    ENDCG

    SubShader 
    {
        Tags { "RenderType" = "Transparent" }
        LOD 200
        Cull Back
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }

    FallBack "Diffuse"
}

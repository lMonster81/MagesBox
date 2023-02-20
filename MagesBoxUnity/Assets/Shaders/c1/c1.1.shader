// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Shader 名字（可目录式结构）
Shader "c1/c1"
{
    //材质参数面板
    Properties
    {
        //在shader中使用的名字，参数面板展示的名字，格式，默认值
        //_加下划线是约定俗成的格式

        //浮点
        _Float("Float", Float) = 0.0
        _Range("Range", Range(0.0, 1.0)) = 0.0
        _Vector("Vector", Vector) = (1,1,1,1)
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("MainTex", 2D) = "black"{}

        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode", int) = 2
    }

    SubShader
    {

        Tags{"Queue" = "Transparent"}

        pass
        {
            //Front Back, 默认是on
            //Cull Off

            Cull [_CullMode]

            //混合
            //第一个参数对象为当前目标，第二个参数对象为颜色缓存
            //Blend SrcAlpha OneMinusSrcAlpha
            //Blend SrcAlpha One
            //半透明队列要关闭深度写入
            //Zwrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                //这里的TexCoord0语义，表示将第一套纹理的坐标填充到该参数
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 color : Color;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                //这里的TexCoord可以存储值，用于指示任意高精度数据，如纹理坐标和位置
                float2 uv : TEXCOORD0;
            };

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            //类型，大小位数，一般使用
            //float 32 坐标点
            //half 16 uv，大部分向量
            //fix 8 颜色

            v2f vert(appdata v)
            {
                v2f o;
                float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
                float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
                float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);

                //用一个内置函数代替
                o.pos = UnityObjectToClipPos(v.vertex);

                o.pos = pos_clip;
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                float4 color = tex2D(_MainTex, i.uv);
                return color;
                //float temp = 1.0;
                //return temp.xxxx; ( = float4(temp, temp, temp, temp))
                //saturate(temp) saturate将值限制在01范围
            }

            ENDCG
        }
    }
}
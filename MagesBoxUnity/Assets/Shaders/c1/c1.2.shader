// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "c1/c1.2"
{
    //材质参数面板
    Properties
    {
        _RimPower("RimPower", Float) = 1.0
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("MainTex", 2D) = "black"{}

        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode", int) = 2
    }

    SubShader
    {

        Tags{"Queue" = "Transparent"}

        pass
        {
            Cull Off

            Cull [_CullMode]

            Blend SrcAlpha OneMinusSrcAlpha
            //半透明队列要关闭深度写入
            Zwrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 color : Color;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_world : TEXCOORD1;
                float3 view_world : TEXCOORD2;
            };

            float _RimPower;
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                //因为缩放问题，法线到世界空间需要特殊转换
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));
                float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view_world = normalize(_WorldSpaceCameraPos.xyz - pos_world);

                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                //因为插值的原因，还需要再标准化一次
                float normal_world = normalize(i.normal_world);
                float3 view_world = normalize(i.view_world);
                float NdotV = saturate(dot(normal_world, view_world));
                float rim = pow(1.0 - NdotV, _RimPower);

                return float4(_Color.rgb, rim);
            }

            ENDCG
        }
    }
}
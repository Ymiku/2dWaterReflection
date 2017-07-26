Shader "Sprites/2DWater"
{
	Properties
	{
	[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
	_NoiseTex ("Noise Texture", 2D) = "white" {}
	_ReflectionTex ("Reflection Texture", 2D) = "white" {}
	_StencilMask("Stencil Mask", Int) = 0
	_Color ("Tint", Color) = (1,1,1,1)
	_woffset("offset",float) = 0
	_wScale("scale",float) = 0
	_wSpeed("speed",float) = 0
	[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
	}
	 
	SubShader
	{
		Tags
		{ 
		"Queue"="Transparent"
		"IgnoreProjector"="True"
		"RenderType"="Transparent"
		"PreviewType"="Plane"
		"CanUseSpriteAtlas"="True"
		}
		 
		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha
		Pass
		{
			Stencil
			{
			Ref[_StencilMask]
			Comp equal
			Pass keep
			Fail keep
			ZFail replace
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#include "UnityCG.cginc"
			 
			struct appdata_t
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			 
			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
			};
			 
			fixed4 _Color;
			sampler2D _NoiseTex;
			sampler2D _ReflectionTex;
			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif
				 
				return OUT;
			}
			 
			sampler2D _MainTex;
			float _woffset;
			float _wScale;
			float _wSpeed;
			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 p = tex2D(_NoiseTex, IN.texcoord+float2(_Time.x*_wSpeed,0));
				float coord = 1-IN.texcoord.y;
				float2 reUV = float2(IN.texcoord.x+p.x*_wScale*coord,coord+p.y*_wScale*coord);

				fixed4 reflection = tex2D(_ReflectionTex,reUV);
				reflection += tex2D(_ReflectionTex,reUV+float2(_woffset,0));
				reflection += tex2D(_ReflectionTex,reUV+float2(-_woffset,0));
				reflection += tex2D(_ReflectionTex,reUV+float2(0,_woffset));
				reflection += tex2D(_ReflectionTex,reUV+float2(0,-_woffset));
				reflection /=5;
				fixed4 c = reflection+tex2D(_MainTex,IN.texcoord)/10;
				c*=IN.color;
				c.rgb *= c.a;
				return c;
			}
			ENDCG
		}

	}
}
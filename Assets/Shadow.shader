Shader "Sprites/shadow"
{
Properties
{
[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
_NoiseTex ("Noise Texture", 2D) = "white" {}
_StencilMask("Stencil Mask", Int) = 0
_Color ("Tint", Color) = (1,1,1,1)
_SizeY("SizeY",float) = 0
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
 
fixed4 frag(v2f IN) : SV_Target
{
fixed4 c = tex2D(_MainTex, IN.texcoord)*IN.color;
c.rgb *= c.a;
return c;
}
ENDCG
}
Pass
{
 
LOD 200
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
float _SizeY;
v2f vert(appdata_t IN)
{
v2f OUT;
float4 dis;
dis.xzw = IN.vertex.xzw;
dis.y = -IN.vertex.y - _SizeY;
dis.x -= (dis.y+(_SizeY/2))*0.5;
dis.y -= (dis.y+(_SizeY/2))*0.5;
float4 v = mul(UNITY_MATRIX_MVP, dis);
fixed4 p = tex2Dlod(_NoiseTex, float4(IN.texcoord+float2(_Time.x,_Time.x)*0.5,0,0));
OUT.vertex = v+p*0.2;
OUT.texcoord = IN.texcoord;
OUT.color = IN.color * _Color;
#ifdef PIXELSNAP_ON
OUT.vertex = UnityPixelSnap (OUT.vertex);
#endif
 
return OUT;
}
 
sampler2D _MainTex;
 
fixed4 frag(v2f IN) : SV_Target
{
fixed4 p = tex2D(_NoiseTex, IN.texcoord)*IN.color;
fixed4 c = tex2D(_MainTex, IN.texcoord)*IN.color;
c.a *= 0.6;
c.rgb *= c.a;
c = floor(c*100)/100;
// c += ceil(IN.vertex.y*5)/20/256;
// c += ceil(IN.vertex.x*5)/20/256;
return c;
}
ENDCG
}
}
}
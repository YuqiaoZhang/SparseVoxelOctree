// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"


////////////////////////////
//       ENUMERATIONS
////////////////////////////

//#define	DISPLAY_DEPTH 0
//#define	DISPLAY_NORMAL 1
//#define	DISPLAY_POSITION 2
//#define	DISPLAY_COLOR 3
//#define	DISPLAY_TOTAL 4
//#define	DISPLAY_LIGHTS 5

/////////////////////////////////////
// Uniforms, Attributes, and Outputs
////////////////////////////////////
//uniform layout (location = deferredShader_u_persp) mat4 u_persp;
uniform layout (location = deferredShader_u_modelview) mat4 u_modelview;
uniform layout (location = deferredShader_u_lightMVP) mat4 u_lightMVP;

uniform layout (binding = deferredShader_u_Depthtex) sampler2D u_Depthtex;
uniform layout (binding = deferredShader_u_Normaltex) sampler2D u_Normaltex;
uniform layout (binding = deferredShader_u_Positiontex) sampler2D u_Positiontex;
uniform layout (binding = deferredShader_u_Colortex) sampler2D u_Colortex;

uniform layout (binding = deferredShader_u_shadowmap) sampler2D u_shadowmap;

uniform layout (location = deferredShader_u_Far) float u_Far;
uniform layout (location = deferredShader_u_Near) float u_Near;
//uniform layout (location = deferredShader_u_DisplayType) int u_DisplayType;

//uniform layout (location = deferredShader_u_ScreenWidth) int u_ScreenWidth;
//uniform layout (location = deferredShader_u_ScreenHeight) int u_ScreenHeight;

uniform layout (location = deferredShader_u_Light) vec4 u_Light;
uniform layout (location = deferredShader_u_LightColor) vec3 u_LightColor;
//uniform layout (location = deferredShader_u_eyePos) vec3 u_eyePos;

layout (location = 0) in vec2 fs_Texcoord;

layout (location = 0) out vec4 out_Color;
///////////////////////////////////////

uniform layout (location = deferredShader_zerothresh) float zerothresh = 1.0f;
uniform layout (location = deferredShader_falloff) float falloff = 0.1f;


/////////////////////////////////////
//				UTILITY FUNCTIONS
/////////////////////////////////////

//Depth used in the Z buffer is not linearly related to distance from camera
//This restores linear depth
float linearizeDepth(float exp_depth, float near, float far) {
    return	(2 * near) / (far + near -  exp_depth * (far - near)); 
}

//Helper function to automatically sample and unpack normals
vec3 sampleNrm(vec2 texcoords) {
    return texture(u_Normaltex,texcoords).xyz;
}

//Helper function to automicatlly sample and unpack positions
vec4 samplePos(vec2 texcoords) {
    vec4 pos = texture( u_Positiontex, texcoords );
    return pos;
}

//Helper function to automicatlly sample and unpack positions
vec4 sampleCol(vec2 texcoords) {
    return texture(u_Colortex,texcoords);
}

vec3 shade( vec4 light, vec3 lightColor, vec4 vertexColor, vec3 pos, vec3 N )
{
    vec3 L, H, V, R;
	float LdotN, blinnTerm;
	vec3 color;
	float decay = 1;

	N = normalize(N);
	L = light.w > 0 ? light.xyz - pos : light.xyz;
	L = normalize(L);
	V = normalize( -pos );
	H = normalize( L+V );
	
	LdotN = max( dot(L,N), 0 );
	blinnTerm = max( dot(N, H), 0 );
	blinnTerm = pow( blinnTerm, vertexColor.a );

	if( light.w > 0 )
	    decay = 1.0 / distance( light.xyz, pos ) / distance( light.xyz, pos );
	color = decay * ( vertexColor.rgb * LdotN + vec3(1,1,1)*blinnTerm );

	return color;
}

///////////////////////////////////
// MAIN
//////////////////////////////////
void main() {

    float exp_depth = texture(u_Depthtex, fs_Texcoord).r;
    float lin_depth = linearizeDepth(exp_depth,u_Near,u_Far);
	
    vec3 normal = sampleNrm(fs_Texcoord);
	vec4 color = sampleCol( fs_Texcoord );

    vec4 pos = samplePos(fs_Texcoord);

	float visibility = 1.0;
	vec4 posEyeSpace = u_modelview * pos;
	vec4 shadowCoord = u_lightMVP * pos;
	float depthBias =0;
	if( textureProj( u_shadowmap, shadowCoord.xyw ).z < ( shadowCoord.z - depthBias )/shadowCoord.w  )
	    visibility = 0.2;

    out_Color = visibility*vec4( shade( u_Light, u_LightColor, color, posEyeSpace.xyz/posEyeSpace.w, normal ), 0 ); 

	//float s_depth = texture( u_shadowmap, fs_Texcoord ).r;
	//out_Color = vec4( s_depth, s_depth, s_depth, 0 );
}


// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

uniform layout (location = passShader_u_InvTrans) mat4x4 u_InvTrans;
uniform layout (location = passShader_u_Color) vec3 u_Color;
uniform layout (location = passShader_u_shininess) float u_shininess;
uniform layout (location = passShader_u_bTextured) int u_bTextured;
uniform layout (location = passShader_u_bBump) int u_bBump;

uniform layout(binding = passShader_u_colorTex) sampler2D u_colorTex;
uniform layout(binding = passShader_u_bumpTex) sampler2D u_bumpTex;

layout (location = 0) in vec3 fs_Normal;
layout (location = 1) in vec4 fs_Position;
layout (location = 2) in vec2 fs_texcoord;
layout (location = 3) in vec4 NDCPos;

layout (location = 0) out vec4 out_Normal;
layout (location = 1) out vec4 out_Position;
layout (location = 2) out vec4 out_Color;

void main(void)
{
    //out_Normal = vec4(normalize(fs_Normal),0.0f);
	out_Normal = u_InvTrans* vec4( fs_Normal,0 );
	if( u_bBump == 1 )
	    out_Normal = u_InvTrans*vec4(texture( u_bumpTex, fs_texcoord ).rgb, 0 );
    out_Position = vec4(fs_Position.xyz,1.0f); //Tuck position into 0 1 range
    out_Color = vec4(u_Color, u_shininess );
	if( u_bTextured == 1 )
	    out_Color.rgb = texture( u_colorTex, fs_texcoord ).rgb;
}

// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

uniform layout (location = passShader_u_Model) mat4x4 u_Model;
uniform layout (location = passShader_u_View) mat4x4 u_View;
uniform layout (location = passShader_u_Persp) mat4x4 u_Persp;
uniform layout (location = passShader_u_InvTrans) mat4x4 u_InvTrans;

layout (location = 0) in vec3 Position;
layout (location = 1) in vec3 Normal;
layout (location = 2) in vec2 texcoord;

layout (location = 0) out vec3 fs_Normal;
layout (location = 1) out vec4 fs_Position;
layout (location = 2) out vec2 fs_texcoord;
layout (location = 3) out vec4 NDCPos;

void main(void) {
    fs_Normal = vec4(Normal,0.0f).xyz;
    vec4 world = u_Model * vec4(Position, 1.0);
    vec4 camera = u_View * world;
    fs_Position = vec4( Position, 1.0 );
	fs_texcoord = texcoord;
    gl_Position = u_Persp * camera;
	
	//Get position in NDC space, both this frame and the prvious frame
	NDCPos = gl_Position;
}
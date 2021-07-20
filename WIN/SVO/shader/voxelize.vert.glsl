// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

//Vertex shader for scene voxelization
//Using the method described in Ch. 22, OpenGL Insights

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"


layout (location = 0) in vec3 Position;
layout (location = 1) in vec3 Normal;
layout (location = 2) in vec2 texcoord;

layout (location = 0) out vec3 v_vertex;
layout (location = 1) out vec3 v_normal;
layout (location = 2) out vec2 v_texcoord;

void main()
{
    v_vertex = Position;
	v_normal = Normal;
	v_texcoord = texcoord;
    gl_Position = vec4( Position, 1 );
}
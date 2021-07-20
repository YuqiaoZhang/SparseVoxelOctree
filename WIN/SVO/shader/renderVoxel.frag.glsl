// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

layout (location = 0) in vec4 f_vertex;
layout (location = 1) in vec4 f_color;
layout (location = 2) in vec3 f_normal;

layout (location = 0) out vec4 out_color;

//uniform sampler3D u_voxel;

void main()
{
	out_color = f_color;
}
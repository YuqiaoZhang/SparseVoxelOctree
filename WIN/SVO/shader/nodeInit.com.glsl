// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin 
 
#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1 ) in;

uniform layout(location = nodeInitShader_u_allocStart) int u_allocStart;
uniform layout(location = nodeInitShader_u_num) int u_num;

uniform layout(binding = 0, r32ui ) coherent uimageBuffer u_octreeIdx;
uniform layout(binding = 1, r32ui ) coherent uimageBuffer u_octreeKd;

void main()
{
    uint offset;
    uint thxId = gl_GlobalInvocationID.y*1024 + gl_GlobalInvocationID.x;
	if( thxId >= u_num )
	    return;

	imageStore( u_octreeIdx, int( u_allocStart + thxId), uvec4(0,0,0,0) );
	imageStore( u_octreeKd, int( u_allocStart + thxId), uvec4(0,0,0,0) );
}
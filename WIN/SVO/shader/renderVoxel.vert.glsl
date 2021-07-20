// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

layout (location = 0) in vec4 glVertex;
layout (location = 1) in vec4 glColor;
layout (location = 2) in vec3 glNormal;

layout (location = 0) out vec3 v_normal;
layout (location = 1) out vec4 v_vertex;
layout (location = 2) out uvec3 v_texcoord;
layout (location = 3) out vec4 v_color;

uniform layout (location = renderVoxelShader_u_ModelView) mat4 u_ModelView;
uniform layout (location = renderVoxelShader_u_Proj) mat4 u_Proj;
uniform layout (location = renderVoxelShader_u_Normal) mat3 u_Normal;
uniform layout (location = renderVoxelShader_u_voxelDim) int u_voxelDim;

void main()
{
   
    //v_texcoord = glVertex.xyz/u_voxelDim;
	v_texcoord.x = gl_VertexID % u_voxelDim;
	v_texcoord.z = (gl_VertexID / u_voxelDim) % u_voxelDim;
	v_texcoord.y = gl_VertexID / (u_voxelDim*u_voxelDim);
	gl_Position = u_Proj * u_ModelView * vec4( v_texcoord, 1.0 );

	//v_texcoord.xyz /= u_voxelDim;
	//v_vertex = vec4( v_texcoord*2-1, 1.0 );
	v_vertex = vec4( v_texcoord/float(u_voxelDim)*2.0-1, 1.0 );
	v_vertex.z += 1.0/u_voxelDim;
	v_vertex.x -= 1.0/u_voxelDim;
	v_normal = u_Normal * glNormal;
	v_color = glColor; 
	
}
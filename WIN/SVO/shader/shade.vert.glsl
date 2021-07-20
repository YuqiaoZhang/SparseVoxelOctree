// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

layout (location = 0) in vec3 Position;
layout (location = 1) in vec2 Texcoord;

//uniform layout (location = deferredShader_u_Persp) mat4 u_Persp;

layout (location = 0) out vec2 fs_Texcoord;

void main() {
    fs_Texcoord = Texcoord;
    gl_Position = vec4(Position,1.0f);
}

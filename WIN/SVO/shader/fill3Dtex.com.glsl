// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

#define USE_SPARSE_OCTREE 1

#if USE_SPARSE_OCTREE == 1
layout (local_size_x = 8, local_size_y = 8, local_size_z = 8 ) in;
#else
layout (local_size_x = 64, local_size_y = 1, local_size_z = 1 ) in;
#endif

uniform layout(binding=0, r8 ) image3D u_voxelImage;
uniform layout(binding=1, r32ui ) uimageBuffer u_octreeBuf;
uniform layout(binding=2, rgb10_a2ui) uimageBuffer u_voxelPos;

uniform layout(location = octreeTo3DtexShader_u_octreeLevel) int u_octreeLevel;
uniform layout(location = octreeTo3DtexShader_u_voxelDim) int u_voxelDim;
uniform layout(location = octreeTo3DtexShader_u_numVoxelFrag) int u_numVoxelFrag;

#if USE_SPARSE_OCTREE == 1
void main()
{
    vec4 data = vec4( 1.0, 0.0, 0.0, 0.0 );
    uvec3 umin, umax;
    uvec3 loc = gl_GlobalInvocationID;
	uint idx = 0;
	int depth;
	int voxelDim = u_voxelDim;
	bool bOccupied = true;

	if( loc.x >= u_voxelDim || loc.y >= u_voxelDim || loc.z >= u_voxelDim )
	    return ;
	
	//decide max and min coord for the root node
	umin = uvec3(0,0,0);
	umax = uvec3( voxelDim, voxelDim, voxelDim );

    for( depth = 0; depth <= u_octreeLevel; ++depth )
    {
	    idx = imageLoad( u_octreeBuf, int(idx) ).r;
		if( (idx & 0x80000000) == 0 )
	    {
		    bOccupied= false;
		    break;
		}
		else if( depth == u_octreeLevel )
		    break;

		idx &= 0x7FFFFFFF;  //mask out flag bit to get child pointer
		if( idx == 0 )
		{
		    bOccupied = false;
		    break;
		}
		voxelDim /= 2;

	    if( (loc.x >= umin.x && loc.x < umin.x+voxelDim) &&
		    (loc.y >= umin.y && loc.y < umin.y+voxelDim) &&
			(loc.z >= umin.z && loc.z < umin.z+voxelDim) 
		  )
	    {
		    
		}
		else if(
            (loc.x >= umin.x+voxelDim && loc.x < umin.x + 2*voxelDim) &&
		    (loc.y >= umin.y && loc.y < umin.y+voxelDim) &&
			(loc.z >= umin.z && loc.z < umin.z+voxelDim)    
		)
		{
		    idx += 1;
		    umin.x += voxelDim;
	    }
		else if(
		    (loc.x >= umin.x && loc.x < umin.x+voxelDim) &&
		    (loc.y >= umin.y && loc.y < umin.y+voxelDim) &&
			(loc.z >= umin.z + voxelDim && loc.z < umin.z + 2*voxelDim) 
		)
		{
		    idx += 2;
			umin.z += voxelDim;
		}
		else if(
		    (loc.x >= umin.x + voxelDim && loc.x < umin.x + 2*voxelDim) &&
		    (loc.y >= umin.y && loc.y < umin.y+voxelDim) &&
			(loc.z >= umin.z + voxelDim && loc.z < umin.z + 2*voxelDim) 
		)
		{
		    idx += 3;
			umin.x += voxelDim;
			umin.z += voxelDim;
		}
		else if(
		    (loc.x >= umin.x && loc.x < umin.x + voxelDim) &&
		    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
			(loc.z >= umin.z && loc.z < umin.z + voxelDim) 
		)
		{
		    idx += 4;
			umin.y += voxelDim;
		
		}
		else if(
		    (loc.x >= umin.x + voxelDim && loc.x < umin.x + 2*voxelDim) &&
		    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
			(loc.z >= umin.z && loc.z < umin.z + voxelDim )
		)
		{
		    idx += 5;
			umin.x += voxelDim;
			umin.y += voxelDim;
		}
		else if(
		    (loc.x >= umin.x && loc.x < umin.x + voxelDim) &&
		    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
			(loc.z >= umin.z + voxelDim && loc.z < umin.z + voxelDim*2) 
		)
		{
		    idx += 6;
			umin.z += voxelDim;
			umin.y += voxelDim;
		}
		else if(
		    (loc.x >= umin.x + voxelDim && loc.x < umin.x + 2* voxelDim) &&
		    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
			(loc.z >= umin.z + voxelDim && loc.z < umin.z + voxelDim*2 )
		)
	    {
		    idx += 7;
			umin += voxelDim;
		}
		else 
		{
		    bOccupied = false;
		    break;
	    }	
	} 
	if( bOccupied )
	    imageStore( u_voxelImage, ivec3(loc.xyz) , data );
	else
	    imageStore( u_voxelImage, ivec3(loc.xyz) , vec4(0,0,0,0) );
}
#else
void main()
{
    uint thxIdx = gl_GlobalInvocationID.x;
	if( thxIdx >= u_numVoxelFrag )
	    return;

    uvec4 texcoord = imageLoad( u_voxelPos, int(thxIdx) );

	imageStore( u_voxelImage, ivec3(texcoord.xyz), vec4(1,0,0,0) );
}
#endif
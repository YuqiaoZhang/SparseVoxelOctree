// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#version 460 core

#extension GL_GOOGLE_include_directive : require

#include "./shader_uniform_location.h"

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1 ) in;

uniform layout(location = nodeFlagShader_u_numVoxelFrag) int u_numVoxelFrag;
uniform layout(location = nodeFlagShader_u_level) int u_level;
uniform layout(location = nodeFlagShader_u_voxelDim) int u_voxelDim;

uniform layout(binding = 0, rgb10_a2ui ) uimageBuffer u_voxelPos;
uniform layout(binding = 1, r32ui ) uimageBuffer u_octreeBuf;

void main()
{
    uint thxId = gl_GlobalInvocationID.y*1024 + gl_GlobalInvocationID.x;
	if( thxId >= u_numVoxelFrag )
	    return;

    uvec3 umin, umax;
    uvec4 loc;
	int childIdx = 0;
	uint node, subnode;
	uint voxelDim = u_voxelDim;
	bool bFlag = true;
	 
	//Get the voxel coordinate of voxel loaded by this thread
	loc = imageLoad( u_voxelPos, int(thxId) );

	//decide max and min coord for the root node
	umin = uvec3(0,0,0);
	umax = uvec3( voxelDim, voxelDim, voxelDim );

	
	node = imageLoad( u_octreeBuf, childIdx ).r;

    for( int i = 0; i < u_level; ++i )
    {
	    voxelDim /= 2;
		if( (node & 0x80000000 ) == 0 ) 
		{
		    bFlag = false;
		    break;
		}
		childIdx = int(node & 0x7FFFFFFF);  //mask out flag bit to get child idx

	 //   if( ( loc.x >= umin.x && loc.x < umin.x+voxelDim ) &&
		//    ( loc.y >= umin.y && loc.y < umin.y+voxelDim ) &&
		//	( loc.z >= umin.z && loc.z < umin.z+voxelDim )
		//  )
	 //   {
		    
		//}
		//else if(
  //          (loc.x >= umin.x+voxelDim && loc.x < umin.x + 2*voxelDim) &&
		//    (loc.y >= umin.y && loc.y < umin.y+voxelDim) &&
		//	(loc.z >= umin.z && loc.z < umin.z+voxelDim )  
		//)
		//{
		//    childIdx += 1;
		//    umin.x = umin.x+voxelDim;
	 //   }
		//else if(
		//    (loc.x >= umin.x && loc.x < umin.x+voxelDim) &&
		//    (loc.y >= umin.y && loc.y < umin.y+voxelDim) &&
		//	(loc.z >= umin.z + voxelDim && loc.z < umin.z + 2*voxelDim )
		//)
		//{
		//    childIdx += 2;
		//	umin.z += voxelDim;
		//}
		//else if(
		//    (loc.x >= umin.x + voxelDim && loc.x < umin.x + 2*voxelDim) &&
		//    (loc.y >= umin.y && loc.y < umin.y+voxelDim) &&
		//	(loc.z >= umin.z + voxelDim && loc.z < umin.z + 2*voxelDim) 
		//)
		//{
		//    childIdx += 3;
		//	umin.x += voxelDim;
		//	umin.z += voxelDim;
		//}
		//else if(
		//    (loc.x >= umin.x && loc.x < umin.x + voxelDim) &&
		//    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
		//	(loc.z >= umin.z && loc.z < umin.z + voxelDim )
		//)
		//{
		//    childIdx += 4;
		//	umin.y += voxelDim;
		
		//}
		//else if(
		//    (loc.x >= umin.x + voxelDim && loc.x < umin.x + 2*voxelDim) &&
		//    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
		//	(loc.z >= umin.z && loc.z < umin.z + voxelDim) 
		//)
		//{
		//    childIdx += 5;
		//	umin.x += voxelDim;
		//	umin.y += voxelDim;
		//}
		//else if(
		//    (loc.x >= umin.x && loc.x < umin.x + voxelDim) &&
		//    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
		//	(loc.z >= umin.z + voxelDim && loc.z < umin.z + voxelDim*2) 
		//)
		//{
		//    childIdx += 6;
		//	umin.z += voxelDim;
		//	umin.y += voxelDim;
		//}
		//else if(
		//    (loc.x >= umin.x + voxelDim && loc.x < umin.x + 2*voxelDim) &&
		//    (loc.y >= umin.y + voxelDim && loc.y < umin.y + 2*voxelDim) &&
		//	(loc.z >= umin.z + voxelDim && loc.z < umin.z + voxelDim*2) 
		//)
	 //   {
		//    childIdx += 7;
		//	umin += voxelDim;
		//}
		//else
		//{
		//    bFlag = false;
		//	break;
		//}
	    subnode = clamp( int(1 + loc.x - umin.x - voxelDim), 0, 1 );
	    subnode += 4 * clamp( int(1 + loc.y - umin.y- voxelDim), 0, 1 );
	    subnode += 2 * clamp( int(1 + loc.z - umin.z- voxelDim), 0, 1 );
	    childIdx += int(subnode);
	
	    umin.x += voxelDim * clamp( int(1 + loc.x - umin.x - voxelDim), 0, 1 );
	    umin.y += voxelDim * clamp( int(1 + loc.y - umin.y- voxelDim),  0, 1 );
	    umin.z += voxelDim * clamp( int(1 + loc.z - umin.z- voxelDim),  0, 1 );

		node = imageLoad( u_octreeBuf, childIdx ).r;
	}
	if( bFlag )
    {
	    node |= 0x80000000; //set the most significant bit
	    imageStore( u_octreeBuf, childIdx, uvec4(node,0,0,0) );
    }
}
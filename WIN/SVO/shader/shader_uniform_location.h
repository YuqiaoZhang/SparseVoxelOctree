#ifndef _SHADER_UNIFORM_LOCATION_H_
#define _SHADER_UNIFORM_LOCATION_H_ 1

#define passShader_u_Model 0
#define passShader_u_View 1
#define passShader_u_Persp 2
#define passShader_u_InvTrans 3
#define passShader_u_Color 4
#define passShader_u_shininess 5
#define passShader_u_bTextured 6
#define passShader_u_bBump 7
#define passShader_u_colorTex 0
#define passShader_u_bumpTex 1

#define deferredShader_u_lightMVP 0
//#define deferredShader_u_persp 1
#define deferredShader_u_modelview 2
//#define deferredShader_u_ScreenHeight 3
//#define deferredShader_u_ScreenWidth 4
#define deferredShader_u_Far 5
#define deferredShader_u_Near 6
//#define deferredShader_u_Persp 7
//#define deferredShader_u_DisplayType 8
#define deferredShader_u_Light 9
#define deferredShader_u_LightColor 10
//#define deferredShader_u_eyePos 11
#define deferredShader_zerothresh 12
#define deferredShader_falloff 13
#define deferredShader_u_Depthtex 0
#define deferredShader_u_Normaltex 1
#define deferredShader_u_Positiontex 2
#define deferredShader_u_Colortex 3
#define deferredShader_u_shadowmap 4

#define shadowmapShaderu_mvp 0

#define leafStoreShader_u_numVoxelFrag 0
#define leafStoreShader_u_octreeLevel 1
#define leafStoreShader_u_voxelDim 2

#define nodeInitShader_u_num 0
#define nodeInitShader_u_allocStart 1

#define nodeAllocShader_u_num 0
#define nodeAllocShader_u_start 1
#define nodeAllocShader_u_allocStart 2

#define nodeFlagShader_u_numVoxelFrag 0
#define nodeFlagShader_u_level 1
#define nodeFlagShader_u_voxelDim 2

#define octreeTo3DtexShader_u_octreeLevel 0
#define octreeTo3DtexShader_u_voxelDim 1
#define octreeTo3DtexShader_u_numVoxelFrag 2

#define voxelizeShader_u_MVPx 0
#define voxelizeShader_u_MVPy 1
#define voxelizeShader_u_MVPz 2
#define voxelizeShader_u_width 3
#define voxelizeShader_u_height 4
#define voxelizeShader_u_bStore 5
#define voxelizeShader_u_voxelPos 6
#define voxelizeShader_u_Color 7
#define voxelizeShader_u_bTextured 8
#define voxelizeShader_u_bBump 9
#define voxelizeShader_u_colorTex 4
#define voxelizeShader_u_bumpTex 5

#define renderVoxelShader_u_ModelView 0
#define renderVoxelShader_u_Proj 1
#define renderVoxelShader_u_Normal 2
#define renderVoxelShader_u_voxelDim 3
#define renderVoxelShader_u_halfDim 4
#define renderVoxelShader_u_octreeLevel 5

#endif
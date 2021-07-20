all: spv_shader/pass.vert.spv spv_shader/pass.frag.spv \
	spv_shader/shade.vert.spv spv_shader/diagnostic.frag.spv \
	spv_shader/shadowmap.vert.spv spv_shader/shadowmap.frag.spv \
	spv_shader/leafStore.com.spv \
	spv_shader/nodeInit.com.spv \
	spv_shader/nodeFlag.com.spv \
	spv_shader/nodeAlloc.com.spv \
	spv_shader/fill3Dtex.com.spv \
	spv_shader/voxelize.vert.spv spv_shader/voxelize.geom.spv spv_shader/voxelize.frag.spv \
	spv_shader/renderVoxel.vert.spv spv_shader/renderVoxel.geom.spv spv_shader/renderVoxel.frag.spv

spv_shader/pass.vert.spv : shader/pass.vert.glsl shader/shader_uniform_location.h
	glslangValidator -G -S vert shader/pass.vert.glsl -o spv_shader/pass.vert.spv

spv_shader/pass.frag.spv : shader/pass.frag.glsl shader/shader_uniform_location.h
	glslangValidator -G -S frag shader/pass.frag.glsl -o spv_shader/pass.frag.spv

spv_shader/shade.vert.spv : shader/shade.vert.glsl shader/shader_uniform_location.h
	glslangValidator -G -S vert shader/shade.vert.glsl -o spv_shader/shade.vert.spv

spv_shader/diagnostic.frag.spv : shader/diagnostic.frag.glsl shader/shader_uniform_location.h
	glslangValidator -G -S frag shader/diagnostic.frag.glsl -o spv_shader/diagnostic.frag.spv

spv_shader/shadowmap.vert.spv : shader/shadowmap.vert.glsl shader/shader_uniform_location.h
	glslangValidator -G -S vert shader/shadowmap.vert.glsl -o spv_shader/shadowmap.vert.spv

spv_shader/shadowmap.frag.spv : shader/shadowmap.frag.glsl shader/shader_uniform_location.h
	glslangValidator -G -S frag shader/shadowmap.frag.glsl -o spv_shader/shadowmap.frag.spv

spv_shader/leafStore.com.spv : shader/leafStore.com.glsl shader/shader_uniform_location.h
	glslangValidator -G -S comp shader/leafStore.com.glsl -o spv_shader/leafStore.com.spv

spv_shader/nodeInit.com.spv : shader/nodeInit.com.glsl shader/shader_uniform_location.h
	glslangValidator -G -S comp shader/nodeInit.com.glsl -o spv_shader/nodeInit.com.spv

spv_shader/nodeFlag.com.spv : shader/nodeFlag.com.glsl shader/shader_uniform_location.h
	glslangValidator -G -S comp shader/nodeFlag.com.glsl -o spv_shader/nodeFlag.com.spv

spv_shader/nodeAlloc.com.spv : shader/nodeAlloc.com.glsl shader/shader_uniform_location.h
	glslangValidator -G -S comp shader/nodeAlloc.com.glsl -o spv_shader/nodeAlloc.com.spv

spv_shader/fill3Dtex.com.spv : shader/fill3Dtex.com.glsl shader/shader_uniform_location.h
	glslangValidator -G -S comp shader/fill3Dtex.com.glsl -o spv_shader/fill3Dtex.com.spv

spv_shader/voxelize.vert.spv : shader/voxelize.vert.glsl shader/shader_uniform_location.h
	glslangValidator -G -S vert shader/voxelize.vert.glsl -o spv_shader/voxelize.vert.spv

spv_shader/voxelize.geom.spv : shader/voxelize.geom.glsl shader/shader_uniform_location.h
	glslangValidator -G -S geom shader/voxelize.geom.glsl -o spv_shader/voxelize.geom.spv

spv_shader/voxelize.frag.spv : shader/voxelize.frag.glsl shader/shader_uniform_location.h
	glslangValidator -G -S frag shader/voxelize.frag.glsl -o spv_shader/voxelize.frag.spv

spv_shader/renderVoxel.vert.spv : shader/renderVoxel.vert.glsl shader/shader_uniform_location.h
	glslangValidator -G -S vert shader/renderVoxel.vert.glsl -o spv_shader/renderVoxel.vert.spv

spv_shader/renderVoxel.geom.spv : shader/renderVoxel.geom.glsl shader/shader_uniform_location.h
	glslangValidator -G -S geom shader/renderVoxel.geom.glsl -o spv_shader/renderVoxel.geom.spv

spv_shader/renderVoxel.frag.spv : shader/renderVoxel.frag.glsl shader/shader_uniform_location.h
	glslangValidator -G -S frag shader/renderVoxel.frag.glsl -o spv_shader/renderVoxel.frag.spv
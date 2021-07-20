// GLSL Utility: A utility class for loading GLSL shaders, for Patrick Cozzi's CIS565: GPU Computing at the University of Pennsylvania
// Written by Varun Sampath and Patrick Cozzi, Copyright (c) 2012 University of Pennsylvania
// Modified by Cheng-Tso Lin to accommodate geometry shader and compute shader creation

#ifndef GLSLUTILITY_H_
#define GLSLUTILITY_H_

#include <cstdlib>

#define GL_GLEXT_PROTOTYPES 1
#include <GL/glcorearb.h>

namespace glslUtility
{


	typedef struct {
		GLuint vertex;
		GLuint fragment;
        GLuint geometry;
        GLuint compute;
	} shaders_t;

shaders_t load_spv_shaders(const char *vert_path, const char *frag_path, const char *geom_path, const char *compute_path = NULL );

shaders_t loadShaders(const char * vert_path, const char * frag_path, const char * geom_path = NULL, const char * compute_path = NULL );

void attachAndLinkProgram( GLuint program, shaders_t shaders);

char* loadFile(const char *fname, GLint &fSize);

// printShaderInfoLog
// From OpenGL Shading Language 3rd Edition, p215-216
// Display (hopefully) useful error messages if shader fails to compile
void printShaderInfoLog(GLint shader);

void printLinkInfoLog(GLint prog) ;

GLenum get_texture_binding_id(int i);

}
 
#endif

// GLSL Utility: A utility class for loading GLSL shaders, for Patrick Cozzi's CIS565: GPU Computing at the University of Pennsylvania
// Written by Varun Sampath and Patrick Cozzi, Copyright (c) 2012 University of Pennsylvania
// Modified by Cheng-Tso Lin to accommodate geometry shader and compute shader creation

#include "glslUtility.h"

#define GL_GLEXT_PROTOTYPES 1
#include <GL/glcorearb.h>
#include <GL/glx.h>

#include <iostream>
#include <fstream>
#include <string>
#include <assert.h>

using namespace std;

namespace glslUtility {

	char* loadFile(const char *fname, GLint &fSize)
	{
		ifstream::pos_type size;
		char * memblock;
		std::string text;

		// file read based on example in cplusplus.com tutorial
		ifstream file (fname, ios::in|ios::binary|ios::ate);
		if (file.is_open())
		{
			size = file.tellg();
			fSize = (GLuint) size;
			memblock = new char [size];
			file.seekg (0, ios::beg);
			file.read (memblock, size);
			file.close();
			printf("%s %s %s \n", "file", fname, "loaded");
			text.assign(memblock);
		}
		else
		{
			printf("%s %s \n", "Unable to open file", fname);
			exit(1);
		}
		return memblock;
	}

	// printShaderInfoLog
	// From OpenGL Shading Language 3rd Edition, p215-216
	// Display (hopefully) useful error messages if shader fails to compile
	void printShaderInfoLog(GLint shader)
	{
		int infoLogLen = 0;
		int charsWritten = 0;
		GLchar *infoLog;

		glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLen);

		// should additionally check for OpenGL errors here

		if (infoLogLen > 0)
		{
			infoLog = new GLchar[infoLogLen];
			// error check for fail to allocate memory omitted
			glGetShaderInfoLog(shader,infoLogLen, &charsWritten, infoLog);
			printf("%s \n %s \n", "InfoLog:", infoLog);
			delete[] infoLog;
		}

		// should additionally check for OpenGL errors here
	}

	void printLinkInfoLog(GLint prog) 
	{
		int infoLogLen = 0;
		int charsWritten = 0;
		GLchar *infoLog;

		glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &infoLogLen);

		// should additionally check for OpenGL errors here

		if (infoLogLen > 0)
		{
			infoLog = new GLchar[infoLogLen];
			// error check for fail to allocate memory omitted
			glGetProgramInfoLog(prog,infoLogLen, &charsWritten, infoLog);
			printf("%s \n %s \n", "InfoLog:", infoLog);
			delete [] infoLog;
		}
	}

	GLuint init_spv_shaders(GLenum type, const char *filename)
	{
		static PFNGLSPECIALIZESHADERPROC pfn_glSpecializeShader = NULL;

		if (NULL == pfn_glSpecializeShader)
		{
			pfn_glSpecializeShader = (PFNGLSPECIALIZESHADERPROC)glXGetProcAddress((GLubyte const*)"glSpecializeShader");
		}
		assert(NULL != pfn_glSpecializeShader);

		GLuint shader = glCreateShader(type);
		GLint compiled;
		char *ss;
		GLint slen;

		ss = loadFile(filename, slen);
		const char *cs = ss;

		glShaderBinary(1, &shader, GL_SHADER_BINARY_FORMAT_SPIR_V, cs, slen);
		pfn_glSpecializeShader(shader, "main", 0, NULL, NULL);
		glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
		if (GL_TRUE != compiled)
		{
			printf("Shader not compiled. \n");
			printShaderInfoLog(shader);
		}
		delete[] ss;

		return shader;
	}

	shaders_t load_spv_shaders(const char *vert_path, const char *frag_path, const char *geom_path, const char *compute_path)
	{
		GLuint f = 0, v = 0, g = 0, c = 0;

		if (vert_path)
			v = init_spv_shaders(GL_VERTEX_SHADER, vert_path);
		if (frag_path)
			f = init_spv_shaders(GL_FRAGMENT_SHADER, frag_path);
		if (geom_path)
			g = init_spv_shaders(GL_GEOMETRY_SHADER, geom_path);
		if (compute_path)
			c = init_spv_shaders(GL_COMPUTE_SHADER, compute_path);

		shaders_t out;
		out.vertex = v;
		out.fragment = f;
		out.geometry = g;
		out.compute = c;

		return out;
	}

	void attachAndLinkProgram( GLuint program, shaders_t shaders) 
    {
        if( shaders.vertex )
            glAttachShader(program, shaders.vertex);
        if( shaders.fragment )
		    glAttachShader(program, shaders.fragment);
        if( shaders.geometry )
            glAttachShader(program, shaders.geometry  );
        if( shaders.compute)
            glAttachShader(program, shaders.compute  );
		glLinkProgram(program);
		GLint linked;
		glGetProgramiv(program,GL_LINK_STATUS, &linked);
		if (!linked) 
		{
			printf("Program did not link. \n");
			printLinkInfoLog(program);
		}
	}

	GLenum get_texture_binding_id(int binding_id)
	{
		static GLenum texture_binding_id[] = {
			GL_TEXTURE0,
			GL_TEXTURE1,
			GL_TEXTURE2,
			GL_TEXTURE3,
			GL_TEXTURE4,
			GL_TEXTURE5,
			GL_TEXTURE6,
			GL_TEXTURE7,
			GL_TEXTURE8,
			GL_TEXTURE9,
			GL_TEXTURE10,
			GL_TEXTURE11,
			GL_TEXTURE12,
			GL_TEXTURE13,
			GL_TEXTURE14,
			GL_TEXTURE15,
			GL_TEXTURE16,
			GL_TEXTURE17,
			GL_TEXTURE18,
			GL_TEXTURE19,
			GL_TEXTURE20,
			GL_TEXTURE21,
			GL_TEXTURE22,
			GL_TEXTURE23,
			GL_TEXTURE24,
			GL_TEXTURE25,
			GL_TEXTURE26,
			GL_TEXTURE27,
			GL_TEXTURE28,
			GL_TEXTURE29,
			GL_TEXTURE30,
			GL_TEXTURE31};

		assert(binding_id < (sizeof(texture_binding_id)/sizeof(texture_binding_id[0])));
		return texture_binding_id[binding_id];
	}
}
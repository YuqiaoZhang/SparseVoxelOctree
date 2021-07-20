// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#define GL_GLEXT_PROTOTYPES 1
#include <GL/glcorearb.h>

#include <assert.h>

#include "shader.h"
#include "glslUtility.h"

using namespace glslUtility;

namespace shader
{

ShaderProgram::ShaderProgram()
{
    program = 0;
    vs = 0;
    fs = 0;
    gs = 0;
}

ShaderProgram::~ShaderProgram()
{
    if( program )
    glDeleteProgram( program );
    if(vs )
    glDeleteShader( vs );
    if( fs )
    glDeleteShader( fs );
    if( gs )
    glDeleteShader( gs );
}

int ShaderProgram::init_spv(const char *vs_source, const char *fs_source, const char *gs_source)
{
    //load shader sources and compile
    shaders_t shaderSet = load_spv_shaders( vs_source, fs_source, gs_source );
    vs = shaderSet.vertex;
    fs = shaderSet.fragment;
    gs = shaderSet.geometry;
   
    //create program
    program = glCreateProgram();

    //attach shader 
    attachAndLinkProgram( program, shaderSet );

    return 0;
}

void ShaderProgram::use()
{
    glUseProgram( program );
}
void ShaderProgram::unuse()
{
    glUseProgram( 0 );
}

void ShaderProgram::set_parameter(shaderAttrib type, void *param, GLint loc)
{
    switch (type)
    {
    case i1:
        glUniform1i(loc, *((int *)param));
        break;
    case f1:
        glUniform1f(loc, *((float *)param));
        break;
    case fv3:
        glUniform3fv(loc, 1, (float *)param);
        break;
    case fv4:
        glUniform4fv(loc, 1, (float *)param);
        break;
    case mat4x4:
        glUniformMatrix4fv(loc, 1, GL_FALSE, (float *)param);
        break;
    case mat3x3:
        glUniformMatrix3fv(loc, 1, GL_FALSE, (float *)param);
        break;
    case img:
        glUniform1i(loc, *((int *)param));
        break;
    }
}

void ShaderProgram::bindAttribLocation( unsigned int idx, char const* name )
{
    glBindAttribLocation( program, idx, name );
}

void ShaderProgram::bindFragDataLocation( unsigned int idx, char const* name )
{
    glBindFragDataLocation( program, idx, name );
}

ComputeShader::ComputeShader()
{  
}

ComputeShader::~ComputeShader()
{
}

int ComputeShader::init_spv( const char* cs_source )
{
    //load shader sources and compile
    shaders_t shaderSet = load_spv_shaders( NULL, NULL, NULL, cs_source );
   
    //create program
    program = glCreateProgram();

    //attach shader 
    attachAndLinkProgram( program, shaderSet );

    return 0;
}

}
/*
 SyphonServerPlugin.cpp
 Syphon Server
 
 Copyright 2011 bangnoise (Tom Butterworth) & vade (Anton Marini).
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "SyphonServerPlugin.h"

VDJ_EXPORT HRESULT __stdcall DllGetClassObject(const GUID &rclsid,const GUID &riid,void** ppObject)
{ 
    // TODO: Is this good?
    if(memcmp(&rclsid,&CLSID_VdjPlugin6,sizeof(GUID))!=0) return CLASS_E_CLASSNOTAVAILABLE; 
    if(memcmp(&riid,&IID_IVdjPluginVideoFx,sizeof(GUID))!=0) return CLASS_E_CLASSNOTAVAILABLE; 
    *ppObject = new SyphonServerPlugin(); 
    return NO_ERROR; 
}

SyphonServerPlugin::SyphonServerPlugin()
{
    _server = nil;
    _monitor = 1;
}

SyphonServerPlugin::~SyphonServerPlugin()
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [_server stop];
    [_server release];
    _server = nil;
    [pool drain];
}

HRESULT __stdcall SyphonServerPlugin::OnLoad()
{
    DeclareParameter(&_monitor, VDJPARAM_SWITCH, 1, (char *)"Monitor", 1);
    return NO_ERROR;
}

HRESULT __stdcall SyphonServerPlugin::OnGetPluginInfo(TVdjPluginInfo *infos)
{
    infos->Author = (char *)"bangnoise";
    infos->PluginName = (char *)"Syphon Server";
    infos->Description = (char *)"Syphon output. http://syphon.v002.info/";
    infos->Bitmap = NULL;
    infos->Flag = 0;
    return NO_ERROR;
}

HRESULT __stdcall SyphonServerPlugin::OnDXClose()
{
    // The GL context may have changed, so stop and release the server
    // so it is rebuilt next draw
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [_server stop];
    [_server release];
    _server = nil;
    [pool drain];
    return NO_ERROR;
}

HRESULT __stdcall SyphonServerPlugin::OnStop()
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [_server stop];
    [_server release];
    _server = nil;
    [pool drain];
    return NO_ERROR;
}

// use this function to render the GL surface on the device, using any modification you want
// return S_OK if you actually draw the texture on the device, or S_FALSE to let VirtualDJ do it
// texture is a GL_TEXTURE_RECTANGLE_EXT
// if using VDJPLUGINFLAG_VIDEOINPLACE, texture and vertices will be NULL
HRESULT __stdcall SyphonServerPlugin::OnDraw(DWORD texture,TVertex *vertices)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (_server == nil)
    {
        CGLContextObj cgl_ctx;
        GLboolean result = aglGetCGLContext(Context, (void **)&cgl_ctx);
        if (result == true)
        {
            _server = [[SyphonServer alloc] initWithName:nil context:cgl_ctx options:nil];
        }
    }
    /*
    //
    // If we wanted to draw the texture ourself, here's the code to do it
    // 
    
    glPushAttrib(GL_ALL_ATTRIB_BITS);
    glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
    
    glEnable(GL_TEXTURE_RECTANGLE_EXT);
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, texture);
    
    glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);				
    glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    
    glColor4f(1.0, 1.0, 1.0, 1.0);
    
    GLfloat tex_coords[] =
    {
        vertices[0].tu, vertices[0].tv,
        vertices[1].tu, vertices[1].tv,
        vertices[2].tu, vertices[2].tv,
        vertices[3].tu, vertices[3].tv
    };
    
    GLfloat verts[] =
    {
        vertices[0].position.x, vertices[0].position.y,
        vertices[1].position.x, vertices[1].position.y,
        vertices[2].position.x, vertices[2].position.y,
        vertices[3].position.x, vertices[3].position.y,
    };
    
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, verts );
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glPopClientAttrib();
    glPopAttrib();
    
    */
    
    [_server publishFrameTexture:texture
                   textureTarget:GL_TEXTURE_RECTANGLE_EXT
                     imageRegion:(NSRect){{0.0, 0.0}, {ImageWidth, ImageHeight}}
               textureDimensions:(NSSize){ImageWidth, ImageHeight}
                         flipped:NO];
    
    [pool drain];
    
    if (_monitor)
    {
        return S_FALSE;
    }
    else
    {
        return S_OK;
    }
}

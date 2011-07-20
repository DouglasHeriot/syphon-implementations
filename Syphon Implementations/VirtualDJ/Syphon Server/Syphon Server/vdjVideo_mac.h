//////////////////////////////////////////////////////////////////////////
//
// VirtualDJ / Cue
// Plugin SDK for MAC
// (c)Atomix Productions 2006
//
//////////////////////////////////////////////////////////////////////////
//
// This file defines the video plugins (both Fx and Transition).
// In addition to all the elements supported from the base IVdjPlugin class,
// it defines additional video-specific functions and variables:
//
//////////////////////////////////////////////////////////////////////////


#ifndef VdjVideoH
#define VdjVideoH

#include "vdjPlugin.h"
#include <AGL/agl.h>

//////////////////////////////////////////////////////////////////////////
// OpenGL data types

struct TVertex
{
	struct {float x,y,z;} position;
	DWORD color;
	float tu,tv;
};

//////////////////////////////////////////////////////////////////////////
// VideoFx plugin class

class IVdjPluginVideoFx : public IVdjPlugin
{
public:
	// called when openGL is initialized and closed, or when the size changes
	// if you need to allocate private surfaces or textures,
	// this is the place to do it
	virtual HRESULT __stdcall OnDXInit() {return 0;}
	virtual HRESULT __stdcall OnDXClose() {return 0;}

	// called on start and stop of the plugin
	virtual HRESULT __stdcall OnStart() {return 0;}
	virtual HRESULT __stdcall OnStop() {return 0;}

	// use this function to render the GL surface on the device, using any modification you want
	// return S_OK if you actually draw the texture on the device, or S_FALSE to let VirtualDJ do it
	// texture is a GL_TEXTURE_RECTANGLE_EXT
	// if using VDJPLUGINFLAG_VIDEOINPLACE, texture and vertices will be NULL
	virtual HRESULT __stdcall OnDraw(DWORD texture,TVertex *vertices)=0;

	// variables you can use (once DX has been initialized)
	AGLContext Context;
	int ImageWidth,ImageHeight;
};

//////////////////////////////////////////////////////////////////////////
// VideoTransition plugin class

class IVdjPluginVideoTransition : public IVdjPlugin
{
public:
	// called when OpenGL is initialized and closed, or when the size changes
	// if you need to allocate private surfaces or textures,
	// this is the place to do it
	virtual HRESULT __stdcall OnDXInit() {return 0;}
	virtual HRESULT __stdcall OnDXClose() {return 0;}

	// use this function to compose both surfaces on the device.
	// calling the RenderSurface[x] function will render the image on the actual render target,
	// using the vertices[x] given.
	virtual HRESULT __stdcall Compose(int crossfader,HRESULT(*RenderSurface[2])(),TVertex *vertices[2])=0;

	// OnStart() and OnStop() are called if the user activate the auto-transition.
	// once activated, OnCrossfaderTimer() will be called every frame to let you change
	// the value of the video crossfader before rendering.
	// return S_FALSE will stop the auto-transition (OnStop() will not be called).
	// return E_NOTIMPL will use the default auto-transition.
	// NOTE: if crossfader is set to 0 or 4096, the Compose() function will not be called.
	virtual HRESULT __stdcall OnStart(int chan) {return 0;}
	virtual HRESULT __stdcall OnStop() {return 0;}
	virtual HRESULT __stdcall OnCrossfaderTimer(int *crossfader) {return E_NOTIMPL;}

	// variables you can use (once AGL has been initialized)
	AGLContext Context;
	int ImageWidth,ImageHeight;
};

//////////////////////////////////////////////////////////////////////////
// flags used in OnGetPluginInfo()
#define VDJPLUGINFLAG_VIDEOINPLACE		0x20	// tell VirtualDJ not to send textures in OnDraw() but instead use directly the backbuffer

//////////////////////////////////////////////////////////////////////////
// GUID definitions

#ifndef VDJVIDEOGUID_DEFINED
#define VDJVIDEOGUID_DEFINED
static const GUID IID_IVdjPluginVideoFx = { 0x9ad1e934, 0x31ce, 0x4be8, { 0xb3, 0xee, 0x1e, 0x1f, 0x1c, 0x94, 0x55, 0x10 } };
static const GUID IID_IVdjPluginVideoTransition = { 0x119f6f6a, 0x1a37, 0x4fe5, { 0x96, 0x53, 0x31, 0x20, 0x3a, 0xc9, 0x4e, 0x28 } };
#else
extern static const GUID IID_IVdjPluginVideoFx;
extern static const GUID IID_IVdjPluginVideoTransition;
#endif

//////////////////////////////////////////////////////////////////////////
	
#endif
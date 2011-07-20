//////////////////////////////////////////////////////////////////////////
//
// VirtualDJ
// Plugin SDK
// (c)Atomix Productions 2009
//
// Modifications by Tom Butterworth (bangnoise) July 2011 for Syphon
//
//////////////////////////////////////////////////////////////////////////
//
// This file defines the basic functions that are used in all plugins.
// It defines the functions and variables needed to:
// - load and unload a plugin
// - give the infos about the plugin (name, picture, etc)
// - get the parameters automatically saved and restored between loads
// - interact with VirtualDJ (ask queries or send commands)
// - implement a custom interface
//
// Other functions specific to particular types of plugin can be found
// in their respective header file
//
//////////////////////////////////////////////////////////////////////////


#ifndef VdjPluginH
#define VdjPluginH

//////////////////////////////////////////////////////////////////////////
// Platform specific defines for compatibility Mac/Windows
#if (defined(WIN32) || defined(_WIN32) || defined(__WIN32_))
#include <windows.h>
#define VDJ_EXPORT		__declspec( dllexport )
#define VDJ_BITMAP		HBITMAP
#define VDJ_HINSTANCE	HINSTANCE
#elif (defined(__APPLE__) || defined(MACOSX) || defined(__MACOSX__))
#define VDJ_EXPORT		__attribute__ ((visibility ("default")))
#define VDJ_BITMAP		char *
#define VDJ_HINSTANCE	CFBundleRef
#define S_OK               ((HRESULT)0x00000000L)
#define S_FALSE            ((HRESULT)0x00000001L)
#define E_NOTIMPL          ((HRESULT)0x80004001L)
#define __stdcall
#define CLASS_E_CLASSNOTAVAILABLE -1
#define NO_ERROR 0
typedef long HRESULT;
typedef unsigned long ULONG;
typedef unsigned long DWORD;
typedef unsigned short WORD; // Added (bangnoise)
typedef char BYTE; // Added (bangnoise)
typedef void* HWND;
typedef struct _GUID {
    DWORD Data1;
    WORD  Data2;
    WORD  Data3;
    BYTE  Data4[8];
} GUID; // Added (bangnoise)
#endif


//////////////////////////////////////////////////////////////////////////
// Standard structures and defines

// structure used in plugin identification
struct TVdjPluginInfo
{
	char *PluginName;
	char *Author;
	char *Description;
	VDJ_BITMAP Bitmap;
	DWORD Flag;
};

// structure used to send queries to virtualdj
struct TVdjQueryResult
{
	// type of the result. Can be one of:
	// 0: no result
	// 'bool': boolean value (stored in vint)
	// 'val': float value (stored in vfloat, usually between 0.0f and 1.0f)
	// 'int': integer value (stored in vint)
	// 'txt': utf-8 text (stored in string)
	DWORD type;
	// value of the parameter (depends on the type, see above).
	union
	{
		int vint;
		float vfloat;
		char *string;
		DWORD flag;
	};
};

// flags used for plugin's parameters
#define VDJPARAM_BUTTON	0
#define VDJPARAM_SLIDER	1
#define VDJPARAM_SWITCH	2
#define VDJPARAM_STRING	3
#define VDJPARAM_CUSTOM	4
#define VDJPARAM_RADIO	5


//////////////////////////////////////////////////////////////////////////
// Base class

class IVdjPlugin
{
public:
	// Initialization
	virtual HRESULT __stdcall OnLoad() {return 0;}
	virtual HRESULT __stdcall OnGetPluginInfo(TVdjPluginInfo *infos) {return E_NOTIMPL;}
	virtual ULONG __stdcall Release() {delete this;return 0;}
	virtual ~IVdjPlugin() {}

	// callback functions to communicate with VirtualDJ
	HRESULT (__stdcall *SendCommand)(char *command,int sync); // send a command to VirtualDJ. if sync is set to 1, the command is sent from the plugin thread (don't use this with Windows-related commands).
	HRESULT (__stdcall *GetInfo)(char *command,void *result); // get infos from VirtualDJ. result must point to a caller-allocated TVdjQueryResult structure.

	// parameters stuff
	// call DeclareParameter() for all your variables during OnLoad()
	// if type=VDJPARAM_CUSTOM or VDJPARAM_STRING, defaultvalue must be set to sizeof(*parameter)
	HRESULT (__stdcall *DeclareParameter)(void *parameter,int type,int id,char *name,int defaultvalue);
	// OnParameter will be called each time a parameter is changed from within VirtualDJ
	virtual HRESULT __stdcall OnParameter(int id) {return 0;}

	// Custom user-interface
	// Create a Window using CreateWindow() or CreateDialog(), and send back the HWND.
	// If you return E_NOTIMPL, the default interface will be used.
	virtual HRESULT __stdcall OnGetUserInterface(HWND *hWnd) {return E_NOTIMPL;}
	VDJ_HINSTANCE hInstance;
	int Width,Height;
};

//////////////////////////////////////////////////////////////////////////
// GUID definitions

#ifndef VDJCLASSGUID_DEFINED
#define VDJCLASSGUID_DEFINED
static const GUID CLSID_VdjPlugin6 = { 0x37db664a, 0x6cf1, 0x4768, { 0xbc, 0x69, 0x32, 0x68, 0x13, 0xbf, 0xb, 0xf4 } };
static const GUID CLSID_VdjPlugin5 = { 0x2e1480fe, 0x4ff4, 0x4539, { 0x90, 0xb3, 0x64, 0x5f, 0x5d, 0x86, 0xf9, 0x3b } };
static const GUID IID_IVdjPluginBasic = { 0x865a6bbe, 0xed4b, 0x4bd5, { 0x93, 0xfe, 0x25, 0xa6, 0x26, 0xe2, 0x56, 0x1f } };
#else
extern static const GUID CLSID_VdjPlugin6;
extern static const GUID CLSID_VdjPlugin5;
extern static const GUID IID_IVdjPluginBasic;
#endif

//////////////////////////////////////////////////////////////////////////
// DLL export function

#ifndef NODLLEXPORT
#ifdef __cplusplus
extern "C" {
#endif
VDJ_EXPORT HRESULT __stdcall DllGetClassObject(const GUID &rclsid,const GUID &riid,void** ppObject);
#ifdef __cplusplus
}
#endif
#endif

//////////////////////////////////////////////////////////////////////////

#endif
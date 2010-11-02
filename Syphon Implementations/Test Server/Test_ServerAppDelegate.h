/*
    Test_ServerAppDelegate.h
	Test Server
	
    Copyright 2010 bangnoise (Tom Butterworth) & vade (Anton Marini).
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

#import <Cocoa/Cocoa.h>
#import "SimpleServerGLView.h"
#import "SimpleRenderer.h"
#import "TestServerRenderThread.h"
#import "SyIStopwatch.h"

@interface Test_ServerAppDelegate : NSObject <NSApplicationDelegate, TestServerRenderThreadDelegate> {
    NSWindow *window;
	SimpleServerGLView* glView;
	SyphonServer *syServer;
	SimpleRenderer *renderer;
	TestServerRenderThread *_thread;
	NSTimer *_UITimer;
	BOOL _rendersQTZ;
	BOOL _rendersOverlay;
	BOOL _hasNewFrame;
	NSUInteger FPS;
	NSTimeInterval fpsStart;
	NSUInteger fpsCount;
	SyIStopwatch *_watch;
	NSUInteger _frameCount;
	SyIStopwatch *_fpsWatch;
}
- (void)render;
@property (assign, nonatomic) NSUInteger FPS;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SimpleServerGLView* glView;
@property (assign) BOOL capsFPS;
@property (assign) float FPSCap;
@property (assign) BOOL rendersQTZ;
@property (assign) BOOL rendersOverlay;
@property (assign) BOOL hasNewFrame;
@end


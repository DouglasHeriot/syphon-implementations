/*
    Simple_ServerAppDelegate.h
	Syphon (SDK)
	
    Copyright 2010-2011 bangnoise (Tom Butterworth) & vade (Anton Marini).
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

@interface Simple_ServerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	SimpleServerGLView* glView;
	SyphonServer *syServer;
	NSTimeInterval startTime;
	SimpleRenderer *renderer;
	NSTimer* lameRenderingTimer;	//yea, should use display link but this is a demo.
	
	NSUInteger FPS;
	NSTimeInterval fpsStart;
	NSUInteger fpsCount;
}
@property (assign, nonatomic) NSUInteger FPS;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SimpleServerGLView* glView;
@property (retain) SimpleRenderer *renderer;

- (IBAction) open:(id)sender;
@end

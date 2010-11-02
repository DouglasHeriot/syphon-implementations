/*
    Test_ServerAppDelegate.m
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
 
#import "Test_ServerAppDelegate.h"


@implementation Test_ServerAppDelegate

@synthesize window;
@synthesize glView;
@synthesize hasNewFrame = _hasNewFrame;
@synthesize FPS;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_watch = [[SyIStopwatch alloc] init];
	CGLContextObj context = [[glView openGLContext] CGLContextObj];
	CGLError err = 0;
	
	// Enable multi-threaded GL
	err =  CGLEnable(context, kCGLCEMPEngine);
	
	if (err != kCGLNoError )
	{
		NSLog(@"Couldn't enable multi-threaded GL");
	}
	
	syServer = [[SyphonServer alloc] initWithName:nil context:context options:nil];
	[glView addObserver:self forKeyPath:@"frame" options:0 context:nil];
	fpsStart = [NSDate timeIntervalSinceReferenceDate];
	_thread = [[TestServerRenderThread alloc] initWithDelegate:self];
	[_thread setName:@"Render Thread"];
	[_thread start];
	_UITimer = [[NSTimer scheduledTimerWithTimeInterval:1/120 target:self selector:@selector(updateUI:) userInfo:nil repeats:YES] retain];
	_fpsWatch = [[SyIStopwatch alloc] init];
	self.FPSCap = 60.0;
	self.capsFPS = YES;
	self.rendersQTZ = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"frame"])
	{
		[renderer setTextureSize:[glView frame].size];
		[renderer render];
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
	CGLLockContext(syServer.context);
	[syServer stop];
	CGLUnlockContext(syServer.context);
	[_fpsWatch stop];
	SYPHONLOG(@"server average milliseconds to render:%f", _watch.runAverage * 1000);
	SYPHONLOG(@"server average fps over %f seconds:%f", _fpsWatch.time, (float)_frameCount / _fpsWatch.time);
}

- (void)dealloc
{
	[_watch release];
	[_fpsWatch release];
	[super dealloc];
}

- (void)updateUI:(NSTimer *)timer
{
	float elapsed = [NSDate timeIntervalSinceReferenceDate] - fpsStart;
	if (elapsed > 0.2)
	{
		// yea we round up...
		CGLLockContext(syServer.context);
		self.FPS = ceilf(fpsCount / elapsed);
		fpsCount = 0;
		CGLUnlockContext(syServer.context);
		fpsStart = [NSDate timeIntervalSinceReferenceDate];
	}
	if (self.hasNewFrame)
	{
		self.hasNewFrame = NO;
		[glView setNeedsDisplay:YES];
	}
}

// rendering only happens on our rendering thread
-(void) render
{
	CGLContextObj context = syServer.context;
	CGLLockContext(context);
	if (renderer == nil)
	{
		[self willChangeValueForKey:@"rendersQTZ"];
		NSString *path = [[NSBundle mainBundle] pathForResource:@"ServerDemo" ofType:@"qtz"];
		renderer = [[SimpleRenderer alloc] initWithFile:path context:context];
		[renderer setTextureSize:[glView frame].size];
		[self didChangeValueForKey:@"rendersQTZ"];
		[self setRendersOverlay:self.rendersOverlay];
		[glView setSource:renderer];
		[_fpsWatch start];
	}
	[renderer render];

	// Monitor frame-rate
	fpsCount++;
	_frameCount++;
	
	// We only publish our frame if we have clients
	if ([syServer hasClients])
	{
		[renderer lockTexture];
		[_watch start];
		// publish our frame to our server.
		[syServer publishFrameTexture:renderer.textureName
						textureTarget:GL_TEXTURE_RECTANGLE_EXT
						  imageRegion:NSMakeRect(0, 0, renderer.textureSize.width, renderer.textureSize.height)
					textureDimensions:renderer.textureSize
							  flipped:NO];
		[_watch stop];
		[renderer unlockTexture];
	}
	CGLUnlockContext(context);
	self.hasNewFrame = YES;
}

- (BOOL)capsFPS
{
	return _thread.FPSIsCapped;
}

- (void)setCapsFPS:(BOOL)caps
{
	_thread.FPSIsCapped = caps;
}

- (float)FPSCap
{
	return _thread.FPS;
}

- (void)setFPSCap:(float)cap
{
	_thread.FPS = cap;
}

- (BOOL)rendersQTZ
{
	return renderer.rendersComposition;
}

- (void)setRendersQTZ:(BOOL)renders
{
	renderer.rendersComposition = renders;
}

- (BOOL)rendersOverlay
{
	BOOL result;
	@synchronized(self)
	{
		result = _rendersOverlay;
	}
	return result;
}

- (void)setRendersOverlay:(BOOL)renders
{
	@synchronized(self)
	{
		_rendersOverlay = renders;
	}		
	// Use the CGL context lock as a free lock to avoid conflict with our render thread, bit odd but hey
	CGLLockContext(syServer.context);
	if ([[[renderer QCRenderer] inputKeys] containsObject:@"Show_Overlay"])
	{
		[[renderer QCRenderer] setValue:[NSNumber numberWithBool:renders] forInputKey:@"Show_Overlay"];
	}
	CGLUnlockContext(syServer.context);
}
@end

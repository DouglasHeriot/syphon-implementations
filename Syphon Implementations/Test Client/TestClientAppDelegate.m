/*
    TestClientAppDelegate.m
	Test Client
	
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

#import "TestClientAppDelegate.h"

@interface TestClientAppDelegate (Private)
- (void)handleServerChange;
@end

@implementation TestClientAppDelegate

@synthesize selectedServersUUID;

@synthesize FPS;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_bindWatch = [[SyIStopwatch alloc] init];
	_unbindWatch = [[SyIStopwatch alloc] init];
	// observe changes in Syphon Client so we can build our UI.
	[[SyphonServerDirectory sharedDirectory] addObserver:self forKeyPath:@"servers" options:0 context:nil];
	[self handleServerChange];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[glView setSyClient:nil];
	
	[[SyphonServerDirectory sharedDirectory] removeObserver:self forKeyPath:@"servers"];
	
	[syClient release];
	syClient = nil;
	[_fpsWatch stop];
	SYPHONLOG(@"client average fps over %f seconds:%f", _fpsWatch.time, (float)_frameCount / _fpsWatch.time);
	SYPHONLOG(@"client average milliseconds to bind:%f", _bindWatch.runAverage * 1000);
	SYPHONLOG(@"client average milliseconds to unbind:%f", _unbindWatch.runAverage * 1000);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (void)handleServerChange
{
	// clear out UI
	[availableServersMenu removeAllItems];
	BOOL selectedServerStillExists = NO;
	for(NSDictionary* serverDescription in [[SyphonServerDirectory sharedDirectory] servers])
	{
		NSString* name = [serverDescription objectForKey:SyphonServerDescriptionNameKey];
		NSString* appName = [serverDescription objectForKey:SyphonServerDescriptionAppNameKey];
		NSString *uuid = [serverDescription objectForKey:SyphonServerDescriptionUUIDKey];
		NSImage* appImage = [serverDescription objectForKey:SyphonServerDescriptionIconKey];
		
		NSString *title = [NSString stringWithString:appName];
		if ([name length] > 0)
		{
			title = [name stringByAppendingFormat:@" - %@", title, nil];
		}
		
		//		NSLog(@"Server UUID:%@, Server ID (name) %@", uuid, title);
		
		NSMenuItem* serverMenuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(setServer:) keyEquivalent:@""];
		[serverMenuItem setRepresentedObject:serverDescription];
		
		[serverMenuItem setImage:appImage];
		
		[[availableServersMenu menu] addItem:serverMenuItem];
		
		if([uuid isEqualToString:self.selectedServersUUID])
		{
			selectedServerStillExists = YES;
			[availableServersMenu selectItem:serverMenuItem];
		}
		
		[serverMenuItem release];
	}
	if (self.selectedServersUUID == nil || selectedServerStillExists == NO)
	{
		self.FPS = 0;
		if ([availableServersMenu numberOfItems] > 0)
		{
			[self setServer:[availableServersMenu selectedItem]];
		} else {
			[syClient release];
			syClient = nil;
			[glView setSyClient:nil];
			[glView setNeedsDisplay:YES];
		}
	}	
}

// Here we build our UI in response to changing bindings in our syClient, using KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	NSLog(@"Changes happened in Syphon Client : %@ change:%@", object, change);
	
	if([keyPath isEqualToString:@"servers"])
	{
		[self handleServerChange];
	}		
}

- (IBAction) setServer:(id)sender
{
	self.selectedServersUUID = [[sender representedObject] objectForKey:SyphonServerDescriptionUUIDKey];
	
	[syClient release];
	fpsStart = [NSDate timeIntervalSinceReferenceDate];
	fpsCount = 0;
	syClient = [[SyphonClient alloc] initWithServerDescription:[sender representedObject] options:nil newFrameHandler:^(SyphonClient *client) {
        // This handler could be called from any thread, but we update our UI so pass this over to the main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Track our framerate
            fpsCount++;
            float elapsed = [NSDate timeIntervalSinceReferenceDate] - fpsStart;
            if (elapsed > 1.0)
            {
                self.FPS = fpsCount / elapsed;
                fpsStart = [NSDate timeIntervalSinceReferenceDate];
                fpsCount = 0;
            }
            if (_fpsWatch == nil)
            {
                _fpsWatch = [[SyIStopwatch alloc] init];
                [_fpsWatch start];
            }
            _frameCount++;
    #if SYPHON_DEBUG_NO_DRAWING
            [_bindWatch start];
            [client bindFrameTexture:NULL];
            [_bindWatch stop];
            [_unbindWatch start];
            [client unbindFrameTexture:NULL];
            [_unbindWatch stop];
    #else
            // We just mark our view as needing display, it will get the frame when it's ready to draw
            [glView setNeedsDisplay:YES];
    #endif
        }];
	}];
	
	[glView setSyClient:syClient];
	if (syClient == nil)
	{
#if !SYPHON_DEBUG_NO_DRAWING
		[glView setNeedsDisplay:YES];
#endif
	}
}

@end

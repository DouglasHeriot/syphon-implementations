/*
    ServerAppDelegate.m
    Messaging Test Rig (Server)
	
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

#import "ServerAppDelegate.h"
#import "SyphonMessaging.h"

@implementation ServerAppDelegate

@synthesize window, shouldStop;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	SyphonMessageSender *sender = [[SyphonMessageSender alloc] initForName:@"SYPHON_TEST"
//																	  protocol:SyphonMessagingProtocolMachMessage
																  protocol:SyphonMessagingProtocolCFMessage
													   invalidationHandler:^(void) {
														   NSLog(@"invalidation handler was called");
													   }];
	unsigned int count = 0;
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	for (int i = 0; i < 100000; i++)
	{
		if (sender)
		{
			NSDate *date = [NSDate date];
			[sender send:date ofType:32];
			count++;
		}
	}
	[sender release];
	NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
	NSLog(@"%u sends over %f seconds", count, duration);
	NSLog(@"%f FPS", count / duration);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}
@end

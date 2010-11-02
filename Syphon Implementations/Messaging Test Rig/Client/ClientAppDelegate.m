/*
    ClientAppDelegate.m
    Messaging Test Rig (Client)
	
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

#import "ClientAppDelegate.h"

@implementation ClientAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	
	_receiver = [[SyphonMessageReceiver alloc] initForName:@"SYPHON_TEST"
//												  protocol:SyphonMessagingProtocolMachMessage
												  protocol:SyphonMessagingProtocolCFMessage
												   handler:^(id <NSCoding> data, uint32_t type) {
													   _frameCount++;
													   _durations += -[(NSDate *)data timeIntervalSinceNow] * 1000;
//		NSLog(@"%u, %@", type, (NSString *)data);
//		usleep(10000);
												   }];
	if (_receiver == nil)
	{
		NSLog(@"Couldn't create receiver");
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	if (_frameCount)
		NSLog(@"Received %u frames with average latency %f ms.", _frameCount, _durations / _frameCount);
	else
		NSLog(@"Received no frames.");

}
@end

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
#import "TestMessages.h"

@implementation ServerAppDelegate

@synthesize window;

- (void)sendMessageToConnection:(NSString *)name
{
    SyphonMessageSender *sender = [[SyphonMessageSender alloc] initForName:name
                                   //							  protocol:SyphonMessagingProtocolMachMessage
																  protocol:SyphonMessagingProtocolCFMessage
													   invalidationHandler:^(void) {
														   NSLog(@"ERROR: Invalidation handler was called for SyphonMessageSender for %@", name);
													   }];
    [sender send:name ofType:TestMessageTestingConnection];
    [sender release];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _receiver = [[SyphonMessageReceiver alloc] initForName:@"SYPHON_TEST"
                                                  protocol:SyphonMessagingProtocolCFMessage
                                                   handler:^(id payload, uint32_t type) {
                                                       switch (type) {
                                                           case TestMessageDate:
                                                               _frameCount++;
                                                               _durations += -[(NSDate *)payload timeIntervalSinceNow] * 1000;
                                                               break;
                                                           case TestMessageAwaitingConnection:
                                                               _newConnectionCount++;
                                                               [self sendMessageToConnection:(NSString *)payload];
                                                               break;
                                                           case TestMessageAwaitingConnectionCount:
                                                           {
                                                               NSLog(@"Sending connection count (%lu)", (unsigned long)_newConnectionCount);
                                                               SyphonMessageSender *sender = [[SyphonMessageSender alloc] initForName:(NSString *)payload
                                                                                              //							  protocol:SyphonMessagingProtocolMachMessage
                                                                                                                             protocol:SyphonMessagingProtocolCFMessage
                                                                                                                  invalidationHandler:^(void) {
                                                                                                                      NSLog(@"ERROR: Invalidation handler was called for SyphonMessageSender for %@", (NSString *)payload);
                                                                                                                  }];
                                                               [sender send:[NSNumber numberWithUnsignedInteger:_newConnectionCount] ofType:TestMessageConnectionCount];
                                                               [sender release];
                                                               [[NSApplication sharedApplication] terminate:self];
                                                               break;
                                                           }
                                                           default:
                                                               NSLog(@"ERROR: Unexpected message type");
                                                               break;
                                                       }
                                                   }];
    if (!_receiver)
        NSLog(@"Couldn't create receiver.");
    else
        NSLog(@"Ready for client.");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [_receiver invalidate];
    [_receiver release];
    _receiver = nil;
    NSLog(@"received %lu connection requests", _newConnectionCount);
    if (_frameCount)
		NSLog(@"Received %lu frames with average latency %f ms. (dropped frames are OK)", _frameCount, _durations / _frameCount);
	else
		NSLog(@"ERROR: Received no frames.");
}
@end

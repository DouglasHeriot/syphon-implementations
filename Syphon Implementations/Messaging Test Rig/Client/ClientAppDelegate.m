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
#import "TestMessages.h"

#define kNumTestConnections 1

@implementation ClientAppDelegate

@synthesize window;

- (void)removeWaitingConnection:(NSString *)name
{
    @synchronized(self)
    {
        SyphonMessageReceiver *found;
        for (SyphonMessageReceiver *next in _waitingConnections) {
            if ([next.name isEqualToString:name])
            {
                found = next;
                break;
            }
        }
        if (found)
        {
            [_waitingConnections removeObject:found];
        }
        else
        {
            NSLog(@"ERROR: Got notification for an unknown connection.");
        }
    }
}

- (void)noteNewConnection:(NSString *)name
{
    if (!name)
    {
        NSLog(@"ERROR: Connection missing payload (should be the connection's name).");
    }
    else
    {
        [self removeWaitingConnection:name];
    }
}

- (void)testThroughput
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"Testing throughput");
    unsigned int count = 0;
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    for (int i = 0; i < 100000; i++)
    {
        NSDate *date = [NSDate date];
        [_sender send:date ofType:TestMessageDate];
        count++;
    }
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
    NSLog(@"%u sends over %f seconds (average time to send is %d µs)", count, duration, (int)(duration / count * 1000000));
    NSLog(@"%f FPS", count / duration);
    [pool drain];
}

- (void)testConnections
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"Testing new connections");
    for (int i = 0; i < kNumTestConnections; i++) {
        NSString *name = [NSString stringWithFormat:@"SYPHON_TEST_%d", i+1];
        SyphonMessageReceiver *receiver = [[SyphonMessageReceiver alloc] initForName:name
                                                                            protocol:SyphonMessagingProtocolCFMessage
                                                                             handler:^(id payload, uint32_t type) {
                                                                                 [self noteNewConnection:(NSString *)payload];
                                                                             }];
        @synchronized(self)
        {
            [_waitingConnections addObject:receiver];
        }
        [receiver release];
        [_sender send:name ofType:TestMessageAwaitingConnection];
    }
    SyphonMessageReceiver *receiver = [[SyphonMessageReceiver alloc] initForName:@"SYPHON_TEST_CONNECTION_COUNT"
                                                                        protocol:SyphonMessagingProtocolCFMessage
                                                                         handler:^(id payload, uint32_t type) {
                                                                             [self removeWaitingConnection:@"SYPHON_TEST_CONNECTION_COUNT"];
                                                                             @synchronized(self)
                                                                             {
                                                                                 _connectionsServerSaw = [(NSNumber *)payload unsignedIntegerValue];
                                                                                 if ([_waitingConnections count] == kNumTestConnections - _connectionsServerSaw)
                                                                                 {
                                                                                     [_waitingConnections removeAllObjects];
                                                                                     NSLog(@"SUCCESS: All %u connections the server saw were acknowledged (%u sent connection requests were dropped due to message queue coalescing)", _connectionsServerSaw, kNumTestConnections - _connectionsServerSaw);
                                                                                     [[NSApplication sharedApplication] terminate:self];
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     NSLog(@"ERROR: Some connections weren't made - got %u of %u", kNumTestConnections - [_waitingConnections count], kNumTestConnections);
                                                                                 }
                                                                             }
                                                                         }];
    @synchronized(self)
    {
        [_waitingConnections addObject:receiver];
    }
    [_sender send:@"SYPHON_TEST_CONNECTION_COUNT" ofType:TestMessageAwaitingConnectionCount];
//    usleep(USEC_PER_SEC * 2.0);
//    [[NSApplication sharedApplication] terminate:self];
    [pool drain];
}

- (void)runTests
{
//    [self testThroughput];
    [self testConnections];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _waitingConnections = [[NSMutableSet alloc] initWithCapacity:kNumTestConnections + 1];
    
	_sender = [[SyphonMessageSender alloc] initForName:@"SYPHON_TEST"
//                                            protocol:SyphonMessagingProtocolMachMessage
                                              protocol:SyphonMessagingProtocolCFMessage
                                   invalidationHandler:^(void) {
                                       NSLog(@"invalidation handler was called for sender");
                                   }];
    if (!_sender)
    {
        NSLog(@"ERROR: Couldn't create SyphonMessageSender. Make sure you launch the server before the client.");
        [[NSApplication sharedApplication] terminate:self];
    }
    else
    {
        _didStartTests = YES;
        [self performSelectorInBackground:@selector(runTests) withObject:nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if (_didStartTests)
    {
        @synchronized(self)
        {
            if ([_waitingConnections count] != 0)
            {
                NSLog(@"ERROR: Tests did not complete. Sent %u requests, server reported seeing %u, got %u acknowledgments",
                      kNumTestConnections, _connectionsServerSaw, [_waitingConnections count] - 1);
            }
        }
    }
}
@end

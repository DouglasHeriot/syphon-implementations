/*
    TestServerRenderThread.m
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
 
#import "TestServerRenderThread.h"


@implementation TestServerRenderThread

- (id)initWithDelegate:(id <TestServerRenderThreadDelegate>)del
{
	if (self = [super init])
	{
		_delegate = del;
	}
	return self;
}

@synthesize FPS = _fps, FPSIsCapped = _capped, delegate = _delegate;

- (void)main
{
	NSDate *last;
	NSAutoreleasePool *pool;
	while (![self isCancelled]) {
		pool = [[NSAutoreleasePool alloc] init];
		last = [NSDate date];
		[_delegate render];
		if (self.FPSIsCapped)
		{
			[NSThread sleepUntilDate:[last dateByAddingTimeInterval:1 / self.FPS]];
		}
		[pool drain];
	}
}
@end

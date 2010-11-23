//
//  SyphonCaptureWindow.m
//  SyphonScreenCapture
//
//  Created by vade on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyphonCaptureWindow.h"


@implementation SyphonCaptureWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	if(self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:deferCreation])
	{
		[self setBackgroundColor:[NSColor clearColor]];
		
		
		SyphonCaptureView* contentView = [[SyphonCaptureView alloc] initWithFrame:contentRect];
		[contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[contentView setFrameOrigin:NSMakePoint(0, 0)];
		[[self contentView] addSubview:contentView];
        
		[contentView release];
		
		[self setLevel:kCGFloatingWindowLevel + 1];
	}
	return self;
}

- (BOOL) isOpaque
{
	return NO;
}

- (BOOL) hasShadow
{
	return NO;
}

@end


@implementation SyphonCaptureView


- (id)initWithFrame:(NSRect)frameRect
{
	if(self = [super initWithFrame:frameRect])
	{
		phase = 0.0;
		phaseTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(updatePhase) userInfo:nil repeats:YES] retain];
		[[NSRunLoop currentRunLoop] addTimer:phaseTimer forMode:NSDefaultRunLoopMode];
	}
	else
	{
		[self release];
		return nil;
	}
    
	return self;
}

- (void) dealloc
{
	[phaseTimer invalidate];
	
	[super dealloc];
}

- (void) updatePhase
{	
	if([self.window isVisible])
	{
		phase += 1.25;
		phase = (phase >= 20.0) ? 0.0 : phase; 
		
		[self setNeedsDisplay:YES];
	}
}

- (void) drawRect:(NSRect) rect
{
	NSBezierPath* drawPath = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:10 yRadius:10];
	
    
    [drawPath setLineCapStyle:NSSquareLineCapStyle];
	[drawPath setLineJoinStyle:NSBevelLineJoinStyle];
	
    [drawPath setLineWidth:4];

	[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
	[drawPath stroke];
    
    
	[[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0] set];
	[drawPath setLineCapStyle:NSSquareLineCapStyle];
	[drawPath setLineJoinStyle:NSBevelLineJoinStyle];
	
	CGFloat	array[2];
	array[0] = 10.0; //segment painted with stroke color
	array[1] = 10.0; //segment not painted with a color
	
	[drawPath setLineDash: array count: 2 phase:phase];
    
	[drawPath stroke];
}

@end

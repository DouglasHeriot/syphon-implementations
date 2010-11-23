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
		
		[self setLevel:kCGOverlayWindowLevelKey + 1];
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

- (void) drawRect:(NSRect) rect
{
    NSBezierPath* drawPath = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:5 yRadius:5];
    
    [[NSColor colorWithCalibratedWhite:0.5 alpha:0.7] set];
    [drawPath fill];
    
    [[NSColor clearColor] set];    
    NSRectFill(NSInsetRect(rect, 10, 10));
}

@end

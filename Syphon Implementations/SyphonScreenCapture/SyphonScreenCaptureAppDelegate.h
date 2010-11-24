//
//  SyphonScreenCaptureAppDelegate.h
//  SyphonScreenCapture
//
//  Created by vade on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <Syphon/Syphon.h>

#import "SyphonCaptureWindow.h"

@class SyphonServer;

@interface SyphonScreenCaptureAppDelegate : NSObject <NSApplicationDelegate>
{
    SyphonServer* syServer;

    SyphonCaptureWindow* captureWindow;
    NSWindow* window;
    NSView* previewView;

    NSPopUpButton* selectSourceWindowPopUpButton;
    NSArray* windowsArray;
        
    // Main fullscreen context, where all capturing happens.
    NSOpenGLContext* fullscreenContext;
    NSOpenGLContext* previewContext;
    
    CVDisplayLinkRef renderLink;
    NSTimer *stupidRenderTimer;
    
    //GLuint captureTexture;
    
    NSRect captureRect;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView* previewView;
@property (assign) IBOutlet NSPopUpButton* selectSourceWindowPopUpButton;

@property (readwrite, retain) SyphonServer* syServer;
@property (readwrite, retain) NSArray* windowsArray;

- (void) initWindowMenu;
- (void) createFullscreenContextOnDisplay:(CGDirectDisplayID) displayID;
- (void) createPreviewContext;
- (void) render;

- (IBAction) shouldDisplayPreviewWindow:(id)sender;

@end

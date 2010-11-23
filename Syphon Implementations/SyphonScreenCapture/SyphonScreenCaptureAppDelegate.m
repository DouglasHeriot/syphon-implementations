//
//  SyphonScreenCaptureAppDelegate.m
//  SyphonScreenCapture
//
//  Created by vade on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyphonScreenCaptureAppDelegate.h"
#import <OpenGL/CGLMacro.h>

#import <Quartz/Quartz.h>

// Im bad
//#import "CoreGraphicsServices.h"
//#import "CGSPrivate.h"

@implementation SyphonScreenCaptureAppDelegate

@synthesize window;
@synthesize previewView;
@synthesize selectSourceWindowPopUpButton;
@synthesize syServer;
@synthesize windowsArray;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    captureWindow = [[SyphonCaptureWindow alloc] initWithContentRect:NSMakeRect(22, 0, 640, 480) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [captureWindow makeKeyAndOrderFront:nil];
    
    // We need to handle some notifications from NSWorkspace
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(initWindowMenu) name:NSWorkspaceDidHideApplicationNotification object:nil]; 
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(initWindowMenu) name:NSWorkspaceDidUnhideApplicationNotification object:nil]; 
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(initWindowMenu) name:NSWorkspaceDidLaunchApplicationNotification object:nil]; 
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(initWindowMenu) name:NSWorkspaceDidTerminateApplicationNotification object:nil]; 
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(initWindowMenu) name:NSWorkspaceDidActivateApplicationNotification object:nil]; 
    
    [self initWindowMenu];
    
    // Make our GL contexts, and views
    CGDirectDisplayID displayID = [[[[NSScreen mainScreen] deviceDescription] valueForKey:@"NSScreenNumber"] unsignedIntValue];
    [self createFullscreenContextOnDisplay:displayID];
    [self createPreviewContext];
    
    // make a new Syphon Server
    syServer = [[SyphonServer alloc] initWithName:@"" context:[fullscreenContext CGLContextObj] options:nil];
    
    stupidRenderTimer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(render) userInfo:nil repeats:YES];
    [stupidRenderTimer retain];
    [[NSRunLoop currentRunLoop] addTimer:stupidRenderTimer forMode:NSRunLoopCommonModes];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [syServer stop];
    [syServer release];
    syServer = nil;
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void) initWindowMenu
{
    [selectSourceWindowPopUpButton removeAllItems];
        
    self.windowsArray = (NSArray*) CGWindowListCopyWindowInfo( kCGWindowListOptionOnScreenOnly + kCGWindowListExcludeDesktopElements, kCGNullWindowID);
            
    for(NSDictionary* winDict in windowsArray)
    {
        NSMenu* menuToAddTo = nil;
        
        NSString* appName = [winDict valueForKey:(NSString*)kCGWindowOwnerName];
        
        if(![appName isEqualTo:@"SystemUIServer"] && ![appName isEqualTo:@"Window Server"] && ![appName isEqualTo:@"Main Menu"] && ![appName isEqualTo:@"Dock"])
        {
            for(NSMenuItem* item in [selectSourceWindowPopUpButton itemArray])
            {
                // if there is an existing sub-menu for the application, use it, otherwise, make one.
                if([[item title] isEqualTo:appName])
                {
                    menuToAddTo = [item submenu];
                    break;
                }
            }
            
            // If we did not find our menu item, make a new one.
            if(menuToAddTo == nil)
            {
                menuToAddTo = [[NSMenu alloc] initWithTitle:appName];
                
                NSMenuItem* newItem = [[NSMenuItem alloc] initWithTitle:appName action:NULL keyEquivalent:@""];
            
                NSRunningApplication* app = [NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)[[winDict valueForKey:(NSString*)kCGWindowOwnerPID] intValue]];
                
                [newItem setImage:[app icon]];
                
                [[selectSourceWindowPopUpButton menu] addItem:newItem];
                [[selectSourceWindowPopUpButton menu] setSubmenu:menuToAddTo forItem:newItem];

                [newItem autorelease];
                [menuToAddTo autorelease];
            }
                        
            NSString* windowtitle = ([winDict valueForKey:(NSString*)kCGWindowName]) ? [winDict valueForKey:(NSString*)kCGWindowName] : @"";
            
            NSMenuItem* newObjectMenuItem = [[NSMenuItem alloc] initWithTitle:windowtitle action:@selector(selectWindow:) keyEquivalent:@""];
            [newObjectMenuItem setRepresentedObject:[winDict valueForKey:(NSString*)kCGWindowNumber]];
            
            [menuToAddTo addItem:newObjectMenuItem];
            [newObjectMenuItem release];
        }
    }
    
    NSMenuItem* newItem = [[NSMenuItem alloc] initWithTitle:@"Desktop" action:@selector(selectWindow:) keyEquivalent:@""];
    [newItem setRepresentedObject:[NSNumber numberWithUnsignedInt:0]];
    [newItem setImage: [NSImage imageNamed:@"NSApplicationIcon"]];
    
    [[selectSourceWindowPopUpButton menu] addItem:newItem];
    [newItem release];
}

- (void) selectWindow:(id)sender
{    
    // We want to get fresh data about the window, so we re-query cause thats how we roll.
    CGWindowID win = (CGWindowID)[[sender representedObject] unsignedIntValue];
    
    if(win)
    {
        CGWindowID windowIDs[1] = { win };
        
        CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, 1, NULL);
        
        NSArray* returned = (NSArray*) CGWindowListCreateDescriptionFromArray(windowIDsArray);
        
        NSDictionary* windowDict = [returned objectAtIndex:0];
        NSDictionary* rectDict = [windowDict valueForKey:(NSString*)kCGWindowBounds]; 
        
        // bring the running applications to the front.
        // The following does not *quite* work. It brings the app, not the window to the front. The window may still be occluded.
        
        NSRunningApplication* targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)[[windowDict valueForKey:(NSString*)kCGWindowOwnerPID] intValue]];
        [targetApp activateWithOptions:NSApplicationActivateAllWindows];

        // Attempted work around using private API CoreGraphicsServices, no dice (so far).
/*        
        CGSInitialize();
        CGWindowID winID = (CGWindowID)[[windowDict valueForKey:(NSString*)kCGWindowNumber] unsignedIntValue ]; 
        
        int err = 0;
        
        CGSConnection defaultConn = _CGSDefaultConnection();
        CGSConnection cid;
        CGSNewConnection(&defaultConn, &cid);
        
        ProcessSerialNumber psn;
        pid_t processid = (pid_t)[[windowDict valueForKey:(NSString*)kCGWindowOwnerPID] intValue];
        GetProcessForPID(processid, &psn);
        
        CGSConnection windowConnectionIWant;
        
        err = CGSGetConnectionIDForPSN(0, &psn, &windowConnectionIWant);
        if(err)
            NSLog(@"Error finding connection for PSN: %i", err);
        
        err = CGSUncoverWindow(windowConnectionIWant, winID);        
        if(err)
            NSLog(@"Error finding connection for PSN: %i", err);
*/
        
        CGRect rect;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)rectDict, &rect);
        NSRect windowRect = NSRectFromCGRect(rect);
        
        windowRect = NSIntersectionRect([NSScreen mainScreen].frame, windowRect);
        
        windowRect.origin.y = [[NSScreen mainScreen] frame].size.height - windowRect.origin.y - windowRect.size.height;    
        
        captureRect = windowRect;
        
        [syServer setName:[windowDict valueForKey:(NSString*)kCGWindowName]];

        [returned autorelease];
        CFRelease(windowIDsArray);
    }
    else
    {
        captureRect = [NSScreen mainScreen].frame;
        [syServer setName:@"Desktop"];
    }
    
    [captureWindow setFrame:NSInsetRect(captureRect, -10, -10) display:YES animate:YES];
    
    // create a new GL Texture sized to fit the screen.
    CGLContextObj cgl_ctx = [fullscreenContext CGLContextObj];
    glDeleteTextures(1, &captureTexture);
    
    glGenTextures(1, &captureTexture);
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, captureTexture);
    // We use RGBA and UNSIGNED_BYTE because we are going GPU -> GPU. 
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, captureRect.size.width, captureRect.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
}

// CGLSetFullscreen is depreciated, but has no replcement for use with screen capture...
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void) createFullscreenContextOnDisplay:(CGDirectDisplayID) displayID
{
    const NSOpenGLPixelFormatAttribute attr[] = {NSOpenGLPFANoRecovery, NSOpenGLPFAAccelerated, NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask(displayID),NSOpenGLPFAFullScreen, 0};
 	
    // make pixel format
    NSOpenGLPixelFormat* pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr];
    if(pf == nil)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Could not create valid Pixel Format - Quitting"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [pf release];
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    // make context
    fullscreenContext = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
    if(fullscreenContext == nil)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Could not create valid Fullscreen context - Quitting"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [fullscreenContext release];
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    // go fullscreen on context
    CGLError err = kCGLNoError;
    err = CGLSetFullScreen([fullscreenContext CGLContextObj]);

	if(err != kCGLNoError)
	{
        NSAlert* alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Attempt to finalize fullscreen context failed - Quitting"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [[NSApplication sharedApplication] terminate:nil];
	}
    
    [pf release];
    
//    //  Be a lame ass and make a CIFilter attached to the window, using Private API's because this wont ever be on the app store..
//    CGSConnection thisConnection;
//    NSUInteger compositingFilter;
//    
//    NSInteger compositingType = 1 << 0; // Under the window
//
//    // Make a new connection to CoreGraphicsServices
//    CGSNewConnection(_CGSDefaultConnection(), &thisConnection);
//    
//    // Create a CoreImage filter and set it up
//    CGSNewCIFilterByName(thisConnection, (CFStringRef)@"CIColorInvert", &compositingFilter);
//    
//    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:3.0] forKey:@"inputRadius"];
//    CGSSetCIFilterValuesFromDictionary(thisConnection, compositingFilter, (CFDictionaryRef)options);
//    
//    /* Now apply the filter to the window */
//    
//    CGSAddWindowFilter(thisConnection, [captureWindow windowNumber], compositingFilter, compositingType);
}
#pragma clang diagnostic pop


- (void) createPreviewContext
{      
    const NSOpenGLPixelFormatAttribute attr[] = {NSOpenGLPFANoRecovery, NSOpenGLPFAAccelerated, NSOpenGLPFADoubleBuffer, 0};
    
    NSOpenGLPixelFormat* fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr];
    previewContext = [[NSOpenGLContext alloc] initWithFormat:fmt shareContext:fullscreenContext];
    
    if(previewContext == nil)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Could not create valid preview context - Quitting"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [previewContext release];
        [fmt release];
        [[NSApplication sharedApplication] terminate:nil];
        return;
    }
    
    [fmt release];

    [previewContext setView:previewView];
    [previewContext update];
}

- (void) render
{
    // get the fullscreen context
    CGLContextObj cgl_ctx;
    cgl_ctx = [fullscreenContext CGLContextObj];
    glReadBuffer(GL_FRONT);

    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, captureTexture);
    //glCopyTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA, captureRect.origin.x, captureRect.origin.y, captureRect.size.width, captureRect.size.height, 0);
    glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, 0, 0,captureRect.origin.x, captureRect.origin.y, captureRect.size.width, captureRect.size.height);    
    
    [syServer publishFrameTexture:captureTexture textureTarget:GL_TEXTURE_RECTANGLE_EXT imageRegion:NSMakeRect(0, 0, captureRect.size.width,captureRect.size.height) textureDimensions:captureRect.size flipped:NO];
    
    // This does not seem strictly necessary since we are not drawing to the fullscreen context.
    //CGLFlushDrawable(cgl_ctx);
    
    // handle preview rendering
    cgl_ctx = [previewContext CGLContextObj];
    [previewContext update];
    glViewport(0, 0, previewView.frame.size.width, previewView.frame.size.height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, previewView.frame.size.width, 0, previewView.frame.size.height, -1, 1);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslated(previewView.frame.size.width * 0.5, previewView.frame.size.height * 0.5, 0.0);

    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (captureTexture != 0)
	{
		glEnable(GL_TEXTURE_RECTANGLE_EXT);
		glBindTexture(GL_TEXTURE_RECTANGLE_EXT, captureTexture);
		
		NSSize textureSize = captureRect.size;
		
		glColor4f(1.0, 1.0, 1.0, 1.0);
		
		NSSize scaled;
		float wr = textureSize.width / previewView.frame.size.width;
		float hr = textureSize.height / previewView.frame.size.height;
		float ratio;
		ratio = (hr < wr ? wr : hr);
		scaled = NSMakeSize((textureSize.width / ratio), (textureSize.height / ratio));
		
		GLfloat tex_coords[] = 
		{
			0.0,	0.0,
			textureSize.width,	0.0,
			textureSize.width,	textureSize.height,
			0.0,	textureSize.height
		};
		
		float halfw = scaled.width * 0.5;
		float halfh = scaled.height * 0.5;
		
		GLfloat verts[] = 
		{
			-halfw, -halfh,
			halfw, -halfh,
			halfw, halfh,
			-halfw, halfh
		};
        
		glEnableClientState( GL_TEXTURE_COORD_ARRAY );
		glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, verts );
		glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
		glDisableClientState( GL_TEXTURE_COORD_ARRAY );
		glDisableClientState(GL_VERTEX_ARRAY);
	}
    
    CGLFlushDrawable(cgl_ctx);
}

- (IBAction) shouldDisplayPreviewWindow:(id)sender
{
    if([(NSButton*)sender state] == NSOnState)
    {
        [captureWindow orderFront:sender];
    }
    else
    {
        [captureWindow orderOut:sender];
    }    
}


@end

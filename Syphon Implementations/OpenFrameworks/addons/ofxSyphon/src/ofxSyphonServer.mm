/*
 *  ofxSyphonServer.cpp
 *  syphonTest
 *
 *  Created by astellato on 11/6/10.
 *  
 *  http://syphon.v002.info/license.php
 */

#include "ofxSyphonServer.h"
#import <Syphon/Syphon.h>

ofxSyphonServer::ofxSyphonServer()
{
	bSetup = false;
}

ofxSyphonServer::~ofxSyphonServer()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    [(SyphonServer *)mSyphon stop];
    [(SyphonServer *)mSyphon release];
    
    [pool drain];
}

void ofxSyphonServer::setup(string n, int w, int h, bool flip)
{
    // Need pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	name = n;
	width = w;
	height = h;
	NSString *title = [NSString stringWithCString:name.c_str() 
												encoding:[NSString defaultCStringEncoding]];
	mSyphon = [[SyphonServer alloc] initWithName:title context:CGLGetCurrentContext() options:nil];
	mTex.allocate(width, height, GL_RGBA);
	bSetup = true;
    
    [pool drain];
}

void ofxSyphonServer::publishScreen()
{
	if(bSetup)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

		mTex.loadScreenData(0, 0, width, height);
		ofTextureData texData = mTex.getTextureData();
		[(SyphonServer *)mSyphon publishFrameTexture:texData.textureID textureTarget:texData.textureTarget imageRegion:NSMakeRect(0, 0, width, height) textureDimensions:NSMakeSize(width, height) flipped:NO];
        
        [pool drain];
    } 
    else 
    {
		cout<<"ofxSyphonServer is not setup.  Cannot draw.\n";
	}
}


void ofxSyphonServer::publishTexture(ofTexture* inputTexture)
{
    // If we are setup, and our input texture
	if(bSetup && inputTexture->bAllocated())
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
		ofTextureData texData = inputTexture->getTextureData();

		[(SyphonServer *)mSyphon publishFrameTexture:texData.textureID textureTarget:texData.textureTarget imageRegion:NSMakeRect(0, 0, texData.width, texData.height) textureDimensions:NSMakeSize(texData.width, texData.height) flipped:texData.bFlipTexture];
        
        [pool drain];
    } 
    else 
    {
		cout<<"ofxSyphonServer is not setup, or texture is not properly backed.  Cannot draw.\n";
	}
}


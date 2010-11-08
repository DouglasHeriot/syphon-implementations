/*
 *  ofxSyphonServer.cpp
 *  syphonTest
 *
 *  Created by astellato,vade,bangnoise on 11/6/10.
 *  
 *  http://syphon.v002.info/license.php
 */

#include "ofxSyphonClient.h"

ofxSyphonClient::ofxSyphonClient()
{
	bSetup = false;
}

ofxSyphonClient::~ofxSyphonClient()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    [mClient release];
    
    [pool drain];
}

void ofxSyphonClient::setup()
{
    // Need pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
	mClient = [[SyphonNameboundClient alloc] init]; 
               
	bSetup = true;
    
    [pool drain];
}

void ofxSyphonClient::setApplicationName(string appName)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    NSString *name = [NSString stringWithCString:appName.c_str() encoding:[NSString defaultCStringEncoding]];
    
    if(bSetup)
    {
        [mClient setAppName:name];
    }
    
    [pool drain];
}
void ofxSyphonClient::setServerName(string serverName)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    NSString *name = [NSString stringWithCString:serverName.c_str() encoding:[NSString defaultCStringEncoding]];
    
    if(bSetup)
    {
        [mClient setName:name];
    }
    
    [pool drain];
}

void ofxSyphonClient::bind()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    if(bSetup)
    {
        
     	[mClient lockClient];
        SyphonClient *client = [mClient client];
   
        latestImage = [client newFrameImageForContext:CGLGetCurrentContext()];
		NSSize texSize = [latestImage textureSize];
        
        // we now have to manually make our ofTexture's ofTextureData a proxy to our SyphonImage
        mTex.texData.textureID = [latestImage textureName];
        mTex.texData.textureTarget = GL_TEXTURE_RECTANGLE_ARB;
        mTex.texData.width = texSize.width;
        mTex.texData.height = texSize.height;
        mTex.texData.tex_w = texSize.width;
        mTex.texData.tex_h = texSize.height;
        mTex.texData.tex_u = 0;
        mTex.texData.tex_t = 0;
        mTex.texData.glType = GL_RGBA;
        mTex.texData.pixelType = GL_UNSIGNED_BYTE;
        mTex.texData.bFlipTexture = NO;
        mTex.texData.bAllocated = YES;
        
        mTex.bind();
    }
    
    
    [pool drain];
}

void ofxSyphonClient::unbind()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if(bSetup)
    {

        mTex.unbind();

        [mClient unlockClient];
        [latestImage release];
        latestImage = nil;
    }
    
    
    [pool drain];
}

void ofxSyphonClient::draw(float x, float y, float w, float h)
{
    bind();
    
    mTex.draw(x, y, w, h);
    
    unbind();
}

void ofxSyphonClient::draw(float x, float y)
{
	draw(x,y, mTex.texData.width, mTex.texData.height);
}








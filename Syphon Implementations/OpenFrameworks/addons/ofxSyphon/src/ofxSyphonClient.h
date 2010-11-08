/*
 *  ofxSyphonServer.h
 *  syphonTest
 *
 *  Created by astellato,vade,bangnoise on 11/6/10.
 *
 *  http://syphon.v002.info/license.php
 */

#include "ofMain.h"
#import "SyphonNameboundClient.h"

class ofxSyphonClient {
	public:
	ofxSyphonClient();
	~ofxSyphonClient();
	
    void setup ();
    
    void setApplicationName(string appName);
    void setServerName(string serverName);
  
    void bind();
    void unbind();
    
    void draw(float x, float y, float w, float h);
    void draw(float x, float y);
    
	protected:
	SyphonNameboundClient *mClient;
    SyphonImage* latestImage;
	ofTexture mTex;
	int width, height;
	bool bSetup;
	string name;
};
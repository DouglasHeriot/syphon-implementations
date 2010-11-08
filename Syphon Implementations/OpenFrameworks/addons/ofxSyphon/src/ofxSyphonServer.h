/*
 *  ofxSyphonServer.h
 *  syphonTest
 *
 *  Created by astellato on 11/6/10.
 *
 *  http://syphon.v002.info/license.php
 */

#include "ofMain.h"

class ofxSyphonServer {
	public:
	ofxSyphonServer();
	~ofxSyphonServer();
	void setup (string n, int w, int h, bool flip);
	void publishScreen();
    void publishTexture(ofTexture* inputTexture);

    
	protected:
	void *mSyphon;
	ofTexture mTex;
	int width, height;
	bool bSetup;
	string name;
};
/**
 * you can put a one sentence description of your library here.
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author		##author##
 * @modified	##date##
 * @version		##version##
 */

package codeanticode.syphon;

import processing.core.*;
import processing.opengl2.*;
import jsyphon.*;

/**
 * This is a template class and can be used to start a new processing library or tool.
 * Make sure you rename this class as well as the name of the example package 'template' 
 * to your own lobrary or tool naming convention.
 * 
 * @example Hello 
 * 
 * (the tag @example followed by the name of an example included in folder 'examples' will
 * automatically include the example in the javadoc.)
 *
 */

public class Syphon {
	
	// myParent is a reference to the parent sketch
	PApplet myParent;
	PGraphicsOpenGL2 ogl2;

	int myVariable = 0;
	private JSyphonServer server;
	
	public final static String VERSION = "##version##";
	

	/**
	 * a Constructor, usually called in the setup() method in your sketch to
	 * initialize and start the library.
	 * 
	 * @example Hello
	 * @param theParent
	 */
	public Syphon(PApplet theParent) {
	  server=new JSyphonServer();
	  server.initWithName("df");
		myParent = theParent;
		ogl2 = (PGraphicsOpenGL2)myParent.g;		
		//welcome();
	}
	
  public void sendImage(PImage img) {
    PTexture tex = ogl2.getTexture(img);
    server.publishFrameTexture(tex.glID,tex.glTarget, 0, 0, tex.glWidth, tex.glHeight, tex.glWidth, tex.glHeight, false);
  }	
	
	private void welcome() {
		System.out.println("##name## ##version## by ##author##");
	}
	
	
	public String sayHello() {
		return "hello library.";
	}
	/**
	 * return the version of the library.
	 * 
	 * @return String
	 */
	public static String version() {
		return VERSION;
	}

	/**
	 * 
	 * @param theA
	 *          the width of test
	 * @param theB
	 *          the height of test
	 */
	public void setVariable(int theA, int theB) {
		myVariable = theA + theB;
	}

	protected PImage getTexture(PImage img) {
    //PTexture tex = (PTexture)img.getCache(ogl2);
    /*
    if (tex == null) {
      tex = addTexture(img);
    } else if (img.isModified()) {
      updateTexture(img, tex);
    }
    */
    //return tex;
	  
	  return null;
  }	
	
	/**
	 * 
	 * @return int
	 */
	public int getVariable() {
		return myVariable;
	}
}


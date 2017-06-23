//
//  Copyright (c) 2014 ULSee. All rights reserved.
//

attribute mediump vec4 position;
attribute mediump vec2 textureCoord;
varying mediump vec2 coordinate;
uniform mediump mat4 matrix; 

void main()
{
	gl_Position = matrix * position;
	coordinate = textureCoord;
}

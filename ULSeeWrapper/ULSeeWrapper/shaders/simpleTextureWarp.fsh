//
//  Copyright (c) 2014 ULSee. All rights reserved.
//

varying mediump vec2 coordinate;
uniform sampler2D textr;
uniform lowp float scaling;

void main()
{
	gl_FragColor = vec4(vec3(scaling),1.)*texture2D(textr, coordinate);
}



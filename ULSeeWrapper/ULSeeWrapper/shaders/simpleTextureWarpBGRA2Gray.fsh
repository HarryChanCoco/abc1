//
//  Copyright (c) 2014 ULSee. All rights reserved.
//

varying mediump vec2 coordinate;
uniform sampler2D textr;

const mediump vec4 cvt = vec4(0.299,0.587,0.114,0);
//const lowp vec4 cvt = vec4(0.35880, 0.70440, 0.13680,0);

void main()
{
	gl_FragColor = vec4(vec3(dot(cvt,texture2D(textr,coordinate))),1);
}

precision mediump float;           // Set the default precision to medium. We don't need as high of a 
                                // precision in the fragment shader.
uniform sampler2D u_TextureX;    // The input texture.
uniform sampler2D u_Texture2X;

varying vec3 v_Rotation;
varying vec3 v_Move;
varying vec2 v_mid;
varying vec2 v_scale;
  
varying vec3 v_PositionX;        // Interpolated position for this fragment.
varying vec4 v_ColorX;              // This is the color from the vertex shader interpolated across the 
varying vec2 v_TexCoordinateX;   // Interpolated texture coordinate per fragment.
varying vec2 v_TexCoordinate2X;
  
// The entry point for our fragment shader.
void main()                            
{
    vec2 rotated =
    vec2(cos(v_Rotation[2])*(v_TexCoordinate2X.x - v_mid.x)*v_scale.x + sin(v_Rotation[2])*(v_TexCoordinate2X.y - v_mid.y)*v_scale.y + v_mid.x,
         cos(v_Rotation[2])*(v_TexCoordinate2X.y - v_mid.y)*v_scale.y - sin(v_Rotation[2])*(v_TexCoordinate2X.x - v_mid.x)*v_scale.x + v_mid.y);
	
	rotated[0] = rotated[0] + 0.25 * v_Move[0];
	rotated[1] = rotated[1] + 0.25 * v_Move[1];
    
	vec4 pixelTop = v_ColorX * texture2D(u_TextureX, v_TexCoordinateX);
	vec4 pixelEnv = texture2D(u_Texture2X, rotated);
//    if( pixelTop[0] == 0.0 ) { pixelTop[0] = pixelEnv[0]; }
//    if( pixelTop[1] == 0.0 ) { pixelTop[1] = pixelEnv[1]; }
//    if( pixelTop[2] == 0.0 ) { pixelTop[2] = pixelEnv[2]; }
//    if( pixelTop[3] > 0.0  ) { pixelTop[3] = 0.5+(pixelTop[3]/2.0); }
//	pixelEnv[3] = pixelEnv[3] / sqrt(v_ColorX[3]);
    vec4 pixelRes = pixelTop;
    float fixValue = pixelTop[3]*0.3;
    if (pixelTop[3] > 0.0)
    {
        // 2014.07.10 NewWay modified. For change BGRA to RGBA.
        pixelRes[2] = (pixelTop[0] * (1.0-fixValue) ) + ( pixelEnv[0] * fixValue);
        pixelRes[1] = (pixelTop[1] * (1.0-fixValue) ) + ( pixelEnv[1] * fixValue);
        pixelRes[0] = (pixelTop[2] * (1.0-fixValue) ) + ( pixelEnv[2] * fixValue);
        
//        pixelRes[0] = pixelTop[0] + (abs(pixelTop[0]-pixelEnv[0]) * (1.0-pixelTop[3]));
//        pixelRes[1] = pixelTop[1] + (abs(pixelTop[1]-pixelEnv[1]) * (1.0-pixelTop[3]));
//        pixelRes[2] = pixelTop[2] + (abs(pixelTop[2]-pixelEnv[2]) * (1.0-pixelTop[3]));
        
//        // 2014.09.02. Add the shader modified by Vincent. For the indoor environment map picture.
//        pixelRes[2] = (pow(pixelEnv[0],5.0)*v_ColorX[3] + pixelTop[0]*(1.0-v_ColorX[3]))*pixelTop[3];
//        pixelRes[1] = (pow(pixelEnv[1],5.0)*v_ColorX[3] + pixelTop[1]*(1.0-v_ColorX[3]))*pixelTop[3];
//        pixelRes[0] = (pow(pixelEnv[2],5.0)*v_ColorX[3] + pixelTop[2]*(1.0-v_ColorX[3]))*pixelTop[3];
        
        pixelRes[3] = pixelTop[3];
    }
	//vec4 pixelRes = pixelTop * pixelEnv;
//	if( pixelEnv[0] > 0.95 && pixelEnv[1] > 0.95 && pixelEnv[2] > 0.95 && pixelEnv[3] > 0.95 )
//	{
//		if( pixelRes[3] > 0.05 )
//		{
//			if( v_ColorX[3] < 0.7 )
//			{
//				pixelRes[3] =  0.7 - (( 0.7-v_ColorX[3] ))/10.0;
//			}
//		}
//	}
    // Multiply the color by the diffuse illumination level and texture value to get final output color.
    gl_FragColor = pixelRes;                                          
}
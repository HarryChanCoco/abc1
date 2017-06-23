uniform mat4 u_MVPMatrixX;        // A constant representing the combined model/view/projection matrix.                     
//uniform mat4 u_MVMatrixX;        // A constant representing the combined model/view matrix.
                      
attribute vec4 a_PositionX;        // Per-vertex position information we will pass in.                   
attribute vec2 a_TexCoordinateX; // Per-vertex texture coordinate information we will pass in.
attribute vec2 a_TexCoordinate2X;

uniform vec4 a_ColorX;            // Per-vertex color information we will pass in.
uniform vec3 a_Rotation;
uniform vec3 a_Move;
uniform vec2 a_mid;
uniform vec2 a_scale;

//varying vec3 v_PositionX;        // This will be passed into the fragment shader.
varying vec4 v_ColorX;            // This will be passed into the fragment shader.                  
varying vec2 v_TexCoordinateX;   // This will be passed into the fragment shader.    
varying vec2 v_TexCoordinate2X;

varying vec3 v_Rotation;
varying vec3 v_Move;
varying vec2 v_mid;
varying vec2 v_scale;
          
// The entry point for our vertex shader.  
void main()                                                     
{                                                         
    // Transform the vertex into eye space.     
    //v_PositionX = vec3(u_MVMatrixX * a_PositionX);
        
    // Pass through the color.
    v_ColorX = a_ColorX;
    
    // Pass through the texture coordinate.
    v_TexCoordinateX = a_TexCoordinateX;
	v_TexCoordinate2X = a_TexCoordinate2X;
    
    v_Rotation = a_Rotation;
	v_Move = a_Move;
	v_mid = a_mid;
	v_scale = a_scale;

    
    // gl_Position is a special variable used to store the final position.
    // Multiply the vertex by the matrix to get the final point in normalized screen coordinates.
    gl_Position = u_MVPMatrixX * a_PositionX;                                 
}
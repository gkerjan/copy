precision mediump float;

/* #TODO GL3.2.3
	Setup the varying values needed to compue the Phong shader:
	* surface normal
	* view vector: direction to camera
*/
varying vec3 surface_normal;
varying vec3 view_vector;

uniform samplerCube cube_env_map;

void main()
{
	/*
	/* #TODO GL3.2.3: Mirror shader
	Calculate the reflected ray direction R and use it to sample the environment map.
	Pass the resulting color as output.
	*/
	vec3 r = reflect(view_vector, surface_normal);
	vec4 result = textureCube(cube_env_map, r); 
	vec3 color = result.xyz;
	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range

}

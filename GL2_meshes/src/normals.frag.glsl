precision mediump float;
		
/* #TODO GL2.2.1
	Pass the normal to the fragment shader by creating a varying vertex-to-fragment variable.
*/
varying vec3 vertex_to_fragment;

void main()
{
	/* #TODO GL2.2.1
	Visualize the normals as false color. 
	*/
	//vertex-to-fragment = vertex-to-fragment * 0.5 + 0.5; 
	vec3 color = normalize(vertex_to_fragment) * 0.5 + vec3(0.5);  //vec3(0., 0., 1.); // set the color from normals

	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range
}

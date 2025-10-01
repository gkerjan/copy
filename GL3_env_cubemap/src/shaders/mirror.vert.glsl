// Vertex attributes, specified in the "attributes" entry of the pipeline
attribute vec3 vertex_position;
attribute vec3 vertex_normal;

// Per-vertex outputs passed on to the fragment shader

/* #TODO GL3.2.3
	Setup the varying values needed to compue the Phong shader:
	* surface normal
	* view vector: direction to camera
*/
varying vec3 surface_normal;
varying vec3 view_vector;

// Global variables specified in "uniforms" entry of the pipeline
uniform mat4 mat_mvp;
uniform mat4 mat_model_view;
uniform mat3 mat_normals_to_view;


void main() {
	/** #TODO GL3.2.3:
	Setup all outgoing variables so that you can compute reflections in the fragment shader.
	You will need to setup all the varying variables listed above, before you
    can start coding this shader.

    Hint: Compute the vertex position and the normal in eye space.
    Hint: Write the final vertex position to gl_Position
    */
	// viewing vector (from camera to vertex in view coordinates), camera is at vec3(0, 0, 0) in cam coords
	//v2f_dir_to_camera = vec3(1, 0, 0); // TODO calculate
	// transform normal to camera coordinates
	//v2f_normal = normal; // TODO apply normal transformation
	
	surface_normal = normalize(mat_normals_to_view * vertex_normal);
	view_vector = normalize((mat_model_view * vec4(vertex_position, 1.)).xyz);

	gl_Position = mat_mvp * vec4(vertex_position, 1);
}




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

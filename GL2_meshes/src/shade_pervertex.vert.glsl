// Vertex attributes, specified in the "attributes" entry of the pipeline
attribute vec3 vertex_position;
attribute vec3 vertex_normal;

// Per-vertex outputs passed on to the fragment shader

/* #TODO GL2.3
	Pass the values needed for per-pixel illumination by creating a varying vertex-to-fragment variable.
*/
varying vec3 ppill;

// Global variables specified in "uniforms" entry of the pipeline
uniform mat4 mat_mvp;
uniform mat4 mat_model_view;
uniform mat3 mat_normals_to_view;

uniform vec3 light_position; // in camera space coordinates already

uniform vec3 material_color;
uniform float material_shininess;
uniform vec3 light_color;

void main() {
	float material_ambient = 0.1;
	/** #TODO GL2.3 Gouraud lighting
	Compute the visible object color based on the Blinn-Phong formula.

	Hint: Compute the vertex position, normal and light_position in view space. 
	*/

	// Vectors needed to apply Blinn-Phong lighting model
	vec3 n_vector = normalize(mat_normals_to_view * vertex_normal);
	vec3 l_vector = normalize(light_position - (mat_model_view * vec4(vertex_position, 1.)).xyz);
	vec3 v_vector = normalize((mat_model_view * vec4(vertex_position, 1.)).xyz);
	vec3 h_vector = normalize(l_vector - v_vector);

	vec3 material_a = material_color * material_ambient;
	vec3 diffuse_element = (material_color * dot(l_vector, n_vector));
	vec3 specular_element = material_color * pow(
		dot(h_vector, n_vector), material_shininess
	);

	vec3 ppill_building = vec3(0., 0., 0.);

	//Diffuse condition
	if (dot(n_vector, l_vector) > 0.) {
		ppill_building += diffuse_element;
	}

	//Specular condition
	if (dot(h_vector, n_vector) > 0. && dot(n_vector, l_vector) > 0.) {
		ppill_building += specular_element;
	}
	
	ppill = (light_color * material_a) + (light_color * ppill_building);

	gl_Position = mat_mvp * vec4(vertex_position, 1);
}

precision mediump float;

/* #TODO GL2.4
	Setup the varying values needed to compue the Phong shader:
	* surface normal
	* lighting vector: direction to light
	* view vector: direction to camera
*/
varying vec3 surface_normal;
varying vec3 lighting_vector;
varying vec3 view_vector;

uniform vec3 material_color;
uniform float material_shininess;
uniform vec3 light_color;

void main()
{
	float material_ambient = 0.1;

	/*
	/* #TODO GL2.4: Apply the Blinn-Phong lighting model

	Implement the Blinn-Phong shading model by using the passed
	variables and write the resulting color to `color`.

	Make sure to normalize values which may have been affected by interpolation!
	*/

	vec3 n_vector = normalize(surface_normal);
	vec3 l_vector = normalize(lighting_vector);
	vec3 v_vector = normalize(view_vector);
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
	
	vec3 ppill = (light_color * material_a) + (light_color * ppill_building);

	gl_FragColor = vec4(ppill, 1.); // output: RGBA in 0..1 range
}

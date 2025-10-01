precision highp float;

varying float v2f_height;

/* #TODO PG1.6.1: Copy Blinn-Phong shader setup from previous exercises */
varying vec3 surface_normal;
varying vec3 lighting_vector;
varying vec3 view_vector;


const vec3  light_color = vec3(1.0, 0.941, 0.898);
// Small perturbation to prevent "z-fighting" on the water on some machines...
const float terrain_water_level    = -0.03125 + 1e-6;
const vec3  terrain_color_water    = vec3(0.29, 0.51, 0.62);
const vec3  terrain_color_mountain = vec3(0.8, 0.5, 0.4);
const vec3  terrain_color_grass    = vec3(0.33, 0.43, 0.18);

void main()
{
	float material_ambient = 0.1; // Ambient light coefficient
	float height = v2f_height;

	/* #TODO PG1.6.1
	Compute the terrain color ("material") and shininess based on the height as
	described in the handout. `v2f_height` may be useful.
	
	Water:
			color = terrain_color_water
			shininess = 30.
	Ground:
			color = interpolate between terrain_color_grass and terrain_color_mountain, weight is (height - terrain_water_level)*2
	 		shininess = 2.
	*/
	
	vec3 material_color = terrain_color_grass;
	float shininess = 0.5;
	

	if (height > terrain_water_level){ 					// Groung
		shininess = 2.0; 
		float weight = 2.0 * (height - terrain_water_level); 
		material_color = mix(terrain_color_grass,terrain_color_mountain, weight);
	} else {												// Water
		material_color = terrain_color_water;
		shininess = 30.0; 
	}
	

	/* #TODO PG1.6.1: apply the Blinn-Phong lighting model
    	Add the Blinn-Phong implementation from GL2 here.
	*/
	vec3 n_vector = normalize(surface_normal);
	vec3 l_vector = normalize(lighting_vector);
	vec3 v_vector = normalize(view_vector);
	vec3 h_vector = normalize(l_vector - v_vector);

	vec3 material_a = material_color * material_ambient;
	vec3 diffuse_element = (material_color * dot(l_vector, n_vector));
	vec3 specular_element = material_color * pow(
		dot(h_vector, n_vector), shininess
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

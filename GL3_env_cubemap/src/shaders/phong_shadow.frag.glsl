
	/* #TODO GL3.1.1
	Sample texture tex_color at UV coordinates and display the resulting color.
	*/
	vec3 material_color = texture2D(tex_color, v2f_uv).xyz;
	
	/*
	#TODO GL3.3.1: Blinn-Phong with shadows and attenuation
	

	Compute this light's diffuse and specular contributions.
	You should be able to copy your phong lighting code from GL2 mostly as-is,
	though notice that the light and view vectors need to be computed from scratch here; 
	this time, they are not passed from the vertex shader. 
	Also, the light/material colors have changed; see the Phong lighting equation in the handout if you need
	a refresher to understand how to incorporate `light_color` (the diffuse and specular
	colors of the light), `v2f_diffuse_color` and `v2f_specular_color`.
	
	To model the attenuation of a point light, you should scale the light
	color by the inverse distance squared to the point being lit.
	
	The light should only contribute to this fragment if the fragment is not occluded
	by another object in the scene. You need to check this by comparing the distance
	from the fragment to the light against the distance recorded for this
	light ray in the shadow map.
	
	To prevent "shadow acne" and minimize aliasing issues, we need a rather large
	tolerance on the distance comparison. It's recommended to use a *multiplicative*
	instead of additive tolerance: compare the fragment's distance to 1.01x the
	distance from the shadow map.

	Implement the Blinn-Phong shading model by using the passed
	variables and write the resulting color to `color`.

	Make sure to normalize values which may have been affected by interpolation!
	*/    
	
    vec3 n_vector = normalize(normal_pos_in_cam_coord);
    vec3 l_vector = normalize(light_position - frag_pos_in_cam_coord);
    vec3 v_vector = normalize(frag_pos_in_cam_coord);
    vec3 h_vector = normalize(l_vector - v_vector);

	vec3 material_a = material_color * material_ambient;
	vec3 diffuse_element = (material_color * dot(l_vector, n_vector));
	vec3 specular_element = material_color * pow(dot(h_vector, n_vector), material_shininess);

	vec3 ppill_diffuse = vec3(0., 0., 0.);
	
	float bruh = textureCube(cube_shadowmap, normalize(frag_pos_in_cam_coord - light_position)).z;
	vec3 in_shadow = vec3(0.,0.,0.); 
	if (length(frag_pos_in_cam_coord - light_position) < bruh * 1.01 ){
		in_shadow =  vec3(1.,1.,1.);
	}

	vec3 ppill_building = vec3(0., 0., 0.);

	//Diffuse condition
	if (dot(n_vector, l_vector) > 0.) {
		ppill_building += diffuse_element;
	}

	//Specular condition
	if (dot(h_vector, n_vector) > 0. && dot(n_vector, l_vector) > 0.) {
		ppill_building += specular_element;
	}
	
	float attenuation_factor = length(light_position - frag_pos_in_cam_coord) * length(light_position - frag_pos_in_cam_coord);

	vec3 shadow = in_shadow * light_color * (ppill_building / attenuation_factor);
	vec3 result = (light_color * material_a)  + shadow;
	
	gl_FragColor = vec4(result, 1.); // output: RGBA in 0..1 range
}



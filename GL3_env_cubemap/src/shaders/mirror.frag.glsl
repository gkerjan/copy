precision
	vec3 r = reflect(view_vector, surface_normal);
	vec4 result = textureCube(cube_env_map, r); 
	vec3 color = result.xyz;
	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range

}

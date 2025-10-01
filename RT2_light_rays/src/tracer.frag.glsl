precision highp float;

#define MAX_RANGE 1e6
//#define NUM_REFLECTIONS

//#define NUM_SPHERES
#if NUM_SPHERES != 0
uniform vec4 spheres_center_radius[NUM_SPHERES]; // ...[i] = [center_x, center_y, center_z, radius]
#endif

//#define NUM_PLANES
#if NUM_PLANES != 0
uniform vec4 planes_normal_offset[NUM_PLANES]; // ...[i] = [nx, ny, nz, d] such that dot(vec3(nx, ny, nz), point_on_plane) = d
#endif

//#define NUM_CYLINDERS
struct Cylinder {
	vec3 center;
	vec3 axis;
	float radius;
	float height;
};
#if NUM_CYLINDERS != 0
uniform Cylinder cylinders[NUM_CYLINDERS];
#endif

#define SHADING_MODE_NORMALS 1
#define SHADING_MODE_BLINN_PHONG 2
#define SHADING_MODE_PHONG 3
//#define SHADING_MODE

// materials
//#define NUM_MATERIALS
struct Material {
	vec3 color;
	float ambient;
	float diffuse;
	float specular;
	float shininess;
	float mirror;
};
uniform Material materials[NUM_MATERIALS];
#if (NUM_SPHERES != 0) || (NUM_PLANES != 0) || (NUM_CYLINDERS != 0)
uniform int object_material_id[NUM_SPHERES+NUM_PLANES+NUM_CYLINDERS];
#endif

/*
	Get the material corresponding to mat_id from the list of materials.
*/
Material get_material(int mat_id) {
	Material m = materials[0];
	for(int mi = 1; mi < NUM_MATERIALS; mi++) {
		if(mi == mat_id) {
			m = materials[mi];
		}
	}
	return m;
}

// lights
//#define NUM_LIGHTS
struct Light {
	vec3 color;
	vec3 position;
};
#if NUM_LIGHTS != 0
uniform Light lights[NUM_LIGHTS];
#endif
uniform vec3 light_color_ambient;


varying vec3 v2f_ray_origin;
varying vec3 v2f_ray_direction;

/*
	Solve the quadratic a*x^2 + b*x + c = 0. The method returns the number of solutions and store them
	in the argument solutions.
*/
int solve_quadratic(float a, float b, float c, out vec2 solutions) {

	// Linear case: bx+c = 0
	if (abs(a) < 1e-12) {
		if (abs(b) < 1e-12) {
			// no solutions
			return 0; 
		} else {
			// 1 solution: -c/b
			solutions[0] = - c / b;
			return 1;
		}
	} else {
		float delta = b * b - 4. * a * c;

		if (delta < 0.) {
			// no solutions in real numbers, sqrt(delta) produces an imaginary value
			return 0;
		} 

		// Avoid cancellation:
		// One solution doesn't suffer cancellation:
		//      a * x1 = 1 / 2 [-b - bSign * sqrt(b^2 - 4ac)]
		// "x2" can be found from the fact:
		//      a * x1 * x2 = c

		// We do not use the sign function, because it returns 0
		// float a_x1 = -0.5 * (b + sqrt(delta) * sign(b));
		float sqd = sqrt(delta);
		if (b < 0.) {
			sqd = -sqd;
		}
		float a_x1 = -0.5 * (b + sqd);


		solutions[0] = a_x1 / a;
		solutions[1] = c / a_x1;

		// 2 solutions
		return 2;
	} 
}

/*
	Check for intersection of the ray with a given sphere in the scene.
*/
bool ray_sphere_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		vec3 sphere_center, float sphere_radius, 
		out float t, out vec3 normal) 
{
	vec3 oc = ray_origin - sphere_center;

	vec2 solutions; // solutions will be stored here

	int num_solutions = solve_quadratic(
		// A: t^2 * ||d||^2 = dot(ray_direction, ray_direction) but ray_direction is normalized
		1., 
		// B: t * (2d dot (o - c))
		2. * dot(ray_direction, oc),	
		// C: ||o-c||^2 - r^2				
		dot(oc, oc) - sphere_radius*sphere_radius,
		// where to store solutions
		solutions
	);

	// result = distance to collision
	// MAX_RANGE means there is no collision found
	t = MAX_RANGE+10.;
	bool collision_happened = false;

	if (num_solutions >= 1 && solutions[0] > 0.) {
		t = solutions[0];
	}
	
	if (num_solutions >= 2 && solutions[1] > 0. && solutions[1] < t) {
		t = solutions[1];
	}

	if (t < MAX_RANGE) {
		vec3 intersection_point = ray_origin + ray_direction * t;
		normal = (intersection_point - sphere_center) / sphere_radius;

		return true;
	} else {
		return false;
	}
}

/*
	Check for intersection of the ray with a given plane in the scene.
*/
bool ray_plane_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		vec3 plane_normal, float plane_offset, 
		out float t, out vec3 normal) 
{
	t = MAX_RANGE + 10.;  // corresponds to no intersection, to be updated if one is found

	//create temporary values that will correspond to t and normal if an intersection is found
	float t_temp = 0.;
	vec3 normal_temp = vec3(0.);

	//if the ray and the plane are perpendicular, there will be no intersection
	if (dot(ray_direction, plane_normal) == 0.) {
		return false;
	}

	t_temp = (plane_offset - dot(ray_origin, plane_normal)) / (dot(ray_direction, plane_normal));
	normal_temp = normalize(plane_normal);

	//if the normal and the ray are going in the same direction, then flip the normal to point to the viewer
	if (dot(ray_direction, normal_temp) > 0.) {
		normal_temp = -normal_temp;
	}

	//if the distance is negative, there is no interaction in front of the viewer
	if (t_temp < 0.) {
		return false;
	}

	//assign temporary values to the outputs
	normal = normal_temp;
	t = t_temp;
	
	//return true because we know the interaction exists
	return true;
}

/*
	Check for intersection of the ray with a given cylinder in the scene.
*/
bool ray_cylinder_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		Cylinder cyl,
		out float t, out vec3 normal) 
{
	t = MAX_RANGE + 10.; // corresponds to no intersection, to be updated if one is found

	//to be sure we have a normalized axis
	cyl.axis = normalize(cyl.axis);
	
	//see RT1_theory/theory.md, coefficients of the quadratic equation (ax^2 + bx + c)
	float a = dot(ray_direction - (dot(ray_direction, cyl.axis) * cyl.axis), ray_direction - dot(ray_direction, cyl.axis) * cyl.axis);
	float b = 2. * dot(ray_direction - (dot(ray_direction, cyl.axis) * cyl.axis), ((ray_origin - cyl.center) - (cyl.axis * dot(ray_origin - cyl.center, cyl.axis))));
	float c = dot((ray_origin - cyl.center) - (cyl.axis * dot(ray_origin - cyl.center, cyl.axis)), 
		(ray_origin - cyl.center) - (cyl.axis * dot(ray_origin - cyl.center, cyl.axis))) - cyl.radius * cyl.radius;

	//solve the quadratic equation
	vec2 solutions;
	int num_sol = solve_quadratic(a, b, c, solutions);

	//create temporary values that will correspond to t and normal if an intersection is found
	float t_temp = 0.;
	vec3 normal_temp = vec3(0.);

	if (num_sol == 0) {
		//there is no intersection, return false
		return false;

	} else if (num_sol ==1) {
		//there is one intersection, check that its height is within the height of the cylinder and that the distance is positive
		//intersection point
		vec3 point = ray_origin + solutions[0] * ray_direction;

		float height = abs(dot(point - cyl.center, cyl.axis));
		bool exists = (height <= cyl.height/2. && solutions[0] > 0.);

		if (!exists) {
			//no interaction
			return false;
		}

		//assign t_temp and the normal
		t_temp = solutions[0];
		normal_temp = (((point - cyl.center) - ((dot((point - cyl.center), cyl.axis)) * cyl.axis))/ cyl.radius);
		
		//if the normal and the ray are going in the same direction, then flip the normal to point to the viewer
		if (dot(ray_direction, normal_temp ) > 0.) {
			normal_temp = -normal_temp;
		}

		//assign temporary values to the outputs
		normal = normal_temp;
		t = t_temp;
		
		//return true because we know the interaction exists
		return true;

	} else {
		//there are 2 interactions, check whether they are in the cylinder then check if the distance is positive
		vec3 point1 = ray_origin + solutions[0] * ray_direction;
		vec3 point2 = ray_origin + solutions[1] * ray_direction;

		//the interaction point we want
		vec3 p;

		float height1 = abs(dot(point1 - cyl.center, cyl.axis));
		float height2 = abs(dot(point2 - cyl.center, cyl.axis));

		bool exists1 = (height1 <= cyl.height/2. && solutions[0] > 0.);
		bool exists2 = (height2 <= cyl.height/2. && solutions[1] > 0.);

		if (exists1 && exists2) {
			if (solutions[0] < solutions[1]) {
				t_temp = solutions[0];
				p = point1;
			} else {
				t_temp = solutions[1];
				p = point2;
			}
		} else if (exists1) {
			t_temp = solutions[0];
			p = point1;
		} else if (exists2) {
			t_temp = solutions[1];
			p = point2;
		} else {
			//no interaction
			return false;
		}

		normal_temp = (((p - cyl.center) - ((dot((p - cyl.center), cyl.axis)) * cyl.axis))/ cyl.radius);
		
		//if the normal and the ray are going in the same direction, then flip the normal to point to the viewer
		if (dot(ray_direction, normal_temp ) > 0.) {
			normal_temp = -normal_temp;
		}

		//assign temporary values to the outputs
		normal = normal_temp;
		t = t_temp;
		
		//return true because we know the interaction exists
		return true;

	}

	//all the possible cases in which there is an interaction returned before this
	return false; 
}


/*
	Check for intersection of the ray with any object in the scene.
*/
bool ray_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		out float col_distance, out vec3 col_normal, out int material_id) 
{
	col_distance = MAX_RANGE + 10.;
	col_normal = vec3(0., 0., 0.);

	float object_distance;
	vec3 object_normal;

	// Check for intersection with each sphere
	#if NUM_SPHERES != 0 // only run if there are spheres in the scene
	for(int i = 0; i < NUM_SPHERES; i++) {
		bool b_col = ray_sphere_intersection(
			ray_origin, 
			ray_direction, 
			spheres_center_radius[i].xyz, 
			spheres_center_radius[i][3], 
			object_distance, 
			object_normal
		);

		// choose this collision if its closer than the previous one
		if (b_col && object_distance < col_distance) {
			col_distance = object_distance;
			col_normal = object_normal;
			material_id =  object_material_id[i];
		}
	}
	#endif

	// Check for intersection with each plane
	#if NUM_PLANES != 0 // only run if there are planes in the scene
	for(int i = 0; i < NUM_PLANES; i++) {
		bool b_col = ray_plane_intersection(
			ray_origin, 
			ray_direction, 
			planes_normal_offset[i].xyz, 
			planes_normal_offset[i][3], 
			object_distance, 
			object_normal
		);

		// choose this collision if its closer than the previous one
		if (b_col && object_distance < col_distance) {
			col_distance = object_distance;
			col_normal = object_normal;
			material_id =  object_material_id[NUM_SPHERES+i];
		}
	}
	#endif

	// Check for intersection with each cylinder
	#if NUM_CYLINDERS != 0 // only run if there are cylinders in the scene
	for(int i = 0; i < NUM_CYLINDERS; i++) {
		bool b_col = ray_cylinder_intersection(
			ray_origin, 
			ray_direction,
			cylinders[i], 
			object_distance, 
			object_normal
		);

		// choose this collision if its closer than the previous one
		if (b_col && object_distance < col_distance) {
			col_distance = object_distance;
			col_normal = object_normal;
			material_id =  object_material_id[NUM_SPHERES+NUM_PLANES+i];
		}
	}
	#endif

	return col_distance < MAX_RANGE;
}

/*
	Return the color at an intersection point given a light and a material, exluding the contribution
	of potential reflected rays.
*/
vec3 lighting(
		vec3 object_point, vec3 object_normal, vec3 direction_to_camera, 
		Light light, Material mat) {

	/** #TODO RT2.1: 
	- compute the diffuse component
	- make sure that the light is located in the correct side of the object
	- compute the specular component 
	- make sure that the reflected light shines towards the camera
	- return the ouput color

	You can use existing methods for `vec3` objects such as `reflect`, `dot`, `normalize` and `length`.
	*/

	

	/** #TODO RT2.2: 
	- shoot a shadow ray from the intersection point to the light
	- check whether it intersects an object from the scene
	- update the lighting accordingly
	*/

	//vectors to the light and to the light reflected
	vec3 l_vector_normalized = normalize(light.position - object_point);
	vec3 r_vector_normalized = normalize(reflect(l_vector_normalized, object_normal));

	//initialize the rgb light vector
	vec3 lighting_rgb = vec3(0., 0., 0.);
	

	#if SHADING_MODE == SHADING_MODE_PHONG
		// - Diffuse
		//check conditions
		if (dot(normalize(object_normal), l_vector_normalized) >= 0.){
			lighting_rgb = lighting_rgb + (mat.diffuse * dot(l_vector_normalized, normalize(object_normal)));
		}

		// - Specular
		//check conditions
		if (dot(r_vector_normalized, direction_to_camera) >= 0. && dot(object_normal, l_vector_normalized) >= 0.) {
			lighting_rgb = lighting_rgb + (mat.specular * pow(
					dot(r_vector_normalized, normalize(direction_to_camera)), mat.shininess
				));
		}

	#endif

	#if SHADING_MODE == SHADING_MODE_BLINN_PHONG
		vec3 h_vector = normalize(-direction_to_camera + l_vector_normalized);

		// - Diffuse
		//check conditions
		if (dot(normalize(object_normal), l_vector_normalized) >= 0.){
			lighting_rgb = lighting_rgb + (mat.diffuse * dot(l_vector_normalized, normalize(object_normal)));
		}

		// - Specular
		//check conditions
		if (dot(h_vector, normalize(object_normal)) >= 0. && dot(object_normal, l_vector_normalized) >= 0.) {
			lighting_rgb = lighting_rgb + (mat.specular * pow(
					dot(h_vector, normalize(object_normal)), mat.shininess
				));
		}
	#endif

	//initialize the output values of ray intersection
	float shadow = 1.;
	float col_distance = 0.;
	vec3 normal = vec3(0., 0., 0.);
	int material = 0;

	bool intersects = ray_intersection((object_point + 1e-6), l_vector_normalized, col_distance, normal, material);

	//check that the intersection returned true and that the distance of the collision is not too close and it is before the light
	if (intersects && col_distance >= 1e-3 && col_distance <= distance(object_point, light.position)) {
		shadow = 0.;
	}

	//return the lighting with the colors and the shadow boolean
	return lighting_rgb * light.color * mat.color * shadow;
}  

/*
Render the light in the scene using ray-tracing!
*/
vec3 render_light(vec3 ray_origin, vec3 ray_direction) {

	/** #TODO RT2.1: 
	- check whether the ray intersects an object in the scene
	- if it does, compute the ambient contribution to the total intensity
	- compute the intensity contribution from each light in the scene and store the sum in pix_color
	*/

	/** #TODO RT2.3.2: 
	- create an outer loop on the number of reflections (see below for a suggested structure)
	- compute lighting with the current ray (might be reflected)
	- use the above formula for blending the current pixel color with the reflected one
	- update ray origin and direction

	We suggest you structure your code in the following way:

	vec3 pix_color          = vec3(0.);
	float reflection_weight = ...;

	for(int i_reflection = 0; i_reflection < NUM_REFLECTIONS+1; i_reflection++) {
		float col_distance;
		vec3 col_normal = vec3(0.);
		int mat_id      = 0;

		if(ray_intersection(ray_origin, ray_direction, col_distance, col_normal, mat_id)) {
			Material m = get_material(mat_id); // get material of the intersected object

			...

			ray_origin        = ...;
			ray_direction     = ...;
			reflection_weight = ...;
		}
	}
	*/

	//initialize the pixel color and the weight of the reflexion
	vec3 pix_color = vec3(0.);
	float reflection_weight = 1.;

	//do a loop for all the reflexions wanted
	for(int i_reflection = 0; i_reflection < NUM_REFLECTIONS+1; i_reflection++) {

		//initialize output values for ray intersections
		float col_distance;
		vec3 col_normal = vec3(0., 0., 0.);
		int mat_id = 0;

		//if there is a collision, then reflect
		bool collision = ray_intersection((ray_origin + 1e-3*ray_direction), ray_direction, col_distance, col_normal, mat_id);

		if(collision && col_distance >= 1e-6) {

			Material m = get_material(mat_id); // get material of the intersected object

			//initialize the color of what we intersect with ambient light
			vec3 coloractual = light_color_ambient * m.ambient * m.color;; 

			//update ray origin
			ray_origin = ray_origin + col_distance * normalize(ray_direction);

			#if NUM_LIGHTS != 0
				for(int i_light = 0; i_light < NUM_LIGHTS; i_light++) {
					//for each light go get diffuse, specular and shadows
					coloractual = coloractual + lighting(ray_origin, col_normal, ray_direction, lights[i_light], m);
				}
			#endif

			//update the general pixel color with the weighted color of what we intersected
			pix_color += (1. - m.mirror) *  reflection_weight * coloractual; 

			//update ray direction and reflexion weight
			ray_direction = reflect(ray_direction, col_normal);
			reflection_weight = reflection_weight * m.mirror; 
			
		}
	}

	//return the color for this pixel
	return pix_color;
}


/*
	Draws the normal vectors of the scene in false color.
*/
vec3 render_normals(vec3 ray_origin, vec3 ray_direction) {
	float col_distance;
	vec3 col_normal = vec3(0.);
	int mat_id = 0;

	if( ray_intersection(ray_origin, ray_direction, col_distance, col_normal, mat_id) ) {	
		return 0.5*(col_normal + 1.0);
	} else {
		vec3 background_color = vec3(0., 0., 1.);
		return background_color;
	}
}


void main() {
	vec3 ray_origin = v2f_ray_origin;
	vec3 ray_direction = normalize(v2f_ray_direction);

	vec3 pix_color = vec3(0.);

	#if SHADING_MODE == SHADING_MODE_NORMALS
	pix_color = render_normals(ray_origin, ray_direction);
	#else
	pix_color = render_light(ray_origin, ray_direction);
	#endif

	gl_FragColor = vec4(pix_color, 1.);
}


import * as vec3 from "../lib/gl-matrix_3.3.0/esm/vec3.js"

function get_vert(mesh, vert_id) {
	const offset = vert_id*3
	return  mesh.vertex_positions.slice(offset, offset+3)
}

function compute_triangle_normals_and_angle_weights(mesh) {

	/** #TODO GL2.1.1: 
	- compute the normal vector to each triangle in the mesh
	- push it into the array `tri_normals`
	- compute the angle weights for vert1, vert2, then vert3 and store it into an array [w1, w2, w3]
	- push this array into `angle_weights`

	Hint: you can use `vec3` specific methods such as `normalize()`, `add()`, `cross()`, `angle()`, or `subtract()`.
		  The absolute value of a float is given by `Math.abs()`.
	*/
	/*let arraynormal; //tableau qui comporte chaque vecteur normal de chaque triangle...
	for (let i = 0; i < mesh.faces.length; ++i ) { // boucle popur calculer chaque elements des triangles 3 par 3
		let currenttriangle = mesh.faces[i]; 
		let a = get_vert(mesh, currenttriangle[0]);  
		let b = get_vert(mesh, currenttriangle[1]);  
		let c = get_vert(mesh, currenttriangle[2]);  

		const bminusa = vec3.subtract(vec3.create(), b, a);
		const cminusa = vec3.subtract(vec3.create(), c, a);

		let normalcurrenttriangle = normalize(vec3.cross([0.,0.,0.], bminusa, cminusa));

		arraynormal.push(normalcurrenttriangle);
	}*/

	const num_faces     = (mesh.faces.length / 3) | 0
	const tri_normals   = []
	const angle_weights = []

	for(let i_face = 0; i_face < num_faces; i_face++) {
		const vert1 = get_vert(mesh, mesh.faces[3*i_face + 0])
		const vert2 = get_vert(mesh, mesh.faces[3*i_face + 1])
		const vert3 = get_vert(mesh, mesh.faces[3*i_face + 2])
		
		// Modify the way triangle normals and angle_weights are computed
		const bminusa = vec3.subtract(vec3.create(), vert2, vert1)
		const cminusa = vec3.subtract(vec3.create(), vert3, vert1)
		const cminusb = vec3.subtract(vec3.create(), vert3, vert2)

		const cross = vec3.cross([0.,0.,0.], bminusa, cminusa)

		let normalcurrenttriangle = vec3.normalize(vec3.create(), cross)

		tri_normals.push(normalcurrenttriangle)

		/*const angle1 = vec3.angle(vert1, vert2)
		const angle2 = vec3.angle(vert2, vert3)
		const angle3 = vec3.angle(vert3, vert1)*/ // MODIFICATION APRES RENDU (01/04)

		const angle1 = vec3.angle(bminusa, cminusa)
		const angle2 = vec3.angle(cminusb, vec3.negate(vec3.create(), bminusa))
		const angle3 = Math.PI - (angle1 + angle2)

		angle_weights.push([angle1, angle2, angle3])
	}
	return [tri_normals, angle_weights]
}

function compute_vertex_normals(mesh, tri_normals, angle_weights) {

	/** #TODO GL2.1.2: 
	- go through the triangles in the mesh
	- add the contribution of the current triangle to its vertices' normal
	- normalize the obtained vertex normals
	*/

	const num_faces    = (mesh.faces.length / 3) | 0
	const num_vertices = (mesh.vertex_positions.length / 3) | 0
	const vertex_normals = Array.from({length: num_vertices}, () => [0., 0., 0.]) // fill with 0 vectors

	for(let i_face = 0; i_face < num_faces; i_face++) {
		const iv1 = mesh.faces[3*i_face + 0]
		const iv2 = mesh.faces[3*i_face + 1]
		const iv3 = mesh.faces[3*i_face + 2]

		const normal = tri_normals[i_face]

		const anglew = angle_weights[i_face]

		const s1 = vec3.scale([0.,0.,0.],normal,anglew[0])
		const s2 = vec3.scale([0.,0.,0.],normal,anglew[1])
		const s3 = vec3.scale([0.,0.,0.],normal,anglew[2])

		vertex_normals[iv1] = vec3.add([0.,0.,0.],vertex_normals[iv1], s1)
		vertex_normals[iv2] = vec3.add([0.,0.,0.],vertex_normals[iv2], s2)
		vertex_normals[iv3] = vec3.add([0.,0.,0.],vertex_normals[iv3], s3)
		// Add your code for adding the contribution of the current triangle to its vertices' normals

	}

	for(let i_vertex = 0; i_vertex < num_vertices; i_vertex++) {
		// Normalize the vertices
		vertex_normals[i_vertex] = vec3.normalize([0.,0.,0.],vertex_normals[i_vertex]);
	}

	return vertex_normals
}

export function mesh_preprocess(regl, mesh) {
	const [tri_normals, angle_weights] = compute_triangle_normals_and_angle_weights(mesh)
			
	const vertex_normals = compute_vertex_normals(mesh, tri_normals, angle_weights)

	mesh.vertex_positions = regl.buffer({data: mesh.vertex_positions, type: 'float32'})
	mesh.vertex_normals = regl.buffer({data: vertex_normals, type: 'float32'})
	mesh.faces = regl.elements({data: mesh.faces, type: 'uint16'})

	return mesh
}

# Solution Description

Firstly, we completed the compute_triangle_normals_and_angle_weights() method by using the concepts seen in class. Then, we completed the compute_vertex_normals() method.
After that, we compute the model-view-projection mat_mvp matrix, we pass it in the "Normals" shader. And, after that, we calculate mat_mvp, mat_model_view and mat_normals_to_view, by using the matrices given.
As for the Gouraud shading, we simply applied the Blinn-Phong lighting model per vertices, and to apply it, we calculate all the various values with the matrices in the -.vert.glsl, as to apply to each vertex. 
As for the Per-Pixel Shading, we did the same, but by passing the values from -.vert.glsl to -.frag.glsl, as to apply to every pixel.

# Contributions

Gersende Kerjan (358305): 18/54

Claire Chaffard (358435): 123/369

Ardi Cerkini (357121): 2/6
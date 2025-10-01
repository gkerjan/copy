# Solution Description

We first started by sampling the given texture in unshaded.frag.glsl, and correctly adapt it in scene.js by setting the wrapping mode to "repeat".
As for the init_capture function asked in GL3.2.1, we created a matrix with the "mat4.perspective", similar to what was hinted in the handout. We choose PI/2 as the field-of-view angle, and 1 for the aspect ratio (since we are talking about a cube). As for the CUBE_FACE_UP vectors in env_capture.js, we adapted the given vectors to represent each face of the cube.
As for the reflection shader, we adapted our solution for GL2 for this situation, as to pass the vectors for the frag.glsl. We then calculate the r vector with the textuerCube() method.
For the shadows, we implemented the Blinn-Phong Lighting by readapting what we did in GL2 in the per_pixel lighting. We adapted it by using the shadow-map cube.

# Contributions

Gersende Kerjan (358305): 1/3

Claire Chaffard (358435): 1/3

Ardi Cerkini (357121): 1/3
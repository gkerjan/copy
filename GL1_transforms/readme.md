# Solution Description

We started by each doing the tutorial on the GPU Pipeline on our side. Then, after this, we started the first task (GL1.1.1) by adding the mouse_offset already defined and implementing it in the vertex shader code and in the regl.frame() call.

After that, for GL1.1.2, with the mat4 library, we created two transformation matrix by multiplying the matrix for translation and the matrix for rotation. For the red triangle, we get the transformation by first applying the rotation matrix, then the translation matrix. Which means that the Rotation-Translation transformation matrix is the matrix of rotation multiplied with the matrix of translation. For the green triangle, it's the other way around. It's the translation matrix multiplied with the rotation matrix.

For GL1.2.1, in unshaded.vert.glsl, we apply the transform matrix by simply multiplying the said matrix with the vector of position, with the value 1 added to the last dimension for it to be an homogenous vector in dimension 4. As for calulcating he MVP matrix, we applied the formula given in the homework in planet.js with the mat4 library. To get mat_mvp,we simply multiply the Projection matrix, the view matrix and the model matrix given by the actor with actor.mat_model_to_world.

As for GL1.2.2, we use the mat4.lookAt() method for generating the view matrix. For calculating the position of the camera, we translate the spherical coordinates of the camera to cartesian coordinates.

For GL1.2.3, we created two helper matrix, one for rotation, the other for scaling, and then, with taking care of the orbits of each parent, we can calculate the position of our planet, and then we applied them in the right order to the transformation matrix for the actor.mat_model_to_world. And thanks to all that we can observe our system with all the planet with their own size and rotate like it should around their own parent. 

# Contributions

Gersende Kerjan (358305): 1/3

Claire Chaffard (358435): 1/3

Ardi Cerkini (357121): 1/3
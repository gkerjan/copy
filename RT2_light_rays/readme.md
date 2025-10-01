# Solution Description

We started by implementing the Phong and Blinn-Phong lightings by following the formulas given in the handout and using the conditions to check that the light is not on the other side of the object that we have seen during the lectures.
We then implemented the shadows by creating a shadows value that is equal to 0 if the ray shot from the object intersects anothe object before the light, and 1 otherwise. This shadow multiplies the diffuse and specular lighting values, such that if it is 0, there will only be ambient light on that object. We avoided shadow acne by offsetting the object point a little bit and then checking that if an intersection point is found, it is not too close.
For the exercise of the reflexions, we used a substitution method to prove the explicit formula of the recursive one that was given.
To implement them, we implemented the explicit formula we proved in the exercise, fixed problems we had found in our previous ray-cylinder interaction function and integrated the ambient lighting into the loop for all the reflexions.

# Contributions

Ardi Cerkini (357121): 1/3

Claire Chaffard (358435): 1/3

Gersende Kerjan (358305): 1/3
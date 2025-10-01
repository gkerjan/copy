# Solution Description

For the first task, we started by thinking on paper to understand and visualize how the Ray-Plane Intersection works. After founding a possible solution at our problem, we apply it to the example given in the handout. Since we found a correct result, we started to implement the function. We first check if the ray and the plane are not parallel, and then we apply the solution of our equation on t. After we initialize t and normal, we apply a condition on the normal in order to respect the view of the user. We test our function thanks to the test scenes where we made some modifications to observe the different responses of our code. 

For the second task, after working on the equation of the intersection between a ray and a cylinder. Thanks to the diagram and the course we had about Ray-Surface Intersection, we could see how to simplify the reasoning. For example, thanks to this equality : 

$$
\begin{equation}
||a||^2 = <a,a>
\end{equation}
$$

we could simplify our computation to a quadratic equation. And then, after we found a logical result and applied to the example given. We started to implement it on our function and use a different function given to find the different solutions of the quadratic equation. At the end we could observe the different cylinders in the different tests scenes.

# Contributions

Ardi Cerkini (357121): 1/3

Claire Chaffard (358435): 1/3

Gersende Kerjan (358305): 1/3
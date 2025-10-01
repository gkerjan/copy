---
title: Theory Exercise RT2 – Lighting and Light Rays
---

# Theory Exercise Homework 2 (RT2)

## Lighting and Light Rays

### Derivation of the Iterative Formula

We start by knowing the relation between the resulting color for a given pixel c<sub>b</sub> and the color at first intersection without reflections c<sub>0</sub>, and the color c<sup>1</sup> due to further reflection. This relation is : 

$$
\begin{equation}
c_b = (1 - \alpha_0 )c_0 + \alpha_0 c^1
\end{equation}
$$

With &alpha;<sub>0</sub> who represents how reflective the first material we intersect is. 

Recursively, we know this relation for c<sub>1</sub> : 

$$
\begin{equation}
c^1 = (1 - \alpha_1 )c_1 + \alpha_1 c^2
\end{equation}
$$

Then we can generalize this equation for k, any integer : 

$$
\begin{equation}
c^k = (1 - \alpha_k )c_k + \alpha_k c^{k+1}
\end{equation}
$$

If we substitute this equation into equation (1), we will get something that looks like this equation : 

$$
\begin{equation}
c^b  = (1 - \alpha_0 )c_0 + \alpha_0 ( (1 - \alpha_1 )c_1 + \alpha_1 (\dots \alpha_{k-1}((1 - \alpha_k )c_k + \alpha_k c^{k+1})) \dots )
\end{equation}
$$

We notice here a repetition of a pattern in the form of : 

$$
\begin{equation}
(1 - \alpha_i ) (\prod_{k=0}^{i -1}  \alpha_k) c^i
\end{equation}
$$

Thus, by induction, we can then assume the following expression, as it tends to infinity : 

$$
\begin{equation}
c_b = \sum_{i=0}^{\infty} (1 - \alpha_i ) (\prod_{k=0}^{i -1}  \alpha_k) c_i

\end{equation}
$$


### Simplification for $N$ Reflections

We consider at most N reflections. If we suppose the (6) expression correct, since the sum tends to infinity, we can conclude that the formula for up to N is also correct. 

It can be verified by induction to ensure the formula stays consistent.
Suppose that for n, we have the following property : 

$$
\begin{equation}
c_b = \sum_{i=0}^{n} (1 - \alpha_i ) (\prod_{k=0}^{i -1}  \alpha_k) c_i
\end{equation}
$$

We know that : 

$$
\begin{equation}
c_n = (1 - \alpha_n)c_n + \alpha_n c^{n+1}
\end{equation}
$$

By replacing c<sub>n</sub> in (7) with its expression in terms of  c<sub>n+1</sub>  , we obtain : 

$$
\begin{equation}
c_b = \sum_{i=0}^{n-1} (1 - \alpha_i ) (\prod_{k=0}^{i -1}  \alpha_k) c_i + (\prod_{k=0}^{n -1}  \alpha_k)((1 - \alpha_n)  c_n + \alpha_n c^{n+1})
\end{equation}
$$

Now, we recognize the structure of the additional term in the sum, which allows us to generalize the formula to : 

$$
\begin{equation}
c_b = \sum_{i=0}^{n+1} (1 - \alpha_i ) (\prod_{k=0}^{i -1}  \alpha_k) c_i
\end{equation}
$$


Conclusion

We have demonstrated by induction that the formula remains valid for any value of N, which confirms our expression for the resulting color while considering a finite number of reflections.





 



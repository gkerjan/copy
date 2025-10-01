precision mediump float;
    
uniform vec3 color;
varying vec3 pixel_color; 

void main() {
    // [R, G, B, 1]
    gl_FragColor = vec4(pixel_color, 1.); // output: RGBA in 0..1 range
}
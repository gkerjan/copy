attribute vec2 position;
attribute vec3 color;

varying vec3 pixel_color; 

void main() {
    // [x, y, 0, 1]
    pixel_color = color;
    gl_Position = vec4(position, 0, 1);
}
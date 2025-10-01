import {createREGL} from "../../lib/regljs_2.1.0/regl.module.js"

const regl = createREGL();

const draw_triangle = regl({

    // Vertex attributes - properties of each vertex such as 
    // position, normal, texture coordinates, etc.
    attributes: {
        // 3 vertices with 2 coordinates each
        position: [
            [0, 0.2], // [x, y] - vertex 0
            [-0.2, -0.2], // [x, y] - vertex 1
            [0.2, -0.2], // [x, y] - vertex 2
        ],
        color: [
            [1, 0, 0], //r
            [0, 1, 0], //g
            [0, 0, 1], //b
        ],
    },

    // Triangles (faces), as triplets of vertex indices
    elements: [
        [0, 1, 2], // a triangle
    ],
    
    // Uniforms: global data available to the shader
    uniforms: {
        color: regl.prop('color'),
    },

    /* 
    Vertex shader program
    Given vertex attributes, it calculates the position of the vertex on screen
    and intermediate data ("varying") passed on to the fragment shader
    */
    vert: await (await fetch('./src/shaders/idk.vert.glsl')).text(),
    
    /* 
    Fragment shader program
    Calculates the color of each pixel covered by the mesh.
    The "varying" values are interpolated between the values 
    given by the vertex shader on the vertices of the current triangle.
    */
    frag: await (await fetch('./src/shaders/idk.frag.glsl')).text(),
});

// Function run to draw each frame
regl.frame((frame) => {
    // Reset the canvas to black
    regl.clear({color: [0, 0, 0, 1]});
        
    // Execute the declared pipeline
    draw_triangle({
        color: [1, 0, 0], // provide the value for regl.prop('color') in uniforms.
    })
});

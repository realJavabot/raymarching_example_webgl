precision mediump float;

attribute vec4 vertex_pos;
varying vec3 fragment_pos;

void main() {
  gl_Position = vertex_pos;
  fragment_pos = gl_Position.xyz;
}
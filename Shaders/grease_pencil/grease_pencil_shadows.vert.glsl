#version 450

#ifdef GL_ES
precision highp float;
#endif

in vec3 pos;
in vec4 col;

uniform mat4 LWVP;

void main() {
	gl_Position = LWVP * vec4(pos.xyz, 1.0);
}

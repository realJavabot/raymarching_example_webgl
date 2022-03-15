precision highp float;

uniform float aspect_ratio;

varying vec3 fragment_pos;

const float bias = .0001;
const float max_ray_length = 10000.;
const vec3 sphere_pos = vec3(0,0,10);
const float sphere_radius = .8;
const vec3 background_color = vec3(.066);

float sdSphere(vec3 p, float s){
  return length(p)-s;
}

void main(void) {
  // the ray is cast from the position of the pixel it renders
  // which, given that the camera is at origin (0,0,0), is at (x,y,0) where the pixel is at coordinate (x,y).
  // The starting length decides the near-plane clipping distance
  vec3 ray_origin = fragment_pos * vec3(aspect_ratio, 1, 1);
  vec3 ray_direction = vec3(0,0,1);
  float ray_current_length = 1.;
  
  vec3 color = background_color;

  for(int i=0; i<255; i++){
    // the point the ray casts to is offset so the sphere can be positioned further away from the camera
    float distanceFromSDF = sdSphere(ray_origin + ray_direction * ray_current_length - sphere_pos, sphere_radius);

    // there needs to be a small bias, otherwise floating point arithmatic results in a lot of noise
    if(distanceFromSDF <= bias){
      color = vec3(1.,0.,0.);
      break;
    }

    ray_current_length += distanceFromSDF;

    if(ray_current_length >= max_ray_length){
      break;
    }
  }

  gl_FragColor = vec4(color, 1.0);
}
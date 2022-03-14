precision mediump float;

uniform float aspect_ratio;

varying vec3 fragment_pos;

const float bias = .0001;
const float max_ray_length = 10000.;
const float sphere_radius = .4;
const vec3 sphere_pos1 = vec3(-1,.5,10);
const vec3 sphere_pos2 = vec3(-.5,.5,10);
const vec3 background_color = vec3(.066);
const float PI = 3.14;

float sdSphere(vec3 p, float s){
  return length(p)-s;
}

float sdf_union(vec3 p){
  // minimum returns the closest volume, therefore combining volumes
  return min(sdSphere(p - sphere_pos1, sphere_radius), sdSphere(p - sphere_pos2, sphere_radius));
}

float sdf_intersect(vec3 p){
  vec3 offset = vec3(0,-1,0);

  // maximum returns the further surface. The surface still needs to be intersected by the ray to be negative, so this
  // really offers a cross-section view of the intersection between volumes
  return max(sdSphere(p - sphere_pos1 - offset, sphere_radius), sdSphere(p - sphere_pos2 - offset, sphere_radius));
}

float sdf_smoothed(vec3 p){
  vec3 offset = vec3(1.5,0,0);

  float d1 = sdSphere(p - sphere_pos1 - offset, sphere_radius);
  float d2 = sdSphere(p - sphere_pos2 - offset, sphere_radius);

  // as d1 and d2 approach zero, x gets very large. This is done smoothly, so we need to multiply by
  // a very small value so the gap doesn't "fill" too much
  float x = 1./abs(max(d1,d2));
  return min(d1,d2) - (.001 * x);
}

float sdf_difference(vec3 p){
  vec3 offset = vec3(1.5,-1,0);

  float d1 = sdSphere(p - sphere_pos1 - offset, sphere_radius);
  float d2 = sdSphere(p - sphere_pos2 - offset - vec3(-.3,0,.2), sphere_radius+.1);

  // To only get the negative (inner) part of the volume it is clamped. When subtracting the negative part
  // with the other volume, the clamped volume "subtracts" from the other volume, forming a hole.
  return d2 - clamp(d1, -1000., 0.);
}

float sdf(vec3 p){
  return min(sdf_union(p), min(sdf_intersect(p), min(sdf_smoothed(p), sdf_difference(p))));
}

vec3 GetSurfaceNormal(vec3 p)
{
    float d0 = sdf(p);
    const vec2 epsilon = vec2(.0001,0);
    vec3 d1 = vec3(
      sdf(p+epsilon.xyy),
      sdf(p+epsilon.yxy),
      sdf(p+epsilon.yyx)
    );
    return normalize(d1 - d0);
}

void main(void) {
  vec3 ray_origin = fragment_pos * vec3(aspect_ratio, 1, 1);
  vec3 ray_direction = vec3(0,0,1);
  float ray_current_length = 0.1;

  vec3 color = background_color;

  for(int i=0; i<255; i++){
    vec3 point = ray_origin + ray_direction * ray_current_length;
    float distanceFromSDF = sdf(point);
    if(distanceFromSDF <= bias){
      vec3 diffuse = vec3(.2);
      vec3 point_light = vec3(dot(GetSurfaceNormal(point), vec3(1,1,-1))) * .2;
      vec3 ambient = vec3(.1,.1,.1);

      color = diffuse + point_light + ambient;

      break;
    }

    ray_current_length += distanceFromSDF;

    if(ray_current_length >= max_ray_length){
      break;
    }
  }

  gl_FragColor = vec4(color, 1.0);
}
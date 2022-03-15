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

float sdf(vec3 p){
  return sdSphere(p - sphere_pos, sphere_radius);
}

vec3 GetSurfaceNormal(vec3 p)
{
  // by sampling the points slightly shifted on the x, y and z axes relative
  // to the provided point we can correlate any difference in distance to a normal
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
      color = GetSurfaceNormal(point);
      break;
    }

    ray_current_length += distanceFromSDF;

    if(ray_current_length >= max_ray_length){
      break;
    }
  }

  gl_FragColor = vec4(color, 1.0);
}
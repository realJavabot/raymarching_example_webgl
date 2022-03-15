precision highp float;

uniform float aspect_ratio;

varying vec3 fragment_pos;

const float bias = .0001;
const float max_ray_length = 10000.;
const vec3 cube_pos = vec3(0,0,10);
const float cube_width = 1.;
const vec2 cube_rotation = vec2(2.3, 2.3);
const vec3 background_color = vec3(.066);

// this function rotates on the z-axis and then on the x-axis.
// in this case rotation.x actually corresponds to the z-axis rotation.
vec3 rotatePos(vec3 p, vec2 rotation){
  p = vec3(
    p.x*cos(rotation.x) - p.z*sin(rotation.x), 
    p.y, 
    p.z * cos(rotation.x) + p.x*sin(rotation.x)
  );
  p = vec3(
    p.x, 
    p.y*cos(rotation.y) - p.z*sin(rotation.x), 
    p.z*cos(rotation.y) + p.y*sin(rotation.y)
  );
  return p;
}

float sdCube(vec3 p, float w){
  p  = rotatePos(p, cube_rotation);

  // When calculating the distance from the cube origin to the surface,
  // we find that the size with the largest displacement would need to have
  // distance w/2 to the surface. Finding the ratio between w/2 and said
  // displacement also gives the ratio between the distance from the origin to
  // the surface and the distance from the origin to the point.
  return length(p) * (1. - (w/2.) / max(abs(p.x),max(abs(p.y),abs(p.z))));
}

float sdf(vec3 p){
  return sdCube(p - cube_pos, cube_width);
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
#define E 0.02
//#define iBeat 0.0

float box_2d (in vec2 p, in vec2 b){
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float bounding_box (vec3 p, vec3 b, float e) {
  p = abs(p)-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}


float torus (vec3 p, vec2 t){
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sphere (vec3 p, float r) {
  return length(p) - r;
}

float floor_height(float z) {
  return sin(z * PI / 2.0) * 0.1 + sin(z / 16.0 * PI) * 0.5 - 0.5;
} 

float scene (vec3 p) {

  float d = 100000.0;
  d = min(d, 10.0 - abs(p.x));
  d = min(d, 10.0 - abs(p.y));

  d = min(d, box_2d(p.xy + vec2(0.0, 0.0 - floor_height(p.z)), vec2(0.75, 0.1)));

  vec3 bb_p = p;
  //p.z += iBeat;
  
  float bb_id = floor(p.z / 8.0);
  bb_p.z = mod(bb_p.z, 8.0) - 4.0; 
  //bb_p.x = abs(bb_p.x);   
  //bb_p.y = abs(bb_p.y);

  bb_p.xy = rot2(bb_p.xy, ((bb_id - 2.0) / 8.0 + iBeat / 8.0 + cos((iBeat + bb_id * 16.0) * PI / 64.0) * 2.0) * PI);
   
  //bb_p.x = abs(bb_p.x);

  d = min(d, bounding_box(bb_p, vec3(3.0, 3.0, 1.0), 0.25));
  

  return d;
}

vec3 normal (vec3 p) {
  return vec3 (
    scene(p + vec3(E, 0.0, 0.0)) - scene(p - vec3(E, 0.0, 0.0)),
    scene(p + vec3(0.0, E, 0.0)) - scene(p - vec3(0.0, E, 0.0)),
    scene(p + vec3(0.0, 0.0, E)) - scene(p - vec3(0.0, 0.0, E))
  );
}

vec3 trace (vec3 p, vec3 d, float k) {
  float dist = 0.0;
  for (int i=0; i<256; i++) {
    dist = scene(p);
    p += dist * k * d;

    if (dist <= E) {
      break;
    }
  }

  return p;
}


vec3 get_color(vec3 p, vec3 n, vec3 o, vec3 d, vec3 o_p) {
  vec3 color = vec3(1.0);
  
  color = n;
  color.rg = rot2(color.rg, p.z * PI / 16.0);
  color.rb = rot2(color.rb, p.z * PI / 64.0);
  color = abs(color);
  //color = normalize(color);

  vec3 wall_color = vec3(0.75);
  float x_stripe = smoothstep(-E, E, abs(fract(abs(p.x) / 4.0) * 2.0 - 1.0) - 0.5);
  float y_stripe = smoothstep(-E, E, abs(fract(abs(p.y) / 4.0) * 2.0 - 1.0) - 0.5);
  float z_stripe = smoothstep(-E, E, abs(fract(abs(p.z) / 4.0) * 2.0 - 1.0) - 0.5);
  
  float checker = max(x_stripe, y_stripe);
  checker = max(checker, z_stripe) * (1.0 - checker * z_stripe);
  wall_color *= checker;
 
  color = mix(color, wall_color, smoothstep(9.0, 9.1, max(abs(p.x), abs(p.y))));
  
  
  color *= 1.0 - smoothstep(0.0, 36.0, distance(o_p, p) - 6.0);

  return color;
}


vec3 scene_color(vec2 uv) {
  vec2 uv_c = (uv * 2.0 - 1.0) * iResolution.xy / iResolution.yy;

 
  vec3 color = vec3(0.0, 0.0, 0.0);
    
  vec3 o = vec3(0.0, 0.0, iBeat);
  o.y += floor_height(o.z) + 1.0;
  vec3 d = normalize(vec3(uv_c, 2.0));
 
  vec3 p = trace(o, d, 1.0);
  vec3 n = normalize(normal(p));
  color = mix(color, get_color(p, n, o, d, o), 1.0 - smoothstep(E, E * 2.0, scene(p)));
  
  vec3 d_reflect = reflect(d, n);
  vec3 p_reflect = trace(p + d_reflect * E * 2.0, d_reflect, 1.0);
  vec3 n_reflect = normalize(normal(p_reflect));
  vec3 color_reflect = get_color(p_reflect, n_reflect, p, d_reflect, o);
 
  color += mix(vec3(0.0), 0.5 * (pow(max((1.0 - length(color)) * 0.5, 1.0 - max(0.0, dot(-d, n))), 2.0) + 0.1) * color_reflect, 1.0 - step(E, scene(p_reflect)));
  
  
  //color *= 1.0 - smoothstep(0.0, 32.0, distance(o, p) - 32.0);

  
  return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;

  vec3 color = vec3(0.0, 0.0, 0.0);
  //color = scene_color(uv);
  
  
  for (int x=-1; x<=1; x++) {
    for (int y=-1; y<=1; y++) {
      vec2 offset = vec2(float(x), float(y)) * 0.33333;
      color += scene_color(uv + offset / iResolution.xy) * (1.0 - length(offset));
    }
  }
  color /= 3.0;
  
  
  color = clamp(vec3(0.0), vec3(1.0), color);

  fragColor = vec4(color, 1.0);
}

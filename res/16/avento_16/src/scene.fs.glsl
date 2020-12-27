#define E 0.01

//#define iBeat 1.0

mat3 lookat(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}


float box(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float rect(vec2 p, vec2 s) {
  p = abs(p - s / 2.0) - s / 2.0;
  return 1.0 - step(0.0, max(p.x, p.y));
}

float rect_border(vec2 p, vec2 s, vec2 b) {
  return (1.0 - rect(p - b / 2.0, s - b)) * rect(p, s) ;
}  

float text(vec2 p, vec2 s, float f_s, float line, float bounce) {
  float in_text = 1.0;

  vec2 char_pos = p / vec2(f_s * 0.5, f_s) - vec2(0.0, line + cos(line * PI) * bounce);
  vec2 char_id = floor(char_pos);


  in_text *= step(0.0, -floor(char_id.x / 3.0) * 3.0 + (char_id.y + line - 2.0) * s.x / f_s * 2.0);
  in_text *= step(1.0 / 32.0, rand(vec2(char_id.y, char_id.y)));
  in_text *= step(min(-0.2 +char_id.x * f_s * 2.0, 0.2), rand(char_id / 4.0)) * (1.0 - step(rand(char_id.yy) + 0.1, char_id.x * f_s * 0.5 / s.x));


  in_text *= rect(fract(char_pos), vec2(1.0, 0.5));
  in_text *= rect(p - f_s / 2.0, s - f_s);
  

  return in_text;
}

float text_pane(vec2 p, vec4 bounds, vec2 border_size, float font_size, float line, float bounce) {
  float value = 0.0;
  
  value += rect_border(p - bounds.xy, bounds.zw - bounds.xy, border_size);
  value += text(p - bounds.xy, bounds.zw - bounds.xy, font_size, line, bounce);

  return value;
}

vec3 floor_transform(vec3 p) {
  return p;
}

float floor_scene(vec3 p) {
  p = floor_transform(p);

  return p.y;
}

vec2 building_id(vec3 p, float interval) {
  return floor(p.xz / interval);
}

vec3 buildings_transform(vec3 p, float interval) {
  p.xz = mod(p.xz, interval) - interval / 2.0;

  return p;
}
 
float buildings_scene(vec3 p) {
  float interval = 16.0;

  vec2 id = building_id(p, interval);
  p = buildings_transform(p, interval);


  float d = 100000.0;

  d = min(d, box(p, vec3(0.3, 0.50 + 0.75 * rand(id / interval), 0.25) * interval));

  return d * 1.0;
}

float kick() {
  return smoothstep(-1.0, 0.0, iBeat - 8 * 4.0);
}

 
float snare() {
  return smoothstep(-1.0, 0.0, iBeat - 40 * 4.0) ;
}

float post_alarm() {
  return smoothstep(-1.0, 0.0, iBeat - 152 * 4.0);
}

float alarm() {
  return smoothstep(-1.0, 0.0, iBeat - 78 * 4.0) * (1.0 - post_alarm());
}


float bass_1() {
  return smoothstep(-1.0, 0.0, iBeat - 58 * 4.0);
}


vec3 subject_transform(vec3 p) {

  p.y -= 16.0 + 0.375 * cos(iBeat * PI) * kick();
  float offset = iBeat * 2.0;
  //offset = mix(offset, offset + 0.125 * cos(iBeat * PI * 2.0), alarm()) * kick();
  p.z += offset;

  return p;
}
 
float subject_scene(vec3 p) {
  p = subject_transform(p);

  float d = 10000.0;
  d = box(p, vec3(0.51, 0.76, 0.05));
  return min(d, 4.0);
}



float scene(vec3 p) {
  float d = 1000000.0;

  d = min(d, floor_scene(p));
  d = min(d, buildings_scene(p));
  d = min(d, subject_scene(p));

  return d;
}

vec3 normal(vec3 p) {
  return vec3(
    scene(p + vec3(E, 0.0, 0.0)) - scene(p - vec3(E, 0.0, 0.0)),
    scene(p + vec3(0.0, E, 0.0)) - scene(p - vec3(0.0, E, 0.0)),
    scene(p + vec3(0.0, 0.0, E)) - scene(p - vec3(0.0, 0.0, E))
  );
}

vec3 trace(vec3 o, vec3 d) {
  vec3 p = o;
  float dist = 0.0;

  for (int n = 0; n<96; n++) {
    dist = scene(p);
    p += d * dist;
    
    if (dist <= E) {
      break;
    }
  }

  return p;
}

vec3 buildings_color(vec3 p) {
    p = buildings_transform(p, 16.0);
    return fract(p);
}

vec3 floor_color (vec3 p) {
  float checker_size = 2.0;

  float checker = 0.0;
  vec2 p_checker = p.xz;
  p_checker = abs(fract(p_checker / checker_size) * 2.0 - 1.0);
  p_checker = smoothstep(-0.1, 0.1, p_checker - 0.75);

  checker = max(0.0, p_checker.x * p_checker.y);
  


  return checker * vec3(0.0, 1.0, 0.0);
}

vec3 subject_color (vec3 p) {
  p = subject_transform(p);
  vec3 color = vec3(0.0);

  vec4 code_bounds = vec4(-0.5, -0.75, 0.5, 0.75);
  vec2 code_border_size = vec2(0.025);
  float code_font_size = 0.1; 16.0 / iResolution.y;
  float code_beat = iBeat * 1.0 / 1.0 + iBeat * 4.0 * alarm();

  color = mix(color, mix(vec3(0.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), alarm()), text_pane(p.xy, code_bounds, code_border_size, code_font_size, code_beat, 0.25 * (1.0 - alarm())));

  return color;  
}

vec3 scene_color(vec2 uv) {
  vec2 uv_c = (uv * 2.0 - 1.0) * iResolution.xy / iResolution.yy;
 
  vec3 color = vec3(0.0, 0.0, 0.0);

  vec3 subject_p = -subject_transform(vec3(0.0));
  //subject_p.z *=-1;


  float plane_rot = sin(iBeat / 128.0 ) * 4.0;
  plane_rot += max(-0.25, sin((iBeat / 64.0 - 1.0) * PI * 2.0)) * sin(iBeat / 4.0) * 1.0 / 4.0 * bass_1();
  plane_rot *= PI * 2.0;
  
  float plane_height = 0.5 * cos(iBeat / 16.0 * PI);
  plane_height += 0.125 * cos(iBeat / 4.0 * PI) * snare(); 

  float screen_roll = snare() * cos(iBeat / 2.0 * PI);
  screen_roll = pow(abs(screen_roll), 16.0) * sign(screen_roll) * (1.0 - max(alarm(), post_alarm()));
  uv_c = rot2(uv_c, screen_roll * PI / 64.0) * (1.0 + .2 * screen_roll);

  float roll = 0.0;
  roll += cos(iBeat / 16.0 * PI) / 4.0 * bass_1();

  float cam_dist = 2.0;

  vec3 o = subject_p + vec3(cos(plane_rot * (1.0 + 0.0 / 16.0)) * cam_dist, plane_height, sin(plane_rot) * cam_dist);

  vec3 d = lookat(o.xyz, subject_p.xyz, roll) * normalize(vec3(uv_c, 1.75));
  
 

  vec3 p = trace(o, d);



  vec4 code_bounds = (vec4(0.0, 0.0, 1.0, 1.0) - 0.5) * iResolution.xyxy / iResolution.yyyy * 2.0 ;
  vec2 code_border_size = vec2(0.00);
  float code_font_size = 12.0 / iResolution.y;
  float code_beat = iBeat * 2.0 / 1.0;

  color = mix(color, mix(vec3(0.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), alarm()), text_pane(-uv_c.yx, code_bounds.yxwz, code_border_size, code_font_size, 128.0 * plane_rot / PI, 0.0));



  if (scene(p) < E * (2.0 + 16.0 * smoothstep(8.0, 32.0, distance(p, o))) ) {
    float d = 10000.0;
    float d_obj = 0.0;
    
    d_obj = floor_scene(p);
    color = mix(color, floor_color(p), step(d_obj, d));
    d = min(d, d_obj);

    d_obj = buildings_scene(p);
    color = mix(color, buildings_color(p), step(d_obj, d));
    d = min(d, d_obj);

    d_obj = subject_scene(p);
    color = mix(color, subject_color(p), step(d_obj, d));
    d = min(d, d_obj);

    vec3 light_p = vec3(p.x, p.y, p.z);
    

    vec3 interval = vec3(0.5, 1.0, 0.5);
    light_p = floor(light_p / interval) * interval + interval / 2.0;
    //light_p.xyz -= 0.25;

    vec3 light = vec3(0.0);
    light += vec3(2.0) / (1.0 + max(0.0, sqrt(distance(-subject_transform(vec3(0.0)), p)) - 2.0) * 16.0);
    light += vec3(1.0) * (1.0 - smoothstep(0.1, 0.25, distance(light_p, p)));

    color *= light;
 
  }

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
  color /= 9.0;

  
  color = clamp(vec3(0.0), vec3(1.0), color);

  fragColor = vec4(color, 1.0);
}



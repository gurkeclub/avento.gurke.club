#define E 0.01

//#define iBeat 0.0

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

float kick() {
  return smoothstep(-1.0, 0.0, iBeat - 11 * 4.0);
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

  d = min(d, box(p, vec3(0.29, 0.50 * 0.0 + 0.75 * rand(id / interval) + 0.75 + id.y / 16.0 * (1.0 - smoothstep(4.0 * 60.0, 4.0 * 60.0 + 35.0, iTime)), 0.249) * interval));

  return d;
}


vec3 subject_transform(vec3 p) {

  p.y -= 0.0 + 0.375 * (0.5 + 0.5 * cos(iBeat * PI)) * kick();
  float offset = iBeat * 2.0;
  offset = mix(offset, offset + 0.0675 * cos(iBeat * PI * 2.0), 1.0) * kick();
  
  p.z += offset;

  return p;
}
 
float subject_scene(vec3 p) {
  p = subject_transform(p);

  float d = 10000.0;

  d = min(d, box(p - vec3(0.7, 0.36, 0.0), vec3(0.21, 0.36, 0.05)));

  d = min(d, mix(d, box(p - vec3(-0.3, 0.76, 0.0), vec3(0.05, 0.76, 0.51)), kick()));

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


vec3 sky_color (vec3 d) {
  vec2 angle = vec2(atan(d.z, d.x), -atan(length(d.xz), d.y));
  vec2 uv = angle / PI * 8.0;

  //uv.x -= iBeat;

  vec3 color = texture(iChannel0, uv).rgb;

  return color;
}


vec3 buildings_color(vec3 p) {
    vec3 n = normalize(normal(p));
    p = buildings_transform(p, 16.0);
    vec3 color = vec3(0.1);
    color = mix(color, fract(p), smoothstep(4.0 * 60.0, 4.0 * 60.0 + 35.0, iTime));
    return color;
}

vec3 floor_color (vec3 p, vec3 d) {
  float checker_size = 2.0;

  float checker = 0.0;
  vec2 p_checker = p.xz / 6.0 - 0.5;
  p_checker = abs(fract(p_checker / checker_size) * 2.0 - 1.0);
  //p_checker = smoothstep(-0.1, 0.1, p_checker - 0.75);

  //checker = max(0.0, p_checker.x * p_checker.y);

  vec3 color = texture(iChannel1, p_checker).rgb;


  color = mix(color, texture(iChannel1, p_checker * 3.0).rgb, smoothstep(0.0, 0.1, color.g - min(color.r, color.b) - 0.3));
  color = mix(color, texture(iChannel1, p_checker * 9.0).rgb, smoothstep(0.0, 0.1, color.g - min(color.r, color.b) - 0.3));
  //color = mix(color, texture(iChannel1, p_checker * 27.0).rgb, smoothstep(0.0, 0.1, color.g - min(color.r, color.b) - 0.3));
  color = mix(color, vec3(0.0), smoothstep(0.0, 0.1, color.g - min(color.r, color.b) - 0.3));

  return color;
}

vec3 subject_color (vec3 p, vec3 d) {
  p = subject_transform(p);
  vec3 color = vec3(0.0, 1.0, 0.0);

  float gena_off = sin(iBeat / 4.0 * PI); 
  float gena_dir = fract(iBeat / 2.0 + 0.25) - 0.5;

  vec2 p_gena = (p.zy + vec2(0.0, -0.76)) / vec2(0.5, 0.76);
  
  vec2 p_chib = (p.xy + vec2(-0.7, -0.36)) / vec2(0.21, 0.36);

  vec3 gena_color = texture(iChannel2, vec2(-1.0, 1.0) * p_gena * 0.5 + 0.5).rgb;

  vec3 chib_color = texture(iChannel3, vec2(mix(1.0, sign(fract(iBeat) * 2.0 - 1.0), step(4.0 * 60.0 + 3.0, iTime)), 1.0) * p_chib * 0.5 + 0.5).rgb;

  float in_gena = 1.0;
  in_gena *= 1.0 - max(step(1.0, abs(p_gena.x)), step(1.0, abs(p_gena.y)));
  in_gena *= smoothstep(0.04, 0.05, abs(p.x + 0.3));
  in_gena *= 1.0 - smoothstep(0.06, 0.061, abs(p.x + 0.3));

  float in_chib = 1.0;
  in_chib *= 1.0 - max(step(1.0, abs(p_chib.x)),  step(1.0, abs(p_chib.y)));
  in_chib *= smoothstep(0.04, 0.05, abs(p.z));

  color = mix(color, gena_color, in_gena);
  color = mix(color, chib_color, in_chib);

  //color = mix(gena_color, chib_color, smoothstep(-0.05, 0.05, p.z));
  color = mix(color, sky_color(d) + 0.03, step(0.1, color.g) * smoothstep(0.0, 0.02, color.g - max(color.r, color.b) - 0.05)); 

  return color;  
}

vec3 scene_color(vec2 uv) {
  vec2 uv_c = (uv * 2.0 - 1.0) * iResolution.xy / iResolution.yy;
 
  vec3 color = vec3(0.0, 0.0, 0.0);

  vec3 subject_p = -subject_transform(vec3(0.0));
  //subject_p.z *=-1;


  float plane_rot = kick() * sin(iBeat / 2.0 * PI) / 32.0 - 0.5;
  plane_rot += 0.25;
  plane_rot *= PI * 1.0;
  
  float plane_height = 0.76;
  plane_height += 0.125 * cos(iBeat / 16.0 * PI);
  plane_height += 0.0675 * cos(iBeat / 2.0 * PI) * snare(); 

  float screen_roll = snare() * cos(iBeat / 2.0 * PI);
  screen_roll = pow(abs(screen_roll), 16.0) * sign(screen_roll) * (1.0 - max(alarm(), post_alarm())) * 0.0;
  uv_c = rot2(uv_c, screen_roll * PI / 64.0) * (1.0 + .2 * screen_roll);

  float fov = 1.5;
  fov -= 1.0 * (smoothstep(3.0 * 60.0 + 30, 4.0 * 60.0, iTime) - smoothstep(4.0 * 60.0, 4.0 * 60.0 + 15.0, iTime));



  float roll = 0.0;
  roll += cos(iBeat / 16.0 * PI) / 4.0 * bass_1() * 0.0;

  float cam_dist = 2.0;

  vec3 o = vec3(subject_p.x, 0.00, subject_p.z) + vec3(cos(plane_rot * (1.0 + 0.0 / 16.0)) * cam_dist, plane_height, sin(plane_rot) * cam_dist);

  vec3 d = lookat(o.xyz, subject_p.xyz + vec3(0.0, 0.76, 0.0), roll) * normalize(vec3(uv_c, fov));
  
   vec3 p = trace(o, d);



  color = sky_color(d) * (1.0 - smoothstep(0.0, 4.0, iBeat - 62.0 * 4.0) + smoothstep(4.0 * 60.0, 4.0 * 60.0 + 35.0, iTime));


  vec3 dir = d;
  if (scene(p) <  E * (2.0 + 16.0 * smoothstep(8.0, 32.0, distance(p, o))) ) {
    float d = 10000.0;
    float d_obj = 0.0;
    
    d_obj = floor_scene(p);
    color = mix(color, floor_color(p, dir), step(d_obj, d) * kick());
    d = min(d, d_obj);

    d_obj = buildings_scene(p);
    color = mix(color, buildings_color(p), step(d_obj, d) * kick());
    d = min(d, d_obj);

    d_obj = subject_scene(p);
    color = mix(color, subject_color(p, dir), step(d_obj, d));
    d = min(d, d_obj);

    vec3 light_p = vec3(p.x, p.y, p.z);
    

    vec3 interval = vec3(0.5, 1.0, 0.5);
    light_p = floor(light_p / interval) * interval + interval / 2.0;
    //light_p.xyz -= 0.25;

    vec3 light = vec3(0.25);
    light += vec3(1.5, 1.0, 1.0) / (1.0 + max(0.0, sqrt(distance(-subject_transform(vec3(0.0)), p)) - 2.0) * 4.0);
    //light += vec3(1.0) * (1.0 - smoothstep(0.1, 0.25, distance(light_p, p)));
    light = max(light, 1.0 - kick() + smoothstep(3.0 * 60.0, 5.0 * 60.0, iTime));

    color *= light;
 
  }

  return color;
}

vec3 tmo_aces(vec3 v) {
    v *= 0.6;
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((v * (a * v + b)) / (v * (c * v + d) + e), vec3(0.0), vec3(1.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;

  vec3 color = vec3(0.0, 0.0, 0.0);
  color = scene_color(uv);
  
  /*
  for (int x=-1; x<=1; x++) {
    for (int y=-1; y<=1; y++) {
      vec2 offset = vec2(float(x), float(y)) * 0.33333;
      color += scene_color(uv + offset / iResolution.xy) * (1.0 - length(offset));
    }
  }
  color /= 5.0;
  */
  
  
  color = tmo_aces(color * 2.0);

  color = clamp(vec3(0.0), vec3(1.0), color);

  fragColor = vec4(color, 1.0);
}



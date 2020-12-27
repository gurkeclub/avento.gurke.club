#define E 0.01

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

float scene (vec3 p) {
  float d = sphere(vec3(p.xy + vec2(cos((p.z + iBeat - 0.5) / 4.0 * PI), sin((p.z + iBeat - 0.5) / 12.0 * PI)), mod(p.z +iBeat, 2.0) - 1.0), 0.1);
  //d = min(d, 1.0 - abs(p.x));
  //d = min(d, 1.0 - abs(p.y));

  vec3 p_torus = p;
  p_torus.z -= 2.0;
  p_torus.xy = rot2(p_torus.xy, iBeat / 3.0 * PI);
  p_torus.yz = rot2(p_torus.yz, cos(iBeat / 8.0 * PI) * 2.0 * PI);
  d = min(d, torus(p_torus, vec2(0.3, 0.05) + 0.05 * abs(fract(iBeat / 2.0) * 2.0 - 1.0)));

  
  
  vec3 p_box = p;
  p_box.z -= 2.0;
  p_box.xy = rot2(p_box.xy, -iBeat / 7.0 * PI);
  p_box.yz = rot2(p_box.yz, cos(iBeat / 16.0 * PI) * 2.0 * PI);


  d = min(d, bounding_box(p_box, vec3(0.35) + 0.15 * pow(0.5 + 0.5 * cos(iBeat / 6.0 * PI), 4.0), 0.03));
  

  return d;
}

vec3 normal (vec3 p) {
  return vec3 (
    scene(p + vec3(E, 0.0, 0.0)) - scene(p - vec3(E, 0.0, 0.0)),
    scene(p + vec3(0.0, E, 0.0)) - scene(p - vec3(0.0, E, 0.0)),
    scene(p + vec3(0.0, 0.0, E)) - scene(p + vec3(0.0, 0.0, E))
  );
}

vec3 trace (vec3 p, vec3 d, float k) {
  for (int i=0; i<6; i++) {
    p += scene(p) * k * d;
  }

  return p;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 uv_c = (uv * 2.0 - 1.0) * iResolution.xy / iResolution.yy;
  

  vec3 color = vec3(0.0, 0.0, 0.0);
  
  vec3 o = vec3(0.0, 0.0, iBeat * 0.0);
  vec3 d = normalize(vec3(uv_c, 2.0));

  vec3 p = trace(o, d, 1.0);
  vec3 n = normalize(normal(p));

    color = vec3(1.0);
  
    color = mix(color, color * vec3(0.0, 0.0, 1.0), pow(dot(-d, n), 0.5));
    color = mix(color, color * mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), cos(iBeat / 4.0 * PI) * 0.5 + 0.5), abs(dot(normalize(vec3(p.x, p.y, -1.0)), n)));
    color += color * abs(vec3(rot2(n.xy, iBeat / 32.0 * PI), n.z));
    color = pow(color, vec3(2.0) / 1.0);
    color*= smoothstep(0.0, 3.0, 5.0 - distance(o, p));
  color *= smoothstep(0.0, 0.1, 0.5 - max(abs(p.x), abs(p.y)));
  color = clamp(vec3(0.0), vec3(1.0), color);
  fragColor = vec4(color, 1.0);
}

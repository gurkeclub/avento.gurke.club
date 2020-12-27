
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  
  vec2 mouse_pos = iMouse.xy / iResolution.xy;  
  mouse_pos = mouse_pos * 2.0 - 1.0;
  mouse_pos.y = -mouse_pos.y;
  mouse_pos *= iResolution.xy / iResolution.yy;

  vec3 view_pos = vec3(iBeat / 4.0, 0.0, 1.0);

  vec3 light_pos = view_pos;
  light_pos.z = 0.75;
  light_pos.y += 0.25 * cos(view_pos.x * PI / 2.0);
  light_pos.x += 0.25 * cos(view_pos.x * PI / 2.0);

  //light_pos.xy += mouse_pos;
  

  vec3 view_dir = normalize(vec3(0.0, 0.0, -1.0));


  vec3 pos = vec3( uv * 2.0 - 1.0, 0.0);
  pos.xy *= iResolution.xy / iResolution.yy; 
  pos.xy += view_pos.xy; 

  vec2 pos_uv = pos.xy / 2.0;

  vec2 pos_graff_uv = pos_uv;
  pos_graff_uv.y *= 2.0;
  pos_graff_uv.y -= 0.5;
  pos_graff_uv.x -= view_pos.x / 2.0 - 0.5;

  vec3 overlay = pow(texture(iChannel5, vec2(pos_uv - 0.5)).rgb, vec3(1.0));
  vec3 diffuse = pow(texture(iChannel0, pos_uv).rgb, vec3(1.0) / 2.2);
  vec3 normal = pow(texture(iChannel1, pos_uv).rgb, vec3(1.0) / 2.2);
  float bump = pow(texture(iChannel2, pos_uv).r, 1.0 / 2.2);
  float spec = pow(texture(iChannel3, pos_uv).r, 1.0 / 2.2);


  float in_graff_y = 1.0 - smoothstep(-0.01, 0.00, abs(pos_graff_uv.y + 0.5) - 0.5);
  float in_graff_x = 1.0 - smoothstep(-0.01, 0.01, abs(pos_graff_uv.x - 0.5) - 0.5);
  float in_graff = in_graff_x * in_graff_y;

  vec3 graff = texture(iChannel4, abs(fract(pos_graff_uv/ 2.0) * 2.0 - 1.0)).rgb;
  graff = pow(graff, vec3(1.0) / 2.2);
  graff = mix(step(0.15, fract(graff * 4.0)), mix(graff, abs(fract(graff * 4.0 + iBeat / 2.0) * 2.0 - 1.0), smoothstep(0.0, 0.01, length(graff) - 0.1)), in_graff);
  //graff = 1.0 - normalize(graff + 0.1);

  diffuse = mix(diffuse, mix(1.0 - graff, graff, in_graff_x), in_graff);

  overlay = mix(overlay, vec3(1.0), in_graff);
  
  normal = pow(normal, vec3(1.0)) * 2.0 - 1.0;
  normal.y *= -1.0;
  normal = normalize(normal); 
  normal = mix(normal, vec3(0.0, 0.0, 1.0), in_graff);


  vec3 light_dir = normalize(pos - light_pos);
  vec3 light_color = mix(vec3(2.0, 0.5, 0.5), vec3(0.5, 2.0, 0.5), abs(fract(iBeat / 16.0) * 2.0 - 1.0));
  float light_ambiant = 0.02;

  float light_attenuation = 1.0 - smoothstep(0.0, 2.50, distance(light_pos, pos));
  light_attenuation = pow(light_attenuation, 2.0); 

  float light_diffuse = max(0.0, dot(light_dir, -normal));
  light_diffuse *= light_attenuation; 
  
  vec3 graff_hsv = rgb2hsv(graff);
  float light_specular = pow(max(0.0, dot(reflect(-light_dir, normal), view_dir)),  0.0 + 5.0 );
  light_specular *= (light_ambiant + light_attenuation) * max(spec, in_graff * 4.0 * (graff_hsv.b * (1.0 - graff_hsv.g))) * 1.0;  

  vec3 color = diffuse;
  color *= (light_diffuse + light_ambiant + light_specular) * light_color;
  color *= overlay;

  color *= 1.5;
  color = clamp(vec3(0.0), vec3(1.0), color);

  //color = mix(color, color - overlay * 0.1, 1.0 - smoothstep(0.0, 0.05, length(color)));

  //color *= 1.0 - step(0.1, fract(length(pos.xy - view_pos.xy)));
  fragColor = vec4(color, 1.0);
}

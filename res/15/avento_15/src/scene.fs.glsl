
float rect(vec2 p, vec2 s) {
  p = abs(p - s / 2.0) - s / 2.0;
  return 1.0 - step(0.0, max(p.x, p.y));
}

float rect_border(vec2 p, vec2 s, vec2 b) {
  return (1.0 - rect(p - b / 2.0, s - b)) * rect(p, s) ;
}  



float text(vec2 p, vec2 s, float f_s, float line) {
  float in_text = 1.0;

  vec2 char_pos = p / vec2(f_s * 0.5, f_s) - vec2(0.0, line);
  vec2 char_id = floor(char_pos);
  in_text *= rect(fract(char_pos), vec2(1.0, 0.5));
  in_text *= step(min(-0.01 +char_id.x * f_s * 2.0, 0.2), rand(char_id / 4.0)) * (1.0 - step(rand(char_id.yy) + 0.1, char_id.x * f_s * 0.5 / s.x));
  in_text *= rect(p - f_s / 2.0, s - f_s);
  

  return in_text;
}

float text_pane(vec2 p, vec4 bounds, vec2 border_size, float font_size, float line) {
  float value = 0.0;
  
  value += rect_border(p - bounds.xy, bounds.zw - bounds.xy, border_size);
  value += text(p - bounds.xy, bounds.zw - bounds.xy, font_size, line);

  return value;
}

vec3 scene_color(vec2 uv) {
  vec2 uv_c = (uv * 2.0 - 1.0) * iResolution.xy / iResolution.yy;
 
  vec3 color = vec3(0.0, 0.0, 0.0);

  vec4 kick_bounds = vec4(-0.5, -0.5, 0.5, 0.5);
  vec2 kick_border_size = vec2(0.025);
  float kick_font_size = 16.0 / iResolution.y;
  float kick_beat = floor(iBeat * 1.0 / 1.0);
  
  vec4 ohat_bounds =  vec4(kick_bounds.z + kick_border_size.x * 3.0, 0.0, kick_bounds.z + kick_border_size.x * 3.0, 0.0) + vec4(0.0, -0.75, 0.5, 0.75);
  vec2 ohat_border_size = vec2(0.025);  
  float ohat_font_size = 16.0 / iResolution.y;
  float ohat_beat= floor(iBeat * 1.0 / 1.0 - 0.5 - 32.0);

  vec4 chat_bounds =  vec4(kick_bounds.x - kick_border_size.x * 3.0, 0.0, kick_bounds.x - kick_border_size.x * 3.0, 0.0) + vec4(-0.5, -0.75, 0.0, 0.75);
  vec2 chat_border_size = vec2(0.025);      
  float chat_font_size = 16.0 / iResolution.y;
  float chat_beat= floor(iBeat * 2.0 / 1.0 - 32.0);


  vec4 snare_bounds =  vec4(ohat_bounds.z + ohat_border_size.x * 3.0, 0.0, ohat_bounds.z + ohat_border_size.x * 3.0, 0.0) + vec4(0.0, -0.3, 1.75, 0.3);
  vec2 snare_border_size = vec2(0.025);
  float snare_font_size = 16.0 / iResolution.y;
  float snare_beat= floor(iBeat * 1.0 / 2.0 - 32.0);

  vec4 tom_bounds =  vec4(chat_bounds.x - chat_border_size.x * 3.0, 0.0, chat_bounds.x - chat_border_size.x * 3.0, 0.0) + vec4(-1.75, -0.3, 0.0, 0.3);
  vec2 tom_border_size = vec2(0.025);
  float tom_font_size = 16.0 / iResolution.y;
  float tom_beat= floor(iBeat * 1.0 / 4.0 - 0.25);


  
  

  color = mix(color, vec3(1.0, 0.0, 0.0), text_pane(uv_c, kick_bounds, kick_border_size, kick_font_size, kick_beat));
  color = mix(color, vec3(1.0, 0.0, 1.0), text_pane(uv_c, ohat_bounds, ohat_border_size, ohat_font_size, ohat_beat));  
  color = mix(color, vec3(0.0, 1.0, 1.0), text_pane(uv_c, chat_bounds, chat_border_size, chat_font_size, chat_beat));
  color = mix(color, vec3(1.0, 1.0, 0.0), text_pane(uv_c, snare_bounds, snare_border_size, snare_font_size, snare_beat));
  color = mix(color, vec3(0.0, 1.0, 0.0), text_pane(uv_c, tom_bounds, tom_border_size, tom_font_size, tom_beat));

  return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;

  vec3 color = vec3(0.0, 0.0, 0.0);
  color = scene_color(uv);
  
  
  color = clamp(vec3(0.0), vec3(1.0), color);

  fragColor = vec4(color, 1.0);
}



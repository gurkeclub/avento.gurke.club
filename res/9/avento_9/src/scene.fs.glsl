#define E 0.01


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 uv_c = (uv * 2.0 - 1.0) * iResolution.xy / iResolution.yy;
  
  vec3 color = vec3(0.0, 0.0, 0.0);

  vec3 bahn_color = texture(iChannel0, uv).rgb;

  vec3 bb_color = texture(iChannel1, uv).rgb;

  color = bahn_color;
  //color = 1.0 - abs(fract(bahn_color) * 2.0 - 1.0);

  

  float edges = 0.0;
  edges += abs(texture(iChannel0, uv.xy + vec2(1.0, 0.0) / iResolution.xy).r - texture(iChannel0, uv.xy - vec2(1.0, 0.0) / iResolution.xy).r);
  edges += abs(texture(iChannel0, uv.xy + vec2(0.0, 1.0) / iResolution.xy).r - texture(iChannel0, uv.xy - vec2(0.0, 1.0) / iResolution.xy).r);
  

  color = mix(color, hsv2rgb(max(rgb2hsv(color * vec3(edges)), vec3(0.0, 1.0, 0.0))), 0.5 + 0.5 * min(pow(abs(fract(iBeat / 16.0) * 2.0 - 1.0), 0.5) * (1.0 - abs(fract(iBeat / 128.0) * 2.0 - 1.0)) * 2.0, 1.0));

  color = clamp(color, bb_color - 1.0 / 255.0, bb_color + 4.0 / 255.0);


  color = clamp(color, vec3(0.0), vec3(1.0));

  fragColor = vec4(color, 1.0);
}

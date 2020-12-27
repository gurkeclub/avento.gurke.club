#define E 0.01


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 uv_c = (uv * 2.0 - 1.0) * iResolution.xy / iResolution.yy;
  
  vec3 color = vec3(0.0, 0.0, 0.0);

  vec3 cat_color = texture(iChannel0, uv).rgb;

  vec3 dem_color = texture(iChannel1, uv).rgb;
  dem_color *= smoothstep(0.0, 0.5, abs(fract(rot2(uv_c.xy, iBeat / 32.0 * PI).y * 4.0 - iBeat / 4.0) * 2.0 - 1.0) - 0.125);

  color = cat_color;
  //color = 1.0 - abs(fract(cat_color) * 2.0 - 1.0);
  color = mix(color, dem_color, step(0.1, length(dem_color) * length(color) * color.r / (color.g + color.b + 0.01)));

  float edges = 0.0;
  edges += abs(texture(iChannel0, uv.xy + vec2(1.0, 0.0) / iResolution.xy).r - texture(iChannel0, uv.xy - vec2(1.0, 0.0) / iResolution.xy).r);
  edges += abs(texture(iChannel0, uv.xy + vec2(0.0, 1.0) / iResolution.xy).r - texture(iChannel0, uv.xy - vec2(0.0, 1.0) / iResolution.xy).r);
  color = mix(color, color * vec3(edges), min(pow(abs(fract(iBeat / 12.0) * 2.0 - 1.0), 0.5) * (1.0 - abs(fract(iBeat / 128.0) * 2.0 - 1.0)) * 2.0, 1.0));

  color = clamp(vec3(0.0), vec3(1.0), color);
  fragColor = vec4(color, 1.0);
}

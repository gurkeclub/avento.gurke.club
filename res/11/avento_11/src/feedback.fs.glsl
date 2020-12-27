void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;

  vec3 color = texture(iChannel0, uv).rgb;
  vec2 uv_fb = vec2(0.0);
  uv_fb = normalize((uv - 0.5) * iResolution.xy / iResolution.yy) * 7.0;
  //uv_fb = rot2(uv_fb, 2.0 * PI * abs(max(0.0, fract(iBeat / 16.0) - 0.75) / 0.25 * 2.0 - 1.0));
  
  //uv_fb *= 1.0 + 2.0 *  (1.0 - abs(fract(max(0.0, fract(iBeat / 8.0 + 0.5) - 0.75) / 0.25 * 2.0) * 2.0 - 1.0)) * sign(fract(iBeat / 16.0) - 0.5);

  uv_fb = floor(uv_fb);

  uv_fb /= iResolution.xy;
  uv_fb = fract(uv_fb);

  uv_fb = uv - uv_fb;

  vec3 color_fb = texture(iChannel1, uv_fb).rgb;
  //color = mix(color, abs(color -  color_fb) * 1.0, smoothstep(-0.05, 0.15, length(color) - 0.95));

  color = clamp(vec3(0.0), vec3(1.0), color);

  fragColor = vec4(color, 1.0);
}

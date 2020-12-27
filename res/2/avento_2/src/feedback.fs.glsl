void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;

  vec3 color = texture(iChannel0, uv).rgb;
  vec2 uv_fb = vec2(0.0);
  uv_fb = floor(rot2(sign(uv - 0.5), PI * iBeat * 1.0 / 8.0) * 4.0) / iResolution.xy;
  //uv_fb.x = -abs(uv_fb.x) * sign(uv.x - 0.5);

  uv_fb = uv - uv_fb;

  vec3 color_fb = texture(iChannel1, uv_fb).rgb;
  color = mix(color, color_fb * 0.9, 1.0 - step(0.0, length(color) - 0.1));

  fragColor = vec4(color, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;

  vec3 color = texture(iChannel0, uv).rgb;
  vec2 uv_fb = vec2(0.0);
  uv_fb = normalize(uv - 0.5) * 2.0;
  uv_fb.y += cos(iBeat / 32.0 * PI) * 2.0;
  uv_fb /= iResolution.xy;
  //uv_fb.x = -abs(uv_fb.x) * sign(uv.x - 0.5);

  uv_fb = uv - uv_fb;

  vec3 color_fb = texture(iChannel1, uv_fb).rgb;
  color = mix(color, max(color, color_fb * 0.8), 1.0 - smoothstep(-0.05, 0.15, length(color) - 0.1));

  fragColor = vec4(color, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;

  vec3 color = texture(iChannel0, uv).rgb;
  color *= 4.0;
  color *= 1.0 - pow(smoothstep(0.5, 2.0, length((uv - 0.5) * iResolution.xy / iResolution.yy)), 0.5);
  //color = mix(color, vec3(0.0, 1.0, 0.0), step(1.0, color.r));

  fragColor = vec4(color, 1.0);
}

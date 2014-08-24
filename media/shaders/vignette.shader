extern vec4 frame;
extern number radius;
extern number blur;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);
  
  screen_coords -= frame.xy;
  vec2 position = (screen_coords.xy / frame.zw) - vec2(0.5);
  float len = length(position);
  float vignette = smoothstep(radius, radius - blur, len);
  result.rgb *= vignette;

  return result * color;
}
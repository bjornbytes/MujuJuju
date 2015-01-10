extern vec4 frame;
extern number radius;
extern number blur;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);
  
  screen_coords -= frame.xy;
  vec2 position = (screen_coords.xy / frame.zw) - vec2(0.5);
  float len = length(position);
  len = clamp((len - radius) / ((radius - blur) - radius), 0.0, 1.0);
  float vignette = len * len * (3 - 2 * len);
  result.rgb *= vignette;

  return result * color;
}

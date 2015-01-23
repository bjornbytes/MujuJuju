extern number threshold;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);
  //result.a = ceil(result.a);
  return vec4(color.rgb, result.a);
}

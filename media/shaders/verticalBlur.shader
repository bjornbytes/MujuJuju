extern number amount;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords) * .2270270270;

  result += Texel(texture, vec2(texture_coords.x, texture_coords.y - 4.0 * amount)) * .0162162162;
  result += Texel(texture, vec2(texture_coords.x, texture_coords.y - 3.0 * amount)) * .0540540541;
  result += Texel(texture, vec2(texture_coords.x, texture_coords.y - 2.0 * amount)) * .1216216216;
  result += Texel(texture, vec2(texture_coords.x, texture_coords.y - amount)) * .1945945946;
  
  result += Texel(texture, vec2(texture_coords.x, texture_coords.y + amount)) * .1945945946;
  result += Texel(texture, vec2(texture_coords.x, texture_coords.y + 2.0 * amount)) * .1216216216;
  result += Texel(texture, vec2(texture_coords.x, texture_coords.y + 3.0 * amount)) * .0540540541;
  result += Texel(texture, vec2(texture_coords.x, texture_coords.y + 4.0 * amount)) * .0162162162;

  return result * color;
}

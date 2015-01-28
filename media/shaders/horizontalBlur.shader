extern number amount;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords) * .2270270270;

  result += Texel(texture, vec2(texture_coords.x - 4.0 * amount, texture_coords.y)) * .0162162162;
  result += Texel(texture, vec2(texture_coords.x - 3.0 * amount, texture_coords.y)) * .0540540541;
  result += Texel(texture, vec2(texture_coords.x - 2.0 * amount, texture_coords.y)) * .1216216216;
  result += Texel(texture, vec2(texture_coords.x - amount, texture_coords.y)) * .1945945946;
  
  result += Texel(texture, vec2(texture_coords.x + amount, texture_coords.y)) * .1945946946;
  result += Texel(texture, vec2(texture_coords.x + 2.0 * amount, texture_coords.y)) * .1216216216;
  result += Texel(texture, vec2(texture_coords.x + 3.0 * amount, texture_coords.y)) * .0540540541;
  result += Texel(texture, vec2(texture_coords.x + 4.0 * amount, texture_coords.y)) * .0162162162;

  return result * color;
}

extern number amount;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords) * .16;

  result += Texel(texture, vec2(texture_coords.x - 4.0 * amount, texture_coords.y)) * .05;
  result += Texel(texture, vec2(texture_coords.x - 3.0 * amount, texture_coords.y)) * .09;
  result += Texel(texture, vec2(texture_coords.x - 2.0 * amount, texture_coords.y)) * .12;
  result += Texel(texture, vec2(texture_coords.x - amount, texture_coords.y)) * .15;
  
  result += Texel(texture, vec2(texture_coords.x + amount, texture_coords.y)) * .15;
  result += Texel(texture, vec2(texture_coords.x + 2.0 * amount, texture_coords.y)) * .12;
  result += Texel(texture, vec2(texture_coords.x + 3.0 * amount, texture_coords.y)) * .09;
  result += Texel(texture, vec2(texture_coords.x + 4.0 * amount, texture_coords.y)) * .05;

  return result * color;
}
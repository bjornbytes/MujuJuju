extern number time;
extern vec2 strength;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	texture_coords.x += sin(texture_coords.x * 20 + time / 80) * strength.x;
	texture_coords.y += cos(texture_coords.y * 20 + time / 80) * strength.y;
  vec4 result = Texel(texture, texture_coords);
  return result;
}

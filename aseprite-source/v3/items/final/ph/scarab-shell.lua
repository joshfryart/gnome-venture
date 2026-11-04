-- scarab-shell (first draft, Sonnet). One glossy scarab wing-case (elytron half) seen from above: a domed oval that
-- shifts from emerald through teal to violet at the rim, fine parallel grooves, a shoulder bump, a gold-ringed
-- drilled hole with a thin cord loop.
-- quirk: the cord loop of a bead necklace trails off with a tiny gold bead.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("scarab-shell")
local floor, sin, cos = math.floor, math.sin, math.cos
c:groundShadow(32, 56, 14, 3)
local m = A.HP.mask()
for y = 8, 54 do
  local t = (y - 8) / 46
  local w = 18.5 * (sin(math.pi * (t ^ .9)) ^ .62)
  for x = floor(32 - w + .5), floor(32 + w - .5) do m:set(x, y) end
end
local ramp = A.R("#2fa876")
A.lit(c, m, ramp, 8, { amb = .06, wrap = .3 })
-- iridescence: hue shift toward teal on lower right, violet on rim
m:each(function(x, y)
  local d = (x - 32) / 17 + (y - 30) / 24
  local hex = c:get(x, y)
  if d > .8 then c:px(x, y, "#3a7ac0") end
  if d > 1.1 then c:px(x, y, "#5a459e") end
end)
-- grooves
for gx = -12, 12, 4 do
  for y = 14, 50 do
    local w = 17 * (sin(math.pi * (((y - 8) / 46) ^ .75)) ^ .75)
    if math.abs(gx) < w - 2 then c:px(32 + gx + floor((y - 30) * gx / 60), y, "#1f6a54") end
  end
end
-- seam in the middle
for y = 12, 52 do c:px(32, y, "#144a40") end
-- specular streak + pop
for y = 14, 24 do c:px(24 - floor((y - 14) / 5), y, "#e4ffd8") end
c:px(26, 13, "#ffffd8")
-- shoulder bump
A.sph(c, 24, 17, 2.4, "#6adea0", { nospec = true })
-- hole with gold ring, cord
A.sph(c, 32, 12, 3.2, "#f5b82e", { nospec = true })
c:fillMask(c:ellipse(32, 12, 1.4, 1.4), "#2b1c26")
A.bezLine(c, { { 32, 12 }, { 20, 2 }, { 40, 2 }, { 45, 8 } }, "#b97a4a", 24)
A.bezLine(c, { { 32, 13 }, { 20, 3 }, { 40, 3 }, { 45, 9 } }, "#864c33", 24)
A.sph(c, 46, 11, 2, "#f5b82e", {})
A.fin()

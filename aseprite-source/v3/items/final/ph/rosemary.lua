-- rosemary (first draft, Sonnet). Three slim woody rosemary sprigs fanned from a tied base, lined with narrow
-- dark-green needles (silver underside glint) and dotted with small blue-violet flowers.
-- quirk: the bundle is tied with a red twine bow.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rosemary")
local floor, sin, cos = math.floor, math.sin, math.cos
local sprigs = { { 28, 57, 47, 9 }, { 28, 57, 30, 5 }, { 28, 57, 12, 12 } }
for _, s in ipairs(sprigs) do A.rod(c, s[1], s[2], s[3], s[4], .8, "#8a5a3a", { amb = .15 }) end
for si, s in ipairs(sprigs) do
  local dx, dy = s[3] - s[1], s[4] - s[2] local l = math.sqrt(dx * dx + dy * dy) local ang = math.atan(dy, dx)
  for t = .3, 1.0, .055 do
    local x, y = s[1] + dx * t, s[2] + dy * t
    local len = 6 - (t - .3) * 3
    A.needle(c, x, y, ang - .8, len, "#2f6a4a", "#8fc0a8") A.needle(c, x, y, ang + .8, len, "#3f7a54", "#8fc0a8")
  end
  A.needle(c, s[3], s[4], ang, 4, "#3f7a54", "#8fc0a8")
  A.sph(c, floor(s[3] - dx * .12), floor(s[4] - dy * .12), 1.6, "#8aa0f0", { nospec = true })
  A.sph(c, floor(s[1] + dx * .5), floor(s[2] + dy * .5), 1.4, "#a8b8ff", { nospec = true })
end
-- twine
for y = 46, 48 do for x = 25, 31 do c:px(x, y, y == 47 and "#e8493b" or "#b52e3f") end end
A.sph(c, 24, 49, 2, "ember", { nospec = true }) A.sph(c, 32, 49, 2, "ember", { nospec = true })
A.ln(c, 28, 49, 26, 53, "#e8493b") A.ln(c, 29, 49, 32, 53, "#b52e3f")
A.fin()

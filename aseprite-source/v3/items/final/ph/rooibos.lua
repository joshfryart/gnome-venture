-- rooibos (first draft, Sonnet). A slim reddish-woody rooibos sprig with side twigs, each ending in a tuft of fine
-- needle leaves (green tipped with red-brown), and a tiny yellow pea flower at the top.
-- quirk: a single dried red needle drifts away from the sprig.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rooibos")
local floor, sin, cos = math.floor, math.sin, math.cos
A.rod(c, 14, 57, 40, 12, 1.0, "#8a4a3a", { amb = .15 })
local function tuft(x, y, a, n, len)
  for i = 1, n do
    local ang = a + (i - (n + 1) / 2) * .35
    A.needle(c, x, y, ang, len, (i % 2 == 0) and "#5c9a52" or "#3f7a44", (i % 3 == 0) and "#c0603a" or "#9bd070")
  end
end
for i = 1, 6 do
  local t = .12 + i * .13
  local sx, sy = 14 + 26 * t, 57 - 45 * t
  local side = (i % 2 == 0) and 1 or -1
  local ex, ey = sx + side * 9, sy - 5
  A.ln(c, floor(sx), floor(sy), floor(ex), floor(ey), "#a05a42")
  tuft(ex, ey, side > 0 and -.5 or -2.6, 5, 6)
end
tuft(40, 12, -1.57, 5, 7)
A.sph(c, 41, 8, 2.4, "#ffd23f", { spec = "#fff4d6" })
c:px(41, 8, "#d98322")
-- drifting needle
A.needle(c, 55, 40, .7, 5, "#c0603a", "#e8493b")
A.fin()

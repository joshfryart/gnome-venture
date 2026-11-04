-- rope (first draft, Sonnet). A neat two-turn coil of twisted tan hemp rope with a tail that trails off to the
-- lower right and ends in a splayed, frayed tip; a red whipping thread bands the tail just before the fray.
-- quirk: the tail's end is unravelled into pale strands.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rope")
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local function ell(cx, cy, rx, ry, a0, a1)
  local out = {}
  local n = floor(math.abs(a1 - a0) / .03)
  for i = 0, n do
    local a = a0 + (a1 - a0) * i / n
    local tx, ty = -rx * sin(a), ry * cos(a) local l = math.sqrt(tx * tx + ty * ty)
    out[#out + 1] = { cx + rx * cos(a), cy + ry * sin(a), tx / l, ty / l }
  end
  return out
end
c:groundShadow(30, 55, 20, 3)
A.rope(c, ell(28, 29, 13, 8.5, 3.6, 3.6 + 2 * pi + .2), 2.6, "#c79a5e")
A.rope(c, ell(28, 29, 21, 15, 2.2, 2.2 + 2 * pi + .1), 2.8, "#c79a5e")
local tail = A.curve({ { 28 + 21 * cos(2.3 + 2 * pi + .1), 29 + 15 * sin(2.3 + 2 * pi + .1) }, { 36, 48 }, { 52, 40 }, { 53, 53 } }, 36)
A.rope(c, tail, 2.6, "#c79a5e")
-- whipping
for i = 0, 1 do
  local p = tail[#tail - 4 - i * 2]
  A.ln(c, floor(p[1] - 3), floor(p[2]), floor(p[1] + 3), floor(p[2]), i == 0 and "#e8493b" or "#b52e3f")
end
-- fray
local e = tail[#tail]
for k = -3, 3 do A.needle(c, e[1] + k * .8, e[2] + 1, 1.57 + k * .18, 4 + (k % 2), "#e8c890", "#fff4d6") end
A.fin()

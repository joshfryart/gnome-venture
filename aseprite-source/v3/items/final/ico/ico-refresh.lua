local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-refresh: two chunky green arrows chasing each other in a circle.
-- quirk: a small leaf sprouts in the gap between the arrow tail and the next head.
local c = D.new("ico-refresh")
local cx, cy, ro, ri = 32, 32, 20, 11
local function arc(a0, a1)
  local m = HP.mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local d = sqrt(dx * dx + dy * dy)
    local a = math.deg(math.atan(dy, dx)) % 360
    if d >= ri and d <= ro and a >= a0 and a <= a1 then m:set(x, y) end
  end end
  return m
end
local function head(a)
  local t = math.rad(a)
  local rm = (ro + ri) / 2
  local px, py = cx + cos(t) * rm, cy + sin(t) * rm
  local tx, ty = -sin(t), cos(t)
  local nx, ny = cos(t), sin(t)
  return c:poly{ { floor(px + nx * 10 + .5), floor(py + ny * 10 + .5) }, { floor(px - nx * 10 + .5), floor(py - ny * 10 + .5) }, { floor(px + tx * 11 + .5), floor(py + ty * 11 + .5) } }
end
local a1 = arc(200, 340):add(head(342))
local a2 = arc(20, 160):add(head(162))
D.lit(c, a1, D.GRN, 6, { amb = 0.06 })
D.lit(c, a2, D.GRN, 6, { amb = 0.06 })
D.pts(c, { {19, 20}, {20, 19}, {21, 18}, {22, 17}, {23, 16} }, D.GRN[6])
D.pts(c, { {44, 46}, {43, 47}, {42, 48}, {41, 49} }, D.GRN[2])
-- sprout leaf in the gap
D.leaf(c, 51, 26, 58, 18, 3, D.YEL, {})
D.leaf(c, 12, 38, 5, 46, 3, D.YEL, {})
D.fin()

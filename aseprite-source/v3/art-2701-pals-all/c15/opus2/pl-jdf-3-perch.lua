-- Jade Shimmer (pl-jdf-3), perch sprite 36x36. Opus second pass (c15/opus2), hand-built at this size.
-- Brilliant-cut jade octagon: flat table facet holding the face (2x3 pill eyes), one ring of 8 facets toned by
-- how they face the upper-left light, light seams on the lit side, two stubby feet.
-- quirk: glitter flecks on the ground and one stuck on its cheek.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-3-perch", 36)

local JADE = { "#173f36", "#22604a", "#33895a", "#58b468", "#98dc84", "#dcf6b8" }
local CX, CY, R = 18, 16, 11
local function octR(th)
  local a = (th + math.pi / 8) % (math.pi / 4) - math.pi / 8
  return R / math.cos(a)
end
c:groundShadow(18, 31, 10, 1)
for _, fx in ipairs({ 13, 23 }) do
  O.shade(c, c:ellipse(fx, 28, 2, 1.5), JADE, { R = 1, amb = .3, wrap = .4, cuts = { .2, .4, .6, .8, .95 } })
end
local tok = { r = { name = "gem" } }
local zone = {}
local LX, LY = -.62, -.78
for y = 2, 30 do for x = 4, 32 do
  local dx, dy = x + .5 - CX, y + .5 - CY
  local th = math.atan(dy, dx)
  local rr = math.sqrt(dx * dx + dy * dy) / octR(th)
  if rr <= 1 then
    local i, z
    if rr < .58 then i, z = 4, "t"
    else
      local s = math.floor((th + math.pi + math.pi / 8) / (math.pi / 4)) % 8
      local mid = -math.pi + s * math.pi / 4
      local d = math.cos(mid) * LX + math.sin(mid) * LY
      i, z = math.max(1, math.min(6, 3 + math.floor(d * 2.2 + .5))), s
    end
    zone[K(x, y)] = z
    c:put(x, y, JADE[i], tok)
  end
end end
local seams = {}
for k, z in pairs(zone) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local zr, zd = zone[K(x + 1, y)], zone[K(x, y + 1)]
  if (zr ~= nil and zr ~= z) or (zd ~= nil and zd ~= z) then seams[#seams + 1] = { x, y } end
end
for _, p in ipairs(seams) do
  local lit = (p[1] + .5 - CX) * LX + (p[2] + .5 - CY) * LY
  c.pix[p[2] * c.w + p[1]] = (lit > -1) and JADE[6] or JADE[2]
end
O.mark(c, { { 13, 11 }, { 14, 11 }, { 13, 12 } }, JADE[5])
O.mark(c, { { 22, 21 }, { 23, 20 } }, JADE[3])

c:eyeSmall(14, 14)
c:eyeSmall(20, 14)
O.dot(c, 12, 18, P.petal.base) O.dot(c, 24, 18, P.petal.base)
O.mark(c, { { 17, 19 }, { 18, 19 } }, P.ink)
O.mark(c, { { 25, 17 } }, "#fff0a0")

O.done(c, "pl-jdf-3-perch", function(c)
  c:sparkle(5, 5) c:sparkle(31, 8)
  for _, p in ipairs({ { 4, 31 }, { 6, 33 }, { 30, 33 }, { 32, 30 } }) do c:put(p[1], p[2], "#98dc84") end
  c:put(31, 32, "#fff0a0")
end)

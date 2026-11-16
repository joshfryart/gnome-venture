-- Jade Shimmer (pl-jdf-3), perch sprite 36x36. Opus richness pass (c15/opus3), hand-built at this size.
-- Brilliant-cut jade octagon: flat table facet holding the face (2x3 pill eyes), one ring of 8 facets toned by
-- how they face the upper-left light (one lower-right cel shade, mid tones kept on the shade side), light seams on
-- the lit side, a table glint, rim light and cool bounce, two stubby feet.
-- quirk: glitter flecks on the ground and one stuck on its cheek; a 3-px rainbow cast beside its foot.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-3-perch", 36)

local JADE = { "#143440", "#1d5a52", "#2d8458", "#55ad5e", "#96d478", "#def4aa" }
local BOUNCE = "#4f8eaa"
local CX, CY, R = 18, 16, 11
local function octR(th)
  local a = (th + math.pi / 8) % (math.pi / 4) - math.pi / 8
  return R / math.cos(a)
end
c:groundShadow(18, 31, 10, 1)
for _, fx in ipairs({ 13, 23 }) do
  O.shade(c, c:ellipse(fx, 28, 2, 1.5), JADE, { R = 1, amb = .3, wrap = .4, cuts = { .2, .4, .6, .8, .95 }, bounce = BOUNCE, bmax = 3 })
end
local tok = { r = { name = "gem" } }
local zone, idx = {}, {}
local LX, LY = -.62, -.78
for y = 2, 30 do for x = 4, 32 do
  local dx, dy = x + .5 - CX, y + .5 - CY
  local th = math.atan(dy, dx)
  local rr = math.sqrt(dx * dx + dy * dy) / octR(th)
  if rr <= 1 then
    local i, z
    if rr < .58 then
      local d = (dx * LX + dy * LY) / (R * .58)
      i, z = (d > .45 and 5 or 4), "t"
    else
      local s = math.floor((th + math.pi + math.pi / 8) / (math.pi / 4)) % 8
      local mid = -math.pi + s * math.pi / 4
      local d = math.cos(mid) * LX + math.sin(mid) * LY
      i, z = (d > .55 and 5 or d > -.05 and 4 or 3), s
      if d < -.3 and rr > .9 then i = 2 end
    end
    zone[K(x, y)] = z
    idx[K(x, y)] = i
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
c._lit = c._lit or {}
c._lit[#c._lit + 1] = { idx = idx, tok = tok, ramp = JADE, rim = true, bounce = BOUNCE, bmax = 3 }
-- table glint and a gold shimmer fleck in the stone
O.mark(c, { { 12, 10 }, { 13, 10 }, { 12, 11 } }, JADE[6])
O.mark(c, { { 26, 23 } }, "#f5cf4e")

c:eyeSmall(14, 14)
c:eyeSmall(20, 14)
O.dot(c, 12, 18, P.petal.base) O.dot(c, 24, 18, P.petal.base)
O.mark(c, { { 17, 19 }, { 18, 19 } }, P.ink)
O.mark(c, { { 25, 16 } }, "#fff0a0")

O.done(c, "pl-jdf-3-perch", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  c:sparkle(4, 5) c:sparkle(32, 6)
  for _, p in ipairs({ { 3, 30 }, { 5, 33 }, { 2, 22 } }) do put(p[1], p[2], "#96d478") end
  put(4, 27, "#fff0a0")
  -- tiny rainbow thrown on the ground, lower right
  for i, h in ipairs({ "#e8493b", "#f5cf4e", "#55ad5e", "#4a86cc" }) do put(28 + i, 33, h) end
end)

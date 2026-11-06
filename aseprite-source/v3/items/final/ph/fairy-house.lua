-- fairy-house (final, Opus single pass). A slim round plank tower under a tall scalloped-shingle witch-hat roof
-- whose tip flops to the right. Planks: vertical-cylinder light, plank seams, wood grain and knots; a deep shadow
-- band under the eave overhang. Roof: 6-tone dusk ramp, cone light, overlapping scallop rows (dark lower lip, lit
-- top), gold finial bead. Arched door (darker plank wood, iron strap, gold knob) on a flat stone step; a round
-- glowing window with a cross bar; rounded foundation stones. Ground shadow (it stands). Draft by Sonnet replaced.
-- quirk: a tiny red toadstool has sprouted right beside the door step, as if it lives there too.
local NAME = "fairy-house"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local WOOD  = { "#4a2a26", "#6e3e2c", "#94593a", "#b97a4a", "#d69c62", "#ecc48a" }
local DOOR  = { "#2f1c22", "#4a2a26", "#6a3a2a", "#8a5034" }
local ROOF  = { "#2a2050", "#3d2f72", "#5a459e", "#7560bf", "#9583da", "#c2b0f2" }
local STONE = { "#3e3f58", "#5e5f78", "#86879c", "#aaa9b8", "#cfcdd8", "#ecebf0" }
local GLOW  = { "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }
local GOLD, IRON = "#f5b82e", "#444663"

c:groundShadow(32, 57, 15, 2)

-- foundation stones (row of rounded stones), drawn as a band then split
local CX, X0, X1 = 32, 22, 42
local fnd = c:rect(X0 - 1, 52, X1 + 1, 56)
local stok = { r = { name = "stone" } }
local sidx = A.shade(c, fnd, (function()
  local n = {}
  fnd:each(function(x, y)
    local cell = floor((x - X0 + 1 + (y > 54 and 2 or 0)) / 4)
    local lx = (x - X0 + 1 + (y > 54 and 2 or 0)) - cell * 4 - 1.5
    local ly = (y > 54) and (y - 55.5) or (y - 53)
    local nx, ny = lx / 2.4, ly / 1.8
    local q = max(0.05, 1 - nx * nx - ny * ny)
    n[K(x, y)] = { A.norm(nx * 0.8 + (x - CX) / 26, ny * 0.8, sqrt(q)) }
  end)
  return n end)(), STONE, { amb = 0.1, wrap = 0.3, tok = stok })
fnd:each(function(x, y)
  local o = (y > 54) and 2 or 0
  if (x - X0 + 1 + o) % 4 == 0 or y == 54 then c:put(x, y, STONE[1], stok) end
end)

-- tower body: vertical cylinder of planks
local body = HP.mask()
for y = 30, 51 do
  local h = 10.5 - (y - 30) * 0.02
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end
end
local bn = {}
body:each(function(x, y) local t = max(-0.96, min(0.96, (x - CX + 0.3) / 10.8)) bn[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local bb = {}
body:each(function(x, y) if y <= 32 then bb[K(x, y)] = -2 elseif y == 33 then bb[K(x, y)] = -1 end end)
local wtok = { r = { name = "planks" } }
local bidx = A.shade(c, body, bn, WOOD, { amb = 0.08, wrap = 0.3, bias = bb, tok = wtok })
-- plank seams + grain + knot
body:each(function(x, y) local k = K(x, y)
  local col = x - X0
  if col % 4 == 0 then c:put(x, y, WOOD[max(1, bidx[k] - 2)], wtok)
  elseif col % 4 == 1 and bidx[k] >= 3 and y > 33 then c:put(x, y, WOOD[min(6, bidx[k] + 1)], wtok)   -- lit plank edge
  elseif X.hash(col // 4, floor((y + col * 3) / 5), 4) > 0.72 and col % 4 == 2 then c:put(x, y, WOOD[max(1, bidx[k] - 1)], wtok) end
end)
c:put(25, 46, WOOD[2]) c:put(26, 46, WOOD[1]) c:put(25, 45, WOOD[3])  -- knot

-- door: arched, centred slightly left, stone step
local door = c:rect(28, 42, 34, 51):add(c:ellipse(31, 42, 3, 3)):clip(c:rect(28, 38, 34, 51))
local dtok = { r = { name = "door" } }
door:each(function(x, y)
  local i = 3
  if x == 28 or y <= 40 then i = 2 end
  if x == 34 then i = 1 end
  if x == 31 then i = 1 end
  if x == 29 or x == 32 then i = 4 end
  c:put(x, y, DOOR[i], dtok)
end)
-- door frame: lit arch on the left/top
for _, p in ipairs{ { 27, 44 }, { 27, 45 }, { 27, 46 }, { 27, 47 }, { 27, 48 }, { 27, 49 }, { 27, 50 }, { 27, 51 }, { 27, 43 }, { 27, 42 },
  { 28, 40 }, { 28, 39 }, { 29, 38 }, { 30, 38 }, { 31, 38 }, { 32, 38 }, { 33, 38 }, { 34, 39 }, { 34, 40 }, { 35, 42 } } do
  if not door:has(p[1], p[2]) then c:put(p[1], p[2], WOOD[6], dtok) end end
for y = 41, 51 do if not door:has(35, y) then c:put(35, y, WOOD[2], dtok) end end
-- iron strap hinges + gold knob
for x = 28, 33 do c:put(x, 44, IRON) c:put(x, 49, IRON) end
c:put(28, 44, "#74758c") c:put(28, 49, "#74758c")
c:put(33, 46, GOLD) c:put(33, 47, "#d98322") c:put(32, 46, "#ffe38a")
-- step
for x = 27, 35 do c:put(x, 52, STONE[5]) c:put(x, 53, STONE[3]) end
c:put(27, 52, STONE[6]) c:put(35, 53, STONE[2]) c:put(35, 52, STONE[4])

-- round window, right, with warm glow and a cross bar
local win = c:ellipse(38.5, 38.5, 2, 2)
win:each(function(x, y) local d = (x - 38) + (y - 38)
  c:put(x, y, d < -1 and GLOW[4] or (d < 1 and GLOW[3] or GLOW[2])) end)
for x = 37, 40 do c:put(x, 38, "#6e3e2c") end
for y = 37, 40 do c:put(38, y, "#6e3e2c") end
c:put(37, 37, GLOW[4])
win:grow(1):cut(win):each(function(x, y) c:put(x, y, (x + y < 77) and WOOD[2] or WOOD[1]) end)

-- roof: tall cone, flopped tip
local Y0, YE = 9, 33
local roof = HP.mask()
local RC, RH = {}, {}
for y = Y0, YE do
  local u = (y - Y0) / (YE - Y0)
  local cx = CX + max(0, (15 - y)) ^ 1.45 * 0.42
  local h = 15.5 * u ^ 1.1 + 0.6
  if y >= YE - 1 then h = h + 1 end
  RC[y], RH[y] = cx, h
  for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do roof:set(x, y) end
end
local rn = {}
roof:each(function(x, y) local t = max(-0.95, min(0.95, (x - RC[y]) / (RH[y] + 0.6)))
  rn[K(x, y)] = { A.norm(t, -0.45, sqrt(1 - t * t)) } end)
local rtok = { r = { name = "roof" } }
local ridx = A.shade(c, roof, rn, ROOF, { amb = 0.08, wrap = 0.25, tok = rtok })
-- shingle scallops: rows every 4 px; each scallop 4 px wide, offset per row
roof:each(function(x, y) local k = K(x, y)
  if y < 12 then return end
  local row = floor((y - 12) / 4)
  local ry = (y - 12) % 4
  local ox = (row % 2) * 2
  local sx = (x - floor(RC[y]) + ox + 64) % 4
  local lip = (ry == 3) or (ry == 2 and (sx == 0 or sx == 3))
  if lip then c:put(x, y, ROOF[max(1, ridx[k] - 2)], rtok)
  elseif ry == 0 and (sx == 1 or sx == 2) and ridx[k] >= 3 then c:put(x, y, ROOF[min(6, ridx[k] + 1)], rtok) end
end)
-- eave: dark underside row and a pale front edge
for x = floor(RC[YE] - RH[YE] + 0.5), floor(RC[YE] + RH[YE] - 0.5) do c:put(x, YE, ROOF[1], rtok) end
-- tip: gold finial bead
c:put(floor(RC[Y0] + 0.5) + 1, Y0, GOLD) c:put(floor(RC[Y0] + 0.5) + 2, Y0, "#d98322") c:put(floor(RC[Y0] + 0.5) + 1, Y0 - 1, "#ffe38a")
-- roof specular
c:put(26, 22, ROOF[6]) c:put(27, 22, "#e6dcff")

-- quirk: tiny toadstool beside the step (right)
for _, q in ipairs{ { 37, 52, "#e2e0e6" }, { 37, 53, "#aaa9b8" }, { 36, 51, "#e8493b" }, { 37, 51, "#e8493b" }, { 38, 51, "#b52e3f" },
  { 37, 50, "#ff8a5c" }, { 36, 50, "#e8493b" }, { 38, 50, "#e8493b" }, { 37, 50, "#fff4d6" } } do c:put(q[1], q[2], q[3]) end
-- grass tufts at the foot
for _, q in ipairs{ { 21, 56, "#3f9150" }, { 21, 55, "#7cc35a" }, { 43, 56, "#3f9150" }, { 44, 55, "#7cc35a" }, { 20, 55, "#3f9150" } } do c:put(q[1], q[2], q[3]) end
A.save(c, NAME)

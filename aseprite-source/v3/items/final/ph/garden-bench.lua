-- garden-bench (aB33_0, Opus single pass). A slim teak garden bench, front view with the seat top showing:
-- arched top rail and a lower back slat between two posts, two-plank seat over a front apron, square front legs,
-- set-back rear legs, low stretcher, curled armrests on short posts. Bevelled planks lit per pixel, streaky grain,
-- pale end grain with a ring on the plank ends, AO and contact shadow wherever parts meet, ground shadow.
-- quirk: someone left a tiny terracotta pot with a seedling on the seat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local NAME = "garden-bench"
local c = A.new(NAME)
local TEAK = { "#4a2422", "#6d3527", "#94502f", "#b8703d", "#d6974f", "#efc277" }
local POT  = { "#5a2228", "#8a3330", "#b44d36", "#d46d42", "#ec9258", "#fbbd82" }
local SOIL = { "#2b1a1d", "#432820", "#5f3a27" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local R = HP.rect

c:groundShadow(32, 54, 25, 2)

-- parts in back-to-front order: { mask, grain dir ("h"/"v"), normal tilt (top faces look up), end-grain side }
local function arch(x0, x1, ytop, ybot, rise)
  local m = HP.mask()
  for x = x0, x1 do local f = (x - (x0 + x1) / 2) / ((x1 - x0) / 2)
    local yt = floor(ytop - rise * (1 - f * f) + 0.5)
    if abs(f) > 0.93 then yt = yt + 1 end
    for y = yt, ybot do m:set(x, y) end end
  return m
end
local parts = {
  { m = R(14, 42, 16, 50), g = "v", id = 1, back = true },             -- rear legs (set back)
  { m = R(47, 42, 49, 50), g = "v", id = 2, back = true },
  { m = R(12, 11, 14, 33), g = "v", id = 3 },                          -- back posts
  { m = R(49, 11, 51, 33), g = "v", id = 4 },
  { m = R(14, 20, 49, 22), g = "h", id = 5 },                          -- lower back slat
  { m = arch(10, 53, 12, 16, 2.4), g = "h", id = 6, ends = true },      -- arched top rail
  { m = R(12, 46, 51, 47), g = "h", id = 7, back = true },             -- stretcher
  { m = R(7, 31, 56, 33), g = "h", id = 8, top = true, ends = true },  -- seat plank (back)
  { m = R(7, 35, 56, 37), g = "h", id = 9, top = true, ends = true },  -- seat plank (front)
  { m = R(8, 38, 55, 41), g = "h", id = 10, ends = true },             -- apron
  { m = R(8, 42, 11, 54), g = "v", id = 11 },                          -- front legs
  { m = R(52, 42, 55, 54), g = "v", id = 12 },
  { m = R(8, 25, 10, 30), g = "v", id = 13 },                          -- arm posts
  { m = R(53, 25, 55, 30), g = "v", id = 14 },
  { m = R(6, 23, 14, 24):add(R(6, 25, 7, 25)), g = "h", id = 15, ends = true },   -- armrests with curled tips
  { m = R(49, 23, 57, 24):add(R(56, 25, 57, 25)), g = "h", id = 16, ends = true },
}
-- gap between seat planks (dark shadow line, drawn as part of the back plank's underside)
parts[8].m:add(R(8, 34, 55, 34))

-- quirk pot (on the front seat plank, right of centre)
local pot = HP.mask()
for y = 26, 34 do local hw = y <= 27 and 4 or (3.4 - (y - 28) * 0.22)
  for x = floor(43.5 - hw + 0.5), floor(43.5 + hw - 0.01) do pot:set(x, y) end end
local all = HP.mask()
for _, p in ipairs(parts) do all:add(p.m) end

local tok = { r = { name = "teak" } }
for i, p in ipairs(parts) do
  local vis = p.m
  local n = X.pillow(vis, 1.5)
  if p.top then for k, nn in pairs(n) do n[k] = { A.norm(nn[1], nn[2] - 0.75, nn[3]) } end end
  local b = {}
  -- AO / contact shadow from every part in front, and from the pot
  for j = i + 1, #parts do X.ao(b, vis, parts[j].m, 1, -1) A.cast(b, vis, parts[j].m, 1, 1, -1) end
  X.ao(b, vis, pot, 1, -1) A.cast(b, vis, pot, 1, 1, -1)
  if p.back then for k in pairs(n) do b[k] = (b[k] or 0) - 1 end end
  -- grain: streaks broken by hash
  local x0, y0, x1, y1 = vis:bbox()
  vis:each(function(x, y) local k = K(x, y)
    if p.g == "h" then
      if y > y0 and y < y1 and (y - y0) % 2 == 1 and X.hash(floor((x + y * 3) / 4), y, p.id) > 0.6 then b[k] = (b[k] or 0) - 1 end
    else
      if x == x0 + 1 + (p.id % 2) and X.hash(x, floor(y / 4), p.id) > 0.5 and y > y0 + 1 and y < y1 - 1 then b[k] = (b[k] or 0) - 1 end
    end
  end)
  if p.id == 8 then vis:each(function(x, y) if y == 34 then b[K(x, y)] = -9 end end) end
  A.tone(c, vis, n, TEAK, { bias = b, tok = tok, amb = 0.14, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 } })
  -- pale end grain + growth ring on the left ends of horizontal planks
  if p.ends then
    for y = y0, y1 do if vis:has(x0, y) and not (p.id == 8 and y == 34) then c:put(x0, y, TEAK[5], tok) end end
    if y1 - y0 >= 2 then c:put(x0, floor((y0 + y1) / 2), TEAK[3], tok) end
  end
end
-- knots
c:put(24, 36, TEAK[2], tok) c:put(25, 36, TEAK[3], tok) c:put(23, 36, TEAK[4], tok)
c:put(36, 14, TEAK[2], tok) c:put(37, 14, TEAK[3], tok)
-- nail heads where the slats meet the posts
for _, q in ipairs{ { 13, 21 }, { 50, 21 }, { 9, 39 }, { 54, 39 } } do c:put(q[1], q[2], TEAK[1], tok) c:put(q[1] - 1, q[2] - 1, TEAK[5], tok) end

-- pot: tapered terracotta, rolled rim band, soil, seedling
local ptok = { r = { name = "pot" } }
local pn = {}
pot:each(function(x, y) local t = max(-0.95, min(0.95, (x - 43.5) / 4.6)) pn[K(x, y)] = { t, y <= 27 and -0.25 or 0.1, sqrt(1 - t*t) } end)
local pb = {}
pot:each(function(x, y) if y == 28 then pb[K(x, y)] = -2 end end) -- shadow under the rim
A.tone(c, pot, pn, POT, { bias = pb, tok = ptok, amb = 0.12, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 } })
for x = 41, 46 do c:put(x, 26, (x < 43) and SOIL[3] or SOIL[2], ptok) end
c:put(40, 29, POT[6], ptok) c:put(40, 30, POT[5], ptok)
local stok = { r = { name = "sprout" } }
for y = 21, 25 do c:put(43, y, y < 23 and LEAF[5] or LEAF[4], stok) end
for _, q in ipairs{ { 41, 20, 5 }, { 42, 20, 6 }, { 40, 21, 4 }, { 41, 21, 5 }, { 42, 21, 4 },
                    { 44, 21, 4 }, { 45, 21, 3 }, { 45, 20, 5 }, { 46, 20, 4 }, { 46, 21, 2 } } do
  c:put(q[1], q[2], LEAF[q[3]], stok) end

A.save(c, NAME)

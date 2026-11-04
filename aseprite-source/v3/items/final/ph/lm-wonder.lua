-- lm-wonder (final, Opus single pass aC21_1). A slim standing-stone gate: two chiselled pillars with small capitals
-- carrying a lilac capstone, on a turf plinth; a faceted gold wonder-star hovers in the gap and lights the grass.
-- Material: per-pixel pillow light (6-tone stone, 6-tone lilac capstone), block joints with lit lip, weather pits, a
-- hairline crack, carved rune with a gold inlay, AO under the capstone and at the pillar feet, grass cap over soil.
-- quirk: a thin ivy tendril with two leaves is climbing the left pillar.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new("lm-wonder")
local STONE = { "#34354f", "#4b4d69", "#686a86", "#8b8ca6", "#b2b2c5", "#dedde6" }
local LIL   = { "#3a2a52", "#55407a", "#71599b", "#917cba", "#b6a6d8", "#e0d6f2" }
local GOLD  = { "#7a361c", "#b8601f", "#e48f22", "#f7b92e", "#ffd960", "#fff2b4" }
local MOSS  = { "#1f4a3c", "#2e6a44", "#45904c", "#6ab455", "#98d06a", "#c8e88a" }
local SOIL  = { "#3a2229", "#55332c", "#77493a", "#9a6748", "#b98a5e", "#d9b07e" }
local IVY   = { "#24544a", "#3f9150", "#7cc35a" }

-- turf plinth: soil slab with a ragged grass cap
local base = c:rrect(9, 47, 55, 55, 3)
base:cut(c:rect(9, 54, 11, 55)):cut(c:rect(53, 54, 55, 55))
local bn = X.pillow(base, 3)
local grass, soil = HP.mask(), HP.mask()
base:each(function(x, y)
  local lip = 50 + ((X.hash(x, 3) > 0.55) and 1 or 0)
  if y <= lip then grass:set(x, y) else soil:set(x, y) end
end)
-- tufts poking up
for _, t in ipairs{ { 12, 46 }, { 20, 46 }, { 25, 46 }, { 25, 45 }, { 38, 46 }, { 51, 46 }, { 52, 45 } } do
  grass:set(t[1], t[2]) bn[K(t[1], t[2])] = { -0.3, -0.6, 0.74 }
end
local gb = {}
grass:each(function(x, y) if x >= 27 and x <= 37 and y <= 48 then gb[K(x, y)] = 1 end end) -- star light on the grass
A.shade(c, soil, bn, SOIL, { bias = {} })
A.shade(c, grass, bn, MOSS, { bias = gb })
for x = 10, 54 do if soil:has(x, 52) and X.hash(x, 9) > 0.7 then c:put(x, 53, SOIL[2]) end end -- pebbles / roots

-- pillars with capitals
local function pillar(x0, joints, crack)
  local m = c:rect(x0, 21, x0 + 5, 49):add(c:rect(x0 - 1, 19, x0 + 6, 21))
  local n = X.pillow(m, 2)
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    if y >= 22 and y <= 23 then bias[k] = -1 end              -- under the capital
    if y >= 47 then bias[k] = (bias[k] or 0) - 1 end            -- feet in the grass
    if y >= 19 and y <= 20 then bias[k] = (bias[k] or 0) - (y == 20 and 0 or 0) end
    if X.hash(x, y, x0) > 0.93 and y > 23 and y < 46 then bias[k] = (bias[k] or 0) - 1 end -- weather pits
  end)
  local idx = A.shade(c, m, n, STONE, { bias = bias })
  -- capital seam
  for x = x0, x0 + 5 do A.step(c, idx, STONE, x, 21, -2) end
  -- block joints: groove + lit lip below
  for _, j in ipairs(joints) do
    for x = x0, x0 + 5 do A.step(c, idx, STONE, x, j, -2) if x < x0 + 4 then A.step(c, idx, STONE, x, j + 1, 1) end end
  end
  if crack then A.pline(c, crack, STONE[2]) end
  return m, idx
end
local lp = pillar(16, { 31, 41 })
local rp = pillar(43, { 28, 38 }, { { 46, 30 }, { 47, 32 }, { 46, 34 }, { 47, 35 } })

-- capstone
local cap = c:rrect(10, 11, 54, 18, 2)
local cn = X.pillow(cap, 2.5)
local cb = {}
cap:each(function(x, y) if y == 18 and ((x >= 15 and x <= 23) or (x >= 42 and x <= 50)) then cb[K(x, y)] = -1 end end)
local ci = A.shade(c, cap, cn, LIL, { bias = cb })
-- chisel streaks along the slab
for _, s in ipairs{ { 14, 20, 13 }, { 41, 49, 16 }, { 24, 27, 16 } } do for x = s[1], s[2] do A.step(c, ci, LIL, x, s[3], -1) end end
-- carved rune: diamond groove with lit lip, gold inlay
local RX, RY = 32, 14
for _, d in ipairs{ { 0, -2 }, { 1, -1 }, { 2, 0 }, { 1, 1 }, { 0, 2 }, { -1, 1 }, { -2, 0 }, { -1, -1 } } do
  c:put(RX + d[1], RY + d[2], LIL[1])
end
c:put(RX + 1, RY + 3, LIL[5]) c:put(RX + 3, RY + 1, LIL[4]) c:put(RX + 2, RY + 2, LIL[5])
c:put(RX, RY, GOLD[5]) c:put(RX, RY + 1, GOLD[3]) c:put(RX + 1, RY, GOLD[4])
-- hard edge highlight along the capstone's top-left
for x = 13, 22 do if cap:has(x, 11) then c:put(x, 11, LIL[6]) end end

-- wonder-star, floating
local sm, sn = A.star(32, 33, 6.5, 9.5, 0.6, 1.3)
local si = A.shade(c, sm, sn, GOLD, { amb = 0.18 })
c:put(31, 30, GOLD[6]) c:put(31, 31, GOLD[6]) c:put(32, 33, "#fff8d8")
c:sparkle(24, 25)

-- quirk: ivy tendril up the left pillar
local vine = { { 17, 48 }, { 16, 46 }, { 17, 44 }, { 16, 42 }, { 16, 40 }, { 17, 38 }, { 16, 36 } }
A.pline(c, vine, IVY[2])
c:put(17, 47, IVY[1]) c:put(17, 43, IVY[1])
A.map(c, { ".gg", "ggd", ".d." }, 13, 40, { g = IVY[3], d = IVY[1] })
A.map(c, { "gg.", "gdd" }, 14, 34, { g = IVY[3], d = IVY[2] })
c:put(15, 36, IVY[2])
A.save(c, "lm-wonder")

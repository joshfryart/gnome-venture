-- holly-hedge-gate: front view of a holly hedge archway (two slim pillars joined by a clipped arch) with a little
-- slatted wooden gate in the opening. Arch lit per pixel as a rounded lumpy mass, inner edge in ambient shade,
-- dark tunnel behind. Gate: six 3 px pickets with pointed tops (cylinder light, grain flecks), two rails with end
-- grain, a diagonal brace, contact shadows under the rails, iron strap hinges with bolts, ring latch.
-- Soil base with flat stepping stones.
-- quirk: a tiny brass bell hangs from the latch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_1.lua")
local HP, K = A.HP, A.K
local c = A.new("holly-hedge-gate")
local W = A.WOOD
-- hedge arch mask
local m = HP.mask()
for y = 8, 52 do for x = 7, 56 do
  local outer = (y >= 31) or ((x - 31.5) / 25.2)^2 + ((y - 31) / 23.4)^2 <= 1
  local inner = (y >= 31 and x >= 19 and x <= 44) or (y < 31 and ((x - 31.5) / 13)^2 + ((y - 31) / 13.6)^2 <= 1)
  if outer and not inner then m:set(x, y) end
end end
A.spikes(m, { { 0, -1 }, { -1, 0 }, { 1, 0 }, { -1, -1 }, { 1, -1 } }, 17, 0.3, function(x, y) return y >= 50 end)
-- tunnel interior
local hole = HP.mask()
for y = 18, 52 do for x = 19, 44 do if not m:has(x, y) and ((y >= 31) or ((x - 31.5) / 13)^2 + ((y - 31) / 13.6)^2 <= 1) then hole:set(x, y) end end end
local ttok = { r = { name = "tunnel" } }
hole:each(function(x, y) c:put(x, y, (y > 44 and "#24343a") or "#18262c", ttok) end)
-- arch foliage, inner edge darkened
local bias = {}
m:each(function(x, y)
  local k = K(x, y)
  if hole:has(x - 1, y) or hole:has(x + 1, y) or hole:has(x, y + 1) then bias[k] = -2
  elseif hole:has(x - 2, y) or hole:has(x + 2, y) or hole:has(x, y + 2) then bias[k] = -1 end
  if y >= 50 then bias[k] = (bias[k] or 0) - 1 end
end)
A.foliage(m, { mode = "top", R = 4, seed = 41, bias = bias, step = 4 })
-- soil base + stepping stones
local stok = { r = { name = "soil" } }
for y = 53, 55 do for x = 6, 57 do
  if not ((x == 6 or x == 57) and y == 55) then
    local i = (y == 53) and 2 or ((y == 55) and 2 or 3)
    if y == 54 and A.h01(x, y, 5) < 0.25 then i = 4 end
    c:put(x, y, A.SOIL[i], stok)
  end
end end
for _, s in ipairs{ { 22, 27 }, { 29, 34 }, { 36, 41 } } do
  for x = s[1], s[2] do c:put(x, 53, A.STONE[5], stok) c:put(x, 54, A.STONE[3], stok) end
  c:put(s[1], 53, A.STONE[4], stok) c:put(s[2], 54, A.STONE[2], stok) c:put(s[1] + 1, 53, A.STONE[6], stok)
end
-- pickets
local gtok = { r = { name = "gate" } }
local tops = { 33, 31, 30, 30, 31, 33 }
for i = 0, 5 do
  local x0 = 20 + i * 4
  local ty = tops[i + 1]
  c:put(x0 + 1, ty - 1, W[5], gtok)
  for y = ty, 52 do
    c:put(x0, y, y == ty and W[4] or W[5], gtok)
    c:put(x0 + 1, y, W[4], gtok)
    c:put(x0 + 2, y, W[2], gtok)
    if A.h01(x0, y, 9 + i) < 0.18 then c:put(x0 + 1, y, W[3], gtok) end
  end
  c:put(x0 + 1, ty, W[6], gtok)
  c:put(x0 + 2, 52, W[1], gtok) c:put(x0 + 1, 52, W[3], gtok)
end
-- brace (between rails, in front of pickets)
local function ln(x0, y0, x1, y1, f)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do f(math.floor(x0 + (x1 - x0) * i / n + .5), math.floor(y0 + (y1 - y0) * i / n + .5)) end
end
ln(21, 45, 42, 38, function(x, y) c:put(x, y, W[5], gtok) c:put(x, y + 1, W[3], gtok) c:put(x, y + 2, W[1], gtok) end)
-- rails with contact shadow beneath and pale end grain
for _, ry in ipairs{ 35, 46 } do
  for x = 20, 43 do
    c:put(x, ry, W[6], gtok) c:put(x, ry + 1, W[4], gtok) c:put(x, ry + 2, W[3], gtok)
    c:put(x, ry + 3, W[1], gtok)
    if A.h01(x, ry, 3) < 0.22 then c:put(x, ry + 1, W[3], gtok) end
  end
  c:put(43, ry, W[6], gtok) c:put(43, ry + 1, "#f2d4a0", gtok) c:put(43, ry + 2, W[5], gtok)
end
-- iron strap hinges into the left pillar
local itok = { r = { name = "iron" } }
for _, ry in ipairs{ 35, 46 } do
  for x = 17, 25 do c:put(x, ry, A.IRON[5], itok) c:put(x, ry + 1, A.IRON[3], itok) c:put(x, ry + 2, A.IRON[2], itok) end
  c:put(26, ry + 1, A.IRON[2], itok)
  c:put(23, ry + 1, A.IRON[6], itok) c:put(18, ry + 1, A.IRON[6], itok)
end
-- ring latch on the right pillar
for _, p in ipairs{ { 43, 40, 4 }, { 44, 39, 5 }, { 45, 40, 3 }, { 44, 41, 2 } } do c:put(p[1], p[2], A.IRON[p[3]], itok) end
c:put(42, 40, A.IRON[2], itok)
-- quirk: brass bell under the latch
local btok = { r = { name = "bell" } }
A.paint({
  ".l.",
  ".G.",
  "gGs",
  "GGs",
  "SSS",
  ".k.",
}, 43, 42, { l = A.IRON[3], g = "#ffe38a", G = "#f5b82e", s = "#d98322", S = "#8f4a1f", k = "#5e3a2e" }, btok)
c:put(43, 44, A.CREAM)
A.berries({ { 10, 22 }, { 14, 39 }, { 22, 12 }, { 39, 11 }, { 50, 21 }, { 49, 41 }, { 31, 9, { { 0, 0 }, { 3, 0 } } } })
A.fin()

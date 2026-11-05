-- pine-log (lean P1b_O7)
-- Fat horizontal pine log: plated furrowed bark (6-tone brown, cylinder-lit), cut end with growth rings + crack,
-- a snapped branch stub on top. quirk: a tiny green needle sprig sprouts from the stub.
local NAME = "pine-log"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local BARK = { "#2a1618", "#4a2a22", "#6e4030", "#94603c", "#b8814c", "#dca868" }
local WOOD = { "#a8683a", "#d0904c", "#eab466", "#f6d088", "#fde6a8", "#fff4cc" }
local NEED = { "#1d4a36", "#2c6b3e", "#45903f", "#74b84c", "#a6d86a" }
c:groundShadow(34, 47, 25, 3)
-- body: cylinder along x, y 20..41
local body = c:rect(14, 20, 53, 41)
c:rect(53, 22, 54, 39):each(function(x, y) body:set(x, y) end)
body:cut(c:rect(14, 20, 15, 20)); body:cut(c:rect(53, 20, 54, 21)); body:cut(c:rect(53, 40, 54, 41))
local n = {}
body:each(function(x, y)
  local ny = (y - 30.5) / 11.5
  local nz = sqrt(max(0.04, 1 - ny * ny))
  local nx = (x > 48) and (x - 48) / 8 or 0
  n[K(x, y)] = { G.norm(nx, ny, nz) }
end)
local bias = {}
body:each(function(x, y)
  local k = K(x, y)
  local w = y + sin(x * 0.35 + floor(y / 5) * 1.7) * 1.4
  local m4 = w % 4.6
  if m4 < 0.9 and X.hash(floor(x / 6), floor(y / 4), 3) > 0.15 then bias[k] = -2
  elseif m4 < 1.8 then bias[k] = -1
  elseif X.hash(floor(x / 5), floor(y / 3), 8) > 0.72 and m4 > 3.2 then bias[k] = 1 end
  if X.hash(x, y, 5) > 0.93 then bias[k] = (bias[k] or 0) - 1 end
end)
G.toneN(c, body, n, BARK, { bias = bias, amb = 0.1, wrap = 0.2 })
-- top branch stub
local stub = c:rect(32, 15, 36, 21)
stub:cut(c:rect(32, 15, 32, 15))
stub:each(function(x, y) c:put(x, y, (x == 32) and BARK[4] or (x == 36 and BARK[2] or BARK[3])) end)
c:fillMask(c:rect(32, 15, 35, 16), WOOD[3]) c:px(33, 15, WOOD[5]) c:px(36, 15, BARK[1])
c:px(34, 18, BARK[2]) c:px(35, 19, BARK[2])
-- needle sprig (quirk)
local function nd(x0, y0, x1, y1, col) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), col) end
nd(34, 15, 34, 9, NEED[2]) nd(34, 13, 29, 10, NEED[3]) nd(34, 13, 39, 10, NEED[3]) nd(34, 11, 30, 7, NEED[4]) nd(34, 11, 38, 7, NEED[4])
nd(34, 9, 34, 6, NEED[5]) c:px(34, 14, NEED[1]) c:px(32, 11, NEED[2])
-- cut end: ellipse w/ rings
local cap = c:ellipse(14, 31, 6, 11)
local cn = {}
cap:each(function(x, y) cn[K(x, y)] = { G.norm((x - 14) / 7 - 0.1, (y - 31) / 12 - 0.15, 1.4) } end)
local ring = {}
cap:each(function(x, y)
  local d = sqrt(((x - 15) / 6.3) ^ 2 + ((y - 31) / 11.2) ^ 2) * 7.5
  local k = K(x, y)
  if d > 6.6 then ring[k] = -3 elseif floor(d) % 2 == 0 then ring[k] = -1 else ring[k] = 0 end
  if abs(y - 31) < 1 and x > 15 and x < 21 then ring[k] = -3 end -- crack
end)
G.toneN(c, cap, cn, WOOD, { bias = ring, amb = 0.5, wrap = 0.3, cuts = { 0.3, 0.45, 0.6, 0.75, 0.88 } })
c:px(11, 25, WOOD[6]) c:px(12, 24, WOOD[6]) c:px(10, 27, WOOD[5])
cap:edge():each(function(x, y) if x <= 14 and y > 28 then c:px(x, y, BARK[4]) end end)
-- bark highlight streak + AO under the cap rim
for x = 22, 46 do if X.hash(x, 1, 2) > 0.3 then c:px(x, 22, BARK[6]) end end
G.save(c, NAME)

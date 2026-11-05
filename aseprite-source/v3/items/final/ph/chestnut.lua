-- chestnut (lean P1b_O0)
-- quirk: a little silky tuft on the nut's tip and a pale hilum band. Egg-shaped nut in a thin split husk bowl with open cream-lined valves.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "chestnut" }
local pi, sin, cos, floor, max, min, abs, sqrt = math.pi, math.sin, math.cos, math.floor, math.max, math.min, math.abs, math.sqrt
local NUT = { "#2a130f", "#4b2217", "#6f3420", "#964a2a", "#be6a3c", "#e49a62" }
local HUSK = { "#223a1c", "#36602a", "#58872f", "#86ad37", "#bccf48", "#e8ea78" }
local DARKIN = { "#141f12", "#1f321a", "#2e4a22" }
local LINE = { "#8d7f5a", "#b7a878", "#d8cd9c", "#efe6bd", "#fbf5dc" }
local HIL = { "#8f7650", "#b79c6c", "#dcc691", "#f6ead0" }
local SPINE = "#d6cf5c"

local function spines(m, sp, col, seed)
  m:copy():each(function(x, y)
    for _, d in ipairs{ {0,-1}, {-1,0}, {1,0}, {0,1} } do
      local ax, ay = x + d[1], y + d[2]
      if not m:has(ax, ay) and (x * 3 + y * 5) % sp == 0 and X.hash(x, y, seed) > 0.25 then
        c:px(ax, ay, col) c:px(ax + d[1], ay + d[2] + (d[2] == 0 and -1 or 0), col)
      end
    end
  end)
end

-- valves (behind)
local function valve(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) return 1.8 + 3.0 * sin(pi * min(1, t * 1.05)) ^ 0.6 end)
  m:each(function(x, y) local k = K(x, y)
    local s = abs(S[k])
    if s > 0.55 then c:px(x, y, HUSK[(S[k] < 0) and 4 or 2]) else c:px(x, y, LINE[(S[k] < 0) and 4 or 3]) end
  end)
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.12 and T[k] > 0.2 then c:px(x, y, LINE[2]) end end)
  spines(m, 3, SPINE, 5)
  return m
end
valve(15, 42, 9, 33, 13, 19)
valve(49, 42, 55, 33, 51, 19)

-- bowl back interior + front
local E = G.oval(32, 40, 21, 7, 0, 1)
c:fillMask(E, DARKIN[2])
c:fillMask(E:copy():shrink(2), DARKIN[1])

-- nut
local nm, nn = G.oval(32, 29, 13, 16, 0.0, 1.1)
local bias = {}
nm:each(function(x, y) local k = K(x, y)
  if (x + y * 0.12) % 4.6 < 1 and X.hash(x, y, 2) > 0.25 and y < 38 then bias[k] = -1 end
end)
G.toneN(c, nm, nn, NUT, { bias = bias, amb = 0.08, wrap = 0.2, tok = { r = { name = "nut" } } })
local hm, hn = G.oval(32, 39, 9, 4.2, 0, 1.2)
G.toneN(c, G.oval(32, 39, 9, 4.2, 0, 1.2), hn, HIL, { tok = { r = { name = "hil" } } })
-- tip tuft
local tm, tn = G.tube({ {32,14}, {32,11}, {34,9}, {35,6} }, function(t) return 1.9 - 1.4 * t end)
G.toneN(c, tm, tn, NUT, { tok = { r = { name = "nut" } } })
c:px(35, 6, HIL[3]) c:px(34, 7, HIL[4])
local sx, sy = G.specAt(nm, nn, 35)
if sx then c:px(sx, sy, "#fff4e0") c:px(sx, sy + 1, NUT[6]) c:px(sx + 1, sy, NUT[6]) c:px(sx - 1, sy + 1, NUT[5]) end

-- front bowl (covers nut bottom)
local B = G.oval(32, 40, 22, 14, 0, 0.8)
local front, rim = HP.mask(), HP.mask()
B:each(function(x, y)
  local dx = (x - 32) / 21
  if y >= 40 and abs(dx) < 1 then
    local arc = 40 + 7 * sqrt(1 - dx * dx)
    if y > arc then front:set(x, y) end
    if y > arc and y <= arc + 1.2 then rim:set(x, y) end
  end
end)
local fn = {}
local _, bn = G.oval(32, 40, 22, 14, 0, 0.8)
front:each(function(x, y) fn[K(x, y)] = bn[K(x, y)] or { 0, 0, 1 } end)
local bias2 = {}
front:each(function(x, y) if (x * 2 + floor(y * 0.5)) % 5 == 0 and X.hash(x, y, 8) > 0.3 then bias2[K(x, y)] = -1 end end)
G.toneN(c, front, fn, HUSK, { bias = bias2, amb = 0.1, wrap = 0.3, tok = { r = { name = "husk" } } })
rim:each(function(x, y) c:px(x, y, (x < 34) and HUSK[6] or HUSK[5]) end)
spines(front, 3, SPINE, 6)
G.save(c, "chestnut")

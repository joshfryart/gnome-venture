-- wing-dust (lean P1b_O19)
local NAME = "wing-dust"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, n, ramp, o) return G.toneN(c, m, n, ramp, o) end
local function ball(cx, cy, rx, ry, ang, ramp, o) local m, n = G.oval(cx, cy, rx, ry, ang, o and o.flat) tone(m, n, ramp, o) return m, n end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, vein)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) return w * sin(pi * min(1, t)) ^ 0.7 + 0.3 end)
  tone(m, n, ramp)
  if vein then m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.17 and T[k] > 0.08 and T[k] < 0.92 then c:put(x, y, vein) end end) end
  return m
end
local function tube(p, w, ramp) local m, n = G.tube(p, function(t) return type(w) == "function" and w(t) or w end) tone(m, n, ramp) return m end
local function cylrect(x0, y0, x1, y1, ramp)
  local m, n = HP.mask(), {}
  local hw, cx = (x1 - x0 + 1) / 2, (x0 + x1) / 2
  for y = y0, y1 do for x = x0, x1 do m:set(x, y) local nx = max(-0.95, min(0.95, (x - cx) / (hw + 0.3))) n[K(x, y)] = { G.norm(nx, 0, sqrt(1 - nx * nx)) } end end
  tone(m, n, ramp) return m
end

-- wing dust: corked glass vial of iridescent powder, a spilled mound with glitter, a torn wing scrap leaning on it
local GL = { "#33467c", "#5578b2", "#86abd6", "#b8d8ea", "#def2f6", "#f6fdff" }
local PW = { "#262a78", "#4a38a4", "#7a4cc6", "#b068e0", "#e690e8", "#ffc8f2" }
local CK = { "#4a2c1c", "#6e4528", "#94643a", "#b88650", "#d9aa68", "#f0cc90" }
local WG = { "#3a5a96", "#5a86c0", "#86b4dc", "#b4dcf0", "#d8f2f8", "#f4fdff" }
-- wing scrap
local wm = leaf(7, 57, 4, 45, 17, 44, 5.0, WG, WG[2])
wm:each(function(x, y) if (x + y) % 5 == 0 and (x - y) % 3 == 0 then c:px(x, y, "#ffe9a0") end end)
-- vial body
local body, bn = G.oval(33, 41, 14, 14, 0, 1)
local neck = c:rrect(28, 17, 38, 30, 1)
local lip = c:rrect(26, 14, 40, 18, 1)
local vial = body:copy():add(neck):add(lip)
local vn = X.pillow(vial, 7)
tone(vial, vn, GL)
-- powder
local inner = body:copy():shrink(2)
local pw = HP.mask()
inner:each(function(x, y) if y >= 34 + floor(sin(x * 0.7) * 1.2 + 0.5) then pw:set(x, y) end end)
local pn = X.pillow(body, 12)
tone(pw, pn, PW, { amb = 0.15, wrap = 0.2 })
pw:each(function(x, y) local h = X.hash(x, y, 5)
  if h > 0.93 then c:px(x, y, "#7af0de") elseif h < 0.05 then c:px(x, y, "#ffe27a") end end)
-- glass streaks
for y = 33, 46 do c:put(23, y, GL[6]) end
c:put(24, 31, GL[5]) c:put(24, 30, GL[5]) c:put(22, 47, GL[5]) c:put(31, 19, GL[5]) c:put(31, 20, GL[5]) c:put(31, 21, GL[5])
-- cork
local ck = c:rrect(29, 5, 37, 14, 2)
tone(ck, X.pillow(ck, 4), CK)
for _, p in ipairs{ {31, 8}, {34, 10}, {32, 12} } do c:px(p[1], p[2], CK[2]) end
-- spill mound
local mm, mn = G.oval(50, 56, 8, 3.2, 0, 1)
tone(mm, mn, PW)
mm:each(function(x, y) if X.hash(x, y, 9) > 0.8 then c:px(x, y, "#7af0de") end end)
-- sparkles
local function sp(x, y, col) c:px(x, y, col) c:px(x - 1, y, col) c:px(x + 1, y, col) c:px(x, y - 1, col) c:px(x, y + 1, col) end
sp(52, 46, "#ffe27a") sp(9, 30, "#ffe27a") c:px(56, 52, "#7af0de") c:px(47, 50, "#ffc8f2") c:px(14, 36, "#7af0de")

G.save(c, NAME)

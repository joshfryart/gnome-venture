-- wild-strawberries (lean P1b_O19)
local NAME = "wild-strawberries"
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

-- wild strawberries: trifoliate toothed leaves, three little berries on stalks (one still pale green)
local RED = { "#4a0f24", "#7a1a2c", "#b02a30", "#d8453a", "#f2735a", "#ffb08a" }
local PAL = { "#4c6232", "#7c9448", "#aabf68", "#cfdc8c", "#eaf0b0", "#fbfcd4" }
local LF = { "#10382c", "#1c5a36", "#2f7e3e", "#4fa44a", "#7cc65c", "#b0e084" }
local SG = { "#2a5a34", "#4a8040", "#78a858", "#a8cc7c", "#cce6a0", "#e6f6c0" }
local STM = { "#3a5a34", "#5a8040", "#82a456", "#b0c878", "#d0e29c", "#ecf6c0" }
leaf(32, 14, 22, 5, 10, 14, 5.2, LF, LF[6])
leaf(32, 14, 42, 5, 54, 14, 5.2, LF, LF[6])
leaf(32, 14, 28, 6, 33, 1, 3.6, LF, LF[6])
-- leaf teeth
for _, p in ipairs{ {13,10}, {17,8}, {22,8}, {51,10}, {47,8}, {42,8} } do c:px(p[1], p[2], LF[3]) end
tube({ {32, 14}, {28, 20}, {21, 24}, {20, 31} }, 0.9, STM)
tube({ {32, 14}, {36, 22}, {43, 26}, {43, 34} }, 0.9, STM)
tube({ {32, 14}, {31, 26}, {33, 36}, {32, 42} }, 0.9, STM)
local function berry(cx, cy, rx, ry, ramp, seedc, seedd)
  local m, n = ball(cx, cy, rx, ry, pi / 2, ramp, { flat = 0.9 })
  local inner = m:copy():shrink(1)
  inner:each(function(x, y)
    if (x + (y % 2) * 2) % 4 == 0 and y % 3 == 0 then c:px(x, y, seedc) c:px(x, y + 1, seedd) end
  end)
  -- calyx star
  local sx, sy = cx, cy - ry + 1
  for _, a in ipairs{ {-4,-1}, {4,-1}, {-2,2}, {2,2}, {0,-2} } do
    leaf(sx, sy, sx + a[1] * 0.5, sy + a[2] - 1, sx + a[1], sy + a[2], 1.2, SG)
  end
  return m
end
berry(20, 38, 7.5, 8.5, RED, "#ffe27a", "#8a3a22")
berry(43, 40, 7, 8, RED, "#ffe27a", "#8a3a22")
berry(32, 50, 5.5, 6.5, PAL, "#e8d060", "#6a7a34")
c:px(29, 47, "#f0a08a") c:px(30, 46, "#f0a08a") c:px(30, 48, "#e88a7a")
c:px(16, 33, "#fff0e0") c:px(17, 32, "#fff0e0") c:px(40, 35, "#fff0e0") c:px(41, 34, "#fff0e0")

G.save(c, NAME)

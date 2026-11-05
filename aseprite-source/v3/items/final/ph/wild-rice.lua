-- wild-rice (lean P1b_O19)
local NAME = "wild-rice"
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

-- wild rice: three arching stalks, drooping panicles of long dark grains with awns, red cord binding
local ST = { "#4f4f1e", "#7a7430", "#a89c48", "#cdbd68", "#e6d890", "#f7efb8" }
local LF = { "#12382c", "#1f5a38", "#338040", "#55a64c", "#82c862", "#b4e088" }
local GR = { "#1c1218", "#3a2420", "#5e3b2a", "#8a5c36", "#b8864a", "#e0b878" }
local RD = { "#4a0e1e", "#7a1a2a", "#b0302e", "#dc5238", "#f58652", "#ffc088" }
leaf(30, 57, 20, 42, 9, 44, 3.4, LF, LF[6])
leaf(35, 57, 46, 40, 57, 46, 3.2, LF, LF[6])
leaf(32, 57, 24, 46, 17, 36, 2.6, LF, LF[6])
tube({ {30, 57}, {29, 42}, {30, 26}, {34, 11} }, 1.4, ST)
tube({ {33, 57}, {35, 42}, {41, 28}, {47, 17} }, 1.4, ST)
tube({ {31, 57}, {28, 42}, {23, 30}, {20, 19} }, 1.4, ST)
local function panicle(tx, ty, pts)
  for _, p in ipairs(pts) do
    local gx, gy = tx + p[1], ty + p[2]
    G.tube({ {tx, ty + 1}, {tx + p[1] * 0.3, ty + 2}, {tx + p[1] * 0.8, ty + p[2] * 0.3}, {gx, gy - 2} }, 0.45, ST)
    ball(gx, gy, 1.5, 3.0, pi / 2 + (p[1] > 0 and -0.2 or 0.2), GR)
    c:px(gx, gy + 3, ST[4]) c:px(gx + (p[1] > 0 and 1 or -1), gy + 4, ST[3])
    c:px(gx - 1, gy - 1, GR[6])
  end
end
panicle(34, 11, { {-4, 4}, {3, 3}, {-1, 8}, {5, 9}, {-5, 11} })
panicle(47, 17, { {-4, 4}, {3, 3}, {-1, 9}, {5, 9} })
panicle(20, 19, { {-4, 4}, {3, 3}, {-1, 9}, {-5, 11} })
-- cord + bow (quirk)
local cord = cylrect(25, 49, 38, 52, RD)
c:fillMask(c:rect(25, 52, 38, 52), RD[1])
ball(24, 50, 2.5, 1.8, -0.5, RD) ball(40, 50, 2.5, 1.8, 0.5, RD)
tube({ {37, 52}, {40, 55}, {39, 58}, {41, 60} }, 0.8, RD)

G.save(c, NAME)

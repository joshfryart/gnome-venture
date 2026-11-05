-- triticale (lean P1b_O18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local function cl(i, n) return max(1, min(n, i)) end
local NAME = "triticale"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local STK  = { "#34502c", "#4f7a38", "#7aa244", "#a9c35a", "#d2de80", "#eef6b0" }
local LEAF = { "#1c3640", "#274f50", "#376e58", "#52905e", "#7bb374", "#abd68e" }
local GR   = { "#51415a", "#7a5f4a", "#a98648", "#d3ad55", "#efd078", "#fff0a8" }
local AW   = { "#7e6038", "#b8923f", "#e0bc58" }
local tk = { r = { name = "p" } }
c:groundShadow(30, 59, 11, 2)
local function leaf(ax, ay, qx, qy, bx, by, wmax)
  local m, n, T, S = G.blade(ax, ay, qx, qy, bx, by, function(t) if t > 0.99 then return -1 end return 0.5 + wmax * sin(pi * t ^ 0.8) ^ 0.8 end)
  G.toneN(c, m, n, LEAF, { tok = tk })
  m:each(function(x, y) local k = K(x, y) local s = S[k]
    if s and abs(s) < 0.2 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], tk) end end)
end
leaf(29, 47, 15, 38, 6, 47, 3.0)
leaf(30, 41, 44, 31, 56, 40, 2.8)
-- stalk with node
local sm, sn, sT = G.tube({ {30, 58}, {28, 48}, {31, 38}, {33, 30} }, function(t) return 1.8 - 0.5 * t end)
G.toneN(c, sm, sn, STK, { tok = tk })
sm:each(function(x, y) local t = sT[K(x, y)] if abs(t - 0.3) < 0.025 then c:put(x, y, STK[1], tk) elseif abs(t - 0.3) < 0.05 then c:put(x, y, STK[2], tk) end end)
-- ear: grain pairs along a bowed axis
local P = { {33, 30}, {34, 23}, {38, 17}, {43, 15} }
local awns = {}
for i = 8, 1, -1 do
  local t = (i - 0.5) / 8
  local x, y = G.bez(P, t)
  local x2, y2 = G.bez(P, min(1, t + 0.01))
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  local ang = math.atan(ty, tx)
  for _, s in ipairs{ -1, 1 } do
    local gx, gy = x + px * s * 2.0, y + py * s * 2.0
    local m, n = G.oval(gx, gy, 3.0, 1.9, ang + s * 0.3, 0.9)
    G.toneN(c, m, n, GR, { tok = tk })
    m:edge():each(function(ex, ey) c:put(ex, ey, (ex + ey > gx + gy) and GR[1] or GR[2], tk) end)
    if (i + (s > 0 and 1 or 0)) % 2 == 0 then awns[#awns + 1] = { gx + tx * 2.8, gy + ty * 2.8, ang + s * 0.2, i } end
  end
end
for _, a in ipairs(awns) do
  for d = 0, 12 do
    local ax, ay = a[1] + cos(a[3]) * d, a[2] + sin(a[3]) * d
    c:put(floor(ax + 0.5), floor(ay + 0.5), d < 5 and AW[2] or (d % 4 == 3 and AW[1] or AW[3]), tk)
  end
end
-- quirk: dewdrop on the left blade
local dx, dy = floor((0.25 * 29 + 0.5 * 15 + 0.25 * 6) + 0.5), floor((0.25 * 47 + 0.5 * 38 + 0.25 * 47) + 0.5) - 2
c:px(dx, dy, "#f4fcff") c:px(dx + 1, dy, "#8fd2f2") c:px(dx, dy + 1, "#6ab4e6") c:px(dx + 1, dy + 1, "#3a78b8")
G.save(c, NAME)

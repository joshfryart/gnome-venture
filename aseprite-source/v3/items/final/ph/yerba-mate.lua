-- yerba-mate (lean D3o_15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan2 or function(y,x) return math.atan(y,x) end
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local TOK = { r = { name = "p" } }
local c
local function paint(m, n, ramp, tex, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  m:each(function(x, y)
    local k = K(x, y)
    local val = v[k] or 0.5
    local i = 1
    for _, ct in ipairs(CUTS) do if val > ct then i = i + 1 end end
    if tex then i = i + (tex(x, y, k, i) or 0) end
    c:put(x, y, ramp[max(1, min(#ramp, i))], TOK)
  end)
  return v
end
local function hline(pts, hex) G.line(c, pts, hex) end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "yerba-mate" }
local LEAF = { "#14352f", "#1e5a3e", "#2c7c46", "#479a4a", "#72b95a", "#a4d474" }
local STEM = { "#4a2e22", "#704630", "#9a6a40", "#c49060" }
local BER = { "#3a1030", "#661848", "#962a5a", "#c4486a", "#e8788a", "#ffd0d0" }
c:groundShadow(24, 58, 8, 2)
local SP = { {16,56},{18,42},{29,33},{40,18} }
local sm_, sn_ = G.tube(SP, function(t) return 1.4 - 0.5 * t end)
paint(sm_, sn_, STEM)
local function stemAt(t) local x, y = G.bez(SP, t) local x2, y2 = G.bez(SP, min(1, t + 0.01)) local x1, y1 = G.bez(SP, max(0, t - 0.01)) local dx, dy = x2 - x1, y2 - y1 local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l local px, py = -dy, dx if px + py < 0 then px, py = -px, -py end return x, y, dx, dy, px, py end
local function leaf(t, side, L, wmax, terminal)
  local ax, ay, tx, ty, px, py = stemAt(t)
  local dx, dy
  if terminal then dx, dy = tx, ty else dx, dy = tx * 0.5 + px * side * 0.87, ty * 0.5 + py * side * 0.87 end
  local dl = sqrt(dx * dx + dy * dy) dx, dy = dx / dl, dy / dl
  local tip = { ax + dx * L, ay + dy * L }
  local p = { {ax, ay}, {ax + dx * L * 0.3, ay + dy * L * 0.3}, {ax + dx * L * 0.7 + tx * 3, ay + dy * L * 0.7 + ty * 3}, tip }
  local m, n, T, S = G.tube(p, function(u)
    if u > 0.985 then return -1 end
    if u < 0.1 then return 0.6 end
    local w = wmax * sin(pi * min(1, (u - 0.1) / 0.9)) ^ 0.7
    return max(0.6, w + 0.5 * (floor(u * L / 2.2) % 2 == 0 and 1 or -0.2) * min(1, u * 3) * (1 - u))
  end)
  paint(m, n, LEAF, function(x, y, k)
    local s, u = S[k], T[k]
    if u < 0.1 then return 0 end
    if abs(s) < 0.2 and u < 0.93 then return s <= 0 and 2 or 0 end
    for _, vt in ipairs{ 0.3, 0.42, 0.54, 0.66, 0.78, 0.88 } do
      local d = (u - vt) * L - abs(s) * 2.2
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.85 then return s < 0 and 1 or -1 end
    end
  end, { amb = 0.12, wrap = 0.3 })
end
leaf(0.12, -1, 17, 4.0)
leaf(0.26, 1, 19, 4.2)
leaf(0.42, -1, 19, 4.4)
leaf(0.58, 1, 17, 4.0)
leaf(0.74, -1, 13, 3.3)
leaf(1.0, 1, 12, 3.4, true)
-- quirk: a little cluster of ripe berries on pedicels
local bx, by, _, _, px, py = stemAt(0.42)
local B = { {5, 7}, {8, 4}, {9, 9} }
for _, o in ipairs(B) do
  local cx, cy = floor(bx + px * o[1] + 0.5) , floor(by + py * o[2] + 0.5) + 1
  hline({ {floor(bx + 0.5), floor(by + 0.5)}, {floor((bx + cx) / 2), floor((by + cy) / 2) - 1}, {cx, cy - 1} }, STEM[3])
  local bm = c:ellipse(cx, cy + 1, 2.4, 2.4)
  paint(bm, X.pillow(bm, 2.6), BER)
  c:px(cx - 1, cy, BER[6])
end
G.fin(c, "yerba-mate")

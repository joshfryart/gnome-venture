-- warrigal-greens (lean D3o_9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="warrigal-greens" }
local LEAF = { "#183a3a", "#245a44", "#32794a", "#4d9a50", "#76b95a", "#a6d56e" }
local STEM = { "#3a5a3c", "#5b8a52", "#8cb468", "#c0dc90" }
c:groundShadow(32, 57, 12, 2)
local function arrow(cx, cy, ang, len, wid)
  local ux, uy = cos(ang), sin(ang)
  local px, py = -uy, ux
  local function pt(a, b) return { floor(cx + ux*a + px*b + 0.5), floor(cy + uy*a + py*b + 0.5) } end
  local m = c:poly{ pt(len, 0), pt(len*0.1, wid), pt(-len*0.35, wid*0.35), pt(-len*0.5, 0), pt(-len*0.35, -wid*0.35), pt(len*0.1, -wid) }
  local n = X.pillow(m, wid * 0.8)
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, 7) > 0.88 then bias[k] = 1 end end)
  G.tone(c, m, X.light(n, {amb=0.14, wrap=0.3}), LEAF, nil, bias)
  -- midrib + two veins
  for _, s in ipairs{ -len*0.5, len*0.95 } do end
  local a = pt(-len*0.45, 0) local b = pt(len*0.85, 0)
  G.line(c, { a, b }, LEAF[6])
  for _, f in ipairs{ 0.15, 0.4 } do
    G.line(c, { pt(len*f, 0), pt(len*(f + 0.22), wid*0.55) }, LEAF[2])
    G.line(c, { pt(len*f, 0), pt(len*(f + 0.22), -wid*0.55) }, LEAF[5])
  end
  return m
end
-- stem with two branches
local function stem(p, w0, w1)
  local m, n = G.tube(p, function(t) return w0 + (w1 - w0)*t end)
  G.tone(c, m, X.light(n, {amb=0.12, wrap=0.3}), STEM, {0.4, 0.7, 0.9})
end
stem({ {32,56},{30,46},{35,38},{32,28} }, 1.7, 1.1)
stem({ {32,41},{26,39},{20,36},{17,31} }, 1.0, 0.7)
stem({ {34,38},{39,35},{45,33},{49,28} }, 1.0, 0.7)
arrow(32, 18, -pi/2 + 0.1, 12, 8.5)
arrow(14, 26, -2.2, 9, 6.5)
arrow(51, 22, -0.8, 9, 6.5)
-- small leaf low left
arrow(21, 46, 3.5, 6.5, 4.6)
-- bud and dewdrop (quirk)
c:rect(35, 36, 36, 37):each(function(x, y) c:px(x, y, "#f2d85a") end)
c:px(30, 14, "#cdf2f4") c:px(31, 14, "#e8fcfc") c:px(30, 15, "#5aa6b8")
G.fin(c, "warrigal-greens")

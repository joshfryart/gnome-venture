-- pigeon-pea (lean W2_14)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pigeon-pea" }
local sin, pi, abs = math.sin, math.pi, math.abs
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local POD  = { "#3a4a22", "#566b2c", "#7c923a", "#a3b84a", "#c8d56a", "#e6ea96" }
local STEM = { "#4a3524", "#6e5232", "#94744a", "#b99a66" }
local CUT = { 0.2, 0.38, 0.55, 0.72, 0.87 }
local function tone(m, n, ramp) G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), ramp, CUT) end
-- main stem
local sm, sn = G.tube({ {30,57}, {33,44}, {29,30}, {32,12} }, function(t) return 1.6 - 0.7 * t end)
tone(sm, sn, STEM)
-- trifoliate leaves
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n = X.cyl(ax, ay, bx, by, function(t) return w * sin(pi * math.min(1, t * 0.9 + 0.08)) ^ 0.7 + 0.4 end)
  tone(m, n, LEAF)
  c:line({ {ax, ay}, {bx, by} }, 1)
end
leaf(32, 14, 22, 8, 12, 9, 3.4)
leaf(32, 14, 34, 5, 44, 5, 3.4)
leaf(30, 30, 20, 26, 11, 29, 3.0)
-- pods hanging, each bulging over seeds
local function pod(pts, seeds)
  local m, n = G.tube(pts, function(t) return 3.6 * sin(pi * math.min(1, t * 0.95 + 0.04)) ^ 0.5 + 0.4 end)
  tone(m, n, POD)
  for _, s in ipairs(seeds) do
    local sd = c:ellipse(s[1], s[2], 1.8, 2.2)
    sd:cut(HP.mask()) 
    c:fillMask(sd, POD[5])
    c:px(s[1], s[2] + 2, POD[1]) c:px(s[1] + 1, s[2] + 1, POD[2])
    c:px(s[1] - 1, s[2] - 1, POD[6])
  end
end
pod({ {33,42}, {42,42}, {47,46}, {49,54} }, { {40,43}, {44,45}, {47,49} })
pod({ {29,33}, {20,33}, {15,38}, {14,47} }, { {22,34}, {18,36}, {15,41} })
pod({ {32,22}, {41,20}, {49,23}, {52,31} }, { {40,21}, {45,22}, {49,25} })
-- quirk: purple streak specks on pod
for _, p in ipairs{ {43,40}, {17,35}, {46,21}, {50,27} } do c:px(p[1], p[2], "#8a4a7a") end
G.fin(c, "pigeon-pea")

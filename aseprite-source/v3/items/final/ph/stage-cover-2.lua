-- stage-cover-2 (lean P1b_O10)
-- Growth stage 2 of ground cover: soil mound with three tall clover stems carrying big trifoliate leaves with pale chevrons, two seed leaves at the base, a ladybird on the tallest leaflet (quirk).
local NAME = "stage-cover-2"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, vf, nm, adj)
  local tok = { r = { name = nm } }
  local nr = #ramp
  m:each(function(x, y)
    local v = vf(x, y)
    local i = 1 + floor(max(0, min(0.999, v)) * nr)
    if adj then i = adj(x, y, i, v) or i end
    c:put(x, y, ramp[max(1, min(nr, i))], tok)
  end)
end
local function T(nm) return { r = { name = nm } } end
local function blob(c, m, R, ramp, nm, amb, wrap, adj)
  local v = X.light(X.pillow(m, R), { amb = amb or 0.1, wrap = wrap or 0.25 })
  paint(c, m, ramp, function(x, y) return v[K(x, y)] end, nm, adj)
end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local LEAF = { "#143a2c", "#20603a", "#38884a", "#5cae54", "#8ed068", "#c4ee90" }
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 56, 24, 3)
local soil = c:ellipse(32, 50, 22, 7)
soil:add(c:ellipse(32, 47, 15, 6))
blob(c, soil, 9, SOIL, "soil", 0.1, 0.2, function(x, y, i) local h = X.hash(x, y, 5) if h > 0.9 then return 5 elseif h < 0.07 then return 1 end end)
for _, p in ipairs{ {16,52},{17,52},{48,52},{49,52},{47,53} } do c:put(p[1], p[2], "#b8a898", T"pb") end
for _, p in ipairs{ {18,53},{50,53} } do c:put(p[1], p[2], "#6a5a60", T"pb") end
local STALK = { "#2c5a3a", "#4a8450", "#7cb468", "#b4dc8c" }
local function clover(bx, by, tx, ty, r, midx)
  local sm, sn = G.tube({ {bx, by}, {bx, by - 8}, {(bx + tx) / 2, (by + ty) / 2 + 4}, {tx, ty + 3} }, function(t) return 1.1 end)
  local sv = X.light(sn, { amb = 0.15, wrap = 0.3 })
  paint(c, sm, STALK, function(x, y) return sv[K(x, y)] end, "stalk")
  local out = {}
  for k, ang in ipairs{ -155, -90, -25 } do
    local a = ang * pi / 180
    local ux, uy = cos(a), sin(a)
    local d = r * 0.95
    local lm, ln = G.oval(tx + ux * d, ty + uy * d, r, r * 0.85, a, 1)
    local lv = X.light(ln, { amb = 0.1, wrap = 0.3 })
    paint(c, lm, LEAF, function(x, y) return lv[K(x, y)] end, "leaf")
    -- pale chevron (V toward the stem)
    local cx, cy = tx + ux * (d + 0.5), ty + uy * (d + 0.5)
    for s = -2, 2 do
      local px, py = -uy * s, ux * s
      c:put(floor(cx + px - ux * (2 - abs(s) * 0.7) + 0.5), floor(cy + py - uy * (2 - abs(s) * 0.7) + 0.5), LEAF[6], T"chev")
    end
  end
end
-- seed leaves at the base
for _, s in ipairs{ -1, 1 } do
  local m, n = G.oval(32 + s * 8, 46, 4, 2.2, s * -0.35, 1)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  paint(c, m, LEAF, function(x, y) return v[K(x, y)] end, "cot")
end
clover(20, 47, 17, 29, 5.2)
clover(44, 47, 47, 26, 5.2)
clover(32, 46, 32, 16, 5.8)
-- ladybird
c:fillMask(c:ellipse(33, 11, 2.4, 2), "#d8312e")
c:put(32, 10, "#ff8a6a", T"lb") c:put(34, 12, "#8c1c28", T"lb") c:put(33, 11, "#2b1c26", T"lb") c:put(31, 11, "#2b1c26", T"lb") c:put(34, 9, "#2b1c26", T"lb") c:put(35, 10, "#2b1c26", T"lb")
G.save(c, NAME)

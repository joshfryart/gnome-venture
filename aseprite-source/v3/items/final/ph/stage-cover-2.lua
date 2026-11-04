-- stage-cover-2 (lean W2_21)
-- Low dirt bed with four young clover plants of different heights, trifoliate leaflets with pale chevrons; a ladybird on the tallest leaf (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-cover-2" }
local sqrt, max, min, floor, cos, sin, pi = math.sqrt, math.max, math.min, math.floor, math.cos, math.sin, math.pi
local SOIL  = { "#2c1b1f", "#4d2f2a", "#744a35", "#9b6a44", "#c28f58", "#dfb87a" }
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local STALK = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
local tok = { r = { name = "p" } }
c:groundShadow(32, 57, 24, 3)
local mound = c:ellipse(32, 50, 23, 7):add(c:ellipse(32, 46, 16, 6))
local n = X.pillow(mound, 8)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
G.tone(c, mound, v, SOIL, nil, nil, tok)
mound:each(function(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.93 and v[K(x, y)] > 0.3 then c:px(x, y, SOIL[2]) elseif h < 0.04 then c:px(x, y, SOIL[6]) end
end)
-- pebbles
for _, p in ipairs{ {18, 52}, {44, 54}, {26, 55}, {50, 50} } do c:px(p[1], p[2], SOIL[5]) c:px(p[1] + 1, p[2], SOIL[3]) c:px(p[1], p[2] + 1, SOIL[1]) end
local plants = {
  { 22, 47, 19, 29, 4.4 }, { 32, 46, 33, 19, 5.0 }, { 42, 47, 45, 27, 4.4 }, { 50, 50, 52, 38, 3.6 },
}
for pi_, P in ipairs(plants) do
  local bx, by, tx, ty, r = P[1], P[2], P[3], P[4], P[5]
  local sm, sn = G.tube({ {bx, by}, {bx, by - 6}, {(bx + tx) / 2 + 0.5, (by + ty) / 2}, {tx, ty + 2} }, function(t) return 0.9 end)
  G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STALK, { 0.3, 0.6, 0.85 }, nil, tok)
  for k, ang in ipairs{ -150, -90, -30 } do
    local a = ang * pi / 180
    local ux, uy = cos(a), sin(a)
    local d = (k == 2) and r * 0.95 or r * 0.85
    local lm = G.rell(tx + ux * d, ty + uy * d, ux, uy, r, r * 0.78)
    local ln = X.pillow(lm, 3)
    G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.3 }), LEAF, nil, nil, tok)
    -- pale chevron
    for s = 1, 3 do
      local cx, cy = tx + ux * (d - r * 0.4 + s * 0.8), ty + uy * (d - r * 0.4 + s * 0.8)
      c:px(floor(cx + 0.5), floor(cy + 0.5), LEAF[5])
    end
  end
end
-- ladybird on tallest plant, top leaflet
c:fillMask(c:ellipse(34, 12, 2, 2), "#d8312e")
c:px(33, 11, "#ff7a62") c:px(35, 13, "#8c1c28") c:px(34, 12, "#2b1c26") c:px(32, 12, "#2b1c26") c:px(35, 10, "#2b1c26")
c:px(34, 9, "#2b1c26")
G.fin(c, "stage-cover-2")

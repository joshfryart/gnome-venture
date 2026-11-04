-- slate-shard (lean D2o_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c
local function shade(m, ramp, R, o) local n = X.pillow(m, R) return G.toneN(c, m, n, ramp, o), n end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "slate-shard" }
local SL = { "#252c40", "#3b4560", "#566380", "#74829e", "#97a5bb", "#c4cfdc" }
local ORG = { "#8a4a14", "#c4741c", "#e8a030", "#f7cc55" }
c:groundShadow(32, 56, 14, 2)
local pts = { {20, 55}, {17, 34}, {23, 19}, {29, 9}, {34, 15}, {42, 11}, {47, 32}, {44, 55} }
local body = c:poly(pts)
-- three cleaved planes (flat facets), each a different tone band
local f1 = body:copy():clip(c:poly{ {0, 0}, {29, 0}, {26, 28}, {24, 63}, {0, 63} })
local f2 = body:copy():clip(c:poly{ {29, 0}, {38, 0}, {37, 28}, {35, 63}, {24, 63}, {26, 28} })
local f3 = body:copy():cut(f1):cut(f2)
local function plane(m, base, dx)
  local n = X.pillow(m, 5, 0.35)
  m:each(function(x, y)
    local k = K(x, y)
    local i = base
    local o = (X.hash(x, y, 3) > 0.93) and 1 or 0
    -- strata: slightly slanted cleavage lines every 6 rows
    if (y + floor(x * 0.25)) % 7 == 0 then i = i - 1 end
    i = i + o
    if x + y * 0 == x then c:put(x, y, SL[max(1, min(6, i))], { r = { name = "p" .. base } }) end
  end)
end
plane(f1, 5) plane(f2, 4) plane(f3, 3)
-- bright ridge on every facet edge facing the light, dark seam on the others
f1:edge():each(function(x, y) if x < 26 and y < 52 then c:px(x, y, SL[6]) end end)
f2:edge():each(function(x, y) if x == 29 + 0 then c:px(x, y, SL[6]) end end)
for y = 16, 54 do c:px(26 + floor((24 - 26) * (y - 28) / 35), y, SL[2]) end
for y = 14, 54 do local x = 37 + floor((35 - 37) * (y - 28) / 35) c:px(x, y, SL[1]) end
-- crack across the lower plane
for _, p in ipairs{ {38, 38}, {39, 39}, {39, 40}, {40, 41}, {40, 42}, {41, 43} } do c:px(p[1], p[2], SL[1]) end
-- base shade
body:each(function(x, y) if y > 51 then c:px(x, y, SL[((x + y) % 2 == 0) and 2 or 3]) end end)
-- quirk: orange lichen patch
for _, p in ipairs{ {20, 41}, {21, 41}, {21, 40}, {22, 42}, {20, 43}, {23, 41}, {22, 40} } do c:px(p[1], p[2], ORG[2]) end
c:px(21, 41, ORG[4]) c:px(22, 41, ORG[3]) c:px(20, 42, ORG[1])
-- a chipped splinter leaning at the foot
local ch = c:poly{ {47, 56}, {49, 49}, {53, 54}, {53, 57} }
G.toneN(c, ch, X.pillow(ch, 3), SL)
G.save(c, "slate-shard")

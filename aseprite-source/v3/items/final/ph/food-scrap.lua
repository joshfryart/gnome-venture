-- food-scrap (final, Opus aB32_2). Leftovers: a slim upright apple core (red waxy caps with bloom specks and one
-- specular, gnawed cream middle with browning bite edges and scalloped tooth marks, two glossy pips, the cut ring
-- under each cap, woody stem + tiny veined leaf) and a bread heel lying beside it (domed crust with flour dust, porous
-- crumb face, AO where it leans on the core). 2-tone ground shadow.
-- quirk: an ant climbs the gnawed core, carrying a crumb above its head.
local NAME = "food-scrap"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SKIN  = { "#5c1630", "#8e1f34", "#c23236", "#e5503a", "#fb7e55", "#ffb48a" }
local FLESH = { "#8a5a3a", "#b98a5a", "#dcb47e", "#f0d8a4", "#fbeccb", "#fff8e6" }
local CRUST = { "#4e2420", "#7a3a24", "#a85a2c", "#cd8038", "#e8a952", "#f8d28a" }
local CRUMB = { "#9a7044", "#c49860", "#e2bf84", "#f2dcaa", "#fbeed0", "#fffaec" }
local WOOD  = { "#4a2a22", "#7a4a30", "#a8723e", "#d2a060" }
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local SPEC, BOUNCE = "#fff4e8", "#9a6aa8"

A.ground(c, 30, 52, 21, 2)

-- apple core ------------------------------------------------------------
local CX = 39
local top = c:ellipse(CX, 21, 7, 4.6):clip(c:rect(0, 0, 63, 24))
local bot = c:ellipse(CX, 44, 6.5, 4.2):clip(c:rect(0, 40, 63, 63))
local flesh = HP.mask()
local function fw(y) return 2.6 + 1.1 * abs(sin((y - 25) * 0.95)) end   -- scalloped tooth marks
for y = 24, 40 do local h = fw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do flesh:set(x, y) end end
flesh:cut(top):cut(bot)
-- stem + leaf behind
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 39, 17 }, { 39, 14 }, { 40, 12 }, { 41, 10 } }, function(t) return 0.9 end)
A.shade(c, sm, sn, WOOD, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
A.leaf(c, 41, 12, 45, 8, 50, 9, 2.2, LEAF, { vs = 2.6 })
-- skin caps: one apple-shaped normal field across both caps
local skin = top:copy():add(bot)
local sk = {}
skin:each(function(x, y)
  local nx = (x - CX) / 8
  local cy = y < 32 and 21 or 44
  local ny = (y - cy) / 6.5
  local q = 1 - nx * nx - ny * ny
  local l = sqrt(nx * nx + ny * ny + max(q, 0.03))
  sk[K(x, y)] = { nx / l, ny / l, sqrt(max(q, 0.03)) / l }
end)
local stok2 = { r = { name = "skin" } }
local sbias = {}
X.ao(sbias, top, sm, 1, -1)
local sidx = A.shade(c, skin, sk, SKIN, { tok = stok2, bias = sbias, amb = 0.06, wrap = 0.2 })
-- cut rings: the bitten face under the top cap and over the bottom cap
for x = CX - 6, CX + 6 do
  if top:has(x, 24) then c:put(x, 24, (x < CX + 3) and FLESH[4] or FLESH[3], stok2) end
  if bot:has(x, 40) then c:put(x, 40, (x < CX + 3) and FLESH[5] or FLESH[3], stok2) end
end
-- waxy bloom specks + specular + cool bounce
skin:copy():shrink(1):each(function(x, y) local k = K(x, y)
  if (sidx[k] or 0) >= 4 and X.hash(x, y, 7) > 0.86 then c:put(x, y, SKIN[6], stok2) end end)
c:put(35, 19, SPEC, stok2) c:put(36, 19, SPEC, stok2) c:put(35, 20, SKIN[6], stok2)
c:put(35, 43, SKIN[6], stok2)
skin:edge():each(function(x, y) local n = sk[K(x, y)] if n[1] > 0.55 and n[2] > 0.1 then c:put(x, y, BOUNCE, stok2) end end)
-- calyx tuft at the bottom
for _, p in ipairs{ { 38, 48 }, { 40, 48 }, { 39, 49 } } do c:put(p[1], p[2], WOOD[1], stok2) end
-- gnawed flesh: vertical cylinder light, browning on the bite edge
local ftok = { r = { name = "flesh" } }
local fn = {}
flesh:each(function(x, y) local t = max(-0.95, min(0.95, (x - CX) / (fw(y) + 0.5))) fn[K(x, y)] = { t, 0.15, sqrt(1 - t * t) } end)
local fbias = {}
X.ao(fbias, flesh, top, 1, -2) X.ao(fbias, flesh, bot, 1, -1)
local fidx = A.shade(c, flesh, fn, FLESH, { tok = ftok, bias = fbias, amb = 0.15, wrap = 0.35 })
flesh:edge():each(function(x, y) local k = K(x, y)
  if not top:has(x, y - 1) and not bot:has(x, y + 1) then c:put(x, y, FLESH[max(2, (fidx[k] or 4) - 2)], ftok) end end)
-- core channel + two pips
for y = 27, 37 do if y % 3 ~= 0 then c:put(CX, y, FLESH[3], ftok) end end
for _, p in ipairs{ { 38, 28 } } do
  c:put(p[1], p[2], "#6a3a26", ftok) c:put(p[1], p[2] + 1, "#3e2020", ftok) c:put(p[1] + 1, p[2] + 1, "#4e2a22", ftok)
  c:put(p[1], p[2] + 2, "#3e2020", ftok) c:put(p[1] + 1, p[2] + 2, "#3e2020", ftok) c:put(p[1], p[2] + 1, "#8a5236", ftok)
end

-- bread heel ------------------------------------------------------------
local loaf = c:rrect(11, 40, 32, 51, 5)
local face = c:rrect(13, 44, 30, 50, 2)
local crust = loaf:copy():cut(face)
local cb = {}
G.cast(cb, crust, face, 0, -1, -1)
local ctok = { r = { name = "crust" } }
local lb = {}
X.ao(lb, loaf, skin:copy():add(flesh), 1, -1)
for k, v in pairs(lb) do cb[k] = (cb[k] or 0) + v end
local cidx = A.lit(c, crust, CRUST, 4, { tok = ctok, bias = cb, amb = 0.08 })
-- flour dust on the dome
for _, p in ipairs{ { 15, 41 }, { 19, 41 }, { 23, 41 }, { 17, 42 }, { 27, 42 } } do c:put(p[1], p[2], CRUST[6], ctok) end
c:put(21, 41, SPEC, ctok) c:put(22, 41, CRUST[6], ctok)
-- crumb face: flat, lit from upper left, porous
local mtok = { r = { name = "crumb" } }
local fb = {}
X.ao(fb, face, crust, 1, -1)
local midx = A.lit(c, face, CRUMB, 1.5, { tok = mtok, bias = fb, amb = 0.3 })
face:copy():shrink(1):each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 21)
  if h > 0.82 then c:put(x, y, CRUMB[max(1, (midx[k] or 4) - 2)], mtok)
  elseif h < 0.07 then c:put(x, y, CRUMB[6], mtok) end end)
-- quirk: an ant climbs the gnawed core, carrying a crumb above its head
local ANT, ANT2 = "#4a1e30", "#7a3a50"
for _, p in ipairs{ { 39, 33 }, { 39, 34 }, { 39, 36 }, { 40, 36 }, { 39, 37 }, { 40, 37 }, { 38, 34 }, { 40, 34 }, { 38, 36 }, { 41, 37 }, { 38, 38 } } do c:put(p[1], p[2], ANT, ftok) end
c:put(39, 35, ANT2, ftok) c:put(39, 36, ANT2, ftok)
c:put(39, 32, CRUST[5], ftok) c:put(40, 32, CRUST[4], ftok) c:put(39, 31, CRUST[6], ftok)
A.save(c, NAME)

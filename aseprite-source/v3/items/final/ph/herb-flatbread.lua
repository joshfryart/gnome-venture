-- herb-flatbread (aC11_5, Opus single pass). A slim oval focaccia-style flatbread lying on a gentle diagonal,
-- seen from above with a 3 px baked crust wall underneath. Material: per-pixel domed light (6-tone golden crumb),
-- finger dimples (shadowed upper-left wall, lit lower-right lip), charred blisters, crumb pores, an olive-oil pool
-- with a glint, rosemary needles and flaky salt. Crust wall darkens where it tucks under (ambient).
-- quirk: someone already took a bite out of the right end, showing the soft airy crumb.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local c = G.new2("herb-flatbread")
local BR = { "#5e2c22", "#8c4a2a", "#b9733a", "#da9e50", "#efc26e", "#ffe2a0" }
local CR = { "#3e1c1e", "#5e2c22", "#7e3e26", "#a2582e" }
local CRUMB = { "#d9b678", "#f2dca6", "#fff0cc" }
local ang = -0.3
local cx, cy = 31, 29
local ux, uy = cos(ang), sin(ang)
local top = G.rell(cx, cy, ux, uy, 23.5, 10.5)
-- bite at the right end (two overlapping scallops)
local bite = G.rell(51.5, 19.0, 1, 0, 3.6, 3.6):add(G.rell(53.0, 23.5, 1, 0, 3.4, 3.4))
top:cut(bite)
local side = HP.mask()
for k = 1, 3 do side:add(top:shift(0, k)) end
side:cut(top) side:cut(bite:shift(0, 1))
-- crust wall
side:each(function(x, y)
  local col = CR[3]
  if not side:has(x, y + 1) then col = CR[1]
  elseif not side:has(x, y + 2) then col = CR[2] end
  if x < cx - 12 and col == CR[3] then col = CR[4] end
  c:put(x, y, col)
end)
-- top: domed light
local n = X.pillow(top, 4.5)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local bias = {}
local idx = X.tone(c, top, v, BR, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 } })
-- crust lip: outer ring one step darker on the shade side
top:edge():each(function(x, y) local k = K(x, y) if (idx[k] or 3) <= 3 then c:put(x, y, BR[max(1, idx[k] - 1)]) end end)
-- crumb pores (grain)
top:shrink(2):each(function(x, y) local k = K(x, y)
  local h = G.hash(x, y, 7)
  if h > 0.9 then c:put(x, y, BR[max(1, idx[k] - 1)]) elseif h < 0.05 then c:put(x, y, BR[min(6, idx[k] + 1)]) end end)
-- bite: exposed crumb wall (cream, with pores), crust skin row on its rim
local near = bite:grow(2)
local bodyAll = top:copy():add(side)
bodyAll:each(function(x, y)
  if near:has(x, y) and not bite:has(x, y) then
    local onEdge = bite:grow(1):has(x, y)
    local h = G.hash(x, y, 3)
    local col = onEdge and CRUMB[2] or CRUMB[3]
    if h > 0.72 then col = CRUMB[1] end
    if side:has(x, y) and not side:has(x, y + 1) then col = CR[2] end
    c:put(x, y, col)
  end
end)
-- finger dimples: shadowed upper-left wall, lit lower-right lip
local dimples = { {14, 33}, {20, 28}, {25, 35}, {29, 24}, {33, 31}, {38, 26}, {41, 33}, {46, 24}, {19, 37}, {35, 37}, {24, 23} }
for _, d in ipairs(dimples) do
  local x, y = d[1], d[2]
  if top:has(x, y) and top:has(x + 1, y + 1) then
    local k = K(x, y) local i = idx[k] or 4
    c:put(x, y, BR[max(1, i - 2)]) c:put(x + 1, y, BR[max(1, i - 1)])
    c:put(x, y + 1, BR[max(1, i - 1)]) c:put(x + 1, y + 1, BR[min(6, i + 1)])
  end
end
-- charred blisters: dark bump, lit top-left pixel
for _, b in ipairs{ {11, 29}, {27, 30}, {44, 29}, {37, 22}, {31, 37}, {48, 30} } do
  local x, y = b[1], b[2]
  if top:has(x, y) and top:has(x + 1, y) then
    c:put(x, y, "#a8603a") c:put(x + 1, y, "#5a2a20") c:put(x, y + 1, "#6e3624") c:put(x + 1, y + 1, "#40201e")
  end
end
-- olive-oil pool on the lit side, with one glint
for _, p in ipairs{ {17, 25}, {18, 25}, {19, 25}, {16, 26}, {17, 26}, {18, 26}, {19, 26}, {20, 26}, {18, 27}, {19, 27} } do
  c:put(p[1], p[2], "#f6d86a") end
c:put(17, 25, "#fff4d6") c:put(20, 27, "#c89a3a")
-- rosemary needles (2-3 px slivers, dark side + lit side) and parsley flecks
local MO = { "#1f4a34", "#2f6a40", "#5a9a4c", "#9cce6a" }
local needles = { {13, 31, 1, -1}, {22, 31, 1, 1}, {27, 27, 1, 0}, {31, 34, -1, 1}, {36, 29, 1, -1}, {40, 36, 1, 0},
  {44, 27, 0, 1}, {24, 39, 1, -1}, {16, 35, 1, 0}, {33, 25, 1, 1}, {47, 33, 1, -1}, {29, 39, 1, 0} }
for i, nd in ipairs(needles) do
  local x, y, dx, dy = nd[1], nd[2], nd[3], nd[4]
  if top:has(x, y) and top:has(x + dx * 2, y + dy * 2) then
    c:put(x, y, MO[2]) c:put(x + dx, y + dy, MO[3]) c:put(x + dx * 2, y + dy * 2, i % 3 == 0 and MO[4] or MO[1])
  end
end
for _, f in ipairs{ {21, 34}, {39, 30}, {28, 22}, {43, 37}, {15, 28} } do
  if top:has(f[1], f[2]) then c:put(f[1], f[2], MO[3]) end end
-- flaky salt crystals
for _, s in ipairs{ {26, 32}, {34, 34}, {42, 23}, {23, 26} } do
  if top:has(s[1], s[2]) then c:put(s[1], s[2], "#fff7e6") c:put(s[1] + 1, s[2] + 1, BR[3]) end end
-- crumb crumbs fallen by the bite
c:put(52, 29, CRUMB[2]) c:put(53, 29, CRUMB[1]) c:put(53, 28, CRUMB[3])
G.save2(c, "herb-flatbread")

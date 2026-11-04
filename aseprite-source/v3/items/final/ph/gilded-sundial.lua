-- gilded-sundial (final pass, Opus single pass). A polished gold dial plate in 3/4 view on a slim fluted stone column
-- with a moulded capital and a stepped plinth. A tall thin gnomon casts a long shadow across the face.
-- Material: gold = bevelled lit rim, engraved hour ring with ticks, brushed specular streak, 6-tone side band;
-- stone = per-pixel cylinder light with flutes (groove + lit lip), chipped plinth edge, AO under the plate and capital.
-- quirk: a small snail is climbing the column toward noon.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, atan, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan, math.pi
local c = A.new("gilded-sundial")
local GOLD  = { "#5a2c24", "#8f4a1f", "#c4782a", "#eda632", "#ffd35a", "#fff0a6" }
local STONE = { "#363656", "#565874", "#7c7e98", "#a6a6ba", "#cbcad8", "#e9e8ee" }
local SPEC = "#fff4d6"
local CX, CY, RX, RY = 32, 21, 18, 6.5

c:groundShadow(32, 56, 13, 2)

-- plinth: two steps (lower wide, upper narrower), flat-lit blocks with lit top edge, chip on the lower step
local ptok = { r = { name = "plinth" } }
local function block(x0, y0, x1, y1)
  local m = c:rect(x0, y0, x1, y1)
  m:each(function(x, y)
    local i = 4
    if y == y0 then i = 6 elseif y == y0 + 1 then i = 5 end
    if x >= x1 - 2 and y > y0 then i = i - 1 end
    if y == y1 then i = 2 end
    c:put(x, y, STONE[max(1, i)], ptok)
  end)
  return m
end
block(20, 52, 44, 55)
block(23, 48, 41, 51)
for x = 23, 41 do c:put(x, 52, STONE[2], ptok) end                 -- AO where the upper step sits
c:put(44, 52, STONE[3], ptok) c:put(43, 52, STONE[4], ptok)
-- chip out of the lower step's front-left corner
c.pix[55 * 64 + 20] = nil c.own[55 * 64 + 20] = nil c.pix[54 * 64 + 20] = nil c.own[54 * 64 + 20] = nil
c:put(21, 54, STONE[3], ptok) c:put(21, 55, STONE[2], ptok)

-- column: slim fluted shaft
local ctok = { r = { name = "column" } }
local cm, cn, CT, CS = A.tube({ { 32, 30 }, { 32, 36 }, { 32, 42 }, { 32, 47.5 } }, function(t) return 3.6 - t * 0.2 + (t > 0.9 and (t - 0.9) * 12 or 0) end)
local cb = {}
cm:each(function(x, y) local k = K(x, y) if y <= 32 then cb[k] = -2 elseif y <= 33 then cb[k] = -1 end end)
local cidx = A.shade(c, cm, cn, STONE, { amb = 0.12, wrap = 0.3, bias = cb, tok = ctok })
cm:each(function(x, y) local k = K(x, y) local s = CS[k]
  for _, f in ipairs({ -0.5, 0.0, 0.5 }) do
    if abs(s - f) < 0.12 and y > 33 and y < 46 then A.step(c, cidx, STONE, x, y, -1, ctok) end
  end end)
-- capital: moulded slab under the plate
local cap = c:rrect(25, 29, 39, 32, 1)
local capn = X.pillow(cap, 1.5)
local kb = {}
cap:each(function(x, y) if y == 29 then kb[K(x, y)] = -2 end end)
A.shade(c, cap, capn, STONE, { amb = 0.1, wrap = 0.3, bias = kb, tok = ctok })
for x = 26, 38 do c:put(x, 32, STONE[2], ctok) end
c:put(27, 30, STONE[6], ctok) c:put(28, 30, STONE[6], ctok)

-- dial plate: side band (thickness 3) then the top face
local gtok = { r = { name = "gold" } }
local top = c:ellipse(CX, CY, RX, RY)
local side = top:shift(0, 1):add(top:shift(0, 2)):add(top:shift(0, 3)):cut(top)
side:each(function(x, y)
  local u = (x - CX) / RX
  local i = u < -0.6 and 5 or u < -0.1 and 4 or u < 0.5 and 3 or 2
  if not side:has(x, y + 1) then i = max(1, i - 1) end
  c:put(x, y, GOLD[i], gtok)
end)
-- top face: polished, brushed streak along the diagonal, bevel ring on the rim
local edge = top:edge()
local ring = top:copy():cut(c:ellipse(CX, CY, RX - 3, RY - 1.2))
local inner = c:ellipse(CX, CY, RX - 4, RY - 1.6)
top:each(function(x, y)
  local u, v = (x - CX) / RX, (y - CY) / RY
  local i = 4
  local d = (u * 0.75 + v * 0.55)
  if d < -0.35 then i = 5 end
  if abs(d + 0.05) < 0.08 then i = 5 end
  if d > 0.45 then i = 3 end
  if edge:has(x, y) then i = (v < 0.1 and u < 0.45) and 6 or 3 end
  c:put(x, y, GOLD[i], gtok)
end)
-- engraved hour ring and 12 ticks
inner:edge():each(function(x, y) if top:has(x, y) and not edge:has(x, y) then
  c:put(x, y, (y < CY) and GOLD[3] or GOLD[2], gtok) end end)
for h = 0, 11 do
  local a = h / 12 * 2 * pi
  local x = floor(CX + math.cos(a) * (RX - 2) + 0.5)
  local y = floor(CY + math.sin(a) * (RY - 0.7) + 0.5)
  if top:has(x, y) and not edge:has(x, y) then c:put(x, y, GOLD[2], gtok) end
end
-- gnomon shadow cast toward lower-right across the face
for _, p in ipairs({ { 33, 22 }, { 34, 22 }, { 35, 23 }, { 36, 23 }, { 37, 23 }, { 38, 24 }, { 39, 24 }, { 40, 24 }, { 41, 25 }, { 42, 25 }, { 43, 25 } }) do
  if top:has(p[1], p[2]) then c:put(p[1], p[2], GOLD[2], gtok) end
end
-- gnomon: thin upright triangular blade (vertical back edge at x=35), 2 px thick: lit face + bright edge
local gn = c:poly{ { 22.5, 21.5 }, { 35.5, 6.5 }, { 36.5, 6.5 }, { 36.5, 21.5 } }
gn:cut(c:poly{ { 26, 22 }, { 34, 12.5 }, { 34, 22 } })      -- open window so it reads as a slim blade
gn:each(function(x, y)
  local i = 4
  if not gn:has(x - 1, y) or not gn:has(x, y - 1) then i = 6 end
  if x >= 36 then i = 3 end
  if y >= 20 then i = i - 1 end
  c:put(x, y, GOLD[max(1, i)], gtok)
end)
c:put(35, 7, SPEC, gtok)
-- polished glint on the plate
c:put(20, 18, SPEC, gtok) c:put(21, 18, GOLD[6], gtok) c:put(19, 19, GOLD[6], gtok)

-- quirk: snail climbing the column (shell spiral + grey body, eye stalk)
local snail = {
  "k.k....",
  "m.m....",
  "kmmk...",
  "hmmkkk.",
  "hmksbsk",
  "hmkbdbk",
  "hmksbbk",
  "hmmkkk.",
  "kkk....",
}
A.map(c, snail, 34, 36, { k = "#3a2230", b = "#c97a4a", s = "#f0b06a", d = "#864c33", g = "#e8b982", m = "#b9a0a8", h = "#d8c8cc" }, ctok)
A.save(c, "gilded-sundial")

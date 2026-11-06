-- cherry-cordial (final pass, Opus single pass). A slim long-necked glass flask of ruby cherry cordial, standing.
-- Glass: 1px wall tinted by what's behind it (pale sky above the liquid, rose on the lit side and wine on the shade
-- side of the liquid), bright vertical rim streak + cream glint, pale core in the empty neck. Liquid: sphere light
-- on a 6-tone ruby ramp, lit meniscus line, two rising bubbles. Cork: bevelled cylinder with grain flecks and a
-- paler end grain top. Twine wrap at the neck with a 2-tone twist. Ground shadow.
-- quirk: a real cherry hangs from the twine knot by its stem, like a charm.
local NAME = "cherry-cordial"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local RUBY  = { "#3a0c26", "#5e1230", "#8a1a38", "#b8263e", "#de4a4e", "#ff8a7a" }
local GLASS = { "#3e5f86", "#6f9fc0", "#a8d4e4", "#d6f0f2", "#eefbf8" }
local CORK  = { "#51302b", "#7a4a32", "#a8703f", "#cf9a5a", "#ecc68a" }
local TW    = { "#8f4a1f", "#d98322", "#f5c860" }
local RED   = { "#4a1030", "#7a1534", "#b01e35", "#dc2f37", "#f25a4a", "#ff9a7a" }
local STEM  = { "#3c4a2a", "#5e7a34", "#8fae4a" }
local SPEC  = "#fff4d6"

local CX = 31
c:groundShadow(CX + 0.5, 57, 11, 1.5)
-- bottle: round-bottomed flask, slim neck, rolled lip
local body = c:ellipse(CX + 0.5, 45, 10.5, 11)
body:cut(c:rect(0, 56, 63, 63))                         -- flat base
local neck = c:rect(CX - 2, 17, CX + 3, 36)
local lip = c:rrect(CX - 3, 15, CX + 4, 17, 1)
local m = body:copy():add(neck):add(lip)
local inner = m:shrink(1)
local LV = 33                                           -- liquid level (just under the shoulder)
local liq = HP.mask() inner:each(function(x, y) if y >= LV then liq:set(x, y) end end)
local wall = m:copy():cut(inner)

-- empty glass: pillow light on the glass ramp, then a pale core
local gtok = { r = { name = "glass" } }
local gidx = A.shade(c, m, X.pillow(m, 3), GLASS, { amb = 0.2, wrap = 0.4, cuts = { 0.3, 0.5, 0.7, 0.88 }, tok = gtok })
-- liquid
local ltok = { r = { name = "liquid" } }
local bias = {}
liq:each(function(x, y) if y <= LV + 1 then bias[K(x, y)] = 1 end end)
local ln = X.sphere(CX - 1, 44, 11, liq)
local lidx = A.shade(c, liq, ln, RUBY, { amb = 0.05, wrap = 0.2, cuts = { 0.14, 0.3, 0.48, 0.68, 0.86 }, bias = bias, tok = ltok })
-- meniscus: lit line at the surface, darker row under it
for x = CX - 9, CX + 10 do
  if liq:has(x, LV) then c:put(x, LV, x < CX + 2 and RUBY[6] or RUBY[5], ltok) end
  if liq:has(x, LV + 1) then c:put(x, LV + 1, RUBY[2], ltok) end
end
-- glass wall alongside the liquid: rose on the lit side, wine on the shade side
wall:each(function(x, y)
  if y >= LV and x <= CX then c:put(x, y, "#e88a96", gtok)
  elseif y >= LV then c:put(x, y, "#6a2440", gtok) end
end)
-- bottom glass is thicker: a pale band in the base
for x = CX - 6, CX + 7 do if inner:has(x, 54) then c:put(x, 54, x < CX + 2 and "#c85a6a" or "#7a2a48", gtok) end end
-- reflected cool light lower-right inside the liquid
local rim = X.rim(ln)
inner:edge():each(function(x, y) local k = K(x, y)
  if liq:has(x, y) and rim[k] and rim[k] > 0.62 then c:put(x, y, "#9a3a6a", ltok) end end)
-- pale core in the empty neck + glass shoulder line
for y = 18, LV - 1 do c:put(CX, y, GLASS[5], gtok) end
for y = 18, LV - 1 do c:put(CX + 2, y, GLASS[2], gtok) end
-- glass specular streak down the lit side of the body + glint
for y = 38, 47 do c:put(CX - 7, y, y < 44 and GLASS[5] or "#f6c2c2", gtok) end
c:put(CX - 6, 39, "#f6c2c2", gtok) c:put(CX - 6, 40, "#f6c2c2", gtok)
c:put(CX - 7, 37, SPEC, gtok)
c:put(CX + 6, 51, "#c85a6a", gtok) c:put(CX + 7, 50, "#c85a6a", gtok)   -- secondary reflection
-- bubbles
for _, b in ipairs{ { CX + 3, 41 }, { CX + 2, 37 } } do c:put(b[1], b[2], RUBY[6], ltok) end
c:put(CX + 4, 46, RUBY[5], ltok)
-- rolled lip highlight
for x = CX - 2, CX + 1 do c:put(x, 15, GLASS[5], gtok) end
c:put(CX + 3, 16, GLASS[1], gtok) c:put(CX + 4, 16, GLASS[1], gtok)

-- cork: cylinder poking out of the lip
local ctok = { r = { name = "cork" } }
local cm, cn = X.cyl(CX + 0.5, 8, CX + 0.5, 15, function() return 2.6 end)
cm:cut(lip)
local cidx = A.shade(c, cm, cn, CORK, { amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ctok })
-- end grain top (paler oval) + pores + AO where cork enters the lip
for x = CX - 2, CX + 3 do if cm:has(x, 8) then c:put(x, 8, x < CX + 2 and CORK[5] or CORK[4], ctok) end end
for _, p in ipairs{ { CX - 1, 11 }, { CX + 2, 10 }, { CX + 1, 13 }, { CX - 2, 13 } } do
  if cm:has(p[1], p[2]) then A.step(c, cidx, CORK, p[1], p[2], -2, ctok) end end
for x = CX - 2, CX + 3 do if cm:has(x, 14) then c:put(x, 14, CORK[1], ctok) end end

-- twine: two wraps round the neck with twist
local ttok = { r = { name = "twine" } }
for _, y in ipairs{ 20, 22 } do
  for x = CX - 3, CX + 4 do
    local i = ((x + y) % 2 == 0) and 3 or 2
    if x == CX + 4 or x == CX + 3 then i = 1 end
    if x == CX - 3 then i = 2 end
    c:put(x, y, TW[i], ttok)
  end
end
for x = CX - 2, CX + 3 do c:put(x, 21, GLASS[1], gtok) end   -- glass shows between wraps (AO)
-- knot + hanging cord on the right
c:put(CX + 5, 21, TW[2], ttok) c:put(CX + 6, 21, TW[3], ttok) c:put(CX + 6, 22, TW[1], ttok)
-- quirk: a cherry charm hanging from the knot by its stem
local stok = { r = { name = "charmstem" } }
for i, p in ipairs{ { CX + 7, 22 }, { CX + 8, 23 }, { CX + 8, 24 }, { CX + 9, 25 }, { CX + 9, 26 }, { CX + 9, 27 } } do
  c:put(p[1], p[2], STEM[i < 3 and 1 or 3], stok) if i > 2 then c:put(p[1] + 1, p[2], STEM[2], stok) end end
local ch = c:ellipse(CX + 9.5, 31, 3.2, 3)
A.shade(c, ch, X.sphere(CX + 9, 30.5, 3.2, ch), RED, { amb = 0.1, wrap = 0.3, cuts = { 0.15, 0.32, 0.5, 0.7, 0.88 }, tok = { r = { name = "charm" } } })
c:put(CX + 9, 28, RED[1]) c:put(CX + 10, 28, RED[2])
c:put(CX + 8, 30, SPEC) c:put(CX + 9, 30, RED[6])
A.save(c, NAME)

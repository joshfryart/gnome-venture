-- garden-tonic (final pass, Opus single pass). A slim tall-shouldered glass bottle, two thirds full of bright leaf-green
-- plant tonic, stoppered with a cork; twisted twine wraps the neck and holds a small paper tag with a leaf mark.
-- Material: glass = per-pixel cylinder light on a pale cool 6-tone ramp, bright rim streak on the lit side, pale core,
-- thick dark base; liquid = 6-tone green with a lit meniscus and three rising bubbles; cork = end grain + pores;
-- twine = 3-tone twist; cool reflected light on the shade side; ground shadow (it stands).
-- quirk: a single green drip is running down the outside of the neck from the lip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("garden-tonic")
local GLASS = { "#3d5a7c", "#5f86a6", "#86b3c8", "#acd6dc", "#d2eeea", "#f2fbf6" }
local TON   = { "#163d3a", "#1f6a44", "#2f9148", "#55b84c", "#8cd65a", "#cdf08a" }
local CORK  = { "#4e2e2a", "#7a4a33", "#a66d45", "#c99260", "#e6b983", "#f6dcae" }
local TW    = { "#8f4a1f", "#d29a4a", "#f2cf86" }
local PAPER = { "#a98e7e", "#dccab0", "#f6ead2" }
local CX = 31.5

c:groundShadow(32, 57, 12, 1.5)
-- bottle mask: body + rounded shoulder + slim neck + lip ring
local body = HP.rrect(22, 33, 41, 56, 4):add(HP.ellipse(CX, 33, 9.5, 6)):add(HP.rect(28, 17, 35, 30))
local lip = HP.rrect(27, 14, 36, 17, 1)
body:add(lip)
-- per row: horizontal cylinder normals blended with a soft pillow
local rows = {}
body:each(function(x, y) local r = rows[y] if not r then rows[y] = { x, x } else r[1] = min(r[1], x) r[2] = max(r[2], x) end end)
local np = X.pillow(body, 2)
local n = {}
body:each(function(x, y) local r = rows[y]
  local cx, hw = (r[1] + r[2]) / 2, (r[2] - r[1]) / 2 + 0.6
  local s = max(-0.97, min(0.97, (x - cx) / hw))
  local a = { s, 0, sqrt(1 - s * s) }
  local b = np[K(x, y)]
  n[K(x, y)] = { A.norm(a[1] * 0.75 + b[1] * 0.25, a[2] * 0.75 + b[2] * 0.25, a[3] * 0.75 + b[3] * 0.25) }
end)
local LV = 39
local liquid, glass = HP.mask(), HP.mask()
body:each(function(x, y) if y >= LV and not lip:has(x, y) then liquid:set(x, y) else glass:set(x, y) end end)
local gtok, ltok = { r = { name = "glass" } }, { r = { name = "tonic" } }
local gidx = A.shade(c, glass, n, GLASS, { tok = gtok, amb = 0.25, wrap = 0.4 })
local bias = {}
liquid:each(function(x, y) if y >= 54 then bias[K(x, y)] = -2 elseif y >= 52 then bias[K(x, y)] = -1 end end)
local lidx = A.shade(c, liquid, n, TON, { tok = ltok, amb = 0.12, wrap = 0.3, bias = bias })
-- meniscus: lit line across the surface, a darker row under it
for x = rows[LV][1] + 1, rows[LV][2] - 1 do c:put(x, LV, TON[6], ltok) c:put(x, LV + 1, TON[4], ltok) end
c:put(rows[LV][1] + 1, LV, TON[5], ltok) c:put(rows[LV][2] - 1, LV, TON[3], ltok)
-- pale core in the liquid (light passing through)
for _, p in ipairs{ { 33, 46 }, { 34, 46 }, { 33, 47 }, { 34, 47 }, { 35, 47 }, { 34, 48 } } do c:put(p[1], p[2], TON[5], ltok) end
-- bubbles
for _, b in ipairs{ { 29, 44 }, { 31, 49 }, { 30, 52 } } do c:put(b[1], b[2], TON[6], ltok) c:put(b[1] + 1, b[2] + 1, TON[3], ltok) end
c:put(28, 42, TON[6], ltok)
-- glass rim streak (lit side) + cool reflected light (shade side)
for y = 19, 52 do local r = rows[y]
  if r then
    local xl = r[1] + (y >= 31 and 2 or 1)
    if y ~= LV and (y < 27 or y > 30) then c:put(xl, y, GLASS[6], y >= LV and ltok or gtok) end
    if y > 34 and y < 52 then c:put(r[2], y, y >= LV and "#3a86b0" or GLASS[3]) end
  end
end
-- thick glass base: dark row + punt highlight
for x = 24, 39 do c:put(x, 56, GLASS[1], gtok) end
for x = 23, 40 do if body:has(x, 55) then c:put(x, 55, x < 28 and GLASS[3] or GLASS[2], gtok) end end
c:put(26, 55, GLASS[5], gtok)
-- lip: bright top row
for x = 28, 35 do c:put(x, 14, GLASS[6], gtok) end
for x = 27, 36 do c:put(x, 17, GLASS[2], gtok) end

-- cork (sits in the neck, sticking out above the lip)
local cork = HP.rrect(28, 8, 35, 14, 1)
local cn = {}
cork:each(function(x, y) local s = max(-0.95, min(0.95, (x - 31.5) / 4.2)) cn[K(x, y)] = { s, 0, sqrt(1 - s * s) } end)
local ctok = { r = { name = "cork" } }
local cidx = A.shade(c, cork, cn, CORK, { tok = ctok, amb = 0.15, wrap = 0.3 })
for x = 29, 34 do c:put(x, 8, x < 32 and CORK[6] or CORK[5], ctok) end -- pale end grain top
c:put(30, 9, CORK[5], ctok) c:put(33, 9, CORK[4], ctok)
for _, p in ipairs{ { 30, 11 }, { 33, 11 }, { 29, 12 }, { 32, 12 }, { 34, 10 } } do c:put(p[1], p[2], CORK[2], ctok) end
for x = 28, 35 do c:put(x, 14, x < 31 and GLASS[6] or GLASS[5], gtok) end -- lip overlaps cork bottom
for x = 28, 35 do c:put(x, 13, CORK[1], ctok) end -- AO where cork enters the lip

-- twine twist round the neck (2 rows, diagonal twist)
for x = 28, 35 do
  c:put(x, 21, (x % 2 == 0) and TW[3] or TW[2])
  c:put(x, 22, (x % 2 == 0) and TW[2] or TW[1])
end
-- tag string to the paper tag
for _, p in ipairs{ { 36, 22 }, { 37, 23 }, { 38, 24 }, { 39, 25 } } do c:put(p[1], p[2], TW[2]) end
local tag = HP.poly{ { 39, 25 }, { 44, 24 }, { 47, 30 }, { 43, 33 }, { 40, 31 } }
local ptok = { r = { name = "tag" } }
tag:each(function(x, y) c:put(x, y, PAPER[3], ptok) end)
tag:each(function(x, y) if not tag:has(x + 1, y) or not tag:has(x, y + 1) then c:put(x, y, PAPER[2], ptok) end end)
c:put(41, 26, PAPER[1], ptok) -- punched hole
-- leaf mark on the tag
c:put(42, 30, TON[3]) c:put(43, 29, TON[4]) c:put(44, 28, TON[4]) c:put(43, 30, TON[2]) c:put(44, 29, TON[5])
-- AO under the twine on the glass
for x = 28, 35 do c:put(x, 23, GLASS[2], gtok) end

-- quirk: a green drip running down the outside of the neck
for y = 18, 24 do c:put(27, y, y < 20 and TON[5] or TON[4]) end
c:put(26, 25, TON[4]) c:put(27, 25, TON[5]) c:put(26, 26, TON[3]) c:put(27, 26, TON[2]) c:put(26, 25, TON[6])
A.save(c, "garden-tonic")

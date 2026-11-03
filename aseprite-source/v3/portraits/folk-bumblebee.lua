-- folk-bumblebee PASS 3 (B: polish over A). Hearth Pop v3, 80x100 stop-folk species portrait, neutral outfit
-- (accessory slot = none). Chubby fuzzy bumblebee, cream bib apron, paired wings behind the shoulders.
-- quirk: mismatched antenna tips, a fuzz ball on one and a glinting pink heart on the other.
-- p3: fur crown grows out of the head (scalloped tufts, wisps, jagged drip hairline) instead of a beret cap,
-- clear open smile + button nose, fluffy neck ruff, fur flecks on body, apron folds + buckles, wing veins.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-bumblebee"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function pts(list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function recol(mask, map) mask:each(function(x, y) local v = map[c:get(x, y) or ""] if v then keep(x, y, v) end end) end
local function mid(mask, a, b, m)
  local s = {}
  mask:each(function(x, y) if c:get(x, y) == a then
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == b then s[#s + 1] = { x, y } break end end end end)
  for _, p in ipairs(s) do keep(p[1], p[2], m) end
end
local GOLD2 = "#e89d28"
local function overlay(mask, r, baseOf)
  mask:each(function(x, y)
    local v = c:get(x, y)
    if v == baseOf.base or v == baseOf.hi then c:put(x, y, r.base, baseOf)
    elseif v == baseOf.shade then c:put(x, y, r.shade, baseOf) end
  end)
end
local FUR = { hi = P.dusk.shade, base = P.dusk.deep, shade = "#2a1f45", deep = "#2a1f45" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function fuzz(m, bumps) -- scallop a mask edge with small round tufts
  for _, b in ipairs(bumps) do m:add(HP.ellipse(b[1], b[2], b[3] or 1.5, b[3] or 1.5)) end
  return m
end

---------------------------------------------------------------- wings (fore + hind, teardrops up-and-out)
local WING = { hi = P.cream, base = P.sky.hi, shade = P.sky.base, deep = P.sky.shade }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
for _, sgn in ipairs{ -1, 1 } do
  local hind = oval(39.5 + sgn * 27, 72, 7, 4.5, sgn * -15)
  local fore = oval(39.5 + sgn * 26, 61, 11, 6, sgn * -55)
  c:part(hind, WING, { band = 1, nopop = true })
  c:part(fore, WING, { band = 2, nopop = true })
  c:fillMask(c:line({ { 39.5 + sgn * 22, 68 }, { 39.5 + sgn * 29, 56 } }, 1):clip(fore:shrink(1)), P.sky.base)
  c:fillMask(c:line({ { 39.5 + sgn * 26, 62 }, { 39.5 + sgn * 33, 60 } }, 1):clip(fore:shrink(1)), P.sky.base)
  c:fillMask(c:line({ { 39.5 + sgn * 22, 72 }, { 39.5 + sgn * 31, 71 } }, 1):clip(hind:shrink(1)), P.sky.base)
  -- lit leading edge on the upper side of each fore wing
  fore:edge():each(function(x, y) if not fore:has(x, y - 1) and c:get(x, y) == P.sky.hi then keep(x, y, P.cream) end end)
end

---------------------------------------------------------------- fuzzy body with stripes and apron
local body = c:ellipse(39.5, 104, 36, 33):clip(c:rect(0, 70, 79, 99))
fuzz(body, { {11,86},{14,81},{19,77},{25,74},{54,74},{60,77},{65,81},{68,86} })
c:part(body, "gold", { band = 3, pop = { x = 14, y = 84 } })
mid(body, P.gold.base, P.gold.shade, GOLD2)
-- fur stripes with zigzag fuzzy edges
local s1, s2 = HP.mask(), HP.mask()
for x = 0, 79 do
  local z = (x % 2 == 0) and 0 or 1
  for y = 81 + z, 86 - z do s1:set(x, y) end
  for y = 93 + z, 99 do s2:set(x, y) end
end
overlay(s1:clip(body), FUR, P.gold) overlay(s2:clip(body), FUR, P.gold)
recol(s1:copy():add(s2):clip(body), { [GOLD2] = FUR.shade })
-- fur flecks: short down-strokes across body and stripes
for y = 75, 99, 3 do for x = (y % 2) * 2, 79, 4 do
  recol(c:rect(x, y, x, y + 1):clip(body), { [P.gold.base] = GOLD2, [GOLD2] = P.gold.shade, [P.dusk.deep] = "#4a3a7c", [FUR.shade] = P.dusk.deep })
end end
-- bib apron: rounded bib, straps over the shoulders, hem stitch
local bib = c:rrect(29, 78, 50, 99, 4)
c:part(bib, CR, { nopop = true, band = 2 })
c:part(c:line({ {31,79},{29,72} }, 3), CR, { nopop = true, band = 1 })
c:part(c:line({ {48,79},{50,72} }, 3), CR, { nopop = true, band = 1 })
c:part(c:rrect(34, 88, 45, 95, 2), { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { nopop = true, band = 1 })
c:stitch{ {35, 89}, {44, 89} }
mid(bib, P.cream, P.stone.hi, "#f3e6c8")
for _, f in ipairs{ { {32,82},{31,98} }, { {47,96},{48,99} }, { {38,96},{37,99} } } do
  recol(c:line(f, 1):clip(bib), { [P.cream] = "#f3e6c8", ["#f3e6c8"] = P.stone.hi })
end
c:part(c:rect(29, 78, 31, 80), "gold", { band = 1, nopop = true }) c:part(c:rect(48, 78, 50, 80), "gold", { band = 1, nopop = true })
keep(29, 78, P.gold.hi) keep(48, 78, P.gold.hi)

---------------------------------------------------------------- fluffy neck ruff
local ruff = c:ellipse(39.5, 69, 15, 3.5)
fuzz(ruff, { {26,71,2},{31,72,2},{37,72.5,2},{43,72.5,2},{49,72,2},{54,71,2} })
c:part(ruff, "gold", { band = 1, pop = { x = 28, y = 68 } })
mid(ruff, P.gold.base, P.gold.shade, GOLD2)

---------------------------------------------------------------- head: round, fur crown grows from the head itself
local hcx, hcy, hrx, hry = 39.5, 47, 21, 18.5
local head = c:ellipse(hcx, hcy, hrx, hry)
-- gold cheek fluff on the sides
for _, a in ipairs{ 160, 175, 190, 5, -10, 20 } do
  local r = math.rad(a)
  head:add(HP.ellipse(hcx + math.cos(r) * (hrx - 0.5), hcy + math.sin(r) * (hry - 0.5), 1.5, 1.5))
end
-- fur crown: the head top + scalloped tufts on its outline (no overhang, so it is not a hat)
local fur = head:copy():clip(c:rect(0, 0, 79, 37))
local TUFT = { 2, 2.5, 2, 2.5, 3, 2.5, 2, 2.5, 2, 2.5, 2 }
for i = 0, 10 do
  local r = math.rad(198 + i * 14.4)
  fur:add(HP.ellipse(hcx + math.cos(r) * (hrx - 0.5), hcy + math.sin(r) * (hry - 0.5), TUFT[i + 1], TUFT[i + 1]))
end
-- stray fluff hairs poking out of the silhouette (1px wisps, alternate lean)
for i = 0, 19 do
  local r = math.rad(196 + i * 7.6)
  local rr = (i % 3 == 1) and 3.6 or 2.8
  local x, y = math.floor(hcx + math.cos(r) * (hrx + rr) + .5), math.floor(hcy + math.sin(r) * (hry + rr) + .5)
  if not fur:has(x, y) then fur:set(x, y) fur:set(x + ((i % 2 == 0) and 1 or -1) * 0, y + 1) end
end
-- jagged hairline: fur points of 1-3 px dripping into the gold
local DRIP = { 1, 2, 0, 1, 3, 1, 0, 2, 1, 0, 1, 3, 1, 0, 2, 1, 0, 1, 2, 0 }
for x = 18, 61 do
  local d = DRIP[(x * 7) % #DRIP + 1]
  if head:has(x, 37) then for y = 38, 37 + d do if head:has(x, y + 1) then fur:set(x, y) end end end
end
head:add(fur)
c:part(head, "gold", { band = 3, pop = { x = 27, y = 41 } })
mid(head, P.gold.base, P.gold.shade, GOLD2)
-- chin fuzz texture
for _, p in ipairs{ {30,60},{34,62},{39,63},{44,62},{24,56} } do recol(c:rect(p[1], p[2], p[1], p[2] + 1), { [P.gold.base] = GOLD2, [GOLD2] = P.gold.shade }) end
local FURP = FUR
c:part(fur, FURP, { band = 2, inner = false, pop = { x = 27, y = 31 } })
-- fur strands (lighter flicks, upper-left lit)
for _, s in ipairs{ {28,32,29,30}, {33,29,34,27}, {39,28,40,26}, {45,29,46,27}, {24,36,25,34}, {31,35,32,33}, {37,33,38,31}, {43,33,44,31},
  {50,31,51,29}, {22,33,23,31}, {35,37,36,35}, {48,35,49,33}, {41,36,42,34}, {27,37,28,35} } do
  c:line({ {s[1],s[2]},{s[3],s[4]} }, 1):clip(fur):each(function(x, y) if c:get(x, y) == P.dusk.deep then keep(x, y, "#4a3a7c") end end)
end
-- gold flecks at the hairline so the edge reads as fur, not a brim line
for x = 19, 60 do
  for y = 36, 41 do
    if c:get(x, y) == P.gold.base and fur:has(x, y - 1) and (x % 3 ~= 0) then keep(x, y, P.gold.shade) break end
  end
end
-- tiny top tuft (three flicks)
c:part(c:poly{ {36,27},{37,22},{39,25},{40,20},{42,25},{44,23},{44,28} }, FURP, { band = 1, nopop = true, inner = false })
-- face
c:eyeLocked(30, 45) c:eyeLocked(45, 45)
c:paint({ "GG" }, 39, 50, { G = "gold.deep" })                          -- button nose
c:paint({ "i......i", ".iiiiii.", ".iDDDDi.", "..iPhi..", "...ii..." }, 36, 52, { i = "ink", D = "ember.deep", P = "petal.base", h = "petal.hi" }) -- open smile, lifted corners
c:paint({ "PPP", "PPP" }, 26, 52, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 51, 52, { P = "petal.base" })
pts({ {26,52},{51,52} }, P.petal.hi)

---------------------------------------------------------------- antenna tips (stalks drawn after the outline)
local ball = c:ellipse(24, 11, 3, 3)
for _, b in ipairs{ {21,7},{27,7},{20,12},{28,12},{24,6},{24,15} } do ball:set(b[1], b[2]) end
c:part(ball, FUR, { band = 1, pop = { x = 22, y = 9 } })
pts({ {25,10},{23,12},{26,13} }, "#4a3a7c")
c:paint({ ".hh.XX.", "hhXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." }, 51, 4, { X = "petal.base", h = "petal.hi" })
pts({ {56,7},{55,8},{54,9},{56,6} }, P.petal.shade)

c:finish{ outline = true }
-- stalks: left one curls once, right one straight and proud
c:fillMask(c:line({ {33,26},{31,22},{29,19},{28,17},{29,15},{27,14} }, 1), P.ink)
c:fillMask(c:line({ {45,26},{48,20},{52,14},{54,10} }, 1), P.ink)
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

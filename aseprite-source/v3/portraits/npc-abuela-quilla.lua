-- npc-abuela-quilla PASS 3 (B: polish over A). Hearth Pop v3, 80x100 portrait, bleed off bottom.
-- Warm old grandmother (skin B), grey plaited braids, cocked brimmed hat with feather, red Andean poncho.
-- quirk: an orange cat pokes out of the poncho slit wearing a tiny copy of her hat (feather too).
-- p3: designed nose (warm ball, lit tip, shadow underside, 2 nostrils), no neck (chin on the rolled collar),
-- ink-edged cat hat, hair strands + brim cast shadow, extra skin/fabric ramp steps, disc outlined in sea tones.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-abuela-quilla"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local D4 = { {1,0},{-1,0},{0,1},{0,-1} }

local function overlay(mask, r, baseOf)
  mask:each(function(x, y)
    local v = c:get(x, y)
    if v == baseOf.base or v == baseOf.hi then c:put(x, y, r.base, baseOf)
    elseif v == baseOf.shade then c:put(x, y, r.shade, baseOf) end
  end)
end
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function pts(list, hex) for _, p in ipairs(list) do keep(p[1], p[2], hex) end end
local function recol(mask, map) mask:each(function(x, y) local v = map[c:get(x, y) or ""] if v then keep(x, y, v) end end) end
local function mid(mask, a, b, m) -- colour a touching colour b -> m (one extra ramp step at the terminator)
  local s = {}
  mask:each(function(x, y) if c:get(x, y) == a then
    for _, d in ipairs(D4) do if c:get(x + d[1], y + d[2]) == b then s[#s + 1] = { x, y } break end end end end)
  for _, p in ipairs(s) do keep(p[1], p[2], m) end
end
local function backdrop(r) -- disc, 2px shade crescent lower-right, 1px darker ring of its own colour
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs(D4) do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local EMB2 = "#cf3b3c" -- ember step between base and shade

---------------------------------------------------------------- poncho
local pon = c:ellipse(39.5, 100, 39, 37):clip(c:rect(0, 63, 79, 99))
c:part(pon, "ember", { band = 3, pop = { x = 13, y = 80 } })
mid(pon, P.ember.base, P.ember.shade, EMB2)
-- drape: V folds falling from the collar, a crease over each shoulder
for _, f in ipairs{ { {27,67},{21,74},{17,82} }, { {52,67},{58,74},{61,82} }, { {9,80},{12,83} }, { {69,79},{67,83} } } do
  local ln = c:line(f, 1):clip(pon)
  recol(ln, { [P.ember.base] = EMB2, [EMB2] = P.ember.shade, [P.ember.shade] = P.ember.deep })
end
overlay(c:rect(0, 84, 79, 84):clip(pon), P.gold, P.ember)
local zz = HP.mask()
for x = 0, 79 do local t = (x + 1) % 6; local d = t < 3 and t or 6 - t; zz:set(x, 86 + d) end
recol(zz:clip(pon), { [P.ember.base] = P.cream, [P.ember.hi] = P.cream, [EMB2] = P.stone.hi, [P.ember.shade] = P.stone.hi })
for x = 3, 79, 6 do
  recol(c:poly{ {x - 0.5, 86.5}, {x + 1.5, 88.5}, {x - 0.5, 90.5}, {x - 2.5, 88.5} }:clip(pon),
    { [P.ember.base] = P.gold.base, [P.ember.hi] = P.gold.base, [EMB2] = P.gold.shade, [P.ember.shade] = P.gold.shade })
end
overlay(c:rect(0, 92, 79, 92):clip(pon), P.gold, P.ember)
recol(c:rect(0, 92, 79, 92):clip(pon), { [EMB2] = P.gold.shade })
recol(c:rect(0, 84, 79, 84):clip(pon), { [EMB2] = P.gold.shade })
overlay(c:rect(0, 95, 79, 96):clip(pon), P.sea, P.ember)
recol(c:rect(0, 95, 79, 96):clip(pon), { [EMB2] = P.sea.shade })
-- rolled collar right under the chin (no neck)
local col = c:ellipse(39.5, 63, 12, 2)
c:part(col, "gold", { band = 1, pop = { x = 30, y = 62 } })
for x = 30, 50, 3 do keep(x, 64, P.gold.shade) end -- roll ribs
local slit = c:ellipse(41.5, 86, 15, 5.5)
c:fillMask(slit, P.ember.deep)
c:fillMask(c:rect(28, 82, 55, 82):clip(slit):cut(slit:copy():shift(0, 1)), P.ember.deep)

---------------------------------------------------------------- braids
local ALT = { hi = P.stone.hi, base = P.stone.base, shade = P.stone.shade, deep = P.stone.deep }
local function braid(x0, y0, y1, lean)
  local i = 0
  for y = y0, y1, 4 do
    local x = x0 + math.floor((y - y0) * lean / (y1 - y0) + .5) + ((i % 2 == 0) and 0 or 1)
    local m = c:ellipse(x, y, 3, 2.5)
    c:part(m, (i % 2 == 0) and "stone" or ALT, { band = 1, nopop = true })
    mid(m, P.stone.base, P.stone.shade, "#8f8fa2")
    pts({ { x - 2, y - 1 }, { x - 1, y - 2 } }, P.stone.hi)
    i = i + 1
  end
end
braid(20, 50, 74, -2)
braid(59, 50, 74, 1)
local function bow(x, y)
  c:part(c:poly{ {x - 1, y - 2}, {x + 3, y - 1}, {x + 3, y + 2}, {x - 1, y + 3} }, "stone", { band = 1, nopop = true })
  c:part(c:poly{ {x - 3, y + 2}, {x + 4, y + 2}, {x + 5, y + 7}, {x + 1, y + 5}, {x - 4, y + 7} }, "stone", { band = 1, nopop = true })
  pts({ { x - 1, y + 4 }, { x + 2, y + 4 } }, P.stone.shade)
  c:part(c:poly{ {x - 4, y - 2}, {x, y}, {x - 4, y + 2.5} }, "sea", { band = 1, nopop = true })
  c:part(c:poly{ {x + 5, y - 2}, {x + 1, y}, {x + 5, y + 2.5} }, "sea", { band = 1, nopop = true })
  c:part(c:rect(x - 1, y - 1, x + 2, y + 1), "sea", { band = 1, nopop = true })
  keep(x - 1, y - 1, P.sea.hi)
end
bow(17, 78) bow(59, 78)

---------------------------------------------------------------- head + hair
local head = c:ellipse(39.5, 44, 20, 18)
c:part(head, "skinB", { band = 3 })
mid(head, P.skinB.base, P.skinB.shade, "#a06640")
local hair = head:copy():clip(c:rect(0, 0, 79, 55)):cut(c:ellipse(40.5, 49, 14.5, 15))
hair:add(c:ellipse(21, 49, 4, 4)):add(c:ellipse(58, 49, 4, 4))
c:part(hair, "stone", { band = 2, nopop = true })
mid(hair, P.stone.base, P.stone.shade, "#8f8fa2")
-- strands sweep from the centre part down to the braids: shade groove + light ridge above it
local STR = {
  { {39,31},{34,33},{28,36},{24,41} }, { {38,34},{32,36},{27,41},{25,46} }, { {37,36},{33,38},{30,42} },
  { {42,31},{47,33},{52,36},{56,41} }, { {43,34},{49,36},{54,41},{56,46} }, { {44,36},{48,38},{51,42} },
}
for i, s in ipairs(STR) do
  local ln = c:line(s, 1):clip(hair)
  recol(ln, { [P.stone.base] = P.stone.shade, ["#8f8fa2"] = P.stone.shade, [P.stone.shade] = P.stone.deep })
  if i <= 3 then recol(ln:shift(0, -1):clip(hair), { [P.stone.base] = P.stone.hi }) end
end
c:fillMask(c:line({ {40,30},{40,33} }, 1):clip(hair), P.stone.deep)  -- centre part

---------------------------------------------------------------- face
c:eyeLocked(31, 44) c:eyeLocked(45, 44)
pts({ {31,41},{32,40},{33,40},{34,40} }, P.stone.shade)
pts({ {45,40},{46,40},{47,40},{48,41} }, P.stone.shade)
pts({ {29,47},{30,48},{51,47},{50,48} }, P.skinB.shade)          -- smile crinkles
-- cheek apples: lit top, warm blush halo, petal core
for _, ch in ipairs{ { 28, 51 }, { 51, 51 } } do
  pts({ { ch[1], ch[2] - 1 }, { ch[1] + 1, ch[2] - 1 } }, "#c88c5f")
  pts({ { ch[1] - 1, ch[2] }, { ch[1] + 2, ch[2] }, { ch[1], ch[2] + 1 }, { ch[1] + 1, ch[2] + 1 } }, "#b86a50")
  c:cheek(ch[1], ch[2])
end
-- NOSE: bridge lit on the left, warm ball, 2x1 lit tip, shadow underside with two nostrils, cast shade right
c:paint({
  "..wm..",
  "..wm..",
  ".whhm.",
  "wwwwwm",
  ".nssnc",
}, 38, 49, { w = "#c97f4c", h = "#efb57e", m = "#a3603c", s = "#7e432d", n = "#4f2620", c = "#9c6240" })
-- laugh lines + soft open smile
pts({ {36,53},{36,54},{45,54},{45,55} }, "#a06640")
c:paint({ "i.....i", ".iDPDi.", "..iii.." }, 37, 56, { i = "skinB.deep", D = "ember.deep", P = "petal.base" })
pts({ {39,59},{40,59},{41,59} }, "#a06640")                           -- lower lip shadow

---------------------------------------------------------------- hat (brim cocked: right side 1px lower)
local crown = c:ellipse(39.5, 22, 12, 10):clip(c:rect(0, 0, 79, 29)):add(c:rect(28, 22, 51, 31))
c:part(crown, "wood", { band = 2 })
mid(crown, P.wood.base, P.wood.shade, "#a0643f")
overlay(c:rect(28, 24, 51, 27), P.ember, P.wood)
recol(c:rect(28, 24, 51, 27), { ["#a0643f"] = P.ember.shade })
c:stitch{ {29, 25}, {51, 25} }
local brim = HP.mask()
for x = 10, 69 do
  local t = (x - 39.5) / 29.5
  local top = 30 - math.floor(3.2 * t * t + .5) + ((x > 46) and 1 or 0)
  local th = math.abs(t) > 0.9 and 2 or 3
  for y = top, top + th do brim:set(x, y) end
end
-- cast shadow of the brim on the hair and forehead (drawn before the brim, one row under it)
brim:copy():shift(0, 1):cut(brim):each(function(x, y)
  local v = c:get(x, y)
  if v == P.stone.base or v == P.stone.hi or v == "#8f8fa2" then keep(x, y, P.stone.shade)
  elseif v == P.stone.shade then keep(x, y, P.stone.deep)
  elseif v == P.skinB.base then keep(x, y, P.skinB.shade) end
end)
c:part(brim, "wood", { band = 1, pop = { x = 16, y = 28 } })
recol(brim:copy():cut(brim:copy():shift(0, -1)), { [P.wood.base] = "#a0643f" }) -- underside step
local fea = c:poly{ {49,25},{51,17},{55,10},{60,4},{63,2},{63,7},{60,13},{55,20},{52,26} }
c:part(fea, "gold", { band = 1, nopop = true })
overlay(c:poly{ {58,2},{64,1},{64,8},{60,9} }:clip(fea), P.ember, P.gold)
c:fillMask(c:line({ {51,24},{54,17},{58,10},{62,4} }, 1), P.gold.deep)
pts({ {52,20},{53,18},{56,13} }, P.gold.hi)

---------------------------------------------------------------- cat
c:part(c:poly{ {29,80},{29,71},{35,76} }, "gold", { band = 1, nopop = true })
c:part(c:poly{ {48,76},{54,71},{54,80} }, "gold", { band = 1, nopop = true })
pts({ {30,74},{31,75},{30,75},{53,74},{52,75},{53,75} }, P.petal.base)
local cat = c:ellipse(41.5, 83, 11, 7.5)
c:part(cat, "gold", { band = 2, pop = { x = 33, y = 80 } })
mid(cat, P.gold.base, P.gold.shade, "#e89d28")
pts({ {38,77},{38,78},{41,77},{41,78},{44,77},{44,78} }, P.gold.shade)             -- tabby M
pts({ {31,83},{32,83},{31,85},{51,83},{52,83},{52,85} }, P.gold.shade)            -- cheek stripes
c:eyeSmall(36, 82) c:eyeSmall(46, 82)
c:fillMask(c:ellipse(41.5, 87, 3.5, 1.5), P.cream)
pts({ {41,85},{42,85} }, P.petal.base)
pts({ {40,87},{41,86},{42,86},{43,87} }, P.gold.deep)
pts({ {35,86},{34,87},{48,86},{49,87} }, P.gold.deep)                             -- whiskers
c:part(c:rrect(30, 89, 36, 93, 2), "gold", { band = 1, nopop = true })
c:part(c:rrect(47, 89, 53, 93, 2), "gold", { band = 1, nopop = true })
pts({ {32,92},{34,92},{49,92},{51,92} }, P.gold.shade)
-- tiny matching hat: ink-edged, gold band dashes like hers
c:paint({
  "......IIIIII......",
  ".....IhHbbbsI.....",
  ".....IbbbbmsI.....",
  ".....IEeEeESI.....",
  ".....IbbbbmsI.....",
  ".IIIIhbbbbbmsIIII.",
  "IHhbbbbbbbbbbmmssI",
  ".Issssssssssssssd.",
  "..IIIIIIIIIIIIII..",
}, 33, 67, { I = "ink", d = "wood.deep", H = "wood.hi", h = "wood.hi", b = "wood.base", m = "#a0643f", s = "wood.shade",
  E = "ember.base", e = "gold.base", S = "ember.shade" })
c:paint({ "...Ig", "..Igg", ".IgG.", "IgG..", "gG...", "G...." }, 45, 63, { g = "gold.hi", G = "gold.base", I = "ink" })

c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

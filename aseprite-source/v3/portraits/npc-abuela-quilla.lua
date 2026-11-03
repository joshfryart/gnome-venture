-- npc-abuela-quilla PASS 2 (polish). Hearth Pop v3, 80x100 portrait, bleed off bottom.
-- Warm old grandmother (skin B), grey plaited braids, curved-brim hat with feather, red Andean poncho.
-- quirk: an orange cat pokes out of the poncho slit wearing a tiny copy of her hat (feather too).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-abuela-quilla"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }

local function overlay(mask, r, baseOf) -- pattern over a part, keeping its shade band
  mask:each(function(x, y)
    local v = c:get(x, y)
    if v == baseOf.base or v == baseOf.hi then c:put(x, y, r.base, baseOf)
    elseif v == baseOf.shade then c:put(x, y, r.shade, baseOf) end
  end)
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade) end end)
end
local function pts(list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end

---------------------------------------------------------------- poncho (rounded shoulders)
local pon = c:ellipse(39.5, 102, 39, 36):clip(c:rect(0, 65, 79, 99))
c:part(pon, "ember", { band = 3, pop = { x = 14, y = 80 } })
-- Andean band: gold rails, cream zigzag, ember-deep diamonds, sea rail
overlay(c:rect(0, 84, 79, 84):clip(pon), P.gold, P.ember)
local zz = HP.mask()
for x = 0, 79 do local t = (x + 1) % 6; local d = t < 3 and t or 6 - t; zz:set(x, 86 + d) end
overlay(zz:clip(pon), { base = P.cream, shade = P.stone.hi }, P.ember)
for x = 3, 79, 6 do overlay(c:poly{ {x - 0.5, 86.5}, {x + 1.5, 88.5}, {x - 0.5, 90.5}, {x - 2.5, 88.5} }:clip(pon), P.gold, P.ember) end
overlay(c:rect(0, 92, 79, 92):clip(pon), P.gold, P.ember)
overlay(c:rect(0, 95, 79, 96):clip(pon), P.sea, P.ember)
-- neck + rolled collar
c:part(c:rect(34, 58, 45, 65), "skinB", { nopop = true, band = 2 })
c:part(c:ellipse(39.5, 65, 10, 1.5), "gold", { band = 1, nopop = true })
-- poncho slit the cat climbs out of
local slit = c:ellipse(41.5, 86, 15, 5.5)
c:fillMask(slit, P.ember.deep)

---------------------------------------------------------------- braids: beaded plait, alternating lumps
local ALT = { hi = P.stone.hi, base = P.stone.base, shade = P.stone.shade, deep = P.stone.deep }
local function braid(x0, y0, y1, lean)
  local i = 0
  for y = y0, y1, 4 do
    local x = x0 + math.floor((y - y0) * lean / (y1 - y0) + .5) + ((i % 2 == 0) and 0 or 1)
    c:part(c:ellipse(x, y, 3, 2.5), (i % 2 == 0) and "stone" or ALT, { band = 1, nopop = true })
    i = i + 1
  end
end
braid(20, 50, 74, -2)
braid(59, 50, 74, 1)
-- sea ribbon bows + flared tufts
local function bow(x, y)
  c:part(c:poly{ {x - 1, y - 2}, {x + 3, y - 1}, {x + 3, y + 2}, {x - 1, y + 3} }, "stone", { band = 1, nopop = true }) -- tuft base hidden below
  c:part(c:poly{ {x - 3, y + 2}, {x + 4, y + 2}, {x + 5, y + 7}, {x + 1, y + 5}, {x - 4, y + 7} }, "stone", { band = 1, nopop = true })
  c:part(c:poly{ {x - 4, y - 2}, {x, y}, {x - 4, y + 2.5} }, "sea", { band = 1, nopop = true })
  c:part(c:poly{ {x + 5, y - 2}, {x + 1, y}, {x + 5, y + 2.5} }, "sea", { band = 1, nopop = true })
  c:part(c:rect(x - 1, y - 1, x + 2, y + 1), "sea", { band = 1, nopop = true })
end
bow(17, 78) bow(59, 78)

---------------------------------------------------------------- head + hair curtains
local head = c:ellipse(39.5, 44, 20, 18)
c:part(head, "skinB", { band = 3 })
local hair = head:copy():clip(c:rect(0, 0, 79, 55)):cut(c:ellipse(40.5, 49, 14.5, 15))
hair:add(c:ellipse(21, 49, 4, 4)):add(c:ellipse(58, 49, 4, 4))
c:part(hair, "stone", { band = 2, pop = { x = 27, y = 35 } })
-- strands + centre part
c:fillMask(c:line({ {40,31},{40,34} }, 1), P.stone.shade)
c:fillMask(c:line({ {37,35},{30,37},{25,42} }, 1), P.stone.shade)
c:fillMask(c:line({ {43,35},{50,37},{54,41} }, 1), P.stone.shade)
-- face
c:eyeLocked(31, 44) c:eyeLocked(45, 44)
pts({ {31,41},{32,40},{33,40},{34,40} }, P.stone.shade)   -- soft brows
pts({ {45,40},{46,40},{47,40},{48,41} }, P.stone.shade)
pts({ {29,47},{51,47} }, P.skinB.shade)                    -- smile crinkles
c:cheek(28, 51) c:cheek(51, 51)
pts({ {41,48},{41,49},{40,50},{41,50} }, P.skinB.shade)    -- nose
c:paint({ "iiiiiii", ".iPPPi.", "..iii.." }, 37, 53, { i = "skinB.deep", P = "petal.shade" })

---------------------------------------------------------------- hat: dome crown, upturned brim, feather
local crown = c:ellipse(39.5, 22, 12, 10):clip(c:rect(0, 0, 79, 29)):add(c:rect(28, 22, 51, 29))
c:part(crown, "wood", { band = 2 })
overlay(c:rect(28, 24, 51, 27), P.ember, P.wood)
c:stitch{ {29, 25}, {51, 25} }
local brim = HP.mask()
for x = 11, 68 do
  local t = (x - 39.5) / 28.5
  local top = 30 - math.floor(3.2 * t * t + .5)
  local th = math.abs(t) > 0.9 and 2 or 3
  for y = top, top + th do brim:set(x, y) end
end
c:part(brim, "wood", { band = 2, pop = { x = 17, y = 28 } })
-- feather (gold vane, ember tip, quill)
local fea = c:poly{ {49,25},{51,17},{55,10},{60,4},{63,2},{63,7},{60,13},{55,20},{52,26} }
c:part(fea, "gold", { band = 1, nopop = true })
overlay(c:poly{ {58,2},{64,1},{64,8},{60,9} }:clip(fea), P.ember, P.gold)
c:fillMask(c:line({ {51,24},{54,17},{58,10},{62,4} }, 1), P.gold.deep)

---------------------------------------------------------------- cat (gold tabby) climbing out of the slit
c:part(c:poly{ {29,80},{29,71},{35,76} }, "gold", { band = 1, nopop = true })
c:part(c:poly{ {48,76},{54,71},{54,80} }, "gold", { band = 1, nopop = true })
pts({ {30,74},{31,75},{53,74},{52,75} }, P.petal.base)
local cat = c:ellipse(41.5, 83, 11, 7.5)
c:part(cat, "gold", { band = 2, pop = { x = 34, y = 79 } })
pts({ {38,77},{38,78},{41,77},{41,78},{44,77},{44,78} }, P.gold.shade) -- tabby M
c:eyeSmall(36, 82) c:eyeSmall(46, 82)
c:fillMask(c:ellipse(41.5, 87, 3.5, 1.5), P.cream)
pts({ {41,85},{42,85} }, P.petal.base)
pts({ {40,87},{41,86},{42,86},{43,87} }, P.gold.deep)
-- paws over the slit lip
c:part(c:rrect(30, 89, 36, 93, 2), "gold", { band = 1, nopop = true })
c:part(c:rrect(47, 89, 53, 93, 2), "gold", { band = 1, nopop = true })
pts({ {32,92},{34,92},{49,92},{51,92} }, P.gold.shade)
-- tiny matching hat, cocked, with its own feather
c:paint({
  "......DDDDDD......",
  ".....DhbbbbsD.....",
  ".....DbbbbbsD.....",
  ".....DEEEEESD.....",
  ".....DbbbbssD.....",
  ".DDDDbbbbbbbsDDDD.",
  "Dhbbbbbbbbbbbbbbsd",
  ".Dssssssssssssssd.",
  "..DDDDDDDDDDDDDD..",
}, 33, 67, { D = "wood.deep", d = "wood.deep", h = "wood.hi", b = "wood.base", s = "wood.shade", E = "ember.base", S = "ember.shade" })
c:paint({ "....g", "...gG", "..gG.", ".gG..", "gG...", "G...." }, 45, 64, { g = "gold.base", G = "gold.shade" })

c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

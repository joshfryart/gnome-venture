-- npc-auntie_mossbead.lua : Auntie Mossbead, keeper of Drum & Den (Greatcanopy, WCA). Cat Fish pet shops (art22).
-- A warm, smiling auntie gnome of the Greatcanopy market town: a tall moss-green gele (head wrap) with a pleated
-- fan and gold thread dots, gold disc earrings, a string of moss-green felt beads (her name), a kente-style
-- woven top in gold, green and red felt blocks, and a carved calabash bowl in her hands with a grey tabby kitten
-- peeking over the rim. 80x100 gvlib "bust" mode, same build as the ph/npc-* set (round backdrop disc, coat
-- bleeding off the bottom, 1 px #000000 border except the bottom edge). Light upper left; locked eyes; no text.
-- Run: AppRun -b --script npc-auntie_mossbead.lua   Writes ../out/npc-auntie_mossbead.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local D = "#2a1a10"

local SKIN  = GV.ramp("#7a4a2e")   -- deep warm brown skin (wood family)
local GELE  = GV.ramp("#4f9a45")   -- moss-green head wrap (moss family)
local TOP   = GV.ramp("#e8a317")   -- kente-style top, gold base (gold family)
local CALA  = GV.ramp("#d9a660")   -- calabash bowl (thatch / straw)
local KIT   = GV.ramp("#9a9488")   -- grey tabby kitten (stone family, warm)
local BEAD  = GV.ramp("#7ab55c")   -- felt beads (leaf light)

-- shapes
local disc  = c:ellipse(39.5, 50, 34, 34)
local coat  = c:ellipse(39.5, 104, 35, 28)
local neck  = c:rect(34, 68, 45, 78)
local head  = c:ellipse(39.5, 57, 18, 16)
local earL  = c:ellipse(21, 59, 2.5, 3.5)
local earR  = c:ellipse(58, 59, 2.5, 3.5)
-- gele: a full crown wrapped above the brow, a pleated fan rising to the upper right, a tuck at the left
local gele  = c:ellipse(39.5, 38, 22, 13):clip(c:rect(0, 0, 79, 47))
gele:add(c:rrect(18, 38, 61, 47, 4))
gele:cut(c:ellipse(39.5, 55, 17, 8):clip(c:rect(0, 47, 79, 99)))
local fan   = c:poly({ { 44, 34 }, { 43, 21 }, { 48, 12 }, { 57, 8 }, { 65, 12 }, { 69, 21 }, { 66, 30 }, { 60, 35 } })
local tuck  = c:poly({ { 16, 42 }, { 15, 34 }, { 20, 30 }, { 26, 33 } })
-- calabash bowl held in front with a kitten peeking over the rim
local kit   = c:ellipse(54.5, 84, 9.5, 7.5):add(c:poly({ { 46, 83 }, { 46, 73 }, { 52, 78 } })):add(c:poly({ { 57, 78 }, { 63, 73 }, { 63, 83 } }))
local bowl  = c:ellipse(52.5, 88, 18, 11):clip(c:rect(0, 87, 79, 99))
bowl:add(c:rect(35, 87, 70, 89))
local pawL  = c:ellipse(49, 87, 2.5, 2)
local pawR  = c:ellipse(60, 87, 2.5, 2)
local handL = c:ellipse(34, 93, 4, 3.5)
local handR = c:ellipse(70, 93, 3.5, 3.5)

local p = c:build{
  { "disc",  disc,  "#b5d68a", { contour = false, gloss = false } },
  { "coat",  coat,  TOP, { gloss = false } },
  { "neck",  neck,  SKIN, { gloss = false, contour = false } },
  { "earL",  earL,  SKIN, { flat = true } },
  { "earR",  earR,  SKIN, { flat = true } },
  { "head",  head,  SKIN, { gloss = { 27, 62 } } },
  { "tuck",  tuck,  GELE, { gloss = false } },
  { "fan",   fan,   GELE, { gloss = false } },
  { "gele",  gele,  GELE, { gloss = { 24, 32 }, stitch = { side = "lit" } } },
}
local p2 = c:build{
  { "kit",   kit,   KIT, { gloss = false } },
  { "bowl",  bowl,  CALA, { gloss = { 39, 90 } } },
  { "pawL",  pawL,  KIT, { flat = true, contact = false } },
  { "pawR",  pawR,  KIT, { flat = true, contact = false } },
  { "handL", handL, SKIN, { gloss = false } },
  { "handR", handR, SKIN, { gloss = false } },
}

-- gele pleats: fan folds (1 px shade lines) and wrap folds across the crown
for _, e in ipairs({ { 46, 18 }, { 51, 12 }, { 57, 10 }, { 63, 13 }, { 67, 20 } }) do
  c:fill(c:line({ { 56, 33 }, e }, 1):clip(p.fan.m:shrink(1)), GELE.shade)
end
c:fill(c:line({ { 20, 41 }, { 30, 35 }, { 44, 32 }, { 56, 34 } }, 1):clip(p.gele.m:shrink(1)), GELE.shade)
c:fill(c:line({ { 19, 30 }, { 24, 34 } }, 1):clip(p.tuck.m:shrink(1)), GELE.shade)
-- gold thread dots on the gele (glazed spots)
for _, q in ipairs({ { 27, 40 }, { 35, 37 }, { 43, 36 }, { 51, 38 }, { 31, 44 }, { 47, 43 }, { 39, 28 }, { 30, 30 } }) do
  if p.gele.m:has(q[1], q[2]) then c:px(q[1], q[2], "#f5cf6a") end
end
for _, q in ipairs({ { 53, 19 }, { 58, 23 }, { 62, 20 } }) do c:px(q[1], q[2], "#f5cf6a") end

-- kente-style woven blocks on the top: green and red bars with umber ticks on the gold, clear of bowl and hands
do
  local cloth = p.coat.m:copy():cut(bowl):cut(handL):cut(handR):cut(neck):cut(kit:grow(1)):shrink(1)
  cloth:cut(c:rect(26, 72, 52, 80))
  cloth:each(function(x, y)
    local bx, by = (x - 3) // 7, (y - 78) // 6
    local ix, iy = (x - 3) % 7, (y - 78) % 6
    if (bx + by) % 2 == 0 then
      if iy == 1 or iy == 2 then c:px(x, y, ((bx // 2) % 2 == 0) and "#2f8a3a" or "#c23a2a") end
    else
      if ix == 3 and iy < 4 then c:px(x, y, "#4a2c1a") end
    end
  end)
end
-- neckline: a scoop of the top over the neck
c:fill(c:ellipse(39.5, 77, 8, 3):clip(c:rect(0, 77, 79, 79)):cut(kit):cut(bowl), SKIN.shade)

-- string of moss-green felt beads (gold spacer every third bead), resting on the chest, behind the kitten
do
  local hide = kit:grow(1):add(bowl)
  local pts = { { 29, 71 }, { 31, 74 }, { 34, 76 }, { 37, 77 }, { 40, 77 }, { 43, 76 }, { 46, 74 }, { 48, 71 } }
  for i, q in ipairs(pts) do
    local gold = (i % 3 == 0)
    local cols = { gold and "#f08a24" or "#7ab55c", gold and "#c23a2a" or "#2f8a3a", gold and "#c23a2a" or "#2f8a3a", gold and "#7a2a20" or "#1f4f2a" }
    for j = 0, 2 do for ii = 0, 2 do
      local col = cols[2]
      if ii == 0 and j == 0 then col = cols[1] elseif ii + j >= 3 then col = cols[4] end
      if not hide:has(q[1] + ii, q[2] + j) then c:px(q[1] + ii, q[2] + j, col) end
    end end
  end
end

-- gold disc earrings
for _, q in ipairs({ { 19, 63 }, { 57, 63 } }) do
  c:paint({ ".g.", "ggs", ".s." }, q[1], q[2], { g = "#e8a317", s = "#d0862a" })
  c:px(q[1] + 1, q[2] + 1, "#f5cf6a")
end

-- calabash: carved rim band and zigzag (pyrography-style)
c:fill(c:rect(35, 89, 70, 89):clip(p2.bowl.m), CALA.shade)
for x = 37, 67, 4 do c:paint({ "z.", ".z" }, x, 93, { z = "#74462a" }) end

-- kitten face: small locked eyes (head under 20 px), pink nose, tabby stripes, inner ears
c:eye(48, 80, true); c:eye(58, 80, true)
c:px(54, 84, "#e46a9b"); c:px(55, 84, "#e46a9b")
c:paint({ "u..u", ".uu." }, 53, 85, { u = D })
c:fill(c:rect(54, 77, 55, 79), KIT.shade)
c:fill(c:rect(50, 78, 50, 79), KIT.shade); c:fill(c:rect(59, 78, 59, 79), KIT.shade)
c:fill(c:rect(48, 77, 49, 79), "#e46a9b"); c:fill(c:rect(60, 77, 61, 79), "#e46a9b")
c:px(48, 86, KIT.rim); c:px(59, 86, KIT.rim)

-- face: locked eyes, soft nose, a broad friendly smile
c:eye(28, 53); c:eye(46, 53)
c:paint({ ".n.", "nnn" }, 38, 59, { n = SKIN.shade })
c:paint({ "u........u", ".uuuuuuuu.", "..uuuuuu.." }, 35, 63, { u = D })
c:fill(c:rect(37, 64, 42, 64), "#dd3a2a")

-- joins: gele hem seam above the brow, a button at the gele knot
c:seam({ { 19, 46 }, { 30, 47 }, { 49, 47 }, { 60, 46 } })
c:button(56, 31)

local t = c:save(OUT .. "npc-auntie_mossbead.aseprite", OUT .. "npc-auntie_mossbead.png")
print(GV.report(t))
assert(t.semi == 0)

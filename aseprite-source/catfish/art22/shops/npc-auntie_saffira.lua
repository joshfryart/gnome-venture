-- npc-auntie_saffira.lua : Cat Fish shopkeeper bust, Auntie Saffira of "Lantern & Lounge" (Dunewhisper, MENA).
-- Matches the npc-* busts in game/assets/img/ph/ (80x100, gvlib "bust" mode, pastel backdrop disc, body bleeding
-- off the bottom edge, 1 px black border on the other sides, locked eyes, gold seams and button).
-- A warm gnome auntie in a saffron headscarf with a soft gnome-hood peak (tassel bead), a teal kaftan with gold
-- embroidery, cuddling a ginger kitten; one of her shop's cat-eared brass lanterns hangs at her side.
-- Run: AppRun -b --script npc-auntie_saffira.lua   (writes art22/out/npc-auntie_saffira.png + .aseprite)
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local DISC   = GV.ramp("#a9d6ea")
local ROBE   = GV.ramp("#2f8a8c")
local SCARF  = GV.ramp("#e8862a")
local SKIN   = GV.ramp("#b97a50")
local HAIR   = GV.ramp("#4a2c2a")
local KIT    = GV.ramp("#f08a24", { gloss = "#ffc27a", dot = "#fff1c8", rim = "#f5b060" })
local PAW    = GV.ramp("#f2e4c0")

-- backdrop disc
local disc = c:ellipse(39.5, 50, 36, 36)
-- kaftan (bleeds off the bottom)
local robe = c:ellipse(39.5, 101, 33, 24):clip(c:rect(0, 78, 79, 99))
-- headscarf: round hood with a soft gnome peak flopping to the upper right, draping onto the shoulders
local hood = c:ellipse(39.5, 55, 23, 22)
hood:add(c:poly({ { 19, 48 }, { 22, 36 }, { 29, 27 }, { 38, 21 }, { 48, 17 }, { 57, 15 }, { 62, 17 }, { 60, 22 }, { 55, 24 }, { 59, 36 }, { 61, 48 } }))
hood:add(c:poly({ { 17, 60 }, { 62, 60 }, { 64, 86 }, { 15, 86 } }))
-- face and hair fringe
local face = c:ellipse(39.5, 59, 15, 14)
local hair = c:ellipse(39.5, 51, 15, 7):cut(c:rect(0, 50, 79, 99))
hair:add(c:ellipse(26.5, 54, 3, 4)):add(c:ellipse(52.5, 54, 3, 4))
hair:clip(face)
-- front fold of the scarf under the chin
local wrap = c:ellipse(39.5, 77, 17, 5):cut(c:rect(0, 0, 79, 73))
-- tassel bead on the peak
local bead = c:rrect(60, 13, 64, 17, 1)

-- brass lantern hanging at her left (cat-eared cap)
local chain = c:rect(12, 14, 13, 22)
local lcap = c:poly({ { 7, 27 }, { 9, 23 }, { 11, 25 }, { 14, 25 }, { 16, 23 }, { 18, 27 } })
local lbody = c:rrect(8, 27, 17, 39, 2)
local lfoot = c:rect(10, 40, 15, 41)

-- ginger kitten cuddled at her right
local kHead = c:ellipse(57, 82, 9, 7)
kHead:add(c:poly({ { 48, 80 }, { 49, 70 }, { 55, 76 } })):add(c:poly({ { 59, 76 }, { 65, 70 }, { 66, 80 } }))
local kBody = c:ellipse(57, 97, 10, 8)
local paws = c:ellipse(51.5, 91, 3, 2):add(c:ellipse(62.5, 91, 3, 2))
local hand = c:ellipse(45, 93, 4, 3)

c:build{
  { "disc", disc, DISC, { gloss = false } },
  { "robe", robe, ROBE, { stitch = { side = "lit" } } },
  { "hood", hood, SCARF, { stitch = { side = "lit" } } },
  { "bead", bead, "gold", { flat = true } },
  { "face", face, SKIN },
  { "hair", hair, HAIR, { flat = true } },
  { "wrap", wrap, SCARF, { gloss = false } },
  { "chain", chain, "#8a4f2a", { flat = true } },
  { "lcap", lcap, "gold", { flat = true } },
  { "lbody", lbody, "gold", { gloss = false } },
  { "lfoot", lfoot, "gold", { flat = true } },
  { "kBody", kBody, KIT, { gloss = false } },
  { "hand", hand, SKIN, { gloss = false } },
  { "kHead", kHead, KIT },
  { "paws", paws, PAW, { flat = true } },
}

-- lantern: glowing window with a cat-face cutout and two brass bands
c:fill(c:rrect(10, 30, 15, 37, 1), "#fff1c8")
c:fill(c:rect(10, 33, 15, 33), "#d0862a")
c:px(11, 31, "#f5cf6a"); c:px(14, 31, "#f5cf6a")

-- scarf: gold trim seam framing the face, seam on the chin fold
local trim = {}
for i = 0, 16 do
  local a = math.pi * (1.05 + 0.9 * i / 16)
  trim[#trim + 1] = { math.floor(39.5 + 17 * math.cos(a) + 0.5), math.floor(59 + 16 * math.sin(a) + 0.5) }
end
c:seam(trim)
c:seam({ { 25, 77 }, { 32, 80 }, { 39, 81 }, { 46, 80 }, { 53, 77 } })
c:button(37, 82)

-- kaftan embroidery: gold V below the fold
c:seam({ { 30, 88 }, { 37, 98 } }); c:seam({ { 47, 88 }, { 42, 95 } })

-- face
c:eye(29, 56); c:eye(46, 56)
c:fill(c:rect(39, 61, 40, 62), SKIN.shade)          -- small nose
c:paint({ "u........u", ".uuuuuuuu." }, 35, 65, { u = "#2a1a10" })

-- kitten face: small locked eyes, pink nose, tabby stripes, inner ears
c:eye(51, 80, true); c:eye(60, 80, true)
c:px(56, 84, "#dd3a2a"); c:px(57, 84, "#dd3a2a")
c:paint({ "u.u", ".u." }, 55, 85, { u = "#2a1a10" })
c:paint({ "s.s.s" }, 55, 76, { s = KIT.shade })
c:fill(c:poly({ { 50, 78 }, { 50, 73 }, { 53, 76 } }), "#dd3a2a")
c:fill(c:poly({ { 61, 76 }, { 64, 73 }, { 64, 78 } }), "#dd3a2a")

local t = c:save(OUT .. "npc-auntie_saffira.aseprite", OUT .. "npc-auntie_saffira.png")
print(GV.report(t))

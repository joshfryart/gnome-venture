-- npc-auntie_saffira.lua : Cat Fish shopkeeper bust, Auntie Saffira of "Lantern & Lounge" (Dunewhisper, MENA).
-- Matches the npc-* busts in game/assets/img/ph/ (80x100, gvlib "bust" mode, pastel backdrop disc, body bleeding
-- off the bottom edge, 1 px black border on the other sides, locked eyes, gold seams and button).
-- A warm gnome auntie in a saffron headscarf with a soft gnome-hood peak (tassel bead), a teal kaftan with gold
-- embroidery, cuddling a cream kitten; one of her shop's cat-eared brass lanterns hangs at her side.
-- Run: AppRun -b --script npc-auntie_saffira.lua   (writes art22/out/npc-auntie_saffira.png + .aseprite)
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local DISC   = GV.ramp("#a9d6ea")
local ROBE   = GV.ramp("#2f8a8c")
local SCARF  = GV.ramp("#e8902a")
local SKIN   = GV.ramp("#b97a50")
local HAIR   = GV.ramp("#4a2c2a")
local KIT    = GV.ramp("#e2cca0", { pale = false })
local PAW    = GV.ramp("#f2e4c0")

-- backdrop disc
local disc = c:ellipse(39.5, 50, 36, 36)
-- kaftan (bleeds off the bottom)
local robe = c:ellipse(39.5, 101, 33, 24):clip(c:rect(0, 78, 79, 99))
-- headscarf: round hood with a soft gnome peak drooping to the right, draping onto the shoulders
local hood = c:ellipse(39.5, 57, 22, 21)
hood:add(c:poly({ { 20, 47 }, { 24, 36 }, { 31, 29 }, { 40, 25 }, { 49, 22 }, { 56, 21 }, { 61, 24 }, { 58, 27 }, { 55, 29 }, { 58, 38 }, { 60, 48 } }))
hood:add(c:poly({ { 19, 64 }, { 60, 64 }, { 63, 84 }, { 16, 84 } }))
-- face and hair fringe
local face = c:ellipse(39.5, 59, 16, 15)
local hair = c:ellipse(39.5, 50, 16, 7):cut(c:rect(0, 49, 79, 99))
hair:add(c:ellipse(25.5, 53, 3, 4)):add(c:ellipse(53.5, 53, 3, 4))
hair:clip(face)
-- front fold of the scarf under the chin
local wrap = c:ellipse(39.5, 77, 18, 6):cut(c:rect(0, 0, 79, 73))
-- tassel bead on the peak
local bead = c:rrect(59, 21, 64, 26, 2)

-- brass lantern hanging at her side (cat-eared cap, glowing window)
local chain = c:rect(12, 13, 13, 24)
local lcap = c:poly({ { 5, 30 }, { 6, 21 }, { 10, 26 }, { 15, 26 }, { 19, 21 }, { 20, 30 } })
local lbody = c:rrect(6, 29, 19, 44, 2)
local lfoot = c:rect(8, 45, 17, 47)

-- cream kitten cuddled at her right
local kHead = c:ellipse(57, 82, 9, 7)
kHead:add(c:poly({ { 48, 81 }, { 49, 70 }, { 55, 76 } })):add(c:poly({ { 59, 76 }, { 65, 70 }, { 66, 81 } }))
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
  { "lbody", lbody, "gold", { gloss = false } },
  { "lcap", lcap, "gold", { flat = true } },
  { "lfoot", lfoot, "gold", { flat = true } },
  { "kBody", kBody, KIT, { gloss = false } },
  { "hand", hand, SKIN, { gloss = false } },
  { "kHead", kHead, KIT },
  { "paws", paws, PAW, { flat = true } },
}

-- lantern window: warm glow with a little cat silhouette
c:fill(c:rrect(8, 32, 17, 42, 2), "#fff1c8")
c:fill(c:ellipse(12.5, 39, 3, 2.5):add(c:poly({ { 9, 39 }, { 9, 34 }, { 12, 37 } })):add(c:poly({ { 13, 37 }, { 16, 34 }, { 16, 39 } })), "#b8661a")
c:px(11, 38, "#fff1c8"); c:px(14, 38, "#fff1c8")

-- scarf: gold trim seam framing the face, seam on the chin fold
local trim = {}
for i = 0, 18 do
  local a = math.pi * (1.02 + 0.96 * i / 18)
  trim[#trim + 1] = { math.floor(39.5 + 18 * math.cos(a) + 0.5), math.floor(59 + 17 * math.sin(a) + 0.5) }
end
c:seam(trim)
c:seam({ { 24, 77 }, { 31, 80 }, { 39, 82 }, { 46, 81 } })
c:button(36, 83)

-- kaftan embroidery: gold V below the fold
c:seam({ { 28, 88 }, { 35, 99 } }); c:seam({ { 45, 89 }, { 41, 96 } })

-- face
c:eye(29, 56); c:eye(46, 56)
c:fill(c:rect(39, 61, 40, 62), SKIN.shade)          -- small nose
c:paint({ "u........u", ".uuuuuuuu." }, 35, 65, { u = "#2a1a10" })

-- kitten face: small locked eyes, pink nose, tabby stripes, inner ears, red collar with a gold bell
c:eye(51, 80, true); c:eye(60, 80, true)
c:px(56, 84, "#dd3a2a"); c:px(57, 84, "#dd3a2a")
c:paint({ "u..u", ".uu." }, 55, 85, { u = "#2a1a10" })
c:paint({ "s.s.s" }, 55, 76, { s = KIT.shade })
c:fill(c:poly({ { 50, 79 }, { 50, 73 }, { 53, 76 } }), "#e46a9b")
c:fill(c:poly({ { 61, 76 }, { 64, 73 }, { 64, 79 } }), "#e46a9b")
c:fill(c:rect(50, 89, 64, 89), "#dd3a2a")
c:fill(c:rect(56, 90, 57, 91), "#e8a317"); c:px(56, 90, "#f5cf6a")

local t = c:save(OUT .. "npc-auntie_saffira.aseprite", OUT .. "npc-auntie_saffira.png")
print(GV.report(t))

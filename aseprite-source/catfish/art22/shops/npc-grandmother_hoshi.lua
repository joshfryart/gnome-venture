-- npc-grandmother_hoshi.lua : shopkeeper bust for Blossom Lantern Cattery (Blossomreach, EA).
-- Matches the shipped villager busts (game/assets/img/ph/npc-*.png, scripts aseprite-source/final/scripts/ph/):
-- 80x100, gvlib "bust" mode (1 px black border, none on the bottom edge), backing disc, body bleeding off the
-- bottom, locked eyes. Grandmother Hoshi is a kindly old grey mouse: silver bun with a hairpin topped by a
-- gold star (hoshi), round gold-wire spectacles, plum kimono-style jacket worn left-over-right (the visible
-- collar runs from her left shoulder down across), red obi with a gold seam, and she holds a calico
-- maneki-neko with a raised paw, red collar and gold bell.
-- Run: AppRun -b --script npc-grandmother_hoshi.lua   Writes ../out/npc-grandmother_hoshi.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local FUR   = GV.ramp("#b3a39c", { rim = "#d4c6bc", gloss = "#e2d6cc", dot = "#f2e4c0" })
local HAIR  = GV.ramp("#e6dee6", { shade = "#b8aac4", deep = "#8a7aa0", bounce = "#c4b4cc" })
local PLUM  = GV.ramp("#8a4a7a", { rim = "#b06a96", gloss = "#d08aa8", dot = "#f6b8cf", shade = "#5e2f5e", deep = "#3e2046", bounce = "#6e3a62" })
local OBI   = GV.R.red
local CAT   = GV.ramp("#f1ece0", { shade = "#d8c49a", bounce = "#e6d4ac", deep = "#b8aac4" })
local PINKE = GV.ramp("#e46a9b", { rim = "#f6b8cf", shade = "#b84a7a", deep = "#8a3460", bounce = "#c4587e" })

-- shapes
local disc  = c:ellipse(39.5, 50, 36)
local body  = c:ellipse(39.5, 104, 35, 28)
local earL  = c:ellipse(17, 36, 10, 10)
local earR  = c:ellipse(62, 36, 10, 10)
local inL   = c:ellipse(16, 36, 6, 6)
local inR   = c:ellipse(63, 36, 6, 6)
local head  = c:ellipse(39.5, 56, 22, 19)
local hair  = c:ellipse(39.5, 45, 19, 10):cut(c:rect(0, 47, 79, 99))
hair:add(c:ellipse(30, 47, 7, 3)):add(c:ellipse(49, 47, 7, 3))
local bun   = c:ellipse(39.5, 29, 9, 7)
local pin   = c:line({ { 26, 33 }, { 54, 24 } }, 2)
local muzz  = c:ellipse(39.5, 65, 11, 7.5)
local obi   = c:rect(0, 93, 79, 99):clip(body)

c:build{
  { "disc", disc, "#f6b8cf", { contour = false, gloss = false } },
  { "earL", earL, FUR, { gloss = false } },
  { "earR", earR, FUR, { gloss = false } },
  { "inL",  inL,  PINKE, { flat = true } },
  { "inR",  inR,  PINKE, { flat = true } },
  { "body", body, PLUM, { stitch = { side = "lit" } } },
  { "obi",  obi,  OBI, { gloss = false, cres = 3, deep = 1 } },
  { "head", head, FUR },
  { "bun",  bun,  HAIR, { gloss = { 34, 25 } } },
  { "hair", hair, HAIR, { gloss = { 27, 40 } } },
  { "muzz", muzz, "cream", { gloss = false, cres = 3, deep = 1 } },
}

-- hairpin (kanzashi) through the bun, with a gold star and a dangling pink blossom bead
c:part(pin, "wood", { flat = true })
c:paint({
  "..g..",
  ".ggg.",
  "ggggg",
  ".gSg.",
  ".g.S.",
}, 53, 19, { g = "#f5cf6a", S = "#e8a317" })
c:px(55, 21, "#fff1c8")
c:px(56, 25, "#e8a317"); c:px(56, 26, "#e8a317")
c:fill(c:rect(55, 27, 57, 28), "#e46a9b"); c:px(55, 27, "#f6b8cf")

-- kimono collar, left over right: cream under-collar V, plum-dark collar bands
local neckV = c:poly({ { 31, 76 }, { 49, 76 }, { 40, 88 } }):clip(body)
c:fill(neckV, "#f2e4c0")
c:fill(c:line({ { 31, 75 }, { 40, 87 } }, 3):clip(body), "#3e2046")      -- under panel edge (short stroke)
c:fill(c:line({ { 50, 75 }, { 40, 87 }, { 31, 95 } }, 3):clip(body), "#5e2f5e") -- top panel edge (long stroke)
c:fill(c:line({ { 49, 75 }, { 40, 86 }, { 31, 94 } }, 1):clip(body), "#b06a96") -- lit edge on the top collar
c:seam({ { 2, 96 }, { 78, 96 } })

-- face: locked eyes, gold-wire spectacles, nose, whiskers, gentle smile
c:eye(27, 52); c:eye(48, 52)
local rimL = c:ellipse(29, 54, 5, 5):cut(c:ellipse(29, 54, 4, 4))
local rimR = c:ellipse(50, 54, 5, 5):cut(c:ellipse(50, 54, 4, 4))
c:fill(rimL:add(rimR), "#e8a317")
c:fill(c:rect(35, 53, 44, 53), "#e8a317")
c:px(26, 51, "#f5cf6a"); c:px(47, 51, "#f5cf6a")
c:fill(c:rrect(37, 60, 42, 62, 1), "#e46a9b"); c:px(38, 60, "#f6b8cf")
c:paint({ "u....u", ".uuuu." }, 37, 66, { u = "umber" })
c:px(39, 63, "#4a2c1a"); c:px(40, 63, "#4a2c1a"); c:px(39, 64, "#4a2c1a"); c:px(40, 65, "#4a2c1a")
for _, w in ipairs({ { { 21, 61 }, { 28, 63 } }, { { 21, 66 }, { 28, 65 } }, { { 51, 63 }, { 58, 61 } }, { { 51, 65 }, { 58, 66 } } }) do
  c:fill(c:line(w, 1), "#74462a")
end
-- soft brows (silver)
c:fill(c:line({ { 26, 48 }, { 31, 47 } }, 1), "#e6dee6")
c:fill(c:line({ { 48, 47 }, { 53, 48 } }, 1), "#e6dee6")

-- the maneki-neko she holds, lower right
local mb = c:ellipse(53.5, 91, 8, 7)
local mh = c:ellipse(53.5, 80, 7, 6)
mh:add(c:poly({ { 47, 78 }, { 47, 72 }, { 51, 75 } })):add(c:poly({ { 56, 75 }, { 60, 72 }, { 60, 78 } }))
local paw = c:rrect(60, 77, 64, 86, 2)                     -- raised beckoning paw
local hands = c:ellipse(45, 94, 3.5, 3):add(c:ellipse(62, 95, 3.5, 3))
local q = c:build{
  { "mb",   mb,   CAT },
  { "paw",  paw,  CAT, { gloss = false, cres = 2, deep = 1 } },
  { "mh",   mh,   CAT, { gloss = { 49, 77 } } },
  { "hands", hands, FUR, { gloss = false, cres = 2, deep = 1 } },
}
-- calico patches, ear insides, happy closed eyes, nose, collar + bell
c:spot(c:ellipse(57, 77, 2, 1.5), "#f2793a", "#ffc27a")
c:spot(c:ellipse(50, 90, 2, 2), "#f2793a", "#ffc27a")
c:spot(c:ellipse(56, 93, 1.5, 1.5), "#4a2c1a", "#74462a")
c:px(48, 75, "#e46a9b"); c:px(48, 76, "#e46a9b"); c:px(59, 75, "#e46a9b"); c:px(59, 76, "#e46a9b")
c:paint({ "u.u", ".u." }, 49, 79, { u = "umber" })
c:paint({ "u.u", ".u." }, 55, 79, { u = "umber" })
c:px(53, 82, "#e46a9b"); c:px(54, 82, "#e46a9b")
c:fill(c:rect(47, 85, 60, 86), "#dd3a2a")
c:fill(c:rect(52, 87, 55, 89), "#e8a317"); c:px(52, 87, "#f5cf6a"); c:px(53, 89, "#8a4a1c")
c:fill(c:rect(61, 80, 63, 80), "#d8c49a")                 -- paw toe line

local t = c:save(OUT .. "npc-grandmother_hoshi.aseprite", OUT .. "npc-grandmother_hoshi.png")
print(GV.report(t))

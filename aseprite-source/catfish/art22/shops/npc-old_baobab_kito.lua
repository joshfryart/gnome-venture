-- npc-old_baobab_kito.lua : Cat Fish pet shops (claude/plan-catfish-petshops.md s1), ESA "Thornacre Trading Den".
-- Shopkeeper bust: Old Baobab Kito, a kind grandfather gnome of Thornacre Savanna. 80x100 gvlib "bust" mode, same
-- build as the ph/npc-* busts and the other shopkeepers (round backdrop disc, head ~38 px, coat bleeding off the
-- bottom, 1 px #000000 border, none on the bottom edge). Warm brown skin, a round white beard and brows, a cream
-- embroidered cap (kofia-style, felt), a striped woven cloth over one shoulder pinned with a gold button, a little
-- baobab-leaf pin, and a woven grass basket in his hands with a tabby kitten peeking out. Friendly smile, no blush.
-- Light from the upper left; locked eyes; no text.
-- Run: AppRun -b --script npc-old_baobab_kito.lua     Writes ../out/npc-old_baobab_kito.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local D = "#2a1a10"

local SKIN  = GV.ramp("#8c5a34")                       -- warm brown skin
local BEARD = GV.ramp("#ece6dc", { pale = true })      -- white beard and brows
local CAP   = GV.ramp("#f1ece0", { dot = "#fff3c8", shade = "#d8c49a", bounce = "#e6d4ac", deep = "#9a6b3f" })
local SHIRT = GV.ramp("#4f9a45")                       -- moss shirt
local CLOTH = GV.ramp("#e8a317")                       -- gold striped shoulder cloth
local BASKET = GV.ramp("#d9a660", { shade = "#b07a45", deep = "#8a4f2a", bounce = "#c98a4a" })
local KIT   = GV.ramp("#9a8a7a")                       -- grey-brown tabby kitten

-- shapes
local disc  = c:ellipse(39.5, 50, 34, 34)
local coat  = c:ellipse(39.5, 104, 35, 28)
local earL  = c:ellipse(20.5, 57, 2.5, 3.5)
local earR  = c:ellipse(58.5, 57, 2.5, 3.5)
local head  = c:ellipse(39.5, 55, 19, 18)
local beard = c:ellipse(39.5, 67, 15, 11):cut(c:rect(0, 0, 79, 59))
beard:add(c:ellipse(39.5, 78, 9, 6))
local cap   = c:rrect(21, 30, 58, 44, 4)
local capTop = c:ellipse(39.5, 31, 18, 3)
-- striped cloth over the viewer's-left shoulder, falling across the chest
local cloth = c:poly({ { 5, 99 }, { 8, 84 }, { 18, 76 }, { 30, 80 }, { 44, 99 } })
-- woven basket held in front, lower right, with a kitten peeking out
local kitH  = c:ellipse(53.5, 80, 9, 7.5)
kitH:add(c:poly({ { 45, 79 }, { 45, 69 }, { 52, 74 } }))
kitH:add(c:poly({ { 55, 74 }, { 62, 69 }, { 62, 79 } }))
local basket = c:rrect(40, 84, 68, 99, 4):add(c:ellipse(54, 85, 15, 3))
local rim    = c:ellipse(54, 85, 15, 2.5)
local handL = c:ellipse(39, 92, 4, 3.5)
local handR = c:ellipse(69, 92, 4, 3.5)

local p = c:build{
  { "disc",   disc,   "#f5b860", { contour = false, gloss = false } },
  { "coat",   coat,   SHIRT, { gloss = false } },
  { "earL",   earL,   SKIN, { gloss = false } },
  { "earR",   earR,   SKIN, { gloss = false } },
  { "head",   head,   SKIN },
  { "beard",  beard,  BEARD, { gloss = false } },
  { "cap",    cap,    CAP, { gloss = { 25, 35 } } },
  { "capTop", capTop, CAP, { flat = true } },
  { "cloth",  cloth,  CLOTH, { stitch = { side = "lit" }, gloss = false } },
  { "kit",    kitH,   KIT, { gloss = false } },
  { "basket", basket, BASKET, { gloss = false } },
  { "rim",    rim,    BASKET, { flat = true } },
  { "handL",  handL,  SKIN, { gloss = false } },
  { "handR",  handR,  SKIN, { gloss = false } },
}

-- cap embroidery: a gold zigzag band and red/moss dots (felt stitch-work, kofia-style)
for x = 23, 56 do
  local k = (x - 23) % 4
  local y = 40 - ((k < 2) and k or (3 - k))
  if p.cap.m:has(x, y) then c:px(x, y, "#e8a317") end
end
for x = 25, 55, 4 do
  if p.cap.m:has(x, 35) then c:px(x, 35, (x % 8 == 1) and "#dd3a2a" or "#4f9a45"); c:px(x + 1, 35, (x % 8 == 1) and "#dd3a2a" or "#4f9a45") end
end
c:seam({ { 22, 43 }, { 57, 43 } })

-- cloth stripes (red and moss bands across the gold weave), skipping kitten/basket/hands
local clothOnly = cloth:copy():cut(handL):shrink(1)
clothOnly:each(function(x, y)
  local d = y % 7
  if d == 0 or d == 1 then c:px(x, y, "#dd3a2a") elseif d == 4 then c:px(x, y, "#2f6a3a") end
end)
c:button(24, 79)

-- basket weave: staggered dashes
for y = 88, 98, 3 do
  for x = 43, 66, 4 do
    local xx = x + ((y // 3) % 2) * 2
    if p.basket.m:has(xx, y) and p.basket.m:has(xx + 1, y) then c:px(xx, y, "#b07a45"); c:px(xx + 1, y, "#b07a45") end
  end
end
c:seam({ { 41, 86 }, { 67, 86 } })

-- baobab-leaf pin on the shirt, viewer's right chest: a little gold trunk with a green tuft
c:paint({ ".gg.", "gggg", ".tt.", ".tt." }, 63, 78, { g = "#7ab55c", t = "#b8661a" })

-- face: eyes, white brows, soft nose, smile in the beard
c:eye(29, 49); c:eye(46, 49)
c:paint({ ".bbbb.", "bb..bb" }, 28, 45, { b = "#ece6dc" })
c:paint({ ".bbbb.", "bb..bb" }, 45, 45, { b = "#ece6dc" })
c:paint({ ".n..", "nnnn", ".nn." }, 38, 55, { n = "#6a3e22" })
-- mustache over the beard, smile below
c:paint({ "..bbbb..bbbb..", ".bbbbbbbbbbbb.", "bbb........bbb" }, 33, 59, { b = "#ece6dc" })
c:paint({ "u......u", ".uuuuuu." }, 36, 62, { u = D })
c:fill(c:rect(38, 63, 41, 63), "#dd3a2a")
-- crinkle lines at the eye corners
c:px(26, 52, "#6a3e22"); c:px(52, 52, "#6a3e22")

-- kitten face: small locked eyes, pink nose, mouth, tabby stripes
c:eye(47, 77, true); c:eye(57, 77, true)
c:paint({ "pp" }, 53, 81, { p = "#e46a9b" })
c:paint({ "u.uu.u", ".u..u." }, 51, 82, { u = D })
c:fill(c:rect(53, 73, 54, 75), "#6e5a4a")
c:fill(c:rect(49, 74, 50, 75), "#6e5a4a"); c:fill(c:rect(57, 74, 58, 75), "#6e5a4a")
c:fill(c:rect(47, 72, 47, 75), "#e46a9b"); c:fill(c:rect(60, 72, 60, 75), "#e46a9b")

local t = c:save(OUT .. "npc-old_baobab_kito.aseprite", OUT .. "npc-old_baobab_kito.png")
print("npc-old_baobab_kito " .. GV.report(t))

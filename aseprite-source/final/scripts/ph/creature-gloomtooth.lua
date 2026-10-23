-- Gloomtooth: trek boss, a blind old mole with a blackened muzzle and huge digging claws.
-- Blind: clouded eye discs (stone pale, no pupil) in place of the locked eye, on purpose.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local back   = GV.ramp("#4a5160")                                   -- stone dark: velvet slate body
local fur    = GV.ramp("#5b6470")                                   -- stone dark: head fur
local silver = GV.ramp("#8b8f96")                                   -- stone mid: grizzled old mantle
local soot   = GV.ramp("#3d2a1c", { shade = "#2a1a10", deep = "#2a1a10" }) -- soil darkest: blackened muzzle
local paw    = GV.R.skin
local bone   = GV.R.cream

local body   = c:ellipse(32, 31, 23, 17)
local tufts  = c:poly({ {17, 18}, {20, 10}, {24, 16} }):add(c:poly({ {28, 15}, {32, 7}, {36, 15} })):add(c:poly({ {40, 16}, {44, 10}, {47, 18} }))
local mantle = c:ellipse(32, 18, 19, 7):clip(body):add(tufts)
local head   = c:ellipse(32, 30, 14, 11)
local snout  = c:ellipse(32.5, 40, 8, 6):add(c:poly({ {25, 40}, {41, 40}, {37, 50}, {28, 50} })):add(c:ellipse(32.5, 48.5, 4.5, 3))
local fangs  = c:poly({ {28, 49}, {33, 49}, {33, 53}, {32, 57}, {30, 57}, {29, 54} })   -- the one long old tooth
local pawL   = c:ellipse(15, 43, 8, 5.5)
local pawR   = c:ellipse(48, 43, 8, 5.5)
local function claw(x0, y0, x1, y1, x2, y2) return c:line({ {x0, y0}, {x1, y1} }, 3):add(c:line({ {x1, y1}, {x2, y2} }, 2)) end
local claws  = claw(9, 45, 8, 49, 8, 53):add(claw(14, 47, 13, 51, 14, 55)):add(claw(19, 47, 20, 51, 22, 54))
claws:add(claw(53, 45, 54, 49, 54, 53)):add(claw(48, 47, 49, 51, 48, 55)):add(claw(43, 47, 42, 51, 40, 54))

c:build{
  { "body",   body, back, { stitch = { side = "lit" } } },
  { "mantle", mantle, silver, { gloss = false, light = body:copy():add(tufts) } },
  { "head",   head, fur, { light = head:copy():add(body) } },
  { "claws",  claws, bone, { flat = true } },
  { "snout",  snout, soot, { gloss = { 28, 37 } } },
  { "fangs",  fangs, bone, { flat = true } },
  { "pawL",   pawL, paw },
  { "pawR",   pawR, paw },
}
-- nostrils at the snout tip
c:px(33, 47, "#5e2a3a"); c:px(36, 47, "#5e2a3a")
-- knuckle creases on the digging paws
c:paint({ "s...s", "s...s" }, 11, 44, { s = paw.deep }); c:paint({ "s...s", "s...s" }, 46, 44, { s = paw.deep })
-- stitched scar across the right brow: dark gash, gold seam over it
c:paint({ "d........", ".d.......", "..d......", "...dd....", ".....d...", "......d..", ".......d.", "........d" }, 36, 20, { d = fur.deep })
-- clouded blind eyes: 5x5 cut-corner stone-pale disc, no pupil, milky lower-right, 1 px glint
local function blind(x, y)
  for j = 0, 4 do for i = 0, 4 do
    if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then
      c:px(x+i, y+j, (i + j >= 5) and "#8b8f96" or "#c9c5bc")
    end
  end end
  c:px(x+1, y+1, "#f2e4c0")
end
blind(21, 26); blind(38, 26)
c:seam({ {36, 20}, {44, 27} }, { free = true })
c:ground(32, 54, 21, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-gloomtooth.aseprite", PNG .. "creature-gloomtooth.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

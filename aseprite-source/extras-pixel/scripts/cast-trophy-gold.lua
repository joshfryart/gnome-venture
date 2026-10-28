-- Trophy gold: golden cup whose bowl is a jigsaw piece (knob on top, tabs for handles, notch at the stem),
-- with a purple mini piece as the crest. Gold family.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bowl = c:poly({ {17, 16}, {46, 16}, {44, 39}, {19, 39} })
bowl:add(c:ellipse(31.5, 13, 6, 5.5))                                 -- knob up
bowl:cut(c:ellipse(31.5, 40, 5.5, 4))                                 -- notch at the stem
local tabs = c:ellipse(13, 26, 5, 5); tabs:add(c:ellipse(50, 26, 5, 5))  -- handle tabs
tabs:cut(bowl:shrink(1)); tabs:cut(c:ellipse(12, 26, 2, 2)); tabs:cut(c:ellipse(51, 26, 2, 2))   -- open loops
local stem = c:rrect(28, 39, 35, 45, 2)
local base = c:rrect(19, 45, 44, 49, 2); base:add(c:rrect(16, 49, 47, 53, 2))
local crest = K.miniPiece(c, 28, 21)

c:build{
  { "tabs", tabs, "gold", { flat = true } },
  { "base", base, "gold", { stitch = false } },
  { "stem", stem, GV.ramp("#d0862a"), { gloss = false } },
  { "bowl", bowl, "gold", {} },
  { "crest", crest, GV.ramp("#8a5fd0"), { gloss = { 29, 24 } } },
}
c:seam({ {19, 51}, {44, 51} })                                        -- plinth lip
c:button(29, 14)
c:paint({ ".s.", "sss", ".s." }, 38, 20, { s = "#fff1c8" })              -- star glint on the lit side
c:paint({ "d.d.d.d.d.d.d" }, 25, 35, { d = "#b8661a" })                -- engraved rim dots
K.save(c, "trophy-gold")

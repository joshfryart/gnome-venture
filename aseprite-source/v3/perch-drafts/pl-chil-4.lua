-- pl-chil-4-perch.lua : 36x36 chibi perch of the fez + lantern pal (gvlib)  [PHASE 4: SHADE]
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-chil-4-perch-20261120-173324/"
local GV = dofile(D .. "gvlib/gvlib.lua")
-- chibi perch scale: uniform 1px dark outline like the finished examples
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#2b1c26", "#2b1c26", "#2b1c26"
local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 0, cres = 2, deep = 1 }

-- ramps from the pal's palette
local body  = GV.ramp("#b86b2c", { rim = "#c67c49", gloss = "#e2ac67" })
local hat   = GV.ramp("#b2352f", { rim = "#d84a31", gloss = "#e35436" })
local wood  = GV.ramp("#9e6648")
local gold  = GV.ramp("#e2ac67")
local cream = GV.ramp("#efe6a9")
local dark  = GV.ramp("#52141c", { rim = "#87331f" })
local limb  = GV.ramp("#c67c49")

-- masks
local pole  = c:rect(5, 9, 6, 32)
local glass = c:rrect(4, 5, 8, 10, 1)
local frame = c:rrect(3, 4, 9, 11, 1):cut(glass)
local plank = c:rrect(10, 27, 26, 32, 2)
local blob  = c:ellipse(18, 19, 10.5, 8)
local armL  = c:rrect(6, 17, 9, 19, 1)
local armR  = c:rrect(25, 17, 28, 19, 1)
local fish  = c:poly({ { 27, 15 }, { 29, 16 }, { 29, 19 }, { 27, 20 } }):add(c:ellipse(31, 17.5, 2, 1.5))
local footL = c:rrect(11, 27, 13, 29, 1)
local footR = c:rrect(22, 27, 24, 29, 1)
local fez   = c:poly({ { 16, 3 }, { 23, 3 }, { 25, 12 }, { 14, 12 } })

c:build({
  { "pole",  pole,  wood,  { gloss = false } },
  { "glass", glass, cream, { flat = true } },
  { "frame", frame, gold,  { flat = true, gloss = false } },
  { "plank", plank, wood,  { gloss = false } },
  { "blob",  blob,  body,  { gloss = false } },
  { "armL",  armL,  limb,  { flat = true } },
  { "armR",  armR,  limb,  { flat = true } },
  { "fish",  fish,  cream, { flat = true } },
  { "footL", footL, dark,  { flat = true } },
  { "footR", footR, dark,  { flat = true } },
  { "fez",   fez,   hat,   { gloss = { 17, 5 } } },
})
c:ground(18, 33, 13, 1.5, "#52141c")

-- TEXTURE: tone-on-tone, hand placed, <=1 shade step from each base
-- plank wood grain: short dashes + one light fleck on the lit top
c:px(13, 30, "#8c4021"); c:px(14, 30, "#8c4021")
c:px(19, 31, "#8c4021"); c:px(20, 31, "#8c4021")
c:px(23, 28, "#8c4021")
c:px(12, 28, "#bca26b")
-- fez knit ribs
c:px(15, 5, "#c53f30"); c:px(15, 6, "#c53f30")
c:px(19, 6, "#9f2a2c"); c:px(19, 7, "#9f2a2c")
-- potato flecks on the body
c:px(10, 22, "#a56131"); c:px(14, 25, "#a56131")
c:px(25, 20, "#a56131"); c:px(23, 14, "#c67c49")

-- DETAIL: face + accents
-- eyes: 5x5 outlined cream discs, 2x2 pupils, 1px glint (upper-left of pupil)
local EYE = { ".AAA.", "AWWWA", "AWWPA", "AWPPA", ".AAA." }
local EG = { A = "#2b1c26", W = "#efe6a9", P = "#2b1c26" }
c:paint(EYE, 11, 14, EG)
c:paint(EYE, 21, 14, EG)
-- tiny smile: one glyph, ends at (15,19)/(19,19), bottom (16,20)/(17,20)/(18,20)
c:paint({ "m...m", ".mmm." }, 15, 19, { m = "#2b1c26" })
-- grey-lavender cheeks + belly band from the 64px pal
c:px(10, 15, "#644562"); c:px(26, 15, "#644562")
c:fill(c:rect(10, 22, 26, 23), "#644562")
-- lantern glass glow
c:px(5, 6, "#fff6c0"); c:px(5, 7, "#fff3c8"); c:px(6, 8, "#fff6c0")
-- fish: eye, fin, glint
c:px(32, 17, "#2b1c26")
c:px(29, 19, "#e2ac67"); c:px(29, 18, "#e2ac67")
c:px(29, 16, "#fff6c0")

local t = c:save(D .. "out/pl-chil-4-perch.aseprite", D .. "out/pl-chil-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1 and t.w == 36 and t.h == 36)

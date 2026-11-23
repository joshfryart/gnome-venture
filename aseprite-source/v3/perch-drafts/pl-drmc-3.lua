-- pl-drmc-3-perch.lua : phase 6 DETAIL (eyes, beak, wing fix, gloss accents)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-3-perch-20261120-175750/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0 }

local bodyRamp = GV.ramp("#d06847")
local hatRamp  = GV.ramp("#263796", { gloss = "#6f7aa9", rim = "#6f7aa9", bounce = "#23144e" })
local goldRamp = GV.R.gold
local footRamp = GV.ramp("#5d1528")
local woodRamp = GV.R.wood
local mossRamp = GV.R.moss
local wingCol  = GV.ramp("#af442b")

-- ground shadow ellipse under the perch (1px past each branch end)
c:ground(18, 30.5, 11, 1.8, GV.ramp("#9a6b3f").shade)

-- parts back to front
local p = c:build{
  { "branch", c:rrect(8, 26, 27, 29, 2), woodRamp, { cres = 2, deep = 2, gloss = false } },
  { "leaf1",  c:ellipse(10.5, 23, 2.4, 1.7),  mossRamp, { flat = true, gloss = false, contact = false } },
  { "leaf2",  c:ellipse(13, 21.5, 1.8, 1.3),  mossRamp, { flat = true, gloss = false, contact = false } },
  { "stem",   c:line({ { 12, 24.5 }, { 14, 25.5 } }, 1), GV.ramp(mossRamp.shade, { gloss = mossRamp.gloss }),
              { flat = true, gloss = false } },
  { "body",   c:ellipse(17.5, 21.5, 6.5, 4), bodyRamp, { cres = 2, deep = 2, gloss = false, stitch = false } },
  { "feetL",  c:ellipse(14.5, 25.6, 2, 1.1), footRamp, { flat = true, gloss = false, contact = true } },
  { "feetR",  c:ellipse(20.5, 25.6, 2, 1.1), footRamp, { flat = true, gloss = false, contact = true } },
  { "head",   c:ellipse(17.5, 12.5, 8, 6.5), bodyRamp, { cres = 2, deep = 2, gloss = { 12, 9 }, stitch = false } },
--
  { "collar", c:ellipse(17.5, 18.3, 4.2, 1.7), goldRamp, { flat = true, gloss = false, contact = false } },
  { "beret",  c:ellipse(17, 6.8, 7.5, 2.8), hatRamp, { cres = 2, deep = 1, gloss = { 12, 6 }, stitch = false } },
  { "brim",   c:ellipse(17, 9, 6.5, 1.2), { base = "#23144e", rim = "#4a375e", gloss = "#4a375e" },
              { flat = true, gloss = false, contact = false, contour = false, cres = 0, deep = 0, stitch = false } },
}

-- wing: tucked 1px inside the body's lower right (replaces phase-5 blob)
c:part(c:ellipse(20.3, 21.8, 1.8, 2.4):clip(p.body.m:shrink(1)), wingCol,
       { flat = true, gloss = false, contact = false, cres = 0, deep = 0, contour = false, stitch = false })

------------ TEXTURE ------------
c:px(13, 28, woodRamp.shade); c:px(14, 28, woodRamp.shade)
c:px(19, 28, woodRamp.shade); c:px(20, 28, woodRamp.shade); c:px(21, 28, woodRamp.bounce)
c:px(16, 28, woodRamp.deep)
c:px(24, 27, woodRamp.shade); c:px(25, 27, woodRamp.deep); c:px(24, 28, woodRamp.deep)
c:px(27, 26, woodRamp.gloss)
c:px(10, 23, mossRamp.shade); c:px(11, 23, mossRamp.shade); c:px(12, 24, mossRamp.shade); c:px(13, 22, mossRamp.shade)
c:px(16, 21, bodyRamp.shade); c:px(15, 23, bodyRamp.shade); c:px(19, 24, bodyRamp.shade)
c:px(23, 13, bodyRamp.base); c:px(22, 15, bodyRamp.base); c:px(24, 11, bodyRamp.base)
c:px(22, 8, hatRamp.base); c:px(21, 9, hatRamp.base)
c:stitch(p.beret.m, { side = "lit" })

------------ DETAIL: face, highlights ------------
-- locked big round eyes (head spans y6..19, face centre y13)
c:eye(12, 11)   -- x12..16
c:eye(19, 11)   -- x19..23
-- tiny gold beak between the eyes (2px wide, centred)
c:paint({ "gg", "hh" }, 16, 13, { g = "#f4d189", h = "#b5762f" })
-- collar: keep matte, no glint noise
-- beret dot
c:px(19, 7, hatRamp.rim)
-- feet glints (rim-lite tone on the lit top of each foot)
c:px(14, 25, "#7a3040"); c:px(21, 25, "#7a3040")

local t = c:save(D .. "out/pl-drmc-3-perch.aseprite", D .. "out/pl-drmc-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 2)

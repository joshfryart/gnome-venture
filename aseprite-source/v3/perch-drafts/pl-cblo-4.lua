-- pl-cblo-4-perch.lua : chibi perch of the acorn-lantern pal (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-4-perch-20261120-172136/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", margin = 3 }

-- ramps kept inside the pal's palette
local bodyR  = GV.ramp("#e58f61", { shade = "#da6540", deep = "#801631" })
local beretR = GV.ramp("#7dcc88", { shade = "#618661", deep = "#256f69" })
local bellyR = GV.ramp("#faeea5", { shade = "#f9c164", deep = "#da6540", dot = "#fff8e0" })
local footR  = GV.ramp("#6b4430")
local staffR = GV.ramp("#9a6a45", { shade = "#5b3a2c", deep = "#3d2a1c" })
local stumpR2 = GV.ramp("#c99a60", { shade = "#8a4f2a", deep = "#5e2f1e" }) -- borrowed wood family, lightened

local bob = c:ellipse(14.5, 16.5, 8, 9)                -- head+body ball x7..22, y7..25

local p = c:build{                                     -- back to front
  { "staff",   c:line({ { 25.5, 10.5 }, { 25.5, 26.5 } }, 2), staffR, { flat = true } },
  { "lantern", c:rrect(21, 6, 28, 12, 1), "gold", { gloss = { 23, 8 } } },
  { "stump",   c:rrect(9, 24, 21, 28, 2), stumpR2, { cres = 1, deep = 1 } },
  { "footL",   c:rrect(8, 25, 11, 27, 1), footR, { flat = true } },
  { "footR",   c:rrect(17, 25, 20, 27, 1), footR, { flat = true } },
  { "body",    bob, bodyR },
  { "belly",   c:ellipse(15, 20.5, 4.5, 4):clip(bob), bellyR, { cres = 2, gloss = { 13, 18 } } },
  { "beret",   c:ellipse(14.5, 9.5, 8.5, 4):cut(c:rect(0, 14, 35, 35)), beretR, { gloss = { 10, 8 } } },
}

-- face (drawn after parts so nothing repaints it)
c:eye(11, 16, true)                              -- 3x3 chibi eye, cream disc + dark pupil
c:eye(17, 16, true)
c:px(14, 21, "#801631"); c:px(15, 21, "#801631") -- tiny mouth

-- texture (hand-placed, subtle, tone-on-tone)
c:stitch(p.beret.m, { side = "lit" })            -- felt edge stitch on the beret's lit half
c:px(17, 15, "#dd712f"); c:px(16, 17, "#dd712f") -- 1px dither stepping into the body's terminator
c:px(13, 26, "#5e2f1e"); c:px(13, 27, "#5e2f1e") -- wood grain tick, lit half of the stump face
c:px(19, 26, "#5e2f1e"); c:px(19, 27, "#5e2f1e") -- second grain tick, on the shaded half
c:px(9, 17, "#f6aa5f"); c:px(8, 19, "#f6aa5f")   -- cheek freckles, bounce tone, on the lit half

local t = c:save(D .. "out/pl-cblo-4-perch.aseprite", D .. "out/pl-cblo-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

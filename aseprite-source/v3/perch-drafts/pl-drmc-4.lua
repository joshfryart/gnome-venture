-- pl-drmc-4-perch.lua : 36x36 chibi perch of the crowned green crab pal
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-4-perch-20261120-175759/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 2 }
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-4-perch-20261120-175759/"

-- ramps from the pal palette
local capR   = GV.ramp("#2b1c26")  -- dark plum head cap
local bodyR  = GV.ramp("#71a758")  -- bright green body
local clawR  = GV.ramp("#946366")  -- mauve-maroon claws
local bandR  = GV.ramp("#4065a9")  -- blue wrap (pal's mid blue)
local feetR  = GV.ramp("#273a92")  -- paws, deep blue of the pal
local perchR = GV.ramp("#1c412f")  -- dark green stone perch
local mossR  = GV.ramp("#467945")  -- moss cushion on perch
local goldR  = GV.ramp("#d8ce87")  -- crown gold

local MAT = { gloss = false }

-- back to front
local crown = c:part(c:ascii({
  ".d.dd.d.",
  ".dddddd.",
}, 12, 3), goldR, { flat = true, gloss = false, contact = false })

local body  = c:part(c:ellipse(16.5, 13.5, 10, 8.5), bodyR, { gloss = false })
local cap   = c:part(c:ellipse(16.5, 8.5, 9, 3.8) , capR)          -- auto violet gloss
c:gloss(body.m, bodyR, { 7, 13 })                                  -- body gloss on lit face, below cap

local band  = c:part(c:ellipse(16.5, 19.5, 7.5, 1.8), bandR, MAT)
local clawL = c:part(c:ellipse(6.2, 14.5, 2.0, 2.2), clawR, MAT)
local clawRr= c:part(c:ellipse(26.8, 14.5, 2.0, 2.2), clawR, MAT)

local paw   = c:part(c:rrect(9, 21, 24, 28, 2), perchR, MAT)
local moss  = c:part(c:ellipse(16.5, 21.5, 8, 2.0), mossR, MAT)
local footL = c:part(c:ellipse(11.5, 20.5, 1.7, 1.4), feetR, MAT)
local footRr= c:part(c:ellipse(21.5, 20.5, 1.7, 1.4), feetR, MAT)

-- tiny accent: fallen crown chip leaning on the perch's right edge
local acc   = c:part(c:ascii({
  ".d.",
  "ddd",
  ".d.",
}, 25, 25), goldR, { flat = true, gloss = false, contact = false })
c:px(26, 26, goldR.dot) -- glint

-- the pal's face: big round dark eyes with cream glints, tiny frown, pink cheeks
c:fill(c:rect(10, 13, 12, 15), "#2b1c26")
c:fill(c:rect(20, 13, 22, 15), "#2b1c26")
c:px(10, 15, "#71a758"); c:px(12, 15, "#71a758")      -- round the eye bottoms
c:px(20, 15, "#71a758"); c:px(22, 15, "#71a758")
c:px(10, 13, "#d8ce87"); c:px(20, 13, "#d8ce87")      -- eye glints
c:fill(c:rect(9, 16, 10, 16), "#946366")
c:fill(c:rect(23, 16, 24, 16), "#946366")             -- pink cheeks
c:px(16, 17, "#2b1c26"); c:px(17, 17, "#2b1c26")      -- tiny mouth

-- texture: pal's green spots, 1px dither on the terminators, claw glints, perch joints
c:px(7, 16, "#607f43"); c:px(15, 16, "#607f43"); c:px(24, 17, "#607f43")
c:px(24, 14, "#607f43"); c:px(22, 16, "#607f43")      -- dither toward shade
c:px(26, 16, "#71a758"); c:px(23, 18, "#71a758")      -- dither into shade
c:px(20, 9, "#7a505e"); c:px(21, 8, "#7a505e"); c:px(22, 10, "#2b1c26") -- cap terminator dither
c:px(6, 14, "#bc9396"); c:px(27, 14, "#bc9396")       -- claw glints
c:px(12, 24, "#153128"); c:px(19, 26, "#153128")      -- stone joints
c:px(10, 22, "#345c3a"); c:px(22, 21, "#345c3a")      -- moss flecks

-- detail: lift the body gloss up the lit shoulder face
c:px(8, 11, bodyR.gloss); c:px(8, 12, bodyR.gloss)

c:ground(16.5, 29.5, 12.5, 1.75)

local t = c:save(D .. "out/pl-drmc-4-perch.aseprite", D .. "out/pl-drmc-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)

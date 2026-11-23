-- pl-aurc-1-perch: chibi perch sprite (36x36) of the pink wizard pal
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-1-perch-20261120-163457/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1 }

local PINK  = GV.ramp("#d53987", { gloss = "#e170a8", rim = "#eba7b1", deep = "#81173a" })
local BODY  = GV.ramp("#e28740", { shade = "#b74b2e", deep = "#4a3040" })
local BOOT  = "soil"
local DARK  = "#2b1c26"

-- stump perch: top surface (rear arc dropped, it would sit behind the body) + wall
local stump = c:ellipse(15, 26, 8.5, 1.8)
stump:add(c:rect(7, 26, 23, 29))
stump:cut(c:rect(0, 0, 35, 25))
c:part(stump, "wood", { cres = 1, deep = 1, gloss = false, contact = false })

-- body: one big egg resting on the stump; auto contact shadow lands on the wood
c:part(c:ellipse(15, 19.5, 8, 6.8), BODY, { gloss = false })

-- boots flat on the stump surface
c:part(c:rrect(10, 24, 13, 26, 1), BOOT, { cres = 1, deep = 1, gloss = false, contour = false })
c:part(c:rrect(16, 24, 19, 26, 1), BOOT, { cres = 1, deep = 1, gloss = false, contour = false })

-- hat: cone behind, brim in front
c:part(c:poly({ {14, 3}, {22, 14.5}, {7, 14.5} }), PINK, { gloss = { 11, 8 }, cres = 1 })
c:part(c:ellipse(15, 14.5, 9, 2), PINK, { cres = 1 })

-- mini flag: pole planted beside the stump, base reaching the ground shadow
c:part(c:rrect(25, 16, 26, 30, 1), BOOT, { cres = 1, deep = 1, gloss = false })
c:part(c:poly({ {26, 17}, {31, 19.5}, {26, 22} }), PINK, { gloss = false, cres = 1 })

-- soft ground shadow
c:ground(15.5, 30.8, 10.5, 0.8, "#4a3040")

-- face: big round eyes, angry brows, tiny mouth, pink cheeks
c:eye(10, 17); c:eye(18, 17)
c:px(13, 15, DARK); c:px(14, 16, DARK)
c:px(16, 16, DARK); c:px(17, 15, DARK)
c:px(15, 23, DARK); c:px(16, 23, DARK)
c:px(9, 21, "#eba7b1"); c:px(10, 21, "#eba7b1")
c:px(20, 21, "#eba7b1"); c:px(21, 21, "#eba7b1")
-- yellow star accent on the hat
c:px(11, 8, "#ecad72"); c:px(12, 8, "#ecad72"); c:px(11, 7, "#ecad72")

-- texture: two wood grain dashes, tone-on-tone speckle on the hat cone with a
-- 1px dither step at its light/shade border
c:px(11, 28, "#d9a660"); c:px(19, 28, "#8a4f2a")
c:px(13, 10, "#b7276a"); c:px(15, 12, "#b7276a"); c:px(12, 6, "#b7276a")
c:px(16, 9, "#ecad72"); c:px(18, 12, "#e170a8")
-- detail accents: cream gloss on the brim's lit left, glint on the pennant
c:px(7, 14, "#eba7b1"); c:px(27, 18, "#eba7b1")

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-1-perch-20261120-163457/out/pl-aurc-1-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-1-perch-20261120-163457/out/pl-aurc-1-perch.png")
print(GV.report(t))

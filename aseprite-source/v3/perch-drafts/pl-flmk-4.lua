-- pl-flmk-4-perch.lua : perch sprite (36x36) for pal pl-flmk-4
local D  = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flmk-4-perch-20261120-184615/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0, cres = 2, deep = 1 }

local green = GV.ramp("#296a3e", { rim = "#abd7b9" })
local cream = GV.ramp("#f6e7bc")
local darkR = GV.ramp("#ad333e", { rim = "#db7a6d" })
local litR  = GV.ramp("#db7a6d")
local dark  = GV.ramp("#241a36", { rim = "#44345c" })
local brown = GV.ramp("#613e30")
local paleB = GV.ramp("#abd7b9")
local taupe = GV.ramp("#866869")

-- props behind, back to front
c:build{
  { "pole", c:rrect(27, 9, 28, 28, 0), taupe, { flat = true, contact = false } },
  { "flag", c:rrect(22, 5, 27, 7, 0),  paleB, { flat = true, contact = false } },
  { "log",  c:ellipse(16, 30, 11.5, 1), brown, { contact = false, cres = 1 } },
  { "moss", c:ellipse(16, 28.5, 11.5, 1), green, { cres = 1, deep = 0 } },
}
-- critter
c:build{
  { "body",  c:rrect(7, 19, 20, 27, 5),   green, {} },
  { "wingL", c:ellipse(7.5, 22, 2, 2),  paleB, { flat = true, contact = false } },
  { "wingR", c:ellipse(19.5, 22, 2, 2), paleB, { flat = true, contact = false } },
  { "chest", c:ellipse(13.5, 23, 4, 2.5), cream, { contour = false, contact = false, gloss = false } },
  { "head",  c:ellipse(13.5, 13, 8, 7), green, {} },
  { "mask",  c:ellipse(13.5, 16.5, 5.5, 2.5), dark, { gloss = false } },
}
-- face
c:eye(10, 15, true); c:eye(16, 15, true)
c:paint({ "uu" }, 13, 17, { u = "#f6e7bc" }) -- tiny mouth
-- hat over head
c:build{
  { "brim", c:rrect(4, 10, 23, 11, 1),  darkR, {} },
  { "dome", c:ellipse(13.5, 7, 7.5, 3), litR, {} },
}
-- feet onto moss
c:part(c:rrect(10, 27, 11, 28, 0), brown, { flat = true })
c:part(c:rrect(16, 27, 17, 28, 0), brown, { flat = true })

-- texture + detail (subtle, hand-placed)
-- moss tufts on the lit crest
c:px(5, 28, "#abd7b9"); c:px(8, 28, "#7fae74"); c:px(23, 28, "#abd7b9"); c:px(25, 28, "#7fae74")
-- log edge grain
c:px(5, 30, "#8a5a36"); c:px(26, 30, "#503427")
-- belly gloss + speckle diamonds from the pal
c:px(10, 20, "#fff3c8"); c:px(11, 20, "#fff3c8")
c:paint({ ".u.", "uvu" }, 10, 21, { u = "#b6ad88", v = "#ad333e" })
c:paint({ "uvu" }, 16, 23, { u = "#b6ad88", v = "#ad333e" })
-- dither at the crown light/shade border
c:px(18, 12, "#4a8a3e"); c:px(19, 13, "#4a8a3e")
-- wing feather notches
c:px(8, 22, "#8fc9b0"); c:px(20, 23, "#8fc9b0")
-- flag fold + pole lit top
c:px(23, 6, "#8fc9b0"); c:px(27, 9, "#a48551"); c:px(27, 10, "#b6ad88")
-- spark accents beside pole top
c:px(30, 7, "#f6e7bc"); c:px(31, 10, "#f6e7bc"); c:px(30, 13, "#f6e7bc")

c:ground(15.5, 31.5, 10, 1)
local t = c:save(D .. "out/pl-flmk-4-perch.aseprite", D .. "out/pl-flmk-4-perch.png")
print(GV.report(t))

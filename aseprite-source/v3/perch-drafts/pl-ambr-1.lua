-- pl-ambr-1-perch.lua  (phase: CRITIQUE)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-1-perch-20261120-161459/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1 }

local bodyR = GV.ramp("#528667", { gloss = "#91d17b", dot = "#c2e69e", rim = "#7cb96c" })
local goldR = GV.ramp("#cc8634")
local baseR = GV.ramp("#ab4c1f")
local mossR = GV.ramp("#91d17b")

-- TEXTURE: ramps done; hand-placed marks, dither at light/shade borders
local thin = { flat = true, contact = false, contour = false }

local rimM = c:rect(11, 24, 22, 26)
local potM = c:poly({ {11, 26}, {22, 26}, {21, 30}, {12, 30} })

local p = c:build{
  { "sproutL", c:line({ {11.5, 9}, {9.5, 6}, {9.5, 4.5} }, 2), goldR, thin },
  { "sproutC", c:line({ {16.5, 8}, {16.5, 5}, {17.5, 3} }, 2), goldR, thin },
  { "sproutR", c:line({ {21.5, 9}, {23.5, 6.5}, {23, 5} }, 2), goldR, thin },
  { "pot",   c:mask():add(rimM):add(potM), baseR, { contact = false, gloss = false } },
  { "coinL", c:ellipse(6, 29.5, 2.5, 1.8), goldR, thin },
  { "coinR", c:ellipse(27.5, 29.5, 2.5, 1.8), goldR, thin },
  { "body",  c:ellipse(17, 15, 10.25, 9.5), bodyR, { contact = false, contour = false, gloss = false } },
  { "tufts", c:mask():add(c:ellipse(11, 6.5, 1.5, 1)):add(c:ellipse(15, 5, 1.5, 1))
              :add(c:ellipse(21, 5.5, 1.5, 1)):add(c:ellipse(24.5, 8, 1.2, 1)), mossR, thin },
}

-- tone-on-tone moss specks on the body lit side (follow the curve)
c:px(10, 13, "#7cb96c"); c:px(13, 10, "#7cb96c")
c:px(20, 22, "#436e53"); c:px(14, 21, "#436e53")
-- 1px dither at the body light/shade border (terminator runs upper-right to lower-right)
c:px(24, 10, "#436e53"); c:px(25, 15, "#528667"); c:px(23, 19, "#436e53"); c:px(21, 23, "#528667")
-- pot: clay specks + lip wear
c:px(13, 27, "#8c4219"); c:px(22, 25, "#dca43b")

-- DETAIL: enamel gloss comma + dot on the body's lit upper-left
c:px(10, 8, bodyR.gloss); c:px(11, 8, bodyR.gloss); c:px(10, 9, bodyR.gloss)
c:px(12, 10, bodyR.dot)
-- gold sprout tips: 1px lit accent on the tip art
c:px(9, 4, goldR.dot); c:px(17, 3, goldR.dot); c:px(23, 4, goldR.dot)
-- coin glints
c:px(5, 28, goldR.dot); c:px(26, 28, goldR.dot)
-- tongue accent in the open mouth
c:px(17, 19, "#771014")

-- face (locked style, pal cream #f8e8c0)
local OL = "#2b1c26"
local EYE = { ".ooo.", "oGPPo", "oPPPo", "ooooo", ".ooo." }
c:paint(EYE, 11, 11, { o = "#f8e8c0", P = OL, G = "#f8e8c0" })
c:paint(EYE, 19, 11, { o = "#f8e8c0", P = OL, G = "#f8e8c0" })
-- open dark mouth
c:fill(c:mask():add(c:rect(16, 18, 18, 19)), "#431916")

c:ground(16.5, 30.5, 11, 1.5)

local t = c:save(D .. "out/pl-ambr-1-perch.aseprite", D .. "out/pl-ambr-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)

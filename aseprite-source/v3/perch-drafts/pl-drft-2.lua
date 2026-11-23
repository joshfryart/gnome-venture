-- pl-drft-2-perch.lua : 36x36 chibi perch for the sprout-bird pal
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-2-perch-20261120-173945/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- spec.md wants a 1 px dark selective outline from the palette (not the 2px brown default)
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#513a4e", "#2b1c26", "#2b1c26"
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0, cx = 18, cy = 16 }

-- palette ramps (spec palette only)
local greenL = { base = "#7fbf6b", gloss = "#c3dd9f", dot = "#c3dd9f", rim = "#c3dd9f", shade = "#589849", deep = "#377740", bounce = "#7aa97f" }
local greenM = { base = "#589849", gloss = "#7fbf6b", dot = "#7fbf6b", rim = "#7fbf6b", shade = "#377740", deep = "#205335", bounce = "#377740" }
local greenD = { base = "#377740", gloss = "#589849", dot = "#589849", rim = "#589849", shade = "#205335", deep = "#205335", bounce = "#205335" }
local purple = { base = "#565a72", gloss = "#565a72", dot = "#565a72", rim = "#565a72", shade = "#513a4e", deep = "#2b1c26", bounce = "#513a4e" }

-- shapes
local leafL = c:ellipse(13, 4.5, 3, 1.8)
local leafR = c:ellipse(20.8, 4.3, 3, 1.7)
local stem  = c:line({ { 16.8, 7.6 }, { 16.8, 4.2 } }, 2)
local head  = c:ellipse(18, 13.5, 7.5, 7)
local neck  = c:rrect(14, 19, 21, 24, 2)
local rim   = c:rrect(12, 23, 23, 26, 1)
local potB  = c:poly({ { 12, 27 }, { 23, 27 }, { 21, 29 }, { 14, 29 } })

-- parts, back to front
c:build{
  { "stem",  stem,  greenD, { flat = true, contact = false, contour = false } },
  { "leafL", leafL, greenM, { contact = false, contour = false, deep = 1 } },
  { "leafR", leafR, greenM, { contact = false, contour = false, deep = 1 } },
  { "neck",  neck,  greenM, { flat = true } },
  { "head",  head,  greenL },
  { "rim",   rim,   purple, { flat = true } },
  { "potB",  potB,  purple, { flat = true } },
  { "sprigS", c:line({ { 6, 28.3 }, { 5.6, 26.6 } }, 1), greenD, { flat = true, contact = false, contour = false } },
  { "sprigL", c:ellipse(4.8, 25.6, 1.6, 1):add(c:ellipse(6.9, 26, 1.2, 0.9)), greenM, { contact = false, contour = false, deep = 1 } },
}

-- hand shading + texture on the pot: 1px belly curve, lip seam, 2 speckles
c:paint({ "AAAAAA" }, 16, 29, { A = "#513a4e" })              -- 1px belly curve, lower edge
c:px(22, 26, "#513a4e"); c:px(22, 27, "#513a4e")              -- seam: rim/lip edge, lower right
c:px(15, 28, "#513a4e"); c:px(19, 28, "#513a4e"); c:px(21, 27, "#513a4e") -- speckles

-- leaf veins: 1px midrib, tone-on-tone
c:px(12, 4, "#377740"); c:px(13, 4, "#377740"); c:px(14, 5, "#377740")
c:px(21, 4, "#377740"); c:px(22, 5, "#377740")

-- dither: 1px transition steps at the head's light/shade border
c:px(15, 9, "#7fbf6b"); c:px(16, 9, "#7fbf6b"); c:px(14, 10, "#7fbf6b")
c:px(24, 15, "#589849"); c:px(23, 16, "#589849")

-- ground shadow
c:ground(17.5, 30.5, 7.5, 2, "#565a72")

-- face (flat tones in block-in; shading later)
for j = 0, 2 do
  for i = 0, 2 do
    c:px(13 + i, 11 + j, "#c3dd9f"); c:px(20 + i, 11 + j, "#c3dd9f")
    if j >= 1 and i >= 1 then c:px(13 + i, 11 + j, "#2b1c26"); c:px(20 + i, 11 + j, "#2b1c26") end
	c:px(14, 12, "#c3dd9f"); c:px(21, 12, "#c3dd9f") -- 1px pupil glint, upper-left
  end
end
c:paint({ ".XXXX.", "XXXXXX", "XXXXZX", ".XXXZ." }, 15, 15, { X = "#ef9f9f", Z = "#c46d72" })
c:px(16, 16, "#2b1c26"); c:px(19, 16, "#2b1c26")

local t = c:save(D .. "out/pl-drft-2-perch.aseprite", D .. "out/pl-drft-2-perch.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local olive = GV.ramp("#b0bc66")
local robe  = GV.ramp("#58a03e")

-- body (robe) bleeding off the bottom
local body = c:ellipse(39.5, 100, 33, 26):cut(c:rect(0, 0, 79, 73))
-- face + eye bumps form one head silhouette
local face = c:ellipse(39.5, 53, 28, 18)
local bumpL = c:ellipse(23, 39, 10, 9)
local bumpR = c:ellipse(56, 39, 10, 9)
local chin = c:ellipse(39.5, 61, 17, 8):clip(face)
local ringL = c:ellipse(23, 40, 6.5, 6)
local ringR = c:ellipse(56, 40, 6.5, 6)
-- hat: slightly crooked wizard cone + wide oval brim
local cone = c:poly({ {17, 33}, {46, 6}, {49, 6}, {64, 33} })
local brim = c:ellipse(39.5, 31, 33, 4.5)

local p = c:build{
  { "body",  body,  robe, { stitch = { side = "lit" } } },
  { "face",  face,  olive, { gloss = false } },
  { "bumpL", bumpL, olive, { gloss = false } },
  { "bumpR", bumpR, olive, { gloss = false } },
  { "chin",  chin,  "#f8eed2", { gloss = false, cres = 3, deep = 1 } },
  { "ringL", ringL, "#f8eed2", { gloss = false, cres = 2, deep = 1 } },
  { "ringR", ringR, "#f8eed2", { gloss = false, cres = 2, deep = 1 } },
  { "cone",  cone,  "wood" },
  { "brim",  brim,  GV.ramp("#8c4a1a") },
}

-- collar V and sash on the robe
c:fill(c:poly({ {30, 74}, {50, 74}, {40, 85} }):clip(body), "#2e5a2c")
c:fill(c:line({ {27, 79}, {33, 82}, {40, 85}, {47, 82}, {53, 79} }, 2):clip(body), "#c4925f")
c:fill(c:line({ {44, 86}, {47, 97} }, 2), "#a5663a")
c:button(38, 83)

-- hat band seam just above the brim
c:seam({ {19, 28}, {61, 28} })

-- warts
local wart = "#58a03e"
c:spot(c:ellipse(16, 52, 1.5, 1), wart, "#7ab55c")
c:spot(c:ellipse(63, 54, 1.5, 1), wart, "#7ab55c")
c:spot(c:ellipse(39.5, 46, 1, 1), wart, "#7ab55c")
c:spot(c:ellipse(22, 61, 1, 1), wart, "#7ab55c")
c:spot(c:ellipse(58, 62, 1, 1), wart, "#7ab55c")

-- locked eyes, set wide
c:eye(21, 38); c:eye(54, 38)

-- nostrils
c:px(36, 51, "#4a2c1a"); c:px(43, 51, "#4a2c1a")

-- wide 2px smile
c:fill(c:line({ {24, 58}, {29, 62}, {35, 64}, {44, 64}, {50, 62}, {55, 58} }, 2), "#4a2c1a")

local t = c:save(O .. "aseprite/ph/npc-sakuya-brushwick.aseprite", O .. "png/ph/npc-sakuya-brushwick.png")
print(GV.report(t))

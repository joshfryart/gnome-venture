local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local O = D .. "img-redraw-full/"

local stone = GV.ramp("#968f96")
local rimR  = GV.ramp("#7a7084")
local broth = GV.ramp("#e46a9b")

-- bowl body: half-round below the rim, flat foot
local body = c:ellipse(31.5, 26, 21, 21):cut(c:rect(0, 0, 63, 25))
body:add(c:rect(11, 24, 52, 28))
body:cut(c:rect(0, 46, 63, 63))
local foot = c:rrect(22, 44, 41, 49, 2)
local lugs = c:rrect(6, 21, 12, 25, 1):add(c:rrect(51, 21, 57, 25, 1))
local rim = c:ellipse(31.5, 23, 21, 6)
local surf = c:ellipse(31.5, 23, 17.5, 4)

local p = c:build{
  { "foot", foot, stone },
  { "lugs", lugs, rimR, { gloss = false } },
  { "body", body, stone, { gloss = { 18, 30 } } },
  { "rim",  rim,  rimR, { gloss = false } },
  { "broth", surf, broth, { gloss = { 22, 21 } } },
}
-- floaters
c:part(c:ellipse(26, 23, 2, 1.5), GV.ramp("#c8302a"), { flat = true })
c:part(c:ellipse(37.5, 23, 2, 1.5), "moss", { flat = true })
c:px(25, 22, "#ff9158"); c:px(37, 22, "#c8d77a")
c:part(c:rect(31, 21, 33, 22), GV.ramp("#f08a24"), { flat = true })

c:ground(31.5, 52, 15, 1.5)
local t = c:save(O .. "aseprite/ph/garden-vegetable-soup.aseprite", O .. "png/ph/garden-vegetable-soup.png")
print(GV.report(t))

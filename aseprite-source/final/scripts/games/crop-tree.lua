local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pear: narrow rounded neck, big round belly
local body = c:ellipse(30.5, 43, 19, 12.5)
body:add(c:ellipse(30.5, 23, 8.5, 9))
body:add(c:poly({ {23, 23}, {39, 23}, {48, 37}, {13, 37} }))
body = body:closed(3)

local stem = c:line({ {30, 15}, {31, 11}, {33, 9}, {35, 8} }, 3)
local leaf = c:poly({ {36, 16}, {39, 10}, {45, 7}, {53, 7}, {50, 13}, {43, 17} })

c:build{
  { "stem", stem, "#6b4a26", { flat = true } },
  { "leaf", leaf, "moss", { gloss = false } },
  { "body", body, GV.ramp("#b8c93a"), { cres = 5, gloss = { 18, 33 } } },
}
-- leaf vein
c:paint({ "....vv", "..vv..", "vv...." }, 40, 10, { v = "#2f5a2a" })
-- freckles
c:px(25, 46, "#7d6a1a"); c:px(34, 50, "#7d6a1a"); c:px(40, 43, "#7d6a1a"); c:px(29, 39, "#7d6a1a")
c:ground(30.5, 56, 16, 1.5)
local t = c:save(O .. "aseprite/games/crop-tree.aseprite", O .. "png/games/crop-tree.png")
print(GV.report(t))

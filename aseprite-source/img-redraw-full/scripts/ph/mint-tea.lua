local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = c:ellipse(32, 28, 18, 22):cut(c:rect(0, 0, 63, 27)):add(c:ellipse(32, 28, 18, 4))
local handle = c:ellipse(14, 37, 6, 6.5):cut(c:ellipse(14, 37, 3, 3.5)):cut(c:rect(17, 0, 63, 63))
local leaf1 = c:poly({ {19, 10}, {24, 14}, {27, 21}, {27, 28}, {22, 24}, {18, 17} })
local leaf2 = c:poly({ {40, 7}, {41, 13}, {38, 21}, {34, 28}, {32, 21}, {35, 13} })
local p = c:build{
  { "saucer", c:ellipse(32, 51, 24, 5), GV.ramp("#8fcbd8") },
  { "handle", handle, GV.ramp("#8fcbd8") },
  { "leaf1",  leaf1, "moss", { gloss = false } },
  { "leaf2",  leaf2, "moss", { gloss = false } },
  { "bowl",   bowl, GV.ramp("#c8ecdc") },
  { "tea",    c:ellipse(32, 28, 15.5, 3), "moss", { gloss = false, contact = false } },
}
c:fill(c:line({ {20, 13}, {25, 22} }, 1):clip(leaf1), "#4a8a3e")
c:fill(c:line({ {39, 10}, {35, 23} }, 1):clip(leaf2), "#4a8a3e")
c:px(21, 12, "#c8d77a"); c:px(37, 11, "#c8d77a"); c:px(38, 10, "#c8d77a")
-- steam wisp
c:part(c:line({ {47, 21}, {45, 18}, {47, 15}, {49, 12}, {47, 9} }, 2), GV.ramp("#f1ece0"), { flat = true })
local t = c:save(O .. "aseprite/ph/mint-tea.aseprite", O .. "png/ph/mint-tea.png")
print(GV.report(t))

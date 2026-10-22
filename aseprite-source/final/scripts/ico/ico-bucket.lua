local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local handle = c:line({ {16, 31}, {17, 24}, {21, 18}, {27, 14}, {32, 13}, {37, 14}, {43, 18}, {47, 24}, {48, 31} }, 4)
local body = c:poly({ {15, 31}, {50, 31}, {45, 58}, {19, 58} })
local rim = c:rrect(12, 26, 52, 34, 2)
local hoop = c:rect(0, 45, 63, 48):clip(body)
local p = c:build{
  { "handle", handle, GV.ramp("#c4925f") },
  { "body",   body,   GV.ramp("#8c4a1a"), { light = body:copy():add(rim) } },
  { "hoop",   hoop,   GV.ramp("#b07a45"), { gloss = false } },
  { "rim",    rim,    GV.ramp("#c4925f") },
}
for x = 14, 50 do c:px(x, 27, "#f0d49a") end
c:fill(c:rect(26, 36, 27, 43), "#5e2f1e"); c:fill(c:rect(26, 50, 27, 55), "#5e2f1e")
c:fill(c:rect(37, 36, 38, 43), "#5e2f1e"); c:fill(c:rect(37, 50, 38, 55), "#5e2f1e")
c:seam({ {18, 46}, {47, 46} })
c:ground(32, 58, 13, 1)
local t = c:save(O .. "aseprite/ico/ico-bucket.aseprite", O .. "png/ico/ico-bucket.png")
print(GV.report(t))

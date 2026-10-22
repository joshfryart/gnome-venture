local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local handles = c:rrect(7, 27, 13, 32, 2):add(c:rrect(50, 27, 56, 32, 2))
local body = c:ellipse(31.5, 30, 20, 22):cut(c:rect(0, 0, 63, 29))
body:add(c:rect(12, 26, 51, 30))
local rim = c:ellipse(31.5, 25, 21, 7)
local soup = c:ellipse(31.5, 25, 18, 4.5)
local p = c:build{
  { "handles", handles, "#5b6470" },
  { "body", body, "#8b8f96", { gloss = { 17, 36 } } },
  { "rim", rim, "#6a6070", { gloss = false } },
  { "soup", soup, "moss", { cres = 2, deep = 1, gloss = { 19, 22 } } },
}
c:fill(c:ellipse(25, 24, 2, 1.5), "#4a8a3e")
c:fill(c:ellipse(37.5, 23.5, 2, 1.5), "#a4b86a"); c:px(37, 23, "#c8d77a")
c:fill(c:ellipse(31, 27, 1.5, 1), "#4a8a3e")
c:fill(c:ellipse(43, 26, 1.5, 1), "#4a8a3e")
c:px(29, 23, "#a4b86a"); c:px(41, 23, "#4a8a3e")
c:part(c:line({ {27,17}, {25,14}, {27,11}, {26,8} }, 2), "#f1ece0", { flat = true })
c:part(c:line({ {36,16}, {38,13}, {36,10}, {37,6} }, 2), "#f1ece0", { flat = true })
c:seam({ {14, 34}, {20, 37}, {31, 38}, {43, 37}, {49, 34} })
c:ground(31.5, 53, 16, 1.5)
local t = c:save(O .. "aseprite/ph/green-pea-soup.aseprite", O .. "png/ph/green-pea-soup.png")
print(GV.report(t))

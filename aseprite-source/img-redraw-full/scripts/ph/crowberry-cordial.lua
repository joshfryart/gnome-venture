local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#d6c9b6", { shade = "#8b8f96" })       -- stone family, pale
local cord  = GV.ramp("#4e3a8a", { gloss = "#a894dc", deep = "#2a1a10" })
local body = c:ellipse(29.5, 40, 15, 12.5):add(c:rrect(20, 23, 39, 34, 2))
local fill = body:copy():clip(c:rect(0, 23, 63, 31):add(c:ellipse(29.5, 30, 10, 3.5)))
local p = c:build{
  { "handle", c:line({ {38, 27}, {46, 27}, {50, 31}, {50, 37}, {46, 42}, {42, 43} }, 3), glass, { gloss = false } },
  { "body",   body, glass, { gloss = false } },
  { "cord",   fill, cord, { contact = false, gloss = { 22, 26 } } },
  { "rim",    c:rrect(19, 20, 40, 23, 1):add(c:poly({ {14, 18}, {20, 20}, {20, 24}, {17, 23} })), "#968f96", { flat = true } },
}
-- glass streak gloss and dot
c:fill(c:rect(21, 37, 22, 46):add(c:rect(20, 38, 20, 44)), "#fff3c8")
c:px(24, 35, "#ffffff")
c:ground(30, 53, 15, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/crowberry-cordial.aseprite", D .. "img-redraw-full/png/ph/crowberry-cordial.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local nut = c:ellipse(31.5, 35, 14, 16)
local cap = nut:copy():clip(c:ellipse(31.5, 17, 19, 12))
local stem = c:line({{31,20},{31,15},{33,12}}, 3)
c:build{
  { "nut", nut, GV.ramp("#dcb06a") },
  { "cap", cap, GV.ramp("#8a4f2a"), { light = nut, gloss = {24, 23} } },
  { "stem", stem, "moss", { flat = true } },
}

c:paint({
  "gg........gg",
  ".gg......gg.",
  "..gg....gg..",
  "...gggggg...",
}, 26, 41, { g = "#5e2f1e" })
c:px(24, 22, "umber"); c:px(37, 21, "umber"); c:px(28, 25, "umber"); c:px(35, 25, "umber")
local t = c:save(O .. "aseprite/ph/kola.aseprite", O .. "png/ph/kola.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 36, 17, 15.5)
local stem = c:rect(31, 15, 33, 22)
local leaf = c:poly({ {33,20}, {36,15}, {42,11}, {48,10}, {46,15}, {41,19}, {35,21} })
c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "body", body, GV.ramp("#f08a24", { gloss = "#ffc27a" }), { gloss = { 23, 28 } } },
  { "leaf", leaf, "#58a03e" },
}
-- navel dimple around the stem
c:fill(c:ellipse(31.5, 22, 4, 1.5):cut(stem), "#b8452f")
c:px(31, 23, "#8a3a2a"); c:px(32, 23, "#8a3a2a"); c:px(33, 23, "#8a3a2a")
-- leaf midrib
c:paint({ "....m", "..m..", ".m...", "m...." }, 36, 13, { m = "#3e7a2e" })
c:px(41, 13, "#3e7a2e"); c:px(42, 12, "#3e7a2e")
-- peel pores
for _, p in ipairs({ {37,29}, {42,36}, {27,41}, {35,44}, {20,36}, {40,46} }) do c:px(p[1], p[2], "#b8452f") end
local t = c:save(O .. "aseprite/ph/mandarin.aseprite", O .. "png/ph/mandarin.png")
print(GV.report(t))

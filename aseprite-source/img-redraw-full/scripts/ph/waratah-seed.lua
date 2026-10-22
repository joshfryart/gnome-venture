local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(12, 15, 51, 56, 2)
local flap = c:poly({ {12, 15}, {52, 15}, {32, 35} })
local win = c:rrect(17, 36, 46, 54, 5)
local bud = c:ellipse(31.5, 46, 8, 7.5)
local p = c:build{
  { "body", body, GV.ramp("#f1ece0"), { gloss = { 15, 50 } } },
  { "flap", flap, GV.ramp("#f6b8cf"), { gloss = { 20, 18 } } },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false, rim = false, bounce = false } },
}
-- pink ring round the label window (inside the umber contour)
local ring = win:copy():shrink(1)
local inner = ring:copy():shrink(2)
c:fill(ring:copy():cut(inner), "#e46a9b")
c:part(bud, GV.ramp("#e46a9b", { shade = "#a8241f" }), { gloss = { 27, 41 } })
-- waratah bud texture: small bracts in rows
c:paint({
  "..b...b..",
  "b...b...b",
  "..b...b..",
  "b...b...b",
}, 28, 44, { b = "#b8452f" })
-- leaf and stem off the top right of the bud
c:fill(c:rect(38, 40, 39, 42), "#2e5a2c")
local leaf = c:poly({ {38, 41}, {41, 38}, {45, 37}, {43, 40}, {39, 42} })
c:fill(leaf, "#58a03e"); c:px(41, 39, "#8ac862"); c:px(42, 39, "#8ac862")
-- gold sticker sealing the flap point
c:part(c:ellipse(32, 32, 3.5, 3.5), "gold", { gloss = { 30, 30 } })
c:seam({ {13, 16}, {32, 35}, {51, 16} })
local t = c:save(O .. "aseprite/ph/waratah-seed.aseprite", O .. "png/ph/waratah-seed.png")
print(GV.report(t))

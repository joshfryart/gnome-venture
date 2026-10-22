local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f1ece0")
local body = c:poly({ {13, 13}, {52, 13}, {52, 57}, {13, 57} })
local flap = c:poly({ {13, 13}, {52, 13}, {52, 21}, {13, 21} })
local tab = c:poly({ {46, 7}, {52, 17}, {40, 17} })
local label = c:rrect(18, 25, 46, 50, 5)
local lime = c:ellipse(32, 38, 7, 7)

c:build{
  { "tab", tab, GV.ramp("#2e7a3a"), { gloss = false } },
  { "body", body, paper },
  { "flap", flap, GV.ramp("#dcb06a"), { gloss = { 15, 15 } } },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
  { "lime", lime, "moss" },
}
-- label border
c:fill(label:edge(), "#7ab55c")
-- fold line
c:fill(c:rect(13, 19, 51, 20), GV.ramp("#dcb06a").shade)
c:seam({ {15, 21}, {49, 21} })
-- stem + leaf
c:fill(c:rect(31, 28, 32, 31), "#2e5a2c")
c:part(c:ellipse(36, 28.5, 3, 1.5), GV.ramp("#58a03e"), { flat = true })
-- lime pores
c:px(34, 41, "#4a8a3e"); c:px(30, 42, "#4a8a3e"); c:px(36, 37, "#4a8a3e")
-- seed dots
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x, 53, x + 1, 54), "#8c4a1a") end

local t = c:save(O .. "aseprite/ph/lime-seed.aseprite", O .. "png/ph/lime-seed.png")
print(GV.report(t))

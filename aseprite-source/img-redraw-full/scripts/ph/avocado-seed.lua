local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- squat, rounded ceramic pot (belly wider than the neck)
local pot = c:ellipse(31.5, 38, 19, 17):cut(c:rect(0, 0, 63, 21))
pot:add(c:rrect(15, 21, 48, 30, 2))
pot:cut(c:rect(0, 54, 63, 63))
local lid = c:rrect(12, 14, 51, 21, 3)
local knob = c:rrect(28, 9, 35, 14, 2)
local leaf = c:poly({ {46, 4}, {52, 12}, {49, 17}, {42, 17}, {42, 12} })
local stemL = c:line({ {41, 15}, {44, 11} }, 2)
local label = c:rrect(20, 26, 43, 50, 6)
local avo = c:ellipse(31.5, 38.5, 7, 8)
avo:add(c:ellipse(31.5, 33, 5, 5))

local p = c:build{
  { "leafstem", stemL, "moss", { flat = true } },
  { "leaf",  leaf,  GV.ramp("#4a8a3e") },
  { "pot",   pot,   GV.ramp("#f1ece0") },
  { "knob",  knob,  GV.ramp("#f4f0e0") },
  { "lid",   lid,   GV.ramp("#f4f0e0") },
  { "label", label, GV.ramp("#2e5a2c"), { gloss = false } },
  { "avo",   avo,   GV.ramp("#58a03e") },
}
-- pale label window inside the green border
c:fill(c:rrect(22, 28, 41, 48, 5):cut(avo:grow(1)), "#f4f0e0")
-- avocado pit
c:spot(c:ellipse(32.5, 40.5, 3, 3), "#8c4a1a", "#c47a52")
-- foot dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 51, x + 2, 52), "#8c4a1a") end

c:seam({ {15, 21}, {48, 21} })
c:button(30, 15)
c:ground(31.5, 55, 15, 1.5)

local t = c:save(O .. "aseprite/ph/avocado-seed.aseprite", O .. "png/ph/avocado-seed.png")
print(GV.report(t))

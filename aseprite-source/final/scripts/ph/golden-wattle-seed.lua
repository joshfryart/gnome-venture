local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local belly = c:ellipse(31.5, 40, 19, 15)
local neck = c:rect(23, 22, 40, 28)
local lid = c:ellipse(31.5, 24, 13, 10):cut(c:rect(0, 25, 63, 63))
local knob = c:ellipse(31.5, 11, 3.5, 3)
local foot = c:rrect(21, 52, 42, 57, 2)
local label = c:rrect(21, 31, 42, 48, 5)

local p = c:build{
  { "foot", foot, GV.ramp("#b07a45") },
  { "belly", belly, GV.ramp("#f1ece0") },
  { "neck", neck, GV.ramp("#e8d8b0") },
  { "knob", knob, GV.ramp("#b07a45") },
  { "lid", lid, GV.ramp("#d9a660") },
  { "label", label, GV.ramp("#f08a24"), { gloss = false } },
  { "labelin", c:rrect(23, 33, 40, 46, 4), GV.ramp("#f4f0e0"), { gloss = false, contact = false, rim = false } },
  { "seed", c:ellipse(31.5, 40.5, 5.5, 5.5), GV.ramp("#f08a24", { shade = "#e0501f" }), { gloss = { 29, 37 } } },
}
c:part(c:ascii({ ".gg.", "gggg", ".gg." }, 34, 32), GV.ramp("#58a03e"), { flat = true })
c:seam({ {20, 24}, {43, 24} })
c:button(30, 16)
local t = c:save(O .. "aseprite/ph/golden-wattle-seed.aseprite", O .. "png/ph/golden-wattle-seed.png")
print(GV.report(t))

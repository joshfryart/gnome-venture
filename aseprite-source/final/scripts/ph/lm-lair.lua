local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local rock = GV.ramp("#7a7282")
local mound = c:ellipse(31.5, 53, 23, 32):cut(c:rect(-20, 54, 83, 99))
-- crest: jagged spikes riding the mound top
local crest = c:poly({ {13,30}, {15,19}, {19,25}, {23,13}, {27,21}, {32,9}, {37,21}, {41,13}, {45,25}, {49,19}, {51,30}, {44,24}, {32,20}, {20,24} })
local mouth = c:ellipse(32, 44, 15, 12):cut(c:rect(-20, 54, 83, 99))
local fangL = c:poly({ {7,54}, {11,44}, {15,54} })
local fangR = c:poly({ {48,54}, {52,44}, {56,54} })
local bone = GV.ramp("#f4f0e0")
local p = c:build{
  { "mound", mound, rock, { gloss = { 16, 34 } } },
  { "crest", crest, GV.ramp("#c42a22") },
  { "fangL", fangL, bone, { gloss = false } },
  { "fangR", fangR, bone, { gloss = false } },
}
c:fill(mouth, "#2a1a10")
c:fill(mouth:copy():cut(mouth:shift(0, 1)), "#4a2c1a")
-- rocky cracks on the mound
c:paint({ "r..", ".r.", ".rr" }, 13, 38, { r = rock.shade })
c:paint({ ".r", "r.", "r." }, 49, 36, { r = rock.shade })
-- glowing eyes
local e1 = c:ellipse(25, 41, 3, 2.2); local e2 = c:ellipse(39, 41, 3, 2.2)
c:fill(e1, "#e0501f"); c:fill(e2, "#e0501f")
c:fill(c:rect(24, 40, 25, 41), "#f5cf6a"); c:fill(c:rect(38, 40, 39, 41), "#f5cf6a")
-- teeth on the mouth floor
for _, x in ipairs({ 21, 29, 37 }) do
  local tt = c:poly({ {x,54}, {x + 3,47}, {x + 7,54} })
  c:fill(tt, "#f4f0e0")
  c:fill(c:line({ {x + 4,49}, {x + 5,53} }, 1):clip(tt), "#c9c5bc")
end
c:ground(32, 55, 22, 1.5)
local t = c:save(O .. "aseprite/ph/lm-lair.aseprite", O .. "png/ph/lm-lair.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local grey  = GV.ramp("#a38f80")
local tailR = GV.ramp("#8f7060")
local legR  = GV.ramp("#4a3a34")
local legs = c:rect(25, 46, 26, 56):add(c:rect(33, 46, 34, 56))
legs:add(c:rect(22, 55, 28, 56)):add(c:rect(31, 55, 37, 56))
local tail = c:poly({ {19, 43}, {5, 36}, {7, 34}, {21, 37} })
local body = c:ellipse(28.5, 41, 13, 7)
local belly = c:ellipse(29, 44, 8, 4):clip(body)
local neck = c:line({ {32, 37}, {36, 31}, {36, 24}, {32, 17} }, 6)
local head = c:ellipse(29.5, 11.5, 7, 6)
local beak = c:poly({ {35, 9}, {53, 13}, {53, 14}, {35, 17} })
local crest = c:poly({ {24, 6}, {11, 5}, {11, 7}, {23, 11} })
local p = c:build{
  { "legs",  legs,  legR,  { flat = true } },
  { "tail",  tail,  tailR },
  { "body",  body,  grey },
  { "belly", belly, GV.ramp("#e6d2ae"), { gloss = false } },
  { "neck",  neck,  grey },
  { "crest", crest, "dusk", { flat = true } },
  { "head",  head,  grey },
  { "beak",  beak,  "gold", { gloss = false } },
}
c:px(36, 13, GV.C.ol2)
c:eye(27, 8, true)
c:ground(30, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-grey-heron.aseprite", O .. "png/ph/creature-grey-heron.png")
print(GV.report(t))

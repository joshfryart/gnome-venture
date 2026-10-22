local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f1ece0")
-- pod peeking out of the top, tilted
local pod = c:line({ {31, 18}, {40, 9} }, 5):add(c:ellipse(40.5, 9, 3, 3))
local top = c:poly({ {16, 14}, {44, 14}, {39, 30}, {25, 30} })
for _, x in ipairs({ 20, 26, 32, 38 }) do top:cut(c:poly({ {x, 13}, {x + 4, 13}, {x + 2, 17} })) end
local bot = c:poly({ {26, 40}, {38, 40}, {47, 57}, {17, 57} })
local p = c:build{
  { "pod", pod, "petal", { gloss = { 36, 10 } } },
  { "bot", bot, cloth, { stitch = { side = "lit" } } },
  { "top", top, cloth, { stitch = { side = "lit" } } },
  { "waist", c:rrect(24, 27, 40, 43, 4), "petal" },
  { "string", c:rect(21, 34, 43, 35), GV.ramp("#8c4a1a"), { flat = true } },
  { "bow", c:ellipse(46, 32.5, 3, 2.5):cut(c:rect(45, 32, 46, 33)), GV.ramp("#8c4a1a"), { flat = true } },
}
-- green cap on pod tip
c:fill(c:ellipse(42, 7.5, 2, 2), "#2e5a2c"); c:px(41, 6, "#4a8a3e")
-- bow tails
c:fill(c:line({ {44, 36}, {46, 39} }, 2), "#8c4a1a")
-- cloth folds
c:fill(c:line({ {29, 29}, {23, 18} }, 1), "#dcb06a")
c:fill(c:line({ {36, 29}, {39, 19} }, 1), "#dcb06a")
c:fill(c:line({ {29, 44}, {24, 54} }, 1), "#dcb06a")
c:fill(c:line({ {35, 44}, {41, 54} }, 1), "#dcb06a")
c:ground(32, 58, 14, 1.5)
local t = c:save(O .. "aseprite/ph/cardamom-seed.aseprite", O .. "png/ph/cardamom-seed.png")
print(GV.report(t))

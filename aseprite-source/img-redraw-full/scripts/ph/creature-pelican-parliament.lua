local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = GV.ramp("#f8eed2")
local wing = GV.ramp("#a38f80")
local bill = GV.ramp("#f5cf6a")
local function pouch(x0, y0, h)
  local m = c:poly({ {x0, y0}, {x0 + 8, y0}, {x0 + 6, y0 + h}, {x0 + 2, y0 + h} })
  m:add(c:ellipse(x0 + 3.5, y0 + h - 2, 2.5, 2.5))
  return m
end
-- back-left bird (lower), back-right bird (higher), front bird (biggest)
local b1 = c:ellipse(18.5, 27, 8.5, 9)
local b2 = c:ellipse(45, 21, 8.5, 9)
local b3 = c:ellipse(31.5, 40, 10.5, 11)
c:build{
  { "legL1", c:rect(15, 34, 16, 38), bill, { flat = true } },
  { "legL2", c:rect(21, 34, 22, 38), bill, { flat = true } },
  { "legR1", c:rect(42, 28, 43, 34), bill, { flat = true } },
  { "legR2", c:rect(48, 28, 49, 34), bill, { flat = true } },
  { "b1", b1, body, { cres = 2, deep = 1 } },
  { "w1a", c:ellipse(11, 29, 2, 4.5):clip(b1:grow(1)), wing },
  { "w1b", c:ellipse(26, 29, 2, 4.5):clip(b1:grow(1)), wing },
  { "k1", pouch(15, 23, 9), bill, { gloss = false } },
  { "b2", b2, body, { cres = 2, deep = 1 } },
  { "w2a", c:ellipse(37.5, 23, 2, 4.5):clip(b2:grow(1)), wing },
  { "w2b", c:ellipse(52.5, 23, 2, 4.5):clip(b2:grow(1)), wing },
  { "k2", pouch(41, 17, 8), bill, { gloss = false } },
  { "footA", c:rect(27, 49, 28, 54), bill, { flat = true } },
  { "footB", c:rect(35, 49, 36, 54), bill, { flat = true } },
  { "b3", b3, body, { cres = 3, deep = 1 } },
  { "w3a", c:ellipse(22, 42, 2.5, 5.5):clip(b3:grow(1)), wing },
  { "w3b", c:ellipse(41, 42, 2.5, 5.5):clip(b3:grow(1)), wing },
  { "k3", pouch(27.5, 35, 11), bill, { gloss = false } },
}
-- ridge down each bill

for _, p in ipairs({ {19,24},{19,25},{19,26},{19,27},{19,28},{19,29},{45,18},{45,19},{45,20},{45,21},{45,22},{31,36},{31,37},{31,38},{31,39},{31,40},{31,41},{31,42},{31,43} }) do c:px(p[1], p[2], "#e8a317") end
c:eye(14, 19, true); c:eye(21, 19, true)
c:eye(40, 13, true); c:eye(47, 13, true)
c:eye(26, 31, true); c:eye(34, 31, true)
c:ground(31.5, 55, 20, 1.5)
local t = c:save(O .. "aseprite/ph/creature-pelican-parliament.aseprite", O .. "png/ph/creature-pelican-parliament.png")
print(GV.report(t))

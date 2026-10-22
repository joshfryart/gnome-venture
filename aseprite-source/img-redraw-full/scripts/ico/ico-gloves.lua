local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local gold = GV.ramp("#e0a73a")

local thumb = c:line({ {22,43}, {15,34} }, 7)
local f1 = c:rrect(21, 16, 29, 36, 3)
local f2 = c:rrect(29, 11, 37, 36, 3)
local f3 = c:rrect(37, 12, 45, 36, 3)
local f4 = c:rrect(45, 19, 53, 36, 3)
local palm = c:rrect(21, 31, 53, 50, 6)
local cuff = c:rrect(20, 48, 54, 56, 2)

local p = c:build{
  { "thumb", thumb, gold },
  { "f1", f1, gold, { gloss = false } },
  { "f2", f2, gold, { gloss = false } },
  { "f3", f3, gold, { gloss = false } },
  { "f4", f4, gold, { gloss = false } },
  { "palm", palm, gold, { stitch = { side = "lit" } } },
  { "cuff", cuff, "#58a03e", { gloss = false } },
}
-- finger glosses
for _, x in ipairs({ 24, 32, 40, 48 }) do
  c:px(x, ({ [24]=18, [32]=13, [40]=14, [48]=21 })[x], gold.gloss)
  c:px(x, ({ [24]=19, [32]=14, [40]=15, [48]=22 })[x], gold.gloss)
end
-- creases
for _, x in ipairs({ 23, 31, 39, 47 }) do c:fill(c:rect(x, 25, x+3, 25), "#b8661a") end
-- knit ribs on cuff
for x = 23, 51, 4 do c:fill(c:rect(x, 51, x, 54), "#4a8a3e") end
c:seam({ {23,48}, {51,48} }, { free = true })

local t = c:save(O .. "aseprite/ico/ico-gloves.aseprite", O .. "png/ico/ico-gloves.png")
print(GV.report(t))

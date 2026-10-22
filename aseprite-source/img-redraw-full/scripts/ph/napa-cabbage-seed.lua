local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped bell belly, widest low
local belly = c:ellipse(31.5, 44, 20, 12):add(c:poly({ { 22, 26 }, { 42, 26 }, { 48, 38 }, { 15, 38 } }))
belly:add(c:rrect(14, 36, 49, 52, 6))
-- puffed frill top: flared scallops
local frill = c:poly({ { 25, 20 }, { 39, 20 }, { 37, 27 }, { 27, 27 } })
frill:add(c:ellipse(22.5, 17, 4, 3.5)):add(c:ellipse(29, 15, 4, 3.5)):add(c:ellipse(35, 15, 4, 3.5)):add(c:ellipse(41.5, 17, 4, 3.5))
frill:add(c:rect(21, 17, 43, 21))
local leaf = c:ellipse(31.5, 43, 8, 9):add(c:poly({ { 24, 41 }, { 39, 41 }, { 32, 29 }, { 31, 29 } }))
local p = c:build{
  { "belly", belly, "cream", { stitch = true } },
  { "frill", frill, "cream", { gloss = { 23, 15 } } },
  { "trim", leaf:grow(1), "#f08a24", { flat = true } },
  { "leaf", leaf, "moss", { gloss = { 27, 38 } } },
}
-- frill folds
for _, x in ipairs({ 26, 32, 38 }) do
  for y = 19, 24 do c:px(x, y, "#dcb06a") end
end
-- leaf veins
for y = 32, 50 do c:px(31, y, "#2f5a2a"); c:px(32, y, "#2f5a2a") end
c:paint({ "v...", ".v..", "..v." }, 27, 37, { v = "#2f5a2a" })
c:paint({ "...v", "..v.", ".v.." }, 33, 37, { v = "#2f5a2a" })
c:paint({ "v...", ".v..", "..v." }, 27, 43, { v = "#2f5a2a" })
c:paint({ "...v", "..v.", ".v.." }, 33, 43, { v = "#2f5a2a" })
-- drawstring band cinching the neck, with loops
local str = c:line({ { 22, 26 }, { 42, 26 } }, 2)
str:add(c:line({ { 24, 27 }, { 19, 30 }, { 18, 34 } }, 2))
str:add(c:line({ { 40, 27 }, { 45, 30 }, { 46, 34 } }, 2))
c:fill(str, "#f08a24")
c:fill(c:line({ { 22, 26 }, { 42, 26 } }, 1), "#f8a85a")
c:button(30, 24)
local t = c:save(B .. "aseprite/ph/napa-cabbage-seed.aseprite", B .. "png/ph/napa-cabbage-seed.png")
print(GV.report(t))

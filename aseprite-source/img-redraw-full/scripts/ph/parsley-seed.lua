local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pouch body: round bottom, narrowing to the neck
local body = c:ellipse(31.5, 39, 18, 15)
body:add(c:poly({ {22, 24}, {42, 24}, {48, 34}, {16, 34} }))
-- frilled ruffle above the cinch, scalloped top
local ruffle = c:poly({ {23, 24}, {40, 24}, {45, 13}, {18, 13} })
for _, x in ipairs({ 20, 25, 30, 35, 40 }) do ruffle:add(c:ellipse(x + 1.5, 13, 2.5, 2)) end
local band = c:rrect(19, 23, 44, 26, 1)
local leaf = c:poly({ {32, 30}, {38, 35}, {39, 41}, {36, 47}, {32, 50}, {28, 47}, {25, 41}, {26, 35} })

local p = c:build{
  { "body",   body,   "#f1ece0", { stitch = { side = "lit" } } },
  { "ruffle", ruffle, "#dcb06a" },
  { "leaf",   leaf,   GV.ramp("#58a03e") },
  { "band",   band,   "gold", { flat = true } },
}
-- cord tails hanging from the knot
c:part(c:line({ {29, 26}, {23, 37} }, 2), "gold", { flat = true })
c:part(c:line({ {34, 26}, {40, 37} }, 2), "gold", { flat = true })
c:part(c:rect(21, 36, 23, 39), "gold", { flat = true })
c:part(c:rect(40, 36, 42, 39), "gold", { flat = true })
-- ruffle pleats
for _, x in ipairs({ 24, 29, 34, 39 }) do for y = 15, 21 do c:px(x + (x < 31 and (y > 18 and 1 or 0) or (y > 18 and -1 or 0)), y, "#b8853f") end end
-- leaf veins
local v = "#2f5a2a"
for y = 33, 47 do c:px(32, y, v) end
c:px(31, 37, v); c:px(30, 36, v); c:px(33, 37, v); c:px(34, 36, v)
c:px(31, 41, v); c:px(30, 40, v); c:px(29, 39, v); c:px(33, 41, v); c:px(34, 40, v); c:px(35, 39, v)
c:px(31, 45, v); c:px(30, 44, v); c:px(33, 45, v); c:px(34, 44, v)
c:ground(31.5, 54, 14, 1.5)
local t = c:save(O .. "aseprite/ph/parsley-seed.aseprite", O .. "png/ph/parsley-seed.png")
print(GV.report(t))

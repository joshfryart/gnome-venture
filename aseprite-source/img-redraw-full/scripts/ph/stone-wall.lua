local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood = GV.ramp("#8c4a1a", { shade = "#8a4f2a" })
local tan  = GV.ramp("#c4925f", { rim = "#f0d49a" })

local p = c:build{
  { "post1", c:rrect(11, 14, 17, 55, 3), wood },
  { "post2", c:rrect(29, 12, 35, 55, 3), wood },
  { "post3", c:rrect(47, 14, 53, 55, 3), wood },
  { "upper", c:rrect(7, 21, 57, 29, 3), tan },
  { "lower", c:rrect(7, 37, 57, 45, 3), tan },
}

-- wood grain on posts (between slabs)
for _, x in ipairs({ 14, 32, 50 }) do
  c:px(x, 32, "#5e2f1e"); c:px(x, 33, "#5e2f1e")
  c:px(x - 1, 49, "#5e2f1e"); c:px(x - 1, 50, "#5e2f1e")
end
-- post tops: peg nail
c:px(14, 17, "#5e2f1e"); c:px(32, 15, "#5e2f1e"); c:px(50, 17, "#5e2f1e")

-- stone cracks: split slabs into separate stones
local ck = "#8a4f2a"
for y = 23, 27 do c:px(22, y, ck); c:px(42, y, ck) end
for y = 39, 43 do c:px(25, y, ck); c:px(45, y, ck) end
c:px(23, 23, ck); c:px(43, 23, ck); c:px(26, 39, ck); c:px(46, 39, ck)

c:ground(32, 57, 24, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/stone-wall.aseprite",
                 D .. "img-redraw-full/png/ph/stone-wall.png")
print(GV.report(t))

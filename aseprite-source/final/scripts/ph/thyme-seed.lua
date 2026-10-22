local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- lumpy burlap sack body
local body = c:ellipse(32, 41, 18, 11)
body:add(c:ellipse(20, 45, 7, 7))
body:add(c:ellipse(44, 45, 7, 7))
body:add(c:ellipse(32, 47, 12, 6))
body:add(c:rrect(22, 28, 42, 36, 3))
-- flared floppy top with a ruffled rim
local top = c:poly({ {24, 27}, {40, 27}, {47, 16}, {17, 16} })
top:add(c:ellipse(20, 16, 3.5, 2.5)); top:add(c:ellipse(28, 15, 3.5, 2.5))
top:add(c:ellipse(36, 15, 3.5, 2.5)); top:add(c:ellipse(44, 16, 3.5, 2.5))
top:cut(c:rect(24, 12, 24, 14)); top:cut(c:rect(32, 12, 32, 13)); top:cut(c:rect(40, 12, 40, 14))

local burlap = GV.ramp("#c9a96e")
local twine = GV.ramp("#a8582f")
local herb = GV.ramp("#a4b86a")
local p = c:build{
  { "body", body, burlap, { stitch = true } },
  { "top", top, burlap },
  { "twine", c:rrect(22, 26, 42, 29, 1), twine },
  { "knot", c:rrect(29, 25, 34, 30, 2), twine },
}
c:part(c:line({ {30, 30}, {27, 35} }, 2), twine, { flat = true })
c:part(c:line({ {34, 30}, {37, 35} }, 2), twine, { flat = true })
-- herb sprig emblem
c:part(c:line({ {32, 40}, {32, 50} }, 2), "#6a9a3a", { flat = true })
c:part(c:poly({ {25, 41}, {28, 37}, {32, 39}, {30, 43}, {26, 43} }), herb, { gloss = false })
c:part(c:poly({ {39, 41}, {36, 37}, {32, 39}, {34, 43}, {38, 43} }):shift(1, 0), herb, { gloss = false })
c:part(c:ellipse(32.5, 36, 2.5, 3), herb, { gloss = false })
-- burlap weave flecks
c:paint({ "w...w", "..w..", "w...w" }, 17, 44, { w = burlap.shade })
c:paint({ "w...w", "..w.." }, 41, 46, { w = burlap.shade })
c:seam({ {48, 38}, {48, 50} })

local t = c:save(O .. "aseprite/ph/thyme-seed.aseprite", O .. "png/ph/thyme-seed.png")
print(GV.report(t))

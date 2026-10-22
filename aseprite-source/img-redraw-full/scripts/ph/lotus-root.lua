local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- inverted bell body: flat top, slight shoulder, taper to a point
local body = c:poly({ { 23, 21 }, { 42, 21 }, { 43, 27 }, { 42, 35 }, { 39, 44 }, { 35, 52 }, { 33, 57 }, { 32, 57 }, { 30, 52 }, { 26, 44 }, { 23, 35 }, { 22, 27 } })
body:add(c:rrect(23, 19, 42, 24, 2))

local leafL = c:poly({ { 31, 21 }, { 28, 17 }, { 25, 12 }, { 24, 6 }, { 27, 8 }, { 30, 12 }, { 33, 18 }, { 33, 21 } })
local leafR = c:poly({ { 32, 21 }, { 32, 18 }, { 35, 12 }, { 38, 8 }, { 41, 6 }, { 40, 12 }, { 37, 17 }, { 34, 21 } })

local p = c:build{
  { "leafL", leafL, "moss" },
  { "leafR", leafR, GV.ramp("#58a03e") },
  { "root", body, GV.ramp("#f6b8cf"), { gloss = { 27, 27 } } },
}
-- cut-top band
c:fill(c:rect(23, 19, 42, 20):clip(p.root.m), "#b8452f")
c:fill(c:rect(25, 19, 40, 19):clip(p.root.m), "#ae2a2a")
-- air-channel holes (dark beans)
local H = "#4a2c1a"
local function hole(x, y)
  c:paint({ ".hh.", "hhhh", "hhhh", ".hh." }, x, y, { h = H })
  c:px(x + 1, y, "#2a1a10"); c:px(x + 2, y, "#2a1a10")
end
c:paint({ ".hh.", "hhhh", ".hh." }, 25, 29, { h = H })
hole(33, 28)
hole(28, 37)
hole(36, 37)
c:paint({ ".h.", "hhh", "hhh", ".h." }, 31, 46, { h = H })
local t = c:save(O .. "aseprite/ph/lotus-root.aseprite", O .. "png/ph/lotus-root.png")
print(GV.report(t))

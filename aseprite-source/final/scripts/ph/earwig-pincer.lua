local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sickle claw: convex edge on the right, concave on the left, tip at top
local claw = c:poly({
  {30, 7}, {33, 13}, {36, 21}, {38, 30}, {37, 40}, {34, 48}, {30, 53},
  {14, 53}, {15, 45}, {19, 36}, {24, 27}, {28, 18}, {29, 11},
})
local cap = c:rrect(12, 50, 31, 57, 2)
local ridge = c:line({ {21, 48}, {25, 38}, {29, 28}, {31, 20} }, 3):clip(claw:shrink(2))

local p = c:build{
  { "claw", claw, GV.ramp("#dcb06a") },
  { "ridge", ridge, "cream", { flat = true, contour = false, contact = false } },
  { "cap", cap, "wood" },
}
c:seam({ {14, 53}, {30, 53} })
-- segment notches on the outer edge
c:paint({ "nn" }, 35, 22, { n = "#2a1a10" })
c:paint({ "nn" }, 36, 32, { n = "#2a1a10" })
c:paint({ "nn" }, 35, 42, { n = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/earwig-pincer.aseprite", O .. "png/ph/earwig-pincer.png")
print(GV.report(t))

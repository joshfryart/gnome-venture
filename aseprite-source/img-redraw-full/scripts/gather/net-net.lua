local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local hx, hy = 29.5, 27.5
local handle = c:line({ {41, 40}, {48, 47} }, 5)
local mesh = c:ellipse(hx, hy, 12)
local hoop = c:ellipse(hx, hy, 15.5):cut(c:ellipse(hx, hy, 11.5))
local ferrule = c:rrect(38, 37, 42, 41, 1)
local p = c:build{
  { "handle", handle, "wood" },
  { "mesh", mesh, GV.ramp("#e8f6ff"), { flat = true } },
  { "hoop", hoop, "moss", { stitch = { side = "lit" } } },
  { "ferrule", ferrule, GV.ramp("#7a3a14"), { flat = true } },
}
local grid = c:mask()
for _, x in ipairs({23, 29, 35}) do grid:add(c:rect(x, 10, x, 45)) end
for _, y in ipairs({21, 27, 33}) do grid:add(c:rect(10, y, 50, y)) end
grid:clip(c:ellipse(hx, hy, 11.5))
c:fill(grid, "#a9d6ea")
c:seam({ {44, 43}, {46, 45} })
local t = c:save(O .. "aseprite/gather/net-net.aseprite", O .. "png/gather/net-net.png")
print(GV.report(t))

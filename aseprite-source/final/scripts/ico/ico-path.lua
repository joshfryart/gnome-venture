local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tile = c:rrect(12, 10, 52, 51, 9)
local pts = { {23, 53}, {23, 46}, {26, 42}, {33, 41}, {39, 39}, {40, 34}, {37, 30}, {30, 26}, {28, 21}, {29, 15}, {30, 9} }
local path = c:line(pts, 8):clip(tile:grow(1))
c:build{
  { "tile", tile, "#58a03e", { stitch = { side = "lit" } } },
  { "path", path, GV.ramp("#dcb06a", { shade = "#b07a45" }), { cres = 2, deep = 1, gloss = false, contact = false } },
}
c:seam({ {23, 49}, {24, 44}, {28, 42}, {34, 41}, {38, 38}, {38, 34}, {35, 31}, {30, 27}, {29, 22}, {29, 17}, {30, 12} }, { on = 1, off = 3, free = true, gap = nil })
c:paint({ ".g.", "ggg" }, 15, 17, { g = "#4a8a3e" })
c:paint({ "g.g", "ggg" }, 45, 44, { g = "#4a8a3e" })
local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-path.aseprite", D .. "img-redraw-full/png/ico/ico-path.png")
print(GV.report(t))

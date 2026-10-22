local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 31, 12, 11)
local bumps = { {19,19,6}, {30,16,6}, {41,18,6}, {46,28,6}, {44,39,6}, {35,46,6}, {24,45,6}, {17,37,6}, {18,27,5} }
for _, b in ipairs(bumps) do body:add(c:ellipse(b[1], b[2], b[3], b[3])) end
local ember = GV.ramp("#f08a24", { shade = "#d6322b" })
c:build{ { "fluff", body, ember, { stitch = { side = "lit" } } } }
local curl = "#e0501f"
c:fill(c:line({ {33,24}, {37,23}, {40,25}, {40,28}, {37,29} }, 2), curl)
c:fill(c:line({ {22,33}, {22,37}, {25,39}, {28,38} }, 2), curl)
c:fill(c:line({ {35,38}, {38,36}, {41,37}, {42,40} }, 2), curl)
local t = c:save(O .. "aseprite/ph/lemming-fluff.aseprite", O .. "png/ph/lemming-fluff.png")
print(GV.report(t))

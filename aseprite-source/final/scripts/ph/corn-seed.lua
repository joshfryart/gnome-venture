local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cob = c:ellipse(31.5, 17, 5, 9)
local leafL = c:poly({ {23, 27}, {29, 27}, {27, 20}, {19, 10}, {22, 19} })
local leafR = c:poly({ {35, 27}, {41, 27}, {43, 19}, {45, 10}, {37, 20} })
local sack = c:ellipse(31.5, 45, 21, 12)
sack:add(c:poly({ {22, 27}, {42, 27}, {50, 38}, {13, 38} }))
local flare = c:ellipse(31.5, 25, 12, 3.5)
local band = c:rect(21, 29, 42, 30)
local loops = c:ellipse(26, 30, 3.5, 2.5):add(c:ellipse(37, 30, 3.5, 2.5))
loops:add(c:line({ {29, 31}, {25, 37} }, 2)):add(c:line({ {34, 31}, {38, 37} }, 2))
local knot = c:rrect(29, 28, 34, 32, 1)
local label = c:rrect(20, 38, 43, 52, 4)

local p = c:build{
  { "cob",   cob,   GV.ramp("#f5cf6a") },
  { "leafL", leafL, GV.ramp("#58a03e"), { gloss = false } },
  { "leafR", leafR, GV.ramp("#58a03e"), { gloss = false } },
  { "sack",  sack,  GV.ramp("#c9a96e"), { stitch = { side = "lit" } } },
  { "flare", flare, GV.ramp("#b0894e"), { gloss = false } },
  { "band",  band,  GV.ramp("#8a4f2a"), { flat = true } },
  { "loops", loops, GV.ramp("#8a4f2a"), { flat = true } },
  { "knot",  knot,  GV.ramp("#8a4f2a"), { flat = true } },
  { "label", label, GV.ramp("#f4f0e0") },
}
-- cob kernel rows
for y = 10, 21, 2 do c:px(29, y, "#e8a317"); c:px(34, y, "#e8a317") end
for y = 11, 21, 2 do c:px(31, y, "#e8a317") end
-- twine loop holes
c:px(26, 30, "#5e2f1e"); c:px(37, 30, "#5e2f1e")
-- label ring and kernel dots
c:stitch(label, {})
c:paint({ ".kk.", "kkkk", "kkkk", "kkkk", ".kk.", "g..g", ".gg." }, 30, 41, { k = "#e8a317", g = "#58a03e" })
c:paint({ "kk", "kk" }, 25, 45, { k = "#e8a317" })
c:paint({ "kk", "kk" }, 37, 45, { k = "#e8a317" })
-- burlap crosshatch diamonds
local dia = { ".d.", "d.d", ".d." }
c:paint(dia, 15, 41, { d = "#a88a55" })
c:paint(dia, 20, 52, { d = "#a88a55" })
c:paint(dia, 45, 45, { d = "#a88a55" })
c:seam({ {48, 37}, {49, 52} })

local t = c:save(O .. "aseprite/ph/corn-seed.aseprite", O .. "png/ph/corn-seed.png")
print(GV.report(t))

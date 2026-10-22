local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

-- wheel ring with chipped notch at upper right
local ring = c:ellipse(17, 47, 10):cut(c:ellipse(17, 47, 6))
ring:cut(c:rect(23, 38, 28, 41))
local spokes = c:line({ {12, 47}, {22, 47} }, 2)
spokes:add(c:line({ {17, 42}, {17, 52} }, 2))
spokes:clip(c:ellipse(17, 47, 6))
local hub = c:ellipse(17.5, 47.5, 2)

local upper = c:line({ {44, 14}, {36, 28} }, 5)
local lower = c:line({ {30, 36}, {22, 48} }, 5)
local head = c:poly({ {36, 7}, {57, 7}, {54, 19}, {39, 19} })
local socket = c:rrect(40, 15, 48, 21, 2)
local spoke = c:rrect(44, 47, 51, 49, 1)

local p = c:build{
  { "spokes", spokes, "wood", { flat = true } },
  { "ring",   ring,   GV.ramp("#d9a660") },
  { "hub",    hub,    GV.ramp("#5e2f1e"), { flat = true } },
  { "lower",  lower,  GV.ramp("#b6814d") },
  { "upper",  upper,  GV.ramp("#b6814d") },
  { "socket", socket, "gold" },
  { "head",   head,   "gold" },
  { "spoke",  spoke,  "wood", { flat = true } },
}
-- splinter crack on the upper shaft end and lower shaft end
c:paint({ "k.", ".k", "k.", ".k" }, 36, 24, { k = "#2a1a10" })
c:paint({ ".k", "k.", ".k" }, 29, 36, { k = "#2a1a10" })
-- crack across the blade
c:paint({ "k..", ".k.", ".kk", "..k" }, 47, 8, { k = "#7a3a14" })
-- wheel rim seam
c:seam({ {10, 42}, {13, 39}, {18, 38} })
local t = c:save(O .. "aseprite/ph/broken-masterwork-wheel-hoe.aseprite", O .. "png/ph/broken-masterwork-wheel-hoe.png")
print(GV.report(t))

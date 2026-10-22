local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood = GV.ramp("#b6814d", { gloss = "#f0d49a" })
local cx, cy, R = 40, 22, 14

-- handle: lower stub snapped at a jagged end, upper part reaching the hoop
local handleLo = c:line({ {11,56}, {21,45} }, 5)
handleLo:add(c:poly({ {19,43}, {24,44}, {22,47}, {25,48}, {22,50} }))
local handleHi = c:line({ {25,40}, {31,34} }, 5)
handleHi:add(c:poly({ {22,41}, {25,38}, {27,42} }))

-- mesh disc with a jagged tear gap on its left side
local mesh = c:ellipse(cx, cy, R - 1, R - 1)
local tear = c:poly({ {27,11}, {34,18}, {31,23}, {37,28}, {33,35}, {26,35}, {28,28}, {24,22}, {28,17}, {24,11} })
mesh:cut(tear)
-- hoop ring with a crack gap at upper-left
local ring = c:ellipse(cx, cy, R + 1, R + 1):cut(c:ellipse(cx, cy, R - 2, R - 2))
ring:cut(c:poly({ {27,9}, {31,7}, {33,11}, {30,13} }))

local p = c:build{
  { "lo", handleLo, wood },
  { "hi", handleHi, wood },
  { "mesh", mesh, GV.ramp("#a9d6ea"), { gloss = { 45, 13 }, contact = false } },
  { "ring", ring, "wood", { gloss = { 34, 10 } } },
}
-- mesh threads (stop at the tear)
local threads = c:line({ {26,22}, {54,22} }, 1):add(c:line({ {40,8}, {40,36} }, 1))
threads:add(c:line({ {30,15}, {50,15} }, 1)):add(c:line({ {29,29}, {51,29} }, 1))
threads:add(c:line({ {33,10}, {33,34} }, 1)):add(c:line({ {47,10}, {47,34} }, 1))
threads:clip(mesh:shrink(1))
c:fill(threads, "#5a86b8")
-- ragged dark tear edge on the mesh side
c:fill(tear:grow(1):clip(mesh):cut(mesh:shrink(1):cut(tear:grow(1))):clip(mesh), "#2f6290")

-- loose shard and chip
c:part(c:poly({ {44,45}, {48,44}, {52,49}, {49,51} }), wood, { gloss = false })
c:part(c:poly({ {37,49}, {40,48}, {42,51}, {39,52} }), wood, { flat = true })
c:ground(30, 57, 16, 1.5)

local t = c:save(O .. "aseprite/ph/broken-bug-net.aseprite", O .. "png/ph/broken-bug-net.png")
print(GV.report(t))

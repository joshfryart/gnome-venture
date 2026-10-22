local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cx, cy = 40.5, 22.5
local disc = c:ellipse(cx, cy, 15, 15)
local inner = c:ellipse(cx, cy, 11, 11)
local ring = disc:copy(); ring:cut(inner)

local handle = c:line({ {10, 55}, {30, 35} }, 5)
-- drooping mesh bag hanging below the hoop
local bag = c:poly({ {32, 30}, {54, 26}, {56, 38}, {54, 47}, {49, 52}, {44, 50}, {38, 40} })
bag:add(c:ellipse(50, 47, 5, 5))
bag:cut(disc)
local p = c:build{
  { "bag", bag, GV.ramp("#bfe0ee"), { gloss = false } },
  { "handle", handle, "wood" },
  { "net", inner:copy(), GV.ramp("#a9d6ea"), { flat = true } },
  { "ring", ring, "stone" },
}
-- mesh wires clipped to the inner disc
local wires = c:mask()
for x = 31, 50, 4 do wires:add(c:rect(x, 10, x, 36)) end
for y = 13, 32, 4 do wires:add(c:rect(26, y, 56, y)) end
wires:clip(inner:shrink(1))
c:fill(wires, "#7f9cb0")
local bw = c:mask()
for k = 0, 40, 4 do bw:add(c:line({ {30 + k, 56}, {50 + k, 24} }, 1)) end
bw:clip(bag:shrink(1))
c:fill(bw, "#8fb4c8")
-- collar wrap where handle meets ring
local collar = c:line({ {28, 37}, {32, 33} }, 6):clip(handle:grow(1))
c:part(collar, "gold", { gloss = false })
c:seam({ {27, 34}, {31, 38} }, { free = true })
-- ring gloss
c:gloss(ring, GV.R.stone, { 31, 13 })

local t = c:save(D .. "img-redraw-full/aseprite/ph/fine-mesh-net.aseprite",
                 D .. "img-redraw-full/png/ph/fine-mesh-net.png")
print(GV.report(t))

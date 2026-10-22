local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- fat rounded stalk tilted ~35 deg up to the right
local stalk = c:line({ {16, 44}, {46, 24} }, 14)
local stalkR = GV.ramp("#dcb06a", { shade = "#b07a45" })

-- cut end face at the lower left
local cut = c:ellipse(12.5, 46, 5, 6)

-- leafy cap at upper right: a block plus two leaf blades
local cap = c:ellipse(49, 21, 7, 7)
local leaves = c:poly({ {44,17}, {47,7}, {52,16} })
leaves:add(c:poly({ {51,17}, {57,9}, {56,21} }))

local p = c:build{
  { "leaves", leaves, "moss", { gloss = false } },
  { "stalk",  stalk,  stalkR, { gloss = { 18, 37 }, light = stalk } },
  { "cut",    cut,    GV.ramp("#f0d49a"), { gloss = false } },
  { "cap",    cap,    GV.ramp("#2f5a2a"), { gloss = { 45, 17 } } },
}

-- node rings: crosswise bands perpendicular to the stalk
local function node(x, y)
  local ring = c:line({ {x - 4, y - 6}, {x + 4, y + 6} }, 2):clip(p.stalk.m:shrink(1))
  c:fill(ring, "#b07a45")
  c:fill(ring:shift(-1, -1):cut(ring):clip(p.stalk.m:shrink(1)), "#f0d49a")
end
node(25, 38); node(34, 32); node(42, 27)

-- cut end rings
c:fill(c:ellipse(12.5, 46, 2, 2.5), "#dcb06a")

local t = c:save(O .. "aseprite/ph/sugarcane.aseprite", O .. "png/ph/sugarcane.png")
print(GV.report(t))

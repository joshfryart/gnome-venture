-- cellar-key: a small old iron key lying on the diagonal, trefoil bow, still warm
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- trefoil bow (upper left): a ring with three round lobes, open eye in the middle
local bow = c:ellipse(19, 19, 8, 8)
bow:add(c:ellipse(12.5, 12.5, 5, 5))
bow:add(c:ellipse(25.5, 12.5, 4.5, 4.5))
bow:add(c:ellipse(12.5, 25.5, 4.5, 4.5))
bow:cut(c:ellipse(18.5, 18.5, 3.5, 3.5))

-- shaft on the diagonal, a darker collar ring, square bit off the far end
local shaft = c:line({ {25, 25}, {48, 48} }, 5)
local collar = c:line({ {24, 32}, {32, 24} }, 3)
local bit = c:poly({ {40, 40}, {50, 50}, {43, 57}, {33, 47} })
bit:cut(c:poly({ {36, 50}, {40, 54}, {42, 52}, {38, 48} }))  -- the ward notch
local whole = bow:copy():add(shaft):add(bit):add(collar)

local iron = GV.ramp("#8b8f96")
local p = c:build{
  { "bit",    bit,    iron, { light = whole, gloss = false } },
  { "shaft",  shaft,  iron, { light = whole, gloss = { 30, 28 } } },
  { "collar", collar, GV.ramp("#5b6470"), { light = whole, gloss = false } },
  { "bow",    bow,    iron, { light = whole, gloss = { 11, 12 } } },
}

-- still warm: a few ember pixels on the lower rim of the bow eye and on the bit
c:paint({ "..o", ".oe", "oe." }, 21, 21, { o = "#f08a24", e = "#e0501f" })
c:paint({ ".o", "oe" }, 44, 50, { o = "#f08a24", e = "#e0501f" })

local t = c:save(D .. "final/aseprite/ph/cellar-key.aseprite", PNG .. "cellar-key.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

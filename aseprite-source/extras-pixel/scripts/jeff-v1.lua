-- Jeff v1: bright-green jigsaw piece, waving with the right arm. 64x64 Stitched Toy sticker.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/jeff/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- body: square slab, knob up, notch at the bottom
local body = c:rrect(17, 24, 46, 51, 4)
body:add(c:rrect(27, 15, 36, 27, 2)); body:add(c:ellipse(31.5, 13, 8, 6.5))
body:cut(c:ellipse(31.5, 53, 6, 4.5))                              -- bottom notch

-- left arm: flat tab out to the side; right arm: raised, waving
local armL = c:rrect(11, 32, 19, 39, 2); armL:add(c:ellipse(11, 35.5, 3, 4.5))
armL:cut(c:rect(18, 24, 63, 63))
local armR = c:line({ {44, 36}, {49, 29}, {51, 23} }, 4)
armR:add(c:ellipse(52, 20, 4, 4))                              -- open hand
armR:cut(body:grow(1))

c:build{
  { "armL", armL, GV.ramp("#2cc97c"), { flat = true } },
  { "armR", armR, GV.ramp("#2cc97c"), { flat = true } },
  { "body", body, GV.ramp("#1fb86b"), { stitch = { side = "lit" } } },
}
c:button(30, 16)                                                   -- pin at the knob neck
c:seam({ {21, 46}, {25, 46} }); c:seam({ {38, 46}, {42, 46} })     -- hem either side of the notch

-- face: big round eyes set wide at the shoulders, wide smile on the body
c:eye(21, 27); c:eye(36, 27)
c:paint({ "u.........u", ".u.......u.", "..uuuuuuu.." }, 26, 37, { u = "umber" })

-- wave sparkle: three gold ticks beside the hand
c:paint({ "g.", "..", ".g" }, 56, 11, { g = "#f5cf6a" }); c:px(58, 16, "#f5cf6a")

local t = c:save(OUT .. "jeff-v1.aseprite", OUT .. "jeff-v1.png")
print("jeff-v1", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

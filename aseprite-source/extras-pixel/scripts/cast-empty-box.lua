-- Empty state: Jeff peeking out of an empty puzzle box (lid tipped back), one hand on the rim.
-- Scene 120x80 drawn at half size, written at 2x -> 240x160. Transparent background, no halo.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local ASE, PNG = D .. "extras-pixel/cast/", "/home/user/gnome-venture/game/assets/img/puzzles/cast/"

local W, H = 120, 80
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }

-- box: cardboard (soil #c9a96e family), front face + inner back wall; lid open behind, leaning left
local backIn  = c:rrect(26, 32, 93, 46, 2)                              -- inside back wall (dark)
local lid     = c:poly({ {22, 10}, {90, 6}, {94, 30}, {26, 34} })        -- lid tipped back
local front   = c:rrect(24, 44, 95, 74, 3)                               -- box front
local rim     = c:rrect(22, 42, 97, 47, 2)                               -- front rim lip

-- Jeff rising from the box: knob, head and shoulders; notch hidden
local bx, by = 59, 0                                                     -- body centre x, offset
local body = c:poly({ {bx-15, 24}, {bx+14, 22}, {bx+15, 50}, {bx-13, 50} })
body:add(c:rrect(bx-5, 13, bx+4, 26, 2)); body:add(c:ellipse(bx-0.5, 11, 7.5, 6))
local armR = c:line({ {bx+13, 34}, {bx+21, 37}, {bx+25, 40} }, 4); armR:add(c:ellipse(bx+28, 43, 3.5, 3))
armR:cut(body:grow(1))

c:build{
  { "lid",    lid,    GV.ramp("#c9a96e"), { gloss = false } },
  { "backIn", backIn, GV.ramp("#7a4a1f"), { gloss = false, rim = false } },
}
c:seam({ {28, 31}, {90, 29} }); c:button(56, 14)                       -- lid seam, before Jeff covers it
c:build{
  { "body",   body,   GV.ramp("#1fb86b"), { stitch = { side = "lit" } } },
  { "front",  front,  GV.ramp("#c9a96e"), { stitch = { side = "lit" } } },
  { "rim",    rim,    GV.ramp("#9a6b3f"), { flat = true } },
  { "armR",   armR,   GV.ramp("#2cc97c"), { flat = true } },
}
-- fingers over the rim
c:paint({ "u.u.u" }, bx+26, 44, { u = "umber" })
-- box label: a cream patch with a little purple puzzle-piece mark and the word "0"
c:fill(c:rrect(46, 52, 73, 67, 1), "#f1ece0")
c:outline(c:rrect(46, 52, 73, 67, 1))
c:paint({
  "..pp...",
  ".pppp..",
  "ppppppp",
  "pppppp.",
  ".pp.pp.",
  ".pp....",
}, 50, 56, { p = "#8a5fd0" })
c:paint({ ".uuu.", "uu.uu", "uu.uu", "uu.uu", "uu.uu", "uu.uu", ".uuu." }, 62, 56, { u = "#74462a" })
-- lid seam and button, hem on the front
c:seam({ {28, 70}, {91, 70} })

-- face: jeff-v2 eyes + brow, worried little smile (empty box!)
c:button(bx-2, 14)
c:eye(bx-11, 28); c:eye(bx+5, 27)
c:paint({ "uuuu" }, bx+5, 24, { u = "umber" })
c:paint({ "u.....u", ".uuuuu." }, bx-4, 35, { u = "umber" })

local t = c:save(ASE .. "empty-box.aseprite", PNG .. "empty-box.png")
print("empty-box", GV.report(t))
assert(t.semi == 0 and t.bw == 0)

-- Puzzles hub tile: Jeff (bright green jigsaw) holding up a big purple puzzle piece. 64x64 icon mode, chunky.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local ASE, PNG = D .. "extras-pixel/cast/", "/home/user/gnome-venture/game/assets/img/puzzles/cast/"

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- Jeff, sat low-left; body as jeff-v2 shifted
local dx, dy = -4, 4
local body = c:poly({ {16+dx, 25+dy}, {45+dx, 22+dy}, {46+dx, 50+dy}, {18+dx, 52+dy} })
body:add(c:rrect(26+dx, 14+dy, 35+dx, 26+dy, 2)); body:add(c:ellipse(30.5+dx, 12+dy, 7.5, 6))
body:cut(c:ellipse(32+dx, 53+dy, 6, 4.5))
body:cut(c:rect(0, 61, 63, 63))

-- left arm tab, right arm raised holding the piece
local armL = c:rrect(10, 39, 15, 45, 2); armL:add(c:ellipse(10, 42, 3, 4))
armL:cut(body:grow(1))
local armR = c:line({ {40, 35}, {44, 30}, {46, 25} }, 4)
armR:cut(body:grow(1))

-- big purple puzzle piece held up at the top right (knob up, tab right, notch bottom)
local piece = c:rrect(38, 12, 52, 26, 2)
piece:add(c:ellipse(45.5, 10, 4, 3.5)); piece:add(c:ellipse(53, 19.5, 3, 4))
piece:cut(c:ellipse(45.5, 27, 4, 3.5))

c:build{
  { "armL",  armL,  GV.ramp("#2cc97c"), { flat = true } },
  { "armR",  armR,  GV.ramp("#2cc97c"), { flat = true } },
  { "body",  body,  GV.ramp("#1fb86b"), { stitch = { side = "lit" } } },
  { "piece", piece, GV.ramp("#8a5fd0"), { gloss = { 41, 15 }, stitch = { side = "lit" } } },
}
c:button(29+dx, 15+dy)
c:seam({ {21+dx, 47+dy}, {25+dx, 47+dy} }); c:seam({ {39+dx, 47+dy}, {43+dx, 47+dy} })
-- hand gripping the bottom of the piece
c:paint({ "aaaa", "aaa." }, 43, 25, { a = "#2cc97c" })

-- face
c:eye(20+dx, 28+dy); c:eye(36+dx, 27+dy)
c:paint({ "uuuu" }, 36+dx, 24+dy, { u = "umber" })
c:paint({
  "u.........u",
  ".u.......u.",
  ".uccccccc u",
  "..uuuuuuu..",
}, 25+dx, 38+dy, { u = "umber", c = "#f1ece0" })

local t = c:save(ASE .. "tile-puzzles.aseprite", PNG .. "tile-puzzles.png")
print("tile-puzzles", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

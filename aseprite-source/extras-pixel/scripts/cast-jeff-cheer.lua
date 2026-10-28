-- Jeff cheer (win pose): both arms thrown up, mouth wide open, confetti bits in the air. 64x64 sticker.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local ASE, PNG = D .. "extras-pixel/cast/", "/home/user/gnome-venture/game/assets/img/puzzles/cast/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dy = 4
local body = c:poly({ {16, 25+dy}, {45, 22+dy}, {46, 50+dy}, {18, 52+dy} })
body:add(c:rrect(26, 14+dy, 35, 26+dy, 2)); body:add(c:ellipse(30.5, 12+dy, 7.5, 6))
body:cut(c:ellipse(32, 53+dy, 6, 4.5))
body:cut(c:rect(0, 61, 63, 63))

-- both arms up in a V, fists at the ends
local armL = c:line({ {18, 36}, {12, 28}, {11, 21} }, 4); armL:add(c:ellipse(10, 18, 3.5, 3.5))
armL:cut(body:grow(1))
local armR = c:line({ {44, 34}, {50, 26}, {50, 20} }, 4); armR:add(c:ellipse(51, 17, 3.5, 3.5))
armR:cut(body:grow(1))

-- confetti: small flat bits, red / gold / purple / water
local function dia(x, y) return c:ascii({ ".x.", "xxx", ".x." }, x, y) end
local conf = {
  { dia(19, 9), "#dd3a2a" }, { dia(40, 8), "#8a5fd0" }, { dia(24, 4), "#e8a317" },
  { dia(5, 27), "#3f8fb0" }, { dia(55, 26), "#e8a317" },
}
local parts = {
  { "armL", armL, GV.ramp("#2cc97c"), { flat = true } },
  { "armR", armR, GV.ramp("#2cc97c"), { flat = true } },
  { "body", body, GV.ramp("#1fb86b"), { stitch = { side = "lit" } } },
}
for i, b in ipairs(conf) do parts[#parts+1] = { "c"..i, b[1], GV.ramp(b[2]), { flat = true, contact = false } } end
c:build(parts)
c:button(29, 15+dy)
c:seam({ {21, 47+dy}, {25, 47+dy} }); c:seam({ {39, 47+dy}, {43, 47+dy} })

-- face: eyes wide, both brows up, mouth wide open with a tooth row and a tongue-dark inside
c:eye(20, 28+dy); c:eye(36, 27+dy)
c:paint({ "uuuu" }, 19, 24+dy, { u = "umber" }); c:paint({ "uuuu" }, 36, 23+dy, { u = "umber" })
c:paint({
  ".uuuuuuuuu.",
  "ucccccccccu",
  "udddddddddu",
  "udddddddddu",
  ".uddddddddu",
  "..uuuuuuu..",
}, 25, 38+dy, { u = "umber", c = "#f1ece0", d = "#6b1b2c" })

local t = c:save(ASE .. "jeff-cheer.aseprite", PNG .. "jeff-cheer.png")
print("jeff-cheer", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

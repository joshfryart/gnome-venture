local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- round cloth belly
local body = c:ellipse(31.5, 39, 18, 16)
-- gathered neck above the twine, flaring into ruffles
local top = c:poly({ {27, 26}, {37, 26}, {41, 19}, {44, 13}, {39, 15}, {36, 12}, {32, 15}, {28, 12}, {25, 15}, {20, 13}, {23, 19} })
-- drooping cloth tail off the right ruffle
local tail = c:poly({ {41, 15}, {46, 14}, {50, 19}, {49, 23}, {46, 21}, {43, 18} })
local twine = c:rrect(24, 24, 39, 27, 1)
local seed = c:ellipse(31.5, 43, 6.5, 6)

local p = c:build{
  { "tail",  tail,  "cream", { flat = true } },
  { "body",  body,  "cream", { stitch = { side = "lit" } } },
  { "top",   top,   "cream", { gloss = false } },
  { "twine", twine, GV.ramp("#dcb06a"), { gloss = false } },
  { "seed",  seed,  GV.ramp("#8c4a1a") },
}
-- ruffle pleats on the neck
c:paint({ "u", "u", "u" }, 29, 18, { u = "#c9a96e" })
c:paint({ "u", "u", "u" }, 34, 18, { u = "#c9a96e" })
-- twine bow loops and tails
local bow = { "..tt..", ".t..t.", "t....t", ".t..t.", "..tt.." }
c:paint({ ".tt.", "t..t", "t..t", ".tt." }, 19, 23, { t = "#a5663a" })
c:paint({ ".tt.", "t..t", "t..t", ".tt." }, 40, 23, { t = "#a5663a" })
c:line({ {25, 28}, {24, 32} }, 1)
c:paint({ "t", "t", "t", "t", "t" }, 25, 28, { t = "#a5663a" })
c:paint({ "t", "t", "t", "t" }, 38, 28, { t = "#a5663a" })
c:paint({ "t" }, 24, 32, { t = "#a5663a" })
c:paint({ "t" }, 39, 31, { t = "#a5663a" })
-- sprout from the seed
c:paint({ "ss", "ss", "ss", "ss", "ss" }, 31, 33, { s = "#2e5a2c" })
c:paint({ "..llll..", ".llllll.", "llllllll", ".llllll." }, 33, 31, { l = "#58a03e" })
c:paint({ "..gg" }, 33, 31, { g = "#8fcf5e" })
-- fold line on the cloth
c:paint({ "ff.......", "..fff....", ".....fff." }, 19, 49, { f = "#dcb06a" })

local t = c:save(O .. "aseprite/ph/chocolate-cosmos-seed.aseprite", O .. "png/ph/chocolate-cosmos-seed.png")
print(GV.report(t))

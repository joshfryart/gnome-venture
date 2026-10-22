local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- round cloth belly
local body = c:ellipse(31.5, 39, 17, 14)
-- gathered neck narrowing to tie, then flaring frill above
local neck = c:poly({ {22, 29}, {42, 29}, {37, 24}, {27, 24} })
local frill = c:poly({ {27, 26}, {37, 26}, {41, 15}, {37, 13}, {32, 17}, {27, 13}, {23, 15} })
frill:add(c:ellipse(26, 15, 3, 2.5)):add(c:ellipse(38, 15, 3, 2.5))
local tie = c:rrect(24, 23, 40, 26, 1)
local bow = c:ellipse(28.5, 24.5, 3, 2):add(c:ellipse(36.5, 24.5, 3, 2))
local patch = c:ellipse(31.5, 41, 8, 7)
local seed = c:ellipse(31.5, 42, 5, 4)

local cloth = GV.ramp("#f1ece0")
local p = c:build{
  { "frill", frill, cloth },
  { "body",  body:add(neck), cloth, { light = body:copy():add(frill) } },
  { "tie",   tie, GV.ramp("#dcb06a") },
  { "bow",   bow, GV.ramp("#dcb06a"), { flat = true } },
  { "patch", patch, GV.ramp("#f4f0e0"), { gloss = false } },
  { "seed",  seed, "petal" },
}
c:stitch(p.patch.m)
-- bow knot and tails
c:fill(c:rect(31, 23, 32, 26), "#b8661a")
c:fill(c:line({ {30, 27}, {29, 31} }, 1), "#b8661a")
c:fill(c:line({ {33, 27}, {34, 31} }, 1), "#b8661a")
-- little sprout on seed
c:paint({ ".gg.", "g..g", ".gg." }, 30, 35, { g = "#58a03e" })
c:fill(c:rect(31, 37, 32, 37), "#3e7a2e")
-- wrap folds
c:fill(c:line({ {19, 36}, {20, 41}, {22, 45} }, 1), "#dcb06a")
c:fill(c:line({ {44, 36}, {43, 41}, {41, 45} }, 1), "#dcb06a")
c:seam({ {46, 32}, {48, 38}, {47, 45}, {44, 50} })
c:ground(31.5, 54, 14, 1.5, "#7a4a1f")
local t = c:save(O .. "aseprite/ph/fuchsia-seed.aseprite", O .. "png/ph/fuchsia-seed.png")
print(GV.report(t))

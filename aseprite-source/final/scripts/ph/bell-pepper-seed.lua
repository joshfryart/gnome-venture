local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

-- cloth sack body (rounded, slightly wider at bottom)
local body = c:ellipse(31.5, 40, 17, 14)
body:add(c:rrect(16, 38, 47, 52, 6))
body:cut(c:rect(0, 54, 63, 63))
-- gathered frilled top above the knot
local top = c:poly({ {22, 13}, {26, 16}, {29, 12}, {32, 16}, {35, 12}, {38, 16}, {42, 13}, {38, 27}, {26, 27} })
-- string tie band
local tie = c:rrect(24, 24, 39, 27, 1)
local seed = c:ellipse(31.5, 41, 6, 6.5)
seed:add(c:ellipse(31.5, 37, 4, 3))

local p = c:build{
  { "top",  top,  "cream" },
  { "body", body, "cream", { stitch = true } },
  { "tie",  tie,  GV.ramp("#dcb06a") },
  { "endL", c:line({ {24, 27}, {21, 31} }, 2), GV.ramp("#dcb06a"), { flat = true } },
  { "endR", c:line({ {39, 27}, {42, 31} }, 2), GV.ramp("#dcb06a"), { flat = true } },
  { "seed", seed, "dusk" },
}
-- sprout from seed
c:fill(c:rect(31, 31, 32, 34), "#2f5a2a")
c:paint({ ".ll.", "llll", "lll.", }, 33, 30, { l = "#6a9a3a" })
c:px(34, 30, "#a4b86a")
-- seed highlight
c:px(29, 38, "#a894dc"); c:px(28, 39, "#7b66b4")
-- hem seam
c:seam({ {21, 51}, {43, 51} })
c:button(30, 23)
local t = c:save(O .. "aseprite/ph/bell-pepper-seed.aseprite", O .. "png/ph/bell-pepper-seed.png")
print(GV.report(t))

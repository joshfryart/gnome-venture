local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local packet = c:rrect(14, 11, 50, 55, 1)
local label = c:rrect(18, 26, 46, 51, 4)
local labelIn = c:rrect(20, 28, 44, 49, 3)
local border = label:copy():cut(labelIn)
local flap = c:poly({ {14, 11}, {51, 11}, {51, 21}, {32, 27}, {14, 21} })

local berry = c:ascii({
  "......xxxxxxx......",
  "...xxxxxxxxxxxxx...",
  ".xxxxxxxxxxxxxxxxx.",
  "xxxxxxxxxxxxxxxxxxx",
  "xxxxxxxxxxxxxxxxxxx",
  "xxxxxxxxxxxxxxxxxxx",
  "xxxxxxxxxxxxxxxxxxx",
  ".xxxxxxxxxxxxxxxxx.",
  ".xxxxxxxxxxxxxxxxx.",
  "..xxxxxxxxxxxxxxx..",
  "..xxxxxxxxxxxxxxx..",
  "...xxxxxxxxxxxxx...",
  "....xxxxxxxxxxx....",
  ".....xxxxxxxxx.....",
  "......xxxxxxx......",
  ".......xxxxx.......",
  "........xxx........",
}, 23, 31)
local calyx = c:ascii({
  "x.....x.....x",
  "xx...xxx...xx",
  ".xxxxxxxxxxx.",
  "..xxxx.xxxx..",
  "...xx...xx...",
}, 26, 29)

local p = c:build{
  { "packet", packet, "cream", { gloss = false } },
  { "label", label, "#f4f0e0", { gloss = false, rim = false, bounce = false } },
  { "flap", flap, GV.ramp("#dcb06a", { shade = "#c4925f" }), { gloss = { 18, 13 } } },
  { "berry", berry, GV.ramp("#d6322b", { shade = "#a8241f", gloss = "#ff9158" }), { gloss = { 26, 34 } } },
  { "calyx", calyx, "moss", { flat = true } },
}
c:fill(border, "#d6322b")
-- stem
c:fill(c:rect(32, 25, 33, 29), "#2f5a2a")
-- seed flecks in a diamond pattern
for _, pt in ipairs({ {32, 36}, {28, 39}, {36, 39}, {32, 42}, {29, 44}, {35, 44}, {32, 46} }) do
  c:px(pt[1], pt[2], "#f08a24")
end
c:seam({ {16, 21}, {31, 26} })
c:seam({ {34, 26}, {49, 21} })
c:ground(32, 57, 16, 2.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/strawberry-seed.aseprite", D .. "img-redraw-full/png/ph/strawberry-seed.png")
print(GV.report(t))

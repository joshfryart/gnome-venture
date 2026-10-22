local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tan = GV.ramp("#dcb06a", { rim = "#d9a660", shade = "#a5663a" })
local leafR = GV.ramp("#58a03e")

local leaf = c:poly({ {32, 20}, {33, 14}, {36, 10}, {41, 7}, {46, 6}, {45, 11}, {42, 15}, {37, 19} })
local stem = c:rrect(30, 13, 33, 23, 1)

c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf", leaf, leafR, { gloss = false } },
  { "gourd", c:ellipse(31.5, 37, 16, 15), tan },
}
-- leaf midrib
c:line({ {34, 17}, {38, 12}, {44, 8} }, 1)
c:fill(c:line({ {34, 17}, {38, 12}, {44, 8} }, 1), leafR.shade)

-- cream seed speckles (beans)
local seed = { ".c.", "ccc", "ccs", ".s." }
local L = { c = "#f1ece0", s = "#c9a96e" }
local seeds = { {25, 31}, {36, 30}, {29, 40}, {38, 39}, {21, 40}, {31, 47}, {41, 45}, {32, 34}, {44, 34}, {24, 46} }
for _, s in ipairs(seeds) do c:paint(seed, s[1], s[2], L) end

local t = c:save(O .. "aseprite/ph/egusi.aseprite", O .. "png/ph/egusi.png")
print(GV.report(t))

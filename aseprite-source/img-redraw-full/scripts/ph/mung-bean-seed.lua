local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- bundle body: squat sack bulging low
local body = c:ellipse(31.5, 41, 18, 13)
body:add(c:rrect(17, 24, 46, 40, 8))
-- gathered neck frill: two flared tufts
local frill = c:poly({ {21, 12}, {27, 15}, {31, 22}, {25, 24}, {22, 19} })
frill:add(c:poly({ {43, 12}, {42, 19}, {39, 24}, {33, 22}, {37, 15} }))
frill:add(c:rrect(26, 16, 38, 24, 2))
frill:add(c:poly({ {28, 17}, {30, 11}, {32, 13}, {34, 11}, {36, 17} }))
local str = c:rrect(24, 21, 40, 23, 1)
local patch = c:rrect(21, 29, 43, 49, 5)

local p = c:build{
  { "body", body, "#f1ece0", { stitch = true } },
  { "frill", frill, "#f1ece0" },
  { "string", str, "#8c4a1a", { flat = true } },
  { "patch", patch, "#f4f0e0", { gloss = false } },
}
-- frill fold lines
c:line({ {25, 17}, {28, 21} }, 1)
c:paint({ "f", ".f", "..f", "...f" }, 25, 17, { f = "#dcb06a" })
c:paint({ "...f", "..f", ".f", "f" }, 36, 17, { f = "#dcb06a" })
c:paint({ "f", "f", "f" }, 32, 17, { f = "#dcb06a" })
-- bow loops + tails
c:paint({
  ".ss.......ss.",
  "s..s.....s..s",
  "s...s...s...s",
  ".sss.....sss.",
}, 26, 17, { s = "#8c4a1a" })
c:paint({ "s", "s", ".s", ".s", "..s" }, 29, 24, { s = "#8c4a1a" })
c:paint({ "..s", "..s", ".s", ".s", "s" }, 33, 24, { s = "#8c4a1a" })
c:button(30, 19)
-- patch border (2px wood)
local pr = patch:copy():cut(patch:shrink(2))
c:fill(pr, "#8c4a1a")
-- mung bean, tilted
local bean = c:poly({ {24, 42}, {27, 37}, {33, 34}, {39, 34}, {41, 37}, {39, 42}, {33, 45}, {27, 46} })
c:part(bean, GV.ramp("#8a4f2a"), { gloss = { 29, 38 } })
c:paint({ "....kk", "..kk", "kk" }, 30, 38, { k = "#44281c" })
c:paint({ ".gg", "g..", "g.." }, 22, 43, { g = "#4a8a3e" })
-- hem dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 51, x + 1, 52), "#8c4a1a") end
c:ground(31.5, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/mung-bean-seed.aseprite", O .. "png/ph/mung-bean-seed.png")
print(GV.report(t))

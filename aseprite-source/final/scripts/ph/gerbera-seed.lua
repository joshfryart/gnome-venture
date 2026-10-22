local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local d = -3
local cloth = GV.ramp("#dfe3b8")
local frill = GV.ramp("#f1ece0")
local cordR = GV.ramp("#b0bc66")
local charmR = GV.ramp("#b0bc66", { rim = "#a4b86a" })
-- belly: wider at the bottom, pinched toward the neck
local body = c:ellipse(32, 42 + d, 18, 13)
body:add(c:poly({ {23, 26 + d}, {42, 26 + d}, {50, 40 + d}, {14, 40 + d} }))
local mouth = c:ellipse(32, 24 + d, 12, 4)
for _, x in ipairs({ 21, 26.5, 32, 37.5, 43 }) do mouth:add(c:ellipse(x, 21 + d, 2.5, 2.5)) end
local p = c:build{
  { "body",  body, cloth, { stitch = { side = "lit" } } },
  { "mouth", mouth, frill },
  { "cord",  c:rect(20, 27 + d, 44, 28 + d), cordR, { flat = true } },
  { "tailL", c:line({ {30, 28 + d}, {24, 36 + d} }, 2), cordR, { flat = true } },
  { "tailR", c:line({ {34, 28 + d}, {40, 36 + d} }, 2), cordR, { flat = true } },
  { "knobL", c:rrect(22, 36 + d, 25, 39 + d, 1), cordR, { flat = true } },
  { "knobR", c:rrect(39, 36 + d, 42, 39 + d, 1), cordR, { flat = true } },
  { "charm", c:ellipse(32, 45 + d, 6, 6), charmR },
  { "leaf",  c:ellipse(33.5, 37.5 + d, 2, 1.5), "#58a03e", { flat = true } },
}
-- charm detail: tiny daisy centre
c:paint({ ".s.", "sss", ".s." }, 31, 44 + d, { s = "#7a8a3a" })
-- hem line
for x = 20, 44 do if body:has(x, 52 + d) then c:px(x, 52 + d, "#dcb06a") end end
c:seam({ {20, 31 + d}, {20, 49 + d} })
c:ground(32, 56 + d, 15, 1.5)
local t = c:save(O .. "aseprite/ph/gerbera-seed.aseprite", O .. "png/ph/gerbera-seed.png")
print(GV.report(t))

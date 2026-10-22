local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local burlap = GV.ramp("#b07a45", { shade = "#8a4f2a", gloss = "#d9a660" })
local frillR = GV.ramp("#d9a660", { shade = "#8a4f2a" })
local twine  = GV.ramp("#e9c98a")
local seedR  = GV.ramp("#7a5cc0", { shade = "#4e3a8a", gloss = "#a894dc" })
local leaf   = GV.ramp("#58a03e")

-- sprout peeking out of the frill
local sprout = c:ellipse(39, 9, 2.5, 3.5)
sprout:add(c:rect(36, 11, 37, 15))

-- lumpy sack: wide bottom, pinched neck
local body = c:ellipse(32, 43, 19, 13)
body:add(c:poly({ {23, 24}, {42, 24}, {49, 36}, {15, 36} }))

-- ruffled zig-zag frill above the tie
local frill = c:poly({ {21, 25}, {17, 15}, {21, 18}, {24, 12}, {28, 17}, {32, 11},
                       {36, 17}, {40, 12}, {43, 18}, {47, 15}, {43, 25} })

local band = c:rect(20, 23, 44, 26)
local knot = c:rrect(29, 22, 35, 28, 1)

local p = c:build{
  { "sprout", sprout, leaf, { flat = true } },
  { "body",  body,  burlap, { stitch = true } },
  { "frill", frill, frillR },
  { "band",  band,  twine },
  { "knot",  knot,  twine },
}

-- burlap patch with weave marks
local patch = c:rrect(22, 31, 42, 52, 3)
c:part(patch, frillR, { gloss = false })
for y = 33, 50, 3 do
  for x = 24, 40, 3 do
    if patch:has(x, y) then c:px(x, y, "#8a4f2a") end
  end
end

-- violet seed
c:part(c:ellipse(32, 41.5, 7, 7), seedR)

-- twine seam and bow tails
c:seam({ {20, 24}, {28, 24} }); c:seam({ {36, 24}, {44, 24} })
c:paint({ "t...t", "tt.tt" }, 30, 29, { t = "#c9a96e" })

local t = c:save(O .. "aseprite/ph/marsh-marigold-seed.aseprite", O .. "png/ph/marsh-marigold-seed.png")
print(GV.report(t))

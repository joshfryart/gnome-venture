local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- arch handle (broken: snapped near the right side, a gap)
local handle = c:line({ {18,31},{18,24},{21,19},{26,16},{33,15},{38,16} }, 3)
handle:add(c:line({ {42,18},{46,21},{49,25},{49,31} }, 3))

-- tapered tub body with chipped lower-right corner
local body = c:poly({ {16,33},{51,33},{47,58},{20,58} })
body:cut(c:poly({ {45,50},{50,50},{50,57},{43,57} }))
body:cut(c:rect(15, 46, 18, 48))

local rimb = c:rrect(14, 26, 51, 34, 4)
rimb:cut(c:rect(14, 26, 16, 28))  -- chip off the rim's left corner

local p = c:build{
  { "handle", handle, GV.ramp("#c4925f", { rim = "#f0d49a" }), { gloss = false } },
  { "body", body, GV.ramp("#8c4a1a") },
  { "rim", rimb, GV.ramp("#c4925f", { rim = "#f0d49a" }) },
}

-- iron hoops / stave dashes
local WD = GV.R.wood.deep
c:fill(c:line({ {22,40},{30,40} }, 1), "#2a1a10")
c:fill(c:line({ {34,46},{42,46} }, 1), "#2a1a10")
c:fill(c:line({ {26,53},{34,53} }, 1), "#2a1a10")

-- crack zig-zag down the body
c:fill(c:line({ {33,35},{36,39},{31,43},{36,48},{33,53} }, 2), "#2a1a10")
-- crack in the rim
c:fill(c:line({ {33,26},{35,30},{33,33} }, 1), "#4a2c1a")

-- rim seam
c:seam({ {18,30}, {50,30} })

-- loose splinter lying beside the bucket
c:part(c:poly({ {11,56},{17,53},{18,55},{12,58} }), GV.ramp("#8c4a1a"), { flat = true })

c:ground(33.5, 58, 15, 1)
local t = c:save(O .. "aseprite/ph/broken-tide-bucket.aseprite", O .. "png/ph/broken-tide-bucket.png")
print(GV.report(t))

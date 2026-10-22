local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- arched strap: half ellipse
local pts = {}
for i = 0, 16 do
  local a = math.pi * i / 16
  pts[#pts + 1] = { math.floor(31.5 - 12 * math.cos(a) + 0.5), math.floor(32 - 18 * math.sin(a) + 0.5) }
end
local strap = c:line(pts, 4)

-- sack body with a torn notch on the right edge
local body = c:poly({ {13, 31}, {51, 31}, {47, 52}, {17, 52} })
body:cut(c:poly({ {51, 36}, {44, 40}, {50, 44} }))
body:cut(c:poly({ {13, 41}, {16, 43}, {13, 45} })) -- small nick left

local band1 = c:rect(10, 37, 54, 39):clip(body)
local band2 = c:rect(10, 45, 54, 47):clip(body)
local knot = c:ellipse(25, 31, 4, 3.5)
local scrap = c:poly({ {48, 46}, {53, 47}, {52, 53}, {47, 51} })

local sack = GV.ramp("#b07a10")
c:build{
  { "strap", strap, sack },
  { "body", body, sack, { stitch = false } },
  { "band1", band1, GV.ramp("#f5cf6a"), { gloss = false } },
  { "band2", band2, GV.ramp("#f5cf6a"), { gloss = false } },
  { "knot", knot, GV.ramp("#8c4a1a") },
  { "scrap", scrap, sack, { gloss = false } },
}
c:seam({ {14, 32}, {50, 32} })
-- zigzag tear down the front
c:fill(c:line({ {33, 32}, {35, 35}, {31, 38}, {35, 41}, {31, 44}, {34, 48} }, 2), "#2a1a10")
local t = c:save(O .. "aseprite/ph/broken-harvest-sack.aseprite", O .. "png/ph/broken-harvest-sack.png")
print(GV.report(t))

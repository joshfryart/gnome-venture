local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 90, mode = "sticker" }

-- tapered tub (wider at the top)
local body = c:poly({ {16, 20}, {85, 20}, {77, 75}, {24, 75} })
local function hoop(yc)
  return c:ellipse(50, yc, 52, 7):cut(c:ellipse(50, yc - 3, 52, 7)):clip(body)
end
local h1, h2 = hoop(38), hoop(62)
local rim = c:ellipse(50, 20, 35, 10)
local water = c:ellipse(50, 21, 29, 6.5)

local p = c:build{
  { "body",  body,  GV.ramp("#8a5530") },
  { "hoop1", h1,    GV.ramp("#7a3a14"), { gloss = false } },
  { "hoop2", h2,    GV.ramp("#7a3a14"), { gloss = false } },
  { "rim",   rim,   GV.ramp("#5e3a22") },
  { "water", water, GV.ramp("#1f4a5c"), { gloss = false, rim = false } },
}
-- plank seams along the taper (skip hoops)
for _, s in ipairs({ { {34, 29}, {37, 74} }, { {50, 30}, {50, 74} }, { {67, 29}, {64, 74} } }) do
  local m = c:line(s, 1):clip(body):cut(h1):cut(h2):cut(rim)
  c:fill(m, "#5e2f1e")
end
-- lighter water ring at upper-left
for x = 24, 50 do
  local t = (x - 50) / 29
  local y = math.floor(21 - 6.5 * math.sqrt(math.max(0, 1 - t * t)) + 1.5)
  c:px(x, y, "#3f8fb0")
end
c:px(26, 19, "#3f8fb0"); c:px(25, 20, "#3f8fb0")
-- a calm glint line on the water
c:fill(c:rect(34, 20, 41, 20), "#3f8fb0")
c:fill(c:rect(56, 23, 59, 23), "#2f6290")
-- thread-gold dashes along the hoops
for _, yc in ipairs({ 38, 62 }) do
  local pts = {}
  for x = 22, 80, 2 do
    local t = (x - 50) / 52
    pts[#pts + 1] = { x, math.floor(yc + 7 * math.sqrt(1 - t * t) - 1.5 + 0.5) }
  end
  c:seam(pts)
end
c:ground(50.5, 76, 30, 2)
local t = c:save(O .. "aseprite/gather/calm-bucket-back.aseprite", O .. "png/gather/calm-bucket-back.png")
print(GV.report(t))

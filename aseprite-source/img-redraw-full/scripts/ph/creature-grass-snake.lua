local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- stamp circles along a path with tapering radius
local function tube(m, pts, r0, r1, step)
  local segs, total = {}, 0
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local d = math.sqrt((b[1]-a[1])^2 + (b[2]-a[2])^2)
    segs[#segs + 1] = { a, b, d }; total = total + d
  end
  local acc = 0
  for _, s in ipairs(segs) do
    local n = math.max(1, math.floor(s[3] / (step or 0.5)))
    for k = 0, n do
      local t = k / n
      local x = s[1][1] + (s[2][1] - s[1][1]) * t
      local y = s[1][2] + (s[2][2] - s[1][2]) * t
      local f = (acc + s[3] * t) / total
      m:add(c:ellipse(x, y, r0 + (r1 - r0) * f))
    end
    acc = acc + s[3]
  end
  return m
end

local path = { {15,47}, {22,52}, {33,53.5}, {44,51.5}, {51,47}, {54,41}, {53,35}, {49,31} }
local body = tube(c:mask(), path, 5, 1.6)
local neck = tube(c:mask(), { {14,48}, {13,42}, {15,34} }, 4.5, 4.2)
local head = c:ellipse(16, 27, 8.5, 8):add(c:ellipse(23, 30, 6, 4))

local green = GV.ramp("#58a03e")
local p = c:build{
  { "body", body, green, { light = body:copy():add(neck):add(head) } },
  { "neck", neck, green, { gloss = false } },
  { "head", head, green },
}

-- pale back stripe along the top of the body (offset toward the back)
local stripe = tube(c:mask(), { {20,49.5}, {33,51}, {43,49}, {48.5,45}, {51,40}, {50.5,36} }, 1.1, 0.7)
stripe:clip(body:shrink(1))
c:fill(stripe, "#b0bc66")
-- neck stripe
local ns = tube(c:mask(), { {12,46}, {11.5,41} }, 0.9, 0.9):clip(neck:shrink(1))
c:fill(ns, "#b0bc66")

-- dark cross bands, perpendicular to the body run
local bands = c:mask()
bands:add(c:rect(23, 48, 24, 56))
bands:add(c:rect(32, 49, 33, 58))
bands:add(c:rect(41, 47, 42, 56))
bands:add(c:poly({ {47,42}, {49,41}, {55,46}, {53,47} }))
bands:add(c:rect(48, 39, 58, 40))
bands:add(c:rect(46, 33, 56, 34))
bands:clip(body:shrink(1))
c:fill(bands, "#2e5a2c")

-- face
c:eye(10, 23, true); c:eye(17, 23, true)
c:paint({ "mmmmmm" }, 21, 32, { m = "#2a1a10" })
-- forked tongue
c:paint({
  "......t",
  "tttttt.",
  "......t",
}, 27, 31, { t = "#d6322b" })
local t = c:save(O .. "aseprite/ph/creature-grass-snake.aseprite", O .. "png/ph/creature-grass-snake.png")
print(GV.report(t))

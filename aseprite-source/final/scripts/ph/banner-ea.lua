local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
-- half-size grid 120x40, written at 2x (240x80)
local c = GV.canvas{ w = 120, h = 40, mode = "scene", out = 2, ol = 1, olx = 0 }

local function band(top) -- wavy band from top(x) down to the bottom
  local m = c:mask()
  for x = 0, 119 do for y = math.floor(top(x) + 0.5), 39 do m:set(x, y) end end
  return m
end

-- sky: soft stepped bands, palest near the horizon
c:bands(c:rect(0, 0, 119, 39), { "#eea6c2", "#f6b8cf", "#f9c8da" }, { dir = "v" })

-- pale moon top right, with two soft craters
c:part(c:ellipse(93.5, 8, 4.5, 4.5), GV.ramp("#f4f0e0"), { gloss = { 91, 6 }, cres = 2, deep = 1 })
c:px(95, 9, "#e2d6bc"); c:px(96, 9, "#e2d6bc"); c:px(92, 10, "#e2d6bc")

-- snow-capped grey peak, centre-left
local peak = c:poly({ { 30, 29 }, { 50, 5 }, { 71, 29 } })
c:part(peak, GV.ramp("#968f96"), { gloss = false, cres = 3 })
local snow = c:poly({ { 50, 5 }, { 59, 15 }, { 56, 13 }, { 53, 16 }, { 50, 13 }, { 47, 16 }, { 44, 13 }, { 41, 15 } }):clip(peak)
c:part(snow, GV.ramp("#f4f0e0"), { gloss = { 49, 8 }, contour = false, cres = 2, deep = 1, outline = false })

-- two rolling hill bands
local far = band(function(x) return 27 + 2.2 * math.sin(x / 11 + 0.6) end)
c:part(far, "moss", { gloss = false, cres = 0, deep = 0, bounce = false })
local near = band(function(x) return 32.5 + 1.8 * math.sin(x / 8 + 2.1) end)
c:part(near, GV.ramp("#58a03e"), { gloss = false, cres = 0, deep = 0, bounce = false })

-- blossom trees: {cx, cy, r, trunk bottom}, varied sizes
local CROWN = GV.ramp("#e46a9b", { rim = "#f6b8cf" })
local trees = { { 12, 27, 5, 35 }, { 36, 28, 6, 37 }, { 74.5, 27, 5.5, 36 }, { 101, 25, 6, 34 }, { 114, 31, 4, 37 } }
for _, t in ipairs(trees) do
  local cx, cy, r, yb = t[1], t[2], t[3], t[4]
  local tx = math.floor(cx)
  c:part(c:rect(tx - 1, math.floor(cy), tx, yb), GV.ramp("#b6814d"), { flat = true })
  local crown = c:ellipse(cx, cy, r, r * 0.9)
  c:part(crown, CROWN, { gloss = false, cres = math.max(2, math.floor(r / 2)), deep = 1 })
  -- lit pink blob offset upper-left, with a 1 px highlight
  local blob = c:ellipse(cx - r * 0.35, cy - r * 0.35, r * 0.5, r * 0.45):clip(crown:shrink(1))
  c:fill(blob, "#f6b8cf")
  local bx, by = blob:bbox()
  if bx then c:px(bx + 1, by, "#fff3c8") end
end

-- petal specks in the sky and grass
local specks = { { 6, 6 }, { 21, 11 }, { 28, 4 }, { 64, 7 }, { 79, 14 }, { 84, 4 }, { 108, 13 }, { 116, 6 },
  { 20, 36 }, { 48, 34 }, { 58, 37 }, { 87, 35 }, { 94, 38 }, { 25, 31 }, { 62, 30 } }
for _, p in ipairs(specks) do c:px(p[1], p[2], "#e46a9b") end

-- hem stitches along top and bottom
c:seam({ { 0, 1 }, { 119, 1 } }, { free = true })
c:seam({ { 0, 38 }, { 119, 38 } }, { free = true })

local t = c:save(O .. "aseprite/ph/banner-ea.aseprite", O .. "png/ph/banner-ea.png")
print(GV.report(t))

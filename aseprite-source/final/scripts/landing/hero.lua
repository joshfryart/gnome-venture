-- landing/hero : 360x170 scene, drawn on a 180x85 grid, written 2x
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 180, h = 85, mode = "scene", out = 2, ol = 1, olx = 1 }
local W, H = 180, 85

-- 1. sky: stepped bands, sun with a glow ring
c:bands(nil, { "#d3e2c8", "#dbe5c6", "#e3e6c4", "#eae8c4", "#f0eac6" })
c:fill(c:ellipse(150, 19, 13), "#efe2a4")
c:fill(c:ellipse(150, 19, 11.5), "#f2dc8c")
c:part(c:ellipse(150, 19, 10), GV.ramp("#f5cf6a", { gloss = "#fff1c8", dot = "#fff8e0", rim = "#fbe39a" }), { outline = false, cres = 3 })

-- 2. clouds: soft cream arcs
local function cloud(x, y, w)
  local m = c:ellipse(x, y, w, w * 0.45):add(c:ellipse(x - w * 0.45, y + 1, w * 0.5, w * 0.3)):add(c:ellipse(x + w * 0.5, y + 1, w * 0.45, w * 0.28))
  m:cut(c:rect(0, y + 2, W, H))
  c:fill(m, "#f4f0e0")
  c:fill(m:copy():cut(m:shift(0, -1)), "#e6e2c8")
end
cloud(30, 34, 9); cloud(44, 27, 7)

-- ridge helper: cosine interpolation through points
local function ridge(pts)
  local m = c:mask()
  for x = -2, W + 1 do
    local y
    for i = 1, #pts - 1 do
      local a, b = pts[i], pts[i + 1]
      if x >= a[1] and x <= b[1] then
        local t = (x - a[1]) / (b[1] - a[1])
        t = (1 - math.cos(t * math.pi)) / 2
        y = a[2] + (b[2] - a[2]) * t
      end
    end
    y = y or (x < pts[1][1] and pts[1][2] or pts[#pts][2])
    m:rect(x, math.floor(y + 0.5), x, H + 4)
  end
  return m
end

-- 3./4. hills
local far = ridge({ { -2, 55 }, { 75, 46 }, { 125, 49 }, { 182, 44 } })
c:part(far, GV.ramp("#b0bc66"), { gloss = false, cres = 6 })
local near = ridge({ { -2, 69 }, { 40, 65 }, { 90, 68 }, { 140, 64 }, { 182, 67 } })
c:part(near, "moss", { gloss = false, cres = 6 })
-- grass tufts on the near hill
for _, p in ipairs({ { 10, 74 }, { 70, 80 }, { 108, 79 }, { 145, 80 }, { 170, 74 }, { 20, 82 } }) do
  c:paint({ "a.a", ".a." }, p[1], p[2], { a = "#4a8a3e" })
end
-- gnome contact shadow
c:fill(c:ellipse(90, 76.5, 13.5, 1.5), "#4a8a3e")

-- 5. mushrooms
local stemR = GV.ramp("#f4f0e0")
local function mush(cx, cy, rx, ry, hex, sw, sh)
  local cap = c:ellipse(cx, cy, rx, ry):cut(c:rect(cx - rx - 2, cy + 1, cx + rx + 2, cy + ry + 2))
  cap:add(c:rrect(cx - rx, cy - 1, cx + rx, cy + 1, 1))
  local stem = c:rrect(cx - sw, cy, cx + sw, cy + sh, 1)
  c:part(stem, stemR, { gloss = false })
  c:part(cap, hex, { cres = rx < 8 and 2 or nil, deep = rx < 8 and 1 or nil })
  return cap
end
local function dots(list) for _, d in ipairs(list) do c:spot(c:ellipse(d[1], d[2], d[3]), "#f4f0e0", "#fff3c8") end end
mush(30, 70, 10, 7, "red", 3, 9)
dots({ { 25, 66, 1.5 }, { 33, 64, 1.5 }, { 35, 68, 1 } })
mush(131, 73, 6.5, 4.5, GV.ramp("gold", { base = "#f0b429" }), 2, 6)
dots({ { 128, 72, 0.5 }, { 132, 71, 0.5 }, { 134, 73, 0.5 } })
mush(155, 72, 11.5, 8, GV.ramp("#7a5cc0"), 3, 10)
dots({ { 149, 68, 1.5 }, { 157, 66, 1.5 }, { 160, 70, 1 } })

-- 6. veg
-- sprout
c:part(c:line({ { 44, 80 }, { 44, 72 } }, 2), "leaf", { flat = true })
c:part(c:ellipse(40, 70, 3.5, 2), "moss", { gloss = false })
c:part(c:ellipse(48.5, 69, 3.5, 2), GV.ramp("#58a03e"), { gloss = false })
-- radish pair
c:part(c:line({ { 53, 72 }, { 52, 68 } }, 2), "leaf", { flat = true })
c:part(c:line({ { 58, 72 }, { 60, 68 } }, 2), "leaf", { flat = true })
c:part(c:ellipse(52.5, 75.5, 3, 3):add(c:rect(52, 78, 53, 79)), "red", { gloss = false })
c:part(c:ellipse(58.5, 76, 3.5, 3.5):add(c:rect(58, 79, 59, 80)), "flame", { gloss = false })
c:px(51, 74, "#ffc27a"); c:px(57, 74, "#ffc27a")
-- carrot
c:part(c:line({ { 117, 72 }, { 116, 68 } }, 2), "leaf", { flat = true })
c:part(c:line({ { 120, 72 }, { 122, 68 } }, 2), "moss", { flat = true })
c:part(c:poly({ { 114, 72 }, { 124, 72 }, { 120, 82 }, { 118, 82 } }), GV.ramp("#f08a24"), { gloss = false, cres = 2 })
c:px(116, 75, "#b8661a"); c:px(117, 75, "#b8661a"); c:px(121, 77, "#b8661a"); c:px(122, 77, "#b8661a")

-- 7. gnome
local boots = c:ellipse(84.5, 76, 3.5, 1.5):add(c:ellipse(95.5, 76, 3.5, 1.5))
c:part(boots, "dusk", { gloss = false })
local coat = c:poly({ { 82, 61 }, { 99, 61 }, { 106, 76 }, { 74, 76 } }):add(c:rrect(75, 70, 105, 76, 2))
local P = c:build{
  { "coat",  coat, GV.ramp("#3f93b2") },
  { "handL", c:ellipse(77, 70, 2.5), "skin", { gloss = false } },
  { "handR", c:ellipse(103, 70, 2.5), "skin", { gloss = false } },
  { "face",  c:ellipse(90, 53, 7.5), GV.ramp("#f6c9a0", { pale = false }), { gloss = { 85, 50 } } },
}
-- beard: rounded, pointed tip
local beard = c:ellipse(89.5, 61, 8, 5):add(c:poly({ { 82, 61 }, { 98, 61 }, { 92, 76 }, { 88, 76 } })):cut(c:rect(80, 50, 100, 56))
c:part(beard, GV.R.cream, { gloss = { 85, 58 } })
-- hat: tall red cone, tip leaning right
local hat = c:poly({ { 91, 23 }, { 93, 25 }, { 102, 49 }, { 78, 49 }, { 88, 26 } })
c:part(hat, "red", { gloss = { 86, 36 } })
c:part(c:rrect(79, 46, 101, 50, 1), GV.ramp("#c66b50"), { gloss = false })
c:part(c:ellipse(91, 25, 2.5), "gold", { gloss = false })
c:px(90, 24, "#fff1c8")
-- nose and eyes
c:part(c:ellipse(90, 56, 1.5, 1.5), GV.ramp("#e9a07a"), { flat = true, outline = false })
c:eye(86, 51, true); c:eye(92, 51, true)
-- stitching: brim seam, button at the collar, coat hem
c:seam({ { 80, 48 }, { 100, 48 } })
c:seam({ { 76, 74 }, { 104, 74 } })
c:button(100, 62)

-- hem stitch along top and bottom edges
c:seam({ { 0, 1 }, { 179, 1 } }, { free = true })
c:seam({ { 0, 83 }, { 179, 83 } }, { free = true })

local t = c:save(O .. "aseprite/landing/hero.aseprite", O .. "png/landing/hero.png")
print(GV.report(t))

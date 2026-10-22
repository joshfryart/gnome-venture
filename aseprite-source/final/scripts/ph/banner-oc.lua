-- ph/banner-oc : underwater coral reef, 120x40 grid written at 2x (240x80)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local c = GV.canvas{ mode = "scene", w = 120, h = 40, out = 2, ol = 1, olx = 1, cres = 2, deep = 1 }
-- three flat water bands
c:fill(c:rect(0, 0, 119, 11), "#a9d6ea")
c:fill(c:rect(0, 12, 119, 23), "#3f93b2")
c:fill(c:rect(0, 24, 119, 39), "#256a80")
-- sunbeam: one flat lighter patch, stepped per band
local beam = c:poly({ {36, 0}, {18, 24}, {42, 24} })
local b1 = beam:copy():clip(c:rect(0, 0, 119, 11));  c:fill(b1, "#c8ecdc")
local b2 = beam:copy():clip(c:rect(0, 12, 119, 23)); c:fill(b2, "#5aa6c0")
-- corner vignette (flat)
c:paint({ "vvv", "vv.", "v.." }, 0, 37 - 0, { v = "#2a3c6c" })
c:paint({ "vvv", ".vv", "..v" }, 117, 37, { v = "#2a3c6c" })
-- sand seabed: gentle wavy mound
local sand = c:mask()
for x = 0, 119 do
  local top = math.floor(35.5 + 1.3 * math.sin(x / 9) + 0.8 * math.sin(x / 4.3 + 1))
  for y = top, 39 do sand:set(x, y) end
end
c:part(sand, "gold", { gloss = false, outline = false, cres = 3 })
-- coral: 2 px stem, two side branches, bud clubs
local function coral(x, top, hex, flip)
  local s = flip and -1 or 1
  local base = 37
  local m = c:line({ {x, base}, {x, top} }, 2)
  local by1 = math.floor((base + top) / 2) + 1
  local by2 = by1 - 5
  local ax, bx = x - 6 * s, x + 6 * s + 1
  m:add(c:line({ {x, by1}, {ax, by1 - 1}, {ax, by1 - 6} }, 2))
  m:add(c:line({ {x + 1, by2}, {bx, by2 - 1}, {bx, by2 - 5} }, 2))
  local function club(px, py) m:add(c:rect(px - 1, py - 1, px + 1, py)) end
  club(x, top); club(ax, by1 - 6); club(bx, by2 - 5)
  c:part(m, hex, { gloss = false })
end
coral(12, 24, "#e46a9b")
coral(26, 27, "#e0501f", true)
coral(69, 22, "#7a5cc0")
coral(84, 26, "#e46a9b", true)
coral(108, 25, "#e0501f")
-- fish: oval body, tail, eye, light stripe
local function fish(x, y, right)
  local s = right and 1 or -1
  local body = c:ellipse(x + 0.5, y, 4, 2)
  local tx = x - 5 * s
  body:add(c:poly(right and { {tx - 1, y - 2}, {x - 3, y}, {tx - 1, y + 3} } or { {tx + 2, y - 2}, {x + 4, y}, {tx + 2, y + 3} }))
  c:part(body, "gold", { gloss = false })
  c:px(x + 2 * s + (right and 1 or 0), y - 1, "#2a1a10")
  c:px(x, y - 1, "#fff1c8"); c:px(x, y, "#fff1c8")
end
fish(48, 18, false)
fish(96, 24, true)
fish(36, 28, true)
-- bubbles
for _, b in ipairs({ {60, 14}, {62, 12}, {24, 20}, {102, 16} }) do
  c:paint({ ".b.", "b.b", ".b." }, b[1] - 1, b[2] - 1, { b = "#f4f0e0" })
end
c:seam({ {0, 1}, {119, 1} }, { free = true })
c:seam({ {0, 38}, {119, 38} }, { free = true })
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local t = c:save(O .. "aseprite/ph/banner-oc.aseprite", O .. "png/ph/banner-oc.png")
print(GV.report(t))

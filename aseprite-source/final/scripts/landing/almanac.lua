-- landing/almanac : 240x160 scene, drawn on a 120x80 grid, written 2x
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 120, h = 80, mode = "scene", out = 2, ol = 1, olx = 1 }
local W, H = 120, 80

-- 1. backdrop + wavy tabletop
c:fill(c:rect(0, 0, W - 1, H - 1), "#f3e5cf")
for i = 0, 6 do c:fill(c:rect(i * 20 + 6, 6 + (i % 2) * 8, i * 20 + 6, 6 + (i % 2) * 8), "#ead6b8") end
local tab = c:mask()
for x = -2, W + 1 do tab:rect(x, math.floor(59 + 1.2 * math.sin(x / 9) + 0.5), x, H + 4) end
c:part(tab, GV.ramp("#dcb06a"), { gloss = false, cres = 3 })

-- 2. floor shadow
c:fill(c:ellipse(60, 68, 35, 2.5), "#c89a58")

-- page shapes (top edge sags toward the spine, bottom dips toward it)
local function page(x0, x1, spineLeft)
  local m = c:mask()
  for x = x0, x1 do
    local t = spineLeft and (x - x0) / (x1 - x0) or (x1 - x) / (x1 - x0)
    local top = 21 + math.floor(2.4 * t * t + 0.5)
    local bot = 61 + math.floor(2.2 * t * t + 0.5)
    m:rect(x, top, x, bot)
  end
  return m
end
local L = page(25, 59, true)
local R = page(61, 95, false)

-- 3. cover: U band under the pages, lit rim outside
local cover = L:grow(3):add(R:grow(3)):add(c:rect(56, 22, 64, 66)):shift(0, 1)
cover = cover:closed(2)
c:part(cover, GV.ramp("#b6814d", { rim = "#f0d49a" }), { gloss = false, cres = 3 })

-- 4./5. pages (pale: umber outline, no lightest tone)
c:part(L, GV.ramp("#f1ece0", { shade = "#e2d4b4", bounce = "#e8dcc0", deep = "#d8c49a" }), { outline = false, gloss = { 28, 24 }, cres = 3 })
c:part(R, GV.ramp("#f4f0e0", { shade = "#e2d4b4", bounce = "#e8dcc0", deep = "#d8c49a" }), { outline = false, gloss = { 64, 24 }, cres = 3 })
local pages = L:copy():add(R)
c:outline(pages:copy():add(c:rect(60, 23, 60, 63)), { ol = 1, olx = 0, pale = pages:grow(3) })
-- 6. spine crease
c:fill(c:rect(59, 23, 61, 64), "#c4925f")
c:fill(c:rect(60, 23, 60, 64), "#a8784a")
-- page curl shading near the spine
c:fill(c:rect(57, 24, 58, 62), "#e8dcc0"); c:fill(c:rect(62, 24, 63, 62), "#e8dcc0")

-- 7. text pills
local pill = "#dcb06a"
c:fill(c:rrect(32, 29, 53, 30, 1), pill); c:fill(c:rrect(32, 33, 47, 34, 1), pill)
c:fill(c:rrect(68, 29, 88, 30, 1), pill); c:fill(c:rrect(68, 33, 81, 34, 1), pill)

-- 8. sprout on left page
c:part(c:line({ { 43, 57 }, { 43, 50 }, { 44, 46 } }, 2), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:poly({ { 43, 48 }, { 36, 42 }, { 34, 46 }, { 38, 50 } }):add(c:ellipse(37.5, 46, 3.5, 2.5)), "moss", { gloss = false, cres = 2 })
c:part(c:poly({ { 44, 47 }, { 51, 40 }, { 53, 44 }, { 49, 48 } }):add(c:ellipse(49.5, 44, 3.5, 2.5)), GV.ramp("#58a03e"), { gloss = false, cres = 2 })
c:paint({ "aaaaaaa" }, 40, 58, { a = "#d8c49a" })

-- 9. mushroom on right page
c:part(c:rrect(74, 48, 80, 58, 2), GV.ramp("#f4f0e0"), { gloss = false, cres = 3 })
local cap = c:ellipse(77, 49, 7.5, 6):cut(c:rect(60, 51, 100, 60)):add(c:rrect(69, 48, 85, 51, 1))
c:part(cap, "red", { gloss = { 73, 45 } })
for _, d in ipairs({ { 75, 46, 1 }, { 80, 45, 1 }, { 82, 49, 0.5 } }) do c:spot(c:ellipse(d[1], d[2], d[3]), "#f4f0e0", "#fff3c8") end
c:paint({ "aaaaaaaaa" }, 73, 59, { a = "#d8c49a" })

-- 10. sparkles: 4-point stars
local function star(cx, cy, r, base, lit)
  local m = c:mask()
  for y = -r, r do for x = -r, r do
    local ax, ay = math.abs(x), math.abs(y)
    if (ax <= 0.5 + (r - ay) * 0.22 and ay <= r) or (ay <= 0.5 + (r - ax) * 0.22 and ax <= r) or (ax + ay <= 2) then m:set(cx + x, cy + y) end
  end end
  c:part(m, base, { flat = true })
  c:px(cx - 1, cy - 1, lit)
end
star(91, 16, 5, "gold", "#fff1c8")
star(30, 15, 3, "petal", "#f6b8cf")
c:px(100, 26, "#f5cf6a"); c:px(20, 24, "#e46a9b"); c:px(104, 10, "#f5cf6a")

-- joins: spine seam and bottom hem
c:seam({ { 60, 25 }, { 60, 62 } })
c:seam({ { 0, 78 }, { 119, 78 } }, { free = true })

local t = c:save(O .. "aseprite/landing/almanac.aseprite", O .. "png/landing/almanac.png")
print(GV.report(t))

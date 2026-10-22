local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 120, h = 40, mode = "scene", out = 2, ol = 1, olx = 1 }

-- sky: stepped bands, lighter at top
c:bands(nil, { "#d8eef6", "#c4e4f1", "#b4dcee", "#a9d6ea" })

local function hill(f)
  local m = c:mask()
  for x = 0, 119 do local t = math.floor(f(x) + 0.5) for y = t, 39 do m:set(x, y) end end
  return m
end
local function snow(apex, base, yEnd, x0, x1)
  -- zigzag lower edge
  local pts = { apex }
  local n = 6
  for i = 0, n do
    local x = x1 - (x1 - x0) * i / n
    pts[#pts+1] = { x, yEnd + ((i % 2 == 0) and 0 or 3) }
  end
  return c:poly(pts)
end

local L = c:poly({ {18, 27}, {33.5, 1.5}, {49, 27} })
local M = c:poly({ {56, 27}, {74.5, -3}, {93, 27} })
local R = c:poly({ {97, 27}, {108, 9.5}, {119, 27} })
local LS = snow({33.5, 1.5}, nil, 10, 26, 41):clip(L)
local MS = snow({74.5, -1}, nil, 8, 65, 84):clip(M)
local RS = snow({108, 9.5}, nil, 14, 103, 113):clip(R)

c:part(L, GV.ramp("#968f96"))
c:part(LS, "cream", { outline = false, contour = false, gloss = false, contact = false })
c:part(R, GV.ramp("#968f96"))
c:part(RS, "cream", { outline = false, contour = false, gloss = false, contact = false })

c:part(M, GV.ramp("#6a6070"))
c:part(MS, "cream", { outline = false, contour = false, gloss = false, contact = false })

local back = hill(function(x) return 29 - 2.2 * math.sin(x / 13 + 0.6) end)
c:part(back, "moss", { gloss = false })
local front = hill(function(x) return 34.5 - 1.8 * math.sin(x / 10 + 2.2) - (x > 70 and (x - 70) * 0.03 or 0) end)
c:part(front, GV.ramp("#58a03e"), { gloss = false })

-- spice crop rows (left/mid field)
local cols = { "#d6322b", "#e8a317", "#e0501f" }
local rows = { 31, 35, 37 }
for r, y in ipairs(rows) do
  for i = 0, 7 do
    local x = 4 + i * 8 + (r % 2) * 4
    if x + 5 <= 68 then
      local col = cols[((i + r) % 3) + 1]
      for dx = 0, 5 do
        local yy = y
        if not front:has(x + dx, yy) and not back:has(x + dx, yy) then yy = yy + 1 end
        c:px(x + dx, yy, col)
      end
    end
  end
end

-- bunting: sagging line with five flags
local pts = {}
for i = 0, 43 do
  local t = i / 43
  pts[#pts+1] = { 10 + i, math.floor(8 - 0 * t + 4 * math.sin(t * math.pi) + 0.5) }
end
for _, p in ipairs(pts) do c:px(p[1], p[2], "#2a1a10") end
local fl = { "#d6322b", "#e8a317", "#58a03e", "#3f93b2", "#e46a9b" }
for i = 1, 5 do
  local p = pts[i * 7 + 1]
  local x, y = p[1], p[2] + 1
  c:paint({ "aaa", "aaa", ".a." }, x - 1, y, { a = fl[i] })
end

-- hem stitch top and bottom
c:seam({ {0, 1}, {119, 1} }, { free = true })
c:seam({ {0, 38}, {119, 38} }, { free = true })

local t = c:save(O .. "aseprite/ph/banner-csa.aseprite", O .. "png/ph/banner-csa.png")
print(GV.report(t))

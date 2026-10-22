local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local W, H = 120, 40
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1 }

-- wavy band from a top edge function down to the bottom
local function band(top)
  local m = c:mask()
  for x = 0, W - 1 do
    for y = math.floor(top(x) + 0.5), H - 1 do m:set(x, y) end
  end
  return m
end

-- sky (two hard bands, pale)
c:part(c:rect(0, 0, W-1, H-1), "#a9d6ea", { flat = true, rim = false, outline = false, contact = false })
c:bands(c:rect(0, 0, W-1, 9), { "#bfe2f0" })

-- clouds: flat-bottomed
local cl1 = c:ellipse(30, 6.5, 8, 2.5):add(c:ellipse(26, 5, 4, 2)):cut(c:rect(0, 8, W-1, H-1))
local cl2 = c:ellipse(70, 7.5, 6, 2):add(c:ellipse(72, 6, 3, 1.5)):cut(c:rect(0, 9, W-1, H-1))
c:part(cl1, "#f4f0e0", { flat = true, contact = false })
c:part(cl2, "#f4f0e0", { flat = true, contact = false })

-- far hills
local hills = band(function(x) return 20 + 2.2 * math.sin(x / 9.0) + 1.2 * math.sin(x / 4.1 + 1) end)
c:part(hills, "moss", { cres = 0, deep = 0, gloss = false, contact = false })

-- birch trees: x, height, base y
local trees = {
  { 9, 16, 28 }, { 24, 12, 28 }, { 40, 9, 27 }, { 58, 17, 29 },
  { 75, 8, 28 }, { 92, 18, 28 }, { 109, 12, 27 },
}
for i, t in ipairs(trees) do
  local x, h, by = t[1], t[2], t[3]
  local top = by - h
  local trunk = c:rect(x, top, x + 1, by)
  c:part(trunk, "#f4f0e0", { flat = true, contact = false, contour = false })
  -- bark ticks
  local ys = { top + 3, top + math.floor(h * 0.55), by - 3 }
  for j, ty in ipairs(ys) do c:px(x + ((i + j) % 2), ty, "#2a1a10") end
  local ry = (h >= 13) and 4.5 or 4
  local crown = c:ellipse(x + 0.5, top - 2, (h >= 13) and 4 or 3.5, ry)
  c:part(crown, "#b0bc66", { cres = 2, deep = 1, contact = false, gloss = false })
  c:px(x - 2, top - 4, "#e4eaa8")
end

-- golden steppe
local steppe = band(function(x) return 26 + 0.8 * math.sin(x / 7 + 2) end)
c:part(steppe, "#f5cf6a", { cres = 0, deep = 0, gloss = false, rim = false, contact = false })

-- near moss strip
local near = band(function(x) return 33 + 1.3 * math.sin(x / 6.5) end)
c:part(near, "#b0bc66", { cres = 0, deep = 0, gloss = false, contact = false })

-- grass tufts: "v" ticks, uneven spacing
for i = 0, 7 do
  local x = 6 + i * 15 + ((i % 3) - 1) * 2
  local y = 36 + (i % 2)
  c:px(x, y, "#b07a10"); c:px(x + 2, y, "#b07a10"); c:px(x + 1, y + 1, "#b07a10")
end
-- dry grass dashes on the steppe
for i = 0, 10 do
  local x = 4 + i * 11 + (i % 2) * 3
  c:px(x, 29 + (i % 2), "#d0862a"); c:px(x + 1, 29 + (i % 2), "#d0862a")
end

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(O .. "aseprite/ph/banner-ee.aseprite", O .. "png/ph/banner-ee.png")
print(GV.report(t))

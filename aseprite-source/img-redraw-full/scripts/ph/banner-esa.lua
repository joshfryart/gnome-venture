local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local W, H = 120, 40
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1, cres = 2, deep = 1 }

-- wavy band: top edge = base + a*sin, extends past the frame so edges never shade
local function band(base, a, f, ph)
  local m = c:mask()
  for x = -8, W + 7 do
    local top = math.floor(base + a * math.sin(x * f + ph) + 0.5)
    for y = top, H + 7 do m:set(x, y) end
  end
  return m
end
-- flat-topped acacia canopy: wide oval with the top sliced flat
local function canopy(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  m:add(c:rect(math.floor(cx - rx + 2), math.floor(cy - ry), math.ceil(cx + rx - 2), math.floor(cy)))
  return m
end

-- sky: hard bands
c:bands(c:rect(0, 0, W - 1, 14), { "#f5cf6a", "#f2b04a" })
c:fill(c:rect(0, 15, W - 1, H - 1), "#f08a24")
c:fill(c:rect(0, 7, W - 1, 14), "#f5b850")

local sun = c:ellipse(60, 18, 9, 9)
local core = c:ellipse(60, 18, 5, 5)
c:part(sun, "#e0501f", { gloss = false, bounce = false, cres = 2 })
c:part(core, "#f5cf6a", { outline = false, flat = true, rim = false, contour = false, contact = false })
-- sun rays: short hard ticks
for _, d in ipairs({ { -13, 0 }, { 13, 0 }, { -10, -9 }, { 10, -9 } }) do
  c:fill(c:rect(60 + d[1] - (d[1] < 0 and 1 or 0), 18 + d[2], 60 + d[1] + (d[1] > 0 and 1 or 0), 18 + d[2]), "#e0501f")
end

c:part(band(24.5, 1.5, 0.09, 0.5), "#a5663a", { gloss = false, bounce = false })
c:part(band(27, 1.2, 0.13, 2.0), "#e8a317", { gloss = false, bounce = false })
c:part(band(31, 1.0, 0.17, 1.0), "#b0bc66", { gloss = false, bounce = false })

-- acacias: forked 2px trunks + flat canopies (three sizes)
local wood = "#44281c"
local function tree(cx, cy, rx, ry, foot)
  local tr = c:line({ { cx, foot }, { cx, cy + 2 } }, 2)
  tr:add(c:line({ { cx, cy + 4 }, { cx - math.floor(rx / 2), cy + 1 } }, 1))
  tr:add(c:line({ { cx + 1, cy + 4 }, { cx + math.floor(rx / 2), cy + 1 } }, 1))
  c:part(tr, wood, { flat = true, rim = false })
  local cp = canopy(cx, cy, rx, ry)
  c:part(cp, "#2e5a2c", { gloss = false, bounce = false, cres = 2, deep = 1 })
  -- small pale gloss on the lit upper-left
  c:px(math.floor(cx - rx + 3), math.floor(cy - ry) + 1, "#c8d77a")
  c:px(math.floor(cx - rx + 4), math.floor(cy - ry) + 1, "#a4b86a")
end
tree(24, 23, 8, 2.5, 33)
tree(96, 22, 10, 3, 35)
tree(80, 26, 5, 1.6, 31)

c:part(band(36, 0.8, 0.11, 3.0), "#e8a317", { gloss = false, bounce = false })
-- grass tufts on the foreground lip
for _, x in ipairs({ 8, 33, 51, 70, 88, 109 }) do
  c:px(x, 34, "#7ab55c"); c:px(x + 1, 33, "#7ab55c"); c:px(x + 2, 34, "#7ab55c")
end

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(O .. "aseprite/ph/banner-esa.aseprite", O .. "png/ph/banner-esa.png")
print(GV.report(t))

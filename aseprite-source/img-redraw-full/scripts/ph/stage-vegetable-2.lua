local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- lens-shaped leaf from base (x0,y0) to tip (x1,y1), half-width w
local function leaf(x0, y0, x1, y1, w)
  local dx, dy = x1 - x0, y1 - y0
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local a, b = {}, {}
  for i = 0, 12 do
    local t = i / 12
    local o = w * math.sin(math.pi * t ^ 0.8)
    local px, py = x0 + dx * t, y0 + dy * t
    a[#a + 1] = { px + nx * o, py + ny * o }
    table.insert(b, 1, { px - nx * o, py - ny * o })
  end
  for _, p in ipairs(b) do a[#a + 1] = p end
  return c:poly(a)
end

local mound = c:ellipse(32, 48.5, 21, 8)
local top = c:ellipse(32, 46.5, 16, 4)
local p = c:build{
  { "mound", mound, "#8c4a1a" },
  { "top", top, "#a5663a", { flat = true, contour = false, contact = false } },
  { "lleaf", leaf(31, 46, 13, 32, 5), "#7ab55c" },
  { "rleaf", leaf(33, 46, 51, 32, 5), "#7ab55c" },
  { "cleaf", leaf(32, 47, 32, 22, 5.5), "#58a03e" },
}
-- midribs
c:fill(c:line({ {32, 44}, {32, 29} }, 1), GV.ramp("#58a03e").shade)
c:fill(c:line({ {28, 42}, {19, 36} }, 1), GV.ramp("#7ab55c").shade)
c:fill(c:line({ {36, 42}, {45, 36} }, 1), GV.ramp("#7ab55c").shade)
-- a few soil crumbs
c:paint({ "s......s.........s" }, 23, 50, { s = GV.ramp("#8c4a1a").deep })

local t = c:save(O .. "aseprite/ph/stage-vegetable-2.aseprite", O .. "png/ph/stage-vegetable-2.png")
print(GV.report(t))

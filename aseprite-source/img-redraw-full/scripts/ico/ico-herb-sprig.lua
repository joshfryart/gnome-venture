local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- leaf polygon from base (bx,by) to tip (tx,ty), half-width hw at the belly
local function leaf(bx, by, tx, ty, hw)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local a, b = {}, {}
  local N = 12
  for i = 0, N do
    local t = i / N
    local w = hw * math.sin(math.pi * (t ^ 0.8)) ^ 0.9
    local px, py = bx + dx * t, by + dy * t
    a[#a + 1] = { px + nx * w, py + ny * w }
    table.insert(b, 1, { px - nx * w, py - ny * w })
  end
  for _, p in ipairs(b) do a[#a + 1] = p end
  return c:poly(a)
end

local leafR = GV.ramp("#58a03e")
local stemR = GV.ramp("#2e5a2c")

local stem = c:rrect(30, 18, 33, 51, 1)
local p = c:build{
  { "stem", stem, stemR },
  { "ll", leaf(32, 46, 13, 36, 4.2), leafR },
  { "lr", leaf(32, 46, 50, 36, 4.2), leafR },
  { "ml", leaf(32, 34, 15, 25, 3.8), leafR },
  { "mr", leaf(32, 34, 48, 25, 3.8), leafR },
  { "top", c:ellipse(31.5, 20, 4.5, 6.5):cut(c:rect(0, 0, 63, 15)):add(c:poly({ {28, 16}, {36, 16}, {32, 11} })), leafR },
}
-- veins
local function vline(pts) for i = 1, #pts - 1 do
  local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for k = 0, n do c:px(math.floor(x0 + (x1 - x0) * k / n + 0.5), math.floor(y0 + (y1 - y0) * k / n + 0.5), "#2e5a2c") end
end end
vline({ {29, 44}, {18, 38} })
vline({ {35, 44}, {46, 38} })
vline({ {29, 32}, {19, 27} })
vline({ {35, 32}, {44, 27} })
vline({ {32, 24}, {32, 15} })

local t = c:save(O .. "aseprite/ico/ico-herb-sprig.aseprite", O .. "png/ico/ico-herb-sprig.png")
print(GV.report(t))

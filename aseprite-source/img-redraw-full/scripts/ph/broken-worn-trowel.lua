local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- teardrop along an axis: pointed at (x0,y0), rounded at (x1,y1)
local function tear(x0, y0, x1, y1, wmax, k)
  local dx, dy = x1 - x0, y1 - y0
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local nx, ny = -uy, ux
  local L1, L2 = {}, {}
  local N = 24
  for i = 0, N do
    local t = i / N
    local f
    if t < k then f = math.sin(t / k * math.pi / 2)
    else local q = (t - k) / (1 - k); f = math.sqrt(math.max(0, 1 - q * q)) end
    local cx, cy = x0 + dx * t, y0 + dy * t
    L1[#L1 + 1] = { cx + nx * wmax * f, cy + ny * wmax * f }
    table.insert(L2, 1, { cx - nx * wmax * f, cy - ny * wmax * f })
  end
  for _, p in ipairs(L2) do L1[#L1 + 1] = p end
  return c:poly(L1)
end

local function pill(x0, y0, x1, y1, r)
  local m = c:mask()
  for i = 0, 12 do
    local t = i / 12
    m:add(c:ellipse(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, r))
  end
  return m
end

local handle = pill(43, 42, 51, 51, 4.5)
-- splinter: a bite out of the handle's upper-right side
handle:cut(c:poly({ { 50, 44 }, { 54, 46 }, { 52, 49 } }))
local ferrule = pill(37.5, 37.5, 41, 41, 3.5)
local blade = tear(13, 10, 39, 37, 12.5, 0.62)
-- chipped notch on the upper-right edge
blade:cut(c:poly({ { 33, 15 }, { 38, 18 }, { 35, 22 } }))
local chip = c:poly({ { 6, 41 }, { 13, 39 }, { 10, 46 } })

local p = c:build{
  { "handle", handle, GV.ramp("#b6814d") },
  { "ferrule", ferrule, GV.ramp("#968f96") },
  { "blade", blade, GV.ramp("#8c4a1a") },
  { "chip", chip, GV.ramp("#8c4a1a"), { gloss = false } },
}

-- lit stripe on the handle's upper-left edge
c:fill(c:line({ { 41, 43 }, { 47, 50 } }, 1):clip(p.handle.m), "#f0d49a")
-- loose splinter sticking out of the handle
c:fill(c:line({ { 51, 47 }, { 54, 44 } }, 2), "#d9a660")
c:px(54, 44, "#ecc58a")

-- rust patches (flat, darker)
local rust = c:ellipse(22, 27, 2.5, 1.5):add(c:ellipse(31, 33, 2, 1.5)):add(c:ellipse(26, 21, 1.5, 1))
c:fill(rust:clip(p.blade.m), "#5e2f1e")

-- dark zigzag crack across the blade and into the neck
local crack = c:line({ { 24, 13 }, { 28, 22 }, { 23, 27 }, { 31, 34 }, { 37, 38 } }, 2)
c:fill(crack:clip(p.blade.m:copy():add(p.ferrule.m)), "#2a1a10")

local t = c:save(O .. "aseprite/ph/broken-worn-trowel.aseprite", O .. "png/ph/broken-worn-trowel.png")
print(GV.report(t))

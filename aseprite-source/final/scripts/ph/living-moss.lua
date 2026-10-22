local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- leaf-shaped frond from pivot (px,py) at angle a (deg from vertical), length L, half-width hw
local function frond(px, py, a, L, hw)
  local r = math.rad(a)
  local dx, dy = math.sin(r), -math.cos(r)
  local nx, ny = -dy, dx
  local pts = {}
  local N = 28
  for i = 0, N - 1 do
    local t = i / N * 2 * math.pi
    local u = (1 - math.cos(t)) / 2 * L        -- 0..L along axis
    local w = math.sin(t) * hw * (0.55 + 0.45 * math.sin(math.pi * u / L)) -- pointed ends
    pts[#pts + 1] = { px + dx * u + nx * w + 0.5, py + dy * u + ny * w + 0.5 }
  end
  return c:poly(pts)
end

local stem = c:line({ { 31, 34 }, { 31, 53 } }, 3)
local p = c:build{
  { "stem",   stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "outerL", frond(31.5, 35, -66, 21, 5), "#6a9a3a", { gloss = false } },
  { "outerR", frond(31.5, 35, 66, 21, 5), "#6a9a3a", { gloss = false } },
  { "midL",   frond(31.5, 34, -33, 21, 5), "#7ab55c", { gloss = false } },
  { "midR",   frond(31.5, 34, 33, 21, 5), "#7ab55c", { gloss = false } },
  { "top",    frond(31.5, 34, 0, 22, 5.5), "moss" },
  { "bud",    c:ellipse(31.5, 33.5, 5, 5), GV.ramp("#7b66b4", { shade = "#3e2f66", deep = "#291d4a" }), { gloss = { 29, 31 } } },
}
-- mid-ribs on the fronds (1 px dark vein accents)
local function rib(a, L, hex)
  local r = math.rad(a)
  for u = 8, L - 4 do
    local x = math.floor(31.5 + math.sin(r) * u + 0.5)
    local y = math.floor(34 - math.cos(r) * u + 0.5)
    c:px(x, y, hex)
  end
end
rib(-66, 19, "#4a8a3e"); rib(66, 19, "#4a8a3e")
rib(-33, 19, "#4a8a3e"); rib(33, 19, "#4a8a3e")
rib(0, 20, "#2f5a2a")
c:px(34, 36, "#a894dc")
local t = c:save(D .. "img-redraw-full/aseprite/ph/living-moss.aseprite", D .. "img-redraw-full/png/ph/living-moss.png")
print(GV.report(t))

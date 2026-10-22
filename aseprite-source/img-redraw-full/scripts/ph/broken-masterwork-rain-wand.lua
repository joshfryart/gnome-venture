-- ph/broken-masterwork-rain-wand : snapped star wand
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- full shaft, then snap it along a zig-zag
local shaft = c:line({ {18, 49}, {38, 21} }, 5)
local crack = c:line({ {25, 30}, {26, 34}, {30, 32}, {30, 37}, {35, 35} }, 2)
shaft:cut(crack)
-- split into halves by flood fill
local function comp(m, sx, sy)
  local out, st, seen = c:mask(), { { sx, sy } }, {}
  while #st > 0 do
    local p = table.remove(st)
    local k = p[1] * 1000 + p[2]
    if not seen[k] and m:has(p[1], p[2]) then
      seen[k] = true; out:set(p[1], p[2])
      st[#st + 1] = { p[1] + 1, p[2] }; st[#st + 1] = { p[1] - 1, p[2] }
      st[#st + 1] = { p[1], p[2] + 1 }; st[#st + 1] = { p[1], p[2] - 1 }
    end
  end
  return out
end
local low = comp(shaft, 19, 48)
local up = comp(shaft, 37, 22):shift(2, -1)
-- chips at both ends
low:cut(c:poly({ {16, 44}, {19, 46}, {16, 48} }))
up:cut(c:poly({ {41, 24}, {43, 27}, {44, 23} }))

-- star
local pts = {}
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and 8.5 or 4
  pts[#pts + 1] = { 43 + r * math.cos(a), 19 + r * math.sin(a) }
end
local star = c:poly(pts)

-- raindrop beads
local function drop(x, y)
  return c:ellipse(x, y, 2.5, 2.5):add(c:poly({ {x - 2, y - 1}, {x + 0.5, y - 5}, {x + 3, y - 1} }))
end

local wood = GV.ramp("#b6814d", { rim = "#f0d49a" })
local bead = GV.ramp("#a9d6ea")
c:build{
  { "low", low, wood },
  { "up", up, wood },
  { "star", star, "gold" },
  { "b1", drop(22.5, 33), bead, { flat = false } },
  { "b2", drop(27.5, 25), bead },
}
-- loose splinter
c:build{ { "chip", c:poly({ {35, 41}, {39, 40}, {38, 43} }), wood, { flat = true } } }

local t = c:save(O .. "aseprite/ph/broken-masterwork-rain-wand.aseprite", O .. "png/ph/broken-masterwork-rain-wand.png")
print(GV.report(t))

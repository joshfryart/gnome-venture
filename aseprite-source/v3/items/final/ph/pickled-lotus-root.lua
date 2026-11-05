-- pickled-lotus-root (lean E2_05)
local NAME = "pickled-lotus-root"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function P(x, y, col) c:put(x, y, col) end
local function RC(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function dome(m, ramp, R, name, o) local n = X.pillow(m, R) local t = { tok = { r = { name = name } }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 } if o then for k, v in pairs(o) do t[k] = v end end G.toneN(c, m, n, ramp, t) return n end
local R = { "#70405a", "#a06a80", "#cf96a2", "#e8bab6", "#f6d8cc", "#fff2e4" }
c:groundShadow(30, 57, 26, 3)
local function slice(cx, cy, r, name)
  local m = c:ellipse(cx, cy, r, r - 1)
  dome(m, R, r * 0.9, name, { amb = 0.2, wrap = 0.4 })
  -- scalloped rim shading, inner ring line
  local ring = m:shrink(2):edge()
  ring:each(function(x, y) if x + y > cx + cy then P(x, y, R[3]) else P(x, y, R[5]) end end)
  local holes = { { cx, cy, r * 0.17, r * 0.15 } }
  for i = 0, 5 do local a = i * pi / 3 + 0.3 holes[#holes + 1] = { cx + cos(a) * r * 0.55, cy + sin(a) * r * 0.5, r * 0.19, r * 0.17 } end
  for _, h in ipairs(holes) do
    local hm = c:ellipse(floor(h[1] + .5), floor(h[2] + .5), h[3], h[4])
    hm:each(function(x, y)
      local up = not hm:has(x - 1, y - 1) or not hm:has(x, y - 1)
      local lo = not hm:has(x + 1, y + 1) and not hm:has(x, y + 1)
      P(x, y, up and "#3c1c34" or lo and "#d8a0a4" or "#5a2c48")
    end)
  end
  return m
end
slice(44, 24, 12, "back")
slice(27, 38, 17, "front")
-- crunchy pickle speckle on front slice
for y = 22, 54 do for x = 11, 44 do
  if X.hash(x, y, 9) > 0.985 then P(x, y, R[2]) end
end end
-- chili ring quirk tucked on the slice
local ch = c:ellipse(40, 49, 4, 4)
local chn = X.pillow(ch, 3)
G.toneN(c, ch, chn, { "#5a0e18", "#8e1424", "#c4222c", "#e8483a", "#f58a5a", "#ffc890" }, { tok = { r = { name = "chili" } }, cuts = { .18, .34, .5, .66, .82 } })
local hole = c:ellipse(40, 49, 1, 1)
hole:each(function(x, y) P(x, y, "#4a1020") end)
P(38, 47, "#fff0d0")
G.save(c, NAME)

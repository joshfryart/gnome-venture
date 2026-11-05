-- pickled-lotus-root (lean P1b_O6)
local NAME = "pickled-lotus-root"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function line(pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
local function paint(m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, ramp, o) return n, v end

local PINK = { "#4d1b3c", "#7c2a55", "#aa3c6a", "#d2588a", "#ec86a8", "#f8c0ca" }
local RIND = { "#4a2a2e", "#7a4a46", "#a87258", "#cfa27a", "#e6c8a0" }
local HOLE = { "#2a0f24", "#431832", "#6c2850" }
local function slice(cx, cy, rx, ry, th, holes, hr)
  local top = c:ellipse(cx, cy, rx, ry)
  local side = top:copy():shift(0, th):add(top):cut(top)
  c:groundShadow(cx + 1, cy + ry + th + 1, rx - 2, 2)
  paint(side, RIND, 4, { amb = 0.2 })
  -- body light on the face
  paint(top, PINK, 12, { amb = 0.1, wrap = 0.3 })
  -- rim lip
  top:copy():shrink(1):edge():each(function(x, y) if x + y < cx + cy then c:px(x, y, PINK[6]) end end)
  local list = { { 0, 0, hr * 1.05 } }
  for i = 0, 5 do local a = i * pi / 3 + 0.5 list[#list + 1] = { cos(a) * rx * 0.55, sin(a) * ry * 0.55, hr } end
  for _, h in ipairs(list) do
    local hm = c:ellipse(cx + h[1], cy + h[2], h[3], h[3] * 0.9)
    hm:each(function(x, y) local d = (x - (cx + h[1])) + (y - (cy + h[2]))
      c:px(x, y, d < -1 and HOLE[1] or HOLE[2]) end)
    hm:copy():shrink(1):each(function(x, y) end)
    -- lit lower-right rim of each hole
    c:px(floor(cx + h[1] + h[3]), floor(cy + h[2] + 1), PINK[6])
    c:px(floor(cx + h[1] + h[3] - 1), floor(cy + h[2] + h[3] * 0.9), PINK[5])
    c:px(floor(cx + h[1] - 1), floor(cy + h[2]), HOLE[3])
  end
  return top
end
local back = slice(22, 22, 13, 11.5, 3, true, 2.1)
local front = c:ellipse(36, 37, 17, 14.5)
-- separate the front slice from the back one
front:copy():grow(1):cut(front):each(function(x, y) if back:has(x, y) then c:px(x, y, PINK[1]) end end)
slice(36, 37, 17, 14.5, 4, true, 2.9)
-- brine sheen
c:px(26, 31, "#fff6ee") c:px(27, 31, "#fff6ee") c:px(25, 32, PINK[6]) c:px(28, 30, PINK[6])
-- stringy lotus fibres (quirk)
line(c, { {47,48},{50,52},{49,56},{52,58} }, RIND[5])
line(c, { {45,50},{46,54},{45,57} }, RIND[4])
G.save(c, NAME)

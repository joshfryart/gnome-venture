local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 100, h = 100, mode = "scene", out = 2 }
local W, H = 100, 100

-- sky: hard stepped bands
c:bands(c:rect(0, 0, W - 1, 45), { "#e8f4d0", "#dcefc2", "#cfe8b2", "#c3e0a0" }, { dir = "v" })

-- clouds (flat felt puffs)
local function cloud(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  m:add(c:ellipse(cx - rx * 0.35, cy - ry * 0.9, rx * 0.45, ry * 0.9))
  m:add(c:ellipse(cx + rx * 0.25, cy - ry * 1.1, rx * 0.4, ry * 1.1))
  c:fill(m, "#f1ece0")
  -- shaded underside
  local under = m:copy():cut(m:shift(0, -1))
  c:fill(under, "#d8dcc0")
  local top = m:copy():cut(m:shift(0, 1))
  c:fill(top, "#fff6e4")
end
cloud(20, 12, 13, 3)
cloud(75, 18, 15, 4)

-- wavy hill helper: fills from wavy top down to bottom, with darker lip
local function hill(base, amp, f1, ph, col, lip)
  local m = c:mask()
  local topy = {}
  for x = 0, W - 1 do
    local t = math.floor(base + amp * math.sin(x * f1 + ph) + 0.5 * amp * math.sin(x * f1 * 2.3 + ph * 1.7) + 0.5)
    topy[x] = t
    for y = t, H - 1 do m:set(x, y) end
  end
  c:fill(m, col)
  for x = 0, W - 1 do
    c:px(x, topy[x], lip)
    -- step pixel so the lip is continuous on slopes
    if x > 0 and topy[x - 1] < topy[x] - 1 then
      for y = topy[x - 1] + 1, topy[x] - 1 do c:px(x, y, lip) end
    elseif x > 0 and topy[x - 1] > topy[x] + 1 then
      for y = topy[x] + 1, topy[x - 1] - 1 do c:px(x - 1, y, lip) end
    end
  end
  return topy
end

local far = hill(29.5, 1.6, 0.09, 0.4, "#a9d27a", "#8fbd62")
-- far hill highlight band just below lip
local mid = hill(48, 2.0, 0.075, 2.1, "#98c768", "#7eb052")
local near = hill(68, 2.0, 0.065, 4.0, "#86b95a", "#6c9f46")

-- far-ridge tufts (5x7 triangles)
for _, tx in ipairs({ 22, 50, 81 }) do
  local ty = far[tx]
  c:fill(c:poly({ { tx - 2.5, ty + 1 }, { tx, ty - 6 }, { tx + 2.5, ty + 1 } }), "#6f9f48")
  c:px(tx - 1, ty - 2, "#8fbd62")
end

-- grass blades from bottom edge (curved tufts)
local function tuft(x)
  local pts = {
    { { x, 99 }, { x - 1, 95 }, { x - 3, 92 } },
    { { x + 1, 99 }, { x + 1, 93 }, { x + 2, 90 } },
    { { x + 2, 99 }, { x + 4, 95 }, { x + 6, 93 } },
  }
  for _, p in ipairs(pts) do
    c:fill(c:line(p, 1), "#6aa046")
  end
end
for _, x in ipairs({ 6, 30, 49, 66, 93 }) do tuft(x) end

-- daisies: 5 white petals, gold centre
local function daisy(cx, cy)
  c:fill(c:line({ { cx, cy + 2 }, { cx, cy + 8 } }, 1), "#5f9a3e")
  local pet = c:mask()
  for i = 0, 4 do
    local a = -math.pi / 2 + i * 2 * math.pi / 5
    pet:add(c:ellipse(cx + math.cos(a) * 2.2, cy + math.sin(a) * 2.2, 1.4, 1.4))
  end
  c:fill(pet, "#f7f2e6")
  c:fill(pet:copy():cut(pet:shift(-1, -1)), "#d9d2c0")
  c:fill(c:rect(cx - 1, cy - 1, cx, cy), "#f6c844")
  c:px(cx, cy, "#d0862a")
end
daisy(17, 75)
daisy(75, 85)

-- tulip buds on stems
local function tulip(x, y)
  c:fill(c:line({ { x, y + 1 }, { x, y + 7 } }, 1), "#5f9a3e")
  c:px(x + 1, y + 5, "#5f9a3e"); c:px(x + 2, y + 4, "#5f9a3e")
  c:fill(c:ellipse(x, y, 1.5, 1.5), "#f2a1bd")
  c:px(x + 1, y + 1, "#d9708f"); c:px(x, y + 1, "#d9708f")
  c:px(x - 1, y - 1, "#fbd0de")
end
tulip(43, 84); tulip(54, 77); tulip(89, 74)

-- sparkles
c:px(35, 20, "#fff6b0"); c:px(36, 20, "#fff6b0")
c:px(65, 38, "#fff6b0")
c:px(9, 45, "#fff6b0"); c:px(9, 44, "#fff6b0")
c:px(93, 50, "#fff6b0")

-- hem stitch along the bottom edge
c:seam({ { 1, 98 }, { 98, 98 } }, { free = true })

local t = c:save(B .. "img-redraw-full/aseprite/gather/net-bg.aseprite", B .. "img-redraw-full/png/gather/net-bg.png")
print(GV.report(t))

local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 120, h = 40, mode = "scene", out = 2 }
local W, H = 120, 40
local floor = math.floor
local function px(x, y, hex) if x >= 0 and x < W and y >= 0 and y < H then c:px(x, y, hex) end end
local function lerp(pts, x)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    if x >= a[1] and x <= b[1] then
      local t = (x - a[1]) / math.max(1, b[1] - a[1])
      t = t * t * (3 - 2 * t)            -- smooth dune curve
      return a[2] + (b[2] - a[2]) * t
    end
  end
  return pts[#pts][2]
end

-- sky
c:fill(c:rect(0, 0, W - 1, H - 1), "#f4f0e0")
c:fill(c:rect(0, 0, W - 1, 14), "#f5cf6a")
c:fill(c:rect(0, 0, W - 1, 6), "#f0bf52")

-- sun
c:fill(c:ellipse(93, 10, 6), "#f08a24")
c:fill(c:ellipse(93, 10, 4), "#f5cf6a")
c:fill(c:ellipse(92, 9, 2), "#fff1c8")

-- far dune
local far = {}
for x = 0, W - 1 do far[x] = floor(19 + 3 * math.abs(x - 60) / 60 + 0.5) end
for x = 0, W - 1 do
  c:fill(c:rect(x, far[x], x, H - 1), "#f5cf6a")
  px(x, far[x], "#e8a317")
end

-- mid dune (gold) with lee-side shade and ridge line
local midP = { {0, 31}, {30, 24}, {37, 24}, {75, 32}, {112, 24}, {119, 26} }
local mid = {}
for x = 0, W - 1 do mid[x] = floor(lerp(midP, x) + 0.5) end
for x = 0, W - 1 do c:fill(c:rect(x, mid[x], x, H - 1), "#e8a317") end
-- lee shade: right of each crest, a wedge under the ridge
local function lee(cx, cy, x1, slope)
  for x = cx + 1, x1 do
    local depth = floor((x - cx) * slope)
    for y = mid[x] + 1, math.min(H - 1, mid[x] + depth) do px(x, y, "#d0862a") end
  end
end
lee(37, 24, 62, 0.35)
lee(112, 24, 119, 0.5)
for x = 0, W - 1 do px(x, mid[x], "#b07a10") end
for x = 31, 36 do px(x, mid[x] + 1, "#f5cf6a") end   -- sunlit crest glint

-- near dune
local near = {}
for x = 0, W - 1 do
  near[x] = floor(35 + 1.6 * math.sin((x + 8) / 11) + 0.6 * math.sin(x / 5) + 0.5)
  if x >= 18 and x <= 42 then near[x] = math.min(near[x], 33) end
end
for x = 0, W - 1 do
  c:fill(c:rect(x, near[x], x, H - 1), "#f5cf6a")
  px(x, near[x], "#e8a317")
end

-- oasis pool
c:fill(c:ellipse(30, 33.5, 6, 1.5), "#3f8fb0")
for x = 25, 35 do px(x, 35, "#2f6290") end
px(27, 33, "#c8ecdc"); px(28, 33, "#c8ecdc"); px(32, 34, "#8fcbd8")
-- grass tufts by the pool
c:paint({ "g.g", ".g." }, 22, 33, { g = "#4a8a3e" })
c:paint({ "g.g", ".g." }, 37, 33, { g = "#4a8a3e" })

-- palms
local function palm(trunk, cx, cy, s)
  c:fill(c:line(trunk, 2), "#c4925f")
  -- trunk rings
  local tm = c:line(trunk, 2)
  tm:each(function(x, y) if y % 2 == 0 and not tm:has(x + 1, y) then px(x, y, "#8a4f2a") end end)
  local fr = {
    { {cx, cy}, {cx - 4*s, cy - 1}, {cx - 7*s, cy + 1}, {cx - 8*s, cy + 3} },
    { {cx, cy}, {cx + 4*s, cy - 1}, {cx + 7*s, cy + 1}, {cx + 8*s, cy + 3} },
    { {cx, cy}, {cx - 3*s, cy - 3*s}, {cx - 5*s, cy - 3*s} },
    { {cx, cy}, {cx + 3*s, cy - 3*s}, {cx + 5*s, cy - 3*s} },
    { {cx, cy}, {cx - 3*s, cy + 2}, {cx - 4*s, cy + 4*s} },
  }
  for _, f in ipairs(fr) do
    for i, p in ipairs(f) do f[i] = { floor(p[1] + 0.5), floor(p[2] + 0.5) } end
    local m = c:line(f, 2)
    c:fill(m, "#58a03e")
    m:each(function(x, y) if not m:has(x, y + 1) and x > cx then px(x, y, "#3e7a2e") end end)
    m:each(function(x, y) if not m:has(x, y - 1) and x <= cx then px(x, y, "#8cc85a") end end)
  end
  -- dates
  px(cx, cy + 2, "#8a4f2a"); px(cx + 1, cy + 2, "#a8582f"); px(cx + 1, cy + 3, "#8a4f2a")
end
palm({ {35, 33}, {34, 29}, {34, 26}, {35, 23} }, 35, 22, 0.7)
palm({ {23, 34}, {23, 29}, {24, 24}, {26, 19} }, 26, 18, 1)

-- hem stitch, top and bottom
for x = 0, W - 1 do
  if x % 3 ~= 2 then px(x, 1, "#fff1c8"); px(x, H - 2, "#e8a317") end
end

local t = c:save(D .. "img-redraw-hybrid/aseprite/ph/banner-mena.aseprite",
                 D .. "img-redraw-hybrid/png/ph/banner-mena.png")
print(GV.report(t))

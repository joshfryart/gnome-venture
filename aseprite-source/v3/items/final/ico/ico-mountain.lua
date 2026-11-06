-- ico-mountain (Opus single pass). Two slim peaks: a tall front peak and a lower one behind it to the right, on a
-- short meadow band. Rock is faceted: each peak has a lit west face, a mid face and a deep east face (planar normals
-- with chunky 3 px block jitter, quantised to a 6-tone cool-violet stone ramp), strata cracks with a lit lip,
-- ambient occlusion where the front peak overlaps the back one and under the snow lip. Snow caps: 6-tone blue-white
-- ramp with toothed lower edge and drips down the gullies, one specular glint on the summit.
-- quirk: a small cloud has snagged on the back peak and wraps it like a scarf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-mountain")
local ST = { "#332f50", "#4d4870", "#6b6489", "#8b84a4", "#aea6c0", "#d0cadb" }
local SN = { "#55639a", "#7f8fc6", "#a9b9e4", "#cfdcf4", "#e8eefb", "#f8faff" }
local GR = { "#24544a", "#2f7450", "#3f9150", "#5fae55", "#86c75e", "#b8de76" }
local SKY = { "#6f8fc8", "#9fbfe6", "#c8e2f6", "#e4f3fd" }
local function nrm(a, b, cc) local l = sqrt(a*a + b*b + cc*cc) return { a / l, b / l, cc / l } end
local BASE = 52

-- peak: apex, base x0..x1; ridge goes from apex to (rx, BASE); west ridge splits the lit side
local function peak(ax, ay, x0, x1, rx, wx, snowY, o)
  local m = c:poly{ { ax, ay }, { x1, BASE }, { x0, BASE } }
  -- slightly convex flanks: nibble 1 px steps so the sides are not ruler-straight
  local n, face = {}, {}
  m:each(function(x, y)
    local t = (y - ay) / (BASE - ay)
    local ridge = ax + (rx - ax) * t + ((floor(y / 4) % 2 == 0) and 0 or 1)
    local west = ax + (wx - ax) * t
    local cell = X.hash(floor(x / 3), floor(y / 3), o.seed) - 0.5
    local cell2 = X.hash(floor(x / 3) + 7, floor(y / 3), o.seed) - 0.5
    local f
    if x > ridge then f = 3 elseif x < west then f = 1 else f = 2 end
    local base = (f == 1) and { -0.72, -0.25, 0.65 } or (f == 2) and { -0.18, -0.2, 0.96 } or { 0.62, -0.22, 0.75 }
    n[K(x, y)] = nrm(base[1] + cell * 0.3, base[2] + cell2 * 0.25, base[3])
    face[K(x, y)] = f
  end)
  -- snow mask: above a toothed snow line plus drips down the gullies
  local snow = HP.mask()
  m:each(function(x, y)
    local tooth = ({ 0, 2, 3, 2, 0, -1 })[(x + o.seed) % 6 + 1]
    local sy = snowY + tooth
    if y <= sy then snow:set(x, y) end
  end)
  for _, d in ipairs(o.drips or {}) do
    for yy = 0, d[3] do
      for xx = 0, (yy < d[3] - 1) and 2 or 1 do if m:has(d[1] + xx, d[2] + yy) then snow:set(d[1] + xx, d[2] + yy) end end
    end
  end
  return m, n, face, snow
end

local m2, n2, f2, s2 = peak(45, 20, 31, 57, 47, 41, 26, { seed = 3, drips = { { 44, 28, 3 } } })
local m1, n1, f1, s1 = peak(24, 8, 7, 45, 29, 17, 20, { seed = 1, drips = { { 22, 22, 6 }, { 15, 25, 4 }, { 31, 24, 3 } } })
m2:cut(m1)
local rockTok2, rockTok1 = { r = { name = "rock2" } }, { r = { name = "rock1" } }
local snowTok = { r = { name = "snow" } }
local CUT = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local function paintPeak(m, n, face, snow, other, tokR, extraBias)
  local rock = m:copy():cut(snow)
  local sn = snow:copy():clip(m)
  local bias = extraBias or {}
  -- AO under the snow lip (2 rows)
  for i = 1, 2 do sn:shift(0, i):each(function(x, y) if rock:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - (3 - i) * 0.5 end end) end
  for k, b in pairs(bias) do bias[k] = floor(b) end
  local v = X.light(n, { amb = 0.05, wrap = 0.15 })
  local idx = X.tone(c, rock, v, ST, { cuts = CUT, bias = bias, tok = tokR })
  local sb = {}
  sn:each(function(x, y) local k = K(x, y) if face[k] == 3 then sb[k] = -1 end end)
  X.tone(c, sn, v, SN, { cuts = { 0.15, 0.3, 0.48, 0.62, 0.8 }, bias = sb, tok = snowTok })
  return rock, idx, v
end

-- back peak: AO where the front peak overlaps it
local ao2 = {}
X.ao(ao2, m2, m1, 3, -1)
local rock2, idx2 = paintPeak(m2, n2, f2, s2, m1, rockTok2, ao2)
local rock1, idx1 = paintPeak(m1, n1, f1, s1, nil, rockTok1, {})

-- strata cracks (dark groove + lit lip below on lit faces)
local cracks = {
  { { 12, 38 }, { 15, 37 }, { 18, 39 }, { 21, 38 } },
  { { 19, 30 }, { 22, 31 }, { 25, 30 } },
  { { 9, 46 }, { 13, 45 }, { 16, 46 } },
  { { 24, 43 }, { 27, 42 }, { 30, 44 }, { 33, 43 } },
  { { 34, 36 }, { 37, 37 }, { 39, 36 } },
  { { 38, 44 }, { 41, 45 } },
  { { 49, 38 }, { 52, 39 }, { 54, 41 } },
  { { 36, 32 }, { 39, 33 } },
}
local function seg(pts, f)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local nstep = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for j = 0, nstep do
      local x = floor(a[1] + (b[1] - a[1]) * j / nstep + .5)
      local y = floor(a[2] + (b[2] - a[2]) * j / nstep + .5)
      f(x, y)
    end
  end
end
for _, cr in ipairs(cracks) do
  seg(cr, function(x, y)
    local rock, idx, tok = rock1, idx1, rockTok1
    if not rock1:has(x, y) then rock, idx, tok = rock2, idx2, rockTok2 end
    if rock:has(x, y) then
      local i = idx[K(x, y)] or 3
      c:put(x, y, ST[max(1, i - 2)], tok)
      if rock:has(x, y + 1) and i >= 3 then c:put(x, y + 1, ST[min(6, i + 1)], tok) end
    end
  end)
end
-- the deep ridge line on the front peak (east face meets mid face): a 1 px darker seam on the upper half
for y = 21, 40 do
  local t = (y - 8) / (BASE - 8)
  local x = floor(24 + (29 - 24) * t + ((floor(y / 4) % 2 == 0) and 0 or 1) + 1)
  if rock1:has(x, y) then c:put(x, y, ST[2], rockTok1) end
end
-- summit glint
c:put(22, 11, SN[6], snowTok) c:put(23, 10, A.CR, snowTok) c:put(21, 12, SN[6], snowTok)

-- meadow band along the foot (front of both peaks), wavy top
local mead = HP.mask()
for x = 6, 58 do
  local top = BASE - 2 - ((x % 7 < 3) and 1 or 0) - ((x % 11 == 5) and 1 or 0)
  for y = top, BASE + 2 do
    if x >= 7 and x <= 57 then mead:set(x, y) end
  end
end
mead:cut(c:rect(4, BASE - 4, 4, BASE + 2)):cut(c:rect(60, BASE - 4, 60, BASE + 2))
-- round the ends
for _, p in ipairs{ { 7, BASE - 3 }, { 7, BASE - 2 }, { 57, BASE - 3 }, { 57, BASE - 2 }, { 7, BASE + 2 }, { 57, BASE + 2 } } do mead:cut(HP.mask():set(p[1], p[2])) end
local nm = X.pillow(mead, 2)
local gb = {}
mead:each(function(x, y)
  local k = K(x, y)
  if X.hash(x, y, 9) > 0.8 then gb[k] = -1 end
  if (rock1:has(x, y - 1) or rock2:has(x, y - 1)) and not (rock1:has(x, y) or rock2:has(x, y)) then gb[k] = (gb[k] or 0) end
end)
-- contact shadow: rock pixels just above the grass darken
mead:each(function(x, y) for dy = 1, 1 do
  if not mead:has(x, y - dy) then
    local r, idx, tok = nil, nil, nil
    if rock1:has(x, y - dy) then r, idx, tok = rock1, idx1, rockTok1 elseif rock2:has(x, y - dy) then r, idx, tok = rock2, idx2, rockTok2 end
    if r then c:put(x, y - dy, ST[max(1, (idx[K(x, y - dy)] or 3) - 1)], tok) end
  end end end)
A.litN(mead, nm, GR, { amb = 0.1, wrap = 0.3, bias = gb, tok = { r = { name = "grass" } } })
-- grass blade tufts poking up
for _, x in ipairs{ 10, 20, 34, 47, 54 } do
  local y0
  for y = BASE - 6, BASE + 2 do if mead:has(x, y) then y0 = y break end end
  if y0 then c:px(x, y0 - 1, GR[5]) c:px(x + 1, y0 - 1, GR[4]) c:px(x, y0 - 2, GR[5]) end
end

-- quirk: cloud scarf snagged on the back peak
local cl = c:ellipse(49, 39, 5.5, 2.5):add(c:ellipse(44, 40, 3.5, 2)):add(c:ellipse(54, 40.5, 3, 2)):add(c:ellipse(47, 37, 3, 2.5)):add(c:ellipse(52, 37.5, 2.5, 2))
cl:cut(m1)
local cn = X.pillow(cl, 2.5)
-- contact shadow under the cloud on the rock
cl:shift(0, 2):each(function(x, y) if rock2:has(x, y) and not cl:has(x, y) then c:put(x, y, ST[2], rockTok2) end end)
A.litN(cl, cn, { "#7fb0dc", "#a8d6f0", "#d2eefb", "#fff4d6", "#fffbea" }, { amb = 0.15, wrap = 0.35, cuts = { 0.22, 0.42, 0.62, 0.82 }, tok = { r = { name = "cloud" } } })
A.done()

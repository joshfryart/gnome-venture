-- Blossomreach (East Asia: Japan/Korea) - gate view town scene, Hearth Pop v3, 480x270 native.
-- Single self-contained script. Run:
-- AppRun -b --script-param out=<dir>/ --script here-town-blossomreach.lua
local SRC = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(SRC .. "/../../lib/hp.lua")
local OUT = app.params.out or (SRC .. "/")
if OUT:sub(-1) ~= "/" then OUT = OUT .. "/" end
local NAME = "here-town-blossomreach"
local W, H, HZ, VX = 480, 270, 112, 240
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }

-- ---------- helpers ----------
local function hsh(x, y, s)
  local n = (x * 73856093) ~ (y * 19349663) ~ ((s or 0) * 83492791)
  n = (n ~ (n >> 13)) * 1274126177
  n = n ~ (n >> 16)
  return (n & 0xffff) / 65535
end
local function P(x, y, col) c:put(floor(x), floor(y), col) end
local function F(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function fill(m, col) c:fillMask(m, col) end
local function each(m, fn) m:each(fn) end
local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function hex(r, g, b)
  r = max(8, min(247, floor(r))); g = max(8, min(247, floor(g))); b = max(8, min(247, floor(b)))
  return string.format("#%02x%02x%02x", r, g, b)
end
-- cool-violet shade of an existing colour
local function shade(h, f)
  f = f or .74
  local r, g, b = rgb(h)
  return hex(r * f * .92 + 6, g * f * .86, b * f + 22)
end
local function shadeMask(m, f)
  each(m, function(x, y) local o = c:get(x, y) if o then c:put(x, y, shade(o, f)) end end)
end
-- warm glow tint of existing colour
local function warm(h)
  local r, g, b = rgb(h)
  return hex(r * 1.08 + 18, g * 1.04 + 10, b * .9)
end
local function poly(pts) return c:poly(pts) end
local function rect(a, b, cc, d) return c:rect(a, b, cc, d) end
local function ell(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function tone4(m, R, cx, cy, rx, ry, seed)
  -- R = {deep, shade, base, hi}; light from upper-left, noise texture
  each(m, function(x, y)
    local nx, ny = (x - cx) / max(1, rx), (y - cy) / max(1, ry)
    local l = .55 - nx * .35 - ny * .5 + (hsh(x, y, seed or 1) - .5) * .45
    local col = l > .78 and R[4] or (l > .42 and R[3] or (l > .12 and R[2] or R[1]))
    c:put(x, y, col)
  end)
end

-- ---------- palettes ----------
local INK = "#2b1c26"
local SAK = { "#b4527e", "#e38fb0", "#f6bdd0", "#ffe2ec" }  -- cherry blossom
local SAK2 = { "#a8507a", "#d985a8", "#efb0c8", "#fcd6e4" }
local VER = { "#6e2038", "#b02f2f", "#e0452f", "#f57a4f" }  -- vermilion
local TIMB = { "#2e1d22", "#4a2f2e", "#634036", "#7e5642" }  -- dark timber
local PLAS = { "#c9b393", "#e2cfb0", "#f3e6cf", "#fbf3e3" }
local MOSS = { "#2f5a3a", "#4f8a45", "#7cb65a", "#b4d97a" }
local STN  = { "#5c5a72", "#8a8798", "#b1adb8", "#d8d3d8" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- ---------- sky (spring morning, pink-gold) ----------
c:stripes(0, HZ, { "#8fbde6", "#a7cbec", "#c3d6ee", "#dcd5ea", "#efd2e0", "#f9d4d4", "#fcdcc4", "#fde6b8" },
  { 3, 3, 3, 2, 2, 2, 2, 2 })
-- soft sun glow (stepped bands, no circle): low warm plates behind far hills
for i = 0, 5 do F(318 - i * 6, 70 + i * 4, 362 + i * 6, 112, ({ "#fff0c4", "#feebbc", "#fde6b8", "#fde2b4", "#fcdcb8", "#fbd8bc" })[i + 1]) end
c:cloud(36, 44, 54, "#fff4f2", "#f2c4d4")
c:cloud(78, 52, 34, "#fff4f2", "#f2c4d4")
c:cloud(286, 30, 60, "#fff4f2", "#f2c4d4")
c:cloud(338, 40, 30, "#fff4f2", "#f2c4d4")
c:cloud(160, 60, 40, "#fdeef0", "#efc0d0")
c:cloud(400, 58, 44, "#fdeef0", "#efc0d0")

-- far mountains (lavender) with snow-tipped ridges
local mt1 = c:terrain(function(x) return 66 + 14 * sin(x / 37) + 8 * sin(x / 13 + 1) + abs(x - 250) * .06 end, "#b7a8d8", HZ)
c:terrain(function(x) return 70 + 14 * sin(x / 37) + 8 * sin(x / 13 + 1) + abs(x - 250) * .06 + 4 end, "#a898cc", HZ)
each(mt1, function(x, y)
  local top = 66 + 14 * sin(x / 37) + 8 * sin(x / 13 + 1) + abs(x - 250) * .06
  if y <= top + 1 and top < 66 then c:put(x, y, "#ece6f6") end
end)
-- mid hills, green-violet with blossom specks
local hill = c:terrain(function(x) return 92 + 6 * sin(x / 21 + 2) + 4 * sin(x / 9) end, "#8ea684", HZ)
each(hill, function(x, y)
  local hv = hsh(x, y, 7)
  if hv > .86 then c:put(x, y, "#e7a6c0") elseif hv < .12 then c:put(x, y, "#748f73") end
end)
-- distant pagoda (five tiers) behind the far street
do
  local px = 262
  for t = 0, 4 do
    local y = 58 + t * 10
    local w = 8 + t * 2
    local rm = poly{ { px - w - 3, y + 6 }, { px - w + 1, y + 3 }, { px + w - 1, y + 3 }, { px + w + 3, y + 6 }, { px + w + 2, y + 7 }, { px - w - 2, y + 7 } }
    fill(rm, "#7d6aa6")
    F(px - w + 3, y + 8, px + w - 3, y + 12, "#a48fc4")
    F(px - w + 3, y + 8, px - w + 4, y + 12, "#c3b0dc")
  end
  F(px - 1, 46, px, 60, "#7d6aa6")
  for i = 0, 3 do P(px - 2, 49 + i * 3, "#7d6aa6"); P(px + 1, 49 + i * 3, "#7d6aa6") end
end

-- ---------- ground ----------
F(0, HZ + 1, W - 1, H - 1, "#9cc56e")
for y = HZ + 1, H - 1 do for x = 0, W - 1 do
  local hv = hsh(x, y, 3)
  if hv > .9 then P(x, y, "#b8d986") elseif hv < .08 then P(x, y, "#86b35e")
  elseif hv > .885 and not (x >= 380 and y >= 230) then P(x, y, "#f3b9cc") end
end end
-- grass blade ticks
for i = 1, 520 do
  local x, y = floor(hsh(i, 1, 11) * W), HZ + 4 + floor(hsh(i, 2, 11) * (H - HZ - 5))
  if not (x >= 380 and y >= 230) then P(x, y, "#6f9a52"); P(x, y - 1, "#86b35e") end
end
-- paved plaza / street in perspective
local plaza = poly{ { 224, HZ }, { 256, HZ }, { 306, 132 }, { 336, 160 }, { 344, 206 }, { 372, 269 }, { 104, 269 }, { 140, 206 }, { 146, 160 }, { 174, 132 } }
local STONES = { "#cfc4b8", "#c2b8b2", "#d9cfc2", "#bdb4b8", "#d3c7bd", "#c8bfbf" }
each(plaza, function(x, y)
  local dy = y - (HZ - 4)
  local z = 1800 / dy
  local row = floor(z)
  local fz = z - row
  local u = (x - VX) / dy * 22 + ((row % 2 == 0) and .5 or 0)
  local col = floor(u)
  local fu = u - col
  local hv = hsh(col, row, 5)
  local base = STONES[1 + floor(hv * #STONES) % #STONES]
  local edgeY = 1800 / (dy * dy) -- one pixel in z units
  local cfr = dy / 22             -- pixels per u unit
  if dy < 22 then
    c:put(x, y, (hsh(x, y, 9) > .7) and "#b9afb2" or "#cdc3ba")
  elseif fz < edgeY * 1.0 or fu < 1 / cfr then
    c:put(x, y, "#8e8396")
  elseif fz < edgeY * 2 or fu < 2 / cfr then
    c:put(x, y, warm(base))
  else
    local n = hsh(x, y, 8)
    c:put(x, y, n > .93 and "#e6ddd2" or (n < .05 and "#a99fa8" or base))
  end
end)
-- plaza border kerb
fill(c:rim(plaza, "#8e8396"), "#8e8396")

-- ---------- generic Japanese building ----------
local function roof(o)
  -- o: x0,x1,yTop,yEave,ov,R={deep,shade,base,hi}
  local L, Rr = o.x0 - o.ov, o.x1 + o.ov
  local h = o.yEave - o.yTop
  local inset = floor(h * 1.0)
  local m = HP.mask()
  local up = {}
  for x = L, Rr do
    local de = min(x - L, Rr - x)
    local u = 0
    if de < 7 then u = floor((7 - de) ^ 2 / 14) end
    up[x] = u
    local yb = o.yEave - u
    local yt
    if de >= inset then yt = o.yTop else yt = floor(o.yEave - 2 - (o.yEave - 2 - o.yTop) * (de / inset) ^ 1.5) - u end
    for y = yt, yb do m:set(x, y) end
  end
  local mid = (L + Rr) / 2
  each(m, function(x, y)
    local k = (x - L) % 4
    local course = (y - o.yTop) % 5 == 4
    local right = x > mid + (Rr - mid) * .35
    local col
    if k == 0 then col = right and o.R[3] or o.R[4] elseif k == 3 then col = o.R[2] else col = right and o.R[2] or o.R[3] end
    if course then col = o.R[2] end
    if hsh(x, y, 21) > .95 then col = o.R[4] end
    c:put(x, y, col)
  end)
  -- eave tile ends
  for x = L, Rr do
    local yb = o.yEave - up[x]
    P(x, yb, o.R[1]); P(x, yb - 1, (x - L) % 4 == 0 and o.R[4] or o.R[2])
  end
  c:edgeIn(m, o.R[1])
  -- ridge with up-curled ends
  local rx0, rx1 = L + inset - 3, Rr - inset + 3
  F(rx0, o.yTop - 3, rx1, o.yTop, o.R[1])
  F(rx0 + 1, o.yTop - 2, rx1 - 1, o.yTop - 2, o.R[2])
  F(rx0 - 1, o.yTop - 6, rx0 + 1, o.yTop - 1, o.R[1]); P(rx0 - 2, o.yTop - 6, o.R[1])
  F(rx1 - 1, o.yTop - 6, rx1 + 1, o.yTop - 1, o.R[1]); P(rx1 + 2, o.yTop - 6, o.R[1])
  P(rx0, o.yTop - 5, o.R[3]); P(rx1, o.yTop - 5, o.R[3])
  return m, L, Rr, inset
end
local function wall(x0, y0, x1, y1, panel, timber, bay)
  F(x0, y0, x1, y1, panel[3])
  for y = y0, y1 do for x = x0, x1 do
    local hv = hsh(x, y, 31)
    if hv > .92 then P(x, y, panel[2]) elseif hv < .05 then P(x, y, panel[4]) end
  end end
  for x = x0, x1, bay do F(x, y0, min(x1, x + 2), y1, timber[2]); P(x, y0, timber[1]); F(x, y0, x, y1, timber[3]) end
  F(x1 - 2, y0, x1, y1, timber[1])
  F(x0, y0, x1, y0 + 2, timber[2]); F(x0, y0 + 2, x1, y0 + 2, timber[1])
  F(x0, y1 - 1, x1, y1, timber[1])
end
-- side wall receding toward the vanishing point; dir = +1 (side to the right of x) or -1
local function sideWall(x, yT, yB, d, dir, col, lines)
  local k = d / abs(VX - x)
  local x2 = x + dir * d
  local pts = { { x, yT }, { x2, floor(yT + (HZ - yT) * k) }, { x2, floor(yB + (HZ - yB) * k) }, { x, yB } }
  local m = poly(pts)
  fill(m, col)
  if lines then each(m, function(px, py) if (px - x) % 4 == 0 then c:put(px, py, lines) end end) end
  c:edgeIn(m, INK)
  return m
end
local function shadowUnder(x0, x1, yb, dx, hh)
  local m = poly{ { x0 + 2, yb + 1 }, { x1 + dx, yb + 1 }, { x1 + dx + 4, yb + hh }, { x0 + 8, yb + hh } }
  shadeMask(m, .76)
end
local function paperLantern(x, y, w, h, body, glow)
  -- rounded paper lantern, top-left x,y
  F(x + 1, y - 2, x + w - 2, y - 1, TIMB[1])
  P(x + floor(w / 2), y - 4, TIMB[2]); P(x + floor(w / 2), y - 3, TIMB[2])
  local m = c:rrect(x, y, x + w - 1, y + h - 1, 2)
  fill(m, body[3])
  for yy = y + 1, y + h - 2, 2 do F(x + 1, yy, x + w - 2, yy, body[2]) end
  F(x + 1, y + 1, x + 2, y + h - 3, glow)
  P(x + 2, y + 2, "#fff4d8")
  c:edgeIn(m, body[1])
  F(x + 1, y + h, x + w - 2, y + h + 1, TIMB[1])
  P(x + floor(w / 2), y + h + 2, GOLD[2]); P(x + floor(w / 2), y + h + 3, GOLD[3])
  -- warm glow specks around
  for i = 0, 5 do
    local gx, gy = x - 2 + floor(hsh(i, x, 41) * (w + 4)), y - 1 + floor(hsh(i, y, 42) * (h + 4))
    local o = c:get(gx, gy)
    if o and not m:has(gx, gy) then c:put(gx, gy, warm(o)) end
  end
end

-- ---------- cherry trees ----------
local function trunk(pts, w, colA, colB)
  local m = c:line(pts, w)
  fill(m, colA or TIMB[2])
  each(m, function(x, y) if not m:has(x - 1, y) then c:put(x, y, colB or TIMB[4]) end end)
  c:edgeIn(m, TIMB[1])
  each(m, function(x, y) if not m:has(x - 1, y) and not m:has(x, y - 1) then c:put(x, y, colB or TIMB[4]) end end)
  return m
end
local function canopy(clumps, R, seed)
  local all = HP.mask()
  for i, cl in ipairs(clumps) do
    local m = ell(cl[1], cl[2], cl[3], cl[4])
    tone4(m, R, cl[1] - cl[3] * .2, cl[2] - cl[4] * .2, cl[3], cl[4], (seed or 0) + i)
    -- clump underside line
    each(m, function(x, y) if not m:has(x, y + 1) and not all:has(x, y + 1) then c:put(x, y, R[1]) end end)
    all:add(m)
  end
  -- flower dots
  each(all, function(x, y)
    local hv = hsh(x, y, 61 + (seed or 0))
    if hv > .965 then c:put(x, y, "#fff2f5") elseif hv < .025 then c:put(x, y, R[2]) end
  end)
  c:edgeIn(all, R[1])
  return all
end
local function sakura(x, yb, s, R, seed)
  local h = floor(24 * s)
  trunk({ { x, yb }, { x - 1, yb - floor(h * .5) }, { x + 2, yb - h } }, max(3, floor(4 * s)))
  trunk({ { x - 1, yb - floor(h * .55) }, { x - floor(10 * s), yb - h - 2 } }, 2)
  trunk({ { x + 1, yb - floor(h * .7) }, { x + floor(11 * s), yb - h - 4 } }, 2)
  local cy = yb - h - floor(6 * s)
  canopy({
    { x - floor(14 * s), cy + floor(3 * s), floor(10 * s), floor(7 * s) },
    { x + floor(14 * s), cy + floor(2 * s), floor(10 * s), floor(7 * s) },
    { x - floor(5 * s), cy - floor(6 * s), floor(11 * s), floor(8 * s) },
    { x + floor(7 * s), cy - floor(5 * s), floor(10 * s), floor(8 * s) },
    { x, cy + floor(4 * s), floor(13 * s), floor(7 * s) },
  }, R, seed)
end

-- far trees flanking the end of the street
sakura(206, 110, 1.15, SAK2, 3)
sakura(286, 108, 1.0, SAK2, 4)
-- distant low roofs at the street end
for _, r in ipairs{ { 226, 98, 238 }, { 244, 100, 256 } } do
  fill(poly{ { r[1] - 3, r[2] + 4 }, { r[1], r[2] }, { r[3], r[2] }, { r[3] + 3, r[2] + 4 } }, "#6d5f8e")
  F(r[1], r[2] + 5, r[3], 111, "#c9b9d6"); F(r[1] + 3, r[2] + 7, r[1] + 5, 110, "#8c7aa8"); F(r[3] - 5, r[2] + 7, r[3] - 3, 110, "#fbe0b0")
end
-- big decorative sakura far left (not a spot)
sakura(54, 128, 1.45, SAK, 5)

-- ================= SPOT: LIBRARY (left far) =================
do
  local x0, x1, yb, yW = 100, 166, 124, 94
  shadowUnder(x0, x1, yb, 14, 7)
  sideWall(x1 + 1, yW, yb, 10, 1, "#7e6a78", "#6a5466")
  local LIB = { "#232a4c", "#3d4670", "#56628f", "#8592c0" }
  -- side roof
  fill(poly{ { x1 + 6, yW }, { x1 + 16, yW + 3 }, { x1 + 12, 72 }, { x1 - 6, 68 } }, LIB[2])
  wall(x0, yW, x1, yb, PLAS, TIMB, 16)
  -- open front with bookshelves
  F(x0 + 8, 103, x1 - 10, yb - 2, TIMB[1])
  local spine = { "#b02f2f", "#3a86b0", "#f5b82e", "#3f9150", "#8a6fd0", "#e8493b", "#5fc4c8", "#c94f84" }
  for sy = 104, yb - 6, 6 do
    F(x0 + 9, sy + 5, x1 - 11, sy + 5, TIMB[3])
    local x = x0 + 9
    while x < x1 - 11 do
      local w = 1 + floor(hsh(x, sy, 71) * 2)
      local h = 3 + floor(hsh(sy, x, 72) * 2)
      local col = spine[1 + floor(hsh(x, sy, 73) * #spine)]
      F(x, sy + 5 - h, min(x1 - 11, x + w - 1), sy + 4, col)
      P(x, sy + 5 - h, warm(col))
      x = x + w + (hsh(x, sy, 74) > .8 and 2 or 0)
    end
  end
  -- door frame posts
  F(x0 + 6, 102, x0 + 8, yb, TIMB[2]); F(x1 - 10, 102, x1 - 8, yb, TIMB[2])
  -- roof
  roof{ x0 = x0, x1 = x1, yTop = 70, yEave = 96, ov = 7, R = LIB }
  -- big open-book sign on the gable
  local bx, by = 118, 74
  F(bx - 1, by + 1, bx + 30, by + 16, "#8a2a2e")      -- cover
  fill(poly{ { bx, by + 2 }, { bx + 14, by }, { bx + 14, by + 14 }, { bx, by + 15 } }, "#fbf1dc")
  fill(poly{ { bx + 15, by }, { bx + 29, by + 2 }, { bx + 29, by + 15 }, { bx + 15, by + 14 } }, "#efe0c4")
  for i = 0, 4 do F(bx + 2, by + 4 + i * 2, bx + 12, by + 4 + i * 2, "#a8865e"); F(bx + 17, by + 4 + i * 2, bx + 27, by + 4 + i * 2, "#a8865e") end
  F(bx + 14, by, bx + 15, by + 15, "#6e2038")
  F(bx + 22, by - 2, bx + 23, by + 3, "#e0452f")   -- ribbon bookmark
  P(bx + 22, by + 4, "#f5809f")                   -- petal bookmark tip
  c:edgeIn(rect(bx - 1, by - 1, bx + 30, by + 16):cut(rect(bx + 14, by - 1, bx + 15, by - 1)), INK)
  -- lantern
  paperLantern(x1 - 6, 98, 6, 9, { "#2a4a7a", "#3a86b0", "#cfe6f0" }, "#ffe38a")
  -- quirk: stack of books used as a step stool with a teacup on top
  F(x0 - 12, yb - 3, x0 - 2, yb, "#3a86b0"); F(x0 - 11, yb - 6, x0 - 3, yb - 4, "#b02f2f"); F(x0 - 12, yb - 9, x0 - 4, yb - 7, "#f5b82e")
  F(x0 - 8, yb - 12, x0 - 6, yb - 10, "#7cb65a")
  c:edgeIn(rect(x0 - 12, yb - 9, x0 - 2, yb), INK)
end

-- ================= SPOT: TEAHOUSE (right far) =================
do
  local x0, x1, yb, yW = 312, 378, 124, 96
  shadowUnder(x0, x1, yb, 10, 7)
  sideWall(x0 - 1, yW, yb, 10, -1, "#c2b27a", "#a8995e")
  local TEA = { "#21402c", "#3d6b45", "#58905a", "#8cbc78" }
  fill(poly{ { x0 - 6, yW }, { x0 - 16, yW + 3 }, { x0 - 12, 74 }, { x0 + 6, 70 } }, TEA[3])
  -- bamboo wall
  F(x0, yW, x1, yb, "#c9c06a")
  for x = x0, x1 do
    local k = (x - x0) % 4
    local col = k == 0 and "#e1d88a" or (k == 3 and "#8f8f46" or "#c0b85e")
    for y = yW, yb do
      local node = (y + (floor((x - x0) / 4) % 2) * 4) % 9 == 0
      P(x, y, node and "#7f7a3a" or col)
    end
  end
  F(x0, yW, x1, yW + 2, TIMB[2]); F(x0, yb - 1, x1, yb, TIMB[1])
  F(x0, yW, x0 + 2, yb, TIMB[2]); F(x1 - 2, yW, x1, yb, TIMB[1])
  -- doorway with green noren curtain
  F(x0 + 24, 104, x0 + 46, yb - 1, TIMB[1])
  F(x0 + 24, 104, x0 + 46, 113, "#3f9150")
  for x = x0 + 31, x0 + 39, 8 do F(x, 106, x, 113, "#24544a") end
  F(x0 + 24, 104, x0 + 46, 104, "#7cc35a")
  -- tiny bowl crest on the curtain
  F(x0 + 33, 108, x0 + 37, 109, "#f3e6cf"); F(x0 + 34, 110, x0 + 36, 110, "#f3e6cf")
  -- square shoji window
  F(x0 + 6, 102, x0 + 18, 114, "#fbf1dc")
  for i = 0, 3 do F(x0 + 6 + i * 4, 102, x0 + 6 + i * 4, 114, "#a8865e"); F(x0 + 6, 102 + i * 4, x0 + 18, 102 + i * 4, "#a8865e") end
  F(x0 + 7, 103, x0 + 9, 105, "#ffe38a")
  roof{ x0 = x0, x1 = x1, yTop = 72, yEave = 98, ov = 7, R = TEA }
  -- hanging sign: matcha bowl + whisk
  F(x1 - 20, 98, x1 - 20, 101, TIMB[1]); F(x1 - 4, 98, x1 - 4, 101, TIMB[1])
  local sm = rect(x1 - 23, 102, x1 - 1, 117)
  fill(sm, "#e8b982"); F(x1 - 22, 103, x1 - 2, 103, "#f5d6a8")
  local bowl = poly{ { x1 - 19, 108 }, { x1 - 5, 108 }, { x1 - 6, 112 }, { x1 - 9, 114 }, { x1 - 15, 114 }, { x1 - 18, 112 } }
  fill(bowl, "#5a3a3a"); F(x1 - 18, 109, x1 - 16, 110, "#8a5a50")
  F(x1 - 18, 107, x1 - 6, 108, "#7cc35a"); F(x1 - 16, 107, x1 - 14, 107, "#c4e07a")
  F(x1 - 4, 104, x1 - 3, 106, "#c9c06a")   -- whisk
  c:edgeIn(sm, TIMB[1])
  -- quirk: four seasonal wind chimes under the eave (spring, summer, autumn, winter)
  for i, col in ipairs{ "#f5809f", "#5fc4c8", "#e8493b", "#c9b2f0" } do
    local x = x0 + 4 + i * 5
    P(x, 99, TIMB[1]); F(x - 1, 100, x + 1, 102, col); P(x, 103, "#a8865e"); F(x, 104, x, 106, "#fbf1dc")
  end
  -- red parasol + bench outside (left)
  F(x0 - 26, 117, x0 - 6, 119, "#e0452f"); F(x0 - 26, 120, x0 - 6, 120, "#b02f2f")
  F(x0 - 24, 121, x0 - 23, 124, TIMB[2]); F(x0 - 9, 121, x0 - 8, 124, TIMB[2])
  F(x0 - 16, 96, x0 - 16, 116, TIMB[2])
  local um = poly{ { x0 - 16, 88 }, { x0 - 2, 98 }, { x0 - 30, 98 } }
  fill(um, "#e0452f")
  each(um, function(x, y) if x > x0 - 16 then c:put(x, y, "#b02f2f") end end)
  for i = -12, 12, 6 do P(x0 - 16 + i, 98, "#f5b82e") end
  c:edgeIn(um, VER[1])
  paperLantern(x0 + 52, 100, 6, 9, { "#24544a", "#3f9150", "#d8eec0" }, "#ffe38a")
end

-- ================= SPOT: WILD TRAIL (right edge) =================
do
  -- dark wild woods at the far right
  canopy({ { 452, 96, 14, 12 }, { 438, 104, 10, 9 }, { 460, 112, 10, 10 } }, { "#24544a", "#3f7a4a", "#5f9e58", "#8cc06c" }, 77)
  -- path leaving the picture to the right
  local path = poly{ { 336, 134 }, { 344, 126 }, { 420, 116 }, { 463, 112 }, { 463, 124 }, { 420, 128 } }
  fill(path, "#d9bf8f")
  each(path, function(x, y)
    local hv = hsh(x, y, 81)
    if hv > .9 then c:put(x, y, "#b89a6e") elseif hv < .06 then c:put(x, y, "#efdcb2") end
  end)
  c:edgeIn(path, "#a07e58")
  -- rustic arch of natural wood with blossom vine
  local ax0, ax1 = 412, 446
  F(ax0, 82, ax0 + 3, 124, "#7e5642"); F(ax0, 82, ax0, 124, "#a87a58")
  F(ax1, 82, ax1 + 3, 124, "#634036"); F(ax1, 82, ax1, 124, "#8a6046")
  local beam = poly{ { ax0 - 7, 76 }, { ax0 - 2, 78 }, { ax1 + 5, 78 }, { ax1 + 10, 76 }, { ax1 + 9, 81 }, { ax0 - 6, 81 } }
  fill(beam, "#7e5642"); F(ax0 - 4, 79, ax1 + 7, 79, "#a87a58")
  c:edgeIn(beam, TIMB[1])
  F(ax0 - 1, 86, ax1 + 4, 88, "#634036")
  c:edgeIn(rect(ax0, 82, ax0 + 3, 124), TIMB[1]); c:edgeIn(rect(ax1, 82, ax1 + 3, 124), TIMB[1])
  -- straw rope with paper streamers
  for x = ax0 + 4, ax1 - 1 do P(x, 90 + floor(2 * sin((x - ax0) / 34 * pi)), "#e8c87a") end
  for x = ax0 + 9, ax1 - 4, 8 do F(x, 92, x + 1, 96, "#fbf3e3"); P(x + 1, 97, "#e2cfb0") end
  canopy({ { ax0 + 2, 78, 6, 4 }, { ax1 + 2, 77, 6, 4 } }, SAK, 88)
  -- signpost with two arrows pointing right (leaf + mountain icons)
  F(398, 92, 400, 126, "#7e5642"); F(398, 92, 398, 126, "#a87a58"); c:edgeIn(rect(398, 92, 400, 126), TIMB[1])
  local a1 = poly{ { 392, 94 }, { 408, 94 }, { 412, 98 }, { 408, 102 }, { 392, 102 } }
  fill(a1, "#7cb65a"); c:edgeIn(a1, "#2f5a3a")
  F(398, 97, 402, 99, "#2f5a3a"); P(403, 97, "#2f5a3a")
  local a2 = poly{ { 393, 105 }, { 407, 105 }, { 411, 109 }, { 407, 113 }, { 393, 113 } }
  fill(a2, "#e8b982"); c:edgeIn(a2, "#864c33")
  fill(poly{ { 397, 111 }, { 400, 107 }, { 403, 111 } }, "#74758c"); P(400, 107, "#e2e0e6")
  -- quirk: a lone walking stick left leaning on the arch, with a hanging straw hat
  for i = 0, 18 do P(ax1 + 6 - floor(i / 6), 106 + i, "#a87a58") end
  fill(poly{ { ax1 + 1, 106 }, { ax1 + 6, 101 }, { ax1 + 11, 106 } }, "#e8c87a"); F(ax1 + 1, 106, ax1 + 11, 106, "#b89a6e")
end

-- ================= SPOT: SHOPS (left mid) =================
do
  local x0, x1, yb, yW = 28, 124, 202, 164
  shadowUnder(x0, x1, yb, 14, 8)
  sideWall(x1 + 1, yW, yb, 10, 1, "#7e6a78", "#6a5466")
  local SH = { "#4a2a2a", "#7a3e34", "#a2583f", "#cf8a62" }
  fill(poly{ { x1 + 6, yW }, { x1 + 16, yW + 2 }, { x1 + 12, 146 }, { x1 - 6, 142 } }, SH[2])
  wall(x0, yW, x1, yb, PLAS, TIMB, 48)
  -- left bay: seed shop, open front
  F(x0 + 4, 176, x0 + 44, yb - 1, TIMB[1])
  -- rack of seed packets
  local pk = { "#f5b82e", "#e8493b", "#7cc35a", "#8a6fd0", "#f5809f", "#5fc4c8" }
  for r = 0, 2 do for i = 0, 6 do
    local px, py = x0 + 6 + i * 5 + (r % 2), 178 + r * 6
    local col = pk[1 + (i + r * 2) % #pk]
    F(px, py, px + 3, py + 4, "#fbf1dc"); F(px, py + 2, px + 3, py + 4, col); P(px + 1, py + 1, col)
  end end
  -- counter with seed sacks
  F(x0 + 2, 195, x0 + 46, yb, "#864c33"); F(x0 + 2, 195, x0 + 46, 195, "#b97a4a")
  for i, s in ipairs{ { x0 + 6, "#e8c87a", "#c94f84" }, { x0 + 20, "#e8c87a", "#f5b82e" }, { x0 + 34, "#d9bf8f", "#3f9150" } } do
    local sm = c:rrect(s[1], 188, s[1] + 9, 196, 2)
    fill(sm, s[2]); F(s[1] + 6, 191, s[1] + 8, 195, "#b89a6e")
    F(s[1] + 2, 188, s[1] + 7, 189, s[3]); P(s[1] + 3, 188, "#fbf3e3")
    c:edgeIn(sm, "#7a5a3a")
  end
  -- orange noren across the opening
  F(x0 + 4, 172, x0 + 44, 178, "#e8833b")
  for x = x0 + 14, x0 + 34, 10 do F(x, 174, x, 178, "#a8522a") end
  F(x0 + 4, 172, x0 + 44, 172, "#f5b07a")
  -- hanging sprout sign on a bracket (seed shop icon)
  F(x0 - 4, 166, x0 + 4, 167, TIMB[1])
  local sg = rect(x0 - 8, 169, x0 + 6, 184)
  fill(sg, "#fbf1dc"); c:edgeIn(sg, TIMB[1])
  F(x0 - 1, 175, x0 - 1, 181, "#3f9150")
  fill(poly{ { x0 - 1, 176 }, { x0 - 6, 172 }, { x0 - 3, 177 } }, "#7cc35a")
  fill(poly{ { x0, 175 }, { x0 + 4, 171 }, { x0 + 2, 176 } }, "#7cc35a")
  F(x0 - 4, 181, x0 + 2, 182, "#864c33")
  -- right bay: stall, shutter half lowered (closed for the blossom picnic) - quirk
  F(x0 + 54, 172, x1 - 6, yb - 1, TIMB[1])
  for y = 172, 189, 3 do F(x0 + 54, y, x1 - 6, y + 1, "#b97a4a"); F(x0 + 54, y, x1 - 6, y, "#e8b982") end
  F(x0 + 56, 191, x1 - 8, 193, "#634036")
  for i = 0, 4 do F(x0 + 58 + i * 7, 194, x0 + 61 + i * 7, 199, ({ "#e8493b", "#f5b82e", "#7cc35a", "#f5809f", "#5fc4c8" })[i + 1]) end
  -- placard with blossom icon hanging on shutter
  local pl = rect(x0 + 66, 179, x0 + 80, 190)
  fill(pl, "#fbf1dc"); c:edgeIn(pl, "#7d2c5e")
  local fx, fy = x0 + 73, 184
  for _, d in ipairs{ { 0, -3 }, { -3, -1 }, { 3, -1 }, { -2, 2 }, { 2, 2 } } do
    F(fx + d[1] - 1, fy + d[2] - 1, fx + d[1] + 1, fy + d[2] + 1, "#f5809f")
  end
  P(fx, fy, "#f5b82e")
  -- roof
  roof{ x0 = x0, x1 = x1, yTop = 146, yEave = 166, ov = 6, R = SH }
  paperLantern(x0 + 48, 168, 6, 9, { "#6e2038", "#e0452f", "#ffd0a8" }, "#ffe38a")
  paperLantern(x1 - 4, 168, 6, 9, { "#6e2038", "#e0452f", "#ffd0a8" }, "#ffe38a")
end

-- ================= SPOT: BLOSSOM GROVE (right mid) =================
do
  -- picnic mats first (on grass)
  local m1 = poly{ { 348, 184 }, { 388, 182 }, { 394, 196 }, { 344, 197 } }
  each(m1, function(x, y) c:put(x, y, ((floor(x / 4) + floor(y / 3)) % 2 == 0) and "#e0452f" or "#fbe6dc") end)
  c:edgeIn(m1, "#8a2a2e")
  local m2 = poly{ { 404, 186 }, { 446, 185 }, { 452, 197 }, { 400, 198 } }
  each(m2, function(x, y) c:put(x, y, (floor(y / 2) % 2 == 0) and "#3a86b0" or "#7fb8d8") end)
  c:edgeIn(m2, "#2a4a7a")
  -- trees
  sakura(360, 186, 1.0, SAK, 21)
  sakura(404, 182, 1.1, SAK, 22)
  sakura(442, 186, .95, SAK, 23)
  -- stacked lacquer lunch boxes
  F(360, 188, 372, 190, "#b02f2f"); F(360, 191, 372, 193, "#2e1d22"); F(361, 186, 371, 187, "#e0452f")
  P(362, 186, "#f57a4f"); c:edgeIn(rect(360, 186, 372, 193), INK)
  -- tea flask + cups on blue mat
  F(420, 186, 424, 194, "#5fc4c8"); F(420, 186, 420, 194, "#b6f0e0"); F(421, 184, 423, 185, "#2a4a7a")
  c:edgeIn(rect(420, 184, 424, 194), "#2a4a7a")
  F(428, 191, 430, 193, "#f3e6cf"); F(433, 192, 435, 194, "#f3e6cf"); P(429, 191, "#7cc35a"); P(434, 192, "#7cc35a")
  -- quirk: a diamond kite tangled in the right tree
  local kt = poly{ { 452, 140 }, { 458, 146 }, { 452, 153 }, { 446, 146 } }
  fill(kt, "#f5b82e"); each(kt, function(x, y) if x > 452 then c:put(x, y, "#e8493b") end end)
  c:edgeIn(kt, "#8f4a1f")
  for i = 0, 8 do P(451 - floor(i / 3), 154 + i, i % 2 == 0 and "#3a86b0" or "#e8493b") end
end

-- ================= SPOT: MOSS GARDEN (centre square, hero) =================
do
  local bed = poly{ { 188, 152 }, { 292, 152 }, { 304, 162 }, { 304, 196 }, { 292, 206 }, { 188, 206 }, { 176, 196 }, { 176, 162 } }
  shadeMask(poly{ { 190, 206 }, { 296, 206 }, { 310, 198 }, { 310, 210 }, { 300, 212 }, { 196, 212 } }, .76)
  -- raked gravel
  each(bed, function(x, y)
    local wv = floor(y + 1.5 * sin(x / 7))
    c:put(x, y, (wv % 3 == 0) and "#cdbfa8" or ((hsh(x, y, 91) > .93) and "#fbf3e3" or "#ece2cc"))
  end)
  -- stone curb
  local curb = bed:copy():cut(bed:shrink(3))
  each(curb, function(x, y)
    local seam = (x % 9 == 0) or (y % 9 == 0)
    c:put(x, y, seam and STN[2] or ((hsh(x, y, 92) > .5) and STN[3] or STN[4]))
  end)
  c:edgeIn(bed, STN[1])
  each(bed:shrink(3):edge(), function(x, y) c:put(x, y, STN[2]) end)
  -- moss islands (the big green)
  local isl = {
    { 240, 176, 46, 16 }, { 198, 190, 16, 9 }, { 282, 190, 16, 9 }, { 214, 166, 14, 7 }, { 270, 165, 13, 7 },
  }
  local mossAll = HP.mask()
  for i, e in ipairs(isl) do
    local m = ell(e[1], e[2], e[3], e[4]):clip(bed:shrink(4))
    tone4(m, MOSS, e[1] - e[3] * .3, e[2] - e[4] * .4, e[3], e[4], 100 + i)
    mossAll:add(m)
  end
  each(mossAll, function(x, y) local hv = hsh(x, y, 93) if hv > .95 then c:put(x, y, "#d6ec9a") elseif hv < .03 then c:put(x, y, "#f6bdd0") end end)
  c:edgeIn(mossAll, MOSS[1])
  -- rocks
  for i, r in ipairs{ { 206, 182, 10, 7 }, { 272, 184, 9, 6 }, { 290, 172, 6, 5 } } do
    local m = poly{ { r[1] - r[3], r[2] + r[4] }, { r[1] - r[3] + 2, r[2] - 1 }, { r[1] - 2, r[2] - r[4] }, { r[1] + r[3] - 3, r[2] - r[4] + 2 }, { r[1] + r[3], r[2] + r[4] } }
    tone4(m, STN, r[1] - 2, r[2] - 2, r[3], r[4], 120 + i)
    each(m, function(x, y) if y == r[2] + r[4] then c:put(x, y, STN[1]) end end)
    -- moss cap
    F(r[1] - 3, r[2] - r[4] + 1, r[1] + 1, r[2] - r[4] + 2, MOSS[3]); P(r[1] - 2, r[2] - r[4] + 1, MOSS[4])
    c:edgeIn(m, "#3e3c55")
  end
  -- stepping stones
  for i, s in ipairs{ { 222, 200 }, { 232, 198 }, { 244, 199 }, { 256, 200 } } do
    local m = c:rrect(s[1], s[2], s[1] + 7, s[2] + 3, 1)
    fill(m, STN[3]); F(s[1] + 1, s[2], s[1] + 4, s[2], STN[4]); c:edgeIn(m, STN[1])
  end
  -- little pine on the left island
  trunk({ { 198, 186 }, { 196, 180 }, { 199, 175 } }, 2)
  canopy({ { 194, 175, 7, 3 }, { 201, 171, 6, 3 }, { 196, 168, 5, 2 } }, { "#1f4434", "#2f6a44", "#4f9a55", "#86c06c" }, 131)
  -- big stone lantern (centre)
  local SL = { "#4e5068", "#7c7d92", "#a6a5b4", "#cfcbd2" }
  local function blk(a, b, cc, d) local m = rect(a, b, cc, d) tone4(m, SL, a, b, cc - a + 1, d - b + 1, a + b) c:edgeIn(m, "#34364c") return m end
  blk(226, 170, 254, 175)
  blk(234, 150, 246, 170)
  F(236, 152, 236, 168, SL[4])
  blk(226, 145, 254, 150)
  blk(230, 132, 250, 145)
  -- glowing window
  F(235, 135, 245, 142, "#f5b82e"); F(236, 136, 240, 139, "#ffe38a"); F(241, 140, 244, 142, "#d98322")
  F(240, 135, 240, 142, "#8f4a1f")
  -- warm glow on the lantern's front stones
  for x = 230, 250 do for y = 143, 145 do local o = c:get(x, y) if o then c:put(x, y, warm(o)) end end end
  -- curved stone roof
  local rf = poly{ { 220, 132 }, { 224, 128 }, { 234, 122 }, { 246, 122 }, { 256, 128 }, { 260, 132 }, { 258, 133 }, { 222, 133 } }
  tone4(rf, SL, 232, 124, 20, 6, 140)
  P(219, 130, "#34364c"); P(261, 130, "#34364c")
  c:edgeIn(rf, "#34364c")
  F(238, 117, 242, 121, SL[3]); F(239, 115, 241, 116, SL[3]); P(238, 117, SL[4]); c:edgeIn(rect(238, 115, 242, 121), "#34364c")
  -- quirk: a little hat of fallen petals on the lantern roof
  for i = 0, 14 do
    local x = 228 + floor(hsh(i, 1, 141) * 24)
    local yy = 124 + floor(abs(x - 240) / 4)
    P(x, yy, (i % 3 == 0) and "#ffe2ec" or "#f5809f")
  end
  -- moss on the lantern base
  F(226, 174, 236, 175, MOSS[3]); F(246, 169, 254, 170, MOSS[2]); P(227, 173, MOSS[4])
  -- garden marker post with moss-leaf icon
  F(181, 166, 182, 186, "#7e5642"); c:edgeIn(rect(180, 166, 183, 186), TIMB[1])
  local tb = rect(176, 158, 190, 168)
  fill(tb, "#e8b982"); c:edgeIn(tb, "#864c33")
  fill(poly{ { 179, 166 }, { 183, 160 }, { 188, 161 }, { 186, 165 } }, "#4f8a45"); P(184, 162, "#b4d97a")
end

-- ================= SPOT: KOI POND (left near) with red bridge =================
do
  local pond = poly{ { 26, 234 }, { 44, 222 }, { 90, 217 }, { 128, 222 }, { 140, 238 }, { 130, 258 }, { 92, 265 }, { 40, 264 }, { 24, 252 } }
  -- stones rim
  local rimM = pond:grow(3):cut(pond)
  each(rimM, function(x, y)
    local cx, cy = floor(x / 6), floor(y / 4)
    local hv = hsh(cx, cy, 151)
    local col = hv > .66 and STN[4] or (hv > .33 and STN[3] or STN[2])
    if (x % 6 == 0) or (y % 4 == 0) then col = STN[1] end
    c:put(x, y, col)
  end)
  -- water (deep at back, lighter front)
  each(pond, function(x, y)
    local t = (y - 217) / 48
    local col = t < .25 and "#3a86b0" or (t < .6 and "#4f9fbe" or "#5fb4c8")
    local hv = hsh(x, y, 152)
    if (y + floor(x / 9)) % 6 == 0 and hv > .45 then col = "#9fdcdc" end
    if hv > .985 then col = "#f6bdd0" end
    c:put(x, y, col)
  end)
  each(pond:edge(), function(x, y) c:put(x, y, "#2a4a7a") end)
  shadeMask(pond:clip(rect(0, 217, 480, 221)), .8)
  -- lily pads
  for i, l in ipairs{ { 40, 246, 6, 3 }, { 118, 248, 5, 3 }, { 104, 228, 5, 2 }, { 56, 230, 4, 2 } } do
    local m = ell(l[1], l[2], l[3], l[4])
    fill(m, MOSS[3]); F(l[1] - l[3] + 1, l[2] - 1, l[1] - 1, l[2] - 1, MOSS[4])
    each(m, function(x, y) if x > l[1] and y > l[2] - 1 and y < l[2] + 1 then c:put(x, y, "#4f9fbe") end end)
    c:edgeIn(m, MOSS[1])
  end
  P(41, 243, "#f5809f"); P(42, 243, "#ffe2ec"); P(41, 242, "#f5809f")
  -- quirk: golden glimmer under the water (the once-a-year golden koi)
  for i, d in ipairs{ { 80, 256 }, { 82, 255 }, { 84, 255 }, { 86, 256 }, { 83, 257 }, { 88, 254 }, { 89, 253 } } do P(d[1], d[2], i == 3 and "#ffe38a" or "#f5b82e") end
  -- red arched bridge
  local bx0, bx1, base = 38, 132, 246
  local function deckY(x) local t = (x - bx0) / (bx1 - bx0) return floor(base - 16 * sin(pi * t)) end
  -- reflection
  for x = bx0 + 4, bx1 - 4, 1 do
    local y = base + 4 + (base - deckY(x)) * 0.5
    if pond:has(x, floor(y)) and (x % 3 ~= 0) then P(x, floor(y), "#9a4a5e") end
  end
  -- posts down into water
  for _, x in ipairs{ bx0 + 16, bx1 - 16 } do F(x, deckY(x) + 3, x + 2, base + 4, VER[2]); F(x, deckY(x) + 3, x, base + 4, VER[3]) end
  for x = bx0, bx1 do
    local y = deckY(x)
    F(x, y, x, y + 3, VER[3]); P(x, y + 3, VER[2]); P(x, y + 4, VER[1])
    P(x, y - 1, "#c9a27a"); P(x, y - 2, (x % 3 == 0) and "#8a6046" or "#e8b982")
    P(x, y - 3, VER[1])
    -- rail
    P(x, y - 9, VER[1]); P(x, y - 8, VER[3]); P(x, y - 7, VER[2])
  end
  for x = bx0, bx1, 12 do
    local y = deckY(x)
    F(x, y - 10, x + 1, y - 3, VER[3]); F(x + 1, y - 10, x + 1, y - 3, VER[2])
    F(x, y - 12, x + 1, y - 11, "#2e1d22"); P(x, y - 12, "#6b4434")
  end
  F(bx1, deckY(bx1) - 10, bx1 + 1, deckY(bx1) - 3, VER[3]); F(bx1, deckY(bx1) - 12, bx1 + 1, deckY(bx1) - 11, "#2e1d22")
  -- koi food basket on the bank
  local kb = c:rrect(128, 256, 138, 263, 2)
  fill(kb, "#e8c87a"); each(kb, function(x, y) if (x + y) % 3 == 0 then c:put(x, y, "#b89a6e") end end)
  F(130, 255, 136, 256, "#d98322"); P(131, 255, "#ffe38a"); c:edgeIn(kb, "#7a5a3a")
  -- iris leaves at bank
  for i = 0, 3 do F(24 + i * 3, 236 - i % 2 * 3, 24 + i * 3, 244, "#3f9150") end
  P(27, 233, "#8a6fd0"); P(28, 232, "#c9b2f0")
end

-- ================= SPOT: NOTICE BOARD (right near) =================
do
  local x0, x1 = 336, 374
  shadeMask(poly{ { x0 + 2, 262 }, { x1 + 12, 262 }, { x1 + 14, 267 }, { x0 + 6, 267 } }, .76)
  F(x0 + 3, 220, x0 + 6, 262, "#634036"); F(x0 + 3, 220, x0 + 3, 262, "#8a6046"); c:edgeIn(rect(x0 + 3, 220, x0 + 6, 262), TIMB[1])
  F(x1 - 6, 220, x1 - 3, 262, "#4a2f2e"); c:edgeIn(rect(x1 - 6, 220, x1 - 3, 262), TIMB[1])
  local bd = rect(x0, 224, x1, 252)
  each(bd, function(x, y) c:put(x, y, ((y - 224) % 6 == 5) and "#864c33" or ((hsh(x, y, 171) > .9) and "#e8b982" or "#b97a4a")) end)
  F(x0 + 1, 225, x0 + 1, 251, "#e8b982")
  c:edgeIn(bd, "#51302b")
  -- small tiled roof cap
  local cap = poly{ { x0 - 6, 222 }, { x0 - 3, 218 }, { x0 + 2, 214 }, { x1 - 2, 214 }, { x1 + 3, 218 }, { x1 + 6, 222 }, { x1 + 4, 223 }, { x0 - 4, 223 } }
  each(cap, function(x, y) c:put(x, y, (x % 3 == 0) and "#56628f" or "#3d4670") end)
  F(x0 - 3, 222, x1 + 3, 222, "#232a4c"); c:edgeIn(cap, "#232a4c")
  F(x0 + 6, 211, x1 - 6, 213, "#232a4c")
  -- pinned papers (various, with scribble lines)
  local papers = { { 340, 227, 349, 238, "#fbf1dc" }, { 352, 226, 362, 234, "#ffe2ec" }, { 364, 228, 371, 240, "#e4f6ff" },
    { 341, 241, 352, 250, "#fff0c4" }, { 355, 237, 363, 249, "#e6f4d0" }, { 365, 243, 372, 250, "#fbf1dc" } }
  for i, p in ipairs(papers) do
    local m = rect(p[1], p[2], p[3], p[4])
    fill(m, p[5])
    for y = p[2] + 3, p[4] - 2, 2 do F(p[1] + 2, y, p[3] - 2 - (y % 3), y, "#9a8a9a") end
    F(p[3] - 1, p[2] + 1, p[3], p[4], shade(p[5], .9))
    c:edgeIn(m, "#8e8396")
    P(floor((p[1] + p[3]) / 2), p[2], i % 2 == 0 and "#e0452f" or "#3a86b0")
  end
  -- drawn icons on two papers: blossom + umbrella
  F(344, 230, 346, 232, "#f5809f"); P(345, 231, "#f5b82e")
  F(357, 240, 361, 241, "#3a86b0"); P(359, 242, "#634036"); P(359, 243, "#634036")
  -- base stones
  F(x0 + 1, 260, x0 + 8, 263, STN[3]); F(x1 - 8, 260, x1 - 1, 263, STN[2]); c:edgeIn(rect(x0 + 1, 260, x0 + 8, 263), STN[1]); c:edgeIn(rect(x1 - 8, 260, x1 - 1, 263), STN[1])
end

-- ---------- quirk near the teahouse: rack of four rain umbrellas, one per season's rain ----------
do
  local x, y = 386, 118
  F(x, y + 2, x + 10, y + 3, TIMB[2]); F(x, y + 4, x + 1, y + 8, TIMB[2]); F(x + 9, y + 4, x + 10, y + 8, TIMB[2])
  for i, col in ipairs{ "#f5809f", "#5fc4c8", "#e8833b", "#c9b2f0" } do
    local ux = x + (i - 1) * 3
    local um = poly{ { ux, y - 10 }, { ux + 2, y - 2 }, { ux - 1, y + 4 } }
    fill(um, col); P(ux, y - 11, TIMB[1]); P(ux, y + 5, TIMB[1])
  end
end

-- ---------- falling petals ----------
local stands = { { 160, 216 }, { 236, 228 }, { 312, 226 }, { 196, 256 }, { 284, 256 }, { 322, 190 } }
for i = 1, 170 do
  local x, y = floor(hsh(i, 3, 201) * 440) + 20, floor(hsh(i, 4, 201) * 240) + 24
  local ok = not (x >= 380 and y >= 228)
  for _, s in ipairs(stands) do if abs(x - s[1]) < 16 and abs(y - s[2]) < 10 then ok = false end end
  if ok then
    P(x, y, "#f6bdd0"); P(x + 1, y, (i % 3 == 0) and "#ffe2ec" or "#e38fb0")
    if i % 4 == 0 then P(x + 1, y + 1, "#c96a92") end
  end
end

-- ================= GATE FRAME: vermilion torii-style arch =================
do
  -- posts
  for _, px in ipairs{ 0, 464 } do
    for x = px, px + 15 do
      local k = x - px
      local col = k <= 2 and VER[4] or (k <= 9 and VER[3] or (k <= 13 and VER[2] or VER[1]))
      F(x, 24, x, 269, col)
    end
    F(px, 248, px + 15, 269, "#3a2a34"); F(px + 1, 248, px + 3, 269, "#5a4652"); F(px, 248, px + 15, 249, "#2e1d22")
    for y = 60, 240, 30 do F(px + 4, y, px + 7, y, VER[4]) end
    c:edgeIn(rect(px, 24, px + 15, 269), VER[1])
  end
  -- nuki (lower tie beam)
  F(0, 26, 479, 33, VER[3]); F(0, 26, 479, 27, VER[4]); F(0, 32, 479, 33, VER[2]); F(0, 34, 479, 34, VER[1])
  -- central strut with a blank plaque crested by a blossom
  F(232, 12, 248, 26, VER[3]); F(232, 12, 233, 26, VER[4])
  local pq = rect(228, 14, 252, 25)
  fill(pq, "#2e1d22"); F(230, 16, 250, 23, "#4a2f2e")
  F(239, 18, 241, 20, "#f5809f"); P(240, 17, "#f5809f"); P(240, 21, "#f5809f"); P(238, 19, "#f5809f"); P(242, 19, "#f5809f"); P(240, 19, "#f5b82e")
  c:edgeIn(pq, GOLD[1])
  -- shimaki + kasagi top beam with up-swept ends
  F(0, 8, 479, 12, VER[3]); F(0, 8, 479, 8, VER[4]); F(0, 12, 479, 12, VER[2])
  local kas = HP.mask()
  for x = 0, 479 do
    local de = min(x, 479 - x)
    local u = de < 40 and floor((40 - de) ^ 2 / 260) or 0
    for y = 1 - u, 7 - floor(u / 2) do kas:set(x, y) end
  end
  fill(kas, "#2e1d22")
  each(kas, function(x, y) if not kas:has(x, y - 1) then c:put(x, y, "#5a4652") end end)
  F(0, 7, 479, 7, "#1f1419")
  -- bunting string with pastel paper pennants
  local cols = { "#f5809f", "#ffe38a", "#a8dcc0", "#fbe6dc", "#c9b2f0", "#7fb8d8" }
  local function sag(x) return 38 + floor(16 * sin(pi * (x - 16) / 448)) end
  for x = 16, 463 do P(x, sag(x), "#8f4a1f") end
  local n = 0
  for x = 22, 456, 12 do
    n = n + 1
    local y = sag(x)
    local col = cols[1 + n % #cols]
    local pm = poly{ { x - 4, y + 1 }, { x + 4, y + 1 }, { x, y + 8 } }
    fill(pm, col); P(x - 2, y + 2, warm(col)); c:edgeIn(pm, shade(col, .62))
  end
  -- hanging paper lanterns from the nuki
  for _, lx in ipairs{ 28, 440 } do
    F(lx + 6, 35, lx + 6, 44, "#2e1d22")
    paperLantern(lx, 48, 13, 20, { "#6e2038", "#e0452f", "#ffd0a8" }, "#ffe38a")
    F(lx + 4, 54, lx + 8, 60, "#fbf1dc"); F(lx + 5, 56, lx + 7, 58, "#f5809f")
  end
  -- blossom sprays hanging from the corners
  canopy({ { 22, 40, 12, 6 }, { 38, 36, 9, 5 }, { 18, 52, 6, 6 } }, SAK, 211)
  canopy({ { 458, 40, 12, 6 }, { 442, 36, 9, 5 }, { 462, 52, 6, 6 } }, SAK, 212)
end

-- ---------- layout / save ----------
local spots = {
  { k = "green",   name = "The Moss Garden",     box = { 176, 115, 304, 206 } },
  { k = "tea",     name = "The Bamboo Teahouse", box = { 306, 62, 388, 126 } },
  { k = "board",   name = "Notice Board",        box = { 330, 210, 378, 266 } },
  { k = "library", name = "Library",             box = { 92, 62, 178, 126 } },
  { k = "s1",      name = "Koi Pond",            box = { 20, 214, 142, 268 } },
  { k = "s2",      name = "Blossom Grove",       box = { 338, 136, 460, 200 } },
  { k = "shops",   name = "Shops",               box = { 18, 136, 136, 204 } },
  { k = "wild",    name = "Wild Trail",          box = { 390, 66, 464, 128 } },
}
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s.k, s.name,
    floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, s in ipairs(stands) do st[#st + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
local json = string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}',
  HZ, table.concat(parts, ","), table.concat(st, ","))
local f = io.open(OUT .. NAME .. ".layout.json", "w"); f:write(json); f:close()

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
print("ok " .. NAME)

-- ico-badger (final, Opus). Front-on badger head, slim and long: domed crown narrowing to a pointed snout,
-- cream face with two charcoal stripes running from the muzzle up through the eyes into small round ears,
-- a cream centre blaze. Per-pixel dome light (sphere + pillow blend) shared by both fur ramps, fur flicks on
-- the cheeks, cream-tipped ears with AO where they meet the crown, ink nose with a lit tip and nostril shadow.
-- quirk: an earthworm dangles from the corner of its mouth.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-badger")
local FUR = { "#5d4c62", "#8a7a8e", "#b6aab4", "#dcd2cc", "#f3e9d4", "#fff4d6" }
local STR = { "#251f33", "#302940", "#3d354f", "#4d4662", "#625b7a", "#7f7997" }
local NOSE = { "#2b1c26", "#4a3442", "#8a6a7e" }
local ftok, stok, etok = { r = { name = "fur" } }, { r = { name = "stripe" } }, { r = { name = "ear" } }
local CX = 32

-- ears (behind the head)
local ears = {}
for _, sx in ipairs{ -1, 1 } do
  local ex, ey = CX + sx * 12.5, 14
  local em = c:ellipse(ex, ey, 4, 4)
  local n = X.sphere(ex, ey, 4, em)
  local idx = A.shade(c, em, n, STR, { amb = 0.1, wrap = 0.3, tok = etok })
  -- cream rim on the top/outer arc
  em:edge():each(function(x, y)
    local dx, dy = x - ex, y - ey
    if dy < 0.5 and dx * sx > -2.5 then c:put(x, y, dy < -2 and FUR[6] or FUR[4], etok) end
  end)
  -- dark inner ear
  c:fillMask(c:ellipse(ex - sx * 0.5, ey + 0.5, 1.5, 1.5), STR[1])
  ears[#ears + 1] = em
end

-- head mask: domed crown + tapering snout + cheek fur tufts
local head = c:ellipse(CX, 25, 15, 12)
head:add(c:poly{ { CX - 13, 30 }, { CX + 13, 30 }, { CX + 5, 49 }, { CX, 52 }, { CX - 5, 49 } })
for _, sx in ipairs{ -1, 1 } do   -- jaw tufts (two small fur points on each cheek)
  head:add(c:poly{ { CX + sx * 12.5, 30 }, { CX + sx * 15, 35 }, { CX + sx * 11, 36 } })
end
-- normals: dome + pillow, snout pushed forward
local np = X.pillow(head, 5)
local ns = X.sphere(CX, 28, 21, head)
local n = {}
for k, a in pairs(np) do local b = ns[k] n[k] = { A.norm(a[1] * 0.45 + b[1] * 0.55, a[2] * 0.45 + b[2] * 0.55, a[3] * 0.45 + b[3] * 0.55) } end
local v = X.light(n, { amb = 0.1, wrap = 0.3 })

-- stripe field: two bands from muzzle (near nose) up through the eyes to the ears
local function stripeD(x, y, sx)
  local ax, ay = CX + sx * 3.2, 44
  local bx, by = CX + sx * 11.5, 13
  local vx, vy = bx - ax, by - ay
  local L = sqrt(vx * vx + vy * vy)
  local t = ((x - ax) * vx + (y - ay) * vy) / (L * L)
  t = max(0, min(1, t))
  local px, py = ax + vx * t, ay + vy * t
  local d = sqrt((x - px) ^ 2 + (y - py) ^ 2)
  return d, t
end
local stripe, fur = HP.mask(), HP.mask()
head:each(function(x, y)
  local isS = false
  for _, sx in ipairs{ -1, 1 } do
    local d, t = stripeD(x, y, sx)
    local w = 1.3 + t * 2.4
    if d <= w and y < 45 then isS = true end
  end
  if isS then stripe:set(x, y) else fur:set(x, y) end
end)
local bias = {}
-- AO where the ears tuck under the crown + under the chin
for _, em in ipairs(ears) do X.ao(bias, head, em, 1, -1) end
-- fur flicks: short 2px strokes on the cheeks and crown
head:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 7)
  if h < 0.05 and y > 16 then bias[k] = (bias[k] or 0) - 1 if head:has(x + 1, y + 1) then local k2 = K(x + 1, y + 1) bias[k2] = (bias[k2] or 0) - 1 end end
  if h > 0.95 and v[k] > 0.5 then bias[k] = (bias[k] or 0) + 1 end
end)
local fidx = X.tone(c, fur, v, FUR, { cuts = A.CUTS6, bias = bias, tok = ftok })
local sidx = X.tone(c, stripe, v, STR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = stok })
-- soft separation: fur pixels touching a stripe drop one tone (fur casts into the groove)
A.touch(fur, stripe):each(function(x, y) A.step(c, fidx, FUR, x, y, -1, ftok) end)

-- eyes: 2x3 ink pills with cream glint, a lit brow pixel above each
for _, sx in ipairs{ -1, 1 } do
  local ex = sx < 0 and CX - 9 or CX + 8
  local ey = 26
  for yy = 0, 2 do for xx = 0, 1 do c:put(ex + xx, ey + yy, A.INK) end end
  c:put(ex, ey, A.CREAM)
  c:put(ex, ey - 1, STR[6], stok) c:put(ex + 1, ey - 1, STR[6], stok)
  c:put(ex - sx, ey + 1, STR[1], stok) c:put(ex, ey + 3, STR[5], stok) c:put(ex + 1, ey + 3, STR[5], stok)
end
-- muzzle: lift the cream around the nose so it pops
fur:each(function(x, y) if y >= 41 and abs(x - CX) <= 6 then A.step(c, fidx, FUR, x, y, (y >= 45 and 2 or 1), ftok) end end)
-- nose: ink-dark button with a lit tip, cream glint, nostrils and a dark underside row
A.map(c, {
  ".bbbbb.",
  "bhcbbbb",
  "bhbbbbb",
  "bkbbbkb",
  ".kkkkk.",
}, CX - 3, 46, { b = "#4a3442", h = "#8a6a7e", c = A.CREAM, k = A.INK })
-- mouth: short ink tick under the nose and a chin shadow
c:put(CX, 51, A.INK) c:put(CX - 1, 52, FUR[2]) c:put(CX + 1, 52, FUR[2])

-- quirk: earthworm hanging from the right mouth corner (2 px thick, segmented)
local W = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local wtok = { r = { name = "worm" } }
local path = { { CX + 2, 51 }, { CX + 4, 52 }, { CX + 6, 54 }, { CX + 7, 56 }, { CX + 6, 58 }, { CX + 4, 58 } }
A.pline(c, path, W[3], wtok)
c:put(CX + 2, 51, W[4], wtok)
local sh = {} for i, p in ipairs(path) do sh[i] = { p[1] + 1, p[2] + 1 } end
A.pline(c, sh, W[2], wtok)
for i = 2, #path - 1, 2 do c:put(path[i][1] + 1, path[i][2] + 1, W[1], wtok) end
c:put(CX + 6, 54, W[4], wtok)
A.save(c, "ico-badger")

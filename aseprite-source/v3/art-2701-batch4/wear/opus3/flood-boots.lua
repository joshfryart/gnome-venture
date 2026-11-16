-- flood-boots: Flood Boots, common cut a (Opus second pass, full redraw). 64x64 Hearth Pop.
-- Same item as the game base: a pair of green rubber wellies with tan turned-down cuffs, the back
-- boot stepped right, toes pointing right, brown soles, wet from a puddle.
-- Redraw: glossy rubber lit per pixel (6-tone hue-shifted green, cool shade, warm lights), a
-- specular streak down each shaft, a rolled tan cuff with a dark mouth and a lip shadow, ankle
-- crinkles, a lugged sole with a lit welt, the front boot's contact shadow on the back boot,
-- a water run down the front shaft and droplets at the toe.
-- quirk: a yellow rubber duck has moved into the back boot and peeks over the cuff.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local HP, X, K = W.HP, W.X, W.K
local c = W.new("flood-boots")

local RUB = { "#132e2c", "#1e4a3a", "#2c6a46", "#3f8a4c", "#5cab55", "#98d078" }
local TAN = { "#4e2e24", "#7c4e36", "#a8744c", "#c99862", "#e4b880", "#f6d8a6" }
local SOLE = { "#2e1c22", "#4a2a26", "#6a3e2e", "#8a5638", "#a8704a", "#c48e62" }
local SEA = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local GLINT = "#d8f2b0"

local function boot(o)
  local shaft = c:rect(o.x0, o.ytop, o.x1, o.ybot)
  local foot = c:poly(o.foot)
  local body = shaft:copy():add(foot)
  local sole = c:rect(o.x0 - 1, o.sy, o.toe, o.sy + 3)
  -- toe of the sole rounds up, heel is square
  sole:cut(c:rect(o.toe, o.sy + 2, o.toe, o.sy + 3))
  for x = o.x0 + 2, o.toe - 2, 5 do sole:cut(c:rect(x, o.sy + 3, x + 1, o.sy + 3)) end  -- tread lugs
  body:cut(sole)
  local cuff = c:rrect(o.x0 - 2, o.cy, o.x1 + 2, o.cy + 8, 2)
  body:cut(cuff)

  -- rubber: shaft is a vertical cylinder, foot a pillow tipped up toward the light
  local nS = W.vcylN(shaft, o.x0, o.x1, 0)
  local nF = W.mixN(X.pillow(foot, 4), W.vcylN(foot, o.x0, o.toe, -0.3), 0.6)
  local n = {}
  for k, v in pairs(nS) do n[k] = v end
  for k, v in pairs(nF) do if not nS[k] then n[k] = v end end
  foot:each(function(x, y)
    local k = K(x, y)
    if y > o.ankle and nS[k] then
      local w = math.min(1, (y - o.ankle) / 7)
      local a, f = nS[k], nF[k]
      n[k] = { W.norm(a[1] * (1 - w) + f[1] * w, a[2] * (1 - w) + f[2] * w, a[3] * (1 - w) + f[3] * w) }
    end
  end)
  local b = {}
  if o.back then body:each(function(x, y) W.addBias(b, x, y, -1) end) end
  W.ao(b, body, cuff, 1, -1)
  W.lit(c, body, n, RUB, { bias = b, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  -- toe cap shine
  c:put(o.toe - 9, o.sy - 6, GLINT) c:put(o.toe - 8, o.sy - 6, RUB[6]) c:put(o.toe - 10, o.sy - 5, RUB[6])
  -- sole
  local nso = W.hcylN(sole, o.sy, o.sy + 3)
  local sb = {}
  sole:each(function(x, y) if y == o.sy then W.addBias(sb, x, y, 2) end end)  -- lit welt
  W.lit(c, sole, nso, SOLE, { bias = sb })
  body:each(function(x, y) if sole:has(x, y + 1) then W.step(c, x, y, RUB, -2) end end)
  -- cuff: a rolled tan band, horizontal cylinder; lip shadow under it
  local nc = W.mixN(W.hcylN(cuff, o.cy + 1, o.cy + 7), W.vcylN(cuff, o.x0 - 2, o.x1 + 2), 0.55)
  local cb = {}
  cuff:each(function(x, y)
    if y == o.cy + 6 then W.addBias(cb, x, y, -1) end  -- the roll's fold line
    if y == o.cy + 8 then W.addBias(cb, x, y, -1) end  -- lip tucked under
  end)
  if o.back then cuff:each(function(x, y) W.addBias(cb, x, y, -1) end) end
  W.lit(c, cuff, nc, TAN, { bias = cb, amb = 0.12 })
  -- mouth: the dark opening along the top of the cuff
  for x = o.x0, o.x1 do c:put(x, o.cy, (x < o.x0 + 3) and TAN[2] or "#3a2028") end
  for x = o.x0 + 1, o.x1 - 1 do c:put(x, o.cy + 1, TAN[3]) end
  -- glossy specular streak down the lit side of the shaft (broken where the rubber creases)
  for y = o.cy + 10, o.ankle - 2 do
    if y % 9 ~= 4 then c:put(o.x0 + 2, y, (y < o.cy + 15) and GLINT or RUB[6]) end
  end
  -- ankle crinkles
  for i, p in ipairs(o.crinkles) do
    c:put(p[1], p[2], RUB[2]) c:put(p[1] + 1, p[2] - 1, RUB[5])
  end
  return body, cuff, sole
end

-- back boot first (stepped right and up)
local Bb, Bc, Bs = boot{ back = true, x0 = 23, x1 = 38, ytop = 15, ybot = 44, cy = 7, ankle = 35, toe = 53, sy = 45,
  foot = { { 23, 35 }, { 33, 33 }, { 42, 35 }, { 48, 38 }, { 52, 41 }, { 53, 45 }, { 23, 45 } },
  crinkles = { { 40, 37 }, { 43, 38 } } }
-- front boot
local Fm = c:rect(9, 11, 31, 55):add(c:poly{ { 12, 38 }, { 26, 37 }, { 34, 40 }, { 40, 43 }, { 44, 47 }, { 44, 55 }, { 12, 55 } })
-- the front boot casts its shadow on the back boot (down-right)
Fm:shift(2, 1):cut(Fm):each(function(x, y)
  local h = W.get(c, x, y)
  for _, R in ipairs{ RUB, TAN, SOLE } do for i, v in ipairs(R) do if v == h then c:put(x, y, R[math.max(1, i - 2)]) end end end
end)
local Fb, Fc, Fs = boot{ x0 = 12, x1 = 29, ytop = 19, ybot = 50, cy = 11, ankle = 40, toe = 44, sy = 51,
  foot = { { 12, 40 }, { 26, 38 }, { 34, 41 }, { 40, 44 }, { 43, 47 }, { 44, 51 }, { 12, 51 } },
  crinkles = { { 30, 41 }, { 33, 42 } } }
-- separation where the front boot overlaps the back one
W.sep(c, Fb:copy():add(Fc):add(Fs), Bb:copy():add(Bc):add(Bs):cut(Fb):cut(Fc):cut(Fs), "#132e2c")
for x = 9, 44 do for y = 0, 63 do
  local k = W.get(c, x, y)
  if k == "#132e2c" and Fc:has(x, y) then c:put(x, y, TAN[1]) end
  if k == "#132e2c" and Fs:has(x, y) then c:put(x, y, SOLE[1]) end
end end

-- water: a run down the front shaft and drops at the front toe
for y = 21, 31 do c:put(21, y, (y < 23) and SEA[4] or ((y % 3 == 0) and SEA[2] or SEA[3])) end
c:put(21, 32, SEA[2]) c:put(22, 21, SEA[3])
W.paint(c, 45, 47, {
  ".d..",
  "dcb.",
  "cbba",
  ".aa.",
}, { a = SEA[1], b = SEA[2], c = SEA[3], d = SEA[4] })
c:put(47, 44, SEA[3]) c:put(47, 43, SEA[4])

-- quirk: a rubber duck in the back boot, peeking over the cuff
local DUCK = { "#8a5a1e", "#d9932a", "#f5c03a", "#ffe07a", "#fff4c0" }
local dm, dn = W.oval(31.5, 4.5, 3.2, 3.2, 0)
dm:cut(c:rect(20, 7, 50, 20))
W.lit(c, dm, dn, { DUCK[1], DUCK[2], DUCK[3], DUCK[3], DUCK[4], DUCK[5] }, { amb = 0.2 })
-- back of the duck in the boot mouth
for x = 30, 36 do c:put(x, 7, (x < 33) and DUCK[3] or DUCK[2]) end
c:put(37, 6, DUCK[2]) c:put(37, 7, DUCK[2]) c:put(36, 6, DUCK[3])  -- tail flick
-- beak and eye
W.paint(c, 26, 4, { "ab", "cc" }, { a = "#ff9c5a", b = "#f07a3a", c = "#c85a2e" })
c:put(30, 3, W.INK) c:put(31, 2, DUCK[5])
W.shift(c, 0, 3)
W.save(c, "flood-boots")

-- butterfly_bush: EMPTY state only (craft pass on the BUILD sign). 64x56, anchor (32,46).
local S = dofile("/tmp/ase/states2/q4signs_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local lerp = K.lerp
local out = app.params.out or "/tmp/ase/states2/butterfly_bush/"
local W, H, AX, AY = 64, 56, 32, 46
local c

local CLOTH = { hi = P.dusk.base, base = P.dusk.shade, shade = "#4a3888", deep = P.dusk.deep }
local BFLY = {
  "oo...oo",
  "ooobooo",
  "owobowo",
  ".pobop.",
  "pp.b.pp",
}
local BFLYMAP = { o = P.gold.base, b = P.ink, p = P.petal.hi, w = P.cream }

-- a bare twig: list of points (bottom first), the lower part 2 px thick
local function twig(pts, forks, buds)
  local thick, thin = HP.mask(), HP.mask()
  for i = 1, #pts - 1 do
    local m = c:line({ pts[i], pts[i + 1] }, 1)
    thin:add(m)
    if i <= 2 then thick:add(m:shift(1, 0)) end
  end
  for _, f in ipairs(forks) do thin:add(c:line(f, 1)) end
  local all = HP.mask():add(thick):add(thin)
  K.ink(all)
  c:fillMask(all, P.wood.base)
  c:fillMask(thick, P.wood.shade)
  thin:each(function(x, y) if not thick:has(x, y) and not all:has(x - 1, y) then px(x, y, P.wood.hi) end end)
  for _, b in ipairs(buds) do px(b[1], b[2], P.petal.base) end
end

local function banner(k)
  local x0, x1, y0 = 15, 48, 11
  local tw = ({ 0, 1, 0, -1 })[k]          -- tail flutter (only the swallowtail moves)
  local tw2 = ({ 0, 0, 1, 1 })[k]
  -- string: twig tips to the hem ends, threaded through the sleeve
  local L, Rr = { 9, 9 }, { 55, 9 }
  local str = c:line({ L, { x0 - 1, y0 + 1 } }, 1):add(c:line({ { x1 + 1, y0 + 1 }, Rr }, 1))
  -- cloth: hem sleeve (3 rows), body, swallowtail (two points, notch in the middle)
  local hem = c:rect(x0, y0, x1, y0 + 2)
  local body = c:rect(x0, y0 + 3, x1, y0 + 12)
  local tail = HP.mask()
  for r = 0, 4 do
    local y = y0 + 13 + r
    local notch = 3 - r             -- notch closes upward
    for x = x0 + r // 2, x1 - r // 2 do
      if math.abs(x - (x0 + x1) / 2) > (r + 1) * 1.6 then tail:set(x + ((r >= 2) and tw or 0), y + ((r >= 3) and tw2 or 0) * 0) end
    end
  end
  K.ink(hem, body, tail)
  c:fillMask(str, S.ROPE or "#d9b46a")
  c:fillMask(body, CLOTH.base)
  c:fillMask(tail, CLOTH.base)
  -- folds: lit left edge, shaded right edge, a soft fold line near each end (margins only)
  R(x0, y0 + 3, x0, y0 + 12, CLOTH.hi)
  R(x1, y0 + 3, x1, y0 + 12, CLOTH.shade)
  tail:each(function(x, y)
    if not tail:has(x + 1, y) or not tail:has(x, y + 1) then px(x, y, CLOTH.shade) end
    if not tail:has(x - 1, y) then px(x, y, CLOTH.hi) end
  end)
  -- hem sleeve: lighter band with gold running stitch, ties at the ends
  c:fillMask(hem, CLOTH.hi)
  R(x0, y0, x1, y0, P.dusk.hi)
  R(x0, y0 + 2, x1, y0 + 2, CLOTH.shade)
  for x = x0 + 1, x1 - 1, 3 do px(x, y0 + 1, P.gold.hi) px(x + 1, y0 + 1, P.gold.hi) end
  px(x0 - 1, y0 + 1, P.cream) px(x1 + 1, y0 + 1, P.cream)
  -- icon + lettering: cream letters with an ink drop shadow on the dark cloth
  K.sprite(BFLY, x0 + 2, y0 + 5, BFLYMAP, true)
  px(x0 + 2, y0 + 5, P.gold.hi) px(x0 + 8, y0 + 5, P.gold.hi)
  px(x0 + 4, y0 + 4, P.gold.hi) px(x0 + 6, y0 + 4, P.gold.hi)   -- antennae
  S.text(x0 + 11, y0 + 5, P.cream, P.ink)
  -- gold stitch spice under the word, on the lower margin
  -- (none: keep the margin clean)
end

local function bfly(x, y, open)
  local rows = open and { "pp.pp", "ppkpp", ".pkp.", "p...p" } or { ".p.p.", ".pkp.", ".pkp.", "....." }
  K.sprite(rows, x, y, { p = P.petal.base, k = P.ink })
  if open then px(x, y, P.petal.hi) px(x + 3, y, P.petal.hi) end
end

local function drawEmpty(k)
  c = S.new(W, H, "butterfly_bush"); S.c = c
  S.plot(9, 35, 55, 52, 11)
  S.footprint(16, 47, 39, 12, 51, 49, 5)
  -- the two bare twigs that hold the pennant, planted at the back corners
  twig({ { 8, 41 }, { 8, 33 }, { 9, 24 }, { 8, 16 }, { 9, 9 } }, { { { 8, 20 }, { 5, 16 }, { 4, 13 } }, { { 9, 12 }, { 11, 8 } } }, { { 4, 12 }, { 11, 7 }, { 5, 16 } })
  twig({ { 55, 41 }, { 55, 33 }, { 54, 25 }, { 55, 16 }, { 55, 9 } }, { { { 55, 22 }, { 58, 18 }, { 59, 15 } }, { { 55, 12 }, { 53, 8 } } }, { { 59, 14 }, { 53, 7 }, { 58, 18 } })
  banner(k)
  -- pebbles, tufts, lilac blooms and a dandelion
  S.pebble(22, 45, true) S.pebble(40, 47) S.pebble(34, 40)
  S.tuft(13, 52) S.tuft(50, 52) S.tuft(29, 52) S.tuft(42, 37)
  S.flower(5, 48, P.dusk.hi, P.cream, 1)
  S.flower(59, 46, P.gold.base, P.gold.deep, -1)
  S.flower(27, 47, P.petal.hi, P.gold.base, 1)
  -- life: a pink butterfly flutters by
  local pos = { { 30, 38 }, { 33, 35 }, { 36, 37 }, { 39, 34 } }
  bfly(pos[k][1], pos[k][2], k % 2 == 1)
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "butterfly_bush", fr, W, H)

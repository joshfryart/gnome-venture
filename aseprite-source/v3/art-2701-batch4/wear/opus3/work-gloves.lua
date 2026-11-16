-- work-gloves: Work Gloves, common cut a (Opus richness pass opus3, built on opus2). 64x64 Hearth Pop.
-- Same item as the game base: a pair of tan leather work gloves, fingers up, the front glove's
-- thumb out to the left, the back glove stepped right with its thumb out to the right, darker
-- leather cuffs with a cream stitch row.
-- Redraw: each finger is its own lit tube (6-tone tan leather, warm lights, cool deep), deep seams
-- between fingers, knuckle creases and a lit knuckle ridge, sparse leather pores, a pillowed palm,
-- a rolled cuff with a contact row and a cream saddle stitch, the front glove's shadow on the back one.
-- quirk: an earthworm has hitched a ride, draped over the back glove's little finger.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local HP, X, K = W.HP, W.X, W.K
local c = W.new("work-gloves")

local LEA = { "#4a2620", "#7a4430", "#a5673a", "#c4864c", "#dca566", "#f0c98a" }
local CUF = { "#3a2020", "#5e3428", "#80492c", "#9a5e36", "#b87a48", "#d49a62" }
local STITCH = "#f2dcb0"

local function glove(o)
  local all = HP.mask()
  local fingers = {}
  for i, f in ipairs(o.fingers) do
    local m, n = W.tube({ { f[1], o.knuckle + 2 }, { f[1], o.knuckle - 4 }, { f[1], f[2] + 4 }, { f[1], f[2] + 1.5 } }, function(t) return f[3] end)
    m:add(W.oval(f[1], f[2] + 1.6, f[3], 1.6, 0))   -- round the tip
    fingers[i] = { m = m, n = n }
  end
  local palm = c:rrect(o.palm[1], o.palm[2], o.palm[3], o.palm[4], 3)
  local thumb, tn = W.tube(o.thumb, function(t) return 2.6 - t * 0.5 end)
  thumb:add(W.oval(o.thumb[4][1], o.thumb[4][2], 2.0, 2.0, 0))
  local cuff = c:rrect(o.cuff[1], o.cuff[2], o.cuff[3], o.cuff[4], 1)
  local back = o.back and -1 or 0

  -- thumb (behind the palm)
  local tb = {}
  W.speck(tb, thumb, 31 + o.seed, 0.06, -1)
  thumb:each(function(x, y) W.addBias(tb, x, y, back) end)
  local tnn = {}
  thumb:each(function(x, y) tnn[K(x, y)] = tn[K(x, y)] or { 0, 0, 1 } end)
  W.lit(c, thumb, tnn, LEA, { bias = tb })
  -- palm
  local pn = X.pillow(palm, 4)
  local pb = {}
  W.speck(pb, palm, 41 + o.seed, 0.06, -1)
  palm:each(function(x, y)
    W.addBias(pb, x, y, back)
    if y == o.knuckle + 1 then W.addBias(pb, x, y, 1) end
    if y == o.knuckle + 2 then W.addBias(pb, x, y, -1) end
  end)
  W.ao(pb, palm, cuff, 2, -1)
  -- pebbled leather grain: small staggered pits
  palm:each(function(x, y) if (x + (y % 2) * 2) % 4 == 0 and y % 2 == 0 and X.hash(x, y, 9 + o.seed) < 0.7 then W.addBias(pb, x, y, -1) end end)
  W.lit(c, palm, pn, LEA, { bias = pb })
  -- reinforcing palm patch: a darker leather panel with a cream running stitch round it
  local pp = c:rrect(o.palm[1] + 3, o.knuckle + 4, o.palm[3] - 3, o.palm[4] - 4, 2)
  pp:each(function(x, y) W.step(c, x, y, LEA, -1) end)
  pp:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, back < 0 and "#d8bc90" or STITCH) end end)
  pp:each(function(x, y) if not pp:has(x + 1, y + 1) then W.step(c, x, y, LEA, -1) end end)
  W.sep(c, palm, thumb:copy():cut(palm), LEA[2])
  -- fingers, left to right; a deep seam between neighbours
  for i, f in ipairs(fingers) do
    local m = f.m:copy():cut(palm:copy():cut(c:rect(0, 0, 63, o.knuckle)))
    local fb = {}
    m:each(function(x, y)
      W.addBias(fb, x, y, back)
      -- knuckle creases: a dark fold with a lit lip above it
      if y == o.crease[i] or y == o.crease[i] + 6 then W.addBias(fb, x, y, -1) end
      if y == o.crease[i] - 1 or y == o.crease[i] + 5 then W.addBias(fb, x, y, 1) end
    end)
    local nn = {}
    m:each(function(x, y) nn[K(x, y)] = f.n[K(x, y)] or { 0, 0, 1 } end)
    W.lit(c, m, nn, LEA, { bias = fb, amb = 0.1, wrap = 0.3 })
    if i > 1 then W.sep(c, m, fingers[i - 1].m:copy():cut(m), LEA[2]) end
    all:add(m)
  end
  c:put(o.fingers[1][1] - 1, o.fingers[1][2] + 3, LEA[6])   -- knuckle glint on the lit finger
  -- cuff: rolled band, contact row above, cream stitch row, worn hem
  local cn = W.mixN(W.hcylN(cuff, o.cuff[2], o.cuff[4]), W.vcylN(cuff, o.cuff[1], o.cuff[3]), 0.5)
  local cb = {}
  W.speck(cb, cuff, 61 + o.seed, 0.06, -1)
  cuff:each(function(x, y) W.addBias(cb, x, y, back) end)
  W.lit(c, cuff, cn, CUF, { bias = cb })
  for x = o.cuff[1] + 1, o.cuff[3] - 1 do c:put(x, o.cuff[2], CUF[1]) end
  for x = o.cuff[1] + 2, o.cuff[3] - 2 do
    if (x - o.cuff[1]) % 3 ~= 1 then c:put(x, o.cuff[2] + 3, (x < o.cuff[1] + 8) and STITCH or "#d8bc90") end
  end
  for x = o.cuff[1] + 1, o.cuff[3] - 1 do if x % 4 == 0 then c:put(x, o.cuff[4], CUF[2]) end end
  all:add(palm):add(thumb):add(cuff)
  W.rimb(c, all, LEA, { rimMax = 6 })
  W.rimb(c, cuff, CUF, {})
  return all, cuff
end

-- back glove (right, stepped up)
local B = glove{ back = true, seed = 100, knuckle = 27,
  fingers = { { 36, 9, 1.9 }, { 39.6, 7, 1.9 }, { 43.2, 9, 1.9 }, { 46.6, 12, 1.7 } },
  crease = { 17, 15, 17, 20 },
  palm = { 34, 24, 48, 43 }, cuff = { 33, 42, 49, 51 },
  thumb = { { 46, 34 }, { 49, 36 }, { 52, 40 }, { 53, 44 } } }
-- front glove casts on the back one
local Fsil = c:rect(16, 11, 34, 55):add(c:rect(9, 19, 16, 40))
Fsil:shift(2, 1):cut(Fsil):clip(B):each(function(x, y) W.step(c, x, y, LEA, -2) W.step(c, x, y, CUF, -2) end)
local F = glove{ seed = 0, knuckle = 29,
  fingers = { { 18.6, 14, 1.9 }, { 22.4, 11, 1.9 }, { 26.2, 12, 1.9 }, { 30, 15, 1.9 } },
  crease = { 21, 19, 20, 23 },
  palm = { 17, 27, 33, 46 }, cuff = { 16, 45, 34, 55 },
  thumb = { { 18, 38 }, { 14, 34 }, { 11, 27 }, { 11.5, 21 } } }
W.sep(c, F, B:copy():cut(F), "#3a2020")

-- quirk: an earthworm draped over the back glove's little finger, one end dangling
local WORM = { "#5e2048", "#7d2c5e", "#b04e74", "#d8768e", "#f2a0ac", "#ffccd0" }
local wm, wn = W.tube({ { 43.5, 15 }, { 44.5, 7.5 }, { 50.5, 7.5 }, { 51, 20 } }, function(t) return (t > 0.93) and 1.0 or 1.55 end)
local wb = {}
wm:each(function(x, y) if (x + y) % 3 == 0 then W.addBias(wb, x, y, -1) end end)   -- segment rings
W.lit(c, wm, wn, WORM, { bias = wb, amb = 0.2, wrap = 0.3 })
c:put(45, 8, WORM[6]) c:put(44, 9, WORM[6])
-- worm's little face at the dangling end: two ink dots
c:put(50, 20, W.INK)
W.save(c, "work-gloves")

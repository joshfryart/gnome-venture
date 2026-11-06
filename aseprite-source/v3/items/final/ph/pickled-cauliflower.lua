-- pickled-cauliflower (C34, Opus single pass). Tall slim straight-sided swing-top jar: glass dome lid on an orange
-- rubber gasket, steel wire bail + lever; golden turmeric brine with knobbly cream florets (per-bump sphere light,
-- dark creases between curds, pale green stems), headspace above the brine, glass walls with a lit band + cool bounce.
-- quirk: a bay leaf has stuck itself flat against the inside of the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("pickled-cauliflower")
local CX = 32
c:groundShadow(CX, 54, 14, 2)

local BRINE = { "#7a3e1c", "#b5621e", "#dc8e28", "#efb53e", "#f8d26a", "#fff0b0" }
local CURD = { "#6e4a3c", "#a87a52", "#d4b07a", "#ecd6a0", "#f8eccc", "#fffbea" }
local STEM = { "#3c5a3a", "#6a8a4a", "#9cb86a", "#c4d890", "#e2ecb8", "#f6fadc" }
local OLIVE = { "#1f3a2a", "#2f5634", "#47723c", "#64904a", "#8aae5c", "#b4cc7a" }
local RUB = { "#5c1e22", "#9a2e26", "#d0482c", "#ec6c34", "#f89a52", "#ffc888" }

-- jar body (neck 15..17, shoulder, straight wall, rounded foot)
local function hw(y)
  if y < 15 or y > 52 then return nil end
  if y <= 17 then return 9.5 end
  if y == 18 then return 10.6 end
  if y == 19 then return 11.5 end
  if y <= 50 then return 12 end
  if y == 51 then return 11.5 end
  return 10.5
end
local body, bn, NX = A.lathe(CX, 15, 52, hw)
local inner = body:shrink(1)
local LEVEL = 23
local tok = { r = { name = "contents" } }
-- headspace + brine
local liq = HP.mask()
inner:each(function(x, y)
  if y < LEVEL then c:put(x, y, (NX[K(x, y)] or 0) < -.2 and "#eef9fc" or "#d6edf5", tok)
  else liq:set(x, y) end end)
local ln = {} liq:each(function(x, y) ln[K(x, y)] = bn[K(x, y)] end)
A.tone(c, liq, ln, BRINE, { amb = .3, wrap = .45, tok = tok })
for x = CX - 12, CX + 12 do if liq:has(x, LEVEL) then c:put(x, LEVEL, x < CX + 4 and BRINE[6] or BRINE[5], tok) end end

-- florets
local occ = HP.mask()
local function floret(fx, fy, s, stemDir)
  -- stem first (under the curds)
  local sd = stemDir or 0
  local sm, sn = HP.mask(), {}
  local stm, stn = A.tube({ { fx, fy + 1 }, { fx + sd * .3, fy + 3 }, { fx + sd * .7, fy + 4.5 }, { fx + sd, fy + 6.5 * s } },
    function(t) return 1.7 - t * .5 end, 40)
  stm:clip(inner)
  local bias = {}
  local list = {
    { fx, fy - .5, 3.1 * s }, { fx - 3.0 * s, fy + .8, 2.5 * s }, { fx + 3.0 * s, fy + .8, 2.5 * s },
    { fx - 1.6 * s, fy - 2.8 * s, 2.3 * s }, { fx + 1.9 * s, fy - 2.9 * s, 2.2 * s }, { fx + .2, fy + 1.8, 2.2 * s },
  }
  local m, n = HP.mask(), {}
  for i, b in ipairs(list) do
    local bm, bnn = A.bumps({ b })
    -- crease: rim of this curd that falls on an earlier curd
    bm:edge():each(function(x, y) if m:has(x, y) then bias[K(x, y)] = -2 end end)
    for k, v in pairs(bnn) do n[k] = v bias[k] = bias[k] end
    bm:each(function(x, y) local k = K(x, y) if bias[k] == -2 and not bm:edge():has(x, y) then bias[k] = nil end end)
    m:add(bm)
  end
  m:clip(inner)
  stm:cut(m)
  -- contact line where this floret sits on earlier ones
  local all = m:copy():add(stm)
  local stn2 = {} stm:each(function(x, y) stn2[K(x, y)] = stn[K(x, y)] end)
  A.tone(c, stm, stn2, STEM, { amb = .15, wrap = .3, tok = tok })
  local cb = {} for k, v in pairs(bias) do if m.s[k] then cb[k] = v end end
  local idx = A.tone(c, m, n, CURD, { amb = .14, wrap = .3, tok = tok, bias = cb })
  -- curd grain: sparse pale florets on lit bumps, dark pits in shade
  m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 7)
    if idx[k] and idx[k] >= 4 and h > .86 then c:put(x, y, CURD[min(6, idx[k] + 1)], tok)
    elseif idx[k] and idx[k] <= 3 and h > .8 then c:put(x, y, CURD[max(1, idx[k] - 1)], tok) end end)
  all:edge():each(function(x, y)
    if occ:has(x + 1, y) or occ:has(x - 1, y) or occ:has(x, y + 1) or occ:has(x, y - 1) then
      local h = c:get(x, y) if h then c:put(x, y, A.mix(h, "#4a2a24", .45), tok) end end end)
  -- contact shadow on what lies behind, just below/right of this floret
  local sh = all:shift(1, 1):cut(all) sh:add(all:shift(0, 1):cut(all))
  sh:each(function(x, y) if occ:has(x, y) and not all:has(x, y) then local h = c:get(x, y)
    if h then c:put(x, y, A.mix(h, "#5a2a1c", .3), tok) end end end)
  occ:add(all)
end
floret(26, 29, 1.0, -1)
floret(37.5, 30, .95, 1)
floret(31.5, 38, 1.05, 0)
floret(23.5, 42, .95, -1.5)
floret(39.5, 41, 1.0, 1)
floret(28, 48, .95, -1)
floret(37, 48.5, .9, 1.2)

-- quirk: bay leaf pressed flat on the glass, lower left
local leaf = A.leaf(c, 21, 48, .35, -1, 9, 1.9, OLIVE, { tok = tok, R = 1.2 })

-- everything under the brine picks up its gold tint
local sub = HP.mask() liq:each(function(x, y) sub:set(x, y) end)
occ:each(function(x, y) if y > LEVEL then local h = c:get(x, y) if h then c.pix[y * c.w + x] = A.mix(h, "#f0b030", .2) end end end)
-- bubbles
for _, b in ipairs{ { 35, 25 }, { 36, 27 }, { 28, 25 }, { 41, 36 } } do
  c:put(b[1], b[2], "#fff8d8", tok) if liq:has(b[1] + 1, b[2] + 1) then c:put(b[1] + 1, b[2] + 1, BRINE[3], tok) end end

-- glass over everything
A.glass(c, body, inner, bn, NX, { ys = LEVEL + 1 })
-- neck rim: thick lip rows
for x = CX - 10, CX + 10 do if body:has(x, 15) then c:put(x, 15, x < CX - 3 and A.GLASS[6] or A.GLASS[4]) end end

-- gasket (orange rubber band) + glass dome lid
local gm, gn = A.lathe(CX, 13, 14, function(y) return 10.6 end)
A.tone(c, gm, gn, RUB, { amb = .2, wrap = .3 })
local lm, lnn, LX = A.lathe(CX, 7, 12, function(y)
  if y == 7 then return 5 elseif y == 8 then return 7.4 elseif y == 9 then return 8.6 end return 9.5 end, 1.6)
A.tone(c, lm, lnn, A.GLASS, { amb = .3, wrap = .45 })
-- lid: pale core, lit bevel, knob
for x = CX - 4, CX + 2 do c:put(x, 8, A.GLASS[6]) end
c:put(CX - 6, 10, A.SPEC) c:put(CX - 5, 9, A.SPEC)
for x = CX - 9, CX + 9 do if lm:has(x, 12) then c:put(x, 12, x < CX + 3 and A.GLASS[3] or A.GLASS[2]) end end

-- wire bail: hinge on the neck, loop over the lid, lever down the right shoulder
local M = A.METAL
local wire = { { CX - 11, 16 }, { CX - 11, 12 }, { CX - 8, 6 }, { CX - 3, 5 } }
A.ln(c, CX - 11, 17, CX - 11, 12, M[5]) A.ln(c, CX - 11, 11, CX - 8, 6, M[5])
A.ln(c, CX - 7, 5, CX + 6, 5, M[4]) c:put(CX - 6, 5, M[6]) c:put(CX - 5, 5, M[6])
A.ln(c, CX + 7, 6, CX + 10, 11, M[3]) A.ln(c, CX + 10, 12, CX + 10, 16, M[3])
-- hinge nubs
c:put(CX - 11, 17, M[3]) c:put(CX - 10, 17, M[2]) c:put(CX + 10, 17, M[2]) c:put(CX + 9, 17, M[3])
-- lever: hinged on the right, folded down along the shoulder
A.ln(c, CX + 11, 17, CX + 13, 22, M[4]) A.ln(c, CX + 12, 17, CX + 14, 21, M[2])
c:put(CX + 13, 23, M[3]) c:put(CX + 11, 16, M[5])

A.fin(c, "pickled-cauliflower")

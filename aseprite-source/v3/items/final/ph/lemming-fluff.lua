-- lemming-fluff (final, Opus single pass). A soft tuft of lemming fur: four tapered locks fanning up from a bound
-- root, coloured like a lemming coat (cream underfur at the root, golden-tawny body, dark brown-black tips).
-- Per-pixel light on each lock, lengthwise strand lines, AO where locks overlap, loose 1 px wisps, a short brush of
-- cut fur ends below the tie. Twisted red thread wrapped round the root (twist cue).
-- quirk: the thread's loose end has come undone and curls off to the side.
local NAME = "lemming-fluff"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local UNDER = { "#7a5a4a", "#a88468", "#cfb08a", "#e8d2ac", "#f6e6c6", "#fff2dc" }
local TAWNY = { "#5a2f2a", "#8a4a2c", "#b8702e", "#dc9a3e", "#f2bf62", "#ffdf96" }
local TIP   = { "#1f1418", "#2e1e20", "#46302a", "#634434", "#86603e", "#a8804e" }
local RED   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

-- locks: cubic beziers from the root (bottom) to the tip; w0 = max half width
local locks = {
  { { { 29, 46 }, { 22, 38 }, { 16, 30 }, { 14, 21 } }, 6.0, 1 },   -- left, back
  { { { 33, 46 }, { 42, 38 }, { 48, 32 }, { 51, 23 } }, 5.8, 2 },   -- right, back
  { { { 33, 47 }, { 44, 46 }, { 50, 46 }, { 55, 42 } }, 4.6, 3 },   -- low right
  { { { 31, 46 }, { 30, 34 }, { 33, 22 }, { 28, 13 } }, 6.6, 4 },   -- centre, front, curling tip
}
local function wfn(w0) return function(t)
  if t < 0.3 then return w0 * (0.45 + 0.55 * t / 0.3) end
  return max(0.3, w0 * ((1 - t) / 0.7) ^ 0.85)
end end
for _, L in ipairs(locks) do
  L.m, L.n, L.T, L.S = A.tube(L[1], wfn(L[2]))
end
-- lock outline scallops: notch the edges so the silhouette reads as fluffy strands
for li, L in ipairs(locks) do
  local cut = {}
  L.m:each(function(x, y) local k = K(x, y)
    if abs(L.S[k]) > 0.6 and L.T[k] > 0.2 and X.hash(x, y, li * 7) > 0.5 then cut[#cut + 1] = k end end)
  for _, k in ipairs(cut) do L.m.s[k] = nil end
end

local tok = { r = { name = "fur" } }
local function rampAt(t)
  if t < 0.16 then return UNDER elseif t > 0.78 then return TIP else return TAWNY end
end
local painted = HP.mask()
for li, L in ipairs(locks) do
  local bias = {}
  -- AO: later locks (in front) darken this one where they meet
  for j = li + 1, #locks do X.ao(bias, L.m, locks[j].m, 2, -1) end
  local v = X.light(L.n, { amb = 0.1, wrap = 0.35 })
  L.m:each(function(x, y) local k = K(x, y)
    local i = 1
    for j, cu in ipairs{ 0.18, 0.34, 0.5, 0.66, 0.82 } do if v[k] >= cu then i = j + 1 end end
    local t, s = L.T[k], L.S[k]
    -- strand lines: stripes along the lock, wavering with t
    local q = s * L[2] + 0.6 * sin(t * 9 + li)
    if (q % 2.2) < 0.75 then i = i - 1 end
    i = max(1, min(6, i + (bias[k] or 0)))
    -- tip band boundary is ragged
    local tt = t + 0.05 * (X.hash(floor(s * 4), li, 3) - 0.5)
    c:put(x, y, rampAt(tt)[i], tok)
  end)
  painted:add(L.m)
end
-- a few lit strand highlights on the front lock
for _, t in ipairs{ 0.36, 0.42, 0.48 } do
  local x, y = A.bez(locks[4][1], t) c:put(floor(x - 1.5), floor(y + 0.5), TAWNY[6], tok)
end
-- loose wisps: 1 px strands curling off lock tips/edges
local wisps = {
  { { 16, 26 }, { 13, 27 }, { 11, 26 } },
  { { 49, 30 }, { 52, 30 }, { 54, 28 } },
  { { 27, 16 }, { 25, 15 }, { 24, 13 } },
  { { 52, 44 }, { 55, 45 }, { 57, 46 } },
}
for _, w in ipairs(wisps) do
  for i, p in ipairs(w) do if not painted:has(p[1], p[2]) or i == 1 then c:put(p[1], p[2], i == 1 and TAWNY[3] or TAWNY[2], tok) end end
end

-- root brush below the tie: short cut fur ends, cream
local brush = HP.mask()
for x = 29, 34 do for y = 49, 52 + ((x % 2 == 0) and 1 or 0) do brush:set(x, y) end end
local bn = X.pillow(brush, 2)
local bv = X.light(bn, { amb = 0.15, wrap = 0.3 })
brush:each(function(x, y) local k = K(x, y)
  local i = bv[k] > 0.7 and 5 or (bv[k] > 0.45 and 4 or 3)
  if y == 49 then i = i - 1 end
  if (x + y) % 3 == 0 then i = i - 1 end
  c:put(x, y, UNDER[max(1, i)], tok) end)

-- twisted red thread wrap: diagonal twist marks, AO above and below
local th = { r = { name = "thread" } }
for x = 28, 35 do
  for y = 46, 48 do
    local i = ((x + y) % 3 == 0) and 4 or (((x + y) % 3 == 1) and 3 or 2)
    if x == 35 or y == 48 then i = max(1, i - 1) end
    c:put(x, y, RED[i], th)
  end
end
-- quirk: loose thread end curling off to the right
local tail = { { 36, 48 }, { 37, 49 }, { 38, 50 }, { 39, 51 }, { 40, 51 }, { 41, 50 }, { 41, 49 }, { 40, 48 } }
for i, p in ipairs(tail) do c:put(p[1], p[2], (i % 2 == 0) and RED[3] or RED[2], th) end
c:put(29, 46, RED[4], th) c:put(30, 46, "#ffc4a8", th)

A.save(c, NAME)

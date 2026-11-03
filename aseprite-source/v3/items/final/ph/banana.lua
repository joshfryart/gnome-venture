-- banana (aR3_3, final single pass). A slim pair of ripe bananas hanging from one shared crown stalk: each finger is a
-- curved tapered tube with the real five-sided cross-section (two lengthwise ridges = bevel: lit lip + dark groove),
-- green-tinged neck, dark dry tip nub, a few sugar freckles, waxy specular on the front finger, cool green bounce on
-- the shade edge, AO where the front finger lies over the back one and where both meet the crown. Crown stalk has a
-- paler fibrous cut end (end grain).
-- quirk: the front banana's tip has split and one strip of peel is curling back, showing the cream flesh.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../_helpers/_aR3_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local NAME = "banana"
local c = G.new2(NAME)

local YEL  = { "#6a3a3e", "#ad6a36", "#d99c2e", "#f2c434", "#ffdf66", "#fff2a6" }
local NECK = { "#2c4636", "#4b6e3a", "#78983e", "#a5b844", "#cdd664", "#e8ec98" }
local STEM = { "#2a3a2e", "#3f5a36", "#5f7f3e", "#86a04a", "#aec266", "#d0dc92" }
local FLESH = { "#c9a46a", "#ead09a", "#fbefcc" }
local FRECK, FRECK2, BOUNCE, SPEC = "#8f5a2a", "#5e3a2a", "#a3ad62", "#fffbe0"
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }

-- two fingers from the crown at the upper right, curving down then sweeping left and slightly up at the tips
local CX, CY = 45, 15
local fingers = {
  { p = { { CX - 1, CY + 2 }, { 38, 27 }, { 29, 36 }, { 11, 33 } }, wmax = 4.3 },   -- back
  { p = { { CX + 1, CY + 3 }, { 47, 36 }, { 36, 52 }, { 15, 51 } }, wmax = 4.6 },   -- front
}
local function hw(wmax) return function(t)
  if t < 0.1 then return 1.6 + (t / 0.1) * (wmax - 2.6) end               -- neck
  if t > 0.9 then return max(0.9, wmax * (1 - (t - 0.9) / 0.1) ^ 0.7 * 0.6 + 0.6) end
  local u = (t - 0.1) / 0.8
  return wmax - 1 + math.sin(u * math.pi) ^ 0.6 * 1.0
end end
for _, f in ipairs(fingers) do
  f.m, f.n, f.T, f.S, f.samp = G.tube(f.p, hw(f.wmax))
end
-- crown stalk (painted first; fingers' necks sit over its bottom)
local sm, sn, ST, SS = X.cyl(CX + 0.5, CY + 3, CX + 2.5, CY - 5, function(t) return 2.0 - t * 0.3 end)
local stok = { r = { name = "stem" } }
local sb = {}
X.ao(sb, sm, fingers[1].m:copy():add(fingers[2].m), 2, -1)
G.toneN(c, sm, sn, STEM, { tok = stok, cuts = CUTS, bias = sb })
-- fibrous lengthwise lines on the stalk
sm:each(function(x, y) local k = K(x, y) if abs(SS[k] - 0.25) < 0.16 and ST[k] > 0.25 then c:put(x, y, STEM[2], stok) end end)
-- pale cut end (end grain), slightly oval, with fibre dots
local cap = G.rell(CX + 2.7, CY - 5.2, 0.97, -0.24, 2.0, 1.3)
cap:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and "#b9b07a" or "#e2dcaa", stok) end)
c:put(floor(CX + 3), floor(CY - 5), "#8f8a5a", stok)

for fi, f in ipairs(fingers) do
  local tok = { r = { name = "finger" .. fi } }
  local v = X.light(f.n, { amb = 0.06, wrap = 0.22 })
  local bias = {}
  if fi == 1 then
    X.ao(bias, f.m, fingers[2].m, 1, -1) G.cast(bias, f.m, fingers[2].m, -1, -2, -1)
  end
  X.ao(bias, f.m, sm, 1, -1)
  f.m:each(function(x, y) local k = K(x, y) if f.T[k] < 0.06 then bias[k] = (bias[k] or 0) - 1 end end)
  local idx = X.tone(c, f.m, v, YEL, { cuts = CUTS, bias = bias, tok = tok })
  local LEN = 0
  for i = 2, #f.samp do LEN = LEN + sqrt((f.samp[i].x - f.samp[i-1].x) ^ 2 + (f.samp[i].y - f.samp[i-1].y) ^ 2) end
  f.m:each(function(x, y) local k = K(x, y)
    local t, s, i = f.T[k], f.S[k], idx[k]
    -- green-tinged neck
    if t < 0.13 then c:put(x, y, NECK[i], tok) end
    -- lengthwise ridges (five-sided fruit): lit lip on the light side of each, groove on the dark side
    if t > 0.14 and t < 0.9 then
      if abs(s + 0.38) < 0.12 then c:put(x, y, YEL[min(6, i + 1)], tok)
      elseif abs(s + 0.22) < 0.09 then c:put(x, y, YEL[max(1, i - 1)], tok)
      elseif abs(s - 0.42) < 0.1 then c:put(x, y, YEL[max(1, i - 1)], tok) end
    end
    -- sugar freckles
    if t > 0.25 and t < 0.85 and abs(s) < 0.75 and X.hash(x, y, fi + 3) > 0.955 then c:put(x, y, i >= 4 and FRECK or FRECK2, tok) end
  end)
  -- cool green bounce on the lower-right edge
  local rim = X.rim(f.n)
  f.m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.72 and f.S[k] > 0.75 and f.T[k] > 0.25 and f.T[k] < 0.85 then c:put(x, y, BOUNCE, tok) end end)
  -- dark dry tip nub
  local s = f.samp[#f.samp]
  local tx, ty = s.tx, s.ty
  for d = 0, 1 do c:put(floor(s.x - tx * d + .5), floor(s.y - ty * d + .5), "#3a2626", tok) end
  c:put(floor(s.x - tx * 2 + .5), floor(s.y - ty * 2 + .5), "#6e4630", tok)
  f.tok = tok f.idx = idx
end
-- waxy specular streak on the lit ridge of the front finger + one glint
do local f = fingers[2]
  for _, q in ipairs{ 0.34, 0.37, 0.40, 0.43, 0.46 } do
    local s = f.samp[floor(q * 160) + 1]
    local x, y = floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5)
    if f.m:has(x, y) then c:put(x, y, YEL[6], f.tok) end
  end
  local s = f.samp[floor(0.4 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5), SPEC, f.tok)
end
-- quirk: front tip split, one peel strip curling back below it, cream flesh showing
do local f = fingers[2]
  local s = f.samp[floor(0.93 * 160) + 1]
  local ftok = { r = { name = "flesh" } }
  -- flesh wedge on the lit half of the tip
  f.m:each(function(x, y) local k = K(x, y)
    if f.T[k] > 0.885 and f.T[k] < 0.965 and f.S[k] < 0.15 then
      c:put(x, y, f.S[k] < -0.45 and FLESH[3] or FLESH[2], ftok)
    end
    if f.T[k] > 0.875 and f.T[k] <= 0.885 and f.S[k] < 0.15 then c:put(x, y, FLESH[1], ftok) end
  end)
  -- curled peel strip hanging from the split, 1-2 px wide
  local x0, y0 = floor(s.x + .5), floor(s.y + s.w + 1.5)
  local curl = {
    "yY..",
    "yY..",
    ".yY.",
    ".dyY",
    "..dy",
    ".dd.",
  }
  G.map(c, x0 - 1, y0 - 1, curl, { y = YEL[4], Y = YEL[5], d = YEL[2] }, { r = { name = "peel" } })
end
G.save2(c, NAME)

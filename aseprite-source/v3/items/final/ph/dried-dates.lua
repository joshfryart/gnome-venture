-- dried-dates (Opus single pass). Two whole Medjool-style dates and one halved date lying across a slim
-- date-palm leaflet (diagonal, V-folded, pale midrib, parallel veins, torn base).
-- Material: per-pixel ellipsoid light on a 6-tone glossy amber-brown ramp, wavy lengthwise wrinkles (dark crease
-- + lit lip), papery tan calyx cap at the stem end, cream specular, cool reflected light lower-right, contact
-- shadows on the leaf. Half date: thin skin ring, honey flesh, grooved pit.
-- quirk: the halved date shows its long grooved pit, sitting in the flesh like a little canoe.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min = math.floor, math.abs, math.sin, math.cos, math.max, math.min
local c = A.new("dried-dates")
local DT    = { "#2a1218", "#4e1f1c", "#73321f", "#9a4a24", "#c06c2e", "#e39a4a" }
local FLESH = { "#7a4224", "#a8642f", "#c98a45", "#dfaa60", "#efc887", "#fbe4b0" }
local PIT   = { "#24141a", "#3e2222", "#5a3226", "#7a4630", "#9a6040", "#c08458" }
local CAP   = { "#6a4a2a", "#a07a48", "#d2ae74" }
local LEAF  = { "#1c3f30", "#2a5a3a", "#3b7442", "#56914a", "#7aae56", "#a6c972" }
local SPEC, BOUNCE = "#fff1cf", "#7a4660"

-- dates first as masks (for contact shadows on the leaf)
local ANG = 1.0
local dates = {
  { 19, 39, 9.5, 4.4, ANG + 0.08, 1 },
  { 31, 31, 9.0, 4.2, ANG - 0.06, 2 },
  { 44, 25, 9.0, 4.4, ANG + 0.04, 3 },   -- halved
}
local D = {}
local all = HP.mask()
for i, d in ipairs(dates) do
  local m, n, U, V = A.oval(d[1], d[2], d[3], d[4], d[5], 0.9)
  D[i] = { m = m, n = n, U = U, V = V, d = d }
  all:add(m)
end

-- leaflet: slim V-folded blade low-left -> up-right
local lm, ln, LT, LS, llen = A.blade(6, 52, 30, 40, 58, 17, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 4.6 * math.sin(math.pi * min(1, 0.18 + t * 0.86)) ^ 0.6)
end, { fold = 0.6 })
-- torn base: ragged cut
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.03 + X.hash(floor(LS[k] * 4), 2, 5) * 0.05 then lm.s[k] = nil end end)
local lb = {}
A.cast(lb, lm, all, 1, 2, -2)
A.cast(lb, lm, all, 0, 1, -1)
local lidx = A.tone(c, lm, ln, LEAF, { bias = lb, amb = 0.12 })
local ltok = { r = { name = "leaf" } }
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if all:has(x, y) then return end
  local i = lidx[k] or 3
  if abs(s) < 0.13 and t > 0.05 and t < 0.93 then c:put(x, y, i >= 3 and LEAF[6] or LEAF[4], ltok)          -- midrib
  elseif abs(abs(s) - 0.55) < 0.1 and t > 0.08 and t < 0.85 then c:put(x, y, LEAF[max(1, i - 1)], ltok) end -- parallel vein
end)

-- dates, back (upper-right) to front
local wtok = { r = { name = "date" } }
for i = 3, 1, -1 do
  local q = D[i]
  local m, n, U, V, d = q.m, q.n, q.U, q.V, q.d
  local bias = {}
  -- ambient: the date in front darkens this one where they nearly touch
  for j = 1, i - 1 do X.ao(bias, m, D[j].m, 1, -1) end
  if i ~= 3 then
    -- wrinkles: wavy lengthwise creases with a lit lip above each
    m:each(function(x, y) local k = K(x, y)
      local u, v = U[k], V[k]
      local ph = v * 9.5 + 0.9 * sin(u * 6.5 + i * 1.7)
      local cr = cos(ph)
      if abs(u) < 0.86 then
        if cr > 0.86 then bias[k] = (bias[k] or 0) - 1
        elseif cos(ph + 0.9) > 0.9 then bias[k] = (bias[k] or 0) + 1 end
      end
      -- a couple of short cross wrinkles near the ends
      if abs(abs(u) - 0.72) < 0.05 and abs(v) < 0.6 then bias[k] = (bias[k] or 0) - 1 end
    end)
    A.tone(c, m, n, DT, { bias = bias, amb = 0.06, wrap = 0.2 })
    A.bounce(c, m, n, BOUNCE, 0.6, wtok)
    -- specular streak along the lit shoulder + cream glint
    local gx, gy = A.glint(c, m, n, SPEC, DT[6], wtok, 30)
    -- calyx cap at the stem end (u = -1, upper-left end)
    local ca, sa = cos(d[5]), sin(d[5])
    local ex, ey = d[1] - ca * (d[3] - 0.6), d[2] - sa * (d[3] - 0.6)
    local cx0, cy0 = floor(ex + 0.5), floor(ey + 0.5)
    c:put(cx0, cy0, CAP[3], wtok) c:put(cx0 + 1, cy0, CAP[2], wtok) c:put(cx0, cy0 + 1, CAP[2], wtok)
    c:put(cx0 + 1, cy0 + 1, CAP[1], wtok)
  else
    -- halved date: skin ring, flesh face, pit
    local skin = m:copy():cut(m:shrink(1))
    local face = m:shrink(1)
    local fn = X.pillow(face, 2.2)
    local fb = {}
    face:each(function(x, y) if X.hash(x, y, 31) > 0.86 then fb[K(x, y)] = -1 end end)   -- fibrous flesh
    A.tone(c, face, fn, FLESH, { bias = fb, amb = 0.15 })
    local sb = {}
    A.tone(c, skin, n, DT, { bias = sb, amb = 0.1 })
    local pm, pn, PU, PV = A.oval(d[1] + 0.3, d[2] + 0.3, 6.4, 2.1, d[5], 0.8)
    pm:clip(face)
    local pb = {}
    -- shadow ring of flesh around the pit (it sits in a hollow)
    X.ao(pb, face, pm, 1, -2)
    face:each(function(x, y) local k = K(x, y) if pb[k] and not pm:has(x, y) then c:put(x, y, FLESH[2]) end end)
    local gb = {}
    pm:each(function(x, y) local k = K(x, y) if abs(PV[k]) < 0.28 and abs(PU[k]) < 0.8 then gb[k] = -2 end end)
    A.tone(c, pm, pn, PIT, { bias = gb, amb = 0.1 })
    local px, py = A.glint(c, pm, pn, SPEC, nil, nil, 30)
    A.bounce(c, skin, n, BOUNCE, 0.7, wtok)
  end
end
A.done(c, "dried-dates")

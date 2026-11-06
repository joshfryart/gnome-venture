-- kelp-frond (final, Opus single pass). One slim ribbon blade of golden-olive kelp sweeping up in an S from a glossy
-- round gas bladder, a thin stipe and a claw-like holdfast of branching haptera below. Material: per-pixel ribbon
-- light with corrugated cross-ripples (bullate blade), wavy ruffled margins, pale midline sheen, wet specular glints,
-- cool reflected light on the shade edge, AO where blade, bladder and stipe meet.
-- quirk: a single seawater drop is about to fall from the blade tip.
local NAME = "kelp-frond"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local KELP = { "#2c2730", "#4a4426", "#6e6524", "#958a2c", "#bbb043", "#e0d77c" }
local BLAD = { "#3a2626", "#6a4424", "#986628", "#c08c32", "#e2b650", "#fbe39a" }
local HOLD = { "#2e1f24", "#4d3226", "#6f4a30", "#93673e", "#b88a56" }
local COOL, SHEEN = "#4d6a6c", "#f2eaa8"

-- blade: S-curve from the bladder (lower left) to the tip (upper right)
local bp = { { 22, 41 }, { 15, 24 }, { 46, 32 }, { 53, 8 } }
local function bw(t)
  if t > 0.985 then return 0 end
  local base = 4.3 * sin(pi * min(1, t * 0.82 + 0.1)) ^ 0.55
  return max(0.6, base + 0.75 * sin(t * 46))
end
local blm, bln, BT, BS, samp = A.tube(bp, bw)
-- corrugation: tilt the normal along the blade in a ripple
local N = #samp - 1
local rn = {}
blm:each(function(x, y) local k = K(x, y)
  local s = samp[floor(BT[k] * N) + 1]
  local r = 0.55 * sin(BT[k] * 46 + BS[k] * 1.2)
  local n = bln[k]
  rn[k] = { A.norm(n[1] + s.tx * r, n[2] + s.ty * r, n[3]) }
end)
-- bladder + stipe + holdfast
local bm, bn = A.oval(22, 42, 3.6, 3.1, 0.6, 1.0)
local stp = { { 15, 53 }, { 17, 50 }, { 19, 47 }, { 21, 45 } }
local sm, sn = A.tube(stp, function(t) return 1.3 - t * 0.2 end)
local hapt = {
  { { 15, 53 }, { 12, 54 }, { 10, 55 }, { 8, 58 } },
  { { 15, 53 }, { 14, 56 }, { 13, 57 }, { 13, 59 } },
  { { 15, 53 }, { 17, 56 }, { 19, 57 }, { 20, 59 } },
  { { 15, 53 }, { 11, 52 }, { 9, 51 }, { 7, 52 } },
  { { 16, 53 }, { 19, 54 }, { 22, 55 }, { 24, 57 } },
}
local hm, hn = HP.mask(), {}
for _, p in ipairs(hapt) do
  local m, n = A.tube(p, function(t) return 1.05 - t * 0.35 end)
  m:each(function(x, y) if not hm:has(x, y) then hm:set(x, y) hn[K(x, y)] = n[K(x, y)] end end)
end
do local m = A.rell(15, 53, 1, 0, 2.2, 1.6) local n = X.sphere(15, 52, 2.5, m)
  m:each(function(x, y) hm:set(x, y) hn[K(x, y)] = n[K(x, y)] end) end

local htok = { r = { name = "holdfast" } }
local hb = {}
X.ao(hb, hm, sm, 1, -1)
A.shade(c, hm, hn, HOLD, { tok = htok, bias = hb, cuts = { 0.2, 0.4, 0.6, 0.8 }, amb = 0.1 })
-- haptera tips: pale grippy ends
for _, p in ipairs(hapt) do local e = p[4] if hm:has(e[1], e[2]) then c:put(e[1], e[2], HOLD[5], htok) end end

local stok = { r = { name = "stipe" } }
sm:cut(bm)
local sb = {} X.ao(sb, sm, bm, 1, -1)
A.shade(c, sm, sn, KELP, { tok = stok, bias = sb, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.1 })

-- blade
local btok = { r = { name = "blade" } }
blm:cut(bm)
local bb = {} X.ao(bb, blm, bm, 2, -1)
local bidx = A.shade(c, blm, rn, KELP, { tok = btok, bias = bb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
-- pale midline sheen (a faint ridge), broken by the ripples
blm:each(function(x, y) local k = K(x, y)
  if abs(BS[k]) < 0.16 and BT[k] > 0.06 and BT[k] < 0.9 and (bidx[k] or 1) >= 3 then
    c:put(x, y, KELP[min(6, bidx[k] + 1)], btok) end end)
-- cool reflected light on the lower-right edge
local rim = X.rim(bln)
blm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and BS[k] > 0.7 and not bb[k] then c:put(x, y, COOL, btok) end end)
-- wet glints on two ripple crests
for _, t in ipairs{ 0.3, 0.62 } do
  local s = samp[floor(t * N) + 1]
  local x, y = floor(s.x - s.px * s.w * 0.4 + .5), floor(s.y - s.py * s.w * 0.4 + .5)
  if blm:has(x, y) then c:put(x, y, SHEEN, btok) end
end

-- bladder: glossy amber float
local otok = { r = { name = "bladder" } }
A.shade(c, bm, bn, BLAD, { tok = otok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.3 })
local brim = X.rim(bn)
bm:edge():each(function(x, y) if brim[K(x, y)] > 0.6 then c:put(x, y, "#7a5a6a", otok) end end)
do local x, y = A.specAt(bm, bn, 30) c:put(x, y, A.CREAM, otok) c:put(x + 1, y, BLAD[6], otok) end

-- quirk: seawater drop leaving the tip (1 px air between)
local tx, ty = A.bez(bp, 1)
local dx, dy = floor(tx + 2.5), floor(ty + 3.5)
c:paint({ ".s.", "sbs", "bbd", ".d." }, dx - 1, dy, { s = "#b6f0e0", b = "#5fc4c8", d = "#3a86b0" })
c:put(dx - 1 + 0, dy + 1, A.CREAM)
A.save(c, NAME)

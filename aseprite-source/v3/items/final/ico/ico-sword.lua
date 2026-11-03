-- ico-sword (final, Opus, aR0_0). Slim arming sword on the diagonal, tip upper-right, bold enough for 16 px.
-- Blade: diamond section toned per diagonal row (bright honed edge on the lit side, lit bevel, ridge, shade bevel,
-- cool reflected light on the shade edge), a sunk fuller (dark wall, deep groove, lit lip) that stops short of the
-- tip, a specular streak and one cream glint. Gold crossguard with forward-swept quillons ending in balls and a
-- ruby boss; leather grip in a twisted cord wrap; gold pommel ball with a bevel ring. AO where blade, grip and
-- pommel meet the guard.
-- quirk: a little red tassel hangs from the pommel, its cord knotted.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-sword")
local ST = { "#2c2b46", "#46486a", "#6a6d90", "#979ab6", "#c4c7da", "#eceef6" }
local GD = { "#6a3418", "#9a561e", "#cf8524", "#f2b232", "#ffd85e", "#fff2a6" }
local LT = { "#2a1714", "#44261c", "#633923", "#86512c", "#aa6e3a", "#cf9050" }
local RB = { "#4e1030", "#8a1a3a", "#c62a40", "#ee4a48", "#ff8a72", "#ffd0b8" }
local TS = { "#5e1a30", "#9a2a3a", "#d0443e", "#f2725a" }
local BOUNCE, SPEC = "#8396c8", "#fff4d6"
local btok, gtok, ltok, rtok, ttok = { r = { name = "blade" } }, { r = { name = "gold" } }, { r = { name = "leath" } },
  { r = { name = "ruby" } }, { r = { name = "tassel" } }

local F = A.frame(13, 51, 1, -1)   -- u: pommel -> tip ; v > 0 lower-right (shade side)
local UMAX = 56.5
local function rnd(x, y) return floor(x + .5), floor(y + .5) end

-- blade
local bm, BU, BJ = HP.mask(), {}, {}
for y = 0, 63 do for x = 0, 63 do
  local u, v = F.UV(x, y)
  if u >= 17 and u <= UMAX then
    local w = 3.0
    if u > UMAX - 11 then w = 3.0 * ((UMAX - u) / 11) ^ 0.85 + 0.1 end
    if u > UMAX - 1.2 then w = -1 end
    if abs(v) <= w then bm:set(x, y) BU[K(x, y)] = u BJ[K(x, y)] = floor(v / 0.7071 + 0.5) end
  end
end end
local OUTER = { [-4] = 6, [-3] = 5, [-2] = 5, [-1] = 5, [0] = 4, [1] = 3, [2] = 3, [3] = 3, [4] = 2 }
local FULL  = { [0] = 1, [1] = 4 }
local bidx = {}
bm:each(function(x, y) local k = K(x, y) local u, j = BU[k], BJ[k]
  local i = OUTER[j] or 3
  if u > 20 and u < 43 and FULL[j] then i = FULL[j] end
  if u > 43 and u < 44.6 and j == 0 then i = 2 end            -- rounded end of the fuller
  if u < 19.2 then i = max(1, i - 1) end                       -- AO at the guard
  bidx[k] = i c:put(x, y, ST[i], btok)
end)
-- shade edge reflected light; outermost lit edge bright
bm:edge():each(function(x, y) local k = K(x, y) local u = BU[k]
  local _, v = F.UV(x, y)
  if v > 0.6 and u > 20 and u < UMAX - 2 then c:put(x, y, BOUNCE, btok) end end)
-- specular streak on the lit bevel and a glint near the tip
for u = 24, 37 do local x, y = rnd(F.W(u, -2.0)) if bm:has(x, y) then c:put(x, y, ST[6], btok) end end
do local x, y = rnd(F.W(47.5, -1.2)) c:put(x, y, SPEC, btok) end

-- grip: leather in a twisted cord wrap
local ax, ay = F.W(4.6, 0) local bx, by = F.W(15.0, 0)
local gm, gn, GT, GS = X.cyl(ax, ay, bx, by, function(t) return 1.75 end)
gm:cut(bm)
local gb = {}
gm:each(function(x, y) local k = K(x, y) local t = GT[k] if t > 0.86 or t < 0.08 then gb[k] = -1 end end)
local gidx = A.shade(c, gm, gn, LT, { amb = 0.12, wrap = 0.3, bias = gb, tok = ltok })
gm:each(function(x, y) local k = K(x, y)
  local u = F.UV(x, y)
  local f = ((u + GS[k] * 1.6) / 2.3) % 1
  local i = gidx[k] or 3
  if f < 0.24 then c:put(x, y, LT[max(1, i - 2)], ltok)
  elseif f > 0.36 and f < 0.62 and GS[k] < 0.2 then c:put(x, y, LT[min(6, i + 1)], ltok) end
end)

-- crossguard: forward-swept bar with ball ends
local cg, cgn = HP.mask(), {}
for y = 0, 63 do for x = 0, 63 do
  local u, v = F.UV(x, y)
  if abs(v) <= 8.2 then
    local u0 = 16.2 + 0.035 * v * v
    local s = (u - u0) / 1.55
    if abs(s) <= 1 then cg:set(x, y)
      local sn = max(-0.95, min(0.95, s))
      cgn[K(x, y)] = { A.norm(F.dx * sn, F.dy * sn, sqrt(1 - sn * sn)) } end
  end
end end
for _, sd in ipairs({ -1, 1 }) do
  local v = sd * 8.6 local u0 = 16.2 + 0.035 * v * v
  local cx, cy = F.W(u0, v)
  local em = HP.ellipse(cx - 0.5, cy - 0.5, 2.0, 2.0)
  local en = X.sphere(cx - 0.5, cy - 0.5, 2.0, em)
  em:each(function(x, y) cg:set(x, y) cgn[K(x, y)] = en[K(x, y)] end)
end
local cidx = A.shade(c, cg, cgn, GD, { amb = 0.12, wrap = 0.3, tok = gtok })
-- ruby boss
do
  local cx, cy = F.W(16.4, 0)
  local rm = HP.ellipse(cx - 0.5, cy - 0.5, 1.6, 1.6)
  local ring = rm:grow(1):cut(rm)
  ring:each(function(x, y) c:put(x, y, GD[2], gtok) end)
  local rn = X.sphere(cx - 0.5, cy - 0.5, 1.6, rm)
  A.shade(c, rm, rn, RB, { amb = 0.15, wrap = 0.3, tok = rtok })
  local sx, sy = A.specAt(rm, rn, 30) c:put(sx, sy, RB[6], rtok)
end

-- pommel: gold ball with a bevel ring toward the grip
local px, py = F.W(1.8, 0)
local pm = HP.ellipse(px - 0.5, py - 0.5, 3.1, 3.1)
pm:cut(gm)
local pn = X.sphere(px - 0.5, py - 0.5, 3.1, pm)
local pb = {}
pm:each(function(x, y) local u = F.UV(x, y) if u > 3.6 then pb[K(x, y)] = -1 end end)
A.shade(c, pm, pn, GD, { amb = 0.1, wrap = 0.25, bias = pb, tok = gtok })
do local sx, sy = A.specAt(pm, pn, 30) c:put(sx, sy, GD[6], gtok) end
-- neck ring between grip and pommel
for v = -1.6, 1.6, 0.5 do local x, y = rnd(F.W(4.4, v)) c:put(x, y, v < 0 and GD[4] or GD[2], gtok) end

-- quirk: knotted red tassel hanging from the pommel
local tx, ty = rnd(F.W(-1.6, 0.9))
local T = {
  ".ab.",
  ".bc.",
  "..b.",
  ".abc",
  ".bcc",
  "abbc",
  "abcd",
  "a.c.",
}
local TP = { a = TS[3], b = TS[2], c = TS[1], d = TS[1] }
T[1] = ".ab."
A.map(c, T, tx - 2, ty + 1, { a = TS[4], b = TS[3], c = TS[2], d = TS[1] }, ttok)
c:put(tx - 1, ty + 4, GD[5], gtok) c:put(tx, ty + 4, GD[4], gtok)  -- gold cap on the tassel

A.save(c, "ico-sword")

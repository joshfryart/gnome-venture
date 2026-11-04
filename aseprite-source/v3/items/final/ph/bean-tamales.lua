-- bean-tamales (final pass, Opus). Two slim corn-husk tamales. Back: still wrapped, a husk cylinder pinched and tied
-- near both ends with twisted husk strips, the ends flaring into fringed husk fans; long husk fibres run along it.
-- Front: unwrapped, the husk opened into a boat (concave inner face lit low, curled lit rim on top, shaded rim below,
-- fibre lines) cradling a golden masa log (per-pixel cylinder light, 6-tone ramp, coarse corn grain, glossy top
-- streak) studded with red-brown beans, each with its own glint. Ambient row where the masa sits in the husk and a
-- contact shadow where the front tamale overlaps the back one.
-- History: Sonnet draft (_dA14) replaced.
-- quirk: someone has already taken a bite out of the end of the masa log (tooth scallops, beans cut in section).
local NAME = "bean-tamales"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local HUSK = { "#5a3a22", "#86602f", "#ad8648", "#cfac68", "#e9cd8c", "#f9ebbc" }
local TIE  = { "#33301a", "#514a24", "#736a32", "#978e48", "#bcb466" }
local MASA = { "#7e3e1c", "#b06424", "#d68a30", "#eeb045", "#f9cf6a", "#ffeaa0" }
local BEAN = { "#2e1018", "#521e26", "#7a2c2c", "#a2443a", "#f0c8a0" }

local function husk(ax, ay, bx, by, body, pinch, flare, ties, tok, opts)
  opts = opts or {}
  local function wfn(t)
    local e = min(t, 1 - t)
    if e < 0.12 then return pinch + (flare - pinch) * ((0.12 - e) / 0.12) ^ 0.8 end
    if e < 0.2 then return pinch + (body - pinch) * sin(pi / 2 * (e - 0.12) / 0.08) end
    return body
  end
  local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)
  local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  -- fringe: notch the flared ends
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local d = min(T[k], 1 - T[k]) * len
    if d < 2.4 then
      local w = wfn(T[k])
      local col = floor((S[k] + 1) * w * 0.5 + 0.5)
      local depth = (col % 2 == 0) and 2.0 or 0.6 + 0.6 * X.hash(col, T[k] < 0.5 and 1 or 2, 9)
      if d < depth then cut[#cut + 1] = k end
    end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m, n, T, S, len, wfn
end

-- ---------------------------------------------------------------- back tamale (wrapped, tied)
local B_AX, B_AY, B_BX, B_BY = 11, 31, 49, 19
local bm, bn, BT, BS, blen, bw = husk(B_AX, B_AY, B_BX, B_BY, 4.6, 2.0, 4.2)
-- front tamale geometry first (for the contact shadow on the back one)
local F_AX, F_AY, F_BX, F_BY = 9, 50, 55, 36
local fm, fn0, FT, FS, flen, fw = husk(F_AX, F_AY, F_BX, F_BY, 6.6, 2.6, 5.0)
local btok = { r = { name = "backhusk" } }
local bb = {}
A.cast(bb, bm, fm, 0, -1, -1) X.ao(bb, bm, fm, 1, -1)
local bidx = A.shade(c, bm, bn, HUSK, { tok = btok, bias = bb, amb = 0.04, wrap = 0.15, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 } })
-- husk fibres along the length; overlap seam (wrap edge) along the upper third
bm:each(function(x, y) local k = K(x, y)
  local w = bw(BT[k])
  local q = (BS[k] + 1) * w
  if (q % 2.6) < 0.5 and abs(BS[k]) < 0.8 then A.step(c, bidx, HUSK, x, y, -1, btok) end
  if abs(BS[k] + 0.35) < 0.09 and BT[k] > 0.2 and BT[k] < 0.8 then c:put(x, y, HUSK[2], btok) end
end)
-- twisted tie strips at the pinches
local function tie(m, T, S, len, w, t0, tok)
  m:each(function(x, y) local k = K(x, y)
    local d = (T[k] - t0) * len
    if abs(d) < 1.6 then
      local i = (S[k] < -0.3) and 4 or (S[k] < 0.35) and 3 or 2
      if floor(S[k] * w + d + 10) % 2 == 0 then i = i + 1 end      -- twist: alternating diagonal ridges
      if abs(S[k]) > 0.85 then i = i - 1 end
      c:put(x, y, TIE[max(1, min(5, i))], tok)
    end
  end)
end
tie(bm, BT, BS, blen, 2.4, 0.13, btok) tie(bm, BT, BS, blen, 2.4, 0.87, btok)
-- loose tie end flicking up off the right knot
for _, q in ipairs{ { 45, 17, 3 }, { 46, 16, 4 }, { 46, 15, 3 }, { 47, 14, 2 } } do c:put(q[1], q[2], TIE[q[3]], btok) end

-- ---------------------------------------------------------------- front tamale (opened husk boat + masa)
local ftok = { r = { name = "fronthusk" } }
local ux, uy = (F_BX - F_AX) / flen, (F_BY - F_AY) / flen
local px, py = -uy, ux
if px + py < 0 then px, py = -px, -py end
local nb = {}
fm:each(function(x, y) local k = K(x, y)
  local s = FS[k]
  if abs(s) < 0.72 then                                    -- concave inner face
    local sn = -s * 0.55
    nb[k] = { A.norm(px * sn, py * sn, 1) }
  else nb[k] = fn0[k] end                                  -- curled convex rims
end)
local fidx = A.shade(c, fm, nb, HUSK, { tok = ftok, amb = 0.12, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 } })
fm:each(function(x, y) local k = K(x, y) local s = FS[k]
  if s < -0.72 and s > -0.86 then c:put(x, y, HUSK[6], ftok) end         -- lit curl crest
  if s > 0.72 and s < 0.84 then c:put(x, y, HUSK[2], ftok) end           -- fold line of the lower rim
  local q = (s + 1) * fw(FT[k])
  if abs(s) < 0.7 and (q % 2.6) < 0.5 then A.step(c, fidx, HUSK, x, y, -1, ftok) end
end)
tie(fm, FT, FS, flen, 3, 0.12, ftok)

-- masa log on the inner face
local MO = -1.4                                            -- shift toward the lit (upper) side
local mx0, my0 = F_AX + ux * flen * 0.18 + px * MO, F_AY + uy * flen * 0.18 + py * MO
local mx1, my1 = F_AX + ux * flen * 0.8 + px * MO, F_AY + uy * flen * 0.8 + py * MO
local mm, mn, MT, MS = X.cyl(mx0, my0, mx1, my1, function(t) return 3.6 end)
-- rounded log ends
mm:add(c:ellipse(mx0, my0, 3.4, 3.4)):clip(fm)
local mlen = sqrt((mx1 - mx0) ^ 2 + (my1 - my0) ^ 2)
-- quirk: a bite out of the right end (two tooth scallops)
local bx, by = mx1 + ux * 1.2 - px * 1.0, my1 + uy * 1.2 - py * 1.0
local bite = c:ellipse(bx - ux * 0.8, by - uy * 0.8, 3.4, 3.4):add(c:ellipse(bx - ux * 1.6 + px * 3.0, by - uy * 1.6 + py * 3.0, 2.4, 2.4))
mm:cut(bite)
local mn2 = X.pillow(mm, 2.4)
for k, a in pairs(mn2) do local b = mn[k]
  if b then mn2[k] = { A.norm(a[1] * 0.4 + b[1], a[2] * 0.4 + b[2], a[3] * 0.4 + b[3]) } end end
-- husk ambient where the masa sits
local fb = {}
X.ao(fb, fm, mm, 1, -1)
fm:each(function(x, y) local k = K(x, y) if fb[k] and not mm:has(x, y) then A.step(c, fidx, HUSK, x, y, -1, ftok) end end)
mm:shift(1, 1):each(function(x, y) if fm:has(x, y) and not mm:has(x, y) then A.step(c, fidx, HUSK, x, y, -1, ftok) end end)
local mtok = { r = { name = "masa" } }
local midx = A.shade(c, mm, mn2, MASA, { tok = mtok, amb = 0.1, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
-- coarse corn grain + bitten face (paler, flatter) along the bite rim
mm:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 21)
  if h > 0.92 then A.step(c, midx, MASA, x, y, 1, mtok) elseif h < 0.05 then A.step(c, midx, MASA, x, y, -1, mtok) end
end)
bite:grow(1):cut(bite):each(function(x, y) if mm:has(x, y) then A.step(c, midx, MASA, x, y, 1, mtok) end end)
-- glossy top streak
for i = 0, 7 do local t = 0.18 + i * 0.07
  local x, y = floor(mx0 + (mx1 - mx0) * t - px * 2.2 + 0.5), floor(my0 + (my1 - my0) * t - py * 2.2 + 0.5)
  if mm:has(x, y) and i % 4 ~= 3 then c:put(x, y, MASA[6], mtok) end
end
-- beans studded in the masa (whole ones, and two cut in section at the bite)
local btk = { r = { name = "beans" } }
local function bean(x, y, horiz)
  -- kidney bean, 4x2 (or 2x3 end-on), lit top, dark belly, one glint; ambient row in the masa below it
  local pts = horiz and { { 1, 0, 4 }, { 2, 0, 4 }, { 3, 0, 3 }, { 0, 1, 3 }, { 1, 1, 2 }, { 2, 1, 2 }, { 3, 1, 1 } }
                     or { { 0, 0, 4 }, { 1, 0, 3 }, { 0, 1, 3 }, { 1, 1, 2 }, { 0, 2, 2 }, { 1, 2, 1 } }
  local ok = true
  for _, q in ipairs(pts) do if not mm:has(x + q[1], y + q[2]) then ok = false end end
  if not ok then return end
  for _, q in ipairs(pts) do c:put(x + q[1], y + q[2], BEAN[q[3]], btk) end
  for _, q in ipairs(pts) do local yy = y + q[2] + 1
    if mm:has(x + q[1], yy) and c:get(x + q[1], yy) and not (c.own[yy * 64 + x + q[1]] == btk) then A.step(c, midx, MASA, x + q[1], yy, -1, mtok) end end
  c:put(x + 1, y, BEAN[5], btk)
end
for i, b in ipairs{ { 0.06, 0.05, false }, { 0.2, -0.4, true }, { 0.36, 0.25, true }, { 0.52, -0.45, true }, { 0.66, 0.2, false } } do
  local x = mx0 + (mx1 - mx0) * b[1] + px * b[2] * 3.6
  local y = my0 + (my1 - my0) * b[1] + py * b[2] * 3.6
  bean(floor(x + 0.5), floor(y + 0.5), b[3])
end
bite:clip(fm):each(function(x, y) if not mm:has(x, y) and FS[K(x, y)] and abs(FS[K(x, y)]) < 0.72 then A.step(c, fidx, HUSK, x, y, -1, ftok) end end)
-- beans cut in section on the bitten face
bite:grow(1):cut(bite):each(function(x, y)
  if mm:has(x, y) and X.hash(x, y, 4) > 0.72 then c:put(x, y, BEAN[3], btk) end end)

A.save(c, NAME)

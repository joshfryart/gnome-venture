-- ico-curry (final, Opus). A glazed blue ceramic bowl on a little foot ring: a dome of white rice on the left,
-- glossy golden curry on the right with carrot and potato chunks, a coriander leaf on the rice, one steam curl.
-- Material: bowl = per-pixel ellipsoid light (6 tones), cream glazed lip, painted cream wave band, a tall glaze
-- specular streak, cool reflected light lower-right, AO under the lip; rice = grain marks; curry = 6 tones with
-- wet speculars; ground shadow (it stands).
-- quirk: one drip of curry has escaped over the rim and is running down the outside of the bowl.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-curry")
local BL   = { "#1c2458", "#25428a", "#2f66b0", "#4290d0", "#72bce4", "#c2ecf6" }
local GLZ  = { "#6e5470", "#a8888e", "#d6b8a8", "#f0dcbc", "#fff0d2", "#fffaea" }
local CU   = { "#4a1a16", "#7a2c16", "#a8481a", "#cc6a1e", "#e8902a", "#fbc25a" }
local RI   = { "#6c6284", "#9a92ac", "#c8c0cc", "#e8e0dc", "#faf3e6", "#fffcf2" }
local OR   = { "#6a2236", "#b03a2a", "#e0621f", "#fb983a", "#ffc874" }
local PO   = { "#7a4a26", "#b88238", "#e6b85a", "#fbe08e" }
local LF   = { "#21593f", "#3f9150", "#7cc35a", "#c4e07a" }
local STM  = { "#c8c4dc", "#ece8f2" }
local SPEC = "#fffaea"
local tB, tG, tC, tR, tX = A.tok("bowl"), A.tok("glaze"), A.tok("curry"), A.tok("rice"), A.tok("bits")

local CX, CY = 32, 33          -- rim centre
c:groundShadow(32, 53, 13, 2)

-- foot ring
local foot = c:rrect(24, 47, 40, 51, 1)
local fn = A.ellN(foot, 32, 46, 9, 6)
local fidx = A.shade(c, foot, fn, BL, { tok = tB, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
for x = 24, 40 do A.step(c, fidx, BL, x, 47, -2, tB) end   -- AO under the bowl belly

-- bowl body: lower half-ellipsoid
local body = A.ell(CX, CY, 24, 15):clip(c:rect(0, CY, 63, 63))
local bn = A.ellN(body, CX, CY - 1, 24.5, 16.5)
local bb = {}
body:each(function(x, y) if y <= CY + 1 then bb[K(x, y)] = -1 end end)    -- AO under the glazed lip
local bidx = A.shade(c, body, bn, BL, { bias = bb, tok = tB, amb = 0.06, wrap = 0.3,
  tilt = { 32, 40, 24, 0.1 }, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- painted cream wave band following the bowl's curve
body:each(function(x, y)
  local u = (x - CX) / 24
  local yb = CY + 6.5 + 4 * u * u
  local i = bidx[K(x, y)] or 3
  if abs(u) < 0.95 then
    if y == floor(yb + 0.5) then
      c:put(x, y, i >= 5 and GLZ[5] or (i >= 3 and GLZ[4] or GLZ[3]), tB)
    elseif y == floor(yb + 0.5) + 1 then c:put(x, y, BL[max(1, i - 1)], tB)
    elseif y == floor(yb + 0.5) + 3 and (x % 4 == 0) then c:put(x, y, i >= 3 and GLZ[3] or GLZ[2], tB) end
  end
end)
-- glaze specular streak (upper-left, tall) + glint
for _, p in ipairs{ { 13, 36 }, { 13, 37 }, { 14, 36 }, { 15, 43 }, { 16, 44 }, { 17, 45 } } do c:put(p[1], p[2], BL[6], tB) end
c:put(13, 35, SPEC, tB)
-- cool reflected light along the lower-right edge
body:edge():each(function(x, y)
  local u, v = (x - CX) / 24, (y - CY) / 15
  if u > 0.15 and v > 0.55 and u + v > 1.0 and not foot:has(x, y + 1) then c:put(x, y, "#5a7cc6", tB) end
end)

-- glazed lip: ring around the opening
local outer = A.ell(CX, CY, 24, 5.5)
local inner = A.ell(CX, CY - 0.4, 21, 3.4)
local lip = outer:copy():cut(inner)
local ln = {}
lip:each(function(x, y)
  local u = (x - CX) / 24
  local up = (y < CY) and -0.7 or 0.55
  ln[K(x, y)] = { A.norm(u * 0.7, up, 0.8) }
end)
local lidx = A.shade(c, lip, ln, BL, { tok = tG, amb = 0.3, wrap = 0.4, tilt = { 32, 33, 24, 0.2 }, cuts = { 0.12, 0.26, 0.42, 0.62, 0.82 } })
-- bright glazed edge on the rim's top
lip:each(function(x, y) if not outer:has(x, y - 1) and x < 40 then c:put(x, y, (x < 26) and GLZ[6] or BL[6], tG) end end)

-- curry pool inside the lip (back wall shows as a deep blue sliver)
local pool = inner:copy()
local wall = pool:copy():clip(c:rect(0, 0, 63, CY - 2))
local pn = {}
pool:each(function(x, y) pn[K(x, y)] = { A.norm((x - 38) / 40, -0.35, 1) } end)
local curryM = pool:copy():add(A.ell(39, 31.5, 11, 3.6):clip(c:rect(0, 0, 63, CY + 3))):cut(lip)
local cn = A.ellN(curryM, 39, 32, 13, 5, 0.8)
local cb = {}
curryM:each(function(x, y) if lip:has(x, y + 1) or lip:has(x, y + 2) then cb[K(x, y)] = -1 end end)
local cidx = A.shade(c, curryM, cn, CU, { bias = cb, tok = tC, amb = 0.1, wrap = 0.3, cuts = { 0.24, 0.42, 0.6, 0.76, 0.9 } })
wall:clip(curryM):each(function(x, y) if y <= CY - 3 and x < 30 then c:put(x, y, BL[1], tB) end end)

-- rice dome (left), sits in front of the back lip, behind the front lip
local rice = A.ell(22, 30, 9, 7):clip(c:rect(0, 0, 63, CY + 1))
rice:cut(lip:copy():clip(c:rect(0, CY, 63, 63)))
local rn = A.ellN(rice, 21.5, 31, 9.5, 8)
local rb = {}
X.ao(rb, curryM, rice, 1, -1)
local ridx = A.shade(c, rice, rn, RI, { tok = tR, amb = 0.18, wrap = 0.35, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 } })
-- re-tone curry where the rice shades it
for k, d in pairs(rb) do local x, y = k % 1024 - 256, k // 1024 - 256 if not rice:has(x, y) then A.step(c, cidx, CU, x, y, d - 1, tC) end end
A.touch(curryM, rice):each(function(x, y) if not rice:has(x, y) then c:put(x, y, CU[1], tC) end end)
-- rice grains: short 2x1 dark ticks + lit ticks
rice:each(function(x, y)
  local h = X.hash(x, y, 11)
  local i = ridx[K(x, y)]
  if i and rice:has(x + 1, y) and not rice:edge():has(x, y) then
    if h > 0.86 then A.step(c, ridx, RI, x, y, -1, tR) A.step(c, ridx, RI, x + 1, y, -1, tR)
    elseif h < 0.08 and i >= 4 then c:put(x, y, RI[6], tR) end
  end
end)
-- coriander leaf on top of the rice
local leaf = A.capsule(19, 24.5, 24, 23, 1.4)
local leafN = A.ellN(leaf, 22, 23, 4, 2)
A.shade(c, leaf, leafN, LF, { tok = tX, cuts = { 0.3, 0.55, 0.78 } })
c:put(20, 24, LF[1], tX) c:put(21, 24, LF[1], tX) c:put(22, 23, LF[1], tX)

-- chunks in the curry: carrot (orange cube), potato (pale cube)
local function chunk(x0, y0, w, h, R)
  local m = c:rrect(x0, y0, x0 + w - 1, y0 + h - 1, 1)
  local n = X.pillow(m, 1.4)
  local ix = A.shade(c, m, n, R, { tok = tX, amb = 0.1, wrap = 0.2, cuts = (#R == 5) and { 0.2, 0.42, 0.62, 0.82 } or { 0.3, 0.55, 0.8 } })
  for x = x0, x0 + w - 1 do if curryM:has(x, y0 + h) then c:put(x, y0 + h, CU[1], tC) end end   -- contact shadow
  for y = y0, y0 + h - 1 do if curryM:has(x0 + w, y) and not m:has(x0 + w, y) then c:put(x0 + w, y, CU[2], tC) end end
  return m
end
chunk(32, 29, 4, 4, OR)
chunk(41, 29, 5, 4, PO)
chunk(37, 33, 3, 3, OR)
-- wet speculars on the curry
c:put(47, 32, CU[6], tC) c:put(48, 32, CU[6], tC) c:put(36, 30, SPEC, tC) c:put(30, 33, CU[6], tC)

-- quirk: drip running over the front lip and down the outside of the bowl
local drip = A.capsule(46, 38, 46, 41, 0.6)
drip:add(A.ell(46.5, 42.5, 1.1, 1.1))
local dn = A.ellN(drip, 45.5, 40, 2.5, 5)
local didx = A.shade(c, drip, dn, CU, { tok = tC, amb = 0.1, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
c:put(46, 42, CU[6], tC)
A.touch(body, drip):each(function(x, y) if not drip:has(x, y) and y > 38 then A.step(c, bidx, BL, x, y, -1, tB) end end)
-- curry covering the lip where it spilled
for _, p in ipairs{ { 45, 36 }, { 46, 36 }, { 47, 36 }, { 46, 35 }, { 45, 35 } } do c:put(p[1], p[2], (p[2] == 35) and CU[5] or CU[4], tC) end

-- steam curl (one S, 2 px)
local st = A.union{ c:line({ { 34, 24 }, { 37, 21 }, { 37, 18 }, { 34, 15 }, { 34, 12 }, { 37, 9 } }, 2) }
st:each(function(x, y) c:put(x, y, st:has(x - 1, y) and STM[1] or STM[2], A.tok("steam")) end)

A.save(c, "ico-curry")

-- marzipan (aC22_4, Opus single pass). A slim baked marzipan log lying on a slight diagonal, its top scored in a
-- diamond lattice toasted gold-brown at the ridges, the right end cut clean to show the pale almond paste with
-- flecks; a small marzipan strawberry (sugar seeds, green paste calyx)
-- sits at the front left. Material: soft matte paste lighting (6 tones), toasted ridges, sugar dusting, cut face
-- flecks, AO and contact shadows where the pieces touch.
-- quirk: a bite has been taken out of the cut end.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = G.new("marzipan")
c:groundShadow(32, 44, 24, 2)
local M = G.MARZ
local TOAST = { "#5a2c22", "#84452a", "#b06a34", "#d49444", "#ecbc62", "#f8dc96" }

-- log: tube with a rounded left end, cut right end
local p = { { 9, 24 }, { 20, 26 }, { 32, 28 }, { 44, 31 } }
local lm, ln, LT, LS, samp = G.tube(p, function(t)
  if t < 0.1 then return 7.2 * sqrt(1 - ((0.1 - t) / 0.1) ^ 2) + 0.3 end
  return 7.2
end)
local lb = {}
local lidx, ltok = G.shade(c, lm, ln, M, { bias = lb, amb = 0.12, wrap = 0.3 })
-- toasted diamond lattice on the lit upper half
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if s < 0.35 and t > 0.08 and t < 0.97 then
    local u = t * 30
    local a, b = (u + s * 6) % 5, (u - s * 6) % 5
    if a < 0.7 or b < 0.7 then
      local i = lidx[k] or 3
      c:put(x, y, TOAST[max(1, min(6, i))], ltok)
    end
  end
end)
-- sugar dusting specks on the top
for _, q in ipairs{ { 14, 20 }, { 19, 21 }, { 25, 22 }, { 30, 23 }, { 22, 20 }, { 36, 25 } } do
  if lm:has(q[1], q[2]) then c:put(q[1], q[2], "#fff6e4", ltok) end
end
-- cut face at the right end (ellipse perpendicular to the axis)
local e = samp[#samp]
local face = G.oval(e.x - e.tx * 0.6, e.y - e.ty * 0.6, 2.6, 7.4, math.atan(e.ty, e.tx), 1)
local fm = face
fm:each(function(x, y)
  local dx, dy = x - e.x, y - e.y
  local inner = (abs(dx * e.tx + dy * e.ty) < 1.6) and (abs(dx * e.px + dy * e.py) < 6)
  c:put(x, y, inner and M[6] or M[5], ltok)
end)
-- face rim shade lower edge + almond flecks
fm:edge():each(function(x, y) if (x - e.x) * e.px + (y - e.y) * e.py > 2 then c:put(x, y, M[4], ltok) end end)
for _, d in ipairs{ { -3, M[3] }, { 0, M[4] }, { 3, M[3] }, { -1, "#fff8ea" } } do
  local x, y = floor(e.x + e.px * d[1] + .5), floor(e.y + e.py * d[1] + .5)
  if fm:has(x, y) then c:put(x, y, d[2], ltok) end
end
local logAll = lm:copy():add(fm)

-- quirk: a bite taken out of the top of the cut end (scalloped tooth marks, pale paste inside)
local bite = HP.mask()
for _, q in ipairs{ { 43.5, 24.2, 2.6 }, { 40.6, 23.4, 2.1 } } do bite:add((G.oval(q[1], q[2], q[3], q[3], 0, 1))) end
bite:clip(logAll)
bite:each(function(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end)
bite:grow(1):cut(bite):each(function(x, y) if logAll:has(x, y) then
  c:put(x, y, (x + y) % 2 == 0 and M[6] or M[4], ltok) end end)
c:put(37, 23, "#fff8ea", ltok)
-- strawberry at the front left
local bm, bn = G.oval(16, 37, 4.6, 5.2, -0.2, 1)
-- taper toward the bottom (heart shape)
local cut = HP.mask()
bm:each(function(x, y) local dy = y - 37 if dy > 1 and abs(x - 15.5 - (dy) * 0.25) > 4.6 - (dy - 1) * 0.9 then cut:set(x, y) end end)
bm:cut(cut)
local bB = {}
G.cast(bB, bm, lm, 1, 1, 0)
local bI, bTok = G.shade(c, bm, bn, G.STRAW, { bias = bB, amb = 0.1, wrap = 0.25 })
local rim = X.rim(bn)
bm:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.75 then c:put(x, y, "#b84a6e", bTok) end end)
for _, s in ipairs{ { 14, 36 }, { 17, 35 }, { 19, 38 }, { 15, 39 }, { 17, 41 }, { 13, 38 } } do
  if bm:has(s[1], s[2]) then c:put(s[1], s[2], "#ffe6a0", bTok) if bm:has(s[1] + 1, s[2] + 1) then c:put(s[1] + 1, s[2] + 1, G.STRAW[2], bTok) end end
end
c:put(13, 34, G.SPEC, bTok)
-- calyx
local cal = HP.mask()
for _, q in ipairs{ { 12, 32 }, { 13, 32 }, { 14, 32 }, { 15, 32 }, { 16, 32 }, { 17, 32 }, { 18, 32 }, { 19, 32 }, { 13, 31 }, { 15, 31 }, { 16, 31 }, { 18, 31 }, { 16, 30 }, { 15, 33 }, { 17, 33 } } do cal:set(q[1], q[2]) end
local calN = X.pillow(cal, 1)
local caI, caTok = G.shade(c, cal, calN, G.LEAF, { amb = 0.2 })
c:put(16, 29, G.LEAF[3]) c:put(16, 28, G.LEAF[4])

G.save(c, "ph", "marzipan")

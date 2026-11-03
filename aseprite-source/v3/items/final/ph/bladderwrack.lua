-- bladderwrack (final, Opus single pass). A sprig of bladderwrack: small holdfast disc, slim stipe forking twice into
-- flat olive-brown straps (bevelled pillow light, raised pale midrib), paired glossy air bladders either side of the
-- midrib (sphere light, specular, cool rim, AO where they sit on the frond) and warty swollen gold receptacle tips.
-- quirk: a tiny striped periwinkle clings to the left branch.
local NAME = "bladderwrack"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local OL = { "#2a2416", "#463b1c", "#665622", "#8a762c", "#ae9a3e", "#d2c066" }
local REC = { "#3e2a16", "#68461e", "#906426", "#b88a34", "#d8b052", "#f2d886" }
local BL = { "#30281a", "#56481e", "#7c6a26", "#a48e34", "#c8b452", "#ece08e" }
local MID, COOL = "#c8b45a", "#4a5a5a"
local SH = { "#3a2a40", "#5a4060", "#86688a", "#b498b0", "#dcc8d4" }

-- branch centre lines (cubic beziers)
local br = {
  { { 31, 54 }, { 31, 49 }, { 30, 45 }, { 31, 40 } },            -- stipe
  { { 31, 40 }, { 27, 35 }, { 22, 31 }, { 20, 26 } },            -- left
  { { 31, 40 }, { 35, 35 }, { 40, 31 }, { 42, 26 } },            -- right
  { { 20, 26 }, { 17, 22 }, { 15, 19 }, { 13, 15 } },            -- left-left
  { { 20, 26 }, { 22, 21 }, { 24, 18 }, { 24, 14 } },            -- left-right
  { { 42, 26 }, { 40, 21 }, { 38, 18 }, { 38, 15 } },            -- right-left
  { { 42, 26 }, { 45, 22 }, { 48, 19 }, { 50, 16 } },            -- right-right
}
local W = { 1.4, 2.3, 2.3, 2.1, 2.1, 2.1, 2.1 }
local fm = HP.mask()
for i, p in ipairs(br) do
  local m = A.tube(p, function(t) return W[i] + (i == 1 and (1 - t) * -0.3 or 0) end, 80)
  fm:add(m)
end
-- receptacle tips: swollen warty ovals at the four ends
local tips = {}
for i = 4, 7 do local p = br[i][4] local q = br[i][3]
  local ux, uy = p[1] - q[1], p[2] - q[2] local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  tips[#tips + 1] = { m = A.rell(p[1] + ux * 1.5, p[2] + uy * 1.5, ux, uy, 3.6, 2.6), x = p[1] + ux * 1.5, y = p[2] + uy * 1.5 }
end
-- air bladders: pairs either side of the midrib, on the four mid branches
local blads = {}
local function pair(p, t, r)
  local x, y = A.bez(p, t)
  local x2, y2 = A.bez(p, t + 0.02)
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  for _, sgn in ipairs{ -1, 1 } do
    local bx, by = x + px * sgn * 2.3, y + py * sgn * 2.3
    blads[#blads + 1] = { bx, by, r }
  end
end
pair(br[2], 0.45, 2.1) pair(br[3], 0.5, 2.1) pair(br[4], 0.35, 1.8) pair(br[7], 0.4, 1.8)
pair(br[1], 0.35, 1.7)
for _, b in ipairs(blads) do b.m = c:ellipse(b[1], b[2], b[3], b[3] + 0.4) end

-- holdfast disc
local hm = c:ellipse(31, 55, 4, 1.6)
local htok = { r = { name = "hold" } }
A.toneN(c, hm, X.pillow(hm, 1.5), REC, { tok = htok, cuts = A.CUTS })

-- frond
local fb = {}
for _, b in ipairs(blads) do X.ao(fb, fm, b.m, 1, -1) A.cast(fb, fm, b.m, 1, 1, -1) end
for _, tp in ipairs(tips) do X.ao(fb, fm, tp.m, 1, -1) end
local ftok = { r = { name = "frond" } }
local fn = X.pillow(fm, 1.8)
A.toneN(c, fm, fn, OL, { tok = ftok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.3, bias = fb })
-- midrib: pale raised line with a dark lee pixel
for i, p in ipairs(br) do
  for s = 0, 40 do local x, y = A.bez(p, s / 40) local xi, yi = floor(x + .5), floor(y + .5)
    if not fb[K(xi, yi)] then c:put(xi, yi, i == 1 and OL[5] or MID, ftok)
      if fm:has(xi + 1, yi) and not fb[K(xi + 1, yi)] then c:put(xi + 1, yi, OL[3], ftok) end end
  end
end
-- cool bounce on the lower-right edges
fm:edge():each(function(x, y) local k = K(x, y) local nn = fn[k]
  if nn and nn[1] + nn[2] > 0.9 and not fb[k] and y < 50 then c:put(x, y, COOL, ftok) end end)

-- receptacles: warty, gold-olive
for i, tp in ipairs(tips) do
  local tok = { r = { name = "rec" .. i } }
  local n = X.pillow(tp.m, 2)
  local idx = A.toneN(c, tp.m, n, REC, { tok = tok, cuts = A.CUTS, amb = 0.1, wrap = 0.3 })
  tp.m:shrink(1):each(function(x, y) if (x * 5 + y * 3 + i) % 5 == 0 then
    local ii = idx[K(x, y)] or 3
    c:put(x, y, REC[min(6, ii + 1)], tok) if tp.m:has(x + 1, y + 1) then c:put(x + 1, y + 1, REC[max(1, ii - 2)], tok) end
  end end)
end
-- bladders: glossy, specular, cool rim
for i, b in ipairs(blads) do
  local tok = { r = { name = "bl" .. i } }
  local m, idx, n = A.ball(c, b[1], b[2], b[3], BL, tok, { ry = b[3] + 0.4, mask = b.m, rim = COOL, amb = 0.05, wrap = 0.25 })
  local sx, sy = A.specAt(m, n, 40)
  c:put(sx, sy, i <= 2 and A.CREAM or BL[6], tok)
end

-- quirk: periwinkle on the left branch
local sx, sy = A.bez(br[2], 0.85)
sx, sy = floor(sx - 2.5), floor(sy + 0.5)
local pm = c:ellipse(sx, sy, 2.2, 1.9)
local ptok = { r = { name = "snail" } }
local sidx, sv = A.ball(c, sx, sy, 2.2, SH, ptok, { ry = 1.9, mask = pm, cuts = { 0.2, 0.4, 0.6, 0.8 } })
c:put(sx, sy, SH[1], ptok) c:put(sx + 1, sy, SH[2], ptok) c:put(sx - 1, sy - 1, SH[5], ptok) c:put(sx + 1, sy - 1, SH[2], ptok)
c:put(sx - 1, sy + 1, SH[2], ptok)

A.save(c, NAME)

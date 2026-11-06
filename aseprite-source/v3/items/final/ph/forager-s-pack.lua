-- forager-s-pack (final, Opus aB32_2). A slim upright canvas rucksack: olive canvas body with diagonal weave and
-- soft pillowed bulge, leather flap with rolled edge and a stitched hem, a leather strap down the front through a
-- bevelled brass buckle (bright edge, specular, dark prong slot), a front pocket with AO under its lip, a twisted
-- rope carry loop on top, and a side water-cup. 2-tone ground shadow.
-- quirk: a single striped jay feather is tucked under the strap.
local NAME = "forager-s-pack"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CANV  = { "#22392e", "#33523a", "#4b6d42", "#688a4c", "#8daa5e", "#b8cc80" }
local LEATH = { "#3e1e1e", "#62302a", "#8a4a32", "#b06a3e", "#d08e52", "#ecb878" }
local BRASS = { "#5a3418", "#8f5a1f", "#c88a28", "#f0b83a", "#ffe08a", "#fff6c8" }
local ROPE  = { "#5a3a24", "#8a6038", "#b88c56", "#e2bc80" }
local TIN   = { "#3e4060", "#5f6584", "#8e93ac", "#bfc2d2", "#e6e6ee" }
local FEATH = { "#24305e", "#3a5aa8", "#5f8ad8", "#a8c8f4" }

A.ground(c, 32, 55, 15, 2)

-- rope carry loop (behind)
local ltok = { r = { name = "rope" } }
local rm, rn, RT, RS = G.tube({ { 27, 15 }, { 26, 6 }, { 38, 6 }, { 37, 15 } }, function(t) return 1.3 end)
local ridx = A.shade(c, rm, rn, ROPE, { cuts = { 0.3, 0.55, 0.8 }, tok = ltok })
rm:each(function(x, y) local k = K(x, y)  -- twist: diagonal dark ticks along the rope
  if ((x + y) % 3 == 0) then c:put(x, y, ROPE[max(1, (ridx[k] or 2) - 1)], ltok) end end)

-- canvas body
local body = c:rrect(20, 14, 44, 54, 6)
local btok = { r = { name = "canvas" } }
local bb = {}
local pocket = c:rrect(23, 39, 41, 52, 3)
G.cast(bb, body, pocket, 1, 1, -1)
local bidx = A.lit(c, body, CANV, 6, { tok = btok, bias = bb, amb = 0.06 })
-- weave: faint diagonal twill lines (every 4th diagonal, one tone down)
body:copy():shrink(1):each(function(x, y) local k = K(x, y)
  if (x - y) % 4 == 0 then c:put(x, y, CANV[max(1, (bidx[k] or 3) - 1)], btok) end end)
-- base seam: darker bottom panel row
for x = 21, 43 do if body:has(x, 51) then c:put(x, 51, CANV[2], btok) end end

-- side cup (tin) hanging off the right side
local cup = c:rrect(43, 37, 48, 45, 1)
local ctok = { r = { name = "tin" } }
local cn = {}
cup:each(function(x, y) local t = max(-0.95, min(0.95, (x - 45.5) / 3)) cn[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local cb = {}
X.ao(cb, cup, body, 1, -1)
A.shade(c, cup, cn, TIN, { tok = ctok, bias = cb, cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.1, wrap = 0.3 })
for x = 43, 48 do c:put(x, 37, TIN[4], ctok) end c:put(44, 38, TIN[5], ctok) c:put(44, 39, TIN[5], ctok)
for x = 44, 48 do c:put(x, 38, TIN[2], ctok) end c:put(44, 38, TIN[5], ctok)

-- front pocket
local ptok = { r = { name = "pocket" } }
local pb = {}
X.ao(pb, pocket, c:rect(23, 38, 41, 38), 1, -1)
local pidx = A.lit(c, pocket, CANV, 3, { tok = ptok, bias = pb, amb = 0.1 })
pocket:copy():shrink(1):each(function(x, y) local k = K(x, y)
  if (x - y) % 4 == 2 then c:put(x, y, CANV[max(1, (pidx[k] or 3) - 1)], ptok) end end)
-- pocket edge piping: inner dark line where it sits on the body
pocket:edge():each(function(x, y) if y > 40 then c:put(x, y, CANV[2], ptok) end end)
for x = 24, 40 do c:put(x, 39, CANV[6], ptok) end

-- leather flap: rounded top, straight bottom edge with a rolled lip
local flap = c:rrect(19, 13, 45, 31, 7):clip(c:rect(0, 0, 63, 31))
local ftok = { r = { name = "flap" } }
local fidx = A.lit(c, flap, LEATH, 4, { tok = ftok, amb = 0.08 })
for x = 19, 45 do if flap:has(x, 31) then c:put(x, 31, LEATH[2], ftok) end if flap:has(x, 30) then c:put(x, 30, LEATH[4], ftok) end end
-- body AO just under the flap lip
for x = 20, 44 do if body:has(x, 32) then c:put(x, 32, CANV[1], btok) end end
-- stitched hem on the flap (the one stitch)
c:stitch{ { 22, 28 }, { 42, 28 } }
-- leather grain: sparse pale and dark specks
flap:copy():shrink(2):each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 31)
  if h > 0.93 then c:put(x, y, LEATH[max(1, (fidx[k] or 3) - 1)], ftok) elseif h < 0.04 and (fidx[k] or 0) >= 4 then c:put(x, y, LEATH[6], ftok) end end)
c:put(24, 17, LEATH[6], ftok) c:put(25, 17, LEATH[6], ftok)

-- quirk: jay feather tucked behind the strap (drawn before the strap)
local qtok = { r = { name = "feather" } }
local fm, fnn, FT, FS = G.blade(31, 40, 27, 30, 22, 21, function(t) if t > 0.97 then return -1 end return max(0.4, 1.8 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6) end, { fold = 0.3 })
local qidx = A.shade(c, fm, fnn, FEATH, { tok = qtok, cuts = { 0.3, 0.55, 0.8 } })
fm:each(function(x, y) local k = K(x, y)
  if abs(FS[k]) < 0.18 then c:put(x, y, "#f2ecf6", qtok)
  elseif floor(FT[k] * 9) % 2 == 0 and FT[k] > 0.3 then c:put(x, y, FEATH[1], qtok) end end)

-- strap down the front + buckle
local stok = { r = { name = "strap" } }
local strap = c:rect(30, 26, 34, 47)
local sb = {}
G.cast(sb, strap, flap, 0, 1, 0)
local sidx = A.lit(c, strap, LEATH, 1.5, { tok = stok, amb = 0.15 })
for y = 27, 47 do c:put(30, y, LEATH[5], stok) c:put(34, y, LEATH[2], stok) end
for y = 26, 47 do if y % 3 ~= 1 then c:put(31, y, LEATH[5], stok) end end
-- strap tip: rounded
c:put(30, 47, LEATH[3], stok) c:put(34, 47, LEATH[1], stok)
-- strap casts shadow on the pocket/body to its right
for y = 33, 47 do local x = 35 if body:has(x, y) then c:put(x, y, (pocket:has(x, y) and CANV[2] or CANV[1]), btok) end end
-- buckle: bevelled brass frame with dark slot and prong
local btk = { r = { name = "brass" } }
local buck = c:rrect(28, 34, 36, 40, 1)
local slot = c:rect(30, 36, 34, 38)
buck:cut(slot)
A.lit(c, buck, BRASS, 1.5, { tok = btk, amb = 0.1 })
for x = 29, 35 do c:put(x, 34, BRASS[5], btk) end
c:put(29, 35, BRASS[6], btk) c:put(30, 35, BRASS[6], btk)
for x = 29, 35 do c:put(x, 40, BRASS[2], btk) end
-- strap visible through the slot, prong across it
for x = 30, 34 do for y = 36, 38 do c:put(x, y, LEATH[2], stok) end end
for y = 36, 38 do c:put(32, y, BRASS[3], btk) end c:put(32, 36, BRASS[5], btk)

A.save(c, NAME)

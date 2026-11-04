-- nav-villagers (C3, Opus single pass): two gnome villagers shoulder to shoulder. Front: brown-skinned elder with
-- a tall red felt hat, round lit nose and a long cream beard over a green tunic. Back: fair, freckled youngster with
-- ginger tufts, a slim blue hat and mustard tunic. Material: felt hats with diagonal fold creases + dark band,
-- sphere-lit faces (6 tones) with designed noses (lit tip, dark underside), 2x3 ink pill eyes with glint, beard strands,
-- tunic weave, AO where the front gnome overlaps the back one and under the hat brims.
-- quirk: the blue hat's tip flops over and carries a tiny brass bell.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_0.lua")
local HP, X, K, tok = A.HP, A.X, A.K, A.tok
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("nav-villagers")
local SKB  = { "#3a2420", "#5e3a2e", "#84523a", "#a8704a", "#c48a5c", "#e0a878" }
local SKA  = { "#7a4036", "#a8604a", "#c98462", "#f0b98d", "#ffd4ac", "#ffe8cc" }
local RED  = { "#5e1a34", "#8e2638", "#b9363a", "#e0523c", "#f77e56", "#ffb08a" }
local BLUE = { "#1e2a5a", "#2a4a7a", "#3a6aa8", "#4f8ccc", "#7ab4e6", "#b6dcf6" }
local GRN  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local MUS  = { "#5a3a1a", "#8f5a1f", "#c2862a", "#e0aa3a", "#f2c860", "#ffe08e" }
local BEARD = { "#6e6a80", "#9a96a8", "#c4c0cc", "#e2dee4", "#f4f0ec", "#fff8f0" }
local HAIR = { "#6e2a1c", "#a4421e", "#d0662a", "#ee8a3a" }
local INK, CREAM = A.INK, A.CREAM

local function cloth(m, ramp, name, bias, slope)
  local idx = A.pil(c, m, ramp, 3, { bias = bias, tok = tok(name) })
  m:each(function(x, y) local i = idx[K(x, y)]
    if (x + y * (slope or 1)) % 5 == 0 and i >= 3 and i <= 5 then c:put(x, y, ramp[i - 1], tok(name)) end end)
  return idx
end
local function eye(x, y)
  c:fillMask(c:rect(x, y, x + 1, y + 2), INK) c:put(x, y, CREAM)
end

------------------------------------------------ back gnome (right)
local bt = A.ell(44, 58, 11.5, 16) bt:clip(c:rect(0, 42, 63, 57))
local bb = {}
cloth(bt, MUS, "btun", bb, -1)
-- AO where the front gnome will overlap
bt:each(function(x, y) if x <= 38 and y >= 47 then c:put(x, y, x <= 37 and MUS[2] or MUS[3], tok("btun")) end end)
-- collar / neck shadow
for x = 38, 46 do c:put(x, 42, MUS[2], tok("btun")) end
-- hair tufts
for _, p in ipairs{ { 35, 31 }, { 35, 32 }, { 35, 33 }, { 36, 34 }, { 34, 32 }, { 49, 31 }, { 49, 32 }, { 49, 33 }, { 48, 34 }, { 50, 32 } } do
  c:put(p[1], p[2], HAIR[(p[1] < 40) and 3 or 2], tok("hair")) end
-- face
local bf = c:ellipse(42, 34, 6, 5.5)
local bfb = {}
bf:each(function(x, y) if y <= 30 then bfb[K(x, y)] = -1 end end)
A.sph(c, 41.5, 33.5, 6.3, SKA, bf, { tok = tok("bface"), bias = bfb })
eye(38, 32) eye(45, 32)
-- nose
local bn = A.ell(42, 35.3, 1.8, 1.5)
A.sph(c, 41.7, 35, 1.9, { "#7a4036", "#a8604a", "#d08a6a", "#f2a882", "#ffc8a4", "#ffe4cc" }, bn, { tok = tok("bnose") })
c:put(41, 37, SKA[2], tok("bface")) c:put(42, 37, SKA[2], tok("bface")) c:put(43, 37, SKA[1], tok("bface"))
c:put(37, 36, "#f5809f", tok("bface")) c:put(38, 36, "#f5809f", tok("bface")) c:put(46, 36, "#f5809f", tok("bface")) c:put(47, 36, "#f5809f", tok("bface"))
c:put(39, 35, SKA[3], tok("bface")) c:put(45, 35, SKA[3], tok("bface")) -- freckles
c:put(40, 38, SKA[1], tok("bface")) c:put(41, 39, INK, tok("bface")) c:put(42, 39, INK, tok("bface")) c:put(43, 38, SKA[1], tok("bface"))
-- hat (slim, tip flops right)
local bh = c:poly{ { 34, 31 }, { 50, 31 }, { 47, 20 }, { 45, 12 }, { 47, 9 }, { 51, 11 }, { 53, 15 }, { 50, 13 }, { 47, 13 }, { 46, 20 } }
bh:add(c:poly{ { 34, 31 }, { 50, 31 }, { 46, 18 }, { 44, 12 }, { 40, 20 } })
local bhb = {}
bh:each(function(x, y) if x >= 46 and y > 18 then bhb[K(x, y)] = -1 end end)
local bhi = cloth(bh, BLUE, "bhat", bhb, 2)
for x = 34, 50 do if bh:has(x, 30) then c:put(x, 30, BLUE[2], tok("bhat")) c:put(x, 29, BLUE[3], tok("bhat")) end end
for x = 35, 40 do c:put(x, 29, BLUE[4], tok("bhat")) end
bf:each(function(x, y) if y == 31 and not bh:has(x, y) then c:put(x, y, SKA[2], tok("bface")) end end)
-- bell (quirk)
A.sph(c, 54, 16.5, 1.7, A.BRASS, nil, { tok = tok("bell") })
c:put(53, 16, CREAM, tok("bell")) c:put(54, 18, A.BRASS[1], tok("bell"))

------------------------------------------------ front gnome (left)
local ft = c:rrect(10, 47, 36, 57, 5)
local fb = {}
ft:each(function(x, y) if y <= 48 then fb[K(x, y)] = -1 end end)
cloth(ft, GRN, "ftun", fb, 1)
-- gold button + belt edge
c:fillMask(c:rect(31, 52, 32, 53), "#f5b82e") c:put(31, 52, "#ffe38a") c:put(32, 53, "#d98322")
-- face
local ff = c:ellipse(23, 39, 6.5, 6)
local ffb = {}
ff:each(function(x, y) if y <= 36 then ffb[K(x, y)] = -1 end end)
A.sph(c, 22.5, 38.5, 6.8, SKB, ff, { tok = tok("fface"), bias = ffb })
-- beard
local bd = c:poly{ { 16, 41 }, { 30, 41 }, { 31, 45 }, { 28, 51 }, { 24, 56 }, { 22, 56 }, { 17, 50 }, { 15, 45 } }
local bdb = {}
local bdi = A.pil(c, bd, BEARD, 2.5, { bias = bdb, tok = tok("beard") })
bd:each(function(x, y) local i = bdi[K(x, y)]
  local wave = (y % 4 < 2) and 0 or 1
  if (x + wave) % 3 == 0 and y > 43 and i >= 2 then c:put(x, y, BEARD[i - 1], tok("beard")) end end)
for x = 17, 29 do if bd:has(x, 41) then c:put(x, 41, BEARD[3], tok("beard")) end end
-- moustache curls
for _, p in ipairs{ { 19, 42 }, { 20, 42 }, { 21, 42 }, { 25, 42 }, { 26, 42 }, { 27, 42 }, { 18, 43 }, { 28, 43 } } do c:put(p[1], p[2], BEARD[5], tok("beard")) end
c:put(19, 43, BEARD[2], tok("beard")) c:put(27, 43, BEARD[2], tok("beard"))
c:put(22, 44, RED[2], tok("beard")) c:put(23, 44, RED[3], tok("beard")) c:put(24, 44, RED[2], tok("beard")) -- mouth peeking
-- eyes + cheeks
eye(19, 37) eye(26, 37)
c:put(17, 40, "#c94f84", tok("fface")) c:put(18, 40, "#c94f84", tok("fface"))
c:put(28, 40, "#c94f84", tok("fface")) c:put(29, 40, "#c94f84", tok("fface"))
-- big round nose
local fn = A.ell(23, 40.2, 2.4, 2.1)
A.sph(c, 22.6, 39.7, 2.5, { "#4a2420", "#6e3428", "#94523a", "#b86a4a", "#d88c62", "#f2b488" }, fn, { tok = tok("fnose") })
for x = 22, 24 do c:put(x, 42, "#4a2420", tok("fnose")) end
c:put(22, 39, "#ffd8b0", tok("fnose"))
-- hat
local fh = c:poly{ { 14, 36 }, { 32, 36 }, { 27, 26 }, { 22, 17 }, { 17, 10 }, { 15, 11 }, { 17, 20 }, { 16, 28 } }
local fhb = {}
fh:each(function(x, y) if x >= 25 then fhb[K(x, y)] = -1 end end)
cloth(fh, RED, "fhat", fhb, -1)
for x = 13, 33 do if fh:has(x, 35) then c:put(x, 35, RED[2], tok("fhat")) c:put(x, 34, RED[3], tok("fhat")) end if fh:has(x, 36) then c:put(x, 36, RED[1], tok("fhat")) end end
for x = 15, 21 do if fh:has(x, 34) then c:put(x, 34, RED[5], tok("fhat")) end end
c:put(16, 13, RED[6], tok("fhat")) c:put(16, 14, RED[6], tok("fhat"))
-- shadow cast by brim on the forehead
ff:each(function(x, y) if y == 37 and not fh:has(x, y) and (x < 19 or x > 27) then c:put(x, y, SKB[2], tok("fface")) end end)

A.fin()

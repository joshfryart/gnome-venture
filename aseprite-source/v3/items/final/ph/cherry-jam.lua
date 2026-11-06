-- cherry-jam (final pass, Opus single pass). A straight-sided glass jar of dark cherry jam with whole fruit pieces,
-- a blue-and-cream gingham cloth cap (diagonal-lit weave checks, pinked zigzag hem) tied on with twisted twine,
-- and a cream paper label with a cherry pair. Glass: rose/wine tinted wall, bright vertical streak + cream glint,
-- cooler threaded rim under the cloth. Jam: cylinder light, 6-tone ramp, pale cherry chunks. Ground shadow.
-- quirk: one fat drip of jam has escaped under the cloth and is running down the glass.
local NAME = "cherry-jam"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local JAM   = { "#2e0a22", "#4e0f2c", "#761836", "#a0223c", "#c8384a", "#ee6a62" }
local PAPER = { "#a88a6a", "#d8c09a", "#f2e2bc", "#fff4d6" }
local TW    = { "#8f4a1f", "#d98322", "#f5c860" }
local RED   = { "#7a1534", "#dc2f37", "#ff9a7a" }
local GREEN = { "#3f9150", "#7cc35a" }
local CK = { -- gingham: {shade, base, hi} per check type
  [0] = { "#c8b4a0", "#ecdcc0", "#fff4d6" },
  [1] = { "#4a669e", "#7898cc", "#a8c4e8" },
  [2] = { "#22305e", "#34508e", "#4e6eae" },
}
local SPEC = "#fff4d6"

local X0, X1 = 20, 43
c:groundShadow(31.5, 57, 13, 1.5)
-- jar body
local body = c:rrect(X0, 27, X1, 56, 4)
local rim = c:rect(X0 + 2, 23, X1 - 2, 27)
local m = body:copy():add(rim)
local inner = body:shrink(1)
local wall = body:copy():cut(inner)
-- jam: vertical cylinder light
local jtok = { r = { name = "jam" } }
local jn = select(2, X.cyl(31.5, 20, 31.5, 60, function() return 12 end, inner))
local jb = {}
inner:each(function(x, y) if y >= 54 then jb[K(x, y)] = -1 end end)
local jidx = A.shade(c, inner, jn, JAM, { amb = 0.05, wrap = 0.25, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, bias = jb, tok = jtok })
-- fruit chunks: little lit lumps with a dark underside
for _, p in ipairs{ { 23, 31 }, { 30, 30 }, { 37, 32 }, { 22, 50 }, { 27, 52 }, { 35, 51 }, { 40, 47 }, { 41, 37 } } do
  local x, y = p[1], p[2]
  if inner:has(x, y) then
    c:put(x, y, JAM[min(6, (jidx[K(x, y)] or 3) + 2)], jtok)
    if inner:has(x + 1, y) then c:put(x + 1, y, JAM[min(6, (jidx[K(x + 1, y)] or 3) + 1)], jtok) end
    if inner:has(x, y + 1) then c:put(x, y + 1, JAM[1], jtok) end
  end
end
-- glass wall
local gtok = { r = { name = "glass" } }
wall:each(function(x, y)
  local col = (x <= 31) and "#d27484" or "#5a1c38"
  if y >= 54 then col = (x <= 31) and "#a84a62" or "#4a1430" end
  c:put(x, y, col, gtok)
end)
-- shoulder glass (empty headspace below the rim) : pale
for x = X0 + 2, X1 - 2 do c:put(x, 27, x < 33 and "#b6dce8" or "#6f9fc0", gtok) end
-- glass streak + glint, cool reflected edge low right
for y = 30, 44 do c:put(X0 + 2, y, y < 38 and "#ffd8d4" or "#e88a96", gtok) end
c:put(X0 + 3, 30, "#ffd8d4", gtok) c:put(X0 + 2, 29, SPEC, gtok)
for y = 44, 52 do c:put(X1 - 1, y, "#8a3a72", gtok) end
-- threaded rim (glass, cool)
local rtok = { r = { name = "rim" } }
for y = 23, 26 do for x = X0 + 2, X1 - 2 do
  local col = (y % 2 == 0) and "#a8d4e4" or "#6f9fc0"
  if x > 36 then col = (y % 2 == 0) and "#6f9fc0" or "#3e5f86" end
  c:put(x, y, col, rtok)
end end

-- label: cream paper, slightly curled right edge, cherry pair stamp
local ltok = { r = { name = "label" } }
for y = 36, 47 do for x = 24, 39 do
  local i = 3
  if x >= 37 then i = 2 end
  if x == 39 or y == 47 then i = 1 end
  if y == 36 and x < 37 then i = 4 end
  c:put(x, y, PAPER[i], ltok)
end end
c:put(39, 36, JAM[3], jtok)               -- corner peels away (shows jam)
c:put(38, 36, PAPER[1], ltok)
-- stamp: two cherries with stems and a leaf
local stamp = {
  "....g.G..",
  "...g.GG..",
  "..g...g..",
  ".g....g..",
  "rr...rr..",
  "Rrd.Rrd..",
  "rdd.rdd..",
}
local SP = { g = GREEN[1], G = GREEN[2], r = RED[2], R = RED[3], d = RED[1] }
A.map(c, stamp, 27, 38, SP, ltok)
for x = 26, 37, 2 do c:put(x, 46, PAPER[2], ltok) end   -- dashed rule under the stamp

-- gingham cloth cap: dome + flared skirt with pinked hem
local cm = c:ellipse(31.5, 22, 13.5, 6)
cm:add(c:rect(X0 - 1, 22, X1 + 1, 27))
-- pinked hem: zigzag points every 2 px
for x = X0 - 2, X1 + 2 do if x % 2 == 0 then cm:set(x, 28) end end
cm:set(X0 - 2, 27) cm:set(X1 + 2, 27)
local cn = X.pillow(cm, 4)
local v = X.light(cn, { amb = 0.1, wrap = 0.3 })
local ctok = { r = { name = "cloth" } }
cm:each(function(x, y) local k = K(x, y)
  local t = ((floor((x + 1) / 3) % 2 == 0) and 1 or 0) + ((floor((y + 1) / 3) % 2 == 0) and 1 or 0)
  local i = v[k] > 0.72 and 3 or (v[k] > 0.4 and 2 or 1)
  if y >= 27 then i = max(1, i - 1) end
  c:put(x, y, CK[t][i], ctok)
end)
-- fold lines: diagonal creases down the skirt
for _, f in ipairs{ { 24, 24 }, { 30, 24 }, { 37, 24 } } do
  for d = 0, 3 do local x, y = f[1] + (f[1] > 31 and d or -d) // 2, f[2] + d
    if cm:has(x, y) then c:put(x, y, CK[2][1], ctok) end end
end
-- twine band with twist + bow ends
local ttok = { r = { name = "twine" } }
for x = X0 - 1, X1 + 1 do
  c:put(x, 25, TW[((x % 2) == 0) and 3 or 2], ttok)
  c:put(x, 26, TW[((x % 2) == 1) and 2 or 1], ttok)
end
for _, p in ipairs{ { X1 + 2, 25, 2 }, { X1 + 3, 26, 3 }, { X1 + 3, 27, 2 }, { X1 + 4, 28, 1 }, { X1 + 2, 26, 1 } } do
  c:put(p[1], p[2], TW[p[3]], ttok) end

-- quirk: a jam drip from under the cloth down the glass
local dtok = { r = { name = "drip" } }
for y = 29, 36 do c:put(30, y, JAM[5], dtok) c:put(31, y, JAM[3], dtok) end
for x = 29, 32 do c:put(x, 37, JAM[x < 31 and 5 or 3], dtok) c:put(x, 38, JAM[x < 31 and 3 or 2], dtok) end
c:put(30, 39, JAM[2], dtok) c:put(31, 39, JAM[1], dtok)
c:put(32, 39, PAPER[1], ltok) c:put(29, 39, PAPER[1], ltok)      -- contact shadow on the label
c:put(30, 30, JAM[6], dtok) c:put(29, 37, SPEC, dtok)
A.save(c, NAME)

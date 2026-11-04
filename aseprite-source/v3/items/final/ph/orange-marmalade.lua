-- orange-marmalade (final, Opus aC31_2 single pass). A slim tall glass jar of glowing amber marmalade with shreds of
-- peel suspended in it, a paper label with a painted orange slice, and an orange-gingham cloth cover gathered at the
-- neck by a twisted twine bow (pinked hem, fold lines). Glass: bright left rim, pale streak, cool right edge, thick base.
-- Ground shadow (stands).
-- quirk: one sticky drip has escaped from under the cloth and is running down the glass.
local NAME = "orange-marmalade"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local MARM = { "#5a1622", "#92281c", "#c64a16", "#e8741a", "#f8a234", "#ffd06a" }
local GL   = { "#3a5a84", "#5a86a8", "#8cbcd0", "#c4e6e6", "#eafaf4" }
local LAB  = { "#9c8470", "#cdb796", "#ecdcba", "#fff3d8" }
local X0, X1 = 22, 41

c:groundShadow(31.5, 57, 13, 1.5)

-- vertical cylinder normal for the jar
local function vn(x) local t = max(-0.95, min(0.95, ((x - X0) / (X1 - X0)) * 2 - 1)) return { t, 0, sqrt(1 - t * t) } end

-- jar
local jar = c:rrect(X0, 24, X1, 56, 3)
local fill = c:rect(X0 + 1, 24, X1 - 1, 53)
fill:clip(jar)
local nf = {}
fill:each(function(x, y) nf[K(x, y)] = vn(x) end)
local mtok = { r = { name = "marm" } }
local midx = A.shade(c, fill, nf, MARM, { tok = mtok, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 }, amb = 0.1, wrap = 0.35 })
-- inner glow: translucent marmalade is brighter in the core, darker at the bottom
fill:each(function(x, y) local k = K(x, y)
  if y >= 52 then c:put(x, y, MARM[max(1, midx[k] - 1)], mtok) end end)
-- peel shreds suspended (short diagonal slivers, lit top px)
for _, s in ipairs{ { 25, 33, 1 }, { 33, 31, -1 }, { 29, 36, 1 }, { 36, 37, -1 }, { 26, 50, -1 }, { 34, 49, 1 }, { 30, 51, 1 }, { 37, 51, -1 } } do
  local x, y, d = s[1], s[2], s[3]
  c:put(x, y, "#ffbe52", mtok) c:put(x + d, y + 1, "#f59a2a", mtok) c:put(x + 2 * d, y + 1, "#b8461a", mtok)
end
c:put(32, 46 - 12, "#ffe2a0", mtok)   -- tiny air bubble
-- glass walls + base
local gtok = { r = { name = "glass" } }
jar:each(function(x, y)
  if fill:has(x, y) then return end
  local i
  if x <= X0 + 1 then i = 5 elseif x >= X1 - 1 then i = 1 elseif y >= 55 then i = 2 else i = 3 end
  if y >= 54 and x > X0 + 1 and x < X1 - 1 then i = (x < 30) and 4 or 3 end
  c:put(x, y, GL[i], gtok)
end)
-- label (paper band, cylinder lit), painted orange slice
local lab = c:rect(X0 + 2, 38, X1 - 2, 46)
local nl = {}
lab:each(function(x, y) nl[K(x, y)] = vn(x) end)
local lidx = A.shade(c, lab, nl, LAB, { cuts = { 0.3, 0.5, 0.72 }, tok = { r = { name = "label" } }, amb = 0.2, wrap = 0.4 })
for x = X0 + 2, X1 - 2 do c:put(x, 38, LAB[max(1, lidx[K(x, 38)] - 1)]) end      -- top edge rolled shadow
c:put(X0 + 2, 46, LAB[1]) c:put(X1 - 2, 38, LAB[1])
c:paint({
  ".oOo.",
  "oYwYo",
  "OwYwO",
  "oYwYo",
  ".oOo.",
}, 29, 40, { o = "#d8602a", O = "#ee7a1d", Y = "#fbb64a", w = "#fff0c8" })
-- glass highlights over everything: lit streak, short second streak, cool right edge
for y = 29, 52 do if y ~= 37 and y ~= 47 then c:put(X0 + 2, y, (y >= 38 and y <= 46) and "#fffbe8" or GL[5], gtok) end end
for y = 31, 35 do c:put(X0 + 4, y, GL[4], gtok) end
for y = 30, 53 do c:put(X1 - 2, y, (y >= 38 and y <= 46) and LAB[2] or "#7a4a6a", gtok) end

-- quirk: drip from under the hem, running down the glass and over the label (drawn before the cloth)
local dtok = { r = { name = "drip" } }
for y = 26, 41 do c:put(35, y, MARM[5], dtok) c:put(36, y, MARM[3], dtok) end
c:paint({ "abc", "abcc", "bccd", ".cd" }, 34, 42, { a = MARM[6], b = MARM[4], c = MARM[3], d = MARM[1] })
c:put(35, 30, "#fffbe8", dtok) c:put(35, 43, "#fffbe8", dtok)
for y = 38, 41 do c:put(37, y, LAB[1]) end   -- tiny shadow of the drip on the label

-- cloth cover: dome over the lid, gathered at the neck, flared skirt with a pinked hem
local cloth = c:ellipse(31.5, 16, 10, 4.5)
cloth:add(c:rect(23, 16, 40, 21))
cloth:add(c:poly{ { 23, 22 }, { 40, 22 }, { 44, 28 }, { 19, 28 } })
for x = 18, 45 do if (x % 2 == 0) then cloth:cut(c:rect(x, 28, x, 28)) end end
local nc = X.pillow(cloth, 3)
local vc = X.light(nc, { amb = 0.1, wrap = 0.3 })
local GING = {
  { "#a48474", "#d2b89c", "#f0e0c2", "#fff6e0" },
  { "#a4503c", "#d4784c", "#f09c62", "#ffc48c" },
  { "#74282e", "#ac3e2c", "#d45e2c", "#f08240" },
}
local ctok = { r = { name = "cloth" } }
cloth:each(function(x, y) local k = K(x, y)
  local v = vc[k] or 0.5
  local t = (v > 0.82 and 4) or (v > 0.62 and 3) or (v > 0.42 and 2) or 1
  if y >= 23 and (x == 25 or x == 31 or x == 37) then t = max(1, t - 1) end     -- fold creases
  if y >= 23 and (x == 26 or x == 32) then t = min(4, t + 1) end                -- lit fold crests
  if y == 22 or y == 23 then t = max(1, t - 1) end                              -- gathered pucker under the twine
  local kind = floor((x + 1) / 3) % 2 + floor((y - 10) / 3) % 2
  c:put(x, y, GING[kind + 1][t], ctok)
end)
-- twine: twisted 2-strand cord around the neck + bow on the left
local TW = { "#5a3a22", "#a8743c", "#e0b066", "#f8dc96" }
local ttok = { r = { name = "twine" } }
for x = 22, 41 do for y = 20, 21 do
  local ph = (x + (y - 20)) % 3
  local i = (ph == 0) and 1 or ((ph == 1) and 3 or 2)
  if x < 26 and i < 3 then i = i + 1 end
  if x > 38 then i = max(1, i - 1) end
  c:put(x, y, TW[i], ttok)
end end
c:paint({
  ".33..",
  "3..2.",
  "3.212",
  ".2121",
  "...2.",
  "...1.",
  "...2.",
  "....3",
}, 17, 17, { ["1"] = TW[1], ["2"] = TW[2], ["3"] = TW[3] })
c:paint({ "..3", ".2.", "2..", "1.." }, 20, 22, { ["1"] = TW[1], ["2"] = TW[2], ["3"] = TW[3] })
c:put(28, 14, "#fffbe8") c:put(29, 14, "#fffbe8")   -- cloth catch-light

A.save(c, NAME)

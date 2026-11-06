-- glowcap-lantern (final pass, Opus). A slim hanging lantern: wire bail and ring, a domed brass hood with vent
-- slots and a finial, two thin brass posts framing a glass chimney; inside, a glowcap mushroom lights the glass from
-- within (bright core, glass tinted lighter around it). Brass: per-pixel cylinder light, bevel bands, specular.
-- Glass: bright rim streak, pale core, dark ambient rows under the hood and over the base.
-- quirk: a small moth has landed on the glass, drawn to the glow.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("glowcap-lantern")
local BR    = { "#4a2a2a", "#7a4630", "#a86c30", "#d4983c", "#f0c45e", "#ffe8a0" }
local GLASS = { "#203650", "#2c5470", "#3c7488", "#5a98a2", "#86c2bc", "#bfe8de" }
local CAP   = { "#1d5e62", "#27907e", "#3fc49c", "#78eabc", "#bdfcdc", "#f0fff2" }
local STEM  = { "#4e7a72", "#7aa89a", "#a8d4bf", "#d4f2e0", "#effff4" }
local tB, tG, tM = { r = { name = "brass" } }, { r = { name = "glass" } }, { r = { name = "cap" } }

-- bail: wire arc + ring at the top
for i = 0, 80 do
  local a = math.pi * i / 80
  local x, y = floor(32 - 8.5 * math.cos(a) + 0.5), floor(17 - 9 * math.sin(a) + 0.5)
  c:put(x, y, a < 1.6 and BR[5] or BR[3], tB)
end
local ring = c:ellipse(32, 6, 2, 2):cut(c:rect(32, 6, 32, 6))
A.shade(c, ring, X.sphere(32, 6, 2, ring), BR, { tok = tB })

-- hood: dome + flared brim
local hood = c:poly{ { 28, 12 }, { 36, 12 }, { 40, 17 }, { 42, 19 }, { 22, 19 }, { 24, 17 } }
hood:add(c:ellipse(32, 13, 4, 2))
local hn = A.vcylN(hood, 21, 43)
hood:each(function(x, y) local k = K(x, y) local a = hn[k] hn[k] = { A.norm(a[1], -0.55, a[3]) } end)
local hi = A.shade(c, hood, hn, BR, { tok = tB })
-- vent slots
for _, x in ipairs{ 27, 30, 34, 37 } do c:put(x, 16, BR[1], tB) c:put(x, 17, BR[2], tB) end
-- finial knob
local fin = c:ellipse(32, 10, 1, 1)
A.shade(c, fin, X.sphere(31.6, 9.6, 1.5, fin), BR, { tok = tB })
-- hood brim band
local brim = c:rect(21, 20, 43, 21)
A.shade(c, brim, A.vcylN(brim, 21, 43), BR, { tok = tB, bias = (function() local b = {} for x = 21, 43 do b[K(x, 21)] = -1 end return b end)() })

-- glass chimney
local glass = c:rect(25, 22, 39, 45)
local gn = A.vcylN(glass, 24, 40)
local gb = {}
-- glow tint from the cap: lighter glass near the light
glass:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - 32) ^ 2 + ((y - 33) * 1.2) ^ 2)
  gb[k] = (d < 8 and 1 or 0)
  if y <= 23 or y >= 44 then gb[k] = gb[k] - 2 end -- ambient under hood / over base
end)
A.shade(c, glass, gn, GLASS, { tok = tG, bias = gb, amb = 0.05, wrap = 0.1 })

-- glowcap mushroom inside (emissive)
local stem = c:poly{ { 31, 34 }, { 33, 34 }, { 34, 43 }, { 30, 43 } }
local sn = A.vcylN(stem, 29, 35)
A.glow(c, stem, 32, 34, 11, STEM, { n = sn, mix = 0.35, cuts = { 0.3, 0.45, 0.6, 0.75 } })
local cap = c:ellipse(32, 33, 6, 4):cut(c:rect(24, 34, 40, 40))
cap:add(c:rect(26, 33, 38, 33))
local cn = X.sphere(32, 33.5, 6, cap)
local ci = A.glow(c, cap, 31, 31, 7.5, CAP, { n = cn, mix = 0.35, tok = tM })
-- gills: dark row under the cap rim
for x = 27, 37 do c:put(x, 34, (x < 31 or x > 33) and CAP[2] or CAP[1], tM) end
c:put(26, 33, CAP[2], tM) c:put(38, 33, CAP[1], tM)
-- glowing cap spots
for _, p in ipairs{ { 29, 31 }, { 34, 30 }, { 36, 32 }, { 31, 29 } } do c:put(p[1], p[2], CAP[6], tM) end
-- little moss foot where the stem meets the glass floor
for x = 29, 35 do c:put(x, 44, (x == 29 or x == 35) and "#24544a" or "#3f9150", tG) end
c:put(31, 43, "#3f9150", tG) c:put(33, 43, "#7cc35a", tG)

-- glass material: bright rim streak on the lit side, thin reflection on the right
for y = 25, 41 do c:put(27, y, GLASS[6], tG) end
for y = 26, 31 do c:put(28, y, GLASS[6], tG) end
for y = 28, 40 do c:put(38, y, GLASS[4], tG) end
c:put(27, 24, A.CREAM, tG)

-- posts (2px brass, cylinder lit)
for _, px in ipairs{ 23, 40 } do
  local post = c:rect(px, 22, px + 1, 45)
  A.shade(c, post, A.vcylN(post, px - 0.5, px + 1.5), BR, { tok = tB, cuts = { 0.15, 0.3, 0.45, 0.6, 0.8 } })
end
-- base: band, tapered foot, ring
local band = c:rect(21, 46, 43, 47)
local bb = {} for x = 21, 43 do bb[K(x, 46)] = -2 end
A.shade(c, band, A.vcylN(band, 21, 43), BR, { tok = tB, bias = bb })
local foot = c:poly{ { 23, 48 }, { 41, 48 }, { 38, 51 }, { 26, 51 } }
local fn = A.vcylN(foot, 22, 42)
foot:each(function(x, y) local k = K(x, y) local a = fn[k] fn[k] = { A.norm(a[1], 0.45, a[3]) } end)
A.shade(c, foot, fn, BR, { tok = tB })
for x = 26, 38 do c:put(x, 48, BR[2], tB) end -- contact under band
-- rivets on bands
for _, x in ipairs{ 24, 32, 40 } do c:put(x, 46, BR[6], tB) c:put(x, 47, BR[2], tB) end
for _, x in ipairs{ 25, 39 } do c:put(x, 20, BR[6], tB) end
-- specular glint on the hood
c:put(28, 14, A.CREAM, tB) c:put(29, 14, BR[6], tB)

-- quirk: moth resting on the glass (right side, upper)
local moth = {
  "w.w",
  "wbw",
  "WbW",
}
local MC = { w = "#d8c8b0", W = "#a89080", b = "#5a3e3a" }
for yy, row in ipairs(moth) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if MC[ch] then c:put(34 + xx, 24 + yy, MC[ch]) end end end
c:put(35, 26, "#b8a28c")

A.save(c, "glowcap-lantern")

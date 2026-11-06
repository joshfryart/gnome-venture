-- ico-worm (final pass, Opus). A pink earthworm rising in an S out of a hole in a little soil mound, round head up and
-- facing us (two 2x3 eyes, cheeks, smile); its tail tip pokes out of a second hole on the other side of the mound.
-- Material: per-pixel tube light (6 tones), segment rings as darker bands, a warmer coral saddle (clitellum),
-- broken wet sheen streak along the lit back, cool reflected light on the underside, AO where the body sinks into
-- each hole. Soil: pillow-lit mound, crumbs and two pebbles, dark hole rims.
-- History: Sonnet draft (_dA12) replaced.
-- quirk: it carries a tiny three-leaf clover sprig in the corner of its mouth.
local NAME = "ico-worm"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local PINK  = { "#5e2142", "#8e3456", "#bd506e", "#e0748a", "#f49cac", "#ffccd2" }
local SADDLE = { "#5a1a30", "#8c2a40", "#b8404e", "#d85e5c", "#ee8474", "#ffbca0" }
local SOIL  = { "#2c1a20", "#482a28", "#6a3e30", "#8c5838", "#ae7a4c", "#d0a06c" }
local STONE = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local BOUNCE = "#b07aa8"

-- soil mound
local mound = c:ellipse(31, 51, 20, 4.5):add(c:ellipse(24, 49, 10, 4)):add(c:ellipse(41, 50, 8, 3.5))
local mn = X.pillow(mound, 3)
local sidx = A.shade(c, mound, mn, SOIL, { amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.42, 0.58, 0.72, 0.86 } })
mound:each(function(x, y)                           -- crumbs: light and dark specks
  local h = X.hash(x, y, 5)
  if h > 0.9 then A.step(c, sidx, SOIL, x, y, 1) elseif h < 0.1 then A.step(c, sidx, SOIL, x, y, -1) end
end)
-- holes
local holeL = c:ellipse(20, 47, 5, 1.5)
local holeR = c:ellipse(45, 48, 3, 1)
c:fillMask(holeL, SOIL[1]) c:fillMask(holeR, SOIL[1])
holeL:shift(0, 1):cut(holeL):each(function(x, y) if mound:has(x, y) then c:px(x, y, SOIL[5]) end end)  -- lit lip
holeR:shift(0, 1):cut(holeR):each(function(x, y) if mound:has(x, y) then c:px(x, y, SOIL[5]) end end)
-- pebbles
for _, p in ipairs{ { 30, 52 }, { 37, 49 } } do
  c:px(p[1], p[2], STONE[3]) c:px(p[1] + 1, p[2], STONE[2]) c:px(p[1], p[2] + 1, STONE[2]) c:px(p[1] + 1, p[2] + 1, STONE[1])
end
c:px(30, 52, STONE[4])

-- body: tube along a cubic, head end at P3
local path = { { 20, 48 }, { 6, 28 }, { 48, 40 }, { 38, 18 } }
local body, bn, BT, BS, samples = A.tube(path, function(t) local w = 4.4 - 0.8 * t if t > 0.55 and t < 0.69 then w = w + 0.5 end return w end)
local len = 0
for i = 2, #samples do len = len + sqrt((samples[i].x - samples[i-1].x)^2 + (samples[i].y - samples[i-1].y)^2) end
-- clip into the hole: drop pixels below the hole rim line
local clipL = HP.mask()
body:each(function(x, y) if y > 47 or (y == 47 and holeL:has(x, y)) then clipL:set(x, y) end end)
body:cut(clipL)
local bias, sad = {}, HP.mask()
body:each(function(x, y) local k = K(x, y)
  local t = BT[k]
  local d = t * len
  if t > 0.56 and t < 0.68 then sad:set(x, y)
  elseif d % 3.1 < 0.9 and t > 0.04 and t < 0.93 then bias[k] = -1 end    -- segment rings
  if y >= 44 then bias[k] = (bias[k] or 0) - (y - 43) end                   -- AO going into the hole
end)
local plain = body:copy():cut(sad)
local tok = { r = { name = "worm" } }
local BC = { 0.3, 0.47, 0.62, 0.76, 0.9 }
local pidx = A.shade(c, plain, bn, PINK, { amb = 0.02, wrap = 0.2, bias = bias, tok = tok, cuts = BC })
-- saddle: own ramp, its ends one step darker (ring edges)
local sb = {}
sad:each(function(x, y) local t = BT[K(x, y)] if t < 0.575 or t > 0.665 then sb[K(x, y)] = -1 end end)
A.shade(c, sad, bn, SADDLE, { amb = 0.02, wrap = 0.2, bias = sb, tok = tok, cuts = BC })
-- wet sheen: broken streak along the lit back
body:each(function(x, y) local k = K(x, y)
  local s, t = BS[k], BT[k]
  if s < -0.42 and s > -0.78 and t > 0.12 and t < 0.86 and not bias[k] and X.hash(x, y, 9) > 0.3 then
    c:put(x, y, sad:has(x, y) and SADDLE[6] or PINK[6], tok)
  end
end)
-- cool reflected light on the underside
local rim = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and y < 40 and BT[k] > 0.15 and BT[k] < 0.85 then c:put(x, y, BOUNCE, tok) end end)

-- tail tip out of the right hole, a little curl
local tail, tn = A.tube({ { 45, 48 }, { 46, 43 }, { 50, 41 }, { 52, 44 } }, function(t) return 1.9 * (1 - t) + 0.6 end)
local tcl = HP.mask() tail:each(function(x, y) if y >= 48 then tcl:set(x, y) end end) tail:cut(tcl)
local tb = {} tail:each(function(x, y) if y >= 46 then tb[K(x, y)] = -1 end end)
A.shade(c, tail, tn, PINK, { amb = 0.02, wrap = 0.2, bias = tb, tok = tok, cuts = BC })

-- head: a chunky round end, facing the viewer
local HX, HY = 38, 16
local head = c:ellipse(HX, HY, 5.6, 5.0)
local hn = X.sphere(HX - 0.8, HY - 0.8, 6, head)
local hidx = A.shade(c, head, hn, PINK, { amb = 0.02, wrap = 0.2, tok = tok, cuts = BC })
-- neck ring where the head meets the body (AO)
body:each(function(x, y) if head:has(x, y - 1) and not head:has(x, y) then A.step(c, pidx, PINK, x, y, -1, tok) end end)
c:put(HX - 3, HY - 3, PINK[6], tok) c:put(HX - 2, HY - 3, PINK[6], tok)          -- wet specular
c:eyeSmall(HX - 3, HY - 1) c:eyeSmall(HX + 1, HY - 1)
c:cheek(HX - 5, HY + 2) c:cheek(HX + 3, HY + 2)
c:px(HX - 1, HY + 3, PINK[1]) c:px(HX, HY + 3, PINK[1]) c:px(HX - 2, HY + 2, PINK[1]) c:px(HX + 1, HY + 2, PINK[1])  -- smile
-- quirk: clover sprig held in the corner of its mouth
local stem = { { HX + 2, HY + 3 }, { HX + 3, HY + 4 }, { HX + 4, HY + 4 }, { HX + 5, HY + 5 }, { HX + 6, HY + 5 }, { HX + 7, HY + 6 } }
for _, p in ipairs(stem) do c:px(p[1], p[2], LEAF[4]) end
local CL = { "#1f4a3a", "#2e6a40", "#3f8c48", "#5aac52", "#80c860", "#b2e07c" }
for _, L in ipairs{ { HX + 10, HY + 4 }, { HX + 9, HY + 8 }, { HX + 12, HY + 7 } } do
  local m = c:ellipse(L[1], L[2], 1.7, 1.7)
  local n = X.sphere(L[1] - 0.5, L[2] - 0.5, 2, m)
  A.shade(c, m, n, CL, { amb = 0.2, wrap = 0.35, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 } })
end
c:px(HX + 10, HY + 6, CL[2])
A.save(c, "ico", NAME)

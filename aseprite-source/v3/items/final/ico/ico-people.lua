-- ico-people (final, Opus single pass). Two gnome heads as a group: a purple-hatted friend behind on the left,
-- a red-hatted one in front on the right, overlapping. Each: slim curved cone hat (cloth fold lines, rolled brim),
-- 2x3 ink eye pills with glints, a designed round nose (lit tip, dark underside, nostril shadow), petal cheeks,
-- a long pointed beard with twisting strands and a moustache. Ambient shading where the front head meets the back.
-- quirk: the back gnome's hat has a little teal patch sewn on with gold stitches.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-people")
local RED   = { "#5e1c34", "#97273c", "#c9383e", "#e8573f", "#ff8a5c", "#ffb784" }
local PURP  = { "#2e2356", "#4a3888", "#6650b4", "#8a6fd0", "#ab92e6", "#cdb8f6" }
local SKIN  = { "#6e3a34", "#a8664e", "#d4936c", "#f0b98d", "#ffd6ae", "#ffe8cc" }
local NOSE  = { "#7a3a36", "#b86652", "#e0906c", "#f7b48c", "#ffd8b8" }
local BEARD = { "#5e4650", "#8e7478", "#bba49c", "#dccbb8", "#f0e4cc", "#fff4d6" }
local TEAL  = { "#2a4a7a", "#3a86b0", "#5fc4c8" }
local INK = A.INK

local function gnome(cx, oy, dir, HAT)
  local G = {}
  -- hat cone along a curved spine, tip flopping to `dir`
  local p = { { cx, oy + 21 }, { cx - dir * 0.5, oy + 12 }, { cx + dir * 1.5, oy + 5 }, { cx + dir * 6.5, oy + 1 } }
  local hm, hn, HT, HS = A.tube(p, function(t) return 0.7 + 8.8 * (1 - t) ^ 1.15 end)
  hm:cut(c:rect(0, oy + 21, 63, 63))
  G.hat = { m = hm, n = hn, T = HT, S = HS }
  G.brim = c:rrect(cx - 10, oy + 19, cx + 10, oy + 23, 2)
  G.face = c:ellipse(cx, oy + 28, 8, 6)
  local bpts = { { cx - 9, oy + 28 }, { cx + 9, oy + 28 }, { cx + 8, oy + 34 }, { cx + 5, oy + 41 }, { cx + 1.5 * dir + 0.5, oy + 47 },
    { cx - 4, oy + 42 }, { cx - 8, oy + 35 } }
  local bm = c:poly(bpts)
  -- leave the eyes and nose clear: beard starts below the cheeks in the middle
  bm:cut(c:ellipse(cx, oy + 27.5, 6.5, 3.2))
  G.beard = bm
  G.cx, G.oy, G.dir, G.HAT = cx, oy, dir, HAT
  G.all = hm:copy():add(G.brim):add(G.face):add(bm)
  return G
end

local function paint(g, bias)
  bias = bias or {}
  local cx, oy, HAT = g.cx, g.oy, g.HAT
  local tok = { r = { name = "hat" .. cx } }
  -- hat
  local idx = A.shade(c, g.hat.m, g.hat.n, HAT, { amb = 0.08, wrap = 0.25, bias = bias, tok = tok })
  -- cloth fold lines following the cone
  g.hat.m:each(function(x, y) local k = K(x, y) local s, t = g.hat.S[k], g.hat.T[k]
    if t > 0.08 and t < 0.75 and (abs(s - 0.32) < 0.07 or abs(s + 0.42 - t * 0.1) < 0.06) then A.step(c, idx, HAT, x, y, -1, tok) end end)
  -- brim: rolled band, darker, AO line under the cone
  local btok = { r = { name = "brim" .. cx } }
  local bn = X.pillow(g.brim, 2)
  local bb = {}
  g.brim:each(function(x, y) bb[K(x, y)] = -1 end)
  for k, v in pairs(bias) do bb[k] = (bb[k] or 0) + v end
  local bidx = A.shade(c, g.brim, bn, HAT, { amb = 0.02, wrap = 0.1, bias = bb, tok = btok, cuts = { 0.24, 0.42, 0.6, 0.78, 0.94 } })
  for x = cx - 9, cx + 9 do A.step(c, bidx, HAT, x, oy + 19, -1, btok) end
  -- face
  local ftok = { r = { name = "face" .. cx } }
  local fn = X.sphere(cx, oy + 27, 9, g.face)
  local fb = {}
  for k, v in pairs(bias) do fb[k] = v end
  for x = cx - 8, cx + 8 do fb[K(x, oy + 24)] = (fb[K(x, oy + 24)] or 0) - 1 end -- AO under the brim
  A.shade(c, g.face, fn, SKIN, { amb = 0.2, wrap = 0.35, bias = fb, tok = ftok })
  -- beard: pillow + spine light, twisting strands
  local brtok = { r = { name = "beard" .. cx } }
  local brn = A.blend(X.pillow(g.beard, 4), X.sphere(cx - 1, oy + 33, 12, g.beard), 0.5)
  local brb = {}
  for k, v in pairs(bias) do brb[k] = v end
  local bri = A.shade(c, g.beard, brn, BEARD, { amb = 0.12, wrap = 0.3, bias = brb, tok = brtok })
  g.beard:each(function(x, y)
    local w = (x - cx) + sin((y - oy) * 0.55) * 1.3 + (y - oy - 30) * 0.12 * (x < cx and -1 or 1)
    if y > oy + 31 and (w + 30) % 3.2 < 0.75 then A.step(c, bri, BEARD, x, y, -1, brtok) end
  end)
  -- moustache: two lobes beside the nose
  local mt = c:ellipse(cx - 3, oy + 31, 3, 1.5):add(c:ellipse(cx + 3, oy + 31, 3, 1.5))
  local mn = X.pillow(mt, 2)
  local mb = {}
  for k, v in pairs(bias) do mb[k] = v end
  A.shade(c, mt, mn, BEARD, { amb = 0.18, wrap = 0.3, bias = mb, tok = brtok })
  c:put(cx, oy + 32, BEARD[2], brtok)
  -- eyes, cheeks
  c:eyeSmall(cx - 4, oy + 25) c:eyeSmall(cx + 3, oy + 25)
  c:cheek(cx - 7, oy + 29) c:cheek(cx + 5, oy + 29)
  -- nose: round, warm, lit tip, dark underside and nostril shadow
  local nose = c:ellipse(cx + 0.5, oy + 29, 2, 1.6)
  local nn = X.sphere(cx + 0.5, oy + 28.6, 2.4, nose)
  A.shade(c, nose, nn, NOSE, { amb = 0.15, wrap = 0.3, tok = ftok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
  c:put(cx - 1, oy + 28, NOSE[5], ftok)
  for x = cx - 1, cx + 2 do c:put(x, oy + 31, NOSE[1], ftok) end
  c:put(cx - 1, oy + 30, NOSE[2], ftok) c:put(cx + 2, oy + 30, NOSE[2], ftok)
end

local back = gnome(23, 5, -1, PURP)
local front = gnome(41, 10, 1, RED)
-- ambient occlusion on the back gnome next to the front one
local bias = X.ao(X.ao({}, back.all, front.all, 1, -1), back.all, front.all, 3, -1)
paint(back, bias)
-- quirk: teal patch on the back hat with gold stitches
do local x0, y0 = 22, 13
  local patch = c:rect(x0, y0, x0 + 4, y0 + 3)
  patch:each(function(x, y) local i = ((x + y) % 3 == 0) and 2 or 3 if x == x0 + 4 or y == y0 + 3 then i = 1 end c:put(x, y, TEAL[i]) end)
  c:put(x0, y0, "#ffe38a") c:put(x0 + 1, y0, "#ffe38a") c:put(x0 + 3, y0, "#ffe38a")
  c:put(x0, y0 + 2, "#ffe38a") c:put(x0 + 4, y0 + 1, "#f5b82e")
  c:put(x0 + 1, y0 + 1, TEAL[3])
end
paint(front, {})
A.save(c, "ico-people")

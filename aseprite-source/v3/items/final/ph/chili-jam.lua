-- chili-jam (final, Opus single pass). A slim glass jar of glossy chili jam with a gingham cloth cap tied by a twisted
-- twine bow. Material: glass as bright left rim, pale core streak, cool right wall and a thick tinted base; jam per-pixel
-- cylinder light on a 6-tone red ramp with seeds and chili flakes suspended in it, a lit meniscus under an air gap;
-- cloth with a 3 px gingham weave shaded in 5 tones, fold lines and a scalloped hem; twine with a 2-tone twist; paper
-- label wrapped round the curve with a tiny chili print. AO under the cloth and a 2-tone ground shadow.
-- quirk: a single drip of jam has escaped from under the cloth and is running down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("chili-jam")
local JAM   = { "#3e0a22", "#6a1228", "#9a1c2c", "#c42c2e", "#e04a34", "#f8784a" }
local GLASS = { "#5a5a86", "#8aa4c0", "#bcd8e0", "#e2f4f0" }
local CREAM = { "#9a7a6a", "#c8a888", "#e6cca4", "#f6e4c0", "#fff4d6" }
local PINK  = { "#8a3a4a", "#b85a5e", "#de7c76", "#f29c8c", "#ffbcaa" }
local REDC  = { "#5e1426", "#8a1e2e", "#b82e34", "#d84a3e", "#ee6a4e" }
local TW    = { "#6a4030", "#a0683e", "#d09a5a", "#f0c884" }
local LAB   = { "#a88a74", "#d6bc98", "#f0dcb4", "#fff0cc" }
local gtok, jtok, ctok, ttok, ltok = { r = { name = "glass" } }, { r = { name = "jam" } }, { r = { name = "cloth" } }, { r = { name = "twine" } }, { r = { name = "label" } }

c:groundShadow(32, 55, 15, 2)
-- jar body
local body = HP.rrect(20, 24, 44, 54, 5)
local bn = A.vcyl(body, 32.5, 12.5, -0.15)
local jam = body:copy():cut(HP.rect(0, 0, 63, 26)):cut(body:edge())
local bias = {}
body:each(function(x, y) if y >= 52 then bias[K(x, y)] = -1 end end)
local jidx = A.shade(c, jam, bn, JAM, { amb = 0.04, wrap = 0.18, bias = bias, tok = jtok })
-- glass walls
local edge = body:edge()
edge:each(function(x, y)
  local col
  if y >= 53 then col = GLASS[1]
  elseif x <= 22 then col = (y > 27 and y < 50) and GLASS[4] or GLASS[3]
  elseif x >= 42 then col = GLASS[1]
  else col = y <= 25 and GLASS[3] or GLASS[2] end
  c:put(x, y, col, gtok) end)
-- thick base
for x = 22, 42 do c:put(x, 52, x < 26 and GLASS[3] or GLASS[2], gtok) end
for x = 24, 40 do c:put(x, 51, JAM[1], jtok) end
-- air gap + meniscus
for y = 25, 26 do for x = 21, 43 do if body:has(x, y) and not edge:has(x, y) then
  c:put(x, y, (y == 25) and GLASS[2] or (x < 30 and GLASS[3] or GLASS[2]), gtok) end end end
for x = 21, 43 do if jam:has(x, 27) then c:put(x, 27, x < 34 and JAM[6] or JAM[5], jtok) end end
-- seeds and flakes in the jam
local seeds = { { 25, 31 }, { 29, 29 }, { 38, 30 }, { 33, 47 }, { 27, 48 }, { 40, 46 }, { 36, 49 }, { 24, 44 }, { 41, 33 } }
for _, s in ipairs(seeds) do c:put(s[1], s[2], "#f6d070", jtok) c:put(s[1] + 1, s[2], "#c89a3a", jtok) end
for _, f in ipairs{ { 31, 30 }, { 26, 46 }, { 38, 49 }, { 42, 38 } } do c:put(f[1], f[2], "#ff6a3a", jtok) c:put(f[1], f[2] + 1, JAM[2], jtok) end
-- glass highlight: long streak + pale core
for y = 34, 49 do c:put(23, y, y < 44 and "#ffd8c4" or JAM[6], gtok) end
for y = 34, 39 do c:put(24, y, "#ffb898", gtok) end
c:put(41, 29, "#ffc8b0", gtok) c:put(41, 30, "#ffc8b0", gtok)

-- label wrapped on the curve
local lab = HP.rect(26, 35, 40, 45)
lab:cut(HP.rect(26, 35, 26, 35)):cut(HP.rect(40, 45, 40, 45)):cut(HP.rect(26, 45, 26, 45)):cut(HP.rect(40, 35, 40, 35))
local ln = A.vcyl(lab, 32.5, 12.5, -0.1)
A.shade(c, lab, ln, LAB, { cuts = { 0.3, 0.5, 0.72 }, tok = ltok })
for x = 27, 39 do c:put(x, 36, LAB[2], ltok) c:put(x, 44, LAB[2], ltok) end
for x = 26, 40 do c:put(x, 46, JAM[1], jtok) end  -- contact shadow under the label
-- tiny chili print
local chili = { "......g.", ".....gg.", "...rRR..", ".rRRr...", "rrr.....", }
A.map(c, chili, 29, 38, { r = "#b82c34", R = "#e85040", g = "#3f8a48" }, ltok)

-- neck (glass) under the cloth
for y = 21, 23 do for x = 23, 41 do c:put(x, y, (x < 26) and GLASS[3] or (x > 39 and GLASS[1] or GLASS[2]), gtok) end end

-- cloth cap: dome + flaring skirt with scalloped hem
local cloth = HP.ellipse(32, 15, 11, 5)
local skirt = HP.poly{ { 21, 14 }, { 43, 14 }, { 47, 24 }, { 17, 24 } }
cloth:add(skirt)
for x = 17, 47 do if (x - 17) % 4 == 3 then cloth:cut(HP.rect(x, 24, x, 24)) end end
cloth:cut(HP.rect(0, 25, 63, 63))
local cn = X.pillow(cloth, 4)
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
local cb = {}
cloth:each(function(x, y) local k = K(x, y)
  if y >= 17 and y <= 23 then cv[k] = cv[k] * (1 - (x - 17) / 60) end
  -- folds
  local f = (x - 17 - (y - 17) * 0.2)
  if y >= 17 and (abs(f - 6) < 0.6 or abs(f - 16) < 0.6 or abs(f - 24) < 0.6) then cb[k] = -1 end
  if y >= 17 and (abs(f - 7) < 0.6 or abs(f - 17) < 0.6) then cb[k] = 1 end
end)
cloth:each(function(x, y) local k = K(x, y)
  local a, b = floor((x - 1) / 3) % 2, floor((y - 1) / 3) % 2
  local ramp = (a == 1 and b == 1) and REDC or ((a == 1 or b == 1) and PINK or CREAM)
  local i = 1
  for j, t in ipairs{ 0.22, 0.42, 0.62, 0.82 } do if cv[k] >= t then i = j + 1 end end
  i = max(1, min(5, i + (cb[k] or 0) + (y >= 23 and -1 or 0)))
  c:put(x, y, ramp[i], ctok)
end)
-- AO on glass just below the hem
for x = 21, 43 do if body:has(x, 25) then c:put(x, 25, x < 26 and GLASS[2] or GLASS[1], gtok) end end

-- twine: twisted band + bow on the right
for x = 19, 45 do
  local ph = (x % 3)
  c:put(x, 20, ph == 0 and TW[4] or TW[3], ttok)
  c:put(x, 21, ph == 0 and TW[2] or (ph == 1 and TW[3] or TW[1]), ttok)
end
local bow = {
  ".tTT.TTt.",
  "tT.tKt.Tt",
  ".tTtKtTt.",
  "...t.t...",
  "..t...t..",
  "..t....t.",
}
A.map(c, bow, 36, 18, { t = TW[2], T = TW[4], K = TW[1] }, ttok)

-- quirk: jam drip running down the glass
local drip = { { 22, 25 }, { 22, 26 }, { 22, 27 }, { 22, 28 }, { 22, 29 }, { 22, 30 }, { 23, 30 }, { 22, 31 }, { 23, 31 } }
for i, q in ipairs(drip) do c:put(q[1], q[2], q[1] == 22 and JAM[4] or JAM[3], jtok) end
c:put(22, 30, JAM[6], jtok) c:put(22, 32, JAM[2], jtok) c:put(23, 32, JAM[2], jtok)

A.save(c, "chili-jam")

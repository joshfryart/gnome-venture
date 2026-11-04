-- chai-blend (final, Opus single pass). A slim enamelled tea tin of chai: deep ember-red cylinder with gold rolled rims,
-- a slip-on lid with a lit top face, a cream paper label printed with a little steaming cup, and a curled cinnamon quill
-- leaning on its shoulder. Ground shadow (it stands).
-- Material: per-pixel cylinder light (6-tone enamel), specular streak down the lit side, cool bounce on the shade edge,
-- bright bevel on the gold rims, AO under the lid lip and behind the cinnamon; cinnamon has layered bark grain and a
-- scrolled end showing the rolled layers.
-- quirk: a star anise sits on the lid like a little hat.
local NAME = "chai-blend"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local EN = { "#4a1630", "#741f36", "#a42c3a", "#cf4440", "#ec7354", "#ffb08a" }
local GOLD = { "#7a3c1c", "#b3651f", "#d98f26", "#f5b82e", "#ffd86a", "#fff0b0" }
local PAPER = { "#8f6a5a", "#bfa088", "#e0c8a4", "#f2e2be", "#fbf0d6" }
local CIN = { "#3e1c16", "#62301e", "#8a4628", "#b1643a", "#d48a54", "#efb57c" }
local ANI = { "#3a1d1c", "#5e3226", "#875034", "#b47a4c", "#dcae78" }
local INKP = "#6a2f2a"
local BOUNCE = "#9a6aa8"

c:groundShadow(33, 55, 15, 2)

local X0, X1 = 23, 41            -- body columns
local body = c:rect(X0, 20, X1, 52):add(c:ellipse(32, 52, 9, 1.5))
local lid = c:rect(X0 - 1, 14, X1 + 1, 21):add(c:ellipse(32, 14, 10, 2))
local lidTop = c:ellipse(32, 14, 9, 1.6)
body:cut(lid)
local etok, gtok, ptok = A.tok("enamel"), A.tok("gold"), A.tok("paper")
local bias = {}
X.ao(bias, body, lid, 2, -1)
local bodyN = A.vcylN(body, X0, X1)
local idx = A.shade(c, body, bodyN, EN, { tok = etok, bias = bias, amb = 0.1, wrap = 0.35 })
-- gold rolled rim at the base
local baseRim = HP.mask()
body:each(function(x, y) if y >= 50 then baseRim:set(x, y) end end)
A.shade(c, baseRim, A.vcylN(baseRim, X0, X1), GOLD, { tok = gtok, amb = 0.15, wrap = 0.35 })
baseRim:each(function(x, y) if y == 50 and x < 30 then c:put(x, y, GOLD[6], gtok) end end)
-- label: cream paper band, wrapped round (shaded with the cylinder)
local label = c:rect(X0, 29, X1, 43)
local lidx = A.shade(c, label, A.vcylN(label, X0, X1), PAPER, { tok = ptok, amb = 0.25, wrap = 0.4, cuts = { 0.2, 0.4, 0.6, 0.8 } })
for x = X0, X1 do c:put(x, 29, EN[1], etok) c:put(x, 43, GOLD[2], ptok) end
-- printed border lines
for x = X0 + 1, X1 - 1 do if x % 3 ~= 0 then c:put(x, 31, INKP, ptok) c:put(x, 41, INKP, ptok) end end
-- printed cup motif (brown ink) with a steam curl
c:paint({
  "..s.s..",
  "...s.s.",
  "..s.s..",
  "ccccc..",
  "ccccccc",
  "cmmmc.c",
  "ccccccc",
  ".ccc...",
}, 29, 32, { s = "#b06a4a", c = INKP, m = "#a0503a" })
-- label paper edge AO and a tiny printed leaf
c:px(37, 35, "#4f8a50") c:px(38, 34, "#4f8a50") c:px(38, 35, "#3f7046")
-- enamel specular streak (lit side) and cool bounce on the shade edge
for y = 21, 49 do
  if y < 29 or y > 43 then c:put(X0 + 3, y, EN[6], etok) if y % 5 == 0 then c:put(X0 + 4, y, EN[6], etok) end end
end
for y = 22, 48 do if y < 29 or y > 43 then c:put(X1, y, BOUNCE, etok) end end
-- lid: cylinder skirt + lit top face, gold rim at its lower edge
local skirt = lid:copy():cut(lidTop)
local lb = {}
A.shade(c, skirt, A.vcylN(skirt, X0 - 1, X1 + 1), EN, { tok = etok, amb = 0.12, wrap = 0.35 })
skirt:each(function(x, y) if y >= 20 then c:put(x, y, (x < 30) and GOLD[5] or (x < 37 and GOLD[4] or GOLD[2]), gtok) end
  if y == 21 then c:put(x, y, x < 33 and GOLD[3] or GOLD[1], gtok) end end)
lidTop:each(function(x, y) local d = (x - 32) / 9 + (y - 14) / 1.6 * 0.6
  c:put(x, y, d < -0.5 and EN[6] or (d < 0.3 and EN[5] or EN[4]), etok) end)
-- lid rolled rim (bevel ring round the top)
lidTop:edge():each(function(x, y) c:put(x, y, (x < 32 and y <= 14) and GOLD[6] or (x < 35 and GOLD[4] or GOLD[2]), gtok) end)
for x = X0 + 1, X0 + 3 do c:put(x, 17, EN[6], etok) end

-- cinnamon quill leaning on the right shoulder
local cp = { { 49, 55 }, { 48, 45 }, { 46, 33 }, { 44, 22 } }
local cm, cn, CT, CS = A.tube(cp, function(t) return 2.1 end)
-- ground contact: trim to the shadow line
local ctok = A.tok("cinnamon")
X.ao({}, cm, body, 1, -1)
local cidx = X.tone(c, cm, X.light(cn, { amb = 0.08, wrap = 0.3 }), CIN, { cuts = CUTS and A.CUTS, tok = ctok })
-- bark grain: long thin lines along the quill, and the seam where the bark rolls in
cm:each(function(x, y) local k = K(x, y)
  local s, t = CS[k], CT[k]
  if abs(s - 0.35) < 0.12 then A.step(c, cidx, CIN, x, y, -2, ctok)
  elseif (floor(t * 30) % 4 == 0) and s < -0.2 and s > -0.7 then A.step(c, cidx, CIN, x, y, 1, ctok)
  elseif X.hash(x, y, 13) > 0.9 then A.step(c, cidx, CIN, x, y, -1, ctok) end
end)
-- scrolled top end: the rolled layers (spiral)
c:paint({
  ".ab.",
  "bcdb",
  "bdcb",
  ".bb.",
}, 42, 19, { a = CIN[6], b = CIN[4], c = CIN[1], d = CIN[3] })
-- AO on the tin behind the stick
cm:grow(1):each(function(x, y) if body:has(x, y) and not cm:has(x, y) then A.step(c, idx, EN, x, y, -1, etok) end end)

-- quirk: star anise on the lid (eight points, seed pods)
local sx, sy = 31, 10
local pts = {}
for i = 0, 7 do local a = i * pi / 4 + 0.2
  pts[#pts + 1] = { floor(sx + cos(a) * 3.3 + 0.5), floor(sy + sin(a) * 2.3 + 0.5) } end
local star = HP.mask()
for _, p in ipairs(pts) do star:add(c:line({ { sx, sy }, p }, 1)) end
star:add(c:rect(sx - 1, sy - 1, sx + 1, sy + 1))
local atok = A.tok("anise")
star:each(function(x, y) local d = (x - sx) + (y - sy) c:put(x, y, d < -1 and ANI[4] or (d > 1 and ANI[2] or ANI[3]), atok) end)
for _, p in ipairs(pts) do c:put(p[1], p[2], (p[1] <= sx and p[2] <= sy) and ANI[5] or ANI[2], atok) end
c:put(sx, sy, ANI[1], atok) c:put(sx - 1, sy - 1, ANI[5], atok)
c:px(sx + 1, sy, "#c98a4a") -- glossy seed peeking in a pod

A.save(c, NAME)

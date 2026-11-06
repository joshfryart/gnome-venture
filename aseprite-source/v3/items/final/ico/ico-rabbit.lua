-- ico-rabbit (Opus single pass). A sitting brown hare-rabbit in side profile facing left: round head with a
-- short muzzle, two long slim ears (far ear darker), sloping back into a round haunch, long hind foot, small front
-- paw, cream chest and a cream puff tail.
-- Material: per-pixel light on every part (6-tone warm fur, 6-tone cream), fur flecks following the coat, chest
-- fluff tufts on the edge, pink inner ear, AO where head meets body, under the haunch and behind the paw.
-- Face: 2x3 ink eye with glint, ink nose tip with cream glint on a distinct muzzle, mouth line, cheek.
-- quirk: the near ear has flopped over at the tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA8_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("ico-rabbit")
local FUR  = { "#45283a", "#6a3e3a", "#905c40", "#b47e50", "#d2a46c", "#ecc994" }
local CRM  = { "#8a6a66", "#b8957e", "#d8bc9a", "#ecd8b6", "#f8eacc", "#fff5e0" }
local PINK = { "#8a3a5a", "#c45a7c", "#ec88a0", "#ffb4c4" }
local INK = A.INK
local ftok = { r = { name = "fur" } }
local ctok = { r = { name = "cream" } }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local BCUTS = { 0.26, 0.42, 0.58, 0.74, 0.9 }
local BOUNCE = "#7a5a7e"

c:groundShadow(34, 56, 17, 1.5)

-- far ear (behind, darker)
local fe, fen = A.HP.mask(), nil
do
  local m, n = X.cyl(27, 22, 33, 8, function(t) if t > 0.96 then return -1 end return 0.8 + 2.0 * sin(pi * min(1, 0.12 + t * 0.92)) ^ 0.6 end)
  local b = {} m:each(function(x, y) b[K(x, y)] = -1 end)
  A.tone(c, m, n, FUR, { amb = 0.05, wrap = 0.2, bias = b, tok = ftok, cuts = CUTS })
  fe = m
end
-- body: sloping back into the haunch
local body, bn = A.oval(36, 42, 13.5, 10.5, 0.32)
local hb = {}
-- haunch
local haunch, hn = A.oval(41, 44, 9, 8.5, 0)
-- head
local head, hdn = A.oval(22, 30, 8.8, 7.8, -0.15)
local muz, mzn = A.oval(15, 33, 4.2, 3.6, 0)
-- paint body + haunch
local bb = {}
body:each(function(x, y) if head:grow(2):has(x, y) then bb[K(x, y)] = -1 end end)        -- AO under head
local bidx = A.tone(c, body, bn, FUR, { amb = 0.03, wrap = 0.1, bias = bb, tok = ftok, cuts = BCUTS })
local hbias = {}
local hidx = A.tone(c, haunch, hn, FUR, { amb = 0.03, wrap = 0.1, bias = hbias, tok = ftok, cuts = BCUTS })
-- haunch crease: darker arc on its front-left edge where it meets the body, lit lip just inside
haunch:edge():each(function(x, y) if x < 41 and y > 36 and body:has(x - 1, y) then c:put(x, y, FUR[2], ftok)
  if haunch:has(x + 1, y) and y < 46 then c:put(x + 1, y, FUR[5], ftok) end end end)
-- cool reflected light along the lower-right of the haunch
do local rr = X.rim(hn) haunch:edge():each(function(x, y) local k = K(x, y) if rr[k] > 0.7 and not body:has(x + 1, y) then c:put(x, y, BOUNCE, ftok) end end) end
-- cream chest: the front-lower part of the body
local chest = HP.mask()
body:each(function(x, y) if (x - 22) * 0.8 + (y - 52) * -0.25 < 6 and y > 36 and not haunch:has(x, y) then chest:set(x, y) end end)
local cv = X.light(bn, { amb = 0.08, wrap = 0.3 })
local cb = {}
chest:each(function(x, y) if head:grow(2):has(x, y) then cb[K(x, y)] = -1 end end)
X.tone(c, chest, cv, CRM, { cuts = CUTS, bias = cb, tok = ctok })
-- fur flecks on body + haunch
A.fur(c, body:copy():cut(chest), bidx, FUR, ftok, 3, 0.7, 0.7, 0.045)
A.fur(c, haunch, hidx, FUR, ftok, 4, 0.7, 0.7, 0.045)
-- tail puff
local tail, tn = A.oval(51, 41, 3.6, 3.4, 0)
local tb = {} tail:each(function(x, y) if x < 50 and y > 41 then tb[K(x, y)] = -1 end end)
local tidx = A.tone(c, tail, tn, CRM, { amb = 0.1, wrap = 0.3, tok = ctok, cuts = CUTS, bias = tb })
-- fluffy edge: notch two outer pixels of the tail
c.pix[(38) * 64 + 54] = nil c.pix[(44) * 64 + 54] = nil
-- hind foot: long, flat, lying along the ground
local foot, fn = A.oval(40, 53, 8.5, 2.6, 0)
foot:add(c:ellipse(46, 51.5, 3, 3)) fn = X.pillow(foot, 2.5)
local fb = {} foot:each(function(x, y) if y <= 51 then fb[K(x, y)] = -1 end end)
local fidx = A.tone(c, foot, fn, FUR, { amb = 0.1, wrap = 0.3, bias = fb, tok = { r = { name = "foot" } }, cuts = CUTS })
-- pale toe tip on the foot front
A.pts(c, { { 32, 53 }, { 32, 54 }, { 33, 54 } }, CRM[3], ctok)
-- front paw
local paw, pn = A.oval(26, 53.5, 3, 2, 0)
local pidx = A.tone(c, paw, pn, FUR, { amb = 0.1, wrap = 0.3, tok = { r = { name = "paw" } }, cuts = CUTS })
A.pts(c, { { 23, 54 }, { 24, 55 }, { 23, 55 } }, CRM[4])
-- head + muzzle
local hdb = {}
local hdx = A.tone(c, head, hdn, FUR, { amb = 0.05, wrap = 0.15, bias = hdb, tok = { r = { name = "head" } }, cuts = CUTS })
A.fur(c, head, hdx, FUR, ftok, 9, -0.7, 0.7, 0.03)
-- chin / cheek cream under the head
local cheek = HP.mask()
head:each(function(x, y) if y > 32 and x < 27 then cheek:set(x, y) end end)
X.tone(c, cheek, X.light(hdn, { amb = 0.1, wrap = 0.3 }), CRM, { cuts = CUTS, tok = ctok })
X.tone(c, muz, X.light(mzn, { amb = 0.12, wrap = 0.3 }), CRM, { cuts = CUTS, tok = { r = { name = "muzzle" } } })
-- muzzle seam on the head side (deep line where muzzle meets the cheek)
muz:edge():each(function(x, y) if x >= 17 and y <= 34 and head:has(x + 1, y) and not muz:has(x + 1, y) then c:put(x, y, CRM[2], ctok) end end)
-- near ear with the flopped tip (drawn over the head)
local nm, nn, NT, NS = X.cyl(22, 24, 23, 11.5, function(t) if t > 0.97 then return -1 end return 0.9 + 2.1 * sin(pi * min(1, 0.12 + t * 0.9)) ^ 0.6 end)
local nb = {} nm:each(function(x, y) if head:has(x, y + 2) then nb[K(x, y)] = -1 end end)
local etok = { r = { name = "ear" } }
local nidx = A.tone(c, nm, nn, FUR, { amb = 0.08, wrap = 0.25, bias = nb, tok = etok, cuts = CUTS })
-- pink inner ear
nm:each(function(x, y) local k = K(x, y)
  if abs(NS[k] + 0.05) < 0.42 and NT[k] > 0.18 and NT[k] < 0.86 then
    c:put(x, y, (NS[k] < -0.15) and PINK[3] or PINK[2], etok)
    if NS[k] > 0.25 then c:put(x, y, PINK[1], etok) end
  end end)
-- flopped tip: short fold hanging forward-down from the ear top
local fm, fnn = X.cyl(23, 11.5, 16, 17, function(t) return 2.3 - t * 0.8 end)
local fbias = {} fm:each(function(x, y) if nm:has(x, y) then fbias[K(x, y)] = 0 end end)
local fold = A.tone(c, fm, fnn, FUR, { amb = 0.1, wrap = 0.3, tok = { r = { name = "fold" } }, cuts = CUTS })
-- fold crease: dark row under the folded flap where it lies on the ear
fm:each(function(x, y) if not fm:has(x, y + 1) and nm:has(x, y + 1) then c:put(x, y + 1, FUR[1], etok) end end)
A.pts(c, { { 21, 11 }, { 20, 12 } }, FUR[6])
A.pts(c, { { 22, 13 }, { 23, 13 }, { 24, 13 } }, FUR[1], etok)
-- face: eye, nose, mouth, cheek
c:eyeSmall(17, 27)
A.pts(c, { { 11, 31 }, { 12, 31 }, { 11, 32 }, { 12, 32 } }, INK)
c:px(11, 31, "#fff4d6")
A.pts(c, { { 12, 34 }, { 13, 35 }, { 14, 35 } }, CRM[1])
c:px(20, 33, PINK[3]) c:px(21, 33, PINK[3])
-- chest fluff tufts poking out on the front edge
A.pts(c, { { 24, 41 }, { 23, 43 }, { 24, 45 } }, CRM[5], ctok)
A.save(c)

-- ico-safari (final, Opus single pass). A friendly grey elephant walking left in a khaki pith helmet: domed back,
-- big veined ear flap, curled trunk with a lit tip, short ivory tusk, four legs (far pair in shadow), rope tail.
-- Material: per-pixel body light (sphere+pillow normals, 6-tone violet-grey), wrinkle creases on trunk and knees,
-- ear veins and a pink inner rim, cool reflected light on the belly, AO where ear meets head and head meets body,
-- cream toenails; helmet with a lit dome, brim shadow on the brow and a red band. Ground shadow (it stands).
-- quirk: a little oxpecker bird is riding on its back.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("ico-safari")
local GR  = { "#2c2742", "#47425f", "#655f82", "#8784a6", "#aaa9c4", "#cfd0e2" }
local EAR = { "#2e2442", "#56486e", "#7a6c96", "#9c90b8", "#bdb2d4", "#ddd4ec" }
local IV  = { "#6a5040", "#a88a6a", "#d8c09a", "#efe0bc", "#fff4d6" }
local KH  = { "#4e3424", "#80592f", "#b08446", "#d2aa62", "#ead08a", "#fbeab8" }
local BOUNCE = "#7f8fb8"
local etok, gtok, htok = { r = { name = "ear" } }, { r = { name = "grey" } }, { r = { name = "helmet" } }

c:groundShadow(32, 53, 22, 2)

-- far legs (behind), darker
local function leg(x0, x1, y0, y1, far)
  local m = c:rrect(x0, y0, x1, y1, 2)
  m:add(c:rrect(x0 - 1, y1 - 3, x1 + (far and 0 or 1), y1, 1))
  local n = X.pillow(m, 3)
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    bias[k] = (far and -2 or 0) + ((y < y0 + 2) and -1 or 0)
    if y == y0 + 6 and x > x0 and x < x1 then bias[k] = bias[k] - 1 end      -- knee crease
  end)
  local idx = A.shade(c, m, n, GR, { bias = bias, tok = gtok, amb = 0.12, wrap = 0.3 })
  if not far then for x = x0 + 1, x1 - 1, 2 do c:put(x, y1, IV[4], gtok) end c:put(x0 + 2, y1 - 1, GR[2], gtok) c:put(x0 + 4, y1 - 1, GR[2], gtok) end
  return m
end
leg(31, 35, 37, 51, true)
leg(39, 43, 37, 51, true)

-- tail (behind body)
local tail = c:line({ { 51, 30 }, { 53, 34 }, { 54, 39 } }, 1)
tail:each(function(x, y) c:put(x, y, GR[3], gtok) end)
A.map(c, { "dd", "dk", ".k" }, 53, 39, { d = GR[2], k = GR[1] }, gtok)

-- body
local body = c:ellipse(37, 32, 15, 11)
local bn = A.body(body, 33, 27, 16, 5, 0.55)
local bb = {}
local bidx = A.shade(c, body, bn, GR, { tok = gtok, bias = bb, amb = 0.08, wrap = 0.25 })
-- cool bounce on the belly
-- skin creases on the flank
for _, p in ipairs{ { 46, 25 }, { 47, 26 }, { 47, 27 }, { 45, 34 }, { 46, 35 } } do A.step(c, bidx, GR, p[1], p[2], -1, gtok) end

-- near legs
leg(23, 28, 37, 51, false)
leg(44, 49, 37, 51, false)
local rim = X.rim(bn)
body:edge():each(function(x, y) if y > 36 and rim[K(x, y)] > 0.5 and not c:get(x, y + 1) then c:put(x, y, BOUNCE, gtok) end end)
-- belly overlap shadow on the near legs' tops (contact)
for _, x0 in ipairs{ 23, 44 } do for x = x0, x0 + 5 do
  if body:has(x, 41) then c:put(x, 42, GR[2], gtok) end end end

-- head
local head = c:ellipse(20, 27, 9, 9)
local hn = A.body(head, 17, 23, 10, 4, 0.6)
local hidx = A.shade(c, head, hn, GR, { tok = gtok, amb = 0.1, wrap = 0.28 })
-- AO on body next to head
body:each(function(x, y) if not head:has(x, y) and (head:has(x - 1, y) or head:has(x - 2, y)) then A.step(c, bidx, GR, x, y, -1, gtok) end end)

-- trunk: curls down and forward, tip turned up
local tp = { { 13, 30 }, { 7, 37 }, { 6, 47 }, { 11, 48 } }
local tm, tn, TT, TS = A.tube(tp, function(t) return 3.4 - 1.6 * t end)
tm:cut(head:copy():cut(c:rect(0, 32, 63, 63)))
local tidx = A.shade(c, tm, tn, GR, { tok = gtok, amb = 0.1, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y)
  if TT[k] and TT[k] > 0.12 and TT[k] < 0.85 and floor(TT[k] * 13) % 2 == 0 and TS[k] > -0.6 then A.step(c, tidx, GR, x, y, -1, gtok) end end)
-- trunk tip: nostril with a lit rim
c:put(12, 47, GR[1], gtok) c:put(12, 46, GR[5], gtok) c:put(11, 46, GR[4], gtok)

-- tusk (in front of the trunk base)
local tu, tun = A.tube({ { 17, 34 }, { 16, 38 }, { 14, 40 }, { 11, 40 } }, function(t) return 1.3 - 0.6 * t end)
A.shade(c, tu, tun, IV, { tok = gtok, amb = 0.3, wrap = 0.4, cuts = { 0.2, 0.4, 0.6, 0.8 } })

-- ear flap (in front of the head), veins + pink inner rim; cast shadow on the head
local ear = c:poly{ { 24, 19 }, { 30, 18 }, { 33, 23 }, { 33, 31 }, { 30, 37 }, { 26, 38 }, { 24, 33 }, { 23, 26 } }
ear:shift(1, 1):cut(ear):each(function(x, y) if head:has(x, y) or body:has(x, y) then
  local k = K(x, y) if hidx[k] then A.step(c, hidx, GR, x, y, -2, gtok) elseif bidx[k] then A.step(c, bidx, GR, x, y, -2, gtok) end end end)
local en = X.pillow(ear, 3)
local eidx = A.shade(c, ear, en, EAR, { tok = etok, amb = 0.1, wrap = 0.3 })
local edg = ear:edge()
edg:each(function(x, y) if (x >= 31 and y > 22) or y >= 36 then c:put(x, y, "#b07fa6", etok) else c:put(x, y, EAR[1], etok) end end)
for _, v in ipairs{ { { 25, 24 }, { 28, 27 }, { 30, 26 } }, { { 25, 29 }, { 28, 31 }, { 31, 33 } }, { { 28, 27 }, { 29, 31 } } } do
  c:line(v, 1):each(function(x, y) if ear:has(x, y) and not edg:has(x, y) then A.step(c, eidx, EAR, x, y, -1, etok) end end)
end

-- eye + brow
c:eyeSmall(16, 24)
c:put(15, 23, GR[2], gtok) c:put(16, 23, GR[2], gtok)
c:put(14, 28, "#b77a9a", gtok) c:put(15, 28, "#b77a9a", gtok)   -- cheek blush

-- pith helmet: dome + brim, red band, brim shadow on brow
local dome = c:ellipse(20, 17.5, 6, 4.5) dome:cut(c:rect(0, 19, 63, 63))
local brim = c:ellipse(20, 19.5, 9.5, 1.6)
local dn = X.sphere(18, 15, 6, dome)
A.shade(c, dome, dn, KH, { tok = htok, amb = 0.15, wrap = 0.3 })
local brn = X.pillow(brim, 1.2)
A.shade(c, brim, brn, KH, { tok = htok, amb = 0.2, wrap = 0.35, bias = {} })
brim:each(function(x, y) if not brim:has(x, y + 1) then c:put(x, y, KH[2], htok) end end)
for x = 14, 26 do if dome:has(x, 18) then c:put(x, 18, "#c4303a", htok) end if dome:has(x, 17) and dome:has(x, 18) then c:put(x, 17, "#e8493b", htok) end end
c:put(15, 17, "#ff8a5c", htok)
c:put(18, 14, KH[6], htok) c:put(19, 14, KH[6], htok)
for x = 12, 28 do if head:has(x, 21) and not brim:has(x, 21) and not ear:has(x, 21) then A.step(c, hidx, GR, x, 21, -1, gtok) end end
c:put(20, 12, KH[1], htok)   -- button on top

-- quirk: oxpecker riding on its back
A.map(c, {
  "..bb..",
  ".bBe..",
  "obBBb.",
  "..bBBbb",
  "...ff..",
}, 40, 17, { b = "#8a5a3a", B = "#b97a4a", e = "#2b1c26", o = "#f5b82e", f = "#e8493b" })
c:put(42, 18, "#2b1c26")

A.save(c, "ico-safari")

-- badger-pelt (final, Opus aR3_1, single pass). A tanned badger hide laid flat, fur up, seen from above: slim shield
-- of grizzled silver-grey back fur (guard hairs with pale tips, darker roots, a parting line down the spine), four
-- thin splayed black legs ending in cream claws, a short grizzled tail, a shaggy tufted fringe all round, and the
-- head with its white blaze between two black stripes, white cheeks, small white-rimmed ears and a dark nose leather.
-- Fur strands follow the lie of the hair (head to tail on the back, along each leg). Soft pillow light from the
-- upper left, AO where the legs, head and tail meet the body.
-- quirk: a little paper trade tag hangs off the right hind leg on a twist of twine.
local NAME = "badger-pelt"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local GREY  = { "#33303c", "#4a4654", "#64606c", "#827d88", "#a29ea4", "#c4c0bc" }
local BLACK = { "#1e1a24", "#29242f", "#36303c", "#453f4c", "#59525f", "#706875" }
local WHITE = { "#7e7a84", "#a09ca4", "#bfbbbd", "#d8d4cf", "#eae6dc", "#f6f2e6" }
local TIP, CLAW, NOSE = "#ddd8d0", "#ece2c8", "#2b1c26"
local TAG   = { "#b8a888", "#dccca8", "#f2e6c8", "#fbf4e0" }
local TWINE = { "#8a5a2c", "#c48a44" }
local CX = 32

-- body: slim shield, a little narrower toward the rump
local body = HP.mask()
for y = 20, 49 do
  local t = (y - 20) / 29
  local hw = 11.4 * sin(pi * min(1, 0.2 + t * 0.84)) ^ 0.42 - t * 1.4
  for x = floor(CX - hw + 0.5), floor(CX + hw - 0.5) do body:set(x, y) end
end
-- shaggy fringe: ragged tufts round the body edge
local fr = body:grow(1):cut(body)
fr:each(function(x, y) if X.hash(x, y, 2) > 0.45 and y > 22 then body:set(x, y) end end)

-- head: wedge to a blunt nose
local head = c:poly({ { 32, 7.5 }, { 35.8, 9.5 }, { 38.6, 14 }, { 39.4, 19 }, { 37, 22 }, { 27, 22 }, { 24.6, 19 }, { 25.4, 14 }, { 28.2, 9.5 } })
local ears = c:ellipse(24.4, 18.4, 1.6, 1.8):add(c:ellipse(39.6, 18.4, 1.6, 1.8))
-- legs (tubes), tail
local legs = {}
local LEGP = {
  { { 26, 27 }, { 21, 25 }, { 18, 22 }, { 15, 19 } },
  { { 38, 27 }, { 43, 25 }, { 46, 22 }, { 49, 19 } },
  { { 26, 43 }, { 21, 45 }, { 18, 48 }, { 15, 51 } },
  { { 38, 43 }, { 43, 45 }, { 46, 48 }, { 49, 51 } },
}
for i, p in ipairs(LEGP) do
  local m, n, T, S = G.tube(p, function(t) return 3.0 - 1.4 * t end)
  m:cut(body)
  legs[i] = { m = m, n = n, T = T, S = S }
end
local tm, tn, TT, TS = G.tube({ { 32, 48 }, { 32, 51 }, { 32.5, 54 }, { 33, 56 } }, function(t) return 2.8 * (1 - t) ^ 0.5 + 0.7 end)
tm:cut(body)

-- body tone: pillow light + fur strands + guard-hair tips + spine parting + AO toward the head
local all = body:copy():add(head)
local bn = X.pillow(body, 3.5)
local bv = X.light(bn, { amb = 0.22, wrap = 0.35 })
local bb = {}
X.ao(bb, body, head, 1, -1)
local btok = { r = { name = "fur" } }
local bidx = X.tone(c, body, bv, GREY, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, bias = bb, tok = btok })
-- strands: sparse vertical hairs, lit tip / mid / dark root (3 px), seeded by hash so they do not band
local ii = {}
body:each(function(x, y) ii[K(x, y)] = bidx[K(x, y)] end)
body:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 13) > 0.8 then
    local i0 = bidx[k]
    for d, delta in ipairs{ 1, 0, -1 } do local q = K(x, y + d - 1)
      if body:has(x, y + d - 1) then ii[q] = i0 + delta end end
    if X.hash(x, y, 14) > 0.75 and i0 >= 3 and y > 22 then ii[k] = 7 end   -- pale guard-hair tip
  end
end)
body:each(function(x, y) local k = K(x, y)
  local i = ii[k]
  if abs(x - CX) < 0.6 and y > 23 and y < 47 then i = min(i, bidx[k]) - 1 end
  c:put(x, y, i >= 7 and TIP or GREY[max(1, min(6, i))], btok)
end)

-- legs: black fur, strands along the leg, claws
for i, L in ipairs(legs) do
  local tok = { r = { name = "leg" .. i } }
  local bias = {}
  X.ao(bias, L.m, body, 1, -1)
  local idx = X.tone(c, L.m, X.light(L.n, { amb = 0.16, wrap = 0.3 }), BLACK, { cuts = { 0.18, 0.36, 0.54, 0.7, 0.86 }, bias = bias, tok = tok })
  L.m:each(function(x, y) local k = K(x, y)
    if abs(L.S[k] + 0.3) < 0.2 and floor(L.T[k] * 14) % 3 == 0 and idx[k] >= 3 then c:put(x, y, BLACK[min(6, idx[k] + 1)], tok) end end)
  local e = LEGP[i][4]
  local d = { e[1] - LEGP[i][3][1], e[2] - LEGP[i][3][2] }
  local l = sqrt(d[1] ^ 2 + d[2] ^ 2) d = { d[1] / l, d[2] / l }
  local px, py = -d[2], d[1]
  for _, o in ipairs{ -1, 0, 1 } do
    local x, y = floor(e[1] + d[1] * 1.6 + px * o * 1.1 + .5), floor(e[2] + d[2] * 1.6 + py * o * 1.1 + .5)
    if not L.m:has(x, y) then c:put(x, y, CLAW, tok) end
  end
end

-- tail: grizzled, strands along it, lighter tip
local ttok = { r = { name = "tail" } }
local tb = {}
X.ao(tb, tm, body, 1, -1)
local tidx = X.tone(c, tm, X.light(tn, { amb = 0.2, wrap = 0.3 }), GREY, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, bias = tb, tok = ttok })
tm:each(function(x, y) local k = K(x, y)
  if (x + y) % 3 == 0 and tidx[k] >= 3 then c:put(x, y, GREY[min(6, tidx[k] + 1)], ttok) end
  if TT[k] > 0.8 then c:put(x, y, WHITE[min(6, tidx[k])], ttok) end
end)

-- head: white face, black stripes, AO at the neck, nose leather
local hn = X.pillow(head, 3)
local hv = X.light(hn, { amb = 0.2, wrap = 0.35 })
local htok = { r = { name = "head" } }
head:each(function(x, y) local k = K(x, y)
  local t = (y - 8) / 14                         -- 0 nose .. 1 neck
  local off = abs(x + 0.5 - CX - 0.5)
  local inner = 0.8 + t * 1.1                    -- half width of white blaze
  local outer = inner + 2.2 + t * 1.6            -- stripe outer edge
  local v = hv[k]
  local i = v < 0.3 and 2 or v < 0.48 and 3 or v < 0.64 and 4 or v < 0.82 and 5 or 6
  if y > 20 then i = i - 1 end
  local ramp = (off > inner and off <= outer and y > 9) and BLACK or WHITE
  if ramp == BLACK then i = i - 1 end
  c:put(x, y, ramp[max(1, min(6, i))], htok)
  if ramp == WHITE and y > 9 and (x + y) % 4 == 0 and i > 2 then c:put(x, y, WHITE[i - 1], htok) end
end)
-- ears: black with white rims
local etok = { r = { name = "ears" } }
ears:cut(head)
ears:each(function(x, y) c:put(x, y, BLACK[3], etok) end)
ears:edge():each(function(x, y) if y < 19 then c:put(x, y, WHITE[4], etok) end end)
-- nose leather + glint
c:put(31, 8, NOSE, htok) c:put(32, 8, NOSE, htok) c:put(31, 9, NOSE, htok) c:put(32, 9, NOSE, htok) c:put(33, 8, NOSE, htok) c:put(31, 8, "#fff4d6", htok)
-- eye holes in the stripes (pelt): dark slits
c:put(28, 14, NOSE, htok) c:put(29, 15, NOSE, htok) c:put(36, 14, NOSE, htok) c:put(35, 15, NOSE, htok)
-- spec: one soft 2x1 sheen on the lit shoulder fur
c:put(26, 27, GREY[6], btok) c:put(27, 27, GREY[6], btok)

-- quirk: tag on twine from the right hind leg
local tgtok = { r = { name = "tag" } }
local twtok = { r = { name = "twine" } }
G.path(c, { { 45, 47 }, { 47, 49 }, { 49, 50 }, { 51, 49 } }, function(t, x, y) return (x + y) % 2 == 0 and TWINE[2] or TWINE[1] end, twtok)
c:put(52, 49, TWINE[1], twtok)
G.map(c, 51, 49, {
  ".aab.",
  "abhbc",
  "abbbc",
  "allbc",
  "abbbc",
  ".cccd",
}, { a = TAG[4], b = TAG[3], c = TAG[2], d = TAG[1], h = "#5a4048", l = "#8a7a70" }, tgtok)

G.save2(c, NAME)

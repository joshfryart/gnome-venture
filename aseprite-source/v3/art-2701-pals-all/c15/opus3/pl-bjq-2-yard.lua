-- Clownfish Peek (pl-bjq-2), yard sprite 64x64. Opus richness pass (c15/opus3), built on c15/opus2.
-- Rootwarden, common, Reef of the Box-Jelly Queen. "A little striped fish that peeks out of the coral, then
-- hides again."
-- A round orange clownfish faces us, peeking up over a low ridge of lavender brain coral (maze grooves), its two
-- little pectoral fins hooked over the coral edge like hands on a wall. Cream stripes with ink borders wrap
-- behind its cheeks, an ink-tipped dorsal fin stands up. Two teal staghorn coral branches rise behind.
-- Haiku weakness fixed: a huge blobby pink mound with the fish a small side-view lump on top; now the fish is the
-- hero, the coral a slim ridge plus branches (clear reef silhouette).
-- quirk: it has only its eyes and fins over the edge, ready to duck back down (one bubble rising).
-- richness: hue-shifted orange (plum-red deeps, butter lights), fine scale scallops on the crown, fin rays, ink
-- trimmed fin edges, brain-coral maze grooves with lit ridge crests on top, staghorn polyp dots and pale growing tips, rim light
-- upper-left and cool bounce lower-right.
-- closer look: a tiny spiral sea snail creeping over the right brain-coral head.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-bjq-2-yard", 64)

local FISH = { "#6e1e2a", "#b23a1e", "#e8641e", "#ff8f2e", "#ffb65a", "#ffe09a" }
local STR  = { "#b8a0a8", "#e4d6d0", "#fff4e6" }
local BRN  = { "#3c2a62", "#5a4490", "#8068c0", "#a690de", "#c8b6f0", "#e6dcfa" }
local STAG = { "#1f4a5a", "#2a6a78", "#3a9298", "#5fc4c8", "#94e0d8", "#c8f4e8" }

c:groundShadow(32, 53, 23, 2)

-- staghorn branches behind (left and right)
for _, br in ipairs({
  { { 15, 46 }, { 12, 36 }, { 9, 30 }, { 8, 24 }, 2.6 }, { { 14, 38 }, { 17, 32 }, { 18, 28 }, { 18, 23 }, 1.8 },
  { { 49, 46 }, { 52, 36 }, { 55, 30 }, { 56, 22 }, 2.6 }, { { 51, 37 }, { 48, 31 }, { 47, 28 }, { 47, 24 }, 1.8 },
}) do
  local m, n = O.tube({ br[1], br[2], br[3], br[4] }, function(t) return br[5] * (1 - t * .35) end)
  local I, Tk = O.shadeN(c, m, n, STAG, { amb = .3, wrap = .45, rim = true, sep = STAG[1] })
  O.tex(c, I, Tk, STAG, function(x, y, i) if H(x, y, 7) > .8 then return 1 end end) -- polyp dots
  O.mark(c, { { br[4][1], br[4][2] } }, STAG[6]) -- pale growing tip
end

-- dorsal fin
local dor = c:poly{ { 26, 17 }, { 30, 9 }, { 35, 8 }, { 38, 12 }, { 38, 17 } }
local dI, dT = O.shade(c, dor, FISH, { R = 2, amb = .35, wrap = .45, sep = FISH[1] })
O.tex(c, dI, dT, FISH, function(x, y, i) if (x - y) % 3 == 0 and y > 10 then return -1 end end) -- fin rays
-- head/body
local head = c:ellipse(32, 27, 14, 11)
local hI, hT = O.shade(c, head, FISH, { sphere = { 27, 21, 18 }, amb = .3, wrap = .45, rim = true, bounce = "#9a6ad0", bmax = 2 })
-- fine scale scallops across the crown (above the eyes)
O.tex(c, hI, hT, FISH, function(x, y, i)
  if y < 21 and y % 2 == 0 and (x + (y // 2 % 2) * 2) % 4 == 0 and i >= 3 then return -1 end
end)
-- cream collar stripes behind the cheeks, with ink borders
head:each(function(x, y)
  local u = math.abs(x + .5 - 32) / 14
  local v = (y + .5 - 27) / 11
  local d = u / math.sqrt(math.max(.05, 1 - v * v))
  local p = y * c.w + x
  if d > .62 and d < .8 then
    c.pix[p] = (x < 32 and y < 26) and STR[3] or (y > 31 and STR[1] or STR[2])
  elseif (d >= .55 and d <= .62) or (d >= .8 and d <= .86) then
    c.pix[p] = P.ink
  end
end)
-- dorsal ink tip
O.mark(c, { { 31, 9 }, { 32, 8 }, { 33, 8 }, { 34, 8 }, { 35, 9 } }, P.ink)
-- glossy head glint
O.mark(c, { { 26, 19 }, { 27, 18 }, { 28, 18 } }, FISH[6])

-- face
c:eyeLocked(25, 23)
c:eyeLocked(34, 23)
c:cheek(24, 29) c:cheek(38, 29)
O.flat(c, c:rect(30, 30, 33, 31), P.ink, "mouth") O.dots(c, { { 31, 31 }, { 32, 31 } }, "#c94f84")

-- brain coral ridge in front, low and wide, maze grooves
-- three brain-coral heads (side ones first, middle one in front), each with wavy concentric grooves
for _, d in ipairs({ { 20, 45, 9, 7 }, { 44, 45, 9, 7 }, { 32, 44, 11, 8 } }) do
  local dm = c:ellipse(d[1], d[2], d[3], d[4])
  dm:cut(c:rect(0, 52, 63, 63))
  local bI, bT = O.shade(c, dm, BRN, { sphere = { d[1] - 4, d[2] - 5, d[3] + 5 }, amb = .3, wrap = .45, rim = true, bounce = "#4a7aa0", bmax = 2, sep = BRN[1] })
  O.tex(c, bI, bT, BRN, function(x, y, i)
    local u, v = (x + .5 - d[1]) / d[3], (y + .5 - d[2]) / d[4]
    local r = math.sqrt(u * u + v * v) * 4.2 + .35 * math.sin(math.atan(v, u) * 7)
    if r % 1 < .3 then return -1 end
    if r % 1 > .5 and r % 1 < .58 and i >= 4 and i <= 5 and y < d[2] then return 1 end -- lit ridge crest on top
  end)
  O.mark(c, { { d[1] - 5, d[2] - 5 }, { d[1] - 4, d[2] - 6 } }, BRN[6])
end
-- pectoral fins hooked over the coral edge
for _, f in ipairs({ { 18, 36, 1 }, { 46, 36, -1 } }) do
  local fx, fy, s = f[1], f[2], f[3]
  local fin = c:poly{ { fx - 3 * s, fy - 1 }, { fx + 3 * s, fy - 2 }, { fx + 4 * s, fy + 3 }, { fx, fy + 4 } }
  O.shade(c, fin, FISH, { R = 1, amb = .35, wrap = .45, sep = FISH[1] })
  O.mark(c, { { fx - 2 * s, fy }, { fx - 1 * s, fy + 2 } }, P.ink) -- ink fin edge marks
  O.mark(c, { { fx + 3 * s, fy - 1 }, { fx + 4 * s, fy + 2 }, { fx + 4 * s, fy + 1 } }, P.ink) -- ink trim on the fin tip
end
-- the little sea snail on the right coral head: spiral shell, soft foot, two eye stalks
O.shade(c, c:ellipse(49, 38, 2, 1.8), { "#7a3a2a", "#c47a4a", "#f0b07a", "#ffe0b8" }, { sphere = { 48, 37, 3 }, amb = .3, cuts = { .3, .55, .8 }, sep = "#7a3a2a" })
O.mark(c, { { 49, 38 }, { 50, 37 } }, "#7a3a2a")
O.flat(c, c:rect(46, 40, 51, 40), "#c8b6c0", "foot") O.dot(c, 46, 40, "#e8dce0")
O.dots(c, { { 51, 39 } }, "#c8b6c0")

O.done(c, "pl-bjq-2-yard", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  -- one bubble rising
  for _, p in ipairs({ { 44, 6 }, { 45, 6 }, { 43, 7 }, { 46, 7 }, { 43, 8 }, { 46, 8 }, { 44, 9 }, { 45, 9 } }) do put(p[1], p[2], "#b9e2f5") end
  put(44, 7, "#e4f6ff")
  for _, p in ipairs({ { 41, 12 }, { 42, 12 }, { 41, 13 }, { 42, 13 } }) do put(p[1], p[2], "#b9e2f5") end
end)

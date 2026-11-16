-- Torii Loop (br-torii-loop), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c07/opus3), built on opus2.
-- opus3: fur tufts with lit tips + cheek/hip fluff on the silhouette, ringed tail fur, lacquer grain and gold end caps
-- on the gate, fluffy belly edge; closer look: it holds a seed in its fore paws (seedkeeper) and a cherry petal rests
-- on its crown between the posts; one petal rides the hop loop.
-- Blossomreach, uncommon, seedkeeper. "Hops through every red gate on the stairs and comes back for more."
-- A round gold hopper (long hare-like hind feet, tucked fore paws, cream belly) that wears a little red torii
-- gate on its head: black-capped kasagi with upturned ends, nuki crossbar, centre strut, two posts that sink into
-- its crown. Its tail is a fluffy open curl with an ember tip (not a closed ring, so it never reads as a handle).
-- Haiku fixes: gate posts now stand clear of the head with a gap under the nuki, tail is a curl, body has a
-- hop pose with big feet so the silhouette reads as a hopper.
-- quirk: a dashed hop trail behind it that loops the loop (it comes back for more).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("br-torii-loop-yard", 64)

local GLD  = { "#6e3a1c", "#9a5422", "#d98322", "#f5b82e", "#ffd45e", "#ffeca6" }
local BEL  = { "#b8763a", "#d99a4e", "#efbe72", "#f9d996", "#fff0c4" }
local RED  = { "#4a1830", "#7a2238", "#b52e3f", "#e8493b", "#ff6e4e", "#ff9e78" }
local CAP  = { "#3a2a3a", "#4e3a4c", "#6a5064", "#8a6c80" }
local EMB  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb48a" }
local TRL  = "#8bc4ea"

c:groundShadow(32, 59, 15, 2)

-- tail: a fluffy open curl behind the right hip
local tl, tn = O.tube({ { 42, 44 }, { 55, 47 }, { 60, 35 }, { 52, 32 } }, function(t) return 2.6 - t * .8 end)
local tI, tT = O.shadeN(c, tl, tn, GLD, { amb = .25, wrap = .4, sep = GLD[1], rim = true, bounce = "#a86a6a", bmax = 2 })
O.tex(c, tI, tT, GLD, function(x, y, i) -- fur strands along the curl
  if H(x, y, 3) > .78 and i >= 3 then return -1 end
end)
local tip = c:poly{ { 49, 31 }, { 53, 29 }, { 55, 32 }, { 52, 34 }, { 49, 33 } }
O.shade(c, tip, EMB, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 }, sep = EMB[1] })

-- hind haunches + long feet
for _, s in ipairs({ { 21, -1 }, { 43, 1 } }) do
  local hx, d = s[1], s[2]
  local foot = c:ellipse(hx + d * 3, 53, 6.5, 2.2)
  O.shade(c, foot, GLD, { R = 1, amb = .25, sep = GLD[1], rim = true })
  for i = 0, 2 do O.mark(c, { { hx + d * 3 + d * 5 - i * d * 2 + (d > 0 and 0 or 0), 54 } }, GLD[2]) end -- toe splits
  local hau = c:ellipse(hx, 46, 6, 5.5)
  O.shade(c, hau, GLD, { sphere = { hx - 3, 42, 8 }, amb = .25, wrap = .4, sep = GLD[1], rim = true, bounce = "#a86a6a", bmax = 2 })
end

-- body/head: one round hopper
local body = c:ellipse(32, 37, 13.5, 12.5)
for _, t in ipairs({ { { 18, 33 }, { 16, 36 }, { 19, 37 } }, { { 18, 38 }, { 16, 41 }, { 20, 41 } },
                     { { 46, 33 }, { 48, 36 }, { 45, 37 } }, { { 46, 38 }, { 48, 41 }, { 44, 41 } }
                     }) do
  body:add(c:poly(t))
end
local bI, bT = O.shade(c, body, GLD, { sphere = { 26, 30, 19 }, amb = .36, wrap = .45, sep = GLD[1], rim = true, bounce = "#a86a6a", bmax = 2 })
-- soft fur flecks on the flanks
-- fur: little tufts (a darker fleck with a lit tip above-left), denser on the flanks, clear of the face
O.tex(c, bI, bT, GLD, function(x, y, i)
  local face = x >= 22 and x <= 42 and y >= 29 and y <= 42
  if face then return end
  local thr = .92
  if H(x, y, 7) > thr and i >= 3 then return -1 end
  if H(x, y + 1, 7) > thr and i >= 3 and (x < 22 or x > 42) then return -1 end -- 2 px strands on the flanks
  if H(x + 1, y + 1, 7) > thr and i >= 3 and i <= 5 then return 1 end
end)
-- cream belly
local bel = c:ellipse(32, 44, 7, 5)
for _, q in ipairs({ { 27, 40 }, { 31, 39 }, { 35, 39 }, { 38, 41 } }) do bel:add(c:ellipse(q[1], q[2], 1.6, 1.4)) end
bel:clip(body)
local lI, lT = O.shade(c, bel, BEL, { R = 3, amb = .4, wrap = .5, cuts = { .25, .45, .65, .85 } })
-- down fluff: little lit chevrons
O.dots(c, { { 28, 42 }, { 29, 41 }, { 30, 42 }, { 34, 43 }, { 35, 42 }, { 36, 43 } }, BEL[5])
O.dots(c, { { 28, 43 }, { 30, 43 }, { 34, 44 }, { 36, 44 } }, BEL[2])
-- fore paws tucked on the belly
-- the seed it keeps, held between the paws
local seed = c:ellipse(32, 47, 3.2, 2.6)
O.shade(c, seed, { "#5a2430", "#8a3a2e", "#c0663a", "#e8984e", "#ffc878" }, { R = 1.5, amb = .4, cuts = { .25, .45, .65, .85 }, sep = "#2b1c26" })
O.dots(c, { { 32, 44 }, { 32, 43 } }, "#3f7a3a") O.dots(c, { { 31, 42 }, { 30, 42 }, { 33, 42 }, { 34, 41 } }, "#8cc44a") -- sprout
O.dot(c, 30, 46, "#fff0c4") -- shine
for _, px in ipairs({ 28, 36 }) do
  O.shade(c, c:ellipse(px, 49, 2.5, 1.8), GLD, { R = 1, amb = .3, sep = GLD[2] })
end
O.dots(c, { { 27, 50 }, { 29, 50 }, { 35, 50 }, { 37, 50 } }, GLD[2]) -- finger splits

-- torii gate on its head
-- posts (hashira), slightly splayed, sink into the crown
for _, s in ipairs({ { 22, -1 }, { 42, 1 } }) do
  local px, d = s[1], s[2]
  local yb = 9
  while not body:has(px + 1, yb) do yb = yb + 1 end
  yb = yb + 1
  local post = c:poly{ { px, 9 }, { px + 2, 9 }, { px + 2 + (d > 0 and 1 or 0), yb }, { px - (d < 0 and 1 or 0), yb } }
  local pI, pT = O.shade(c, post, RED, { R = 1, amb = .3, wrap = .4, sep = RED[1], rim = true })
  O.tex(c, pI, pT, RED, function(x, y, i) if H(x, y // 4, 5) > .72 and i >= 3 then return -1 end end) -- lacquer grain
  -- black base collar (kamaki) where it meets the head
  O.flat(c, c:rect(px - (d < 0 and 1 or 0), yb - 1, px + 2 + (d > 0 and 1 or 0), yb), CAP[2], "kamaki")
  O.dots(c, { { px, yb - 1 } }, CAP[4])
end
-- nuki crossbar, sticking out past the posts
local nuki = c:rect(17, 15, 47, 17)
local nI, nT = O.shade(c, nuki, RED, { R = 1, amb = .3, wrap = .4, sep = RED[1], rim = true })
O.tex(c, nI, nT, RED, function(x, y, i) if H(x // 5, y, 9) > .7 and i >= 3 then return -1 end end)
-- gakuzuka centre strut
O.shade(c, c:rect(31, 11, 33, 14), RED, { R = 1, amb = .3, sep = RED[1] })
-- shimaki (red under-beam) + kasagi (black cap) with upturned ends
local shim = c:poly{ { 15, 9 }, { 49, 9 }, { 48, 11 }, { 16, 11 } }
local sI, sT = O.shade(c, shim, RED, { R = 1, amb = .3, wrap = .4, sep = RED[1] })
O.tex(c, sI, sT, RED, function(x, y, i) if H(x // 6, y, 13) > .72 and i >= 3 then return -1 end end)
local kas = c:poly{ { 11, 4 }, { 15, 6 }, { 49, 6 }, { 53, 4 }, { 52, 8 }, { 12, 8 } }
O.shade(c, kas, CAP, { R = 1, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, rim = true })
O.dots(c, { { 16, 6 }, { 17, 6 }, { 18, 6 }, { 19, 6 }, { 24, 6 }, { 25, 6 } }, CAP[4]) -- sheen
-- gold end caps on the upturned kasagi tips
O.flat(c, c:poly{ { 11, 4 }, { 13, 5 }, { 13, 7 }, { 12, 7 } }, "#d98322", "capL") O.dot(c, 12, 5, "#ffd45e")
O.flat(c, c:poly{ { 53, 4 }, { 51, 5 }, { 51, 7 }, { 52, 7 } }, "#d98322", "capR") O.dot(c, 52, 5, "#f5b82e")
-- nuki wedges (kusabi) beside the posts
O.dots(c, { { 20, 16 }, { 44, 16 } }, "#4e3a4c")
-- gold plaque (gakuzuka tablet)
O.flat(c, c:rect(31, 11, 33, 13), "#f5b82e", "plaque") O.dot(c, 31, 11, "#ffe38a") O.dot(c, 33, 13, "#d98322")
O.dot(c, 32, 12, "#9a5422") -- the gate's one-stroke name
-- closer look: a cherry petal resting on the crown between the posts
O.dots(c, { { 34, 24 }, { 35, 24 }, { 35, 23 } }, "#f5a3bd") O.dot(c, 34, 24, "#ffd0dc") O.dot(c, 36, 23, "#d9708f")

-- face
c:eyeLocked(24, 31)
c:eyeLocked(35, 31)
c:cheek(21, 38) c:cheek(41, 38)
O.dots(c, { { 31, 37 }, { 32, 37 } }, EMB[2]) O.dot(c, 31, 37, EMB[3]) -- nose
O.dots(c, { { 30, 39 }, { 31, 40 }, { 32, 40 }, { 33, 39 } }, "#5a2420") -- smile

-- quirk: dashed hop trail that loops the loop behind it (un-outlined, drawn after the outline)
O.done(c, "br-torii-loop-yard", function(c)
  local pts = {}
  local function add(x, y) pts[#pts+1] = { math.floor(x + .5), math.floor(y + .5) } end
  for t = 0, 1, .05 do add(3 + t * 5, 58 - t * 12) end                       -- lead-in up from the last step
  for a = 0, math.pi * 2, .1 do add(8 + 4.5 * math.sin(a), 41.5 + 4.5 * math.cos(a)) end -- the loop
  for t = 0, 1, .05 do add(8 + t * 7, 46 - 4.5 - t * 14) end                  -- back out toward the gate
  local seen, n = {}, 0
  for _, p in ipairs(pts) do
    local k = p[1] .. "," .. p[2]
    if not seen[k] then seen[k] = true n = n + 1
      if n % 3 < 2 and not c:get(p[1], p[2]) then c:put(p[1], p[2], TRL, { r = { name = "trail" } }) end
    end
  end
  -- a petal riding the loop
  for _, q in ipairs({ { 8, 41, "#f5a3bd" }, { 9, 41, "#ffd0dc" }, { 8, 42, "#d9708f" } }) do c:put(q[1], q[2], q[3], { r = { name = "petal" } }) end
end)

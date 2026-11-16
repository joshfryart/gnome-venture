-- Torii Loop (br-torii-loop), yard sprite 64x64. Opus second pass (art-2701-pals-all/c07/opus2), from the Haiku pass.
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
O.shadeN(c, tl, tn, GLD, { amb = .25, wrap = .4, sep = GLD[1], rim = true })
local tip = c:ellipse(51.5, 32, 2.5, 2.2)
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
local bI, bT = O.shade(c, body, GLD, { sphere = { 26, 30, 17 }, amb = .24, wrap = .45, sep = GLD[1], rim = true, bounce = "#a86a6a", bmax = 2 })
-- soft fur flecks on the flanks
O.tex(c, bI, bT, GLD, function(x, y, i)
  if (x < 20 or x > 44 or y > 44) and H(x, y, 7) > .8 and i >= 3 then return -1 end
end)
-- cream belly
local bel = c:ellipse(32, 44, 7, 5)
bel:clip(body)
O.shade(c, bel, BEL, { R = 3, amb = .4, wrap = .5, cuts = { .25, .45, .65, .85 } })
-- fore paws tucked on the belly
for _, px in ipairs({ 27, 37 }) do
  O.shade(c, c:ellipse(px, 49, 2.5, 1.8), GLD, { R = 1, amb = .3, sep = GLD[2] })
end

-- torii gate on its head
-- posts (hashira), slightly splayed, sink into the crown
for _, s in ipairs({ { 22, -1 }, { 42, 1 } }) do
  local px, d = s[1], s[2]
  local post = c:poly{ { px, 9 }, { px + 2, 9 }, { px + 2 + (d > 0 and 1 or 0), 27 }, { px - (d < 0 and 1 or 0), 27 } }
  O.shade(c, post, RED, { R = 1, amb = .3, wrap = .4, sep = RED[1], rim = true })
  -- black base collar (kamaki) where it meets the head
  O.flat(c, c:rect(px - (d < 0 and 1 or 0), 25, px + 2 + (d > 0 and 1 or 0), 26), CAP[2], "kamaki")
  O.dots(c, { { px, 25 } }, CAP[4])
end
-- nuki crossbar, sticking out past the posts
local nuki = c:rect(17, 15, 47, 17)
O.shade(c, nuki, RED, { R = 1, amb = .3, wrap = .4, sep = RED[1], rim = true })
-- gakuzuka centre strut
O.shade(c, c:rect(31, 11, 33, 14), RED, { R = 1, amb = .3, sep = RED[1] })
-- shimaki (red under-beam) + kasagi (black cap) with upturned ends
local shim = c:poly{ { 15, 9 }, { 49, 9 }, { 48, 11 }, { 16, 11 } }
O.shade(c, shim, RED, { R = 1, amb = .3, wrap = .4, sep = RED[1] })
local kas = c:poly{ { 11, 4 }, { 15, 6 }, { 49, 6 }, { 53, 4 }, { 52, 8 }, { 12, 8 } }
O.shade(c, kas, CAP, { R = 1, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, rim = true })
O.dots(c, { { 16, 6 }, { 17, 6 }, { 18, 6 }, { 19, 6 } }, CAP[4]) -- sheen
-- gold plaque (gakuzuka tablet)
O.flat(c, c:rect(31, 11, 33, 13), "#f5b82e", "plaque") O.dot(c, 31, 11, "#ffe38a") O.dot(c, 33, 13, "#d98322")

-- face
c:eyeLocked(24, 31)
c:eyeLocked(35, 31)
c:cheek(21, 38) c:cheek(41, 38)
O.dots(c, { { 31, 37 }, { 32, 37 } }, EMB[2]) O.dot(c, 31, 37, EMB[3]) -- nose
O.dots(c, { { 29, 39 }, { 30, 40 }, { 31, 39 }, { 32, 39 }, { 33, 40 }, { 34, 39 } }, "#5a2420") -- w-smile

-- quirk: dashed hop trail that loops the loop behind it (un-outlined, drawn after the outline)
O.done(c, "br-torii-loop-yard", function(c)
  local pts, last = {}, nil
  for i = 0, 140 do
    local t = i / 140
    -- rising arc from the lower left with one loop in it
    local x = 3 + t * 15 + 5 * math.sin(t * math.pi * 2.0) * (t > .3 and t < .8 and 1 or 0)
    local y = 56 - t * 26
    local a = (t - .3) / .5 * math.pi * 2
    if t > .3 and t < .8 then x = 9 + 4.5 * math.sin(a) + (t - .3) * 6; y = 40 - 4.5 * (1 - math.cos(a)) * .9 - (t - .3) * 10 end
    if t >= .8 then x = 12 + (t - .8) * 20; y = 35 - (t - .8) * 40 end
    local px, py = math.floor(x + .5), math.floor(y + .5)
    if px ~= (last and last[1]) or py ~= (last and last[2]) then pts[#pts+1] = { px, py } last = { px, py } end
  end
  for i, p in ipairs(pts) do
    if i % 4 < 2 and not c:get(p[1], p[2]) and p[1] < 16 then c:put(p[1], p[2], TRL, { r = { name = "trail" } }) end
  end
end)

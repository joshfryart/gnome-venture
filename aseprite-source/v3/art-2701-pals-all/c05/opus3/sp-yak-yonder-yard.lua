-- Yak Yonder (sp-yak-yonder), yard sprite 64x64. Opus richness pass (c05/opus3), built on c05/opus2.
-- Richness pass: hue-shifted fur ramp (plum-black shadow -> warm umber light), long strands with lit tips on the
-- fringe and wavy strands on the flank, gold diamond motifs woven into the blanket's red bands, growth rings on
-- the horns, burlap seams, a lit edge on the pennant pole and a wave in the flag.
-- closer-look detail: a little brass bell hanging under its chin on a red cord.
-- Wayfinder, common, Spicepeak. "Leads a laden yak across the bridge, because yonder is always further."
-- A shaggy mountain yak heading left: long dark-brown coat that hangs in a jagged fringe skirt almost to the
-- hooves (strand texture, rim light, cool bounce), a cream forelock over its brow, pale curved horns, locked
-- eyes and a soft muzzle. On its back: a striped woven blanket (red, teal and gold bands) and two rope-tied
-- burlap bundles.
-- Fixes vs Haiku: no longer a brown cow with a purple box. Shaggy fringe silhouette, horns curving up and out,
-- forelock, a real pack with blanket, bundles and rope; 6-tone fur ramp.
-- quirk: a little orange pennant on a pole stuck in the load, streaming forward (left), pointing yonder.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("sp-yak-yonder-yard", 64)

local FUR  = { "#20141e", "#3a2426", "#5c3a30", "#7e5440", "#a07250", "#c4946a" }
local LOCK = { "#7a6450", "#ad9474", "#d4be98", "#ecdcba", "#f6ecd4" }
local HORN = { "#6a5a48", "#a8987a", "#d8ccb0", "#f2ead6" }
local MUZ  = { "#4a3430", "#6e5248", "#957264", "#b89282" }
local HOOF = { "#2a2228", "#4a3e44", "#6a5c62" }
local RED  = { "#4f1a26", "#8f2a33", "#c2463f", "#e8704e", "#f49a72" }
local TEAL = { "#1f4e56", "#2f7a7e", "#4aa8a0", "#7cd0c0" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local SACK = { "#4a3622", "#6e5434", "#957448", "#b8965e", "#d8b880" }
local WOOD = { "#3d2620", "#64402c", "#8d6340", "#b48a58" }
local PEN  = { "#8a2a14", "#d0521e", "#f08a2e", "#fbbf5a" }
local BNC  = "#5a5a7a"

c:groundShadow(32, 57, 23, 2.5)

-- legs (short, mostly hidden by the fringe)
for i, lx in ipairs({ 22, 29, 41, 48 }) do
  local far = (i == 2 or i == 4)
  local m = c:rect(lx - 1, 48, lx + 2, 54)
  local bias = {} if far then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  O.shade(c, m, FUR, { R = 1, bias = bias, amb = .25, sep = FUR[1] })
  O.flat(c, c:rect(lx - 1, 55, lx + 2, 56), HOOF[2], "hoof") O.dot(c, lx - 1, 55, HOOF[3]) O.dot(c, lx + 2, 56, HOOF[1])
end
-- tail tuft at the back
local tl, tn = O.tube({ { 53, 33 }, { 57, 35 }, { 58, 40 }, { 57, 44 } }, function(t) return .8 + t * 1.2 end)
O.shadeN(c, tl, tn, FUR, { amb = .25, sep = FUR[1] })

-- body with the jagged fringe skirt
local body = c:ellipse(37, 37, 17, 10)
local hem = HP.mask()
for x = 20, 54 do
  local d = 49 + ((x % 4 < 2) and 1 or 0) + math.floor(H(x, 0, 3) * 2)
  for y = 38, d do hem:set(x, y) end
end
hem:clip(c:ellipse(37, 42, 18, 12))
body:add(hem)
local bb = {}
body:each(function(x, y) if y >= 46 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, FUR, { R = 6, bias = bb, amb = .2, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
-- long hanging strands: vertical streaks, lit and dark
O.tex(c, bI, bT, FUR, function(x, y, i)
  if y < 30 then return nil end
  local xs = x + math.floor(math.sin(y * .45) * 1.2 + .5) -- wavy strands
  if y < 41 then
    if xs % 4 == 0 and H(xs, 1, 5) > .4 and i >= 2 then return -1 end
    if xs % 4 == 2 and H(xs, 2, 6) > .6 and i >= 2 and i <= 5 then return 1 end
    return nil
  end
  if x % 3 == 0 and H(x, 1, 5) > .3 and i >= 2 then return -1 end
  if x % 3 == 1 and H(x, 2, 6) > .55 and i <= 5 then return 1 end
end)
-- lit strand tips along the fringe hem
for x = 21, 53, 3 do
  for y = 52, 38, -1 do if c:get(x, y) then O.mark(c, { { x, y - 1 } }, FUR[4]) break end end
end

-- pack: striped blanket draped over the back
local blanket = c:poly{ { 26, 29 }, { 33, 26 }, { 44, 26 }, { 50, 29 }, { 50, 39 }, { 46, 40 }, { 30, 40 }, { 26, 38 } }
local blI, blT = O.shade(c, blanket, RED, { R = 2, amb = .3, wrap = .4, cuts = { .22, .42, .62, .82 }, sep = FUR[1], rim = true })
for k, p in pairs(blI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local pi = y * c.w + x
  if c.own[pi] == blT then
    local band = (x - 26) % 8
    if band == 3 or band == 4 then c.pix[pi] = TEAL[math.min(4, p)]:lower()
    elseif band == 6 then c.pix[pi] = GOLD[math.min(4, p)]:lower() end
  end
end
-- gold diamond motifs in the red bands
for _, bx in ipairs({ 35, 43 }) do
  for _, cy in ipairs({ 30, 36 }) do
    O.mark(c, { { bx, cy - 1 }, { bx - 1, cy }, { bx + 1, cy }, { bx, cy + 1 } }, GOLD[3]) O.mark(c, { { bx, cy } }, RED[1])
  end
end
for x = 27, 49 do if c:get(x, 39) and x % 2 == 0 then O.mark(c, { { x, 40 } }, GOLD[3]) end end -- tassel hem
for x = 27, 49, 2 do if not c:get(x, 41) then O.dot(c, x, 41, GOLD[2]) end end

-- two burlap bundles tied on
for i, s in ipairs({ { 33, 22, 5.5, 4.5 }, { 44, 22.5, 5, 4 } }) do
  local m = c:ellipse(s[1], s[2], s[3], s[4])
  local sI, sT = O.shade(c, m, SACK, { R = 2, amb = .3, wrap = .4, sep = SACK[1], rim = true })
  O.tex(c, sI, sT, SACK, function(x, y, k)
    if (x + y) % 3 == 0 and y % 2 == 0 and k >= 2 then return -1 end
    if (x - y) % 3 == 0 and y % 2 == 1 and k >= 2 and k <= 4 then return 1 end
  end) -- weave
  O.mark(c, { { s[1] + 2, s[2] - 1 }, { s[1] + 2, s[2] }, { s[1] + 2, s[2] + 1 } }, SACK[2]) -- seam
  local ty = math.floor(s[2] - s[4] + .5)
  O.mark(c, { { s[1] - 1, ty }, { s[1], ty }, { s[1] + 1, ty } }, SACK[2]) O.mark(c, { { s[1] - 1, ty + 1 } }, SACK[5]) -- tied neck
end
-- rope across the load
local rope = {}
for x = 27, 50 do local y = 26 + math.floor(math.abs(x - 38.5) * .15) if c:get(x, y) then rope[#rope+1] = { x, y } end end
O.mark(c, rope, HORN[2])
for i, p in ipairs(rope) do if i % 3 == 0 then O.mark(c, { p }, HORN[1]) end end

-- quirk: pennant pole stuck in the load, flag streaming forward (left)
O.flat(c, c:rect(39, 5, 39, 21), WOOD[4], "pole") O.flat(c, c:rect(40, 5, 40, 21), WOOD[2], "pole")
O.mark(c, { { 39, 9 }, { 39, 15 } }, WOOD[3])
O.dot(c, 39, 4, GOLD[3]) O.dot(c, 40, 4, GOLD[2])
local flag = c:poly{ { 38, 5 }, { 30, 7 }, { 26, 9 }, { 30, 10 }, { 38, 12 } }
local fb = {} flag:each(function(x, y) if x < 32 and y > 8 then fb[K(x, y)] = -1 end end)
O.shade(c, flag, PEN, { R = 1, bias = fb, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = WOOD[1] })
O.mark(c, { { 33, 8 }, { 34, 8 }, { 35, 8 }, { 36, 8 } }, PEN[4])
O.mark(c, { { 31, 9 }, { 30, 9 } }, PEN[1]) -- wave fold

-- head, front and to the left
local horns = { { { 12, 30 }, { 8, 29 }, { 6, 26 }, { 7, 22 } }, { { 22, 30 }, { 26, 29 }, { 28, 26 }, { 27, 22 } } }
for _, h in ipairs(horns) do
  local m, n = O.tube(h, function(t) return 1.7 - t * .8 end)
  O.shadeN(c, m, n, HORN, { amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = HORN[1], rim = true })
  for _, t in ipairs({ .2, .4 }) do -- growth rings
    local x, y = O.bez(h, t)
    O.mark(c, { { math.floor(x + .5), math.floor(y + .5) } }, HORN[1])
  end
end
local head = c:ellipse(17, 36, 8.5, 7.5)
O.shade(c, head, FUR, { sphere = { 15, 33, 10 }, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
-- shaggy cheeks: jagged lower edge strands
O.dots(c, { { 9, 40 }, { 10, 42 }, { 24, 40 }, { 23, 42 } }, FUR[3])
-- forelock
local lock = c:poly{ { 10, 31 }, { 13, 28 }, { 18, 27 }, { 23, 29 }, { 24, 32 }, { 22, 33 }, { 20, 32 }, { 18, 34 }, { 16, 32 }, { 14, 33 }, { 12, 32 } }
local lI, lT = O.shade(c, lock, LOCK, { R = 1, amb = .35, wrap = .4, cuts = { .25, .45, .65, .85 }, sep = FUR[1], rim = true })
O.tex(c, lI, lT, LOCK, function(x, y, i) if x % 2 == 0 and i >= 2 then return -1 end end)
-- muzzle
local mz = c:ellipse(17, 41, 5, 2.5)
O.shade(c, mz, MUZ, { R = 1, amb = .4, wrap = .45, cuts = { .3, .55, .8 }, sep = FUR[1] })
O.dots(c, { { 15, 41 }, { 19, 41 } }, MUZ[1])
O.dots(c, { { 16, 43 }, { 17, 43 }, { 18, 43 } }, P.ink)
c:eyeLocked(10, 34) c:eyeLocked(19, 34)
-- closer-look detail: brass bell under the chin on a red cord
O.flat(c, c:rect(17, 45, 17, 45), RED[2], "cord")
local bell = c:poly{ { 16, 46 }, { 18, 46 }, { 19, 49 }, { 15, 49 } }
O.shade(c, bell, GOLD, { R = 1, amb = .35, cuts = { .35, .6, .85 }, sep = RED[1] })
O.dot(c, 16, 47, GOLD[4]) O.dot(c, 17, 50, HOOF[1])
c:cheek(9, 39) c:cheek(24, 39)

O.done(c, "sp-yak-yonder-yard")

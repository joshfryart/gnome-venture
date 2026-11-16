-- Tall Tiptoe (th-tall-tiptoe), yard sprite 64x64. Opus richness pass (c05/opus3), built on c05/opus2.
-- Richness pass: hue-shifted cream (olive-brown shadow -> warm ivory light) and chestnut ramps; each coat patch
-- darkens toward its edge and keeps the body's light; fine fur ticks on the cream; a two-tone mane; lit hooves;
-- the acacia sprig gets feathery leaflet pairs and a pale thorn.
-- closer-look detail: a red-billed oxpecker riding on its back.
-- Wayfinder, rare, Thornacre. "Reaches the top leaves before anybody else is out of bed."
-- A young giraffe stretched up on the tips of its hooves: slim legs ending in tiny dark hooves with the heels
-- lifted, a long neck rising on the diagonal to a round head turned to face you (locked eyes, pale muzzle,
-- two ossicones with dark tufts, side ears). Real giraffe coat: chestnut patches in a cream net (Voronoi
-- cells, each patch lit with the body), a short mane down the neck, tufted tail.
-- Fixes vs Haiku: three blot spots -> a proper patch net, legs slim and on tiptoe, head readable with
-- ossicones and muzzle, leaf no longer jammed on the head; the leaves are now what it is reaching for.
-- quirk: its long purple-blue tongue curls up out of the side of its mouth to hook the top acacia leaves.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-tall-tiptoe-yard", 64)

local CRM   = { "#6e4c34", "#a8783e", "#d4a65a", "#eac88a", "#f6e2b4", "#fcf2da" }
local OXP   = { "#3a2622", "#6a4a36", "#9a7652" }
local PAT   = { "#3a1f1a", "#5c2f1f", "#7e4128", "#a05630", "#bc6c3a", "#d4844a" }
local MUZ   = { "#a07c62", "#cfae8e", "#ead2b4", "#f8e8d2" }
local HOOF  = { "#2e2230", "#4a3a44", "#6a5660" }
local TONG  = { "#3a2a5e", "#5a4490", "#7e68b8", "#a690d6" }
local LEAF  = { "#1f3a2a", "#2f5a35", "#4a7d3c", "#6fa047", "#9cc25a", "#c8e080" }
local TWIG  = { "#3d2620", "#64402c", "#8d6340" }
local BNC   = "#6a6080"

-- giraffe coat: Voronoi patches. Returns true when (x,y) lies inside a patch (not on the cream net)
local seeds = {}
for gy = -1, 14 do for gx = -1, 14 do
  seeds[#seeds+1] = { gx * 5 + H(gx, gy, 1) * 3.5, gy * 5 + H(gx, gy, 2) * 3.5 }
end end
local function patch(x, y)
  local d1, d2 = 1e9, 1e9
  for _, s in ipairs(seeds) do
    local d = (x - s[1]) ^ 2 + (y - s[2]) ^ 2
    if d < d1 then d2 = d1 d1 = d elseif d < d2 then d2 = d end
  end
  local g = math.sqrt(d2) - math.sqrt(d1)
  if g > 2.6 then return 2 elseif g > 1.3 then return 1 end
  return false
end
local function coat(idx, tok, keep)
  for k, i in pairs(idx) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    local q = patch(x, y)
    if c.own[p] == tok and q and not (keep and keep(x, y)) then
      c.pix[p] = PAT[q == 2 and i or math.max(1, i - 1)]:lower() -- patch edge one tone darker
    elseif c.own[p] == tok and not q and H(x, y, 31) > .9 and i >= 3 and i <= 5 then
      c.pix[p] = CRM[i - 1]:lower() -- fur ticks on the cream net
    end
  end
end

c:groundShadow(25, 58, 14, 2)

-- legs, far pair first (darker), hooves on tiptoe (heel lifted: hoof is a 2x2 point with the leg kinked)
local legs = { { 16, 42, 15, 56, true }, { 29, 42, 30, 56, true }, { 13, 42, 12, 56 }, { 25, 42, 26, 56 } }
for _, L in ipairs(legs) do
  local m, n = O.tube({ { L[1], L[2] }, { L[1], L[2] + 5 }, { L[3], L[4] - 6 }, { L[3], L[4] - 2 } }, function(t) return 1.2 - t * .3 end)
  local bias = {}
  if L[5] then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  O.shadeN(c, m, n, CRM, { amb = .25, wrap = .35, bias = bias, sep = CRM[1] })
  O.shade(c, c:ellipse(L[3], L[4] - 7, 1.5, 1), CRM, { R = 1, amb = .35, bias = bias }) -- knee
  O.flat(c, c:rect(L[3] - 1, L[4] - 1, L[3] + 1, L[4]), HOOF[2], "hoof")
  O.dot(c, L[3] - 1, L[4] - 1, HOOF[3]) O.dot(c, L[3] + 1, L[4], HOOF[1]) O.dot(c, L[3], L[4] - 1, "#8a7480")
end

-- tail with tuft
local tl, tn = O.tube({ { 11, 36 }, { 8, 38 }, { 7, 42 }, { 7, 45 } }, function() return .7 end)
O.shadeN(c, tl, tn, CRM, { amb = .3, sep = CRM[1] })
O.shade(c, c:ellipse(7, 46, 1, 1.5), HOOF, { R = 1, amb = .4, cuts = { .4, .75 } })

-- body
local body = c:ellipse(21, 38, 11, 6.5)
local bI, bT = O.shade(c, body, CRM, { R = 5, amb = .22, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
coat(bI, bT)

-- neck on the diagonal up to the head, mane on the back edge
local nk, nkn = O.tube({ { 27, 36 }, { 32, 28 }, { 37, 21 }, { 41, 14 } }, function(t) return 3.6 - t * 1.4 end)
local nI, nT = O.shadeN(c, nk, nkn, CRM, { amb = .22, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
coat(nI, nT)
for t = .1, .9, .1 do
  local x, y = O.bez({ { 25, 34 }, { 30, 26 }, { 35, 19 }, { 39, 12 } }, t)
  O.dot(c, math.floor(x), math.floor(y), (t * 10) % 2 < 1 and PAT[2] or PAT[3])
  O.dot(c, math.floor(x) - 1, math.floor(y), (t * 10) % 2 < 1 and PAT[4] or PAT[2]) -- two-tone mane
end

-- head turned to face you
local head = c:ellipse(43, 12, 7.5, 6)
local hI, hT = O.shade(c, head, CRM, { sphere = { 41, 10, 8 }, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
coat(hI, hT, function(x, y) return y >= 7 end) -- face kept clear: only the crown carries a patch
-- side ears
O.shade(c, c:ellipse(35, 9.5, 2.5, 1.2), CRM, { R = 1, amb = .35, sep = CRM[1] })
O.shade(c, c:ellipse(51.5, 9.5, 2.5, 1.2), CRM, { R = 1, amb = .3, sep = CRM[1] })
-- ossicones with dark tufts
for _, ox in ipairs({ 40, 46 }) do
  O.flat(c, c:rect(ox, 4, ox + 1, 7), CRM[3], "oss") O.dot(c, ox, 5, CRM[5])
  O.flat(c, c:rect(ox - 1, 2, ox + 2, 3), PAT[2], "tuft") O.dot(c, ox - 1, 2, PAT[4])
end
-- muzzle
local mz = c:ellipse(43, 16, 4, 2.5)
O.shade(c, mz, MUZ, { R = 1, amb = .4, wrap = .45, cuts = { .3, .55, .8 }, sep = CRM[1] })
O.dots(c, { { 41, 15 }, { 45, 15 } }, MUZ[1]) -- nostrils
O.dots(c, { { 41, 18 }, { 42, 18 }, { 43, 18 }, { 44, 18 } }, P.ink)
-- eye sockets: a soft brown ring so the cream eye discs read against the cream face
for _, ex in ipairs({ 37, 44 }) do
  local ring = {}
  for i = 1, 3 do ring[#ring+1] = { ex + i, 8 } ring[#ring+1] = { ex + i, 14 } end
  for j = 1, 3 do ring[#ring+1] = { ex - 1, 9 + j } ring[#ring+1] = { ex + 5, 9 + j } end
  ring[#ring+1] = { ex, 9 } ring[#ring+1] = { ex + 4, 9 } ring[#ring+1] = { ex, 13 } ring[#ring+1] = { ex + 4, 13 }
  O.mark(c, ring, CRM[3])
  c:eyeLocked(ex, 9)
end
O.mark(c, { { 36, 9 }, { 49, 9 } }, PAT[2]) -- lash flicks
c:cheek(36, 14) c:cheek(49, 14)

-- acacia twig with leaves at the top right
local tw = c:line({ { 61, 4 }, { 57, 6 }, { 54, 9 } }, 1)
O.flat(c, tw, TWIG[2], "twig")
for _, lf in ipairs({ { 56, 4, 1.5, 1 }, { 59, 7, 1.5, 1 }, { 55, 8, 1.5, 1 }, { 59, 3, 1.5, 1 } }) do
  O.shade(c, c:ellipse(lf[1], lf[2], lf[3], lf[4]), LEAF, { R = 1, amb = .35, cuts = { .25, .45, .65, .85 }, sep = LEAF[1] })
end
-- feathery leaflet pairs along the twig and a pale thorn
O.dots(c, { { 58, 6 }, { 57, 5 }, { 60, 5 }, { 61, 3 } }, LEAF[5])
O.dot(c, 56, 7, "#efe4c8")
-- closer-look detail: a red-billed oxpecker riding on its back
O.shade(c, c:ellipse(15, 30.5, 2.5, 1.5), OXP, { R = 1, amb = .35, cuts = { .35, .7 }, sep = CRM[1] })
O.flat(c, c:rect(17, 29, 18, 30), OXP[2], "oxhead") O.dot(c, 17, 29, OXP[3])
O.dot(c, 18, 29, "#f4c83a") -- yellow eye-ring
O.dot(c, 19, 30, "#d8382a") -- red bill
O.dot(c, 12, 30, OXP[1]) -- tail

-- quirk: tongue curling out of the mouth corner up to hook the leaves
local tg, tgn = O.tube({ { 45, 18 }, { 50, 19 }, { 53, 15 }, { 54, 10 } }, function(t) return .9 - t * .3 end)
O.shadeN(c, tg, tgn, TONG, { amb = .3, cuts = { .3, .55, .8 }, sep = TONG[1] })
-- rare: a dawn sparkle (first one up)
c:sparkle(57, 13)

O.shift(c, 0, 1)
O.done(c, "th-tall-tiptoe-yard")

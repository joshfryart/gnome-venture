-- Nest Wobble (pl-cnd-5), yard sprite 64x64. Opus richness pass (c10/opus3), built on c10/opus2.
-- Richness pass: the cloud is bigger on the left with three clear puff bumps and seams (opus2 weakness: its bumps
-- were hidden by the nest), a bright lit lip along the front rim, crossing twigs with pale cut ends poking out of
-- the weave, three stray twigs (the right one forked), darker egg speckles.
-- closer look: a wisp of grey condor down caught on the left rim, beside the pink bloom.
-- Bloomcaller, uncommon. "A twiggy nest on a cloud that sways in the wind and never quite falls off."
-- A deep woven twig bowl, tipped to the right on top of a puffy cloud so its right side hangs past the cloud's
-- edge. Twigs cross in two directions with dark gaps between them, stray twig ends stick out of the rim, and a
-- pale speckled condor egg sits inside. The face sits on the woven front.
-- Haiku pass fixed: the face was on the egg and the nest read as a brown ring (a ufo or a hat brim).
-- quirk: the wobble. The nest leans out past the cloud's right edge, with sway arcs either side.
-- closer look: a little pink bloom tucked into the twigs (bloomcaller).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-5-yard", 64)

local TWIG = { "#3a2220", "#5e3828", "#865234", "#ae7444", "#d09a5c", "#ecc488" }
local SKY  = { "#6a84b8", "#8eaad4", "#b9d2ec", "#dcecf8", "#f2f8fc" }
local EGG  = { "#7a92a8", "#a8c0d0", "#cde0e8", "#eaf4f2", "#f8fcf8" }
local PET  = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

-- cloud
local cloud = O.unionCircles{ { 10, 50, 6, 5.5 }, { 13, 44, 5, 4.5 }, { 21, 45, 9, 8.5 }, { 33, 45, 9, 8 }, { 43, 50, 6, 5 }, { 26, 53, 19, 4 } }
cloud:cut(c:rect(0, 57, 63, 63))
local cI, cT = O.shade(c, cloud, SKY, { sphere = { 20, 40, 26 }, amb = .4, wrap = .55, cuts = { .25, .45, .7, .88 }, rim = true, bounce = "#9a8ad0", bmax = 2 })
-- puff seams
O.tex(c, cI, cT, SKY, function(x, y, i)
  for _, q in ipairs({ { 21, 45, 9, 8.5 }, { 33, 45, 9, 8 }, { 10, 50, 6, 5.5 }, { 13, 44, 5, 4.5 } }) do
    local dx, dy = (x - q[1]) / q[3], (y - q[2]) / q[4]
    local d = dx * dx + dy * dy
    if d > .82 and d < 1.05 and y > q[2] - 2 and x > q[1] and i >= 2 then return -1 end
  end
end)

-- nest in its own tipped frame
local CX, CY, A = 35, 30, math.rad(9)
local ca, sa = math.cos(A), math.sin(A)
local function loc(x, y) local dx, dy = x - CX, y - CY return dx * ca + dy * sa, -dx * sa + dy * ca end
local function M(f)
  local m = HP.mask()
  for y = 0, 63 do for x = 0, 63 do local u, v = loc(x, y) if f(u, v) then m:set(x, y) end end end
  return m
end
local function weave(I, T, R, dens)
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    if c.own[p] == T then
      local u, v = loc(x, y)
      local a = (math.floor(u / 6) % 2 == 0) and .6 or -.6
      local s = u * a + v
      local ii = i
      if (math.floor(s) % 3 == 0) then ii = i - 1 end -- gap between twigs
      if (math.floor(s) % 3 == 1) and H(x, y, 4) > .6 then ii = i + 1 end -- lit twig
      if R[ii] == nil then ii = math.max(1, math.min(#R, ii)) end
      c.pix[p] = R[ii]:lower()
    end
  end
end

-- back rim + hollow
local RV = -6
local rimBack = M(function(u, v) return (u / 19) ^ 2 + ((v - RV) / 5) ^ 2 <= 1 and v < RV end)
local rI, rT = O.shade(c, rimBack, TWIG, { R = 2, amb = .3, wrap = .45 })
weave(rI, rT, TWIG)
local hollow = M(function(u, v) return (u / 15.5) ^ 2 + ((v - RV) / 3) ^ 2 <= 1 end)
O.flat(c, hollow, TWIG[2], "hollow")
hollow:each(function(x, y) local u, v = loc(x, y) if v < RV - .5 then c.pix[y * c.w + x] = TWIG[1]:lower() end end)
-- egg inside
local egg = M(function(u, v) return ((u - 3) / 5.5) ^ 2 + ((v - RV + 3) / 6.5) ^ 2 <= 1 and v < RV + 2 end)
local eI, eT = O.shade(c, egg, EGG, { sphere = { 35, 17, 9 }, amb = .35, wrap = .5, cuts = { .25, .45, .7, .88 }, sep = TWIG[1] })
O.tex(c, eI, eT, EGG, function(x, y, i) local h = H(x, y, 17) if h > .9 then return -3 elseif h > .8 then return -1 end end) -- speckles
-- bowl body + front rim
local bowl = M(function(u, v) return v >= RV and (u / 19) ^ 2 + ((v - RV) / 17) ^ 2 <= 1 and v <= 11 end)
bowl:add(M(function(u, v) return (u / 19) ^ 2 + ((v - RV) / 5) ^ 2 <= 1 and v >= RV end))
bowl:cut(hollow)
local bI, bT = O.shade(c, bowl, TWIG, { sphere = { 28, 24, 26 }, amb = .3, wrap = .45, rim = true, bounce = "#6a6aa0", bmax = 2, sep = TWIG[1] })
weave(bI, bT, TWIG)
-- smooth woven patch under the face so the eyes read
local faceM = M(function(u, v) return (u / 11) ^ 2 + ((v - 2.5) / 5) ^ 2 <= 1 end)
faceM:each(function(x, y) local i = bI[K(x, y)] or 4 c.pix[y * c.w + x] = TWIG[math.max(3, math.min(5, i))]:lower() end)
-- lit lip along the front rim (top edge of the bowl)
bowl:each(function(x, y)
  local u, v = loc(x, y)
  if v >= RV and v < RV + 1.2 and not bowl:has(x, y - 1) and not faceM:has(x, y) then c.pix[y * c.w + x] = TWIG[(u < 8) and 6 or 5]:lower() end
end)
-- pale cut twig ends poking out of the weave
for _, e in ipairs({ { 21, 33 }, { 44, 34 }, { 26, 41 }, { 41, 40 }, { 33, 44 } }) do
  if bowl:has(e[1], e[2]) and not faceM:has(e[1], e[2]) then O.mark(c, { e }, TWIG[6]) O.mark(c, { { e[1] + 1, e[2] + 1 } }, TWIG[1]) end
end
-- stray twigs out of the rim, the right one forked
for _, tw in ipairs({ { { 20, 21 }, { 15, 17 } }, { { 47, 22 }, { 51, 16 } }, { { 51, 18 }, { 54, 17 } }, { { 51, 18 }, { 52, 15 } } }) do
  local m = c:line(tw, 1)
  m:cut(bowl) m:cut(rimBack)
  local tk = O.flat(c, m, TWIG[4], "twig")
  local e = tw[#tw]
  O.mark(c, { e }, TWIG[6])
end
-- closer look: a wisp of grey condor down caught on the left rim
local dw = HP.mask()
for _, p in ipairs({ { 25, 20 }, { 25, 19 }, { 24, 19 }, { 24, 18 }, { 23, 17 }, { 22, 17 }, { 22, 16 }, { 23, 16 } }) do if not c:get(p[1], p[2]) then dw:set(p[1], p[2]) end end
O.flat(c, dw, "#b8b4c4", "down")
O.mark(c, { { 25, 20 }, { 24, 19 } }, "#7e7a90") O.mark(c, { { 22, 16 }, { 23, 16 } }, "#e4e0e8")

-- face on the woven front
local function face(u, v) local x = CX + u * ca - v * sa local y = CY + u * sa + v * ca return math.floor(x + .5), math.floor(y + .5) end
local lx, ly = face(-6, 0)
local rx, ry = face(5, 0)
c:eyeLocked(lx - 2, ly - 2)
c:eyeLocked(rx - 2, ry - 2)
local mx, my = face(0, 5)
O.dots(c, { { mx - 2, my - 1 }, { mx - 1, my }, { mx, my }, { mx + 1, my }, { mx + 2, my } }, P.ink)
local ax, ay = face(-11, 4) c:cheek(ax, ay)
local bx, by = face(10, 4) c:cheek(bx, by)

-- closer look: a pink bloom tucked in the twigs, lower left of the bowl
local bloom = O.unionCircles{ { 20, 30, 1.5, 1.5 }, { 23, 30, 1.5, 1.5 }, { 21.5, 28, 1.5, 1.5 }, { 21.5, 32, 1.5, 1.5 } }
O.shade(c, bloom, PET, { R = 1, amb = .4, wrap = .5, cuts = { .3, .6, .85 }, sep = TWIG[1] })
O.dot(c, 21, 30, "#f5b82e") O.dot(c, 22, 30, "#d98322")

O.shift(c, -1, -1)
O.done(c, "pl-cnd-5-yard", function(c)
  -- sway arcs either side
  local arcs = { { 10, 19 }, { 9, 19 }, { 9, 20 }, { 9, 21 }, { 8, 21 }, { 8, 22 }, { 8, 23 }, { 8, 24 }, { 8, 25 }, { 9, 25 }, { 9, 26 }, { 9, 27 }, { 10, 27 },
                 { 5, 21 }, { 5, 22 }, { 5, 23 }, { 4, 23 }, { 4, 24 }, { 5, 24 }, { 5, 25 },
                 { 57, 30 }, { 58, 30 }, { 58, 31 }, { 58, 32 }, { 59, 32 }, { 59, 33 }, { 59, 34 }, { 59, 35 }, { 58, 35 }, { 58, 36 }, { 58, 37 }, { 57, 37 } }
  for _, p in ipairs(arcs) do c:put(p[1], p[2], P.ink) end
end)

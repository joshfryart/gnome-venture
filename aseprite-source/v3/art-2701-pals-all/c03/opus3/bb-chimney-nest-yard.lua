-- Chimney Nest (bb-chimney-nest), yard sprite 64x64. Opus richness pass (c03/opus3), built on c03/opus2.
-- Uncommon, seedkeeper, Birchbramble. "A stork's nest on a chimney, and a stork who never moves out."
-- Richness pass: the nest is rebuilt as a deep woven bowl of single sticks (each stick its own stroke, lit by the
-- upper-left light, dark gaps between, pale cut ends, a few strays poking out) instead of a flat noisy ellipse;
-- bricks get per-brick tone, lit top lips and a soot streak; the stone cap is chipped; slate tiles get lit edges
-- and a moss patch; the dozing stork gets covert scallops and black primaries.
-- quirk: a striped sock hung to dry on a nest twig. closer look: a curl of chimney smoke sneaks out under the nest,
-- keeping the stork's toes warm.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local floor, max, min = math.floor, math.max, math.min
local c = O.canvas("bb-chimney-nest-yard", 64)

local BRK  = { "#3e1820", "#6a2428", "#963a2e", "#bc5838", "#da8450", "#f0b07e" }
local MOR  = { "#4e3e48", "#6e5e62", "#90807c", "#b0a294", "#ccc0ae", "#e4dacb" }
local STN  = { "#33304a", "#4e4b66", "#6e6c86", "#918fa6", "#b6b4c6", "#d8d6e0" }
local SLT  = { "#202238", "#30344f", "#434a6c", "#5a6488", "#7682a6", "#9aa6c4" }
local TWG  = { "#2e1a16", "#4a2c1c", "#6e4426", "#946234", "#b8844a", "#dcb072" }
local STK  = { "#6a6278", "#968ea8", "#c2bccc", "#e4dfe8", "#f4f0ee" }
local BLK  = { "#21182a", "#3a2c42", "#55465e" }
local BILL = { "#6e1c18", "#b0341e", "#de582a", "#f4904c" }
local MOSS = { "#2c4a34", "#4a7a40", "#7cac52" }
local SOCK = { "#6e1a2a", "#b0304a", "#d84a5e", "#ece2d8" }
local SMK  = { "#8a8aa4", "#b4b4c8", "#dcdce6" }

-- slate roof slice under the chimney, tiles in staggered rows that follow the slope
local roof = c:poly{ { 4, 61 }, { 4, 57 }, { 60, 49 }, { 60, 61 } }
local rI, rT = O.shade(c, roof, SLT, { R = 3, amb = .3, wrap = .4, rim = true })
O.tex(c, rI, rT, SLT, function(x, y, i)
  local yy = y + floor((x - 4) * 8 / 56)
  local row = yy // 4
  if yy % 4 == 0 then return -1 end                                          -- tile bottom edge
  if yy % 4 == 1 and i <= 5 then return 1 end                                -- lit tile lip
  if (x + row * 3) % 7 == 0 and i >= 2 then return -1 end                   -- tile joints
end)
-- moss patch and lichen on the slates (right of the chimney, catching the light)
local moss = c:ellipse(49, 52, 3, 1)
moss:each(function(x, y) if roof:has(x, y) then O.mark(c, { { x, y } }, (x + y) % 2 == 0 and MOSS[3] or MOSS[2]) end end)
O.mark(c, { { 47, 53 }, { 51, 53 }, { 53, 52 } }, MOSS[1]) O.mark(c, { { 48, 51 }, { 50, 51 } }, MOSS[3])
O.mark(c, { { 12, 58 }, { 55, 57 }, { 9, 59 } }, "#b8b47a")

-- chimney stack: per-brick tone, lit top lip, recessed mortar
local stack = c:poly{ { 20, 32 }, { 42, 32 }, { 42, 52 }, { 20, 55 } }
local sI, sT = O.shade(c, stack, BRK, { R = 4, amb = .22, wrap = .35, sep = BRK[1], rim = true, bounce = "#7a6a9a", bmax = 2 })
for k, i in pairs(sI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == sT then
    local row = (y - 33) // 3
    local bx = (x - 20 + (row % 2) * 3)
    local col = bx // 6
    local face = x >= 23 and x <= 39 and y >= 36 and y <= 46
    if (y - 33) % 3 == 2 or bx % 6 == 5 then
      c.pix[p] = MOR[max(1, min(6, i - 1))]:lower()
    else
      local d = 0
      local hb = H(col, row, 21)
      if hb > .75 then d = d + 1 elseif hb < .25 then d = d - 1 end
      if face then d = max(0, d) end
      if (y - 33) % 3 == 0 and bx % 6 <= 2 and i >= 3 then d = d + 1 end   -- lit lip on the brick's upper-left
      if not face and H(x, y, 3) > .92 then d = d - 1 end                 -- pits
      local t = i + d
      if face then t = min(t, 5) end
      c.pix[p] = BRK[max(1, min(6, t))]:lower()
    end
  end
end
-- soot streak down from the cap
O.mark(c, { { 35, 33 }, { 36, 33 }, { 37, 33 }, { 36, 34 }, { 37, 34 }, { 36, 35 }, { 37, 36 } }, BRK[1])
O.mark(c, { { 34, 33 }, { 38, 33 }, { 38, 34 } }, BRK[2])

-- stone cap, chipped at the front corner
local cap = c:rect(17, 29, 45, 32)
cap:cut(c:rect(44, 32, 45, 32)) cap:cut(c:rect(45, 31, 45, 31))
local qI, qT = O.shade(c, cap, STN, { R = 1, amb = .3, sep = STN[1], rim = true, bounce = "#7a7aa8", bmax = 2 })
O.tex(c, qI, qT, STN, function(x, y, i) if H(x, y, 5) > .86 and i >= 2 then return -1 end end)
O.mark(c, { { 28, 31 }, { 29, 32 } }, STN[2]) -- crack

-- the back rim of the nest (behind the stork)
local function stickTone(x, y, base)
  local v = .62 - .42 * (x - 31) / 19 - .55 * (y - 24) / 8 + base
  return max(2, min(6, floor(v * 5) + 1))
end
local back = c:ellipse(31, 21.5, 18.5, 3.5)
O.shade(c, back, TWG, { R = 2, amb = .2, wrap = .3, cuts = { .3, .5, .7, .85, .95 }, sep = TWG[1] })

-- stork body (sits down in the nest), covert scallops, black primaries to the tail
local sb = c:ellipse(34, 18, 10, 5.5)
local kI, kT = O.shade(c, sb, STK, { sphere = { 31, 14, 12 }, amb = .3, wrap = .4, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
O.tex(c, kI, kT, STK, function(x, y, i)
  if x >= 38 and y >= 16 then return -(i - 1) end                         -- primaries
  if x >= 28 and x < 38 and y >= 16 and (x + (y % 2) * 2) % 4 == 0 and i >= 3 then return -1 end -- coverts
end)
O.mark(c, { { 41, 15 }, { 43, 16 }, { 44, 17 }, { 45, 18 } }, BLK[2])
O.mark(c, { { 40, 17 }, { 42, 18 } }, BLK[3])
-- neck and head
local nk, nn = O.tube({ { 28, 17 }, { 26, 13 }, { 24, 10 }, { 23, 7 } }, function(t) return 2.6 - t * .5 end)
O.shadeN(c, nk, nn, STK, { amb = .35, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
local hd = c:ellipse(22, 6, 4, 3.5)
O.shade(c, hd, STK, { sphere = { 20, 4, 5 }, amb = .35, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
-- long red bill resting down over the rim
local bl, bn = O.tube({ { 19, 7 }, { 15, 9 }, { 12, 12 }, { 10, 16 } }, function(t) return 1.5 - t * .9 end)
O.shadeN(c, bl, bn, BILL, { amb = .35, cuts = { .3, .55, .8 }, sep = BILL[1] })
O.dots(c, { { 16, 9 }, { 14, 10 } }, BILL[4])
-- dozing: closed lid arc, pink cheek
O.dots(c, { { 20, 5 }, { 21, 6 }, { 22, 6 }, { 23, 5 } }, P.ink)
O.dot(c, 24, 8, "#f5809f")

-- nest bowl front: deep woven bowl made of single sticks
local bowl = c:ellipse(31, 21, 19.5, 9)
bowl:cut(c:rect(0, 0, 63, 20))
bowl:add(c:ellipse(31, 21.5, 19.5, 2))
O.flat(c, bowl, TWG[2], "nest")
local nT = { r = { name = "nestfront" } }
bowl:each(function(x, y) c:put(x, y, (x > 36 or y > 26) and TWG[1] or TWG[2], nT) end)
-- strands: arcs that follow the bowl's front curve, broken into overlapping sticks
local function arcY(x, y0) local u = (x - 31) / 19.5 return y0 + 3.2 * (1 - u * u) end
for row = 0, 5 do
  local y0 = 19 + row * 1.6
  local x = 11 + floor(H(row, 1, 9) * 5)
  local n = 0
  while x < 52 do
    n = n + 1
    local len = 5 + floor(H(row, n, 13) * 8)
    local tilt = (H(row, n, 17) - .5) * .25
    local base = (H(row, n, 19) - .5) * .3
    for xx = x, x + len - 1 do
      local y = floor(arcY(xx, y0) + (xx - x) * tilt + .5)
      if bowl:has(xx, y) then
        local t = stickTone(xx, y, base)
        if xx == x and H(row, n, 23) > .6 then t = 6 end                   -- pale cut end
        c:put(xx, y, TWG[t], nT)
      end
    end
    x = x + len - 1 - floor(H(row, n, 29) * 3)
  end
end
-- crossing sticks woven diagonally through the front
for _, s in ipairs({ { 15, 22, 20, 28 }, { 24, 21, 30, 29 }, { 38, 21, 34, 29 }, { 45, 21, 41, 27 }, { 19, 21, 23, 26 } }) do
  local pts = c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1)
  pts:each(function(x, y) if bowl:has(x, y) and (x + y) % 3 ~= 0 then c:put(x, y, TWG[stickTone(x, y, .1)], nT) end end)
end
-- stray sticks poking out of the silhouette (single sticks, lit tip)
local strays = { { { 13, 20 }, { 7, 17 } }, { { 13, 24 }, { 8, 26 } }, { { 49, 19 }, { 55, 16 } }, { { 49, 24 }, { 56, 25 } },
  { { 20, 28 }, { 17, 31 } }, { { 43, 28 }, { 47, 31 } }, { { 29, 19 }, { 27, 16 } }, { { 37, 19 }, { 39, 15 } } }
for _, s in ipairs(strays) do
  local m = c:line(s, 1)
  local tk = { r = { name = "stray" } }
  m:each(function(x, y) c:put(x, y, TWG[stickTone(x, y, 0)], tk) end)
  c:put(s[2][1], s[2][2], TWG[min(6, stickTone(s[2][1], s[2][2], .2) + 1)], tk)
end
-- the stork's tucked belly feathers lip over the back of the rim
O.dots(c, { { 31, 20 }, { 32, 20 }, { 33, 20 }, { 34, 20 }, { 35, 20 }, { 36, 20 }, { 37, 20 } }, STK[2])
O.dots(c, { { 32, 20 }, { 34, 20 } }, STK[3])

-- face on the chimney
c:eyeLocked(24, 38) c:eyeLocked(34, 38)
c:cheek(22, 44) c:cheek(39, 44)
O.dots(c, { { 28, 45 }, { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 45 } }, P.ink)
O.dots(c, { { 30, 47 }, { 31, 47 } }, "#e05a6a")

-- quirk: a striped sock drying on a twig
local sock = c:poly{ { 52, 26 }, { 55, 26 }, { 55, 32 }, { 58, 33 }, { 58, 35 }, { 52, 35 } }
local skI, skT = O.shade(c, sock, { SOCK[1], SOCK[2], SOCK[3] }, { R = 1, amb = .4, cuts = { .35, .7 }, sep = SOCK[1] })
O.tex(c, skI, skT, { SOCK[1], SOCK[2], SOCK[3], SOCK[4] }, function(x, y, i)
  if y == 26 or y == 29 or y == 32 then return 4 - i end   -- cream stripes (cuff, two bands)
  if y == 27 or y == 30 then return 0 end
end)
O.dots(c, { { 57, 35 }, { 58, 34 } }, SOCK[1]) -- toe darning
O.dots(c, { { 53, 34 } }, "#e8b44a")        -- a gold darning stitch on the heel
local tw = c:line({ { 48, 24 }, { 57, 26 } }, 1)
local twk = { r = { name = "twig" } }
tw:each(function(x, y) c:put(x, y, TWG[4], twk) end) c:put(57, 26, TWG[6], twk) c:put(48, 24, TWG[3], twk)

-- closer look: a curl of chimney smoke sneaking out from under the nest, warming the stork's toes
for _, q in ipairs({ { 13, 31, 1.4 }, { 9.5, 29.5, 1.6 }, { 6.5, 27, 1.2 }, { 5, 24, .8 } }) do
  O.shade(c, c:ellipse(q[1], q[2], q[3], q[3]), SMK, { R = 1, amb = .45, wrap = .5, cuts = { .35, .7 } })
end
O.dots(c, { { 10, 30 }, { 9, 30 } }, SMK[1])
O.done(c, "bb-chimney-nest-yard")

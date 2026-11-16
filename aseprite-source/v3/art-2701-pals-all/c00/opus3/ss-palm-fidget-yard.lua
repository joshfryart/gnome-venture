-- Palm Fidget (ss-palm-fidget), yard sprite 64x64. Opus richness pass (c00/opus3), built on c00/opus2.
-- Richness pass: the tapping foot is now clearly up (6 px, on a little leg, toes tipped), an open grin with a
-- row of pale coconut-flesh teeth so the mouth reads on the dark husk (opus2's was low contrast), leaflet
-- midribs and dry brown frond tips, bigger tap ticks and curled breeze swooshes; the husk shows the coconut's
-- three little pores up on its crown (the closer-look detail).
-- Bloomcaller, common, Sunsprinkle. "Cannot sit still when the breeze is fresh."
-- A hairy coconut with a crown of three real palm fronds (a curved rachis with leaflets both sides, not bare
-- sticks), all swept to the right by the breeze; coir hair strokes over the husk, rim light and a cool bounce.
-- quirk: it cannot sit still: one stubby foot is up mid-tap, two tap ticks under it, breeze swooshes behind.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-palm-fidget-yard", 64)

local NUT  = { "#2e1c1e", "#4e2e26", "#74472f", "#9a6640", "#bf8a58", "#dcae7a" }
local FROND = { "#1f4438", "#2a6a42", "#3f9150", "#62b257", "#9ccf6a", "#d0eb96" }
local FOOT = { "#4e2e26", "#74472f", "#9a6640", "#bf8a58" }

-- frond: a broad blade along bezier p, slit from the edges toward the rachis into leaflets that point to the tip
local function frond(p, w)
  local wf = function(t) return w * math.sin(math.pi * (.15 + .85 * t)) ^ .6 * (1 - .35 * t) + .6 end
  local m, n, T, S = O.tube(p, wf)
  -- slits: from near the spine out to the edge, angled toward the tip, both sides
  for k = 1, 7 do
    local t0 = .1 + k * .11
    local t1 = math.min(1, t0 + .07)
    local x0, y0 = O.bez(p, t0)
    local x1, y1 = O.bez(p, t1)
    local xa, ya = O.bez(p, math.min(1, t1 + .01))
    local tx, ty = xa - x1, ya - y1
    local l = math.sqrt(tx * tx + ty * ty) if l == 0 then l = 1 end
    tx, ty = tx / l, ty / l
    for _, sd in ipairs({ -1, 1 }) do
      local px, py = -ty * sd, tx * sd
      local e = wf(t1) + 1
      local sx, sy = x0 + px * 1.6, y0 + py * 1.6
      m:cut(c:line({ { math.floor(sx + .5), math.floor(sy + .5) }, { math.floor(x1 + px * e + .5), math.floor(y1 + py * e + .5) } }, 1))
    end
  end
  local I, Tk = O.shadeN(c, m, n, FROND, { amb = .2, wrap = .4, rim = true, bounce = "#2f5a6a", bmax = 2 })
  -- spine one tone down, leaflet ribs (+1 streak halfway out), dry brown tip
  m:each(function(x, y)
    local sd, t = S[K(x, y)], T[K(x, y)]
    local q = y * c.w + x
    if c.own[q] ~= Tk or not sd then return end
    local i = I[K(x, y)] or 3
    if t > .93 then c.pix[q] = (i >= 3) and "#b08a4a" or "#7a5a32"
    elseif math.abs(sd) < .16 then c.pix[q] = FROND[math.max(2, i - 1)]
    elseif math.abs(math.abs(sd) - .55) < .1 and i >= 3 and i <= 5 then c.pix[q] = FROND[i + 1] end
  end)
end

c:groundShadow(31, 57, 14, 2.5)

-- fronds behind the nut, all leaning right in the breeze
frond({ { 30, 28 }, { 24, 20 }, { 14, 18 }, { 7, 26 } }, 5)
frond({ { 33, 28 }, { 42, 18 }, { 53, 17 }, { 58, 28 } }, 5.5)
frond({ { 31, 27 }, { 27, 12 }, { 38, 4 }, { 52, 9 } }, 6)

-- feet: left planted, right lifted mid-tap
O.shade(c, c:ellipse(25, 54, 4, 2), FOOT, { R = 1, amb = .3, wrap = .4, cuts = { .3, .55, .8 } })

-- the coconut
local nut = c:ellipse(32, 39, 14, 13)
local nI, nT = O.shade(c, nut, NUT, { sphere = { 27, 33, 20 }, amb = .3, wrap = .45, rim = true, bounce = "#7a5a72", bmax = 2 })
-- coir hair: short diagonal strokes, light and dark
O.tex(c, nI, nT, NUT, function(x, y, i)
  if x >= 22 and x <= 42 and y >= 34 and y <= 46 then return 0 end -- keep the face clean
  local h = H(x - y, y, 5)
  if (x + y * 2) % 5 == 0 and h > .4 then return -1 end
  if (x + y * 2) % 5 == 2 and h > .7 and i >= 3 then return 1 end
end)
-- the three pores on the crown
O.mark(c, { { 37, 29 }, { 39, 30 }, { 38, 32 } }, NUT[1])
O.mark(c, { { 36, 29 }, { 38, 30 }, { 37, 32 } }, NUT[3])
-- tuft of fibre where the fronds join
O.dots(c, { { 30, 26 }, { 31, 26 }, { 33, 26 }, { 34, 27 }, { 29, 27 } }, NUT[5])

-- the lifted, tapping foot (in front)
local leg, ln = O.tube({ { 40, 49 }, { 43, 49 }, { 45, 48 }, { 46, 46 } }, function(t) return 1.3 end)
O.shadeN(c, leg, ln, FOOT, { amb = .3, wrap = .4, cuts = { .3, .55, .8 }, sep = NUT[1] })
local foot = c:poly{ { 44, 43 }, { 50, 44 }, { 51, 46 }, { 45, 48 } }
O.shade(c, foot, FOOT, { R = 1, amb = .3, wrap = .4, cuts = { .3, .55, .8 }, sep = NUT[1] })
O.dots(c, { { 51, 45 }, { 50, 44 } }, FOOT[1])

-- face
c:eyeLocked(24, 36)
c:eyeLocked(35, 36)
c:cheek(22, 43) c:cheek(40, 43)
O.dots(c, { { 28, 44 }, { 29, 44 }, { 30, 44 }, { 31, 44 }, { 32, 44 }, { 33, 44 }, { 34, 44 }, { 35, 44 },
             { 29, 45 }, { 34, 45 }, { 29, 46 }, { 34, 46 }, { 30, 47 }, { 31, 47 }, { 32, 47 }, { 33, 47 } }, P.ink)
O.dots(c, { { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 } }, "#f4ead0")   -- coconut-flesh teeth
O.dots(c, { { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 } }, "#c0484e")
O.dots(c, { { 31, 46 }, { 32, 46 } }, P.petal.base)

O.shift(c, 0, 0)
O.done(c, "ss-palm-fidget-yard", function(c)
  -- tap ticks under the lifted foot, breeze swooshes behind (not outlined)
  for _, p in ipairs({ { 43, 53 }, { 42, 54 }, { 41, 55 }, { 47, 52 }, { 47, 53 }, { 47, 54 }, { 51, 53 }, { 52, 54 }, { 53, 55 } }) do c:put(p[1], p[2], P.ink) end
  for _, p in ipairs({ { 2, 38 }, { 3, 38 }, { 4, 38 }, { 5, 38 }, { 6, 37 }, { 7, 37 }, { 8, 36 }, { 8, 35 }, { 7, 34 },
                       { 4, 44 }, { 5, 44 }, { 6, 44 }, { 7, 44 }, { 8, 43 }, { 9, 43 }, { 10, 42 } }) do c:put(p[1], p[2], "#8bc4ea") end
  for _, p in ipairs({ { 6, 34 }, { 11, 41 } }) do c:put(p[1], p[2], "#c4e4f4") end
end)

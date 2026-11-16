-- Tide Tuck (ss-tide-tuck), yard sprite 64x64. Opus richness pass (c00/opus3), built on c00/opus2.
-- Brewroot, common, Sunsprinkle. "Tucks itself into the sand just before a wave."
-- A cockle-shell creature: a broad sand-gold dome with radiating ribs (lit crests, dark grooves, fading off the
-- face), dug into a sand mound up to its chin, two small paws holding the sand up like a blanket.
-- Fixes the opus2 weakness (the wave outweighed the pal): the pal is now the big central mass and the wave is a
-- smaller curl standing behind it on the right, its lip arching over the pal's head. Wet dark sand and a foam wash
-- where the wave lands; dry grainy sand with ripple lines in front.
-- quirk: a tiny pink starfish has been tucked into the sand blanket too.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-tide-tuck-yard", 64)

local SEA  = { "#1c3058", "#264a7c", "#2c6e9c", "#3a9ab6", "#66c4c4", "#a6e6d8" }
local FOAM = { "#9cc8cc", "#d6ece4", "#fff4d6" }
local SAND = { "#86583e", "#b48452", "#d6a86c", "#ebc88a", "#f8e2ac" }
local WET  = { "#6a4a3e", "#8e6650", "#ad8460" }
local SHEL = { "#743228", "#ac5a2c", "#d68838", "#f0b04c", "#ffd474", "#fff0ac" }
local STAR = { "#9a3a4a", "#e0606a", "#ff9a8a" }

c:groundShadow(32, 58, 28, 2)

-- the wave, behind and to the right: rises from the sand, curls left over the pal's head
local wp = { { 53, 52 }, { 61, 30 }, { 52, 9 }, { 38, 14 } }
local wave, wn, WT, WS = O.tube(wp, function(t) return 6 * (1 - t) ^ .7 + 1.5 end)
wave:cut(c:rect(0, 53, 63, 63))
local wI, wTk = O.shadeN(c, wave, wn, SEA, { amb = .22, wrap = .4, bounce = "#1c2a4e", bmax = 2 })
O.tex(c, wI, wTk, SEA, function(x, y, i)
  local s, t = WS[K(x, y)], WT[K(x, y)]
  if not s then return 0 end
  if s < -.25 and t and t < .9 then
    if (t * 12 + s * .5) % 1 < .14 then return 2 end -- flow streaks on the lit inner face
    return 1
  end
  if s > .62 then return -1 end
end)
-- foam crest: scalloped cream along the outer top edge of the curl
wave:each(function(x, y)
  local t, s = WT[K(x, y)], WS[K(x, y)]
  if t and s and t > .35 and t < .98 and s > .5 then
    local q = y * c.w + x
    if c.own[q] == wTk then c.pix[q] = (H(x, y, 3) > .45 or s > .82) and FOAM[3] or FOAM[2] end
  end
end)
O.flat(c, c:ellipse(37, 15, 2, 1.5), FOAM[3], "spray")
O.dot(c, 36, 17, FOAM[2])

-- the creature: a broad cockle dome
local dome = c:ellipse(28, 41, 15, 13)
local dI, dT = O.shade(c, dome, SHEL, { sphere = { 24, 36, 17 }, amb = .25, wrap = .4, rim = true, bounce = "#7a6a92", bmax = 2, sep = SEA[1] })
-- radiating ribs from a hinge below the face: crest (+1 on the lit side), groove (-1); off the face oval
local function onFace(x, y) return ((x - 28) / 11)^2 + ((y - 43) / 6)^2 < 1 end
O.tex(c, dI, dT, SHEL, function(x, y, i)
  if onFace(x, y) then return 0 end
  local a = math.atan(y - 52, x - 28)
  local v = (a / math.pi * 13) % 1
  if v < .22 then return -1 end
  if v > .5 and v < .7 and i >= 3 then return 1 end
end)
-- growth lines (concentric) on the upper shell
O.tex(c, dI, dT, SHEL, function(x, y, i)
  if onFace(x, y) then return 0 end
  local r = math.sqrt((x - 28)^2 + (y - 52)^2)
  if math.abs(r - 20.5) < .5 and i >= 2 then return -1 end
end)

-- sand mound pulled up to its chin
local sand = c:ellipse(32, 58, 30, 8)
sand:add(c:ellipse(27, 53, 18, 5))
sand:cut(c:rect(0, 59, 63, 63))
local sI, sT = O.shade(c, sand, SAND, { R = 3, amb = .3, wrap = .45, cuts = { .25, .45, .65, .85 }, sep = SAND[1], rim = true })
O.tex(c, sI, sT, SAND, function(x, y, i)
  if x >= 47 then return 0 end
  if (y == 55 or y == 57) and (x + y) % 7 < 4 and x > 6 then return -1 end      -- wind ripples
  local h = H(x, y, 9) if h > .9 then return -1 end if h < .07 then return 1 end -- grains
end)
-- wet sand where the wave lands (darker, smooth)
sand:each(function(x, y) if x >= 47 + (y % 2) then local q = y * c.w + x if c.own[q] == sT then
  c.pix[q] = WET[math.max(1, math.min(3, (sI[K(x, y)] or 3) - 1))] end end end)
for x = 45, 60 do local y = 51 + ((x % 3 == 0) and 0 or 1) if c.own[y * c.w + x] then c.pix[y * c.w + x] = FOAM[3] end end
O.dots(c, { { 47, 53 }, { 50, 54 }, { 55, 53 } }, FOAM[2])

-- paws holding the sand blanket up
for _, px in ipairs({ 17, 36 }) do
  O.shade(c, c:ellipse(px, 49.5, 2, 1.5), SHEL, { R = 1, amb = .4, cuts = { .2, .38, .55, .71, .86 }, sep = SHEL[1] })
  O.dot(c, px, 50, SHEL[2])
end

-- quirk: pink starfish tucked into the sand
local STARP = { "..b..", "bbabb", ".bab.", ".d.d." }
local stc = { a = STAR[3], b = STAR[2], c = STAR[2], d = STAR[1] }
for j, row in ipairs(STARP) do for i = 1, 5 do local ch = row:sub(i, i)
  if ch ~= "." then O.dot(c, 6 + i, 52 + j, stc[ch]) end end end
O.dot(c, 8, 54, STAR[3])

-- face peeking over the sand blanket
c:eyeLocked(21, 38)
c:eyeLocked(31, 38)
c:cheek(18, 44) c:cheek(37, 44)
O.dots(c, { { 26, 44 }, { 27, 45 }, { 28, 45 }, { 29, 45 }, { 30, 44 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "ss-tide-tuck-yard", function(c)
  for _, p in ipairs({ { 33, 13 }, { 32, 18 }, { 35, 10 } }) do c:put(p[1], p[2], FOAM[2]) end
end)

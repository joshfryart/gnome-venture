-- Great White Plumelet (pl-owl-6), yard sprite 64x64. Opus second pass (c10/opus2), built on c10/haiku.
-- Wayfinder, rare. "The great white owl's finest feather, dipped in aurora light."
-- A long, soft white plume that rises from its quill, arches over and droops down at the tip like a fountain.
-- Cool lavender shading on the white, fluffy barb wisps along the edge, a pale shaft. The droop is dipped in
-- aurora: mint, then teal, then violet at the very tip. Face on the crown of the arch, eyes in lavender sockets
-- so the cream discs read on white. Rare: three sparkles.
-- Haiku pass fixed: the plume was a white dome on a stick (read as a jellyfish or a lamp) with low-contrast eyes.
-- quirk: one drop of aurora light dripping off the tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-owl-6-yard", 64)

local WHT  = { "#4a4868", "#76739a", "#a4a2c4", "#cbcbe0", "#e8e8f2", "#f8f6f4" }
local MINT = { "#24544a", "#2f7f68", "#46b08a", "#7fdcae", "#bdf2cf", "#e8fbe8" }
local TEAL = { "#2a4a7a", "#2f6d96", "#3f9cb8", "#62c8d0", "#a6e8e4", "#e0f8f4" }
local VIOL = { "#35295f", "#4e3c8c", "#6e58b8", "#9a82dc", "#c9b2f0", "#ece2fb" }
local QUIL = { "#7a7088", "#a8a0b4", "#d4cedc", "#f0ecf2" }

c:groundShadow(22, 60, 7, 1.5)
-- quill
local quill = O.tube({ { 20, 59 }, { 20, 56 }, { 19, 53 }, { 19, 50 } }, function(t) return 1.1 end)
O.shade(c, quill, QUIL, { R = 1, amb = .3, cuts = { .3, .55, .8 } })

local SH = { { 19, 52 }, { 12, 18 }, { 42, 2 }, { 50, 30 } }
local plume, pn, PT, PS = O.tube(SH, function(t)
  if t < .08 then return 1.5 + t * 30 end
  return 9.5 * math.sin(math.pi * (.05 + .9 * t)) ^ .55
end)
-- fluffy barb wisps along the outer edges
local wisp = HP.mask()
plume:edge():each(function(x, y)
  for _, d in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
    local nx, ny = x + d[1], y + d[2]
    if not plume:has(nx, ny) and H(nx, ny, 5) > .62 then wisp:set(nx, ny) end
  end
end)
plume:add(wisp)
local function tOf(x, y)
  if PT[K(x, y)] then return PT[K(x, y)] end
  for _, d in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
    local v = PT[K(x + d[1], y + d[2])] if v then return v end
  end
  return 0
end
local pb = {}
plume:each(function(x, y) if wisp:has(x, y) then pb[K(x, y)] = 1 end end)
local wI, wT = O.shade(c, plume, WHT, { R = 5, bias = pb, amb = .3, wrap = .5, rim = true, bounce = "#8a9ad0", bmax = 3 })
-- barbs: faint soft lines sweeping back from the shaft (kept off the face)
O.tex(c, wI, wT, WHT, function(x, y, i)
  local t = tOf(x, y)
  if t > .36 and t < .56 then return 0 end
  local sd = PS[K(x, y)] or 1
  if math.floor(t * 90 + math.abs(sd) * 7) % 4 == 0 and i >= 3 then return -1 end
end)
-- aurora dip on the drooping end: mint, teal, then violet at the tip
for k, i in pairs(wI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == wT then
    local t = tOf(x, y) + (H(x, y, 9) - .5) * .03
    local R = t > .93 and VIOL or (t > .86 and TEAL or (t > .76 and MINT or nil))
    if R then c.pix[p] = R[math.max(2, math.min(6, i))]:lower() end
  end
end
-- shaft
plume:each(function(x, y)
  local t, sd = PT[K(x, y)], math.abs(PS[K(x, y)] or 1)
  if t and sd < .1 and (t < .34 or (t > .58 and t < .74)) then O.mark(c, { { x, y } }, QUIL[3]) end
end)

-- face on the crown of the arch, eyes in lavender sockets
for _, ex in ipairs({ 22, 32 }) do
  local ring = c:ellipse(ex + 2, 16, 3.5, 3.5)
  ring:each(function(x, y) if plume:has(x, y) then O.mark(c, { { x, y } }, WHT[3]) end end)
  c:eyeLocked(ex, 14)
end
c:cheek(19, 21) c:cheek(37, 21)
O.dots(c, { { 27, 21 }, { 28, 22 }, { 29, 22 }, { 30, 21 } }, P.ink)
O.dots(c, { { 28, 23 }, { 29, 23 } }, "#c94f84")

-- quirk: a drop of aurora dripping off the tip
local drop = c:ellipse(51, 42, 1.5, 2)
drop:add(c:rect(51, 39, 51, 40))
O.shade(c, drop, VIOL, { R = 1, amb = .4, wrap = .5, nopop = true })
O.dot(c, 50, 41, VIOL[6])

O.shift(c, 1, -2)
O.done(c, "pl-owl-6-yard", function(c)
  c:sparkle(8, 8)
  c:sparkle(58, 12)
  c:sparkle(41, 48)
end)

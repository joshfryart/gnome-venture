-- Great White Plumelet (pl-owl-6), perch sprite 36x36. Opus richness pass (c10/opus3), built on c10/opus2, hand-built at this size.
-- Richness pass: soft barb lines, a pale shaft line, a ragged edge on the aurora dip with two light flecks.
-- The white plume arching over from its quill, fluffy wisps on the edge, the drooping tip dipped in aurora
-- (mint, teal, violet). Pill eyes in lavender sockets on the crown of the arch. One sparkle.
-- quirk: a violet drop of aurora dripping off the tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-owl-6-perch", 36)

local WHT  = { "#4a4868", "#76739a", "#a4a2c4", "#cbcbe0", "#e8e8f2", "#f8f6f4" }
local MINT = { "#24544a", "#2f7f68", "#46b08a", "#7fdcae", "#bdf2cf", "#e8fbe8" }
local TEAL = { "#2a4a7a", "#2f6d96", "#3f9cb8", "#62c8d0", "#a6e8e4", "#e0f8f4" }
local VIOL = { "#35295f", "#4e3c8c", "#6e58b8", "#9a82dc", "#c9b2f0", "#ece2fb" }
local QUIL = { "#7a7088", "#a8a0b4", "#d4cedc", "#f0ecf2" }

c:groundShadow(12, 33, 4, 1)
O.shade(c, c:rect(11, 29, 11, 33), QUIL, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
local SH = { { 11, 30 }, { 6, 10 }, { 24, 1 }, { 29, 17 } }
local plume, pn, PT, PS = O.tube(SH, function(t)
  if t < .08 then return 1 + t * 25 end
  return 6 * math.sin(math.pi * (.05 + .9 * t)) ^ .55
end)
local wisp = HP.mask()
plume:edge():each(function(x, y)
  for _, d in ipairs({ { -1, 0 }, { 0, -1 }, { 1, 0 } }) do
    local nx, ny = x + d[1], y + d[2]
    if not plume:has(nx, ny) and H(nx, ny, 5) > .78 then wisp:set(nx, ny) end
  end
end)
plume:add(wisp)
local wI, wT = O.shade(c, plume, WHT, { R = 3, amb = .3, wrap = .5, rim = true, bounce = "#8a9ad0", bmax = 3 })
for k, i in pairs(wI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  local t = PT[K(x, y)] or (x > 22 and y > 8 and .9 or 0)
  if c.own[p] == wT then
    local sd = math.abs(PS[K(x, y)] or 0)
    t = t + ((x + y) % 3 == 0 and .02 or 0)
    local R = t > .92 and VIOL or (t > .84 and TEAL or (t > .74 and MINT or nil))
    if R then c.pix[p] = R[math.max(2, math.min(6, i))]:lower()
    elseif PT[K(x, y)] and sd > .3 and math.floor(t * 50 + sd * 4) % 4 == 0 and i >= 3 and not (t > .3 and t < .6) then c.pix[p] = WHT[i - 1]:lower() end
  end
end
plume:each(function(x, y)
  local t, sd = PT[K(x, y)], math.abs(PS[K(x, y)] or 1)
  if t and sd < .12 and (t < .32 or (t > .6 and t < .74)) then O.mark(c, { { x, y } }, QUIL[3]) end
end)
for _, ex in ipairs({ 12, 18 }) do
  O.mark(c, { { ex - 1, 9 }, { ex - 1, 10 }, { ex - 1, 11 }, { ex + 2, 9 }, { ex + 2, 10 }, { ex + 2, 11 }, { ex, 12 }, { ex + 1, 12 } }, WHT[3])
  c:eyeSmall(ex, 9)
end
O.dot(c, 10, 13, "#f5809f") O.dot(c, 21, 13, "#f5809f")
O.dots(c, { { 15, 13 }, { 16, 14 }, { 17, 13 } }, P.ink)
local drop = c:ellipse(30, 25, 1, 1.5)
drop:add(c:rect(30, 22, 30, 23))
O.shade(c, drop, VIOL, { R = 1, amb = .4, wrap = .5, nopop = true })

O.shift(c, 1, -1)
O.done(c, "pl-owl-6-perch", function(c) c:sparkle(4, 3) end)

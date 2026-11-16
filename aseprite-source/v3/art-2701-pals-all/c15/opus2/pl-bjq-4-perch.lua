-- Gold Spike Tiara (pl-bjq-4), perch sprite 36x36. Opus second pass (c15/opus2), hand-built at this size.
-- A circlet of sea-glass bubbles (dim back row, bright front row) with four bevelled gold spikes standing out of
-- it; the big centre bubble holds 2x3 pill eyes and a smile.
-- quirk: one bubble has come loose and drifts up off the top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-4-perch", 36)

local GOLD = { "#6e3416", "#a85a1c", "#d98322", "#f5b82e", "#ffe38a", "#fff4c0" }
local BUB  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ae4e0", "#d0f6f0", "#f0fffa" }

c:groundShadow(18, 32, 11, 1)
local function bubble(x, y, r, dim)
  local I, T = O.shade(c, c:ellipse(x, y, r, r), BUB, { sphere = { x - r * .4, y - r * .5, r + 1.5 }, amb = dim and .12 or .3, wrap = .45, rim = not dim, sep = BUB[1] })
  if dim then O.tex(c, I, T, BUB, function() return -1 end) end
  O.mark(c, { { math.floor(x - r * .45), math.floor(y - r * .45) } }, BUB[6])
end
for _, x in ipairs({ 8, 12, 16, 20, 24, 28 }) do bubble(x, 19, 1.6, true) end
local spikes = { { 7, 11, 10 }, { 13, 4, 15 }, { 23, 4, 21 }, { 29, 11, 26 } }
for _, sp in ipairs(spikes) do
  local tx, ty, bx, by, w = sp[1], sp[2], sp[3], 21, 2.5
  local m = c:poly{ { bx - w, by }, { bx + w, by }, { tx + .5, ty } }
  local tok = { r = { name = "spike" } }
  m:each(function(x, y)
    local f = (y - ty) / (by - ty)
    local d = x + .5 - (tx + (bx - tx) * f)
    c:put(x, y, GOLD[d < -.6 and 5 or d < .4 and 4 or 3], tok)
  end)
  O.mark(c, { { tx, ty + 1 } }, GOLD[6])
end
for _, b in ipairs({ { 6, 22, 2.2 }, { 30, 22, 2.2 }, { 10, 25, 3 }, { 26, 25, 3 } }) do bubble(b[1], b[2], b[3]) end
bubble(18, 25, 6)
c:eyeSmall(15, 23)
c:eyeSmall(20, 23)
O.dot(c, 13, 27, P.petal.base) O.dot(c, 23, 27, P.petal.base)
O.mark(c, { { 17, 28 }, { 18, 28 } }, P.ink)
bubble(30, 5, 1.6)

O.done(c, "pl-bjq-4-perch")

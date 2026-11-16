-- Thawdrop Pip (pl-frt-3), perch sprite 36x36. Opus richness pass (c09/opus3), hand-built at this size.
-- Meltwater drop (6-tone glassy ramp, window highlight, caustic lower-right, frozen tip), 2x3 pill eyes.
-- quirk: mid-yawn. Opus2's tall slot read as "wow"; now a wide lopsided yawn with a tongue, a yawn tear by the
-- right eye and a small sleepy z. Fewer, bolder details than the yard (no bubbles, no snowdrop).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-3-perch", 36)
local WATER = { "#26346e", "#2a5a98", "#3184ae", "#55bec4", "#97e2d6", "#d8f8ee" }
local ICE = { "#6f9fd8", "#a9dcf2", "#e2f7fb" }
c:groundShadow(18, 31, 9, 1.5)
local cy, r, top = 21, 9, 5
local drop = HP.mask()
for y = top, cy + r do
  local w, cx
  if y <= cy then local s = (y - top) / (cy - top) w = r * math.sin(s * math.pi / 2) ^ 1.5 cx = 17.5 + 2.5 * (1 - s) ^ 2
  else w = math.sqrt(math.max(0, r * r - (y - cy) ^ 2)) + .3 cx = 17.5 end
  for x = math.floor(cx - w), math.ceil(cx + w) do if math.abs(x - cx) <= w then drop:set(x, y) end end
end
local I, T = O.shade(c, drop, WATER, { sphere = { 15, 17, 12 }, amb = .28, wrap = .6, rim = true, bounce = "#7a6cc4", bmax = 3 })
local inner = drop:copy():cut(drop:edge())
O.tex(c, I, T, WATER, function(x, y, i) if inner:edge():has(x, y) and (x - 18) + (y - 22) > 5 and y > 21 then return 3 end end)
-- window highlight
O.dots(c, { { 11, 18 }, { 11, 19 }, { 12, 16 }, { 13, 15 } }, WATER[6])
O.dot(c, 14, 16, WATER[5])
-- frozen tip
for _, p in ipairs({ { 20, 5 }, { 20, 6 }, { 19, 7 }, { 20, 7 } }) do if drop:has(p[1], p[2]) then O.dot(c, p[1], p[2], ICE[3]) end end
-- eyes, cheeks, yawn tear
c:eyeSmall(13, 18) c:eyeSmall(21, 18)
O.dot(c, 11, 22, P.petal.base) O.dot(c, 24, 22, P.petal.base)
O.dots(c, { { 24, 18 }, { 24, 19 } }, ICE[3]) O.dot(c, 24, 20, ICE[1])
-- wide lopsided yawn: arched high on the left, dropping to the right
local mouth = HP.mask()
local mt = { [15] = 23, [16] = 22, [17] = 22, [18] = 22, [19] = 23, [20] = 24 }
local mb = { [15] = 25, [16] = 26, [17] = 26, [18] = 26, [19] = 26, [20] = 25 }
for x = 15, 20 do for y = mt[x], mb[x] do mouth:set(x, y) end end
local mIn = mouth:copy():cut(mouth:edge())
O.flat(c, mIn, "#4a2240", "mouth")
O.dots(c, { { 17, 25 }, { 18, 25 } }, P.petal.base)
O.dot(c, 17, 23, "#2f1a3a")
mouth:edge():each(function(x, y) c:put(x, y, P.ink, { r = { name = "lip" } }) end)
-- sleepy bead off the tip
O.flat(c, c:rect(25, 8, 26, 9), WATER[4], "bead") O.dot(c, 25, 8, WATER[6]) O.dot(c, 26, 9, WATER[3])
O.done(c, "pl-frt-3-perch", function(c)
  -- small sleepy z (un-outlined)
  for _, p in ipairs({ { 28, 1 }, { 29, 1 }, { 30, 1 }, { 31, 1 }, { 32, 1 }, { 31, 2 }, { 30, 3 }, { 29, 4 }, { 28, 5 }, { 29, 5 }, { 30, 5 }, { 31, 5 }, { 32, 5 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#9ec4e8") end
  end
end)

-- Aurora Thread (pl-owl-3), perch sprite 36x36. Opus second pass (c10/opus2), hand-built at this size.
-- A ball of aurora yarn, strands wound two ways in green and violet with dark grooves, a loose curl of thread on
-- top, pill eyes on a smooth green patch.
-- quirk: its own thread knitted into a scarf round its middle, knotted on the right, one tail flicking out.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-owl-3-perch", 36)

local GRN = { "#1f4a44", "#2c7860", "#3fa878", "#72d08e", "#b2eca8", "#e4fbd2" }
local VIO = { "#2e2458", "#4a3a8a", "#6e56b8", "#9a80dc", "#c6aef2", "#ece0fc" }
local BNC = "#5a7ab0"

c:groundShadow(16, 31, 10, 1.5)
local cx, cy, r = 16, 19, 11
local ball = c:ellipse(cx, cy, r, r)
local bI, bT = O.shade(c, ball, GRN, { sphere = { 12, 14, 15 }, amb = .2, wrap = .45, rim = true, bounce = BNC, bmax = 2 })
for k, i in pairs(bI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == bT then
    local a = (x - cx) + (y - cy) * .55 < 3 and math.rad(-30) or math.rad(52)
    local s = (x - cx) * math.cos(a) + (y - cy) * math.sin(a)
    local band = math.floor(s / 2.6)
    local R = (band % 2 == 0) and GRN or VIO
    local f = s / 2.6 - band
    c.pix[p] = R[math.max(1, math.min(6, f < .35 and i - 2 or i))]:lower()
  end
end
local face = c:ellipse(15, 15, 5.5, 3.5)
face:each(function(x, y) c.pix[y * c.w + x] = GRN[math.max(3, math.min(6, (bI[K(x, y)] or 4)))]:lower() end)
local loop = O.tube({ { 18, 9 }, { 19, 3 }, { 25, 2 }, { 24, 6 } }, function(t) return .8 end)
O.shade(c, loop, VIO, { R = 1, amb = .45, wrap = .5, nopop = true, sep = VIO[1] })
c:eyeSmall(11, 13)
c:eyeSmall(17, 13)
O.dot(c, 9, 17, "#f5809f") O.dot(c, 21, 17, "#f5809f")
O.dots(c, { { 14, 17 }, { 15, 18 }, { 16, 17 } }, P.ink)

local band = HP.mask()
for x = cx - r - 1, cx + r + 1 do
  local u = (x - cx) / (r + 1)
  local yc = 21 + 2 * (1 - u * u)
  for y = math.floor(yc - 2), math.floor(yc + 1) do if ball:grow(1):has(x, y) then band:set(x, y) end end
end
local function scarfPaint(m, ofs)
  local I, T = O.shade(c, m, GRN, { R = 1, amb = .3, wrap = .5, bounce = BNC, bmax = 2, sep = GRN[1] })
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    if c.own[p] == T and math.floor((x + ofs) / 2) % 2 == 1 then c.pix[p] = VIO[i]:lower() end
  end
end
scarfPaint(band, 0)
scarfPaint(O.tube({ { 27, 23 }, { 28, 27 }, { 31, 28 }, { 33, 26 } }, function(t) return 1.3 end), 1)
O.shade(c, c:ellipse(27, 22, 1.5, 1.5), VIO, { R = 1, amb = .3, wrap = .5, sep = VIO[1] })

O.shift(c, -1, 0)
O.done(c, "pl-owl-3-perch")

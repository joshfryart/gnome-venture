-- broken-diver-s-creel (aB11_0, Opus single pass). A wicker creel: tapered basket of over-under willow weave with
-- twisted rim bindings, a domed lid with the fish slot, a leather latch tab on a brass peg, and a slim leather
-- shoulder strap arching over on brass rings. Material: vertical-cylinder light (6-tone straw) broken into woven
-- bumps (lit top, dark under-row, stake gaps), rope twist on the rims, AO under the lid and the rims.
-- broken: the lower-right corner is torn out (real gap) with snapped withies poking from the hole, and a loose
-- withy splinter flies off. quirk: a little orange starfish clings to the side.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.start("broken-diver-s-creel")
local SW, L, B = A.STRAW, A.LEATH, A.BRASS

-- strap (behind)
local stm, stn, STT, STS = G.tube({ { 15, 31 }, { 12, 6 }, { 52, 6 }, { 49, 31 } }, function() return 1.25 end)
local sidx = A.toneN(c, stm, stn, L)
-- strap edge stitch line (lighter dashes on the lit edge)
stm:each(function(x, y) local k = K(x, y)
  if STS[k] < -0.2 and STS[k] > -0.7 and floor(STT[k] * 60) % 3 ~= 0 then c:px(x, y, L[5]) end end)

-- basket body
local x0, x1 = 13, 51
local body = c:poly{ { 13, 30 }, { 52, 30 }, { 49, 53 }, { 16, 53 } }
body:cut(c:rect(13, 52, 16, 53)):cut(c:rect(49, 52, 52, 53))
local n = {}
body:each(function(x, y)
  local t = max(-.97, min(.97, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
  n[K(x, y)] = { t, 0.15, sqrt(1 - t * t) }
end)
local bias = {}
body:each(function(x, y) local k = K(x, y)
  local ly = y - 33
  if ly >= 0 and y <= 49 then
    local row = floor(ly / 3)
    local r = ly % 3
    local lx = (x + (row % 2) * 3) % 6
    local b = 0
    if lx == 5 then b = -2                      -- stake gap between bumps
    elseif r == 0 then b = (lx >= 1 and lx <= 2) and 1 or 0
    elseif r == 2 then b = -1 end
    bias[k] = b
  end
end)
-- AO under the lid
body:each(function(x, y) if y == 32 or y == 33 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end end)
local bidx = A.toneN(c, body, n, SW, { bias = bias, amb = 0.12, wrap = 0.35 })
-- rims: rolled bindings with a twist
local function rim(y, xa, xb)
  for x = xa, xb do
    local tw = (x + y) % 3
    local i = bidx[K(x, y)] or 3
    c:px(x, y, tw == 0 and SW[max(1, i - 2)] or SW[min(6, i + (tw == 1 and 1 or 0))])
    c:px(x, y + 1, tw == 2 and SW[max(1, i - 2)] or SW[max(1, i - 1)])
  end
end
rim(50, 16, 49)
-- lid: shallow dome
local lid = c:ellipse(32.5, 30, 20.5, 5):clip(c:rect(0, 0, 63, 32))
local ln = X.pillow(lid, 3, 0.7)
local lb = {}
lid:each(function(x, y) if (x + floor(y / 2) * 2) % 5 == 0 then lb[K(x, y)] = -1 end
  if y == 32 then lb[K(x, y)] = (lb[K(x, y)] or 0) - 1 end end)
local lidx = A.toneN(c, lid, ln, SW, { bias = lb, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- lid rim twist row
for x = 12, 53 do
  if lid:has(x, 31) then c:px(x, 31, (x % 3 == 0) and SW[2] or SW[5]) end
  if lid:has(x, 32) then c:px(x, 32, (x % 3 == 1) and SW[1] or SW[3]) end
end
-- fish slot in the lid
local slot = c:ellipse(40, 27.5, 3.5, 1)
slot:each(function(x, y) c:px(x, y, SW[1]) end)
c:px(38, 27, A.INK) c:px(39, 27, A.INK) c:px(40, 27, A.INK)
for x = 37, 43 do if lid:has(x, 26) and not slot:has(x, 26) then c:px(x, 26, SW[2]) end end
for x = 37, 43 do if not slot:has(x, 29) and lid:has(x, 29) then c:px(x, 29, SW[6]) end end
-- latch tab (leather) over the lid edge, on a brass peg
local tab = c:rrect(29, 28, 33, 36, 1)
local tidx = A.lit(c, tab, L, { R = 1.5 })
for y = 29, 35 do c:px(33, y, L[2]) end
A.map(c, 30, 36, { "abc", "bcd", ".d." }, { a = B[6], b = B[4], c = B[3], d = B[2] })
c:px(31, 33, L[1])
-- strap rings
for _, p in ipairs{ { 14, 31 }, { 48, 31 } } do
  A.map(c, p[1], p[2], { ".a.", "a.c", ".c." }, { a = B[5], c = B[2] })
end

-- broken: lower-right corner torn out (real gap) with snapped withies poking from it
local tear = c:poly{ { 43, 53 }, { 45, 45 }, { 48, 47 }, { 50, 42 }, { 53, 41 }, { 53, 54 } }
A.erase(c, tear)
-- dark inside showing through the ragged edge
for _, p in ipairs{ { 44, 49 }, { 44, 50 }, { 45, 47 }, { 46, 47 }, { 47, 48 }, { 48, 46 }, { 49, 44 }, { 50, 43 } } do
  if c:get(p[1], p[2]) then c:px(p[1], p[2], SW[1]) end end
-- snapped withy ends
c:px(46, 46, SW[6]) c:px(47, 45, SW[5])
c:px(51, 41, SW[6]) c:px(52, 40, SW[5])
c:px(44, 53, SW[5])
-- flying splinter + a chip of binding
A.map(c, 54, 49, { "a..", ".ab", "..b" }, { a = SW[6], b = SW[3] })
A.map(c, 50, 56, { "ab" }, { a = SW[5], b = SW[2] })

-- quirk: starfish clinging to the left side
A.map(c, 17, 38, {
  "..a..",
  "aabbc",
  ".bdc.",
  "b.c.d",
}, { a = "#ffb07a", b = "#f07a3a", c = "#c94a30", d = "#8a2c2c" })
A.save(c, "broken-diver-s-creel")

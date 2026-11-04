-- ico-arrow-right (final pass, Opus). A fletched archery arrow pointing right, drawn bold for a nav icon.
-- Structure: barbed blue-glass arrowhead, twine binding at the socket, slim ash shaft, two red feathers and a nock.
-- Material: glass head = two lit facets split by a bright ridge, bright rim on the lit edges, pale core, dark barbs;
-- wood = rounded shaft with grain flecks; twine = diagonal twist; feather = barbs swept back with one split vane.
-- AO where the binding meets head and shaft, contact shadow under the feathers.
-- quirk: a ladybug is hitching a ride on the shaft.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local GL, AS, TW, PL, BG = R.glass, R.ash, R.twine, R.plume, R.bug
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("ico-arrow-right")

-- feathers (behind the shaft)
local fTop = A.poly{ { 26, 31 }, { 19, 25 }, { 14, 22 }, { 8, 22 }, { 10, 31 } }
local fBot = A.poly{ { 26, 34 }, { 19, 40 }, { 14, 43 }, { 8, 43 }, { 10, 34 } }
local function feather(m, up)
  local idx = {}
  local d = X.dist(m)
  m:each(function(x, y)
    local k = K(x, y)
    local near if up then near = y >= 29 else near = y <= 36 end        -- close to the shaft: ambient shadow
    local i = up and 5 or 3
    if (d[k] or 0) < 0.6 then i = up and 6 or 4 end   -- lit outer vane edge
    if near then i = up and 3 or 2 end
    local bd = up and (x + y) or (x - y)
    if bd % 3 == 0 and (d[k] or 0) >= 0.6 and not near then i = i - 1 end
    idx[k] = i c:put(x, y, PL[i])
  end)
  -- a split in the vane
  for i = 0, 2 do local x, y = 15 + i, up and (23 + i) or (42 - i)
    if m:has(x, y) then c:put(x, y, PL[1]) end end
  return idx
end
local tIdx = feather(fTop, true)
local bIdx = feather(fBot, false)

-- shaft
local shaft, sn = X.cyl(8, 32.5, 45, 32.5, function() return 1.6 end)
local sb = {}
shaft:each(function(x, y) local h = X.hash(floor(x / 3), y, 5) if h < 0.25 and y == 32 then sb[K(x, y)] = -1 end end)
local sIdx = A.shadeN(c, shaft, sn, AS, { bias = sb, amb = 0.15, wrap = 0.35 })
for x = 12, 40, 7 do A.step(c, sIdx, AS, x, 31, 1) end
-- contact shadow from the feathers onto the shaft edge rows
for x = 10, 25 do A.step(c, sIdx, AS, x, 34, -1) end
-- nock: darker cap with a notch
for y = 31, 34 do c:put(7, y, AS[2]) c:put(8, y, AS[3]) end
c:put(7, 32, A.INK) c:put(7, 33, A.INK) c:put(8, 31, AS[5])

-- glass head
local head = A.poly{ { 58, 32.5 }, { 37, 14 }, { 43, 32.5 }, { 37, 51 } }
local hIdx = {}
local hd = X.dist(head)
head:each(function(x, y)
  local k = K(x, y)
  local up = y <= 32
  local r = abs(y - 32.5)                              -- distance from the ridge
  local i
  if up then i = (r < 4) and 5 or 4 else i = (r < 4) and 2 or 3 end
  if (hd[k] or 0) < 0.6 then i = up and 6 or 4 end     -- bright rim / cool bounce on the rim
  if x < 41 and not up then i = 2 end                  -- barb under the socket in shadow
  hIdx[k] = i c:put(x, y, GL[i])
end)
-- ridge: bright line, deep line just below it
for x = 45, 57 do c:put(x, 32, x < 54 and GL[6] or GL[5]) if head:has(x, 33) then c:put(x, 33, GL[1]) end end
-- pale core streak on the upper facet + spec
for x = 46, 51 do c:put(x, 29, GL[5]) end
for x = 47, 49 do c:put(x, 28, GL[5]) end
c:put(48, 29, A.CREAM) c:put(49, 29, A.CREAM)
-- dark barbs
c:put(38, 16, GL[2]) c:put(38, 49, GL[1]) c:put(39, 49, GL[1]) c:put(39, 48, GL[2])
-- twine binding over the socket
local bind = c:rect(39, 30, 45, 35)
bind:cut(c:rect(39, 30, 39, 30)):cut(c:rect(39, 35, 39, 35)):cut(c:rect(45, 30, 45, 30)):cut(c:rect(45, 35, 45, 35))
local bIdx2 = A.face(c, bind, TW, { R = 2.5, nfn = function(x, y, n) return n[1], n[2] + (y - 32.5) / 4, n[3] end })
bind:each(function(x, y) if (x - y) % 3 == 0 then A.step(c, bIdx2, TW, x, y, -2) end end)
-- AO where binding meets the head and the shaft
for y = 30, 35 do A.step(c, hIdx, GL, 46, y, -1) A.step(c, sIdx, AS, 38, y, -1) end

-- quirk: ladybug on the shaft
A.map(c, {
  "...ebbbe.",
  "..ebcbkbd",
  ".kbkbbbbd",
  "kkbbbkbdd",
  "kkdddddd.",
}, 25, 26, { b = BG[4], c = BG[6], d = BG[2], e = BG[3], k = A.INK })
c:put(26, 28, A.CREAM)                     -- glint on the head
c:put(30, 26, BG[2]) c:put(30, 27, BG[2])  -- wing seam

A.save(c, "ico-arrow-right")

-- elderberry (final pass, Opus single pass). One flat-topped umbel of glossy blue-black berries on fine red-purple
-- pedicels that radiate from a single hub, a slim green-to-red stalk, and one pair of serrated leaflets below.
-- Material: each berry is a 4-5 px glossy sphere (6-tone violet ramp, cream specular, dusty bloom pixel, cool
-- reflected light lower-right), berries kept 1 px apart so the ink reads them one by one; back berries a tone darker.
-- Stalk: per-pixel cylinder light with AO at the hub and a node knuckle; leaflets: midrib, veins and saw-tooth edge.
-- quirk: one late cream elderflower floret still blooming among the ripe berries.
local NAME = "elderberry"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB2r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)

local BER  = { "#170c26", "#2a1744", "#432663", "#5f3a86", "#8462ae", "#b6a0d8" }
local PED  = { "#4a1a32", "#7e2e48", "#b24e5e" }
local STEM = { "#2a3a2a", "#4a5a30", "#6e7a3a", "#94913e", "#b9a85a", "#d8c788" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SPEC, BLOOM, BOUNCE = "#fff4e4", "#9a8ab8", "#4a4a8a"
local tokP, tokB, tokS = { r = { name = "ped" } }, { r = { name = "berry" } }, { r = { name = "stem" } }

local HX, HY = 31, 33                                              -- umbel hub

-- leaflets (behind the stalk)
A.leaf(c, 31, 46, 22, 46, 13, 39, 3.6, LEAF, { vs = 3, fold = 0.5 })
A.leaf(c, 33, 49, 42, 50, 51, 44, 3.4, LEAF, { vs = 3, fold = 0.5 })

-- stalk
local sm, sn, sT = A.stem(c, { { HX, HY + 1 }, { HX + 0.5, 40 }, { 32.5, 48 }, { 33, 56 } },
  function(t) return 1.15 + 0.35 * t end, STEM, { tok = tokS })
for _, p in ipairs{ { 31, 47, STEM[2] }, { 32, 47, STEM[4] }, { 33, 47, STEM[3] }, { 34, 47, STEM[2] } } do c:put(p[1], p[2], p[3], tokS) end  -- node knuckle
c:put(32, 57, STEM[6], tokS) c:put(33, 57, STEM[5], tokS)          -- pale cut end

-- berry positions: hex grid inside a flat dome
local berries = {}
for row = 0, 5 do
  local y = 9 + row * 4.2
  local half = ({ 9, 14, 18, 20, 19, 13 })[row + 1]
  local off = (row % 2) * 2.5
  for x = HX - 22 + off, HX + 22, 5 do
    if abs(x - HX) <= half then
      local j = X.hash(floor(x), row, 5)
      berries[#berries + 1] = { x = floor(x + (j - 0.5) * 0.8 + .5), y = floor(y + (X.hash(row, floor(x), 9) - 0.5) * 1.2 + .5),
        big = j > 0.62, row = row }
    end
  end
end
-- pedicels: hub -> 6 rays -> berries
local rays = {}
for i = 0, 5 do local a = -pi + (i + 0.5) / 6 * pi
  rays[#rays + 1] = { x = HX + cos(a) * 9.5, y = HY - 4 + sin(a) * 6 } end
local function seg(x0, y0, x1, y1, col)
  local n = max(abs(x1 - x0), abs(y1 - y0)) * 2 + 1
  for i = 0, n do local t = i / n c:put(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), col, tokP) end
end
for _, r in ipairs(rays) do seg(HX, HY, r.x, r.y, PED[2]) end
for _, b in ipairs(berries) do
  local best, br = 1e9
  for _, r in ipairs(rays) do local q = (r.x - b.x)^2 + (r.y - b.y)^2 if q < best then best, br = q, r end end
  seg(br.x, br.y, b.x + 1, b.y + 2, (b.row >= 4) and PED[3] or PED[2])
end
c:put(HX, HY, PED[1], tokP) c:put(HX + 1, HY, PED[1], tokP) c:put(HX, HY + 1, STEM[1], tokS)   -- hub AO

-- berries
local B4 = { ".54.", "5S43", "4432", ".3b." }
local B5 = { ".554.", "5S543", "54432", "44321", ".32b." }
local quirkAt = 7
for i, b in ipairs(berries) do
  if i ~= quirkAt then
    local pat = b.big and B5 or B4
    local d = (b.row <= 1) and -1 or 0                              -- back rows a tone darker
    for yy, row in ipairs(pat) do for xx = 1, #row do local ch = row:sub(xx, xx)
      local x, y = b.x + xx - 1, b.y + yy - 1
      if ch == "S" then c:put(x, y, SPEC, tokB)
      elseif ch == "b" then c:put(x, y, BOUNCE, tokB)
      elseif ch ~= "." then c:put(x, y, BER[max(1, min(6, tonumber(ch) + d))], tokB) end
    end end
    if b.big then c:put(b.x + 3, b.y + 1, BLOOM, tokB) end           -- dusty bloom
  end
end
-- quirk: one late elderflower floret (5-petal cream star with a gold eye)
local q = berries[quirkAt]
A.map(c, { ".c..", "cgcc", ".cc.", ".c.." }, q.x, q.y, { c = "#fff4d6", g = "#f5b82e" }, tokB)
c:put(q.x + 2, q.y + 2, "#e2d6b8", tokB)
A.save(c, NAME)

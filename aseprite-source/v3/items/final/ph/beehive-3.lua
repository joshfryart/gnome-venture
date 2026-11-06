-- beehive-3 (final pass, Opus). Tier 3 straw skep: the beehive-2 coils grow a weathered thatched hackle (straw hood)
-- tied off with twine at the tip, on a plank stand.
-- Material: 6-tone lit coils with rope twist, cane bindings, AO seams; hackle in darker weathered straw with radial
-- strands, a ragged fringe and a contact shadow cast on the coils beneath; twine knot with twist; plank grain + end grain.
-- quirk: honey has dribbled out of the entrance and over the front of the plank, one glossy drop about to fall.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local norm = A.norm
local c = A.new("beehive-3")
local CX = 31.5
local W = A.WOOD
c:groundShadow(32, 56, 18, 2)
A.stand(c, 15, 48, 47, { th = 4, lh = 3, legs = { 18, 42 } })
local all, idx, info = A.skep(c, CX, 46, { { w = 13, h = 8 }, { w = 11, h = 8 }, { w = 9, h = 7 }, { w = 6.5, h = 7 } }, { crown = 3 })
for x = 15, 48 do if all:has(x, 46) then c:put(x, 47, W[3]) end end
A.bind(c, idx, info, CX, { -7, 6 }, A.STRAW, { "#3e2429", "#5c372e", "#83503a" })
local em = A.entrance(c, CX, 46, 3, 5)

-- hackle: thatched cone over the top coils
local TH = { "#4a2630", "#74432e", "#a06a34", "#c99040", "#e6b858", "#f8dc94" }
local tipY, botY = 13, 27
local hm, hn, ht = HP.mask(), {}, {}
for y = tipY, botY + 2 do
  local t = (y - tipY) / (botY - tipY)
  local hw = 1.2 + 10.6 * (t ^ 0.8)
  for x = floor(CX - hw - 1), floor(CX + hw + 1) do
    local dx = x - CX
    local fr = botY + ((x * 7) % 3 == 0 and 2 or ((x % 2 == 0) and 1 or 0))   -- ragged fringe
    if abs(dx) <= hw and y <= fr then
      hm:set(x, y)
      local sx = dx / (hw + 0.5)
      hn[K(x, y)] = { norm(sx * 0.95, -0.7 + 0.45 * t, sqrt(max(0.08, 1 - sx * sx * 0.9))) }
      ht[K(x, y)] = t
    end
  end
end
-- contact shadow of the hackle on the coils below it
hm:shift(1, 1):each(function(x, y) if all:has(x, y) and not hm:has(x, y) and idx[K(x, y)] then A.step(c, idx, A.STRAW, x, y, -2, 1) end end)
local bias = {}
hm:each(function(x, y) if y >= botY then bias[K(x, y)] = -1 end end)
local hidx = A.tone(c, hm, hn, TH, { bias = bias, amb = 0.08, wrap = 0.3 })
-- radial strands from the tip: dark lines on a fan, pale straw beside them
hm:each(function(x, y)
  local dx, dy = x - CX, y - tipY + 2
  if dy > 3 then
    local a = dx / dy
    local u = floor(a * 9 + 50 + (y % 5 == 0 and 0.5 or 0))
    if u % 3 == 0 then A.step(c, hidx, TH, x, y, -1, 1)
    elseif u % 3 == 1 and X.hash(x, y, 5) > 0.55 then A.step(c, hidx, TH, x, y, 1, 1, 5) end
  end
end)
-- fringe tips catch light
hm:each(function(x, y) if not hm:has(x, y + 1) and y >= botY and x < CX + 4 then A.step(c, hidx, TH, x, y, 1, 1, 5) end end)
-- twine knot at the tip + splayed tuft above
local RO = { "#51302b", "#8a5a3a", "#c49064", "#e6c08c" }
for y = 14, 16 do for x = 30, 33 do
  local u = (x + y) % 2
  c:put(x, y, x == 33 and RO[1] or (u == 0 and RO[2] or RO[3]))
end end
c:put(30, 14, RO[4])
for _, p in ipairs{ { 31, 13, 4 }, { 32, 13, 3 }, { 31, 12, 5 }, { 32, 12, 3 }, { 30, 11, 5 }, { 33, 11, 3 }, { 29, 10, 5 }, { 34, 10, 2 } } do
  c:put(p[1], p[2], TH[p[3]])
end
-- spec on the hackle's lit flank
c:put(26, 21, TH[6]) c:put(27, 20, TH[6])

-- quirk: honey dribble from the entrance, over the plank front, one drop hanging
local HO = A.HONEY
local dr = {
  { 30, 47, 4 }, { 31, 47, 5 }, { 32, 47, 5 }, { 33, 47, 4 }, { 34, 47, 3 },
  { 31, 48, 4 }, { 32, 48, 5 }, { 33, 48, 3 },
  { 32, 49, 4 }, { 33, 49, 3 },
  { 32, 50, 4 }, { 33, 50, 2 },
  { 32, 51, 3 }, { 33, 51, 2 },
  { 32, 52, 4 }, { 33, 52, 3 }, { 31, 52, 3 },
  { 31, 53, 3 }, { 32, 53, 5 }, { 33, 53, 3 }, { 34, 53, 2 },
  { 31, 54, 2 }, { 32, 54, 3 }, { 33, 54, 2 },
}
for _, p in ipairs(dr) do c:put(p[1], p[2], HO[p[3]]) end
c:put(31, 47, HO[6]) c:put(32, 53, HO[6])
A.save(c, "beehive-3")

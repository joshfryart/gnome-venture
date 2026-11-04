-- greenhouse-3 (aC10_2 Opus pass): tier 3. A grand bell-domed conservatory on a red brick plinth with a stone sill:
-- curved white ribs following the dome's meridians, a gilded eave ring, glazed double doors, a little glass cupola with a
-- red pyramid cap and gold ball finial. Inside: two lollipop lemon standards, tomato bushes and a brass lantern hung
-- from the dome. Glass: gradient + reflection streaks, bright rims, AO under bars; brick: mortar, bevel, pits.
-- quirk: a robin has claimed the top of the dome, right beside the cupola.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local c = D.new("greenhouse-3")
c:groundShadow(32, 54, 25, 2)

D.blocks(c, 10, 46, 54, 52, D.BRICK, { bh = 3, bw = { 4, 6 }, seed = 7, name = "brick" })
D.ledge(c, 9, 55, 44, D.STONE)

-- body: walls + dome
local CX, CY, RX, RY = 32, 33, 20.5, 14
local dome = HP.mask()
for y = floor(CY - RY), CY do for x = 11, 53 do
  if ((x - CX) / RX) ^ 2 + ((y - CY) / RY) ^ 2 <= 1 then dome:set(x, y) end end end
local body = HP.rect(12, 33, 52, 43):add(dome)
local gt = D.glass(c, body, { phase = 4, period = 13, base = 0.66 })

-- inside: lemon standards, bushes, lantern
local function standard(x, top)
  local tt = D.tok("trunk")
  for y = top + 4, 42 do c:put(x, y, D.WOOD[3], tt) c:put(x + 1, y, D.WOOD[2], tt) end
  local can = G.rell(x + 0.5, top + 2, 1, 0, 3.6, 3.2)
  local tok = D.vol(c, can, D.LEAF, 2.4, { name = "canopy", amb = 0.12, wrap = 0.35 })
  for _, p in ipairs{ { -2, 0 }, { 1, 2 }, { 2, -1 } } do
    c:put(x + p[1], top + 2 + p[2], D.GOLD[5], tok) c:put(x + p[1] + 1, top + 2 + p[2], D.GOLD[3], tok)
  end
  -- pot
  local pt = D.tok("pot")
  for y = 40, 43 do for xx = x - 2, x + 3 do
    if not (y == 43 and (xx == x - 2 or xx == x + 3)) then
      c:put(xx, y, D.BRICK[(y == 40) and 5 or (xx >= x + 2 and 3 or 4)], pt) end end end
end
D.bush(c, 13, 27, 43, 6, nil, { fruit = D.RED, seed = 11, fdens = 0.07 })
D.bush(c, 37, 51, 43, 6, nil, { fruit = D.RED, seed = 13, fdens = 0.07 })
standard(17, 27) standard(46, 27)
-- lantern on a chain
local lt = D.tok("lamp")
for y = 21, 24 do c:put(32, y, (y % 2 == 0) and D.IRON[4] or D.IRON[5], lt) end
for y = 25, 29 do for x = 31, 33 do
  local hx = D.GOLD[4]
  if y == 25 or y == 29 then hx = (x == 33) and D.GOLD[2] or D.GOLD[3]
  elseif x == 31 then hx = D.GOLD[6] elseif x == 33 then hx = D.GOLD[3] else hx = D.GOLD[5] end
  c:put(x, y, hx, lt)
end end
c:put(32, 30, D.GOLD[2], lt)

-- frames: dome ribs (meridians) and wall mullions
local ft = D.tok("frame", true)
for _, u in ipairs{ -0.68, -0.34, 0.34, 0.68 } do
  local pts = {}
  for y = CY, CY - RY + 1, -1 do
    local w = sqrt(max(0, 1 - ((CY - y) / RY) ^ 2))
    pts[#pts + 1] = { CX + u * RX * w, y }
  end
  local m = HP.line(pts, 1)
  m:each(function(x, y) if dome:has(x, y) then c:put(x, y, u < 0 and D.FR[5] or D.FR[4], ft) end end)
  local xw = floor(CX + u * RX + 0.5)
  D.vbar(c, xw, 34, 43, 1, ft)
end
for y = CY - RY, CY do c:put(CX, y, D.FR[5], ft) end
-- dome ring
do local y = 25 local w = RX * sqrt(1 - ((CY - y) / RY) ^ 2)
  for x = floor(CX - w + 1), floor(CX + w) do if dome:has(x, y) then c:put(x, y, D.FR[4], ft) end end end
-- dome edge frame (lit left, shade right)
dome:edge():each(function(x, y) if y < CY then c:put(x, y, x < CX and D.FR[5] or D.FR[3], ft) end end)
-- corner posts and doors
D.vbar(c, 12, 33, 43, 2, ft) D.vbar(c, 51, 33, 43, 2, ft)
D.vbar(c, 27, 35, 43, 2, ft) D.vbar(c, 36, 35, 43, 2, ft) D.vbar(c, 32, 36, 43, 1, ft)
D.hbar(c, 29, 35, 35, 1, ft) D.hbar(c, 29, 35, 39, 1, ft)
c:put(31, 40, D.GOLD[5], ft) c:put(33, 40, D.GOLD[5], ft)
D.rims(c, gt, D.GL)
-- gilded eave ring
local gk = D.tok("gilt", true)
for x = 11, 53 do c:put(x, 32, D.GOLD[5], gk) c:put(x, 33, D.GOLD[3], gk) end
for x = 13, 51, 4 do c:put(x, 33, D.GOLD[2], gk) end
c:put(11, 32, D.GOLD[6], gk)

-- cupola
local cg = D.glass(c, HP.rect(29, 14, 35, 18), { phase = 1, period = 5, base = 0.8 })
local ck = D.tok("cupola", true)
D.vbar(c, 28, 14, 19, 1, ck) D.vbar(c, 36, 14, 19, 1, ck) D.vbar(c, 32, 14, 18, 1, ck)
for x = 27, 37 do c:put(x, 19, D.FR[5], ck) c:put(x, 20, D.FR[3], ck) end
D.rims(c, cg, D.GL)
local cap = HP.poly{ { 27, 13 }, { 37, 13 }, { 32, 8 } }
local capt = D.vol(c, cap, D.RED, 2, { name = "cap", cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
for x = 27, 37 do c:put(x, 13, D.RED[2], capt) end
c:put(32, 7, D.GOLD[4], ck) c:put(32, 6, D.GOLD[5], ck) c:put(33, 6, D.GOLD[3], ck) c:put(32, 5, D.GOLD[6], ck)

-- quirk: robin on the dome
local robin = {
  "..bbO..",
  "ybKbbO.",
  ".RRbbbb",
  ".RRRbbO",
  "..RRb..",
  "..k.k..",
}
local RC = { b = D.WOOD[4], K = D.INK, O = D.WOOD[3], y = D.GOLD[4], R = D.RED[4], k = D.IRON[3] }
local rt = D.tok("robin")
for yy, row in ipairs(robin) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if RC[ch] then c:put(38 + xx, 14 + yy, RC[ch], rt) end end end
c:put(42, 15, D.WOOD[5], rt)
D.save(c, "greenhouse-3")

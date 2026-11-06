-- resid.lua: evening village street of n cottages (4|6|8). Run: AppRun -b --script-param n=6 --script resid.lua
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local N = tonumber(app.params.n or "6")
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "resid-" .. N }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local GX = dofile(SRC .. "/v3/gather/gx.lua")
local floor, max, min, sin, abs, sqrt = math.floor, math.max, math.min, math.sin, math.abs, math.sqrt
local hash = S.hash
local INK = "#2b1c26"
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON, SBLUE, DIRT =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.IRON, S.SBLUE, S.DIRT
local COB = {"#3a2e40","#5a4a56","#7c6a6c","#9a8884","#b8a49a","#d0bcae"}
local function P(x, y, col) c:put(x, y, col) end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do c:put(x, y, col) end end end
local rect = S.rect

---------------------------------------------------------------- sky
c:stripes(0, 150, {"#2a2250","#3c3170","#58407e","#7e4c86","#a85c80","#cc7078","#e68c6c","#f4aa6c","#f8c884"}, {14,14,14,12,12,10,9,8,8})
for i = 1, 40 do   -- dither between bands
  local y = floor(hash(i, 1, 5) * 100)
end
for x = 0, 479 do for y = 0, 150 do   -- dithered band edges
  local cur = c:get(x, y)
  if cur and hash(x, y, 71) > .93 and y > 4 then local up = c:get(x, y - 2) if up then c:put(x, y, up) end end
end end
for i = 1, 46 do local x, y = floor(hash(i, 2, 9) * 470) + 4, floor(hash(i, 3, 9) * 70) + 3
  P(x, y, "#f4e6d0"); if i % 7 == 0 then P(x - 1, y, "#cdb8c8"); P(x + 1, y, "#cdb8c8"); P(x, y - 1, "#cdb8c8"); P(x, y + 1, "#cdb8c8") end end
-- moon
do local m = c:ellipse(392, 38, 9, 9); local cut = c:ellipse(397, 35, 8, 8); m:cut(cut)
  c:rim(m, "#8a6a8e"); c:fillMask(m, "#fbe9b8")
  m:each(function(x, y) if x < 388 and y < 40 then P(x, y, "#fffbe4") end end) end
c:cloud(60, 62, 56, "#e89a92", "#b8687c"); c:cloud(300, 78, 62, "#f0a890", "#c0707c"); c:cloud(160, 100, 40, "#f4b48c", "#c8788a")

---------------------------------------------------------------- hills, trees line, ground
local function f1(x) return 112 + 10 * sin(x / 60) + 5 * sin(x / 17 + 1) end
c:terrain(f1, "#5a4a7c", 200)
for x = 0, 479 do local y0 = floor(f1(x) + .5); P(x, y0, "#7a6296"); if x % 2 == 0 then P(x, y0 + 1, "#6a5688") end end
local function f2(x) return 134 + 5 * sin(x / 33 + 2) + 3 * sin(x / 11) end
c:terrain(f2, GREEN[2], 269)
for cx = 4, 479, 10 do   -- distant bushes on the near ridge
  local y0 = floor(f2(cx)) + 1
  local m = c:ellipse(cx, y0, 5 + floor(hash(cx, 1, 3) * 3), 3 + floor(hash(cx, 2, 3) * 2)); c:fillMask(m, GREEN[2])
  m:each(function(x, y) if y < y0 - 1 and x < cx then P(x, y, GREEN[3]) end end)
end
for x = 0, 479 do for y = floor(f2(x)) + 4, 269 do
  local t = (y - 134) / 136
  local v = .78 - .5 * t + (GX.vn(x, y, 7, 11) - .5) * .3
  local i = v > .8 and 5 or v > .6 and 4 or v > .4 and 3 or 2
  c:put(x, y, GREEN[i])
end end
for x = 0, 479 do P(x, floor(f2(x)) + 3, GREEN[4]) end
for x = 0, 479 do for y = 140, 269 do   -- grass flecks
  local h = hash(x, y, 4)
  if h > .975 then P(x, y, GREEN[5]) elseif h < .02 then P(x, y, GREEN[1]) end
end end

---------------------------------------------------------------- cobbled paths
local function cobble(m, seed)
  c:rim(m, COB[2])
  m:each(function(x, y)
    local row = y // 4
    local px = (x + (row % 2) * 4 + hash(row, 0, seed) * 7) % 8
    local py = y % 4
    local col = COB[4]
    local hv = hash(floor((x + (row % 2) * 4) / 8), row, seed)
    if hv > .7 then col = COB[5] elseif hv < .25 then col = COB[3] end
    if py == 3 or floor(px) == 7 then col = COB[2]
    elseif py == 0 and floor(px) < 6 then col = COB[6] end
    c:put(x, y, col)
  end)
end
local function streetY(x) return 161 + 3 * sin(x / 45) end
local function laneY(x) return 253 + 2 * sin(x / 38 + 1) end
local street, lane = HP.mask(), HP.mask()
for x = 84, 479 do
  local hh = 8; if x < 100 then hh = 8 - (100 - x) // 4 end
  for y = floor(streetY(x) - hh), floor(streetY(x) + hh) do street:set(x, y) end
end
for x = 118, 479 do
  local hh = 9; if x < 134 then hh = 9 - (134 - x) // 3 end
  for y = floor(laneY(x) - hh), floor(laneY(x) + hh) do lane:set(x, y) end
end
cobble(street, 3); cobble(lane, 8)

---------------------------------------------------------------- helpers
local function glowPool(cx, cy, rx, ry)   -- warm pool of light on the ground, stepped
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    local dd = sqrt(((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2)
    local cur = c:get(x, y)
    if dd < 1 and cur then
      local a = dd < .5 and .5 or .28
      c:put(x, y, GX.mix(cur, "#fcd870", a))
    end
  end end
end
local function blobShade(m, ramp, cx, cy, r, seed)
  c:rim(m, INK)
  m:each(function(x, y)
    local v = .6 - ((x - cx) + (y - cy)) / (2.4 * r) + (GX.vn(x, y, 3, seed) - .5) * .5
    c:put(x, y, ramp[v > .82 and 6 or v > .66 and 5 or v > .48 and 4 or v > .3 and 3 or 2])
  end)
end
local function bush(cx, cy, r, seed, ramp)
  ramp = ramp or GREEN
  local m = HP.mask()
  GX.disc(m, cx, cy, r, floor(r * .8))
  GX.disc(m, cx - floor(r * .7), cy + 1, floor(r * .6), floor(r * .55))
  GX.disc(m, cx + floor(r * .7), cy + 1, floor(r * .6), floor(r * .55))
  m = GX.rough(m, seed, 1)
  blobShade(m, ramp, cx, cy, r, seed)
end
local function tree(cx, by, h, seed)
  local m = rect(cx - 2, by - h, cx + 2, by)
  c:rim(m, INK); S.planks(m, TIMB, {w = 3, vert = true, base = 3, seed = seed})
  local cm = HP.mask()
  local cy = by - h - 8
  GX.disc(cm, cx, cy, 15, 13); GX.disc(cm, cx - 11, cy + 6, 9, 7); GX.disc(cm, cx + 11, cy + 6, 9, 7); GX.disc(cm, cx, cy - 9, 9, 7)
  cm = GX.rough(cm, seed, 1)
  blobShade(cm, LEAF, cx - 2, cy - 2, 15, seed)
  for i = 1, 6 do local fx, fy = cx - 12 + floor(hash(i, seed, 3) * 24), cy - 8 + floor(hash(i, seed, 4) * 20)
    if cm:has(fx, fy) then P(fx, fy, "#f4a8b8"); P(fx + 1, fy, "#fac4d4") end end   -- blossom
end
local function fence(x0, x1, y, gx0, gx1)   -- picket fence, gap for gate
  for x = x0, x1, 5 do
    if not (gx0 and x + 2 >= gx0 and x <= gx1) then
      R(x - 1, y - 5, x + 3, y, INK)
      P(x + 1, y - 7, INK); R(x, y - 6, x + 2, y - 6, INK); P(x + 1, y - 6, INK)
      R(x, y - 5, x + 2, y - 1, CREAM[5]); P(x + 1, y - 6, CREAM[6]); R(x + 2, y - 5, x + 2, y - 1, CREAM[3]); P(x, y - 5, CREAM[6])
    end
  end
  for xx = x0, x1 do
    if not (gx0 and xx >= gx0 and xx <= gx1) then
      P(xx, y - 4, CREAM[4]); P(xx, y - 3, INK); P(xx, y - 2, CREAM[3]); P(xx, y - 1, INK)
    end
  end
  P(x0 - 1, y - 4, INK)
end
local function lamp(x, y, lit)   -- base at y
  R(x - 1, y - 20, x, y, INK); R(x, y - 19, x, y - 1, IRON[4]); R(x - 1, y - 19, x - 1, y - 1, IRON[5])
  R(x - 3, y - 1, x + 2, y, INK); R(x - 2, y - 1, x + 1, y - 1, IRON[3])
  R(x - 4, y - 27, x + 3, y - 19, INK)
  R(x - 3, y - 26, x + 2, y - 20, lit and GOLD[5] or SBLUE[3])
  R(x - 3, y - 26, x - 2, y - 24, lit and GOLD[6] or SBLUE[4]); R(x + 1, y - 22, x + 2, y - 20, lit and GOLD[4] or SBLUE[2])
  R(x - 5, y - 29, x + 4, y - 28, INK); P(x - 1, y - 30, INK); P(x, y - 30, INK); R(x - 4, y - 28, x + 3, y - 28, IRON[3])
end
local function flowers(x0, x1, y, seed, cols)
  for x = x0, x1 do
    local h = hash(x, y, seed)
    if h > .35 then
      local hgt = 2 + floor(hash(x, 0, seed) * 3)
      P(x, y, GREEN[2]); for k = 1, hgt do P(x, y - k, GREEN[3]) end
      local col = cols[1 + floor(hash(x, 5, seed) * #cols)]
      P(x, y - hgt - 1, col)
      if x % 3 == 0 then P(x, y - hgt - 2, col); end
    end
  end
end
local function heart(cx, cy)
  local rows = {"..XX...XX..", ".XXXX.XXXX.", "XXXXXXXXXXX", "XXXXXXXXXXX", ".XXXXXXXXX.", "..XXXXXXX..", "...XXXXX...", "....XXX....", ".....X....."}
  local m = HP.mask()
  for r, row in ipairs(rows) do for i = 1, #row do if row:sub(i, i) == "X" then m:set(cx - 5 + i - 1, cy + r - 1) end end end
  c:rim(m, "#a8607c")
  m:each(function(x, y) P(x, y, (x - cx < -1 and y - cy < 3) and "#fff0ee" or (y - cy > 5 or x - cx > 2) and "#f0a4bc" or "#f8c4d0") end)
end
local function puff(cx, cy, r)
  local m = HP.mask(); GX.disc(m, cx, cy, r, r)
  c:rim(m, "#8e7488"); m:each(function(x, y) P(x, y, (x < cx and y < cy) and "#e8dce0" or "#c4b2c0") end)
end

---------------------------------------------------------------- house
local WALLS = {CREAM, ROSE, SBLUE, TEAL, PINK, CREAM, ROSE, TEAL}
local ROOFS = {BARN, SBLUE, DIRT, VIOLET, TEAL, GREEN, VIOLET, BARN}
local DOORS = {OAK, TEAL, BARN, OAK, VIOLET, SBLUE, OAK, BARN}
local SZ = ({[4] = {70, 34, 28}, [6] = {62, 30, 25}, [8] = {56, 28, 22}})[N]
local W, WH, RH = SZ[1], SZ[2], SZ[3]
local houseDoors = {}
local function house(idx, cx, by, heartSmoke, chimSide)
  local wl, rf, dr = WALLS[idx], ROOFS[idx], DOORS[idx]
  local seed = idx * 7 + N
  local x0, x1 = cx - W // 2, cx - W // 2 + W - 1
  local wt = by - WH + 1
  local ex = 6
  local function roofY(x) local k = 1 - abs(x - cx) / (W / 2 + ex); return wt - 1 - floor(RH * max(0, k) + .5) end
  -- soft shadow on grass
  for x = x0 - 2, x1 + 6 do for y = by + 1, by + 2 do local cur = c:get(x, y); if cur and cur ~= INK and (x + y) % 2 == 0 then P(x, y, GX.mix(cur, "#1c3434", .5)) end end end
  -- chimney (behind roof)
  local chx = cx + chimSide * floor(W * .27)
  local cyb = roofY(chx) + 3
  local chm = rect(chx - 3, cyb - 13, chx + 3, cyb)
  c:rim(chm, INK); S.tex(chm, function(x, y)
    local row = (y - (cyb - 13)) // 3
    local px = (x - chx + 3 + (row % 2) * 2) % 4
    if y == cyb - 13 then return BARN[5] end
    if px == 3 then return BARN[2] end
    if x >= chx + 2 then return BARN[3] end
    return BARN[4]
  end)
  R(chx - 4, cyb - 14, chx + 4, cyb - 13, INK); R(chx - 3, cyb - 13, chx + 3, cyb - 13, STONE[4]); R(chx - 3, cyb - 14, chx + 3, cyb - 14, STONE[5])
  R(chx - 2, cyb - 14, chx + 2, cyb - 14, STONE[1])
  if heartSmoke then
    puff(chx, cyb - 20, 3); puff(chx + 3, cyb - 27, 2); heart(chx + 2, cyb - 42)
  elseif idx % 3 == 1 then puff(chx, cyb - 20, 3); puff(chx + 2, cyb - 27, 2) end
  -- wall
  local wm = rect(x0, wt, x1, by)
  c:rim(wm, INK)
  S.tex(wm, function(x, y)
    local lit = x - x0 < 2
    local sh = (x1 - x < 3) or (by - y < 2)
    local t = 4
    if hash(x // 2, y // 2, seed) > .88 then t = 3 end
    if lit then t = 5 elseif sh then t = 3 end
    if x1 - x < 1 then t = 2 end
    if y == wt then t = t - 1 end
    return wl[max(1, min(6, t))]
  end)
  R(x0, by - 3, x1, by, STONE[4]); R(x0, by - 3, x1, by - 3, STONE[5]); R(x0, by - 1, x1, by, STONE[3])   -- stone footing
  for x = x0 + 3, x1, 6 do P(x, by - 2, STONE[2]) end
  for x = x0 + 1, x1 - 1, 7 do P(x, by - 1, STONE[2]) end
  -- timber beam under the eave
  R(x0, wt + 1, x1, wt + 2, TIMB[3]); R(x0, wt + 1, x1, wt + 1, TIMB[4])
  -- roof
  local rm = HP.mask()
  for x = x0 - ex, x1 + ex do for y = roofY(x), wt do rm:set(x, y) end end
  R(x0 - ex, wt + 1, x1 + ex, wt + 1, INK)
  c:rim(rm, INK)
  rm:each(function(x, y)
    local course = (y - roofY(cx)) // 4
    local sub = (y - roofY(cx)) % 4
    local off = (course % 2) * 3
    local sx = (x + off) % 6
    local t = 4
    if x < cx then t = 5 elseif x > cx + 4 then t = 3 end
    if sub == 3 then t = t - 1 elseif sub == 0 and sx < 4 then t = min(6, t + 1) end
    if sx == 5 and sub < 3 then t = t - 1 end
    if y >= wt - 1 then t = 2 end
    c:put(x, y, rf[max(1, min(6, t))])
  end)
  -- ridge
  local ry = roofY(cx)
  R(cx - 1, ry, cx + 1, ry, rf[6])
  -- attic window
  local lit = hash(idx, N, 5) > .4
  local ay = wt - floor(RH * .5)
  local am = rect(cx - 2, ay - 2, cx + 2, ay + 2)
  c:rim(am, INK); c:fillMask(am, lit and GOLD[5] or SBLUE[2]); P(cx, ay, lit and GOLD[6] or SBLUE[4])
  R(cx - 3, ay + 3, cx + 3, ay + 3, INK); R(cx - 2, ay + 3, cx + 2, ay + 3, CREAM[4])
  -- door
  local dm = c:rrect(cx - 4, by - 14, cx + 4, by, 3):clip(rect(cx - 4, by - 14, cx + 4, by - 3))
  dm:add(rect(cx - 4, by - 11, cx + 4, by - 3))
  c:rim(dm, INK)
  S.planks(dm, dr, {w = 3, vert = true, base = 4, seed = seed})
  P(cx + 2, by - 7, GOLD[5]); P(cx + 2, by - 6, GOLD[3])
  R(cx - 5, by - 3, cx + 5, by - 2, STONE[5]); R(cx - 5, by - 2, cx + 5, by - 2, STONE[3]); 
  local doorLit = hash(idx, N, 9) > .55
  if doorLit then R(cx - 1, by - 12, cx, by - 11, GOLD[5]) end
  -- windows
  local litCount = 0
  for k, sx in ipairs{-1, 1} do
    local wx = cx + sx * floor(W * .34)
    local isLit = hash(idx * 3 + k, N, 2) > .45
    if k == 2 and litCount == 0 and not lit and not doorLit then isLit = true end
    if isLit then litCount = litCount + 1 end
    local wy = wt + 8
    local gm = rect(wx - 4, wy, wx + 4, wy + 9)
    -- shutters
    R(wx - 8, wy, wx - 6, wy + 9, INK); R(wx + 6, wy, wx + 8, wy + 9, INK)
    R(wx - 7, wy + 1, wx - 6, wy + 8, rf[4]); R(wx + 6, wy + 1, wx + 7, wy + 8, rf[3])
    c:rim(gm, INK)
    R(wx - 4, wy, wx + 4, wy + 9, CREAM[4])
    for yy = wy + 1, wy + 8 do for xx = wx - 3, wx + 3 do
      local col
      if isLit then col = (yy - wy > 5) and GOLD[4] or GOLD[5]; if xx == wx - 3 and yy - wy < 4 then col = GOLD[6] end
      else col = (xx + yy) % 5 == 0 and SBLUE[4] or SBLUE[2]; if xx == wx - 3 and yy == wy + 1 then col = SBLUE[5] end end
      P(xx, yy, col)
    end end
    R(wx, wy + 1, wx, wy + 8, CREAM[3]); R(wx - 3, wy + 4, wx + 3, wy + 4, CREAM[3])
    R(wx - 5, wy + 10, wx + 5, wy + 11, INK); R(wx - 4, wy + 10, wx + 4, wy + 10, TIMB[4]); R(wx - 4, wy + 11, wx + 4, wy + 11, TIMB[2])
    for xx = wx - 4, wx + 4, 2 do P(xx, wy + 9, (hash(xx, wy, seed) > .5) and "#e86c8c" or "#f4cc4a") end   -- flower box blooms
    if isLit then houseDoors[#houseDoors + 1] = {wx, by + 3} end
  end
  if doorLit or lit then houseDoors[#houseDoors + 1] = {cx, by + 4} end
  -- vine / ivy quirk-free details: lantern by door
  P(cx + 7, by - 9, IRON[3]); P(cx + 7, by - 8, lit and GOLD[5] or GOLD[3])
  return x0, x1
end

---------------------------------------------------------------- layout
local back, front, trees, lamps
if N == 4 then
  back = {{180}, {340}}; front = {{110}, {270}}
  trees = {{255, 150, 20}, {380, 238, 18}, {450, 230, 22}}
  lamps = {{262, 152}, {188, 244}, {392, 250}}
elseif N == 6 then
  back = {{140}, {244}, {348}}; front = {{120}, {224}, {328}}
  trees = {{400, 232, 18}, {452, 236, 22}, {394, 150, 14}}
  lamps = {{192, 152}, {296, 152}, {172, 244}, {380, 250}}
else
  back = {{128}, {206}, {284}, {362}}; front = {{124}, {202}, {280}, {358}}
  trees = {{404, 232, 18}, {452, 236, 20}}
  lamps = {{167, 152}, {245, 152}, {323, 152}, {163, 244}, {319, 244}}
end
local BY_B, BY_F = 148, 236
local order = {1, 5, 2, 4, 3, 7, 6, 8}
local slots = {}
for i, s in ipairs(back) do slots[#slots + 1] = {s[1], BY_B, i} end
for i, s in ipairs(front) do slots[#slots + 1] = {s[1], BY_F, i} end
-- door stubs (cobbled) and light pools first
for i, s in ipairs(slots) do
  local stub = (s[2] == BY_B) and rect(s[1] - 4, s[2] + 1, s[1] + 4, floor(streetY(s[1])) - 6) or rect(s[1] - 4, s[2] + 1, s[1] + 4, floor(laneY(s[1])) - 8)
  cobble(stub, 20 + i)
end
-- build everything: trees behind back row first
for _, t in ipairs(trees) do if t[2] < 200 then tree(t[1], t[2], t[3], t[1]) end end
local heartIdx = (N == 4) and 2 or (N == 6) and 2 or 3
for i, s in ipairs(slots) do
  if s[2] == BY_B then
    local x0, x1 = house(order[i], s[1], s[2], i == heartIdx, (i % 2 == 0) and 1 or -1)
    fence(x0 - 6, x1 + 6, s[2] + 5, s[1] - 7, s[1] + 7)
    flowers(x0 - 4, s[1] - 9, s[2] + 4, 20 + i, {"#e86c8c", "#f4cc4a", "#f8e8d0"})
    flowers(s[1] + 9, x1 + 4, s[2] + 4, 40 + i, {"#a290d0", "#f4a8b8", "#f4cc4a"})
  end
end
for _, l in ipairs(lamps) do if l[2] < 200 then lamp(l[1], l[2], true) end end
for i, s in ipairs(slots) do
  if s[2] == BY_F then
    local x0, x1 = house(order[i], s[1], s[2], false, (i % 2 == 0) and -1 or 1)
    fence(x0 - 6, x1 + 6, s[2] + 5, s[1] - 7, s[1] + 7)
    flowers(x0 - 4, s[1] - 9, s[2] + 4, 60 + i, {"#f4a8b8", "#f4cc4a", "#a290d0"})
    flowers(s[1] + 9, x1 + 4, s[2] + 4, 80 + i, {"#e86c8c", "#f8e8d0", "#f4cc4a"})
  end
end
for _, t in ipairs(trees) do if t[2] >= 200 then tree(t[1], t[2], t[3], t[1] + 3) end end
for _, l in ipairs(lamps) do if l[2] >= 200 then lamp(l[1], l[2], true) end end
-- light pools from lamps and lit windows (drawn on the paths only)
for _, l in ipairs(lamps) do glowPool(l[1], l[2] + 3, 16, 5) end
-- bushes and flower beds in the open ground
local function bed(cx, cy, w)
  local m = c:ellipse(cx, cy, w, 3); c:rim(m, INK); c:fillMask(m, "#6a502e")
  m:each(function(x, y) if y < cy then P(x, y, "#8a6a34") end end)
  flowers(cx - w + 1, cx + w - 1, cy, cx, {"#e86c8c", "#f4cc4a", "#f8e8d0", "#a290d0"})
end
if N == 4 then bed(300, 214, 14); bed(190, 214, 12); bush(60, 205, 7, 5); bush(440, 190, 8, 6); bed(420, 214, 12) end
if N == 6 then bed(270, 212, 12); bush(445, 192, 8, 7) end
if N == 8 then bush(440, 196, 8, 8); bed(420, 208, 10) end
bush(448, 262, 9, 9); bush(300, 266, 6, 10)
local sx = {160, 205, 340, 395}
for _, x in ipairs(sx) do if N ~= 8 or x ~= 205 then bush(x, 268, 5, x) end end
c:finish{ outline = false }
c:save{ aseprite = d .. "/out/resid-" .. N .. ".aseprite", png = d .. "/out/resid-" .. N .. ".png", scale = 1 }
c:save{ png = "/tmp/claude-0/-home-user-gnome-venture/06fd8064-60b9-5d47-ba02-41f9cb9f6245/scratchpad/resid-" .. N .. "_x2.png", scale = 2 }

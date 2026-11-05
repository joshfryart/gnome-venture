-- The Pal Yard: garden yard beside the treehouse, 480x270, horizon 96. Sites fill the layout boxes (here_layouts.json 'yard').
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/tree-yard/out/")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "yard-pals" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, sin, abs = math.floor, math.max, math.min, math.sin, math.abs
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON, DIRT =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.IRON, S.DIRT
local rect, rr, poly, obj, tex, hash = S.rect, S.rr, S.poly, S.obj, S.tex, S.hash
local cols = {"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8", "#8a6fd0", "#f5809f"}

---------------------------------------------------------------- sky, far hills, grass, paths
c:stripes(0, 96, {"#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8"}, {2, 2, 2, 2, 3})
c:cloud(60, 52, 48, "#f8f0e0", "#d6e6f0"); c:cloud(300, 40, 40, "#f8f0e0", "#d6e6f0")
c:terrain(function(x) return 70 + 12 * sin(x / 48) + 5 * sin(x / 17 + 1) end, "#7e9cc4", 98)
c:terrain(function(x) return 84 + 7 * sin(x / 37 + 2) end, "#5f9a78", 98)
local grass = rect(0, 96, 479, 269)
S.tex(grass, function(x, y)
  local t = (y - 96) / 174
  local i = t < .25 and 3 or t < .6 and 4 or 4
  if hash(x, y, 6) > .955 then i = min(6, i + 1) elseif hash(x, y, 7) > .975 then i = max(1, i - 1) end
  return GREEN[i]
end)
c:fillMask(rect(0, 96, 479, 96), GREEN[2])
-- dirt paths joining the sites and the stand points (flat, plain: 28+ clear around stand slots)
local function path(pts, th) local m = c:line(pts, th); tex(m, function(x, y) return DIRT[hash(x, y, 2) > .93 and 3 or 4] end); return m end
path({{150, 206}, {240, 190}, {330, 196}}, 12); path({{240, 190}, {240, 226}}, 12); path({{170, 150}, {240, 150}, {330, 146}}, 10)
path({{120, 236}, {240, 232}, {360, 236}}, 10); path({{330, 146}, {392, 116}}, 8); path({{330, 196}, {420, 190}}, 8); path({{150, 206}, {84, 176}}, 8); path({{170, 150}, {64, 112}}, 6)
-- fence along the horizon
for x = 6, 474, 12 do obj(rect(x, 92, x + 2, 104), OAK, { base = 4 }) end
obj(rect(4, 95, 476, 97), OAK, { base = 5 }); obj(rect(4, 100, 476, 102), OAK, { base = 4 })

local function blobTree(cx, cy)   -- a bushy tree at the fence (hero size)
  local m = c:ellipse(cx, cy, 22, 18); c:rim(m, GREEN[1])
  tex(m, function(x, y) local t = ((x - cx) / 22) * .5 + ((y - cy) / 18) * .8; local i = t < -.5 and 5 or t < 0 and 4 or 3; return GREEN[i] end)
  obj(rect(cx - 3, cy + 14, cx + 3, cy + 26), TIMB, { base = 3 })
end
blobTree(24, 76); blobTree(452, 72); blobTree(300, 78)

---------------------------------------------------------------- Sick bay [30,92,100,136]: a little tent-cottage with a bandage banner (no text)
local sb = rect(36, 108, 94, 136); c:rim(sb, "#2b1c26"); S.planks(sb, CREAM, { w = 6, base = 4, seed = 3 })
local roof = poly{{30, 110}, {65, 92}, {100, 110}}; c:rim(roof, "#2b1c26"); tex(roof, function(x, y) return (floor(x / 6) % 2 == 0) and ROSE[4] or CREAM[5] end)
local door = rr(58, 118, 72, 136, 3); c:rim(door, "#2b1c26"); c:fillMask(door, TEAL[3])
local cross = {{63, 121, 67, 121}, {63, 124, 67, 124}}   -- stitched patch above the door
obj(rect(40, 118, 52, 128), CREAM, { base = 5 }); c:fillMask(rect(45, 118, 46, 128), TIMB[3]); c:fillMask(rect(40, 123, 52, 124), TIMB[3])

---------------------------------------------------------------- Garden plot [40,150,130,206]: raised beds with rows
local gp = rect(40, 150, 130, 206); c:rim(gp, TIMB[1]); obj(gp, TIMB, { base = 3 })
for r = 0, 1 do
  local bed = rect(46, 156 + r * 24, 124, 172 + r * 24); c:rim(bed, "#2b1c26"); tex(bed, function(x, y) return hash(x, y, 1) > .9 and "#6a3e2c" or "#845236" end)
  for i = 0, 7 do
    local x = 52 + i * 9; local y = 160 + r * 24
    c:fillMask(rect(x, y + 3, x + 1, y + 11), GREEN[3]); c:fillMask(rect(x - 2, y, x + 3, y + 4), GREEN[5]); c:fillMask(rect(x - 1, y - 1, x + 2, y), GREEN[6])
    if (i + r) % 3 == 0 then local f = S.diamond(x + 1, y - 2, 2); c:rim(f, "#2b1c26"); c:fillMask(f, cols[(i + r) % 6 + 1]) end
  end
end

---------------------------------------------------------------- Trail head [360,98,424,140]: gate arch and signpost to the hills
local g1, g2 = rect(362, 104, 368, 140), rect(416, 104, 422, 140)
obj(g1, TIMB, { base = 4 }); obj(g2, TIMB, { base = 4 }); obj(rect(360, 98, 424, 106), TIMB, { base = 5 })
local lantern = rect(388, 108, 394, 116); c:rim(lantern, "#2b1c26"); c:fillMask(lantern, GOLD[5])
for i = 0, 3 do local f = poly{{366 + i * 14, 108}, {376 + i * 14, 108}, {371 + i * 14, 116}}; c:rim(f, "#2b1c26"); c:fillMask(f, cols[i % 6 + 1]) end
obj(rect(396, 124, 400, 140), TIMB, { base = 3 }); obj(rect(388, 124, 412, 132), OAK, { base = 5 }); c:fillMask(rect(408, 126, 412, 130), "#fff4d6")

---------------------------------------------------------------- Delve mouth [392,166,468,214]: rock mound with a timbered cave
local mound = poly{{392, 214}, {400, 184}, {418, 168}, {444, 168}, {462, 184}, {468, 214}}
c:rim(mound, STONE[1]); tex(mound, function(x, y) local t = (x - 392) / 76; local i = t < .3 and 5 or t < .65 and 4 or 3; if hash(floor(x / 3), floor(y / 3), 5) > .8 then i = i - 1 end return STONE[max(1, min(6, i))] end)
local mouth = rr(416, 186, 446, 214, 6); c:rim(mouth, "#2b1c26"); c:fillMask(mouth, "#1a1226")
obj(rect(412, 184, 416, 214), TIMB, { base = 4 }); obj(rect(446, 184, 450, 214), TIMB, { base = 4 }); obj(rect(410, 180, 452, 186), TIMB, { base = 5 })
c:fillMask(rect(425, 204, 437, 214), "#3a2c4a")

---------------------------------------------------------------- Kitchen and craft stations [198,118,282,178]: pavilion with a stove and a workbench
for _, x in ipairs{200, 276} do obj(rect(x, 126, x + 4, 178), TIMB, { base = 4 }) end
local awn = poly{{196, 128}, {284, 128}, {278, 118}, {202, 118}}; c:rim(awn, "#2b1c26"); tex(awn, function(x, y) return (floor(x / 8) % 2 == 0) and BARN[4] or CREAM[5] end)
local stove = rect(206, 148, 236, 178); obj(stove, IRON, { base = 3 }); c:fillMask(rect(212, 156, 230, 168), "#1a1226"); c:fillMask(rect(214, 160, 228, 166), "#f5b82e"); c:fillMask(rect(216, 162, 226, 166), "#ff8a5c")
obj(rect(210, 136, 218, 148), IRON, { base = 3 })   -- chimney pipe
obj(rect(244, 154, 274, 160), OAK, { base = 5 }); obj(rect(246, 160, 250, 178), TIMB, { base = 3 }); obj(rect(268, 160, 272, 178), TIMB, { base = 3 })
for i = 0, 3 do c:fillMask(rect(248 + i * 7, 148, 252 + i * 7, 153), cols[(i + 2) % 6 + 1]) end

---------------------------------------------------------------- Ledger [200,202,280,252]: a noticeboard with pinned notes and a ledger book
obj(rect(206, 206, 210, 252), TIMB, { base = 3 }); obj(rect(270, 206, 274, 252), TIMB, { base = 3 })
local board = rect(208, 204, 272, 236); c:rim(board, "#2b1c26"); S.planks(board, OAK, { w = 8, base = 4, vert = false, seed = 4 })
for i = 0, 5 do local x, y = 214 + (i % 3) * 18, 210 + floor(i / 3) * 12; c:rim(rect(x, y, x + 12, y + 8), "#2b1c26"); c:fillMask(rect(x, y, x + 12, y + 8), i % 2 == 0 and CREAM[6] or "#f4d88a"); c:fillMask(rect(x + 5, y, x + 6, y + 1), "#e8493b") end
obj(rect(224, 238, 256, 248), BARN, { base = 4 }); c:fillMask(rect(224, 241, 256, 241), CREAM[5]); c:fillMask(rect(239, 238, 240, 248), BARN[2])   -- the ledger book

---------------------------------------------------------------- flowers and tufts (never near the stand slots or the compass corner)
for i = 0, 40 do
  local x, y = floor(hash(i, 1, 9) * 470) + 4, 110 + floor(hash(i, 2, 9) * 150)
  local ok = true
  for _, s in ipairs{ {150, 206}, {330, 196}, {170, 150}, {330, 146}, {120, 236}, {360, 236} } do if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 < 34 ^ 2 then ok = false end end
  if x > 360 and y > 214 then ok = false end
  if ok and not c:get(x, y):find("^#c") then c:fillMask(rect(x, y, x + 1, y + 1), cols[i % 6 + 1]) end
end

---------------------------------------------------------------- POLISH (guarded: never touches the stand slots or the compass corner)
local STAND = { {150, 206}, {330, 196}, {170, 150}, {330, 146}, {120, 236}, {360, 236} }
local function blocked(x, y)
  if x >= 366 and y >= 218 then return true end
  for _, s in ipairs(STAND) do if abs(x - s[1]) <= 15 and abs(y - s[2]) <= 15 then return true end end
  return false
end
local rawput = c.put
c.put = function(self, x, y, hex, o) if x < 0 or y < 0 or x >= W or y >= H then return end if blocked(x, y) then return end return rawput(self, x, y, hex, o) end

local INK = "#2b1c26"
local SBLUE = S.SBLUE
local function P(x, y, col) c:put(floor(x), floor(y), col) end
local function R(x0, y0, x1, y1, col) for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do P(x, y, col) end end end
local function is(x, y, set) local v = c:get(x, y); return v ~= nil and set[v] == true end
local function setOf(t) local o = {} for _, v in ipairs(t) do o[v:lower()] = true end return o end
local GRASS, PATHS = setOf(GREEN), setOf{ DIRT[3], DIRT[4] }
local function vn(x, y, cs, s) -- smooth-ish value noise, 0..1
  local gx, gy = x / cs, y / cs; local x0, y0 = floor(gx), floor(gy); local fx, fy = gx - x0, gy - y0
  local a, b, cc, d = hash(x0, y0, s), hash(x0 + 1, y0, s), hash(x0, y0 + 1, s), hash(x0 + 1, y0 + 1, s)
  return (a * (1 - fx) + b * fx) * (1 - fy) + (cc * (1 - fx) + d * fx) * fy
end
local function pebble(x, y, k)
  P(x, y, STONE[k or 4]); P(x + 1, y, STONE[k or 4]); P(x, y - 1, STONE[min(6, (k or 4) + 1)]); P(x, y + 1, STONE[2]); P(x + 1, y + 1, STONE[2])
end
local function tuft(x, y, k)
  P(x, y, GREEN[2]); P(x - 1, y - 1, GREEN[k or 5]); P(x, y - 2, GREEN[k or 5]); P(x + 1, y - 1, GREEN[k or 5]); P(x, y - 1, GREEN[3])
end
local function flower(x, y, kind, col)
  P(x, y, GREEN[2]); P(x, y - 1, GREEN[3])
  if kind == 1 then -- daisy: cream petals, gold eye
    P(x, y - 3, "#f8eacc"); P(x - 1, y - 2, "#f8eacc"); P(x + 1, y - 2, "#f8eacc"); P(x, y - 1, "#f8eacc"); P(x, y - 2, "#f5b82e")
  elseif kind == 2 then -- tulip cup
    P(x - 1, y - 3, col); P(x + 1, y - 3, col); P(x - 1, y - 2, col); P(x, y - 2, col); P(x + 1, y - 2, col); P(x, y - 3, ROSE[3])
  else -- clover / bluebell dot with leaf
    P(x, y - 2, col); P(x, y - 3, col); P(x - 1, y - 1, GREEN[5]); P(x + 1, y - 1, GREEN[5])
  end
end

-- PASS 1: weak flat areas -> mottled grass, worn paths, pebbles, leaves, flowers
for y = 97, 269 do for x = 0, 479 do
  if is(x, y, GRASS) then
    local v = vn(x, y, 14, 21) * .65 + vn(x, y, 5, 22) * .35
    local chk = (x + y) % 2 == 0
    local far = y < 140
    if v > .66 and chk then P(x, y, GREEN[5]) elseif v > .6 and (x % 2 == 0 and y % 2 == 0) then P(x, y, GREEN[5])
    elseif v < .34 and chk then P(x, y, GREEN[3]) elseif v < .4 and (x % 2 == 1 and y % 2 == 1) then P(x, y, GREEN[3]) end
    if far and (x + y) % 3 == 0 and hash(x, y, 23) > .6 then P(x, y, GREEN[5]) end
  end
end end
-- worn paths: dark verge, light crown, ruts, hard pebbles
local snap = {}
for y = 97, 269 do for x = 0, 479 do if is(x, y, PATHS) then snap[y * W + x] = true end end end
local function pth(x, y) return snap[y * W + x] == true end
for y = 97, 269 do for x = 0, 479 do
  if pth(x, y) then
    local edge = not (pth(x - 1, y) and pth(x + 1, y) and pth(x, y - 1) and pth(x, y + 1))
    local edge2 = not (pth(x - 2, y) and pth(x + 2, y) and pth(x, y - 2) and pth(x, y + 2))
    if edge then P(x, y, hash(x, y, 31) > .35 and DIRT[2] or DIRT[3])
    elseif edge2 then P(x, y, ((x + y) % 2 == 0) and DIRT[3] or DIRT[4])
    elseif hash(x, y, 32) > .93 then P(x, y, DIRT[5])
    elseif hash(x, y, 33) > .955 then P(x, y, DIRT[3])
    elseif vn(x, y, 9, 34) > .72 and (x + y) % 2 == 0 then P(x, y, DIRT[5]) end
  end
end end
for i = 0, 170 do
  local x, y = floor(hash(i, 3, 40) * 476) + 2, 100 + floor(hash(i, 4, 40) * 164)
  if pth(x, y) and pth(x + 1, y + 1) and hash(i, 5, 40) > .45 then pebble(x, y, 3 + i % 2)
  elseif pth(x, y) then P(x, y, i % 3 == 0 and LEAF[4] or LEAF[3]); P(x + 1, y, LEAF[5]) end
end
-- flowers, tufts and pebbles in the grass
for i = 0, 150 do
  local x, y = floor(hash(i, 7, 50) * 472) + 4, 108 + floor(hash(i, 8, 50) * 156)
  if is(x, y, GRASS) and is(x, y - 3, GRASS) and is(x + 1, y, GRASS) then
    local r = hash(i, 9, 50)
    if r < .22 then flower(x, y, 1)
    elseif r < .4 then flower(x, y, 2, i % 2 == 0 and "#e8493b" or "#f5809f")
    elseif r < .52 then flower(x, y, 3, i % 2 == 0 and "#8a6fd0" or "#5fc4c8")
    elseif r < .8 then tuft(x, y, i % 3 == 0 and 6 or 5)
    elseif r < .9 then pebble(x, y, 4)
    else P(x, y, LEAF[4]); P(x + 1, y, LEAF[5]); P(x, y + 1, LEAF[2]) end
  end
end

-- PASS 2: frame (hedges, picket fence, gate) and clearer site silhouettes with own accent colours
local function bush(cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry); c:rim(m, GREEN[1])
  tex(m, function(x, y)
    local t = ((x - cx) / rx) * .55 + ((y - cy) / ry) * .8
    local i = t < -.55 and 5 or t < .05 and 4 or t < .6 and 3 or 2
    if hash(x, y, seed) > .9 then i = min(6, i + 1) elseif (x + y) % 2 == 0 and abs(t + .05) < .12 then i = max(1, i - 1) end
    return GREEN[i]
  end)
end
local function berries(cx, cy, rx, ry, col, n, seed)
  for i = 1, n do local x, y = cx + floor((hash(i, 1, seed) * 2 - 1) * (rx - 2)), cy + floor((hash(i, 2, seed) * 2 - 1) * (ry - 2)); P(x, y, col); P(x + 1, y, INK) end
end
for y = 106, 262, 9 do local x = 3 + floor(hash(y, 1, 60) * 3); bush(x, y, 7, 6, 61) end          -- left hedge
for y = 108, 214, 9 do local x = 476 - floor(hash(y, 2, 60) * 3); bush(x, y, 7, 6, 62) end        -- right hedge
for i = 0, 7 do berries(4, 106 + i * 9, 7, 6, "#e8493b", 1, 70 + i) end
for i = 0, 3 do berries(476, 108 + i * 9 * 3, 7, 6, "#f5809f", 2, 80 + i) end
local function picket(x0, x1, y, h)   -- horizontal picket fence, cream, ink rim, pointed tops
  local un = HP.mask()
  un:add(rect(x0, y + 3, x1, y + 4)); un:add(rect(x0, y + h - 4, x1, y + h - 3))
  for x = x0, x1 - 2, 6 do un:add(rect(x, y + 1, x + 2, y + h)); un:set(x + 1, y) end
  c:rim(un, INK)
  for x = x0, x1 - 2, 6 do
    R(x, y + 1, x + 2, y + h, CREAM[4]); P(x + 1, y, CREAM[5]); R(x, y + 1, x, y + h, CREAM[5]); R(x + 2, y + 1, x + 2, y + h, CREAM[3])
    if hash(x, y, 90) > .5 then P(x + 1, y + 5, CREAM[2]) end
  end
  R(x0, y + 3, x1, y + 3, OAK[5]); R(x0, y + 4, x1, y + 4, OAK[3]); R(x0, y + h - 4, x1, y + h - 4, OAK[5]); R(x0, y + h - 3, x1, y + h - 3, OAK[3])
end
-- bottom fence with a gate in the middle (kept clear of the compass corner)
picket(10, 292, 252, 14); picket(346, 358, 252, 14)
for _, ex in ipairs{6, 358} do obj(rect(ex, 246, ex + 4, 266), TIMB, { base = 4 }); R(ex - 1, 244, ex + 5, 245, OAK[5]) end
for _, gx in ipairs{292, 340} do obj(rect(gx, 244, gx + 6, 268), TIMB, { base = 4 }); R(gx - 1, 242, gx + 7, 243, OAK[5]); R(gx, 244, gx + 6, 244, OAK[6]) end
local arch = poly{{292, 244}, {346, 244}, {340, 236}, {298, 236}}; c:rim(arch, INK); tex(arch, function(x, y) return y < 239 and TIMB[5] or TIMB[3] end)
for i = 0, 1 do local gl = rect(300 + i * 21, 252, 318 + i * 21, 266); c:rim(gl, INK); S.planks(gl, OAK, { w = 5, base = 4, seed = 8 + i }) end
c:fillMask(rect(317, 247, 321, 250), "#f5b82e"); P(319, 248, GOLD[6])    -- little brass lantern on the gate
-- garden: low picket frame + bright leafy accent
picket(36, 134, 207, 11)
for _, x in ipairs{40, 72, 104, 126} do obj(rect(x, 192, x + 2, 206), OAK, { base = 5 }) end
-- sick bay: red-cross signboard on a post, hanging lamp, chimney
obj(rect(95, 112, 97, 136), TIMB, { base = 3 })
local sg = rr(88, 100, 104, 114, 2); c:rim(sg, INK); c:fillMask(sg, CREAM[6])
c:fillMask(rect(94, 102, 98, 112), "#e8493b"); c:fillMask(rect(91, 105, 101, 109), "#e8493b"); R(94, 102, 95, 112, "#f0705a"); R(91, 105, 101, 105, "#f0705a")
obj(rect(78, 94, 83, 104), STONE, { base = 4 })
-- trip: blue banner pennants on the gate + steps to the hills
for i = 0, 2 do local b = poly{{426 + i * 0, 100 + i * 12}, {436, 104 + i * 12}, {426, 108 + i * 12}}; end
local pole = rect(422, 80, 424, 104); obj(pole, TIMB, { base = 4 })
local flag = poly{{424, 82}, {446, 87}, {424, 94}}; c:rim(flag, INK); tex(flag, function(x, y) return (y < 88) and "#3f8ee0" or "#2a6ab8" end)
c:fillMask(rect(430, 86, 434, 88), "#f8eacc")
for i = 0, 3 do obj(rect(376 + i * 0, 138 + i * 0, 408, 141), STONE, { base = 5 - (i % 2) }) end
-- delve: violet crystal cluster and rail track out of the mouth
local function crystal(x, y, h, w)
  local m = poly{{x, y}, {x + w, y}, {x + w // 2 + 1, y - h}, {x + w // 2, y - h}}
  c:rim(m, INK); tex(m, function(px, py) return (px - x) < w / 2 and VIOLET[5] or VIOLET[3] end); P(x + w // 2, y - h + 1, VIOLET[6])
end
crystal(396, 210, 12, 5); crystal(402, 212, 8, 4); crystal(463, 212, 11, 5); crystal(468, 214, 6, 3)
for i = 0, 5 do R(422 + i * 4, 214, 424 + i * 4, 214, OAK[2]) end
-- station: red/orange accent: bunting, hanging lantern
obj(rect(238, 128, 240, 134), IRON, { base = 3 }); c:rim(rect(236, 134, 242, 140), INK); c:fillMask(rect(236, 134, 242, 140), "#ffb347"); R(238, 136, 240, 138, "#fff0b0")
-- noticeboard: blue cloth banner roof + bright pennants
local roofB = poly{{204, 204}, {276, 204}, {270, 195}, {210, 195}}; c:rim(roofB, INK); tex(roofB, function(x, y) return (floor((x + y) / 5) % 2 == 0) and SBLUE[4] or SBLUE[3] end)
R(210, 195, 270, 195, SBLUE[6])

-- PASS 3: material cues (wood grain and knots, stone courses and chips, moss, shingles, cloth folds, rope, rust)
local WOOD, STN, IRN = setOf{ TIMB[3], TIMB[4], TIMB[5], OAK[3], OAK[4], OAK[5], OAK[6], TIMB[6] }, setOf{ STONE[3], STONE[4], STONE[5], STONE[2] }, setOf{ IRON[2], IRON[3], IRON[4], IRON[5] }
local function grain(x0, y0, x1, y1, seed, vert)
  for a = (vert and x0 or y0), (vert and x1 or y1) do
    if hash(a, 1, seed) > .55 then
      local len, st = 3 + floor(hash(a, 2, seed) * 8), (vert and y0 or x0) + floor(hash(a, 3, seed) * ((vert and y1 - y0 or x1 - x0) - 3))
      for k = 0, len do
        local x, y = vert and a or st + k, vert and st + k or a
        if x <= x1 and y <= y1 and is(x, y, WOOD) then P(x, y, (hash(x, y, seed) > .8) and OAK[6] or TIMB[2]) end
      end
    end
  end
  for i = 0, 1 do local kx, ky = x0 + floor(hash(i, 4, seed) * (x1 - x0 - 2)) + 1, y0 + floor(hash(i, 5, seed) * (y1 - y0 - 2)) + 1
    if is(kx, ky, WOOD) and is(kx + 1, ky + 1, WOOD) then P(kx, ky, TIMB[1]); P(kx + 1, ky, TIMB[2]); P(kx, ky + 1, TIMB[2]); P(kx - 1, ky, OAK[5]) end end
end
local function stoneCourses(x0, y0, x1, y1, seed, step)
  local row = 0
  for y = y0, y1, step do
    for x = x0, x1 do if is(x, y, STN) and hash(x, y, seed) > .12 then P(x, y, STONE[2]) end end
    local off = (row % 2) * (step + 1)
    for x = x0 + off, x1, step * 2 do for k = 1, step - 1 do if is(x, y + k, STN) then P(x, y + k, STONE[2]) end end end
    row = row + 1
  end
  for i = 0, 40 do local x, y = x0 + floor(hash(i, 6, seed) * (x1 - x0)), y0 + floor(hash(i, 7, seed) * (y1 - y0))   -- chips: lit nick + dark crack
    if is(x, y, STN) and is(x + 1, y + 1, STN) then P(x, y, STONE[6]); P(x + 1, y + 1, STONE[1]); if i % 3 == 0 then P(x + 2, y + 2, STONE[1]) end end end
end
local function moss(x0, y0, x1, y1, seed, set)
  for y = y0, y1 do for x = x0, x1 do
    if is(x, y, set) and (not is(x, y - 1, set) or (not is(x, y - 2, set) and hash(x, y, seed + 1) > .4)) and vn(x, y, 7, seed) > .6 then
      P(x, y, (x + y) % 3 == 0 and LEAF[4] or GREEN[4]); if hash(x, y, seed) > .6 then P(x, y + 1, GREEN[3]) end
    end
  end end
end
-- timber: posts, bed frame, board legs
grain(40, 150, 130, 156, 101); grain(40, 170, 46, 206, 102, true); grain(124, 150, 130, 206, 103, true)
grain(362, 104, 368, 140, 104, true); grain(416, 104, 422, 140, 105, true); grain(360, 98, 424, 106, 106); grain(388, 124, 412, 132, 107)
grain(200, 126, 204, 178, 108, true); grain(276, 126, 280, 178, 109, true); grain(244, 154, 274, 160, 110); grain(206, 206, 210, 252, 111, true); grain(270, 206, 274, 252, 112, true)
grain(412, 184, 416, 214, 113, true); grain(446, 184, 450, 214, 114, true); grain(410, 180, 452, 186, 115)
-- delve mound: stone courses, chips, moss on the shaded-top side
stoneCourses(394, 170, 466, 213, 120, 6); moss(392, 166, 468, 190, 121, STN)
-- garden: soil clods, wet furrows, moss on the bed frame
for r = 0, 1 do for i = 0, 14 do local x, y = 47 + floor(hash(i, r, 130) * 76), 157 + r * 24 + floor(hash(i, r + 5, 130) * 14)
  if c:get(x, y) == "#845236" then P(x, y, "#5a3022"); P(x + 1, y, "#9a6240") end end end
for _, p in ipairs{{41, 200}, {42, 201}, {41, 202}, {43, 202}, {42, 199}, {128, 152}, {127, 151}, {129, 153}} do P(p[1], p[2], p[1] < 60 and GREEN[4] or LEAF[4]) end
-- sick bay: wall plank grain, shingle ticks on the roof, moss at the north eave
for y = 112, 134 do for x = 37, 93 do if is(x, y, setOf{CREAM[4], CREAM[5]}) and (x % 6 == 0 or hash(x, y, 140) > .985) then P(x, y, CREAM[2]) end end end
for y = 94, 109 do for x = 31, 99 do
  if is(x, y, setOf{ROSE[4], CREAM[5]}) and ((y % 4 == 0) or ((y % 4 == 2) and x % 6 == 3)) then P(x, y, is(x, y, setOf{ROSE[4]}) and ROSE[2] or CREAM[3]) end
end end
moss(36, 108, 56, 136, 141, setOf{CREAM[4], CREAM[5]})
-- station: awning scallops + cloth folds, stove rust and rivets, bench
for i = 0, 10 do local x0 = 198 + i * 8; local col = (floor((x0 + 3) / 8) % 2 == 0) and BARN[4] or CREAM[5]
  local m = rr(x0 + 1, 129, x0 + 7, 133, 2); c:rim(m, INK); c:fillMask(m, col); P(x0 + 3, 131, col == BARN[4] and BARN[2] or CREAM[3]) end
for x = 204, 278, 8 do for y = 120, 127 do if is(x, y, setOf{BARN[4], CREAM[5]}) then P(x, y, c:get(x, y) == BARN[4] and BARN[2] or CREAM[3]) end end end
for i = 0, 6 do local x = 206 + floor(hash(i, 1, 150) * 28); for y = 150 + floor(hash(i, 2, 150) * 6), 176 do if is(x, y, IRN) and hash(x, y, 151) > .45 then P(x, y, y % 3 == 0 and "#a8603a" or "#7a3e28") end end end
for _, p in ipairs{{208, 150}, {233, 150}, {208, 175}, {233, 175}} do P(p[1], p[2], IRON[6]); P(p[1] + 1, p[2], IRON[2]) end
for y = 136, 146 do P(211, y, IRON[5]) end
-- noticeboard: cork-like plank grain, nail heads, ledger folds
for y = 205, 235 do for x = 209, 271 do if (y - 205) % 8 == 7 then P(x, y, OAK[2]) end end end
grain(208, 205, 272, 235, 160)
for _, p in ipairs{{211, 206}, {268, 206}, {211, 233}, {268, 233}} do P(p[1], p[2], IRON[5]) end
for x = 226, 254, 6 do P(x, 243, BARN[2]); P(x + 1, 245, BARN[5]) end
-- trip: gate rope with knot and sign planks; rope coil on the delve post
local function rope(pts, col1, col2) for i, p in ipairs(pts) do P(p[1], p[2], i % 2 == 0 and col1 or col2) end end
rope({{392,116},{392,118},{393,120},{393,122},{392,124}}, "#d8b862", "#8a6a34")
P(391, 125, "#8a6a34"); P(393, 125, "#8a6a34"); P(392, 126, "#d8b862")
for a = 0, 11 do local x, y = floor(412 + 5 * math.cos(a * .52) + .5), floor(204 + 6 * sin(a * .52) + .5); P(x, y, a % 2 == 0 and "#d8b862" or "#8a6a34") end
for y = 204, 207 do P(448, y, "#d8b862") end
-- sign planks
R(388, 128, 412, 128, OAK[2]); R(388, 130, 412, 130, OAK[3])

-- PASS 4: lived-in props + light (key light top-left, shadows lower-right, warm lantern glow, cool far field)
local function mixhex(h1, h2, t)
  local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
  local r1, g1, b1 = rgb(h1); local r2, g2, b2 = rgb(h2)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local DARK = {}
for i = 2, 6 do DARK[GREEN[i]] = GREEN[i - 1] end
DARK[DIRT[3]] = DIRT[2]; DARK[DIRT[4]] = DIRT[3]; DARK[DIRT[5]] = DIRT[4]; DARK[DIRT[2]] = DIRT[1]
local function cast(x0, y0, x1, y1, dx, dy)   -- cast shadow of a box falling lower-right (dithered rim)
  local box, sh = rect(x0, y0, x1, y1), HP.mask()
  for t = 1, 8 do sh:add(box:shift(floor(dx * t / 8 + .5), floor(dy * t / 8 + .5))) end
  sh:cut(box)
  local far = box:shift(dx, dy)
  sh:each(function(x, y)
    local v = c:get(x, y); local d = v and DARK[v]
    if d and (far:has(x, y) == false or (x + y) % 2 == 0) then P(x, y, d) end
  end)
end
cast(36, 108, 94, 136, 7, 4); cast(40, 150, 134, 218, 7, 4); cast(200, 126, 280, 178, 8, 5); cast(206, 204, 274, 252, 8, 4)
cast(362, 104, 422, 140, 7, 4); cast(392, 168, 466, 214, 7, 4); cast(10, 252, 358, 266, 3, 3)
-- far field cooler and lighter (dithered towards the hills)
for y = 97, 126 do for x = 0, 479 do local v = c:get(x, y)
  if v and DARK[v] ~= nil and is(x, y, GRASS) then local t = (126 - y) / 30 * .42; if (x + y) % 2 == 0 or y < 108 then P(x, y, mixhex(v, "#a8d0d4", t)) end end
end end
-- watering can (teal, spout, rose, handle) and a drip of water
c:rim(rr(112, 195, 124, 205, 2), INK); R(112, 196, 124, 204, TEAL[4]); R(112, 196, 114, 204, TEAL[5]); R(122, 196, 124, 204, TEAL[3]); R(112, 204, 124, 204, TEAL[2]); R(113, 195, 123, 195, TEAL[6])
for i = 0, 6 do P(125 + i, 199 - i, INK); P(125 + i, 200 - i, TEAL[3]); P(125 + i, 201 - i, INK) end
R(130, 191, 133, 192, TEAL[5]); P(129, 191, INK); P(134, 191, INK); R(129, 190, 134, 190, INK)
for i = 0, 3 do P(110 + (i == 1 and 0 or (i == 2 and 0 or 1)), 197 + i, INK) end; R(109, 198, 109, 200, INK); P(110, 197, INK); P(110, 201, INK); R(110, 198, 110, 200, TEAL[2])
P(134, 194, "#9fd8ea"); P(135, 197, "#9fd8ea")
-- cabbages and carrots among the lettuce, sunflowers, pumpkins
local function cabbage(x, y) local m = c:ellipse(x, y, 4, 3); c:rim(m, INK); tex(m, function(px, py) return (px - x) + (py - y) < -2 and TEAL[5] or (px - x) + (py - y) > 2 and TEAL[3] or TEAL[4] end); P(x - 1, y, TEAL[6]); P(x, y + 1, TEAL[2]) end
local function carrot(x, y) P(x, y + 1, "#f08a2c"); P(x - 1, y, "#f08a2c"); P(x + 1, y, "#d86a1c"); for k = 1, 4 do P(x - 1 + (k % 2) * 2, y - k, GREEN[k > 2 and 5 or 4]); P(x, y - k, GREEN[5]) end end
for r = 0, 1 do for i = 0, 7 do local x, y = 52 + i * 9, 160 + r * 24
  if (i + r) % 4 == 1 then R(x - 3, y - 2, x + 4, y + 9, "#845236"); cabbage(x, y + 7)
  elseif (i + r) % 4 == 3 then R(x - 3, y - 2, x + 4, y + 9, "#845236"); carrot(x, y + 9); carrot(x + 3, y + 10) end
end end
local function sunflower(x, y, h)
  R(x, y - h, x + 1, y, GREEN[3]); P(x - 1, y - 5, GREEN[4]); P(x - 2, y - 6, GREEN[5]); P(x + 2, y - 8, GREEN[4]); P(x + 3, y - 9, GREEN[5])
  local hd = c:ellipse(x, y - h - 2, 4, 4); c:rim(hd, INK); c:fillMask(hd, GOLD[5]); c:fillMask(c:ellipse(x, y - h - 2, 2, 2), TIMB[2])
  P(x - 4, y - h - 2, GOLD[4]); P(x - 3, y - h - 5, GOLD[6]); P(x, y - h - 2, TIMB[1])
end
sunflower(136, 180, 15); sunflower(142, 184, 11)
local function pumpkin(x, y, r)
  local m = c:ellipse(x, y, r + 2, r); c:rim(m, INK)
  tex(m, function(px, py) local d = px - x; return d < -r * .5 and "#f5a040" or d > r * .6 and "#c0501c" or abs(d) % 4 == 0 and "#d8661e" or "#e8803a" end)
  P(x - 2, y - 1, "#fcc470"); P(x, y - r - 1, GREEN[2]); P(x + 1, y - r - 2, GREEN[3]); P(x, y - r, GREEN[3])
  P(x + r + 3, y + r - 1, DARK[GREEN[4]] or GREEN[2]); P(x + r + 4, y + r, GREEN[2])
end
pumpkin(52, 227, 5); pumpkin(64, 229, 4); pumpkin(76, 226, 3); P(70, 230, GREEN[5]); P(88, 228, GREEN[5])
-- sick bay: potion table with jars and a bandage roll
R(72, 129, 92, 131, OAK[5]); R(72, 131, 92, 131, OAK[3]); R(73, 132, 74, 136, TIMB[3]); R(90, 132, 91, 136, TIMB[3]); c:rim(rect(72, 129, 92, 131), INK)
local function jar(x, col, lid) c:rim(rect(x, 121, x + 3, 128), INK); R(x, 121, x + 3, 128, "#cfe4ea"); R(x + 1, 124, x + 3, 128, col); P(x, 122, "#ffffff" == "" and col or CREAM[6]); R(x, 120, x + 3, 120, lid); P(x + 3, 128, DARK[col] or col) end
jar(74, "#e8493b", OAK[4]); jar(79, "#7cc35a", OAK[4]); jar(84, "#8a6fd0", OAK[4])
c:rim(rr(88, 123, 92, 128, 1), INK); R(88, 124, 92, 128, CREAM[6]); R(88, 126, 92, 126, CREAM[3]); P(89, 124, "#e8493b"); R(92, 128, 94, 128, CREAM[5]); P(94, 129, CREAM[4])
-- station: kettle with steam, hanging bell
local kb = c:ellipse(229, 144, 5, 4); c:rim(kb, INK); tex(kb, function(x, y) return (x - 229) + (y - 144) < -2 and BARN[6] or (x - 229) + (y - 144) > 2 and BARN[3] or BARN[5] end); R(227, 139, 231, 139, IRON[3]); P(229, 138, IRON[5])
R(234, 142, 237, 140, BARN[4]); P(238, 139, INK); P(233, 143, BARN[5]); R(225, 141, 225, 142, INK)
for _, p in ipairs{{228, 136}, {230, 135}, {227, 134}, {229, 133}} do if (p[1] + p[2]) % 2 == 0 then P(p[1], p[2], CREAM[6]) end end
P(228, 136, "#f8eacc"); P(230, 134, "#dcc4a6"); P(229, 132, "#dcc4a6")
R(265, 133, 265, 135, "#d8b862"); local bell = poly{{262, 143}, {269, 143}, {268, 138}, {267, 136}, {264, 136}, {263, 138}}; c:rim(bell, INK)
tex(bell, function(x, y) return x < 265 and GOLD[6] or x > 267 and GOLD[3] or GOLD[5] end); R(262, 142, 269, 142, GOLD[2]); P(265, 144, IRON[3]); P(265, 145, INK)
-- noticeboard lamp post with warm lantern, bucket
obj(rect(284, 208, 286, 250), TIMB, { base = 3 }); R(280, 206, 290, 207, IRON[3]); c:rim(rect(281, 198, 289, 205), INK); R(281, 198, 289, 205, "#ffcf5a"); R(283, 200, 287, 204, "#fff0b0"); R(281, 198, 289, 198, IRON[4]); R(284, 198, 286, 205, IRON[3]); P(285, 196, IRON[5])
-- delve: ore cart on the rails, pick leaning on the post
local cart = poly{{421, 202}, {444, 202}, {441, 212}, {424, 212}}; c:rim(cart, INK)
tex(cart, function(x, y) if y == 202 then return IRON[5] end; if y >= 210 then return IRON[2] end; return x < 428 and IRON[4] or x > 439 and IRON[3] or ((y + x) % 7 == 0 and "#8a5a3a" or IRON[3]) end)
for _, wx in ipairs{427, 438} do local w = c:ellipse(wx, 213, 2, 2); c:rim(w, INK); c:fillMask(w, IRON[5]); P(wx, 213, IRON[1]) end
for i = 0, 6 do local x = 423 + i * 3; local m = poly{{x, 202}, {x + 4, 202}, {x + 2, 198 - (i % 3)}}; c:rim(m, INK); c:fillMask(m, i % 2 == 0 and VIOLET[5] or GOLD[5]); P(x + 1, 200 - (i % 3), i % 2 == 0 and VIOLET[6] or GOLD[6]) end
for k = 0, 14 do P(453 + floor(k * .35), 213 - k, k % 2 == 0 and TIMB[5] or TIMB[3]); P(454 + floor(k * .35), 213 - k, TIMB[2]) end
for k = 0, 6 do P(451 + k, 197 - floor(k * .3), IRON[5]); P(451 + k, 198 - floor(k * .3), INK) end; P(450, 198, IRON[4]); P(458, 199, IRON[3])
-- warm glow from lantern, stove flame, gate lantern
S.glow(391, 112, 9, "#ffd066", .35); S.glow(239, 137, 9, "#ffb347", .35); S.glow(221, 163, 12, "#ff9a4c", .3, {206, 148, 236, 178}); S.glow(285, 202, 11, "#ffd066", .4); S.glow(319, 248, 8, "#ffd066", .3)
-- rim light on stone, hedge, and wood tops (upper-left key)
for y = 166, 214 do for x = 392, 468 do if is(x, y, STN) and c:get(x, y - 1) == STONE[1]:lower() then P(x, y, STONE[6]) end end end
for y = 100, 262 do for x = 0, 16 do if is(x, y, GRASS) and c:get(x, y - 1) == GREEN[1]:lower() then P(x, y, GREEN[6]) end end end
for y = 100, 220 do for x = 462, 479 do if is(x, y, GRASS) and c:get(x, y - 1) == GREEN[1]:lower() then P(x, y, GREEN[6]) end end end
-- more plant kinds: ferns and reeds beside the paths
local function fern(x, y) for k = -3, 3 do P(x + k, y - 3 + abs(k), GREEN[k % 2 == 0 and 5 or 4]); P(x + k, y - 2 + abs(k), GREEN[3]) end P(x, y, GREEN[2]); P(x, y - 1, GREEN[3]); P(x, y - 4, GREEN[6]) end
local function reed(x, y) for k = 0, 8 do P(x + (k > 5 and 1 or 0), y - k, GREEN[k > 5 and 5 or 3]) end P(x + 1, y - 9, TIMB[4]); P(x + 1, y - 10, TIMB[3]); P(x + 1, y - 8, TIMB[3]); P(x - 1, y - 3, GREEN[4]); P(x + 2, y - 4, GREEN[4]) end
for i = 0, 36 do local x, y = floor(hash(i, 11, 55) * 470) + 4, 112 + floor(hash(i, 12, 55) * 140)
  if is(x, y, GRASS) and is(x + 3, y, GRASS) and is(x - 3, y, GRASS) and is(x, y - 10, GRASS) then if i % 2 == 0 then fern(x, y) else reed(x, y) end end end
c:save{ aseprite = OUT .. "yard-pals.aseprite", png = OUT .. "yard-pals.png" }
print("ok")

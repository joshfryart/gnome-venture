---------------------------------------------------------------- kinds (parameterised by p)
local K = {}
local function dopts(p, extra)
  local o = { shape = p.shape, x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = p.f or 4, frame = p.frame, wood = p.wood, seed = p.seed or 2, pw = p.pw or 7, blocks = p.blocks, woven = p.woven, straps = p.straps, kx = 255, ky = 186 }
  for k, v in pairs(extra or {}) do o[k] = v end
  return o
end
local function drawDoor(p, o)
  local m = door(o)
  if p.ov then OV[p.ov](o, m, p.ova) end
  knob(o.kx, o.ky)
  return m
end
local function props(p) for _, pr in ipairs(p.props or {}) do PR[pr[1]](pr[2], pr[3], pr[4], pr[5], pr[6]) end end
local function lan(p) lantern(300, 120, p.post and { post = { p.post, 206 } } or nil) end
local function ground(p, n, fl, avoid)
  for i = 1, n do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), p.tuft or GREEN) end
  flowers(p.nfl or 12, p.fseed or 12, 210, 266, fl or { "#f0809c", "#ffd24a", "#fff2dc" }, avoid or function(x) return x > 190 and x < 290 end)
end

K.cottage = function(p)
  for y = 60, 205 do for x = 0, 479 do
    local n = vn(x, y, 6, 3) * .5 + vn(x, y, 2.3, 9) * .5
    local v = .64 + (n - .5) * .4 - (y - 70) / 136 * .1 + (hash(x, y, 2) > .96 and .1 or 0)
    P(x, y, p.wall[GX.idx(v, { .2, .35, .5, .6, .8 })])
  end end
  local B = p.beam or TIMB
  local function beam(m) c:rim(m, INK); S.obj(m, B, { base = 4, lit = 1, shade = 1 }); S.planks(m, B, { w = 99, vert = false, base = 4, seed = 2 }) end
  for _, x in ipairs{ 0, 100, 392, 470 } do beam(rect(x, 66, x + 8, 196)) end
  beam(rect(0, 66, 479, 76)); beam(rect(0, 186, 479, 193))
  for _, b in ipairs{ { 108, 80, 130, 106 }, { 392, 80, 372, 106 }, { 8, 180, 34, 150 }, { 470, 180, 444, 150 } } do
    local bm = c:line({ { b[1], b[2] }, { b[3], b[4] } }, 4); c:rim(bm, INK); S.obj(bm, B, { base = 4, lit = 1, shade = 1 })
  end
  stones(function(x, y) return y >= 194 and y <= 205 end, 0, 194, 479, 205, STONE, { rh = 6, seed = 4, wmin = 9 })
  local rm = HP.mask()
  for x = 0, 479 do local yb = 63 + floor(3 * sin(x / 7) + 2 * sin(x / 3.3 + 1)); for y = 0, yb do rm:set(x, y) end end
  rm:each(function(x, y)
    local row0 = floor((y + 1.8 * sin(x / 6 + floor(y / 11) * 1.7)) / 11)
    local t = (y + floor(2 * sin(x / 6 + row0 * 1.7))) % 11
    local v = .55 + (hash(x // 1, row0, 6) - .5) * .35 + (vn(x, y, 4, 7) - .5) * .25 - x / 480 * .1
    if t < 2 then v = v - .32 elseif t >= 8 then v = v + .18 end
    if hash(x, y // 3, 8) > .9 then v = v - .15 end
    P(x, y, p.roof[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 64, 67 do for x = 0, 479 do local cur = c:get(x, y); if cur and not rm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .4 - (y - 64) * .08)) end end end
  grass(function(x) return 206 + floor(sin(x / 30) * 1.2) end, GREEN, 5)
  local pm = HP.mask()
  for y = 206, 269 do local hw = 30 + (y - 206) * .5; for x = floor(240 - hw), floor(240 + hw) do pm:set(x, y) end end
  stones(function(x, y) return pm:has(x, y) end, 190, 206, 290, 269, STONE, { rh = 8, seed = 11, wmin = 9, wvar = 10, shade = function(x, y) return -1 end })
  window(130, 116, 166, 152, p.shut, true, p.box1); window(372, 116, 408, 152, p.shut, true, p.box2)
  step(204, 276, 205, STONE)
  drawDoor(p, dopts(p))
  plate(240, 84, p.plate)
  ground(p, 26)
  for x = 20, 96, 11 do tuft(x, 204, GREEN) end
  props(p)
  lan(p)
end

K.burrow = function(p)
  sky({ "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#e0f0f2" }, 2, 200)
  c:cloud(40, 66, 54, "#f8f0e0", "#d6e6f0"); c:cloud(380, 44, 44, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 150 + 10 * sin(x / 40) + 5 * sin(x / 15) end, p.far or { "#3c6e5a", "#4c8068", "#6a9c7c", "#86b494", "#a4cca8", "#bcdcb4" }, 215, 3)
  grass(function(x) return 207 + floor(sin(x / 25) * 1.2) end, GREEN, 4)
  local HR = p.hill or GREEN
  local hm = HP.mask()
  for y = 40, 214 do for x = 20, 460 do if ((x - 240) / 222) ^ 2 + ((y - 215) / 172) ^ 2 <= 1 then hm:set(x, y) end end end
  hm = GX.rough(hm, 5, 1)
  c:rim(hm, INK)
  hm:each(function(x, y)
    local nx, ny = (x - 240) / 222, (y - 215) / 172
    local nz = sqrt(max(0, 1 - nx * nx - ny * ny))
    local v = .5 + (-nx * .35 - ny * .3 + nz * .25) + (vn(x, y, 7, 4) - .5) * .3
    if hash(x, y // 4, 3) > .93 then v = v - .12 end
    P(x, y, HR[GX.idx(v)])
  end)
  for i = 1, 240 do
    local x, y = 30 + floor(hash(i, 1, 9) * 420), 56 + floor(hash(i, 2, 9) * 146)
    if hm:has(x, y) and hm:has(x, y - 2) and free(x, y) then P(x, y, HR[6]); P(x, y + 1, HR[3]) end
  end
  for _, x in ipairs{ 210, 268 } do local pm = rect(x, 64, x + 2, 100); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 }) end
  local bar = rect(208, 70, 272, 73); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  plate(240, 84, p.plate, { w = 40 })
  local o = dopts(p, { x0 = 207, y0 = 135, x1 = 272, y1 = 203, f = 5, pw = 8, blocks = true, kx = 256, ky = 186 })
  drawDoor(p, o)
  for x = 206, 274 do if hash(x, 1, 8) > .5 then GX.tuft(c, x, 130 - floor(abs(x - 240) ^ 2 / 60) + 6, R4(HR)) end end
  step(210, 270, 205, STONE, { h = 4 })
  for i = 1, 14 do tuft(floor(hash(i, 1, 6) * 470) + 6, 210 + floor(hash(i, 2, 6) * 56), GREEN) end
  flowers(16, p.fseed or 21, 70, 190, p.fl or { "#f0809c", "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x, y) return (x > 195 and x < 285 and y > 60) or (x > 285 and x < 330 and y < 150) end)
  props(p)
  lan(p)
end

K.treehouse = function(p)
  sky({ "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8" }, 7, 215)
  c:cloud(24, 110, 46, "#f8f0e0", "#d6e6f0"); c:cloud(410, 130, 40, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 172 + 8 * sin(x / 44) + 4 * sin(x / 13) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 215, 5)
  hills(function(x) return 190 + 6 * sin(x / 31 + 2) end, { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 6)
  grass(function(x) return 207 + floor(sin(x / 28) * 1.3) end, GREEN, 8)
  local tr = p.trunk or OAK
  GX.trunk(c, 150, 326, 30, 208, R4(tr), 4, { moss = { hi = GREEN[5], base = GREEN[4], shade = GREEN[3], deep = GREEN[2] } })
  local F1, F2 = p.fol1 or GREEN, p.fol2 or LEAF
  for _, b in ipairs{ { 30, 34, 72, 40 }, { 130, 24, 84, 34 }, { 250, 20, 90, 34 }, { 370, 30, 84, 38 }, { 450, 40, 56, 34 }, { 70, 52, 56, 22 }, { 230, 44, 70, 24 }, { 400, 54, 56, 20 } } do
    GX.foliage(c, b[1], b[2], b[3], b[4], R4(b[1] % 2 == 0 and F1 or F2), b[1] + 3)
  end
  for _, k in ipairs{ { 168, 120 }, { 310, 190 } } do
    local km = c:ellipse(k[1], k[2], 3, 4); c:rim(km, INK); c:fillMask(km, tr[2]); P(k[1] - 1, k[2] - 2, tr[3])
  end
  local o = dopts(p, { f = 5 })
  local m = drawDoor(p, o)
  for i = 0, 14 do local lx = 213 + floor(i * 3.4); P(lx, 133 + floor(abs(i - 7) / 3), GREEN[4 + i % 2]); P(lx, 132 + floor(abs(i - 7) / 3), GREEN[5]) end
  step(208, 272, 205, TIMB)
  plate(240, 84, p.plate)
  for i = 0, 5 do P(205 + i * 8, 77 + i % 2 * 2, LEAF[4]); P(206 + i * 8, 78 + i % 2 * 2, LEAF[5]) end
  for i = 1, 20 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  for x = 134, 160, 9 do tuft(x, 208, GREEN) end
  flowers(10, p.fseed or 31, 214, 266, p.fl or { "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x) return x > 160 and x < 330 end)
  props(p)
  lan(p)
end

K.hut = function(p)
  local E = p.env
  sky(E.sky, 3, 215)
  c:cloud(30, 70, 46, E.cl[1], E.cl[2]); c:cloud(400, 52, 40, E.cl[1], E.cl[2])
  hills(function(x) return 176 + 8 * sin(x / 60 + 1) end, E.hill, 215, 4)
  grass(function(x) return 207 + floor(sin(x / 22) * 1.2) end, E.grass, 9, { tex = .3 })
  local function banana(bx, by, sc)
    for k = 1, 7 do
      local a = -2.7 + k * .32
      local lm = HP.mask()
      for t = 0, 1, .04 do local px, py = bx + cos(a) * 46 * sc * t, by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t; GX.disc(lm, floor(px), floor(py), max(1, floor(5 * sc * (1 - t) + 1))) end
      c:rim(lm, INK); S.obj(lm, GREEN, { base = (k % 2 == 0) and 4 or 3, lit = 2, shade = 2 })
      for t = 0, 1, .05 do P(floor(bx + cos(a) * 46 * sc * t), floor(by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t), GREEN[6]) end
    end
    local tm = rect(bx - 3, by - 50 * sc, bx + 3, by); c:rim(tm, INK); S.obj(tm, LEAF, { base = 3 })
  end
  if E.side == "banana" then banana(44, 206, 1); banana(436, 206, 1.1)
  elseif E.side == "bush" then for _, bx in ipairs{ 60, 420 } do for _, d in ipairs{ { -16, 14 }, { 14, 14 }, { 0, 20 } } do discPaint(bx + d[1], 190 + d[2] - 14, d[2] + 2, GREEN) end end
  elseif E.side == "rocks" then for _, r in ipairs{ { 60, 206, 26 }, { 96, 206, 16 }, { 430, 206, 30 }, { 392, 206, 14 } } do
      local e = c:ellipse(r[1], r[2] - r[3] // 2, r[3], r[3] // 2 + 4):clip(rect(r[1] - r[3] - 1, 0, r[1] + r[3] + 1, 206)); c:rim(e, INK)
      e:each(function(x, y) local l = lit(x, y, r[1], r[2] - r[3] // 2, r[3]); P(x, y, STONE[l > .4 and 6 or (l > -.1 and 5 or (l > -.5 and 4 or 3))]) end) end
  end
  local W = p.wall or DIRT
  local wm = rect(142, 70, 338, 206)
  wm:each(function(x, y)
    local k = floor((x - 142) / 4)
    local t = 4 + ((hash(k, 1, 3) > .5) and 0 or -1)
    if (x - 142) % 4 == 0 then t = 2 elseif (x - 142) % 4 == 1 then t = t + 1 end
    if (y - 70) % 24 < 3 then t = (y - 70) % 24 == 0 and 6 or 3; if (y - 70) % 24 == 2 then t = 2 end end
    if hash(x, y // 6, 3) > .94 then t = t - 1 end
    if (x - 240) / 98 > .6 then t = t - 1 end
    P(x, y, W[max(1, min(6, t + 1))])
  end)
  c:rim(wm, INK)
  for _, x in ipairs{ 142, 332 } do local pm = rect(x, 70, x + 6, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 1, shade = 2 }); for y = 82, 200, 24 do for xx = x, x + 6 do P(xx, y, TIMB[2]) end end end
  local rm = HP.mask()
  for y = 6, 72 do local t = (y - 6) / 66; local hw = 6 + (t ^ .8) * 132 + floor(2 * sin(y / 5)); for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end end
  for x = 100, 380 do local hw = abs(x - 240); if hw > 100 then for y = 62, 74 do if hash(x, 5, 4) > .2 then rm:set(x, y) end end end end
  rm:each(function(x, y)
    local row = floor((y + 1.6 * sin(x / 5)) / 9); local t = (y + floor(1.6 * sin(x / 5))) % 9
    local s = (x - 240) / 138
    local v = .62 - s * .22 + (hash(x, row, 5) - .5) * .3 + (vn(x, y, 4, 7) - .5) * .2
    if t < 2 then v = v - .3 elseif t >= 6 then v = v + .15 end
    if hash(x, y // 4, 5) > .88 then v = v - .14 end
    P(x, y, p.roof[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .45 - (y - 73) * .1)) end end end
  local fin = c:ellipse(240, 6, 3, 4); c:rim(fin, INK); c:fillMask(fin, p.roof[3])
  step(204, 276, 205, TIMB, { h = 4 })
  drawDoor(p, dopts(p, { woven = p.woven }))
  for y = 138, 202, 16 do for x = DX0 - 4, DX1 + 4, 1 do if x < DX0 or x > DX1 then P(x, y, W[6]); P(x, y + 1, TIMB[2]) end end end
  plate(240, 84, p.plate, { w = 44 })
  for i = 1, 16 do tuft(floor(hash(i, 1, 6) * 470) + 6, 214 + floor(hash(i, 2, 6) * 52), E.tuft) end
  for i = 1, 9 do
    local x, y = 20 + floor(hash(i, 3, 6) * 440), 216 + floor(hash(i, 4, 6) * 48)
    if free(x, y) and not (x > 190 and x < 290) then c:fillMask(rect(x, y, x + 2, y + 1), E.pebble or "#a8906a"); P(x, y, "#c8b088"); P(x, y + 2, "#7a6040") end
  end
  if E.flowers then flowers(12, p.fseed or 17, 212, 266, E.flowers, function(x) return x > 190 and x < 290 end) end
  props(p)
  lan(p)
end

K.stone = function(p)
  sky({ "#a4c8e8", "#b8d4ec", "#cce0f0", "#e0ecf4", "#f0f0ec" }, 6, 215)
  c:cloud(30, 84, 50, "#f8f0e0", "#d6e6f0"); c:cloud(410, 60, 44, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 168 + 10 * sin(x / 50) end, { "#58708a", "#6c88a0", "#84a0b4", "#9cb6c6", "#b4cad4", "#cadce0" }, 215, 3)
  hills(function(x) return 190 + 7 * sin(x / 33 + 1) end, { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 7)
  grass(function(x) return 207 + floor(sin(x / 26) * 1.2) end, GREEN, 10)
  local SR = p.stone or STONE
  local function cyl(x, y) local s = (x - 240) / 100; return (s > .82) and -2 or ((s > .55) and -1 or ((s < -.85) and -1 or 0)) end
  local wm = rect(140, 66, 340, 206)
  c:rim(wm, INK)
  stones(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, SR, { rh = 9, seed = p.sseed or 5, shade = cyl })
  local mo = p.moss or 0
  moss(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, 13, function(x, y) return .56 + mo + (206 - y) / 150 * .22 + ((x < 150 or x > 330) and -.1 or 0) end, 5)
  local rm = HP.mask()
  for y = 12, 72 do local t = (y - 12) / 60; local hw = 5 + (t ^ .9) * 132; for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end end
  c:rim(rm, INK)
  stones(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, p.roof, { rh = 6, seed = 8, wmin = 8, wvar = 6, shade = function(x, y) local s = (x - 240) / 130; return (s > .5) and -1 or ((s < -.2) and 1 or 0) end })
  if p.roofmoss then moss(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, 17, function(x, y) return .66 - (72 - y) / 200 end, 4) end
  local fin = c:ellipse(240, 10, 3, 4); c:rim(fin, INK); c:fillMask(fin, SR[4]); P(239, 8, SR[6])
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#2a1830", .5 - (y - 73) * .12)) end end end
  stones(function(x, y) return y >= 196 and y <= 206 and abs(x - 240) < 114 end, 126, 196, 354, 206, SR, { rh = 6, seed = 20, wmin = 12, shade = function() return -1 end })
  for x = 126, 354 do if abs(x - 240) < 114 then P(x, 195, INK) end end
  step(204, 276, 205, SR)
  local o = dopts(p, { f = 6, blocks = true })
  drawDoor(p, o)
  local sh = o.shape
  moss(function(x, y) local fm = dmask(sh, DX0 - 6, DY0 - 6, DX1 + 6, DY1); return fm:has(x, y) and not dmask(sh, DX0, DY0, DX1, DY1):has(x, y) end, 210, 128, 270, 204, 31, function(x, y) return .6 + (y - 128) / 400 end, 4)
  plate(240, 84, p.plate)
  for i = 1, 18 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  flowers(9, p.fseed or 41, 212, 266, p.fl or { "#c8b8ec", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)
  props(p)
  lan(p)
end

K.boat = function(p)
  sky({ "#8ec4ea", "#a4d4ee", "#bce2f2", "#d4eef6", "#eaf4ee" }, 4, 150)
  c:cloud(44, 80, 52, "#f8f0e0", "#d6e6f0"); c:cloud(396, 56, 46, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 128 + 8 * sin(x / 45) + 3 * sin(x / 12) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 152, 3)
  local WT = { "#1e4a6a", "#2a6a8a", "#3a86a4", "#52a0b8", "#78bccc", "#a8dce0" }
  for y = 146, 269 do for x = 0, 479 do
    local v = .72 - (y - 146) / 124 * .45 + (vn(x, y * 2.2, 10, 3) - .5) * .25
    P(x, y, WT[GX.idx(v, { .2, .36, .5, .62, .8 })])
  end end
  for i = 1, 70 do
    local x, y = floor(hash(i, 1, 5) * 480), 152 + floor(hash(i, 2, 5) * 116)
    if not (x > 130 and x < 350 and y < 242) then for k = 0, 3 + floor(hash(i, 3, 5) * 5) do P(x + k, y, WT[6]) end; for k = 1, 3 do P(x + k + 1, y + 1, WT[2]) end end
  end
  for _, px in ipairs{ 356, 408, 462 } do
    local pm = rect(px, 214, px + 6, 258); c:rim(pm, INK); S.obj(pm, TIMB, { base = 3, lit = 0, shade = 2 })
    for y = 232, 260 do if (y % 4) == 0 then for x = px, px + 6 do P(x, y, TIMB[1]) end end end
    for x = px - 2, px + 8 do P(x, 258, WT[6]); P(x, 259, WT[5]) end
  end
  local dm = rect(344, 200, 479, 214); c:rim(dm, INK)
  dm:each(function(x, y)
    local t
    if y <= 205 then t = ((x // 17 + y) % 2 == 0) and 5 or 4; if (x % 17) == 0 then t = 2 end; if y == 200 then t = 6 end
    elseif y <= 208 then t = 5 else t = (y == 214) and 2 or ((y % 2 == 0) and 3 or 4) end
    if y > 205 and y <= 208 then t = (y == 206) and 6 or 5 end
    if hash(x, y, 3) > .94 then t = max(2, t - 1) end
    P(x, y, TIMB[t])
  end)
  for x = 344, 479 do P(x, 206, TIMB[2]) end
  for _, nx in ipairs{ 360, 394, 430, 466 } do P(nx, 203, TIMB[1]); P(nx + 1, 203, TIMB[2]) end
  local HU = p.hull or SBLUE
  local hm = HP.mask()
  for y = 208, 240 do local inset = floor((y - 208) * .42); for x = 138 + inset, 342 - inset do hm:set(x, y) end end
  c:rim(hm, INK)
  hm:each(function(x, y)
    local t = (y < 214) and 5 or 4
    if y >= 214 and y <= 217 then t = 6 end
    if y > 217 and y < 232 then t = 3 end
    if y >= 232 then t = 2 end
    local s = (x - 240) / 100
    if s > .7 then t = t - 1 end
    if y > 217 and (x % 14) == 0 then t = t - 1 end
    P(x, y, (y >= 214 and y <= 217) and (p.trim or CREAM)[(s > .7) and 4 or 5] or HU[max(1, min(6, t))])
  end)
  for _, px in ipairs{ 170, 210, 270, 310 } do
    local pm = c:ellipse(px, 226, 4, 4); c:rim(pm, INK); c:fillMask(pm, HU[2]); c:fillMask(c:ellipse(px, 226, 3, 3), "#a8d4ec"); P(px - 2, 224, "#e8f4f8"); P(px + 2, 228, "#6aa0c0")
  end
  for x = 130, 350 do if abs(x - 240) < 108 then local cur = c:get(x, 241); if cur then P(x, 241, WT[2]); P(x, 242, WT[3]) end end end
  for x = 150, 330, 4 do P(x, 243, WT[5]); P(x + 1, 243, WT[5]) end
  local tire = HP.mask(); for y = 222, 235 do for x = 338, 345 do tire:set(x, y) end end
  c:rim(tire, INK); tire:each(function(x, y) P(x, y, (x < 341) and "#5a5a6e" or "#34344a") end)
  local CB = p.cabin
  local cm = rect(152, 66, 328, 205); c:rim(cm, INK)
  cm:each(function(x, y)
    local t = 4
    if (y - 66) % 7 == 0 then t = 2 elseif (y - 66) % 7 == 1 then t = 5 end
    if (x - 152) > 160 then t = t - 1 end
    if hash(x, y // 7, 3) > .96 then t = t - 1 end
    P(x, y, CB[max(1, min(6, t))])
  end)
  local ch = rect(274, 28, 288, 60); c:rim(ch, INK); stones(function(x, y) return ch:has(x, y) end, 274, 28, 288, 60, p.chim or BARN, { rh = 5, seed = 4, wmin = 7, wvar = 4 })
  for k, pp in ipairs{ { 280, 20, 4 }, { 286, 10, 5 }, { 294, 0, 6 } } do local sm = c:ellipse(pp[1], pp[2], pp[3], pp[3] - 1); c:rim(sm, INK); c:fillMask(sm, CREAM[5]); P(pp[1] - 1, pp[2] - 1, CREAM[6]) end
  local RB = p.roof
  local rm = HP.mask()
  for y = 46, 69 do local ins = floor((70 - y) * .3); for x = 142 + ins, 338 - ins do rm:set(x, y) end end
  c:rim(rm, INK)
  rm:each(function(x, y)
    local t = (y - 46) // 4
    local col = RB[max(1, min(6, 5 - t))]
    if (x // 9) % 2 == 0 and y > 52 then col = RB[max(1, min(6, 5 - t - 1))] end
    P(x, y, col)
  end)
  for x = 142, 338 do P(x, 69, RB[2]) end
  for y = 70, 73 do for x = 152, 328 do local cur = c:get(x, y); if cur and cur ~= INK then P(x, y, mixc(cur, "#102a30", .4 - (y - 70) * .09)) end end end
  local dk = rect(140, 204, 340, 210); c:rim(dk, INK)
  dk:each(function(x, y) local t = (y == 204) and 6 or ((y >= 209) and 2 or 4); if (x % 15) == 0 and y > 205 then t = 2 end; P(x, y, OAK[t]) end)
  if p.port then
    local pm = c:ellipse(185, 128, 12, 12); c:rim(pm, INK); c:fillMask(pm, GOLD[3])
    local pg = c:ellipse(185, 128, 9, 9); c:rim(pg, GOLD[1]); c:fillMask(pg, SBLUE[4])
    pg:each(function(x, y) if y < 128 then P(x, y, SBLUE[5]) end end)
    for k = 0, 5 do P(180 + k, 124 - k + 3, SBLUE[6]) end
    for x = 177, 193 do P(x, 128, GOLD[2]) end
    for y = 120, 136 do P(185, y, GOLD[2]) end
  end
  if p.ring then
    local lr = c:ellipse(318, 168, 8, 8); lr:cut(c:ellipse(318, 168, 3, 3)); c:rim(lr, INK)
    lr:each(function(x, y) local a = floor((math.atan(y - 168, x - 318) + 3.1416) / .7854); P(x, y, (a % 2 == 0) and "#e8493b" or CREAM[5]) end)
    P(313, 162, "#ff9a8a")
  end
  drawDoor(p, dopts(p, { f = 4 }))
  plate(240, 84, p.plate)
  props(p)
  lan(p)
end

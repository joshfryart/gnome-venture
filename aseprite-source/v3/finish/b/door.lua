-- door.lua: a villager's front door seen straight on, 480x270, six habitats. Param: name=cottage|burrow|treehouse|hut|stone|boat (or all)
-- Run: AppRun -b --script-param name=cottage --script door.lua   -> out/door-<name>.png/.aseprite
-- Contract: door centred (240,170) [x218..261, y136..204], blank name plate at (240,84), lantern at (300,120), basket spot (350,206) left empty.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, sin, cos, sqrt, abs = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs
local INK = "#2b1c26"
local NAME = app.params.name or "cottage"

local function build(name)
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "door-" .. name }
local S = dofile(V3 .. "/tree-yard/common.lua").setup(c)
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, SBLUE, BARN, GOLD, STONE, TEAL, VIOLET, PINK, DIRT, IRON =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.SBLUE, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.DIRT, S.IRON
local hash, rect = S.hash, S.rect
local THATCH = {"#4a3022","#6e4a2a","#946a38","#b88c48","#d4aa5c","#ecc878"}
local function P(x, y, col) c:put(x, y, col) end
local function R4(r) return { hi = r[6], base = r[4], shade = r[3], deep = r[2] } end
local function mixc(a, b, t) return GX.mix(a, b, t) end
local function vn(x, y, sc, s) return GX.vn(x, y, sc, s) end
local function free(x, y) return not (x > 322 and x < 380 and y > 184 and y < 228) end   -- basket zone

---------------------------------------------------------------- shared helpers
local function dmask(shape, x0, y0, x1, y1)
  local m = HP.mask()
  local w = x1 - x0 + 1
  local cx, cy = (x0 + x1 + 1) / 2, (y0 + y1 + 1) / 2
  for y = y0, y1 do for x = x0, x1 do
    local ok = true
    if shape == "round" then ok = ((x + .5 - cx) / (w / 2)) ^ 2 + ((y + .5 - cy) / ((y1 - y0 + 1) / 2)) ^ 2 <= 1
    elseif shape == "arch" then
      local r = w / 2
      if y < y0 + r then ok = (x + .5 - (x0 + r)) ^ 2 + (y + .5 - (y0 + r)) ^ 2 <= r * r end
    end
    if ok then m:set(x, y) end
  end end
  return m
end

-- door: shape rect|arch|round, frame ramp, wood ramp; o.blocks (stone voussoirs), o.straps, o.woven, o.kx,o.ky
local function door(o)
  local f = o.f or 4
  local m = dmask(o.shape, o.x0, o.y0, o.x1, o.y1)
  local fm = (o.shape == "round") and dmask("round", o.x0 - f, o.y0 - f, o.x1 + f, o.y1 + f) or dmask(o.shape, o.x0 - f, o.y0 - f, o.x1 + f, o.y1)
  c:rim(fm, INK)
  local cx, cy = (o.x0 + o.x1) / 2, (o.y0 + o.y1) / 2
  local fr = o.frame
  fm:each(function(x, y)
    if m:has(x, y) then return end
    local l = -((x - cx) * .5 + (y - cy) * .8) / ((o.y1 - o.y0) / 2)
    local t = l > .55 and 5 or (l > -.1 and 4 or 3)
    if o.blocks then
      local a = math.atan(y - cy, x - cx)
      local seg = (a + 3.1416) / (3.1416 / 8)
      local fr2 = seg - floor(seg)
      if fr2 < .09 or fr2 > .93 then t = 1 elseif floor(seg) % 2 == 0 then t = min(6, t + 1) end
    end
    if hash(x, y, o.seed or 1) > .9 then t = max(1, t - 1) end
    P(x, y, fr[t])
  end)
  c:rim(m, fr[1])
  c:fillMask(m, o.wood[4])
  local wd = o.wood
  if o.woven then
    m:each(function(x, y)
      local a, b = floor(x / 3), floor(y / 3)
      local t = ((a + b) % 2 == 0) and 4 or 3
      if (x % 3 == 0 and (a + b) % 2 == 0) or (y % 3 == 0 and (a + b) % 2 == 1) then t = 5 end
      if hash(x, y, 5) > .93 then t = 2 end
      P(x, y, wd[t])
    end)
  else
    S.planks(m, wd, { w = o.pw or 7, base = 4, seed = o.seed or 1 })
  end
  m:each(function(x, y)   -- recessed: shadow from the frame at top and left
    if not m:has(x, y - 1) or not m:has(x, y - 2) then P(x, y, wd[2])
    elseif not m:has(x - 1, y) then P(x, y, wd[3]) end
  end)
  if o.straps then
    for _, sy in ipairs(o.straps) do
      for y = sy, sy + 4 do for x = o.x0, o.x1 do if m:has(x, y) then
        local t = (y == sy) and 5 or ((y >= sy + 3) and 2 or 3)
        P(x, y, IRON[t])
      end end end
      for x = o.x0 + 4, o.x1 - 3, 9 do if m:has(x, sy + 2) then P(x, sy + 2, IRON[6]) end end
    end
  end
  local kx, ky = o.kx or (o.x1 - 8), o.ky or (cy + 6)
  c:fillMask(rect(kx - 2, ky - 2, kx + 2, ky + 2), INK)
  c:fillMask(rect(kx - 1, ky - 1, kx + 1, ky + 1), GOLD[4]); P(kx - 1, ky - 1, GOLD[6]); P(kx + 1, ky + 1, GOLD[2])
  P(kx, ky + 4, INK); P(kx, ky + 5, INK)
  return m
end

local function step(x0, x1, y, ramp, o)
  o = o or {}
  local m = rect(x0, y, x1, y + (o.h or 5))
  c:rim(m, INK)
  for yy = y, y + (o.h or 5) do for x = x0, x1 do
    local t = (yy == y) and 5 or ((yy >= y + (o.h or 5) - 1) and 2 or 4)
    if x == x0 and t > 2 then t = min(6, t + 1) end
    if hash(x, yy, 12) > .92 then t = max(2, t - 1) end
    P(x, yy, ramp[t])
  end end
end

local function plate(cx, cy, ramp, o)   -- blank hanging plate: chains + recessed empty panel
  o = o or {}
  local w, h = o.w or 44, 14
  local x0, y0, x1, y1 = cx - floor(w / 2), cy - 7, cx - floor(w / 2) + w - 1, cy + 6
  for _, x in ipairs{ x0 + 6, x1 - 6 } do
    for y = y0 - 7, y0 - 1 do P(x, y, ((y - y0) % 2 == 0) and IRON[3] or IRON[5]) end
    P(x - 1, y0 - 8, INK); P(x, y0 - 8, IRON[5]); P(x + 1, y0 - 8, INK); P(x, y0 - 9, INK)
  end
  local m = S.rr(x0, y0, x1, y1, 2)
  c:rim(m, INK)
  m:each(function(x, y)
    local t = 4
    if y - y0 < 1 or x - x0 < 1 then t = 6 elseif y1 - y < 1 or x1 - x < 1 then t = 2 elseif y - y0 < 2 then t = 5 elseif y1 - y < 2 then t = 3 end
    P(x, y, ramp[t])
  end)
  local inner = rect(x0 + 4, y0 + 3, x1 - 4, y1 - 3)
  inner:each(function(x, y)
    local t = 3
    if y == y1 - 3 or x == x1 - 4 then t = 5 elseif y == y0 + 3 or x == x0 + 4 then t = 1 end
    P(x, y, ramp[t])
  end)
end

local function lantern(cx, cy, o)   -- hanging lantern + bracket; o.post = wooden post ramp standing on the ground
  o = o or {}
  S.glow(cx, cy + 2, 26, "#ffd070", .5)
  local ax = cx + 12
  if o.post then
    local pm = rect(ax - 1, cy - 22, ax + 2, o.post[2])
    c:rim(pm, INK)
    pm:each(function(x, y) P(x, y, (x == ax - 1) and o.post[1][5] or ((x >= ax + 1) and o.post[1][3] or o.post[1][4])) end)
  else
    c:fillMask(rect(ax - 1, cy - 22, ax + 1, cy - 8), INK)
    c:fillMask(rect(ax, cy - 21, ax, cy - 9), IRON[4])
  end
  for x = cx, ax do P(x, cy - 17, INK); P(x, cy - 16, IRON[4]) end
  P(ax - 1, cy - 15, INK); P(ax - 2, cy - 14, IRON[3]); P(ax - 3, cy - 15, IRON[3])
  for y = cy - 15, cy - 10 do P(cx, y, ((y % 2) == 0) and IRON[3] or IRON[5]) end
  c:fillMask(rect(cx - 2, cy - 11, cx + 2, cy - 9), INK)   -- ring/cap
  c:fillMask(rect(cx - 4, cy - 8, cx + 4, cy + 7), INK)
  c:fillMask(rect(cx - 3, cy - 7, cx + 3, cy + 6), "#ffe08a")
  c:fillMask(rect(cx - 1, cy - 5, cx + 1, cy + 4), "#fff6cc")
  for x = cx - 3, cx + 3 do P(x, cy - 8, IRON[4]); P(x, cy + 6, IRON[3]) end
  P(cx - 3, cy - 7, "#ffe08a"); P(cx + 3, cy + 5, "#e8a840"); P(cx + 3, cy + 4, "#e8a840")
  P(cx - 3, cy - 8, IRON[5]); P(cx, cy + 7, INK); P(cx, cy + 8, IRON[3]); P(cx - 1, cy + 8, INK); P(cx + 1, cy + 8, INK); P(cx, cy + 9, INK)
  P(cx, cy - 7, IRON[3]); P(cx, cy + 5, IRON[3])
end

local function sky(cols, seed, y1)
  GX.bands(c, 0, y1 or 269, cols, seed, .12)
end
local function hills(f, ramp, ybot, seed)
  local m = c:terrain(f, nil, ybot)
  m:each(function(x, y)
    local t = (y - f(x)) / 30
    local v = .78 - t * .35 + (vn(x, y, 9, seed) - .5) * .3
    P(x, y, ramp[GX.idx(v)])
  end)
  for x = 0, 479 do P(x, floor(f(x) + .5), ramp[6]) end
end
local function grass(yfn, ramp, seed, o) GX.ground(c, yfn, R4(ramp), seed, o) end
local function tuft(x, y, ramp) if free(x, y) then GX.tuft(c, x, y, R4(ramp)) end end
local function flowers(n, seed, y0, y1, cols, avoid)
  for i = 1, n do
    local x, y = floor(hash(i, 1, seed) * 470) + 4, y0 + floor(hash(i, 2, seed) * (y1 - y0))
    if free(x, y) and not (avoid and avoid(x, y)) then GX.flower(c, x, y, cols[i % #cols + 1]) end
  end
end
local function stones(inside, x0, y0, x1, y1, R, o)
  o = o or {}
  local rh, seed = o.rh or 9, o.seed or 1
  local row, y = 0, y0
  while y <= y1 do
    local x = x0 - floor(hash(row, 0, seed) * 14)
    while x <= x1 do
      local w = (o.wmin or 10) + floor(hash(x, row, seed + 1) * (o.wvar or 12))
      local b = 3 + floor(hash(x, row, seed + 2) * 3)
      for py = 0, rh - 1 do for px = 0, w - 1 do
        local X, Y = x + px, y + py
        if X >= x0 and X <= x1 and Y <= y1 and inside(X, Y) then
          local sh = o.shade and o.shade(X, Y) or 0
          local t
          if py == rh - 1 or px == w - 1 then t = 2
          elseif (px == 0 or px == w - 2) and (py == 0 or py == rh - 2) then t = 2
          elseif py == 0 or px == 0 then t = b + 1
          elseif py >= rh - 3 or px >= w - 3 then t = b - 1
          else
            t = b
            local hv = hash(X, Y, seed + 7)
            if hv > .93 then t = b - 1 elseif hv < .04 then t = b + 1 end
          end
          P(X, Y, R[max(1, min(6, t + sh))])
        end
      end end
      x = x + w
    end
    y = y + rh; row = row + 1
  end
end
local function moss(inside, x0, y0, x1, y1, seed, thr, sc)
  for y = y0, y1 do for x = x0, x1 do
    if inside(x, y) and vn(x, y, sc or 6, seed) > thr(x, y) then P(x, y, GREEN[2 + floor(hash(x, y, seed) * 3)]) end
  end end
end
local function snail(x, y)   -- (x,y) = bottom-left of the foot
  local body = rect(x, y - 1, x + 7, y)
  body:add(rect(x + 6, y - 3, x + 7, y - 1)):add(c:ellipse(x + 3, y - 3, 3, 3))
  body:add(rect(x + 7, y - 5, x + 7, y - 4)):add(rect(x + 5, y - 5, x + 5, y - 4))
  c:rim(body, INK)
  c:fillMask(rect(x, y - 1, x + 7, y), "#e8cfa4"); c:fillMask(rect(x + 6, y - 3, x + 7, y - 1), "#e8cfa4")
  P(x + 7, y - 4, "#e8cfa4"); P(x + 5, y - 4, "#e8cfa4"); P(x + 7, y - 5, INK); P(x + 5, y - 5, INK)
  local sh = c:ellipse(x + 3, y - 3, 3, 3)
  sh:each(function(xx, yy)
    local l = (xx - x - 3) * -.5 + (yy - y + 3) * -.7
    P(xx, yy, l > 1 and "#f0a868" or (l < -1.5 and "#a8502c" or "#d4783c"))
  end)
  P(x + 3, y - 3, "#7a3420"); P(x + 4, y - 3, "#7a3420"); P(x + 4, y - 4, "#7a3420"); P(x + 2, y - 4, "#7a3420"); P(x + 2, y - 2, "#7a3420")
end
local function mushroom(x, y, r, cap)
  c:fillMask(rect(x, y - 3, x + 1, y), "#f4e6c8"); P(x + 1, y - 3, "#d8c4a0"); P(x + 1, y - 2, "#d8c4a0"); P(x + 1, y - 1, "#d8c4a0")
  local m = rect(x - r, y - 6, x + 1 + r, y - 4); m:add(rect(x - r + 1, y - 7, x + r, y - 7))
  c:rim(m, INK); c:fillMask(m, cap)
  for xx = x - r, x + r + 1 do P(xx, y - 4, mixc(cap, "#3a1020", .35)) end
  P(x - 1, y - 6, "#fff2dc"); P(x + 2, y - 5, "#fff2dc"); P(x - r + 1, y - 5, "#fff2dc")
end
local function window(x0, y0, x1, y1, shut, box, cols)
  local fm = rect(x0 - 3, y0 - 3, x1 + 3, y1 + 3)
  for _, sx in ipairs{ x0 - 13, x1 + 5 } do
    local sm = rect(sx, y0 - 3, sx + 8, y1 + 3)
    c:rim(sm, INK); S.planks(sm, shut, { w = 3, base = 4, seed = sx })
    for yy = y0 + 2, y1 - 2, 4 do for xx = sx + 2, sx + 6 do P(xx, yy, shut[2]) end end
  end
  c:rim(fm, INK); S.obj(fm, TIMB, { base = 4 })
  local gm = rect(x0, y0, x1, y1)
  gm:each(function(x, y) P(x, y, ((y - y0) < (y1 - y0) * .5) and SBLUE[5] or SBLUE[4]) end)
  c:fillMask(rect(x0, (y0 + y1) // 2, x1, (y0 + y1) // 2 + 1), TIMB[3]); c:fillMask(rect((x0 + x1) // 2, y0, (x0 + x1) // 2 + 1, y1), TIMB[3])
  for k = 0, 5 do P(x0 + 2 + k, y0 + 7 - k, SBLUE[6]) end
  for x = x0, x1 do P(x, y1 + 1, TIMB[2]) end
  if box then
    local bm = S.rr(x0 - 6, y1 + 3, x1 + 6, y1 + 12, 1)
    c:rim(bm, INK); S.planks(bm, TIMB, { w = 5, base = 4, seed = 8 })
    for x = x0 - 4, x1 + 4 do
      local h = 3 + floor(hash(x, 1, 4) * 4)
      for k = 0, h do P(x, y1 + 2 - k, GREEN[(k > h - 2) and 5 or 3]) end
    end
    local i = 0
    for x = x0 - 3, x1 + 3, 4 do
      i = i + 1; local fy = y1 - 3 - floor(hash(x, 2, 4) * 4)
      local col = cols[i % #cols + 1]
      P(x, fy, "#ffe38a"); P(x - 1, fy, col); P(x + 1, fy, col); P(x, fy - 1, col); P(x, fy + 1, col)
    end
  end
end

local DX0, DX1, DY0, DY1 = 218, 261, 136, 204

---------------------------------------------------------------- COTTAGE: timber, plaster and thatch, flower boxes, snail
local function cottage()
  for y = 60, 205 do for x = 0, 479 do
    local n = vn(x, y, 6, 3) * .5 + vn(x, y, 2.3, 9) * .5
    local v = .64 + (n - .5) * .4 - (y - 70) / 136 * .1 + (hash(x, y, 2) > .96 and .1 or 0)
    P(x, y, CREAM[GX.idx(v, { .2, .35, .5, .6, .8 })])
  end end
  local function beam(m) c:rim(m, INK); S.obj(m, TIMB, { base = 4, lit = 1, shade = 1 }); S.planks(m, TIMB, { w = 99, vert = false, base = 4, seed = 2 }) end
  for _, x in ipairs{ 0, 100, 392, 470 } do beam(rect(x, 66, x + 8, 196)) end
  beam(rect(0, 66, 479, 76)); beam(rect(0, 186, 479, 193))
  for _, b in ipairs{ { 108, 80, 130, 106 }, { 392, 80, 372, 106 }, { 8, 180, 34, 150 }, { 470, 180, 444, 150 } } do
    local bm = c:line({ { b[1], b[2] }, { b[3], b[4] } }, 4); c:rim(bm, INK); S.obj(bm, TIMB, { base = 4, lit = 1, shade = 1 })
  end
  stones(function(x, y) return y >= 194 and y <= 205 end, 0, 194, 479, 205, STONE, { rh = 6, seed = 4, wmin = 9 })
  -- thatch roof
  local rm = HP.mask()
  for x = 0, 479 do
    local yb = 63 + floor(3 * sin(x / 7) + 2 * sin(x / 3.3 + 1))
    for y = 0, yb do rm:set(x, y) end
  end
  rm:each(function(x, y)
    local row0 = floor((y + 1.8 * sin(x / 6 + floor(y / 11) * 1.7)) / 11)
    local t = (y + floor(2 * sin(x / 6 + row0 * 1.7))) % 11
    local v = .55 + (hash(x // 1, row0, 6) - .5) * .35 + (vn(x, y, 4, 7) - .5) * .25 - x / 480 * .1
    if t < 2 then v = v - .32 elseif t >= 8 then v = v + .18 end
    if hash(x, y // 3, 8) > .9 then v = v - .15 end
    P(x, y, THATCH[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 64, 67 do for x = 0, 479 do local cur = c:get(x, y); if cur and not rm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .4 - (y - 64) * .08)) end end end
  grass(function(x) return 206 + floor(sin(x / 30) * 1.2) end, GREEN, 5)
  -- flagstone path
  local pm = HP.mask()
  for y = 206, 269 do local hw = 30 + (y - 206) * .5; for x = floor(240 - hw), floor(240 + hw) do pm:set(x, y) end end
  stones(function(x, y) return pm:has(x, y) end, 190, 206, 290, 269, STONE, { rh = 8, seed = 11, wmin = 9, wvar = 10, shade = function(x, y) return -1 end })
  window(130, 116, 166, 152, TEAL, true, { "#f0809c", "#ffd24a", "#e8493b", "#c8b8ec" })
  window(372, 116, 408, 152, TEAL, true, { "#ffd24a", "#f5a0c0", "#fff2dc", "#e8493b" })
  step(204, 276, 205, STONE)
  door{ shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, frame = TIMB, wood = BARN, seed = 3, pw = 7, straps = { 150, 186 } }
  snail(207, 204)
  plate(240, 84, TIMB)
  lantern(300, 120, { arm = true })
  for i = 1, 26 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  flowers(14, 12, 210, 266, { "#f0809c", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)
  for x = 20, 96, 11 do tuft(x, 204, GREEN) end
end

---------------------------------------------------------------- BURROW: round door in a grassy hill, mushrooms and a ladybug
local function burrow()
  sky({ "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#e0f0f2" }, 2, 200)
  c:cloud(40, 66, 54, "#f8f0e0", "#d6e6f0"); c:cloud(380, 44, 44, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 150 + 10 * sin(x / 40) + 5 * sin(x / 15) end, { "#3c6e5a", "#4c8068", "#6a9c7c", "#86b494", "#a4cca8", "#bcdcb4" }, 215, 3)
  grass(function(x) return 207 + floor(sin(x / 25) * 1.2) end, GREEN, 4)
  -- the hill
  local hm = HP.mask()
  for y = 40, 214 do for x = 20, 460 do
    if ((x - 240) / 222) ^ 2 + ((y - 215) / 172) ^ 2 <= 1 then hm:set(x, y) end
  end end
  hm = GX.rough(hm, 5, 1)
  c:rim(hm, INK)
  hm:each(function(x, y)
    local nx, ny = (x - 240) / 222, (y - 215) / 172
    local nz = sqrt(max(0, 1 - nx * nx - ny * ny))
    local v = .5 + (-nx * .35 - ny * .3 + nz * .25) + (vn(x, y, 7, 4) - .5) * .3
    if hash(x, y // 4, 3) > .93 then v = v - .12 end
    P(x, y, GREEN[GX.idx(v)])
  end)
  for i = 1, 240 do   -- grass blades
    local x, y = 30 + floor(hash(i, 1, 9) * 420), 56 + floor(hash(i, 2, 9) * 146)
    if hm:has(x, y) and hm:has(x, y - 2) and free(x, y) then P(x, y, GREEN[6]); P(x, y + 1, GREEN[3]) end
  end
  -- sign gantry
  for _, x in ipairs{ 210, 268 } do local pm = rect(x, 64, x + 2, 100); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 }) end
  local bar = rect(208, 70, 272, 73); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  plate(240, 84, OAK, { w = 40 })
  -- door
  local ring = dmask("round", 204 - 6, 135 - 6, 275 + 6, 203 + 6)
  door{ shape = "round", x0 = 207, y0 = 135, x1 = 272, y1 = 203, f = 5, frame = STONE, wood = GOLD, seed = 6, pw = 8, blocks = true, straps = { 150, 183 }, kx = 240, ky = 170 }
  for x = 206, 274 do if hash(x, 1, 8) > .5 then GX.tuft(c, x, 130 - floor(abs(x - 240) ^ 2 / 60) + 6, R4(GREEN)) end end
  step(210, 270, 205, STONE, { h = 4 })
  -- front ground
  for i = 1, 14 do tuft(floor(hash(i, 1, 6) * 470) + 6, 210 + floor(hash(i, 2, 6) * 56), GREEN) end
  flowers(16, 21, 70, 190, { "#f0809c", "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x, y) return (x > 195 and x < 285 and y > 60) or (x > 285 and x < 330 and y < 150) end)
  mushroom(192, 206, 2, "#e8493b"); mushroom(199, 209, 1, "#e8493b"); mushroom(186, 210, 1, "#f5809f")
  -- ladybug on the door ring
  local lx, ly = 262, 138
  c:fillMask(c:ellipse(lx, ly, 2, 2), INK); c:fillMask(c:ellipse(lx, ly, 1, 1), "#e8493b"); P(lx - 1, ly - 1, "#ff9a8a"); P(lx, ly, INK); P(lx + 1, ly, INK); P(lx, ly - 2, INK)
  lantern(300, 120, { post = { TIMB, 206 } })
end

---------------------------------------------------------------- TREEHOUSE: door in a great trunk, rope ladder, shelf fungus
local function treehouse()
  sky({ "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8" }, 7, 215)
  c:cloud(24, 110, 46, "#f8f0e0", "#d6e6f0"); c:cloud(410, 130, 40, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 172 + 8 * sin(x / 44) + 4 * sin(x / 13) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 215, 5)
  hills(function(x) return 190 + 6 * sin(x / 31 + 2) end, { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 6)
  grass(function(x) return 207 + floor(sin(x / 28) * 1.3) end, GREEN, 8)
  local tm = GX.trunk(c, 150, 326, 30, 208, R4(OAK), 4, { moss = { hi = GREEN[5], base = GREEN[4], shade = GREEN[3], deep = GREEN[2] } })
  for _, b in ipairs{ { 30, 34, 72, 40 }, { 130, 24, 84, 34 }, { 250, 20, 90, 34 }, { 370, 30, 84, 38 }, { 450, 40, 56, 34 }, { 70, 52, 56, 22 }, { 230, 44, 70, 24 }, { 400, 54, 56, 20 } } do
    GX.foliage(c, b[1], b[2], b[3], b[4], R4(b[1] % 2 == 0 and GREEN or LEAF), b[1] + 3)
  end
  -- limb stubs and bark knots
  for _, k in ipairs{ { 168, 120 }, { 310, 190 } } do
    local km = c:ellipse(k[1], k[2], 3, 4); c:rim(km, INK); c:fillMask(km, OAK[2]); P(k[1] - 1, k[2] - 2, OAK[3])
  end
  -- door
  door{ shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 5, frame = TIMB, wood = TEAL, seed = 9, pw = 7, straps = { 152, 184 } }
  for i = 0, 14 do local lx = 213 + floor(i * 3.4); P(lx, 133 + floor(abs(i - 7) / 3), GREEN[4 + i % 2]); P(lx, 132 + floor(abs(i - 7) / 3), GREEN[5]) end
  step(208, 272, 205, TIMB)
  plate(240, 84, TIMB)
  for i = 0, 5 do P(205 + i * 8, 77 + i % 2 * 2, LEAF[4]); P(206 + i * 8, 78 + i % 2 * 2, LEAF[5]) end
  -- rope ladder
  local lx = 186
  local ax0, ax1 = lx - 8, lx + 8
  local peg = rect(ax0 - 2, 92, ax1 + 2, 95); c:rim(peg, INK); S.obj(peg, TIMB, { base = 4, lit = 1, shade = 1 })
  for y = 96, 202 do
    local xo = floor(sin(y / 26) * 1.4 + .5)
    for _, rx in ipairs{ lx - 7 + xo, lx + 7 + xo } do P(rx - 1, y, INK); P(rx, y, DIRT[5]); P(rx + 1, y, DIRT[2]) end
    if (y - 96) % 10 == 5 then
      for x = lx - 8 + xo, lx + 8 + xo do P(x, y, INK); P(x, y + 1, (x < lx + xo) and TIMB[5] or TIMB[3]); P(x, y + 2, INK) end
    end
  end
  -- shelf fungus
  for _, f in ipairs{ { 288, 156, 8 }, { 292, 168, 6 }, { 284, 178, 5 } } do
    local fm = c:ellipse(f[1], f[2], f[3], 2); fm:cut(rect(f[1] - f[3] - 1, f[2] - 6, f[1] + f[3] + 1, f[2] - 1))
    fm:cut(rect(f[1] - f[3] - 1, f[2] - 6, f[1] - f[3] - 1, f[2] + 6))
    fm = c:ellipse(f[1], f[2], f[3], 3):clip(rect(f[1] - f[3] - 1, f[2] - 1, f[1] + f[3] + 1, f[2] + 3))
    c:rim(fm, INK); fm:each(function(x, y) P(x, y, (y == f[2] - 1 or y == f[2]) and "#f2a060" or ((y >= f[2] + 2) and "#c4622c" or "#e08040")) end)
    P(f[1] - 2, f[2] - 1, "#ffd8a0"); P(f[1] + 2, f[2] + 1, "#ffd8a0")
  end
  for i = 1, 20 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  for x = 134, 160, 9 do tuft(x, 208, GREEN) end
  flowers(10, 31, 214, 266, { "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x) return x > 160 and x < 330 end)
  lantern(300, 120)
end

---------------------------------------------------------------- HUT: reed wall, straw roof, woven door, chili string
local function hut()
  sky({ "#8ec8e8", "#a8d8ec", "#c4e4ee", "#f0e8cc", "#f8dcb0" }, 3, 215)
  c:cloud(30, 70, 46, "#fff4e0", "#f0d0b0"); c:cloud(400, 52, 40, "#fff4e0", "#f0d0b0")
  hills(function(x) return 176 + 8 * sin(x / 60 + 1) end, { "#a8784c", "#bc8c58", "#d0a468", "#e0bc7c", "#ecd096", "#f4e0ac" }, 215, 4)
  grass(function(x) return 207 + floor(sin(x / 22) * 1.2) end, { "#97754a", "#b8935e", "#d0b078", "#e8d09a", "#f0dcaa", "#f8e8bc" }, 9, { tex = .3 })
  -- banana plants
  local function banana(bx, by, sc)
    for k = 1, 7 do
      local a = -2.7 + k * .32
      local lm = HP.mask()
      for t = 0, 1, .04 do
        local px, py = bx + cos(a) * 46 * sc * t, by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t
        GX.disc(lm, floor(px), floor(py), max(1, floor(5 * sc * (1 - t) + 1)))
      end
      c:rim(lm, INK); S.obj(lm, GREEN, { base = (k % 2 == 0) and 4 or 3, lit = 2, shade = 2 })
      for t = 0, 1, .05 do P(floor(bx + cos(a) * 46 * sc * t), floor(by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t), GREEN[6]) end
    end
    local tm = rect(bx - 3, by - 50 * sc, bx + 3, by); c:rim(tm, INK); S.obj(tm, LEAF, { base = 3 })
  end
  banana(44, 206, 1); banana(436, 206, 1.1)
  -- walls: woven reed
  local wm = rect(142, 70, 338, 206)
  wm:each(function(x, y)
    local k = floor((x - 142) / 4)
    local t = 4 + ((hash(k, 1, 3) > .5) and 0 or -1)
    if (x - 142) % 4 == 0 then t = 2 elseif (x - 142) % 4 == 1 then t = t + 1 end
    if (y - 70) % 24 < 3 then t = (y - 70) % 24 == 0 and 6 or 3; if (y - 70) % 24 == 2 then t = 2 end end
    if hash(x, y // 6, 3) > .94 then t = t - 1 end
    local s = (x - 240) / 98
    if s > .6 then t = t - 1 end
    P(x, y, DIRT[max(1, min(6, t + 1))])
  end)
  c:rim(wm, INK)
  for _, x in ipairs{ 142, 332 } do local pm = rect(x, 70, x + 6, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 1, shade = 2 }); for y = 82, 200, 24 do for xx = x, x + 6 do P(xx, y, TIMB[2]) end end end
  -- roof: layered straw
  local rm = HP.mask()
  for y = 6, 72 do
    local t = (y - 6) / 66
    local hw = 6 + (t ^ .8) * 132 + floor(2 * sin(y / 5))
    for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end
  end
  for x = 100, 380 do local hw = abs(x - 240); if hw > 100 then for y = 62, 74 do if hash(x, 5, 4) > .2 then rm:set(x, y) end end end end
  rm:each(function(x, y)
    local row = floor((y + 1.6 * sin(x / 5)) / 9); local t = (y + floor(1.6 * sin(x / 5))) % 9
    local s = (x - 240) / 138
    local v = .62 - s * .22 + (hash(x, row, 5) - .5) * .3 + (vn(x, y, 4, 7) - .5) * .2
    if t < 2 then v = v - .3 elseif t >= 6 then v = v + .15 end
    if hash(x, y // 4, 5) > .88 then v = v - .14 end
    P(x, y, THATCH[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .45 - (y - 73) * .1)) end end end
  local fin = c:ellipse(240, 6, 3, 4); c:rim(fin, INK); c:fillMask(fin, THATCH[3])
  -- details
  local bar = rect(190, 100, 290, 102)
  step(204, 276, 205, TIMB, { h = 4 })
  door{ shape = "rect", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, frame = TIMB, wood = DIRT, woven = true, seed = 2, kx = 255, ky = 178 }
  for y = 138, 202, 16 do for x = DX0 - 4, DX1 + 4, 1 do if x < DX0 or x > DX1 then P(x, y, DIRT[6]); P(x, y + 1, TIMB[2]) end end end
  plate(240, 84, DIRT, { w = 44 })
  -- chili string
  local cx = 180
  for y = 98, 104 do P(cx, y, "#7a5a30") end
  P(cx - 2, 97, INK); P(cx - 1, 97, INK); P(cx, 96, INK); P(cx + 1, 97, INK); P(cx + 2, 97, INK)
  for k = 0, 4 do
    local y = 104 + k * 7
    local colr = (k % 2 == 0) and "#e8493b" or "#f08838"
    c:fillMask(rect(cx - 2 + (k % 2), y, cx + 2 + (k % 2), y + 1), INK)
    c:fillMask(rect(cx - 1 + (k % 2), y, cx + 1 + (k % 2), y + 6), colr); P(cx + (k % 2) - 1, y + 7, INK); P(cx + (k % 2), y + 7, INK); P(cx + (k % 2) - 1, y + 1, "#ffb8a0")
    c:fillMask(rect(cx - 2 + (k % 2), y - 1, cx + 2 + (k % 2), y - 1), "#3f9150")
    P(cx - 2 + (k % 2), y + 1, INK); P(cx - 2 + (k % 2), y + 2, INK); P(cx - 2 + (k % 2), y + 3, INK); P(cx - 2 + (k % 2), y + 4, INK); P(cx - 2 + (k % 2), y + 5, INK); P(cx - 2 + (k % 2), y + 6, INK)
    P(cx + 2 + (k % 2), y + 3, INK); P(cx + 2 + (k % 2), y + 4, INK); P(cx + 1 + (k % 2), y + 5, INK); P(cx + 1 + (k % 2), y + 6, INK)
  end
  for i = 1, 16 do tuft(floor(hash(i, 1, 6) * 470) + 6, 214 + floor(hash(i, 2, 6) * 52), { "#6a502e", "#8a6a34", "#a8863c", "#c2a04a", "#d8b862", "#e8cc7c" }) end
  for i = 1, 9 do
    local x, y = 20 + floor(hash(i, 3, 6) * 440), 216 + floor(hash(i, 4, 6) * 48)
    if free(x, y) and not (x > 190 and x < 290) then c:fillMask(rect(x, y, x + 2, y + 1), "#a8906a"); P(x, y, "#c8b088"); P(x, y + 2, "#7a6040") end
  end
  lantern(300, 120)
end

---------------------------------------------------------------- STONE: round mossy stone house, slate cone roof, frog
local function stonehouse()
  sky({ "#a4c8e8", "#b8d4ec", "#cce0f0", "#e0ecf4", "#f0f0ec" }, 6, 215)
  c:cloud(30, 84, 50, "#f8f0e0", "#d6e6f0"); c:cloud(410, 60, 44, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 168 + 10 * sin(x / 50) end, { "#58708a", "#6c88a0", "#84a0b4", "#9cb6c6", "#b4cad4", "#cadce0" }, 215, 3)
  hills(function(x) return 190 + 7 * sin(x / 33 + 1) end, { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 7)
  grass(function(x) return 207 + floor(sin(x / 26) * 1.2) end, GREEN, 10)
  local function cyl(x, y) local s = (x - 240) / 100; return (s > .82) and -2 or ((s > .55) and -1 or ((s < -.85) and -1 or 0)) end
  local wm = rect(140, 66, 340, 206)
  c:rim(wm, INK)
  stones(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, STONE, { rh = 9, seed = 5, shade = cyl })
  moss(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, 13, function(x, y) return .56 + (206 - y) / 150 * .22 + ((x < 150 or x > 330) and -.1 or 0) end, 5)
  -- roof cone (slate)
  local rm = HP.mask()
  for y = 12, 72 do
    local t = (y - 12) / 60
    local hw = 5 + (t ^ .9) * 132
    for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end
  end
  c:rim(rm, INK)
  stones(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, SBLUE, { rh = 6, seed = 8, wmin = 8, wvar = 6, shade = function(x, y) local s = (x - 240) / 130; return (s > .5) and -1 or ((s < -.2) and 1 or 0) end })
  moss(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, 17, function(x, y) return .66 - (72 - y) / 200 end, 4)
  local fin = c:ellipse(240, 10, 3, 4); c:rim(fin, INK); c:fillMask(fin, STONE[4]); P(239, 8, STONE[6])
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#2a1830", .5 - (y - 73) * .12)) end end end
  -- plinth and ground
  stones(function(x, y) return y >= 196 and y <= 206 and abs(x - 240) < 114 end, 126, 196, 354, 206, STONE, { rh = 6, seed = 20, wmin = 12, shade = function() return -1 end })
  for x = 126, 354 do if abs(x - 240) < 114 then P(x, 195, INK) end end
  -- door (oak, iron, stone voussoirs)
  step(204, 276, 205, STONE)
  door{ shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 6, frame = STONE, wood = OAK, seed = 4, pw = 6, blocks = true, straps = { 150, 184 }, kx = 252, ky = 176 }
  moss(function(x, y) local fm = dmask("arch", DX0 - 6, DY0 - 6, DX1 + 6, DY1); return fm:has(x, y) and not dmask("arch", DX0, DY0, DX1, DY1):has(x, y) end, 210, 128, 270, 204, 31, function(x, y) return .6 + (y - 128) / 400 end, 4)
  plate(240, 84, OAK)
  -- frog on the step end
  local fx, fy = 214, 204
  local fm = c:ellipse(fx, fy - 3, 5, 3):clip(rect(fx - 6, fy - 7, fx + 6, fy))
  fm:add(rect(fx - 4, fy - 7, fx - 3, fy - 6)):add(rect(fx + 3, fy - 7, fx + 4, fy - 6)):add(rect(fx - 6, fy - 1, fx - 4, fy)):add(rect(fx + 4, fy - 1, fx + 6, fy))
  c:rim(fm, INK)
  fm:each(function(x, y) P(x, y, (y >= fy - 1) and "#6fa04a" or ((x < fx) and "#86bc58" or "#5c8e40")) end)
  c:fillMask(rect(fx - 3, fy - 2, fx + 3, fy - 1), "#e8e0a8")
  P(fx - 4, fy - 7, "#f8f0d0"); P(fx + 3, fy - 7, "#f8f0d0"); P(fx - 4, fy - 6, INK); P(fx + 3, fy - 6, INK); P(fx - 1, fy - 4, "#3a6a30"); P(fx + 1, fy - 4, "#3a6a30")
  for i = 1, 18 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  flowers(9, 41, 212, 266, { "#c8b8ec", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)
  lantern(300, 120)
end

---------------------------------------------------------------- BOAT: houseboat door on a dock, water, duck
local function boat()
  sky({ "#8ec4ea", "#a4d4ee", "#bce2f2", "#d4eef6", "#eaf4ee" }, 4, 150)
  c:cloud(44, 80, 52, "#f8f0e0", "#d6e6f0"); c:cloud(396, 56, 46, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 128 + 8 * sin(x / 45) + 3 * sin(x / 12) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 152, 3)
  -- water
  local WT = { "#1e4a6a", "#2a6a8a", "#3a86a4", "#52a0b8", "#78bccc", "#a8dce0" }
  for y = 146, 269 do for x = 0, 479 do
    local v = .72 - (y - 146) / 124 * .45 + (vn(x, y * 2.2, 10, 3) - .5) * .25
    P(x, y, WT[GX.idx(v, { .2, .36, .5, .62, .8 })])
  end end
  for i = 1, 70 do
    local x, y = floor(hash(i, 1, 5) * 480), 152 + floor(hash(i, 2, 5) * 116)
    if not (x > 130 and x < 350 and y < 242) then for k = 0, 3 + floor(hash(i, 3, 5) * 5) do P(x + k, y, WT[6]) end; for k = 1, 3 do P(x + k + 1, y + 1, WT[2]) end end
  end
  -- dock (right): planks on piles
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
  -- hull
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
    P(x, y, (y >= 214 and y <= 217) and CREAM[(s > .7) and 4 or 5] or SBLUE[max(1, min(6, t))])
  end)
  for _, px in ipairs{ 170, 210, 270, 310 } do
    local pm = c:ellipse(px, 226, 4, 4); c:rim(pm, INK); c:fillMask(pm, SBLUE[2]); c:fillMask(c:ellipse(px, 226, 3, 3), "#a8d4ec"); P(px - 2, 224, "#e8f4f8"); P(px + 2, 228, "#6aa0c0")
  end
  for x = 130, 350 do if abs(x - 240) < 108 then local cur = c:get(x, 241); if cur then P(x, 241, WT[2]); P(x, 242, WT[3]) end end end
  for x = 150, 330, 4 do P(x, 243, WT[5]); P(x + 1, 243, WT[5]) end
  local tire = HP.mask()
  for y = 222, 235 do for x = 338, 345 do tire:set(x, y) end end
  c:rim(tire, INK); tire:each(function(x, y) P(x, y, (x < 341) and "#5a5a6e" or "#34344a") end)
  -- cabin
  local cm = rect(152, 66, 328, 205); c:rim(cm, INK)
  cm:each(function(x, y)
    local t = 4
    if (y - 66) % 7 == 0 then t = 2 elseif (y - 66) % 7 == 1 then t = 5 end
    if (x - 152) > 160 then t = t - 1 end
    if hash(x, y // 7, 3) > .96 then t = t - 1 end
    P(x, y, TEAL[max(1, min(6, t))])
  end)
  -- roof and chimney
  local ch = rect(274, 28, 288, 60); c:rim(ch, INK); stones(function(x, y) return ch:has(x, y) end, 274, 28, 288, 60, BARN, { rh = 5, seed = 4, wmin = 7, wvar = 4 })
  for k, p in ipairs{ { 280, 20, 4 }, { 286, 10, 5 }, { 294, 0, 6 } } do local sm = c:ellipse(p[1], p[2], p[3], p[3] - 1); c:rim(sm, INK); c:fillMask(sm, CREAM[5]); P(p[1] - 1, p[2] - 1, CREAM[6]) end
  local rm = HP.mask()
  for y = 46, 69 do local ins = floor((70 - y) * .3); for x = 142 + ins, 338 - ins do rm:set(x, y) end end
  c:rim(rm, INK)
  rm:each(function(x, y)
    local t = (y - 46) // 4
    local col = BARN[max(1, min(6, 5 - t))]
    if (x // 9) % 2 == 0 and y > 52 then col = BARN[max(1, min(6, 5 - t - 1))] end
    P(x, y, col)
  end)
  for x = 142, 338 do P(x, 69, BARN[2]) end
  for y = 70, 73 do for x = 152, 328 do local cur = c:get(x, y); if cur and cur ~= INK then P(x, y, mixc(cur, "#102a30", .4 - (y - 70) * .09)) end end end
  -- deck
  local dk = rect(140, 204, 340, 210); c:rim(dk, INK)
  dk:each(function(x, y) local t = (y == 204) and 6 or ((y >= 209) and 2 or 4); if (x % 15) == 0 and y > 205 then t = 2 end; P(x, y, OAK[t]) end)
  -- porthole window left of the door
  local pm = c:ellipse(185, 128, 12, 12); c:rim(pm, INK); c:fillMask(pm, GOLD[3])
  local pg = c:ellipse(185, 128, 9, 9); c:rim(pg, GOLD[1]); c:fillMask(pg, SBLUE[4])
  pg:each(function(x, y) if y < 128 then P(x, y, SBLUE[5]) end end)
  for k = 0, 5 do P(180 + k, 124 - k + 3, SBLUE[6]) end
  for x = 177, 193 do P(x, 128, GOLD[2]) end
  for y = 120, 136 do P(185, y, GOLD[2]) end
  -- life ring on the right wall
  local lr = c:ellipse(318, 168, 8, 8); lr:cut(c:ellipse(318, 168, 3, 3)); c:rim(lr, INK)
  lr:each(function(x, y) local a = floor((math.atan(y - 168, x - 318) + 3.1416) / .7854); P(x, y, (a % 2 == 0) and "#e8493b" or CREAM[5]) end)
  P(313, 162, "#ff9a8a")
  door{ shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, frame = CREAM, wood = SBLUE, seed = 5, pw = 7, straps = nil, kx = 254, ky = 178 }
  plate(240, 84, OAK)
  -- duck on the deck
  local dxx, dyy = 202, 203
  local body = c:ellipse(dxx, dyy - 3, 5, 3); body:add(rect(dxx + 3, dyy - 8, dxx + 6, dyy - 4)):add(rect(dxx + 7, dyy - 6, dxx + 9, dyy - 5))
  c:rim(body, INK); body:each(function(x, y) P(x, y, (y > dyy - 3) and "#e8b030" or "#ffd84a") end)
  c:fillMask(rect(dxx + 7, dyy - 6, dxx + 9, dyy - 5), "#f08838"); P(dxx + 5, dyy - 7, INK); P(dxx - 3, dyy - 4, "#ffe88a"); P(dxx - 2, dyy - 3, "#c88a20"); P(dxx - 1, dyy - 3, "#c88a20")
  lantern(300, 120)
end

local F = { cottage = cottage, burrow = burrow, treehouse = treehouse, hut = hut, stone = stonehouse, boat = boat }
F[name]()
c:save{ aseprite = d .. "/out/door-" .. name .. ".aseprite", png = d .. "/out/door-" .. name .. ".png", scale = 1 }
end

if NAME == "all" then for _, n in ipairs{ "cottage", "burrow", "treehouse", "hut", "stone", "boat" } do build(n) end else build(NAME) end

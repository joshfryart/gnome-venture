-- door.lua: a villager's front door seen straight on, 480x270, six habitats. Param: name=cottage|burrow|treehouse|hut|stone|boat (or all)
-- Run: AppRun -b --script-param name=cottage --script door.lua   -> out/door-<name>.png/.aseprite
-- Contract: door centred (240,170) [x218..261, y136..204], blank name plate at (240,84), lantern at (300,120), basket spot (350,206) left empty.
local V3 = "/home/user/gnome-venture/aseprite-source/v3"
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, sin, cos, sqrt, abs = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs
local INK = "#2b1c26"
local NAME = app.params.name
local OUT = app.params.out or "./"

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
    elseif shape == "gothic" then
      local H = w * .85
      if y < y0 + H then local t = (y - y0 + .5) / H; ok = abs(x + .5 - (x0 + w / 2)) <= (w / 2) * (t ^ .55) end
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
  if o.ovl then o.ovl(m, o) end
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
local BLUEW = {"#1f2a52","#2f4a8c","#3f6cb4","#5a8fd0","#82b4e4","#b4d6f4"}
local REDW  = {"#4a1426","#7a2230","#b0343a","#d4503f","#ec7a58","#f8a888"}
local VIO   = {"#2c2048","#443272","#6450a0","#8268c4","#a48ae0","#c8b4f4"}
local MOSSR = {"#1f3a34","#2c5444","#3e6e4e","#5a8c5a","#86b06a","#b4d482"}
local function lit(x, y, cx, cy, k) return -((x - cx) * .55 + (y - cy) * .8) / k end   -- >0 = upper-left lit
local function discPaint(cx, cy, r, ramp, rim)
  local m = c:ellipse(cx, cy, r, r); if rim ~= false then c:rim(m, INK) end
  m:each(function(x, y) local l = lit(x, y, cx, cy, r); P(x, y, ramp[l > .6 and 5 or (l > .1 and 4 or (l > -.5 and 3 or 2))]) end)
  return m
end
local function can(x, y)
  c:fillMask(c:ellipse(x + 8, y + 1, 12, 2), "#58803c")
  local sp = c:line({ { x + 12, y - 8 }, { x + 21, y - 17 } }, 2); c:rim(sp, INK); c:fillMask(sp, "#3f8c8c")
  local rose = rect(x + 20, y - 21, x + 24, y - 16); c:rim(rose, INK); c:fillMask(rose, "#7fd0c4")
  local h = c:line({ { x + 3, y - 12 }, { x - 3, y - 10 }, { x - 3, y - 3 }, { x + 1, y - 2 } }, 2); c:rim(h, INK); c:fillMask(h, "#2f7a80")
  local b = rect(x, y - 12, x + 13, y); c:rim(b, INK)
  b:each(function(xx, yy) local t = (xx - x < 3) and "#7fd0c4" or ((xx - x > 9) and "#2f7a80" or "#4fa6a0"); if yy == y - 12 then t = "#a8e8dc" elseif yy >= y - 1 then t = "#2f7a80" end; P(xx, yy, t) end)
  P(x + 1, y - 9, "#fff8dc"); P(x + 5, y - 6, "#2f7a80"); P(x + 6, y - 6, "#2f7a80")   -- a stencilled dot
  P(x + 23, y - 12, "#82b4e4"); P(x + 24, y - 9, "#82b4e4")
end
local function cabbages()
  for _, q in ipairs{ { 60, 228, 8 }, { 88, 236, 7 }, { 114, 226, 8 } } do
    local cx, cy, r = q[1], q[2], q[3]
    local m = c:ellipse(cx, cy, r, r - 1); c:rim(m, INK)
    m:each(function(x, y) local l = lit(x, y, cx, cy, r); local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2); local t = l > .5 and 5 or (l > 0 and 4 or (l > -.5 and 3 or 2)); if d > r - 2.2 then t = min(6, t + 1) end; P(x, y, GREEN[t]) end)
    for a = 3.4, 5.4, .1 do P(floor(cx + cos(a) * (r - 3) + .5), floor(cy + sin(a) * (r - 4) + .5), GREEN[6]) end
    for a = .2, 2, .1 do P(floor(cx + cos(a) * (r - 4) + .5), floor(cy + sin(a) * (r - 4) + .5), GREEN[2]) end
  end
end
local function trellis(x)
  local pm = rect(x, 100, x + 2, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 })
  local bar = rect(x - 9, 108, x + 11, 110); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  for y = 203, 104, -1 do local vx = floor(x + 1 + 5 * math.sin(y / 7)); P(vx - 1, y, INK); P(vx + 1, y, INK); P(vx, y, GREEN[(y % 4 < 2) and 5 or 4]) end
  for y = 196, 112, -14 do
    local vx = floor(x + 1 + 5 * math.sin(y / 7)); local sd = (y % 28 == 0) and 1 or -1
    local lm = c:ellipse(vx + sd * 5, y - 2, 4, 2); c:rim(lm, INK); c:fillMask(lm, LEAF[4]); P(vx + sd * 5 - 1, y - 3, LEAF[6]); P(vx + sd * 6, y - 1, LEAF[2])
  end
  for _, q in ipairs{ { x + 8, 150 }, { x - 12, 172 }, { x + 7, 190 } } do
    local pm2 = rect(q[1], q[2], q[1] + 7, q[2] + 3); pm2:cut(rect(q[1], q[2], q[1], q[2])); c:rim(pm2, INK); c:fillMask(pm2, "#a8e060")
    for k = 1, 5, 2 do P(q[1] + k, q[2] + 1, "#d4f48a"); P(q[1] + k, q[2] + 2, "#6aa838") end
  end
  for _, q in ipairs{ { x - 3, 140 }, { x + 9, 124 } } do P(q[1], q[2], "#fff2dc"); P(q[1] - 1, q[2], "#f8d8e8"); P(q[1] + 1, q[2], "#f8d8e8"); P(q[1], q[2] - 1, "#f8d8e8"); P(q[1], q[2] + 1, "#f8d8e8"); P(q[1], q[2], "#ffd24a") end
end
local function acorn(x, y)
  c:fillMask(c:ellipse(x, y, 7, 2), "#58803c")
  local n = c:ellipse(x, y - 6, 5, 6); c:rim(n, INK)
  n:each(function(xx, yy) local l = lit(xx, yy, x, y - 6, 6); P(xx, yy, l > .4 and "#f0b860" or (l > -.3 and "#d09448" or "#a06a32")) end)
  local cap = rect(x - 6, y - 13, x + 6, y - 9); cap:add(rect(x - 4, y - 15, x + 4, y - 14)); c:rim(cap, INK)
  cap:each(function(xx, yy) local t = ((xx + yy) % 3 == 0) and "#5a3c1c" or "#7a5a30"; if yy <= y - 14 or xx < x - 3 and yy < y - 11 then t = ((xx + yy) % 3 == 0) and "#7a5a30" or "#9a7440" end; P(xx, yy, t) end)
  P(x, y - 17, INK); P(x, y - 16, "#5a3c1c"); P(x - 3, y - 13, "#c8a060")
  local slot = rect(x - 3, y - 6, x + 3, y - 5); c:fillMask(slot, INK)
  local env = rect(x - 2, y - 9, x + 4, y - 6); c:rim(env, INK); c:fillMask(env, "#f8ecd0"); P(x + 1, y - 7, "#e8493b")   -- letter poking out
end
local function chimes(x)
  for y = 76, 84 do P(x, y, "#7a5a30") end
  local bar = rect(x - 9, 85, x + 9, 87); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  for i, dx in ipairs{ -7, -2, 3, 8 } do
    local len = ({ 10, 15, 12, 8 })[i]
    for y = 88, 90 do P(x + dx, y, INK) end
    local tm = rect(x + dx - 1, 91, x + dx + 1, 91 + len); c:rim(tm, INK)
    tm:each(function(xx, yy) P(xx, yy, (xx == x + dx - 1) and "#a8f0e8" or ((xx == x + dx + 1) and "#2f8c94" or "#58c4c0")) end)
    P(x + dx, 92 + len, "#2f8c94")
  end
end
---------------------------------------------------------------- W1: ramps, helpers
local NITE = {"#150f2a","#241a48","#352a68","#4a3c8c","#6e5cb4","#9a88d8"}
local INDG = {"#14143a","#232a68","#34428c","#4a62b0","#7a8ed4","#a8b8ec"}
local ORNG = {"#5a2410","#9a4416","#d4741c","#f0a030","#ffc850","#ffe890"}
local CHZ  = {"#6a4a10","#a87818","#d8a828","#f0c840","#f8de70","#fff0a8"}
local COPPER = {"#3a1a10","#7a3418","#b8602c","#d88848","#f0b070","#ffe0a8"}
local SAND = {"#97754a","#b8935e","#d0b078","#e8d09a","#f0dcaa","#f8e8bc"}
local SANDT = {"#6a502e","#8a6a34","#a8863c","#c2a04a","#d8b862","#e8cc7c"}
local PR, OVL = {}, {}
local GYK = { cottage = 205, burrow = 206, treehouse = 207, hut = 206, stone = 207, boat = 203 }
local function inn(m, x, y) return m:has(x, y) and m:has(x, y - 2) and m:has(x - 1, y) end
local function gsh(x, gy, w) c:ellipse(x, gy, w, 2):each(function(xx, yy) local cur = c:get(xx, yy); if cur and cur ~= INK then P(xx, yy, mixc(cur, "#2a1830", .3)) end end) end
local function bx(x0, y0, x1, y1, ramp)
  local m = rect(x0, y0, x1, y1); c:rim(m, INK)
  m:each(function(x, y) local t = 4
    if y == y0 then t = 6 elseif y == y0 + 1 then t = 5 elseif y >= y1 then t = 2 elseif x >= x1 - 1 then t = 3 elseif x == x0 then t = 5 end
    P(x, y, ramp[t]) end)
  return m
end
local function ball(cx, cy, r, ramp)
  local m = c:ellipse(cx, cy, r, r); c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, cx, cy, r); P(x, y, ramp[l > .6 and 6 or (l > .15 and 5 or (l > -.4 and 4 or 3))]) end)
  return m
end
local function pole(x0, y0, x1, y1, w, ramp)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, w); c:rim(m, INK)
  m:each(function(x, y)
    local cxx = (y1 ~= y0) and (x0 + (x1 - x0) * (y - y0) / (y1 - y0)) or (x0 + x1) / 2
    P(x, y, x < cxx - .5 and ramp[5] or (x > cxx + .5 and ramp[3] or ramp[4]))
  end)
  return m
end
local function leafp(cx, cy, rx, ry, ramp)
  local m = c:ellipse(cx, cy, rx, ry); c:rim(m, INK)
  m:each(function(x, y) P(x, y, (y < cy and x < cx) and ramp[5] or ((y > cy and x >= cx) and ramp[3] or ramp[4])) end)
  return m
end
local function tri(x1, y1, x2, y2, x3, y3, col, rim)
  x1, y1, x2, y2, x3, y3 = floor(x1), floor(y1), floor(x2), floor(y2), floor(x3), floor(y3)
  local m = HP.mask()
  local function sg(px, py, ax, ay, bx_, by_) return (px - bx_) * (ay - by_) - (ax - bx_) * (py - by_) end
  for y = min(y1, y2, y3), max(y1, y2, y3) do for x = min(x1, x2, x3), max(x1, x2, x3) do
    local d1, d2, d3 = sg(x, y, x1, y1, x2, y2), sg(x, y, x2, y2, x3, y3), sg(x, y, x3, y3, x1, y1)
    if not ((d1 < 0 or d2 < 0 or d3 < 0) and (d1 > 0 or d2 > 0 or d3 > 0)) then m:set(x, y) end
  end end
  if rim ~= false then c:rim(m, INK) end
  if col then c:fillMask(m, col) end
  return m
end
local function stem(x0, y0, x1, y1, ramp)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, 1); c:rim(m, INK); c:fillMask(m, (ramp or GREEN)[4])
end
local function clover(cx, cy, s, ramp)
  local m = c:ellipse(cx - s, cy, s, s)
  m:add(c:ellipse(cx + s, cy, s, s)):add(c:ellipse(cx, cy - s, s, s)):add(c:ellipse(cx, cy + s, s, s))
  c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, cx, cy, s * 2); P(x, y, ramp[l > .3 and 5 or (l > -.3 and 4 or 3)]) end)
  P(cx, cy, ramp[2]); P(cx - s, cy - s, ramp[6])
end
local function sflower(cx, cy, r, pet, ctr)
  for k = 0, 7 do local a = k * .785; ball(floor(cx + cos(a) * r * .9 + .5), floor(cy + sin(a) * r * .9 + .5), max(2, floor(r * .45)), pet) end
  ball(cx, cy, floor(r * .62), ctr)
  for k = 0, 5 do local a = k * 1.05; P(floor(cx + cos(a) * r * .3 + .5), floor(cy + sin(a) * r * .3 + .5), ctr[6]) end
end
local function bloom(cx, cy, r, pet, ctr)
  for k = 0, 11 do local a = k * .5236; ball(floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5), max(2, floor(r * .42)), pet) end
  ball(cx, cy, floor(r * .6), ctr)
  for k = 0, 6 do local a = k * .9; P(floor(cx + cos(a) * r * .3 + .5), floor(cy + sin(a) * r * .3 + .5), ctr[6]) end
end
local function bunting(x1, y1, x2, y2, cols)
  local n = 6
  local function ry(x) local t = (x - x1) / (x2 - x1); return floor(y1 + (y2 - y1) * t + sin(t * 3.14159) * 6) end
  for x = x1, x2 do P(x, ry(x) + 1, INK); P(x, ry(x), DIRT[5]) end
  for i = 0, n do
    local fx = floor(x1 + (x2 - x1) * (i + .5) / (n + 1)); local fy = ry(fx) + 2
    tri(fx - 3, fy, fx + 3, fy, fx, fy + 8, cols[i % #cols + 1])
  end
end
local function lamp(cx, cy, style, col)
  col = col or REDW
  local ax = cx + 12
  c:fillMask(rect(ax - 1, cy - 22, ax + 1, cy - 8), INK); c:fillMask(rect(ax, cy - 21, ax, cy - 9), IRON[4])
  for x = cx, ax do P(x, cy - 17, INK); P(x, cy - 16, IRON[4]) end
  for y = cy - 15, cy - 9 do P(cx, y, (y % 2 == 0) and IRON[3] or IRON[5]) end
  if style == "paper" then
    S.glow(cx, cy + 2, 26, "#ffb070", .5)
    local m = c:ellipse(cx, cy, 6, 8); c:rim(m, INK)
    m:each(function(x, y) local l = lit(x, y, cx, cy, 8); P(x, y, col[l > .4 and 6 or (l > -.2 and 5 or 4)]) end)
    for dy = -6, 6, 4 do for x = cx - 6, cx + 6 do if m:has(x, cy + dy) then P(x, cy + dy, col[2]) end end end
    c:fillMask(rect(cx - 2, cy - 10, cx + 2, cy - 8), INK); P(cx - 3, cy - 3, "#fff6cc"); P(cx - 3, cy - 2, "#fff6cc")
    P(cx, cy + 9, INK); P(cx, cy + 10, col[5]); P(cx, cy + 11, col[5]); P(cx, cy + 12, INK)
  elseif style == "orb" then
    S.glow(cx, cy + 2, 26, "#c8a0ff", .5)
    ball(cx, cy, 6, VIO); c:fillMask(c:ellipse(cx, cy, 3, 3), "#f4ecff"); P(cx - 2, cy - 2, "#ffffe8")
    c:fillMask(rect(cx - 4, cy + 6, cx + 4, cy + 7), INK); c:fillMask(rect(cx - 3, cy + 6, cx + 3, cy + 6), IRON[4])
    c:fillMask(rect(cx - 2, cy - 10, cx + 2, cy - 8), INK)
  else   -- jar of fireflies
    S.glow(cx, cy + 2, 26, "#d8ff90", .5)
    local m = rect(cx - 4, cy - 6, cx + 4, cy + 7); c:rim(m, INK)
    m:each(function(x, y) P(x, y, (x < cx - 1) and "#f4ffd0" or ((x > cx + 2) and "#a8d870" or "#d8f890")) end)
    for _, q in ipairs{ { -2, -3 }, { 2, 0 }, { -1, 3 }, { 3, -4 } } do P(cx + q[1], cy + q[2], "#fffbe0"); P(cx + q[1] + 1, cy + q[2], "#f4d848") end
    c:fillMask(rect(cx - 5, cy - 9, cx + 5, cy - 7), INK); c:fillMask(rect(cx - 4, cy - 8, cx + 4, cy - 8), IRON[5])
  end
end

---------------------------------------------------------------- door shapes / finishing
local function DP(p, d)
  local o = {}
  for k, v in pairs(d) do o[k] = v end
  o.shape = p.shape or o.shape; o.frame = p.frame or o.frame; o.wood = p.wood or o.wood
  if p.fw then o.f = p.fw end
  if p.straps ~= nil then o.straps = p.straps and (d.straps or { 150, 186 }) or nil end
  if p.woven ~= nil then o.woven = p.woven end
  if p.blocks ~= nil then o.blocks = p.blocks end
  if p.hw then local cx = (d.x0 + d.x1 + 1) / 2; o.x0 = floor(cx - p.hw); o.x1 = floor(cx + p.hw) - 1 end
  if p.dx0 then o.x0 = p.dx0; o.x1 = p.dx1 end
  if p.dy0 then o.y0 = p.dy0 end
  if p.kx then o.kx = p.kx end
  if p.ky then o.ky = p.ky end
  if p.seed then o.seed = p.seed end
  if p.ov then o.ovl = function(m) local ok, err = pcall(OVL[p.ov], m, p); if not ok then print("OVL ERR " .. p.slug .. ": " .. tostring(err)) end end end
  return o
end
local function FIN(p, DM, ldef)
  local gyk = GYK[p.kind]
  for _, pr in ipairs(p.props or {}) do
    local f, x, gy = PR[pr[1]], pr[2], gyk
    if p.kind == "boat" and x > 345 then gy = 200 end
    if f then local ok, err = pcall(f, x, gy, pr[3]); if not ok then print("PROP ERR " .. p.slug .. " " .. pr[1] .. ": " .. tostring(err)) end
    else print("PROP MISSING " .. pr[1]) end
  end
  local st = p.lant or ((ldef and ldef.post) and "post" or "hang")
  if st == "hang" then lantern(300, 120, ldef) elseif st == "post" then lantern(300, 120, { post = { TIMB, 206 } }) else lamp(300, 120, st, p.lcol) end
end

---------------------------------------------------------------- W1: prop library (x = centre, gy = ground line)
PR.can = function(x, gy) can(x, gy) end
PR.acorn = function(x, gy) acorn(x, gy) end
PR.chimes = function(x) chimes(x) end
PR.mushroom = function(x, gy, col) mushroom(x, gy + 1, 2, col or "#e8493b"); mushroom(x + 7, gy + 3, 1, col or "#e8493b") end

PR.clothesline = function()
  local cols = { { REDW, CREAM }, { TEAL, GOLD }, { BLUEW, ROSE } }
  local function ly(x) return 94 + floor((x - 146) * .08 + sin((x - 146) / 66 * 3.14) * 4) end
  for x = 148, 214 do P(x, ly(x) + 1, INK); P(x, ly(x), CREAM[4]) end
  for i, x in ipairs{ 154, 172, 192 } do
    local y = ly(x) + 2; local cl = cols[i]
    local m = rect(x, y, x + 11, y + 14 + (i % 2) * 3); c:rim(m, INK)
    m:each(function(xx, yy) local k = ((yy - y) // 3) % 2; P(xx, yy, k == 0 and cl[1][4] or cl[2][5]); if yy == y then P(xx, yy, cl[1][6]) end; if xx >= x + 10 then P(xx, yy, cl[1][3]) end end)
    P(x + 1, y - 1, INK); P(x + 9, y - 1, INK)
  end
end
PR.yarn = function(x, gy)
  gsh(x, gy, 15)
  ball(x - 7, gy - 5, 5, REDW); ball(x + 6, gy - 5, 5, TEAL); ball(x - 1, gy - 14, 5, GOLD)
  for k = -3, 3 do P(x - 7 + k, gy - 5 + k // 2, REDW[2]) end
  for k = -3, 3 do P(x + 6 + k, gy - 6 - k // 2, TEAL[2]) end
  local n = c:line({ { x + 3, gy - 15 }, { x + 16, gy - 32 } }, 1); c:rim(n, INK); c:fillMask(n, GOLD[5])
  P(x + 17, gy - 33, ROSE[5]); P(x + 16, gy - 33, INK)
  for k = 0, 9 do P(x + 4 + floor(sin(k / 2) * 2) + k, gy - 5 + k // 2, REDW[4]) end
end
PR.hatpeg = function(x)
  local y = 150
  c:fillMask(rect(x + 2, y, x + 4, y + 3), INK); P(x + 3, y + 1, TIMB[5])
  local dome = c:ellipse(x + 3, y - 5, 5, 4); dome:cut(rect(x - 4, y - 3, x + 10, y + 3)); c:rim(dome, INK)
  dome:each(function(xx, yy) P(xx, yy, (xx < x + 3) and OAK[5] or OAK[3]) end)
  local br = rect(x - 4, y - 3, x + 10, y - 2); c:rim(br, INK); c:fillMask(br, OAK[4])
  for xx = x - 2, x + 8 do P(xx, y - 4, REDW[4]) end
  P(x + 11, y - 9, ROSE[5]); P(x + 10, y - 9, REDW[5]); P(x + 9, y - 8, INK)
end

PR.books = function(x, gy)
  gsh(x, gy, 14)
  local sp = { { VIO, 18, 6 }, { REDW, 15, 5 }, { TEAL, 16, 5 }, { GOLD, 12, 4 } }
  local y = gy
  for i, s in ipairs(sp) do
    local ox = ((i % 2) * 2 - 1) * 2
    local x0, x1 = x - s[2] // 2 + ox, x + s[2] // 2 + ox
    local m = rect(x0, y - s[3], x1, y - 1); c:rim(m, INK)
    m:each(function(xx, yy) local t = 4; if yy == y - s[3] then t = 6 elseif yy >= y - 2 then t = 3 elseif xx == x0 then t = 5 end; P(xx, yy, s[1][t]) end)
    for xx = x1 - 3, x1 do for yy = y - s[3] + 1, y - 2 do P(xx, yy, CREAM[5]) end end
    P(x0 + 2, y - 3, GOLD[5])
    y = y - s[3]
  end
  c:fillMask(rect(x - 1, y - 9, x + 1, y - 1), INK); c:fillMask(rect(x, y - 8, x, y - 2), CREAM[5])
  S.glow(x, y - 12, 11, "#ffd070", .4); P(x, y - 11, "#ffd24a"); P(x, y - 10, "#fff6cc")
end
PR.cauldron = function(x, gy)
  gsh(x, gy, 17)
  for _, lx in ipairs{ x - 9, x + 7 } do c:fillMask(rect(lx - 1, gy - 5, lx + 2, gy), INK); P(lx, gy - 4, IRON[4]) end
  S.glow(x, gy - 16, 24, "#a8ff80", .25)
  local b = c:ellipse(x, gy - 11, 13, 10):clip(rect(x - 14, gy - 22, x + 14, gy - 3)); c:rim(b, INK)
  b:each(function(xx, yy) local l = lit(xx, yy, x, gy - 11, 12); P(xx, yy, IRON[l > .5 and 5 or (l > 0 and 4 or (l > -.5 and 3 or 2))]) end)
  c:fillMask(rect(x - 14, gy - 22, x + 14, gy - 20), INK); c:fillMask(rect(x - 13, gy - 21, x + 13, gy - 21), IRON[5])
  c:fillMask(c:ellipse(x, gy - 22, 11, 2), "#8cf060"); c:fillMask(c:ellipse(x - 2, gy - 22, 6, 1), "#c8ffa0")
  ball(x - 4, gy - 28, 3, GREEN); ball(x + 5, gy - 31, 2, GREEN); ball(x + 1, gy - 36, 2, LEAF)
  P(x - 5, gy - 29, "#e8ffd0")
end
PR.shovel = function(x, gy)
  pole(x + 1, gy - 13, x + 9, gy - 48, 2, TIMB)
  c:fillMask(rect(x + 6, gy - 52, x + 14, gy - 49), INK); c:fillMask(rect(x + 7, gy - 51, x + 13, gy - 50), TIMB[5])
  local bl = c:ellipse(x, gy - 7, 5, 7); c:rim(bl, INK)
  bl:each(function(xx, yy) P(xx, yy, (xx < x) and IRON[5] or IRON[3]) end); P(x - 2, gy - 11, IRON[6]); P(x, gy - 1, INK)
end
PR.dirtmound = function(x, gy)
  local m = c:ellipse(x, gy, 15, 8):clip(rect(x - 16, gy - 9, x + 16, gy + 1)); c:rim(m, INK)
  m:each(function(xx, yy) local l = lit(xx, yy, x, gy, 10); local t = l > .5 and 5 or (l > 0 and 4 or 3); if hash(xx, yy, 3) > .9 then t = t - 1 end; P(xx, yy, OAK[t]) end)
  for _, q in ipairs{ { -5, -3 }, { 4, -5 }, { 9, -1 } } do P(x + q[1], gy + q[2], STONE[5]); P(x + q[1] + 1, gy + q[2], STONE[3]) end
  c:fillMask(rect(x + 8, gy - 14, x + 8, gy - 8), TIMB[4]); tri(x + 9, gy - 14, x + 15, gy - 12, x + 9, gy - 10, REDW[4])
end
PR.wheelbarrow = function(x, gy)
  gsh(x, gy, 18)
  local lines = c:line({ { x + 10, gy - 12 }, { x + 27, gy - 7 } }, 1); c:rim(lines, INK); c:fillMask(lines, TIMB[4])
  c:fillMask(rect(x + 6, gy - 7, x + 8, gy - 1), INK); P(x + 7, gy - 4, TIMB[4])
  local m = HP.mask()
  for yy = gy - 17, gy - 7 do local ins = (yy - (gy - 17)) // 3; for xx = x - 14 + ins, x + 14 - ins do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) local t = 4; if yy == gy - 17 then t = 6 elseif yy >= gy - 9 then t = 3 elseif xx < x - 8 then t = 5 end; P(xx, yy, REDW[t]) end)
  local d = c:ellipse(x, gy - 18, 12, 4):clip(rect(x - 13, gy - 23, x + 13, gy - 17)); c:rim(d, INK); d:each(function(xx, yy) P(xx, yy, OAK[(xx + yy) % 5 == 0 and 5 or 3]) end)
  ball(x - 10, gy - 5, 5, IRON); c:fillMask(c:ellipse(x - 10, gy - 5, 1, 1), GOLD[4])
end

PR.clovers = function(x, gy)
  gsh(x, gy + 2, 17)
  for _, q in ipairs{ { -14, -3, 2 }, { 12, -4, 2 }, { 3, -2, 2 }, { -3, -11, 3 }, { 9, -14, 2 } } do
    if q[2] < -6 then stem(x + q[1], gy + q[2] + 3, x + q[1] + 1, gy, GREEN) end
    clover(x + q[1], gy + q[2], q[3], GREEN)
  end
  for _, q in ipairs{ { -8, -2 }, { 17, -1 } } do P(x + q[1], gy + q[2], CREAM[6]); P(x + q[1] + 1, gy + q[2], ROSE[5]) end
end
PR.thornvine = function(x)
  for y = 206, 116, -1 do
    local vx = floor(x + 5 * sin(y / 9) + .5)
    P(vx - 1, y, INK); P(vx + 1, y, INK); P(vx, y, GREEN[(y % 4 < 2) and 3 or 2])
    if y % 7 == 0 then P(vx + 2, y, IRON[5]); P(vx + 3, y - 1, IRON[6]); P(vx - 2, y - 3, IRON[5]); P(vx - 3, y - 4, IRON[6]) end
    if y % 19 == 0 then ball(vx + 4, y, 2, REDW); P(vx + 3, y - 1, "#ffc8b0") end
  end
end
PR.whistle = function(x)
  for y = 108, 118 do P(x, y, DIRT[4]) end
  P(x - 1, 107, INK); P(x, 106, INK); P(x + 1, 107, INK)
  local m = rect(x - 2, 119, x + 2, 140); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, (xx == x - 2) and IRON[6] or ((xx == x + 2) and IRON[3] or IRON[5])) end)
  for yy = 128, 138, 3 do P(x, yy, INK) end
  c:fillMask(rect(x - 2, 119, x + 2, 121), GOLD[4]); P(x - 2, 119, GOLD[6])
  tri(x + 3, 112, x + 9, 108, x + 8, 116, REDW[4]); tri(x - 3, 112, x - 9, 108, x - 8, 116, REDW[5])
end

PR.buoys = function(x)
  for xx = x - 12, x + 12 do P(xx, 99, INK); P(xx, 100, DIRT[4]) end
  for _, q in ipairs{ { -8, 112, 5, REDW }, { 6, 118, 5, ORNG }, { 15, 108, 4, REDW } } do
    local cx, cy, r = x + q[1], q[2], q[3]
    for yy = 101, cy - r do P(cx, yy, DIRT[4]) end
    local m = ball(cx, cy, r, q[4])
    for xx = cx - r, cx + r do if m:has(xx, cy) or m:has(xx, cy + 1) then P(xx, cy, CREAM[5]); P(xx, cy + 1, CREAM[4]) end end
  end
end
PR.mpot = function(x, gy)
  gsh(x, gy, 10)
  for _, q in ipairs{ { -4, 22 }, { 3, 28 }, { 8, 18 } } do stem(x + q[1], gy - 10, x + q[1], gy - q[2] + 3, GREEN) end
  local pot = HP.mask(); for yy = gy - 10, gy do local ins = (yy - (gy - 10)) // 4; for xx = x - 7 + ins, x + 7 - ins do pot:set(xx, yy) end end
  c:rim(pot, INK); pot:each(function(xx, yy) P(xx, yy, (xx < x - 2) and BARN[5] or ((xx > x + 3) and BARN[3] or BARN[4])) end)
  c:fillMask(rect(x - 8, gy - 12, x + 8, gy - 10), INK); c:fillMask(rect(x - 7, gy - 12, x + 7, gy - 11), BARN[5])
  for _, q in ipairs{ { -4, 22 }, { 3, 28 }, { 8, 18 } } do bloom(x + q[1], gy - q[2], 3, ORNG, ORNG) end
end
PR.sunflowers = function(x, gy)
  gsh(x + 7, gy, 17)
  for _, s in ipairs{ { 0, 62, 8 }, { 15, 48, 7 } } do
    local sx, h, r = x + s[1], s[2], s[3]
    stem(sx, gy - h, sx, gy, GREEN)
    leafp(sx - 6, gy - h // 2, 5, 2, LEAF); leafp(sx + 6, gy - h // 3, 5, 2, LEAF)
    sflower(sx, gy - h, r, GOLD, OAK)
  end
end
PR.bamboo = function(x, gy)
  gsh(x + 8, gy, 17)
  for _, s in ipairs{ { 0, 76 }, { 8, 58 }, { 16, 86 } } do
    local sx, h = x + s[1], s[2]
    local m = rect(sx, gy - h, sx + 3, gy); c:rim(m, INK)
    m:each(function(xx, yy) local t = (xx == sx) and LEAF[6] or ((xx == sx + 3) and LEAF[3] or LEAF[5]); if (gy - yy) % 14 == 0 then t = LEAF[2] end; P(xx, yy, t) end)
    leafp(sx - 6, gy - h + 6, 6, 2, GREEN); leafp(sx + 9, gy - h + 14, 6, 2, GREEN); leafp(sx + 1, gy - h - 4, 2, 5, GREEN)
  end
end
PR.pinwheel = function(x, gy)
  gsh(x, gy, 8)
  local cx, cy = x, gy - 42
  pole(x, cy, x, gy, 1, TIMB)
  local cols = { REDW[4], GOLD[5], TEAL[5], ROSE[5] }
  tri(cx, cy, cx + 11, cy - 1, cx + 11, cy - 11, cols[1]); tri(cx, cy, cx + 1, cy + 11, cx + 11, cy + 11, cols[2])
  tri(cx, cy, cx - 11, cy + 1, cx - 11, cy + 11, cols[3]); tri(cx, cy, cx - 1, cy - 11, cx - 11, cy - 11, cols[4])
  ball(cx, cy, 2, GOLD)
end

PR.easel = function(x, gy)
  gsh(x, gy, 16)
  pole(x, gy - 62, x - 15, gy, 2, TIMB); pole(x, gy - 62, x + 15, gy, 2, TIMB); pole(x + 1, gy - 56, x + 5, gy, 1, TIMB)
  local cv = rect(x - 12, gy - 54, x + 12, gy - 24); c:rim(cv, INK)
  cv:each(function(xx, yy) P(xx, yy, (yy < gy - 40) and "#a8c8ec" or "#8ec47a") end)
  c:fillMask(c:ellipse(x - 5, gy - 46, 4, 4), "#ffd24a"); c:fillMask(rect(x - 12, gy - 40, x + 12, gy - 40), "#6aa458")
  c:fillMask(c:ellipse(x + 5, gy - 33, 8, 3), "#e8798c"); c:fillMask(rect(x + 4, gy - 38, x + 8, gy - 34), "#c84a5c")
  c:fillMask(rect(x - 11, gy - 53, x + 11, gy - 53), CREAM[6])
  bx(x - 14, gy - 24, x + 14, gy - 22, TIMB)
end
PR.paintpots = function(x, gy)
  gsh(x, gy, 17)
  for i, pc in ipairs{ BLUEW, REDW, GOLD } do
    local px = x - 14 + (i - 1) * 12
    bx(px, gy - 10, px + 8, gy - 1, CREAM)
    c:fillMask(rect(px + 1, gy - 9, px + 7, gy - 7), pc[4]); c:fillMask(rect(px + 1, gy - 9, px + 3, gy - 9), pc[6])
    c:fillMask(rect(px - 1, gy - 12, px + 9, gy - 11), INK); c:fillMask(rect(px, gy - 12, px + 8, gy - 12), pc[5])
  end
  local br = c:line({ { x - 12, gy - 12 }, { x - 15, gy - 24 } }, 1); c:rim(br, INK); c:fillMask(br, TIMB[5]); P(x - 15, gy - 25, REDW[4])
  P(x - 16, gy - 26, INK)
end

PR.kettle = function(x, gy)
  gsh(x, gy, 17)
  bx(x - 13, gy - 4, x + 13, gy - 1, STONE)
  local sp = c:line({ { x + 8, gy - 16 }, { x + 19, gy - 28 } }, 2); c:rim(sp, INK); c:fillMask(sp, COPPER[4])
  local hd = c:ellipse(x - 12, gy - 18, 6, 8); hd:cut(c:ellipse(x - 12, gy - 18, 3, 5)); c:rim(hd, INK); c:fillMask(hd, COPPER[3])
  ball(x, gy - 16, 11, COPPER)
  bx(x - 5, gy - 30, x + 5, gy - 26, COPPER); ball(x, gy - 33, 2, COPPER)
  for k = 0, 10 do local sx = x + 21 + floor(sin(k / 2) * 2); P(sx, gy - 30 - k, CREAM[5]); P(sx + 1, gy - 30 - k, CREAM[3]) end
end
PR.teachest = function(x, gy)
  gsh(x, gy, 17)
  local m = bx(x - 13, gy - 16, x + 13, gy - 1, TIMB)
  for yy = gy - 12, gy - 3, 4 do for xx = x - 12, x + 12 do P(xx, yy, TIMB[2]) end end
  c:fillMask(rect(x - 6, gy - 13, x + 6, gy - 5), CREAM[5]); c:fillMask(rect(x - 6, gy - 13, x + 6, gy - 13), CREAM[6]); leafp(x, gy - 9, 3, 2, GREEN)
  bx(x - 14, gy - 20, x + 14, gy - 16, OAK)
  for _, q in ipairs{ { -8, -22 }, { -3, -23 }, { 5, -22 }, { 9, -21 } } do P(x + q[1], gy + q[2], LEAF[4]); P(x + q[1] + 1, gy + q[2] + 1, GREEN[3]) end
end
PR.mugrack = function(x)
  local y = 144
  local m = rect(x - 14, y, x + 14, y + 2); c:rim(m, INK); c:fillMask(m, TIMB[4]); c:fillMask(rect(x - 14, y, x + 14, y), TIMB[6])
  for i, mc in ipairs{ REDW, GOLD, BLUEW } do
    local mx = x - 9 + (i - 1) * 9
    P(mx, y + 3, IRON[5])
    local mm = rect(mx - 3, y + 4, mx + 3, y + 11); c:rim(mm, INK)
    mm:each(function(xx, yy) P(xx, yy, (xx == mx - 3) and mc[6] or ((xx >= mx + 2) and mc[3] or mc[4])) end)
    P(mx + 4, y + 6, INK); P(mx + 5, y + 6, INK); P(mx + 5, y + 7, INK); P(mx + 5, y + 8, INK); P(mx + 4, y + 9, INK)
  end
end

PR.fiddle = function(x)
  local cy = 150
  P(x, 118, INK); P(x - 1, 119, INK); P(x + 1, 119, INK)
  local m = c:ellipse(x, cy - 5, 6, 5); m:add(c:ellipse(x, cy + 5, 7, 6)); m:cut(rect(x - 3, cy - 1, x + 3, cy + 1)); m:add(rect(x - 3, cy - 2, x + 3, cy + 2))
  c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, ((xx + yy) % 7 == 0) and ORNG[2] or ((xx < x) and ORNG[4] or ORNG[3])) end)
  local fb = rect(x - 1, 124, x + 1, cy - 4); c:rim(fb, INK); c:fillMask(fb, IRON[2])
  ball(x, 122, 2, ORNG)
  P(x - 3, cy + 3, INK); P(x + 3, cy + 3, INK); P(x - 3, cy + 4, INK); P(x + 3, cy + 4, INK)
  c:fillMask(rect(x - 4, cy + 10, x + 4, cy + 10), INK); c:fillMask(rect(x, cy - 7, x, cy + 10), CREAM[4])
  local bw = c:line({ { x + 10, 160 }, { x + 18, 134 } }, 1); c:rim(bw, INK); c:fillMask(bw, CREAM[5])
end
PR.fernpot = function(x, gy)
  gsh(x, gy, 14)
  local pot = HP.mask(); for yy = gy - 10, gy do local ins = (yy - (gy - 10)) // 4; for xx = x - 7 + ins, x + 7 - ins do pot:set(xx, yy) end end
  c:rim(pot, INK); pot:each(function(xx, yy) P(xx, yy, (xx < x - 2) and BARN[5] or ((xx > x + 3) and BARN[3] or BARN[4])) end)
  c:fillMask(rect(x - 8, gy - 12, x + 8, gy - 10), INK); c:fillMask(rect(x - 7, gy - 12, x + 7, gy - 11), BARN[5])
  for _, a in ipairs{ { -16, 18 }, { -9, 30 }, { 0, 36 }, { 9, 30 }, { 16, 18 } } do
    local m = c:line({ { x, gy - 12 }, { x + a[1] * .6, gy - 12 - a[2] * .9 }, { x + a[1] * 1.3, gy - 12 - a[2] * .55 } }, 1)
    c:rim(m, INK); c:fillMask(m, LEAF[(a[1] < 0) and 5 or 4])
    for t = 1, 5 do local px, py = x + a[1] * (.15 + t * .2), gy - 12 - a[2] * (.9 - ((t % 3) * .08) - t * .05); P(floor(px), floor(py) - 1, LEAF[6]); P(floor(px), floor(py) + 1, GREEN[3]) end
  end
end
PR.musicstand = function(x, gy)
  gsh(x, gy, 14)
  pole(x - 11, gy, x, gy - 30, 1, IRON); pole(x + 11, gy, x, gy - 30, 1, IRON); pole(x, gy - 40, x, gy - 3, 1, IRON)
  local bd = rect(x - 13, gy - 58, x + 13, gy - 36); c:rim(bd, INK); c:fillMask(bd, TIMB[4]); c:fillMask(rect(x - 13, gy - 58, x + 13, gy - 58), TIMB[6])
  local sh = rect(x - 10, gy - 55, x + 10, gy - 39); c:fillMask(sh, CREAM[5])
  for k = 0, 3 do for xx = x - 9, x + 9 do P(xx, gy - 52 + k * 3, IRON[3]) end end
  for i, q in ipairs{ { -7, 2 }, { -2, 0 }, { 3, 3 }, { 7, 1 } } do local nx, ny = x + q[1], gy - 52 + q[2] * 1 + 1; P(nx, ny, INK); P(nx + 1, ny, INK); P(nx + 1, ny - 1, INK); P(nx + 1, ny - 2, INK); P(nx + 1, ny - 3, INK) end
end

PR.umbrella = function(x, gy)
  gsh(x, gy, 10)
  local top = gy - 50
  pole(x, gy - 30, x, gy - 3, 1, TIMB); P(x + 1, gy - 1, INK); P(x + 2, gy - 1, INK); P(x + 2, gy - 2, INK)
  local m = c:ellipse(x, gy - 32, 22, 17):clip(rect(x - 23, top - 1, x + 23, gy - 30)); c:rim(m, INK)
  m:each(function(xx, yy) local l = lit(xx, yy, x, gy - 32, 20); local t = l > .45 and 6 or (l > 0 and 5 or (l > -.4 and 4 or 3)); if (xx - x) % 8 == 0 then t = max(2, t - 2) end; P(xx, yy, PINK[t]) end)
  for k = -2, 2 do local ex = x + k * 8 + 4; P(ex, gy - 29, INK); P(ex, gy - 30, PINK[2]) end
  c:fillMask(rect(x - 1, top - 3, x + 1, top - 1), INK); P(x, top - 2, GOLD[5])
end
PR.puddle = function(x, gy)
  local yy0 = gy + 12
  local m = c:ellipse(x, yy0, 22, 5); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, ((yy < yy0 - 1) and SBLUE[5]) or SBLUE[4]) end)
  for k = 0, 8 do P(x - 12 + k, yy0 - 2, "#e8f4f8") end; for k = 0, 4 do P(x + 4 + k, yy0, "#e8f4f8") end
  for k = 0, 5 do P(x + 8 + k, yy0 + 2, SBLUE[3]) end; P(x - 9, yy0 + 1, SBLUE[6]); P(x - 3, yy0 + 1, SBLUE[6])
end
PR.barrel = function(x, gy)
  gsh(x, gy, 14)
  local m = rect(x - 10, gy - 26, x + 10, gy - 1); c:rim(m, INK)
  m:each(function(xx, yy) local t = ((xx - x) % 5 == 0) and 3 or 4; if xx < x - 6 then t = 5 elseif xx > x + 6 then t = 3 end; P(xx, yy, TIMB[t]) end)
  for _, by in ipairs{ gy - 22, gy - 5 } do for xx = x - 10, x + 10 do P(xx, by, IRON[4]); P(xx, by + 1, IRON[2]) end end
  c:fillMask(c:ellipse(x, gy - 26, 10, 2), SBLUE[4]); c:fillMask(c:ellipse(x - 2, gy - 27, 5, 1), "#e8f4f8")
  P(x + 11, gy - 12, INK); P(x + 12, gy - 12, IRON[5]); P(x + 12, gy - 11, INK)
end

PR.ivy = function(x)
  for i, s in ipairs{ { 0, 52 }, { 7, 38 }, { 15, 64 } } do
    local vx0, h = x + s[1], s[2]
    for yy = 96, 96 + h do local vx = vx0 + floor(sin(yy / 8 + i) * 1.5 + .5); P(vx - 1, yy, INK); P(vx + 1, yy, INK); P(vx, yy, GREEN[3 + (yy % 2)]) end
    for yy = 104, 96 + h, 11 do local vx = vx0 + floor(sin(yy / 8 + i) * 1.5 + .5); leafp(vx + ((yy // 11) % 2 * 8 - 4), yy, 4, 2, LEAF) end
  end
end
PR.nettle = function(x, gy)
  gsh(x, gy, 17)
  for _, l in ipairs{ { -12, 24 }, { 11, 26 }, { -5, 34 }, { 5, 40 }, { 0, 30 } } do
    local cx = x + l[1]
    tri(cx - 4, gy, cx + 4, gy, cx + l[1] // 3, gy - l[2], GREEN[4])
    for yy = gy - l[2] + 4, gy - 2, 3 do P(cx + (yy - gy) // 6 * 0, yy, GREEN[2]); P(cx - 3, yy, GREEN[6]); P(cx + 4, yy + 1, GREEN[2]) end
  end
  for _, q in ipairs{ { -8, -12 }, { 8, -20 }, { 0, -30 } } do P(x + q[1], gy + q[2], CREAM[6]) end
end

PR.pasta = function(x, gy)
  gsh(x, gy, 20)
  for _, px in ipairs{ x - 18, x + 18 } do local m = rect(px, gy - 36, px + 2, gy - 1); c:rim(m, INK); S.obj(m, TIMB, { base = 4, lit = 0, shade = 1 }) end
  for _, by in ipairs{ gy - 34, gy - 20 } do local b = rect(x - 20, by, x + 22, by + 2); c:rim(b, INK); S.obj(b, TIMB, { base = 4, lit = 1, shade = 1 })
    for xx = x - 16, x + 18, 3 do local l = 10 + floor(hash(xx, by, 3) * 6); for k = 1, l do P(xx, by + 2 + k, (k % 5 == 0) and GOLD[4] or GOLD[5]) end; P(xx, by + 3 + l, INK); P(xx + 1, by + 3, GOLD[3]) end end
end
PR.tomatoes = function(x, gy)
  gsh(x, gy, 17)
  for _, q in ipairs{ { -8, 17 }, { 0, 18 }, { 8, 17 }, { -4, 22 }, { 4, 22 } } do ball(x + q[1], gy - q[2] + 2, 4, REDW); P(x + q[1], gy - q[2] - 2, LEAF[5]); P(x + q[1] - 1, gy - q[2] - 1, GREEN[4]) end
  bx(x - 14, gy - 16, x + 14, gy - 1, TIMB)
  for yy = gy - 11, gy - 4, 5 do for xx = x - 13, x + 13 do P(xx, yy, TIMB[2]) end end
  c:fillMask(rect(x - 5, gy - 13, x + 5, gy - 7), CREAM[5]); P(x - 2, gy - 10, REDW[4]); P(x - 1, gy - 10, REDW[4]); P(x + 1, gy - 10, REDW[4])
end
PR.garlic = function(x)
  c:fillMask(rect(x - 1, 126, x + 1, 128), INK); P(x, 127, REDW[4])
  for i = 0, 4 do
    local by = 132 + i * 8; local bxx = x + ((i % 2) * 2 - 1) * 3
    ball(bxx, by, 4, CREAM); P(bxx, by - 4, INK); P(bxx, by - 5, DIRT[4]); P(bxx - 1, by + 1, ROSE[5])
  end
  for yy = 128, 174 do P(x, yy, REDW[3]) end
  for i = 0, 4 do local by = 132 + i * 8; local bxx = x + ((i % 2) * 2 - 1) * 3; ball(bxx, by, 4, CREAM) end
  c:fillMask(rect(x - 1, 172, x + 1, 176), REDW[4])
end

PR.gong = function(x, gy)
  gsh(x, gy, 20)
  for _, px in ipairs{ x - 17, x + 17 } do local m = rect(px, gy - 52, px + 3, gy - 1); c:rim(m, INK); S.obj(m, TIMB, { base = 4, lit = 0, shade = 1 }) end
  local b = rect(x - 19, gy - 54, x + 21, gy - 51); c:rim(b, INK); S.obj(b, TIMB, { base = 4, lit = 1, shade = 1 })
  for _, hx in ipairs{ x - 7, x + 7 } do for yy = gy - 50, gy - 40 do P(hx, yy, INK) end end
  ball(x, gy - 28, 13, GOLD)
  local r2 = c:ellipse(x, gy - 28, 8, 8); for k = 0, 40 do local a = k * .157; P(floor(x + cos(a) * 8 + .5), floor(gy - 28 + sin(a) * 8 + .5), GOLD[2]) end
  ball(x, gy - 28, 3, GOLD); P(x - 1, gy - 29, GOLD[6])
  local mal = c:line({ { x + 17, gy - 3 }, { x + 26, gy - 3 } }, 1); c:rim(mal, INK); c:fillMask(mal, TIMB[4]); ball(x + 27, gy - 3, 3, REDW)
end
PR.rice = function(x, gy)
  gsh(x, gy, 17)
  local m = HP.mask(); for yy = gy - 30, gy do local ins = (yy - (gy - 30)) * -.16; for xx = floor(x - 14 - ins * 1), floor(x + 14 + ins * 1) do m:set(xx, yy) end end
  c:rim(m, INK)
  m:each(function(xx, yy) local a, b = (xx + 3) // 3, yy // 3; local t = ((a + b) % 2 == 0) and 4 or 3; if xx < x - 8 then t = t + 1 elseif xx > x + 8 then t = t - 1 end; P(xx, yy, DIRT[max(1, min(6, t))]) end)
  c:fillMask(c:ellipse(x, gy - 31, 14, 3), CREAM[5]); c:fillMask(c:ellipse(x - 2, gy - 33, 9, 2), CREAM[6])
  for k = 0, 8 do P(x - 10 + k * 3, gy - 31 + (k % 2), CREAM[4]) end
  c:fillMask(rect(x - 13, gy - 17, x + 14, gy - 15), REDW[4])
end
PR.horns = function()
  for _, sd in ipairs{ -1, 1 } do
    local pts = { { 240 + sd * 136, 76 }, { 240 + sd * 142, 62 }, { 240 + sd * 140, 50 }, { 240 + sd * 132, 44 } }
    local m = c:line(pts, 3); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (yy % 4 == 0) and CREAM[3] or ((sd * (xx - 240) > 139) and CREAM[4] or CREAM[5])) end)
    P(240 + sd * 132, 43, CREAM[6])
  end
end

PR.cheese = function(x, gy)
  gsh(x, gy, 17)
  for _, w in ipairs{ { 0, 0, 14 }, { 4, -10, 11 } } do
    local cx, top = x + w[1], gy + w[2] - 10
    local side = rect(cx - w[3], top, cx + w[3], top + 8); side:add(c:ellipse(cx, top + 8, w[3], 3)); c:rim(side, INK)
    side:each(function(xx, yy) P(xx, yy, (xx < cx - w[3] // 2) and CHZ[5] or ((xx > cx + w[3] // 2) and CHZ[3] or CHZ[4])) end)
    c:fillMask(c:ellipse(cx, top, w[3], 3), CHZ[6]); c:fillMask(c:ellipse(cx + 2, top, 3, 1), CHZ[3]); c:fillMask(c:ellipse(cx - 5, top + 5, 2, 1), CHZ[2])
  end
  tri(x - 3, gy - 28, x + 8, gy - 27, x + 3, gy - 20, CHZ[5]); P(x + 2, gy - 25, CHZ[2])
end
PR.broom = function(x, gy)
  pole(x + 4, gy - 16, x + 12, gy - 52, 2, TIMB)
  local m = HP.mask(); for yy = gy - 18, gy - 1 do local sp = (yy - (gy - 18)) // 3; for xx = x - 3 - sp, x + 9 + sp do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, THATCH[((xx + yy // 2) % 3 == 0) and 3 or ((xx < x + 3) and 5 or 4)]) end)
  c:fillMask(rect(x - 2, gy - 17, x + 8, gy - 14), REDW[4]); c:fillMask(rect(x - 2, gy - 17, x + 8, gy - 17), REDW[5])
end

PR.inkwell = function(x, gy)
  gsh(x, gy, 14)
  bx(x - 8, gy - 11, x + 8, gy - 1, TIMB)
  ball(x - 2, gy - 17, 5, INDG); c:fillMask(rect(x - 3, gy - 23, x - 1, gy - 22), INK); P(x - 2, gy - 23, OAK[5])
  local q = c:line({ { x, gy - 22 }, { x + 11, gy - 46 } }, 2); c:rim(q, INK); c:fillMask(q, CREAM[5])
  tri(x + 3, gy - 30, x + 14, gy - 50, x + 13, gy - 36, CREAM[5]); tri(x + 11, gy - 49, x + 16, gy - 54, x + 14, gy - 45, ROSE[5])
  P(x + 1, gy - 23, INDG[3])
end
PR.sapling = function(x, gy)
  gsh(x, gy, 8)
  local pot = HP.mask(); for yy = gy - 7, gy do local ins = (yy - (gy - 7)) // 4; for xx = x - 5 + ins, x + 5 - ins do pot:set(xx, yy) end end
  c:rim(pot, INK); pot:each(function(xx, yy) P(xx, yy, (xx < x - 1) and BARN[5] or BARN[3]) end)
  stem(x, gy - 8, x, gy - 20, LEAF); leafp(x - 5, gy - 18, 4, 2, LEAF); leafp(x + 5, gy - 21, 4, 2, GREEN); leafp(x, gy - 24, 2, 3, LEAF)
end

PR.bigbrush = function(x, gy)
  gsh(x, gy, 14)
  for i, q in ipairs{ { -4, 48 }, { 2, 36 }, { 7, 42 } } do
    local hx = x + q[1]; local m = rect(hx - 1, gy - q[2], hx + 1, gy - 8); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (xx == hx - 1) and LEAF[5] or ((xx == hx + 1) and LEAF[3] or LEAF[4])) end)
    local bt = c:ellipse(hx, gy - q[2] - 3, 2, 4); c:rim(bt, INK); c:fillMask(bt, IRON[2]); P(hx - 1, gy - q[2] - 5, IRON[5])
  end
  bx(x - 10, gy - 14, x + 10, gy - 1, SBLUE)
  for xx = x - 8, x + 8, 4 do P(xx, gy - 8, CREAM[5]); P(xx + 1, gy - 7, CREAM[5]) end
  for xx = x - 10, x + 10 do P(xx, gy - 14, CREAM[6]) end
end
PR.toro = function(x, gy)
  gsh(x, gy, 14)
  bx(x - 9, gy - 4, x + 9, gy - 1, STONE); bx(x - 3, gy - 20, x + 3, gy - 5, STONE)
  bx(x - 8, gy - 33, x + 8, gy - 20, STONE)
  S.glow(x, gy - 27, 12, "#ffd070", .35)
  c:fillMask(rect(x - 4, gy - 31, x + 4, gy - 23), INK); c:fillMask(rect(x - 3, gy - 30, x + 3, gy - 24), "#ffe08a"); c:fillMask(rect(x - 3, gy - 30, x - 2, gy - 28), "#fff6cc")
  c:fillMask(rect(x, gy - 30, x, gy - 24), INK)
  tri(x - 13, gy - 33, x + 13, gy - 33, x, gy - 45, STONE[4])
  for xx = x - 12, x + 12 do P(xx, gy - 33, STONE[5]) end
  ball(x, gy - 47, 2, STONE)
end

PR.thistles = function(x, gy)
  gsh(x + 8, gy, 17)
  for _, s in ipairs{ { 0, 48 }, { 8, 62 }, { 17, 40 } } do
    local sx, h = x + s[1], s[2]
    stem(sx, gy - h, sx, gy, GREEN)
    tri(sx - 1, gy - 6, sx - 9, gy - 16, sx - 3, gy - 14, GREEN[4]); tri(sx + 1, gy - 12, sx + 9, gy - 22, sx + 3, gy - 20, GREEN[3])
    ball(sx, gy - h, 4, VIO)
    for k = -3, 3 do P(sx + k, gy - h - 5 - (3 - abs(k)) // 2 * 1, VIO[5]) end
    for k = -4, 4, 2 do P(sx + k, gy - h - 6, VIO[6]) end
    leafp(sx, gy - h + 5, 4, 2, GREEN)
  end
end
PR.jars = function(x, gy)
  gsh(x, gy, 17)
  bx(x - 15, gy - 7, x + 15, gy - 1, TIMB)
  for i, col in ipairs{ "#ffd24a", "#f5a0c0", "#a8f0b8" } do
    local jx = x - 12 + (i - 1) * 10
    local m = rect(jx, gy - 22, jx + 7, gy - 8); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (yy < gy - 18) and "#e8f4f8" or ((xx < jx + 2) and "#fff6cc" or col)) end)
    c:fillMask(rect(jx - 1, gy - 25, jx + 8, gy - 23), INK); c:fillMask(rect(jx, gy - 24, jx + 7, gy - 24), IRON[5])
    P(jx + 3, gy - 14, "#fffbe0"); P(jx + 5, gy - 11, "#fffbe0")
    S.glow(jx + 4, gy - 15, 8, col, .22)
  end
end
PR.blueberry = function(x, gy)
  gsh(x, gy, 20)
  local m = c:ellipse(x - 8, gy - 12, 12, 11); m:add(c:ellipse(x + 8, gy - 12, 12, 11)):add(c:ellipse(x, gy - 18, 13, 12)); c:rim(m, INK)
  m:each(function(xx, yy) local l = lit(xx, yy, x, gy - 14, 24); local t = l > .4 and 5 or (l > -.1 and 4 or 3); if hash(xx, yy, 4) > .88 then t = t + 1 end; P(xx, yy, GREEN[min(6, t)]) end)
  for i = 1, 14 do
    local bxx, byy = x - 16 + floor(hash(i, 1, 4) * 32), gy - 28 + floor(hash(i, 2, 4) * 24)
    if m:has(bxx, byy) and m:has(bxx + 1, byy + 1) then c:fillMask(rect(bxx, byy, bxx + 1, byy + 1), BLUEW[3]); P(bxx, byy, BLUEW[5]); P(bxx + 1, byy + 1, BLUEW[1]) end
  end
end
PR.bindle = function(x, gy)
  pole(x, gy - 1, x + 7, gy - 50, 2, TIMB)
  local bl = ball(x + 9, gy - 56, 8, ROSE)
  for _, q in ipairs{ { -3, -3 }, { 3, 0 }, { -1, 4 }, { 4, -5 } } do P(x + 9 + q[1], gy - 56 + q[2], CREAM[6]); P(x + 10 + q[1], gy - 56 + q[2], CREAM[6]) end
  tri(x + 5, gy - 49, x + 13, gy - 49, x + 9, gy - 45, ROSE[3]); P(x + 9, gy - 49, ROSE[6])
end
PR.mossstump = function(x, gy)
  gsh(x, gy, 17)
  local m = rect(x - 12, gy - 14, x + 12, gy - 1); m:add(c:ellipse(x, gy - 1, 12, 3)); c:rim(m, INK)
  m:each(function(xx, yy) local t = (xx < x - 5) and 5 or ((xx > x + 5) and 3 or 4); if (xx + yy // 3) % 6 == 0 then t = t - 1 end; P(xx, yy, OAK[t]) end)
  local top = c:ellipse(x, gy - 15, 13, 5); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, GREEN[(yy < gy - 15) and 5 or 4]) end)
  for k = -10, 10, 3 do local h = 3 + floor(hash(k, 1, 6) * 5); for yy = gy - 14, gy - 14 + h do P(x + k, yy, GREEN[3]) end end
  stem(x + 1, gy - 20, x + 1, gy - 30, LEAF); leafp(x - 4, gy - 30, 4, 2, LEAF); leafp(x + 6, gy - 32, 4, 2, GREEN)
end
PR.plumes = function(x, gy)
  gsh(x, gy, 12)
  for i, q in ipairs{ { -5, -7, 56 }, { 2, 0, 66 }, { 8, 6, 50 } } do
    local x0, y0, x1, y1 = x + q[1] // 2, gy - 14, x + q[1] + q[2] // 2, gy - q[3]
    local pts = { { x0, y0 }, { (x0 + x1) // 2 + 3, (y0 + y1) // 2 }, { x1, y1 } }
    local m = c:line(pts, 4); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, ((yy + xx) % 3 == 0) and CREAM[4] or ((xx < (x0 + x1) / 2) and CREAM[6] or CREAM[5])) end)
    local sh = c:line(pts, 1); c:fillMask(sh, IRON[5])
    P(x1, y1 - 3, VIO[5]); P(x1, y1 - 2, VIO[4])
  end
  local jar = rect(x - 8, gy - 15, x + 8, gy - 1); c:rim(jar, INK)
  jar:each(function(xx, yy) P(xx, yy, (xx < x - 3) and INDG[5] or ((xx > x + 3) and INDG[2] or INDG[3])) end)
  c:fillMask(rect(x - 9, gy - 16, x + 9, gy - 14), INK); c:fillMask(rect(x - 8, gy - 15, x + 8, gy - 15), INDG[5])
  P(x - 4, gy - 10, GOLD[5]); P(x + 2, gy - 6, GOLD[5])
end

PR.bunting = function(x, gy, a) bunting(a[1], a[2], a[3], a[4], a[5]) end

---------------------------------------------------------------- W1: door overlays (painted on the door leaf before the knob)
OVL.stripes = function(m)   -- abuela: poncho weave
  local pal = { REDW[4], GOLD[5], TEAL[4], CREAM[5], REDW[4], BLUEW[4] }
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local k = ((y - 136) // 7) % 6; local col = pal[k + 1]
    if (y - 136) % 7 == 0 then col = mixc(col, "#fff0c0", .3) end
    P(x, y, col)
  end)
  for yy = 150, 196, 14 do for xx = 223, 259, 8 do if m:has(xx, yy) then
    for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do P(xx + d[1], yy + d[2], CREAM[6]) end; P(xx, yy, REDW[3]) end end end
end
OVL.spell = function(m)   -- bram: pentagram ring
  local cx, cy = 240, 170
  for a = 0, 6.283, .02 do P(floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5), GOLD[5]) end
  for a = 0, 6.283, .03 do P(floor(cx + cos(a) * 18 + .5), floor(cy + sin(a) * 18 + .5), (floor(a * 10) % 2 == 0) and VIO[6] or VIO[2]) end
  local pts = {}; for k = 0, 4 do local a = -1.5708 + k * 1.2566; pts[k + 1] = { floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5) } end
  for _, pr in ipairs{ { 1, 3 }, { 3, 5 }, { 5, 2 }, { 2, 4 }, { 4, 1 } } do c:fillMask(c:line({ pts[pr[1]], pts[pr[2]] }, 1), CREAM[6]) end
  for _, q in ipairs{ { 226, 146 }, { 254, 148 }, { 224, 196 }, { 256, 194 } } do P(q[1], q[2], GOLD[6]); P(q[1] - 1, q[2], GOLD[5]); P(q[1] + 1, q[2], GOLD[5]); P(q[1], q[2] - 1, GOLD[5]); P(q[1], q[2] + 1, GOLD[5]) end
end
OVL.studs = function(m)   -- burdock: peephole and brass studs
  for yy = 164, 198, 9 do for xx = 224, 258, 9 do if m:has(xx, yy) and not (xx > 232 and xx < 248 and yy < 168) then
    c:fillMask(rect(xx, yy, xx + 1, yy + 1), INK); P(xx, yy, GOLD[6]); P(xx + 1, yy + 1, GOLD[3]) end end end
  ball(240, 152, 7, IRON); c:fillMask(c:ellipse(240, 152, 4, 4), INK); c:fillMask(c:ellipse(240, 152, 3, 3), "#3a2a4c"); P(238, 150, "#a8c8f0"); P(239, 150, "#a8c8f0")
  for a = 0, 6.283, .8 do P(floor(240 + cos(a) * 6.5 + .5), floor(152 + sin(a) * 6.5 + .5), GOLD[5]) end
end
OVL.clover = function(m)
  clover(240, 164, 7, LEAF)
  stem(240, 172, 238, 198, GREEN); stem(238, 188, 232, 184, GREEN)
  for _, q in ipairs{ { 226, 150 }, { 254, 152 }, { 228, 192 }, { 252, 190 } } do clover(q[1], q[2], 2, GREEN) end
end
OVL.dutch = function(m)
  for x = 218, 261 do if m:has(x, 171) then P(x, 169, INK); P(x, 170, GOLD[5]); P(x, 171, GOLD[3]); P(x, 172, INK) end end
  local cx, cy = 240, 153
  local g = c:ellipse(cx, cy, 10, 10); c:rim(g, GOLD[2])
  g:each(function(x, y) P(x, y, (y < cy - 2) and SBLUE[6] or ((y < cy + 3) and SBLUE[5] or SBLUE[4])) end)
  for k = 0, 6 do P(cx - 7 + k, cy - 3 - k // 2, "#e8f4f8") end
  for a = 0, 6.283, .1 do P(floor(cx + cos(a) * 11 + .5), floor(cy + sin(a) * 11 + .5), GOLD[5]) end
  for x = cx - 9, cx + 9 do P(x, cy, GOLD[3]) end; for y = cy - 9, cy + 9 do P(cx, y, GOLD[3]) end
  for yy = 176, 198, 8 do for x = 222, 258, 12 do if m:has(x, yy) then P(x, yy, ORNG[5]); P(x + 1, yy, ORNG[3]) end end end
end
OVL.sun = function(m)
  for a = 0, 6.283, .3927 do
    local x0, y0, x1, y1 = floor(240 + cos(a) * 15 + .5), floor(166 + sin(a) * 15 + .5), floor(240 + cos(a) * 22 + .5), floor(166 + sin(a) * 22 + .5)
    local l = c:line({ { x0, y0 }, { x1, y1 } }, 1); c:fillMask(l:clip(m), GOLD[6])
  end
  sflower(240, 166, 11, GOLD, OAK)
end
OVL.bamboo = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local k = (x - 218) % 6
    local t = (k == 0) and 6 or ((k == 5) and 2 or ((k == 4) and 3 or 5))
    if (y - 136 + ((x - 218) // 6 % 2) * 7) % 14 == 0 then t = 2 end
    P(x, y, LEAF[t])
  end)
  for _, yy in ipairs{ 160, 186 } do for x = 214, 266 do if m:has(x, yy) then P(x, yy, DIRT[5]); P(x, yy + 1, DIRT[3]) end end end
end
OVL.splat = function(m)   -- indigo: paint on a scarf-mustard stripe
  for _, s in ipairs{ { 218, 168, 262, 172, GOLD[4] }, { 226, 144, 232, 200, "#e8798c" }, { 246, 150, 256, 196, "#7fd0c4" }, { 236, 176, 252, 181, REDW[4] } } do
    local sm = rect(s[1], s[2], s[3], s[4]); c:fillMask(sm:clip(m), s[5])
  end
  for i = 1, 16 do local x, y = 220 + floor(hash(i, 1, 8) * 40), 140 + floor(hash(i, 2, 8) * 60)
    if m:has(x, y) then local cc = ({ "#ffd24a", "#f5a0c0", "#a8f0b8", "#fff6cc" })[i % 4 + 1]; c:fillMask(rect(x, y, x + 1, y + 1), cc) end end
end
OVL.teapot = function(m)
  local cx, cy = 240, 174
  local sp = c:line({ { cx + 8, cy - 3 }, { cx + 17, cy - 12 } }, 2); c:rim(sp, INK); c:fillMask(sp:clip(m), CREAM[5])
  local hd = c:ellipse(cx - 11, cy - 2, 5, 7); hd:cut(c:ellipse(cx - 11, cy - 2, 2, 4)); c:rim(hd, INK); c:fillMask(hd, CREAM[4])
  ball(cx, cy, 11, CREAM)
  bx(cx - 5, cy - 15, cx + 5, cy - 11, CREAM); ball(cx, cy - 18, 2, CREAM)
  for yy = cy - 3, cy + 3, 3 do for xx = cx - 6, cx + 6, 3 do P(xx, yy, ORNG[4]) end end
  for k = 0, 9 do local sx = 252 + floor(sin(k / 2) * 2); if m:has(sx, 150 - k) then P(sx, 152 - k, CREAM[5]) end end
end
OVL.patch = function(m)
  local cols = { LEAF[4], OAK[4], MOSSR[3], GOLD[4], CREAM[5], GREEN[3], ROSE[4], TEAL[4] }
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local gx, gy = (x - 218) // 11, (y - 136) // 11
    local col = cols[floor(hash(gx, gy, 5) * #cols) + 1]
    local ex, ey = (x - 218) % 11, (y - 136) % 11
    if ex == 0 or ey == 0 then col = ((x + y) % 2 == 0) and CREAM[6] or OAK[2]
    elseif ex == 1 or ey == 1 then col = mixc(col, "#fff0c0", .25) end
    P(x, y, col)
  end)
end
OVL.bloom = function(m) bloom(240, 168, 15, ORNG, OAK) end
OVL.shell = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local row = (y - 134) // 10; local ox = (row % 2) * 6
    local ex, ey = (x - 214 + ox) % 12, (y - 134) % 10
    local col = LEAF[4]
    if ex == 0 or ey == 0 then col = TIMB[2] elseif ex == 1 or ey == 1 then col = LEAF[6] elseif ex >= 10 or ey >= 8 then col = LEAF[3] end
    if hash(x // 3, y // 3, 6) > .8 then col = mixc(col, "#2c5a30", .2) end
    P(x, y, col)
  end)
end
OVL.dots = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local row = (y - 136) // 7; local xx = (x - 218 + (row % 2) * 4) % 8; local yy = (y - 136) % 7
    if xx >= 2 and xx <= 4 and yy >= 2 and yy <= 4 and not (xx == 2 and yy == 2) then P(x, y, (yy == 4 or xx == 4) and CREAM[4] or CREAM[6]) end
  end)
  tri(240, 142, 230, 137, 230, 147, CREAM[5]); tri(240, 142, 250, 137, 250, 147, CREAM[4]); ball(240, 142, 2, CREAM)
end
OVL.batik = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local d1, d2 = (x + y) % 14, (x - y) % 14
    if d1 == 0 or d2 == 0 then P(x, y, GOLD[5]) end
  end)
  for _, q in ipairs{ { 231, 150 }, { 249, 150 }, { 240, 170 }, { 231, 190 }, { 249, 190 } } do
    for a = 0, 6.283, .25 do local x, y = floor(q[1] + cos(a) * 5 + .5), floor(q[2] + sin(a) * 5 + .5); if m:has(x, y) then P(x, y, ORNG[4]) end end
    if m:has(q[1], q[2]) then c:fillMask(rect(q[1] - 1, q[2] - 1, q[1] + 1, q[2] + 1), CREAM[5]); P(q[1], q[2], ORNG[3]) end
  end
end
OVL.cheese = function(m)
  for _, h in ipairs{ { 232, 158, 4 }, { 250, 150, 3 }, { 249, 172, 5 }, { 233, 184, 4 }, { 248, 196, 3 }, { 240, 143, 2 } } do
    local hm = c:ellipse(h[1], h[2], h[3], h[3]):clip(m)
    c:fillMask(hm, CHZ[2]); c:fillMask(hm:clip(rect(h[1] - 9, h[2] - 9, h[1] + 9, h[2] - h[3] + 1)), CHZ[1])
    P(h[1] - h[3] + 1, h[2] + h[3] - 1, CHZ[6])
  end
end
OVL.quill = function(m)
  local f = c:line({ { 252, 197 }, { 232, 148 } }, 7); c:rim(f, INK)
  f:each(function(x, y) P(x, y, ((x + y) % 4 == 0) and CREAM[4] or ((x < 242) and CREAM[6] or CREAM[5])) end)
  c:fillMask(c:line({ { 252, 200 }, { 230, 146 } }, 1), INDG[3])
  tri(228, 148, 233, 140, 236, 150, ROSE[5])
  for i = 1, 7 do local x, y = 222 + floor(hash(i, 1, 4) * 36), 176 + floor(hash(i, 2, 4) * 24); if m:has(x, y) and (x < 238 or y > 192) then P(x, y, INDG[3]); P(x + 1, y, INDG[3]) end end
  for k = 0, 16 do if m:has(224 + k * 2, 200 + floor(sin(k) * 2)) then P(224 + k * 2, 200 + floor(sin(k) * 2), GOLD[5]) end end
end
OVL.enso = function(m)
  local cx, cy = 240, 168
  for a = .6, 6.2, .012 do
    local w = 3 - (a - .6) * .35
    for r = 12, 12 + max(1, floor(w + .5)) do local x, y = floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5); if m:has(x, y) then P(x, y, (r == 12 and a > 3) and IRON[3] or INK) end end
    if a > 5 and floor(a * 100) % 3 == 0 then P(floor(cx + cos(a) * 14 + .5), floor(cy + sin(a) * 14 + .5), CREAM[5]) end
  end
  for _, q in ipairs{ { 258, 154 }, { 255, 150 }, { 224, 190 } } do if m:has(q[1], q[2]) then P(q[1], q[2], INK); P(q[1] + 1, q[2], INK) end end
  local hk = rect(250, 190, 256, 197); c:fillMask(hk:clip(m), REDW[4]); c:fillMask(rect(251, 192, 255, 192):clip(m), CREAM[5]); c:fillMask(rect(253, 191, 253, 195):clip(m), CREAM[5])
end
OVL.wings = function(m)
  for _, sd in ipairs{ -1, 1 } do
    for _, w in ipairs{ { 11, 152, 11, 5 }, { 9, 168, 8, 4 } } do
      local wm = c:ellipse(240 + sd * w[1], w[2], w[3], w[4]):clip(m)
      wm:each(function(x, y) P(x, y, (y < w[2]) and SBLUE[6] or SBLUE[5]) end)
      for k = -2, 2 do local l = c:line({ { 240 + sd * 2, w[2] + k }, { 240 + sd * (w[1] + w[3]), w[2] + k * 2 } }, 1); c:fillMask(l:clip(wm), SBLUE[3]) end
    end
  end
  ball(240, 166, 3, VIO); c:fillMask(rect(239, 156, 241, 176), VIO[3]); P(240, 156, VIO[6])
  for _, q in ipairs{ { 224, 192 }, { 256, 190 }, { 230, 142 } } do P(q[1], q[2], PINK[6]); P(q[1] + 1, q[2], PINK[5]); P(q[1], q[2] + 1, PINK[5]) end
end
OVL.berries = function(m)
  for _, y0 in ipairs{ 150, 178 } do
    for x = 218, 261 do local y = floor(y0 + sin(x / 5 + y0) * 4); if m:has(x, y) then P(x, y, LEAF[5]); P(x, y + 1, LEAF[3]) end end
  end
  for _, q in ipairs{ { 226, 152 }, { 244, 148 }, { 255, 180 }, { 232, 178 }, { 242, 196 } } do
    for _, d in ipairs{ { 0, 0 }, { 3, 2 }, { -2, 3 }, { 2, -2 } } do
      local bxx, byy = q[1] + d[1], q[2] + d[2]
      if m:has(bxx, byy) and m:has(bxx + 2, byy + 2) then c:fillMask(rect(bxx, byy, bxx + 2, byy + 2), BLUEW[3]); P(bxx, byy, BLUEW[6]); P(bxx + 2, byy + 2, BLUEW[1]) end
    end
    if m:has(q[1] + 4, q[2] - 3) then leafp(q[1] + 5, q[2] - 3, 3, 1, LEAF) end
  end
end
OVL.night = function(m)
  S.glow(240, 168, 20, "#9a88d8", .18)
  local pts = { { 240, 142 }, { 242, 168 }, { 240, 198 } }
  for i = 1, 9 do
    local y = 146 + i * 5; local l = 11 - abs(i - 5) * 1.6
    local lk = c:line({ { 241, y }, { floor(241 + l), y - 4 } }, 1); c:fillMask(lk:clip(m), NITE[6])
    local rk = c:line({ { 240, y }, { floor(240 - l), y - 4 } }, 1); c:fillMask(rk:clip(m), NITE[5])
  end
  for yy = 142, 200 do P(240, yy, CREAM[6]) end
  for _, q in ipairs{ { 226, 150 }, { 254, 160 }, { 228, 184 }, { 255, 192 } } do P(q[1], q[2], "#ffd24a"); P(q[1] - 1, q[2], "#9a88d8"); P(q[1] + 1, q[2], "#9a88d8"); P(q[1], q[2] - 1, "#9a88d8"); P(q[1], q[2] + 1, "#9a88d8") end
end

---------------------------------------------------------------- W1: per-villager parameter table
local PAR = {
  ["abuela-quilla"] = { kind = "hut", shape = "rect", wood = REDW, woven = true, frame = TIMB, roof = BARN, plate = REDW, lant = "paper", lcol = REDW, ov = "stripes",
    props = { { "clothesline", 0 }, { "yarn", 190 }, { "hatpeg", 272 } } },
  ["bram"] = { kind = "hut", shape = "gothic", wood = VIO, woven = false, straps = true, frame = TIMB, roof = VIO, plate = VIO, lant = "orb", ov = "spell", gnd = GREEN, tft = GREEN, banana = false,
    props = { { "books", 186 }, { "cauldron", 292 }, { "chimes", 206 } } },
  ["burdock-deepdelve"] = { kind = "cottage", shape = "arch", wood = OAK, frame = STONE, straps = true, wall = DIRT, roof = THATCH, shut = OAK, fl = { "#c8b8ec", "#ffd24a", "#f5a0c0" }, plate = OAK, ov = "studs",
    props = { { "shovel", 284 }, { "dirtmound", 192 }, { "wheelbarrow", 142 } } },
  ["clover-thornwhistle"] = { kind = "stone", shape = "arch", wood = LEAF, frame = STONE, blocks = true, straps = false, hw = 20, roof = TEAL, plate = OAK, ov = "clover",
    props = { { "clovers", 186 }, { "thornvine", 196 }, { "whistle", 284 } } },
  ["didi-marigold"] = { kind = "boat", shape = "rect", wood = REDW, frame = CREAM, wall = TEAL, roof = BARN, hull = SBLUE, plate = OAK, ov = "dutch",
    props = { { "buoys", 160 }, { "mpot", 205 }, { "can", 396 } } },
  ["fern-sunpatch"] = { kind = "cottage", shape = "round", wood = GOLD, frame = TIMB, wall = CREAM, roof = THATCH, shut = GOLD, fl = { "#ffd24a", "#fff2dc", "#8fc0f0" }, plate = GOLD, lant = "paper", lcol = GOLD, ov = "sun",
    props = { { "sunflowers", 160 }, { "sunflowers", 286 }, { "can", 182 } } },
  ["haru-pennywhistle"] = { kind = "boat", shape = "round", dx0 = 214, dx1 = 265, dy0 = 153, wood = LEAF, frame = GOLD, wall = LEAF, roof = PINK, hull = TEAL, plate = OAK, lant = "paper", lcol = ROSE, ov = "bamboo", ky = 190, kx = 258,
    props = { { "bamboo", 146 }, { "pinwheel", 294 }, { "bunting", 0, { 154, 96, 214, 100, { REDW[4], GOLD[5], ROSE[5], TEAL[5] } } } } },
  ["indigo-fennelwick"] = { kind = "stone", shape = "gothic", wood = INDG, frame = STONE, blocks = true, straps = false, roof = SBLUE, plate = INDG, lant = "orb", ov = "splat",
    props = { { "easel", 170 }, { "paintpots", 304 }, { "acorn", 274 } } },
  ["juniper-kettleby"] = { kind = "boat", shape = "arch", wood = TEAL, frame = CREAM, wall = OAK, roof = TEAL, hull = BARN, plate = OAK, ov = "teapot",
    props = { { "teachest", 172 }, { "kettle", 290 }, { "mugrack", 280 } } },
  ["lark-fernsway"] = { kind = "cottage", shape = "rect", wood = GREEN, frame = TIMB, straps = false, wall = CREAM, roof = MOSSR, shut = LEAF, fl = { "#c8b8ec", "#f5a0c0", "#fff2dc" }, plate = LEAF, lant = "jar", ov = "patch",
    props = { { "fiddle", 196 }, { "fernpot", 172 }, { "musicstand", 290 } } },
  ["marigold-puddleby"] = { kind = "burrow", shape = "round", wood = TEAL, frame = STONE, blocks = true, straps = false, plate = OAK, ov = "bloom",
    props = { { "puddle", 150 }, { "barrel", 184 }, { "umbrella", 284 } } },
  ["nettle-fernsway"] = { kind = "treehouse", shape = "round", wood = OAK, frame = TIMB, straps = false, wall = OAK, noladder = true, plate = TIMB, lant = "jar", ov = "shell",
    props = { { "ivy", 196 }, { "nettle", 166 }, { "acorn", 284 } } },
  ["nonna-briscola"] = { kind = "boat", shape = "arch", wood = REDW, frame = CREAM, wall = ROSE, roof = REDW, hull = SBLUE, plate = OAK, ov = "dots",
    props = { { "pasta", 172 }, { "garlic", 278 }, { "tomatoes", 402 } } },
  ["pak-lontar"] = { kind = "hut", shape = "rect", wood = BLUEW, woven = false, frame = TIMB, roof = THATCH, plate = BLUEW, lant = "paper", lcol = ORNG, ov = "batik",
    props = { { "gong", 170 }, { "rice", 292 }, { "horns", 0 } } },
  ["pip-burrowell"] = { kind = "stone", shape = "arch", hw = 15, dy0 = 150, wood = CHZ, frame = STONE, blocks = true, straps = false, fw = 5, roof = BARN, plate = OAK, ov = "cheese", kx = 249, ky = 184,
    props = { { "cheese", 188 }, { "broom", 282 }, { "mushroom", 204 } } },
  ["quill-rootstock"] = { kind = "hut", shape = "rect", wood = TEAL, woven = false, straps = true, frame = TIMB, roof = TEAL, plate = TEAL, ov = "quill", banana = false,
    props = { { "inkwell", 190 }, { "sapling", 286 }, { "bunting", 0, { 150, 100, 212, 104, { TEAL[5], GOLD[5], ROSE[5], VIO[5] } } } } },
  ["sakuya-brushwick"] = { kind = "burrow", shape = "round", wood = CREAM, frame = REDW, fw = 6, blocks = false, straps = false, plate = OAK, lant = "paper", lcol = REDW, ov = "enso",
    props = { { "bigbrush", 172 }, { "toro", 292 }, { "sapling", 196 } } },
  ["thistle-leafwhisker"] = { kind = "treehouse", shape = "gothic", wood = PINK, frame = TIMB, straps = false, nofungus = true, plate = TIMB, lant = "jar", ov = "wings",
    props = { { "thistles", 150 }, { "jars", 296 }, { "acorn", 262 } } },
  ["willow-rootstock"] = { kind = "hut", shape = "round", wood = MOSSR, woven = false, frame = TIMB, roof = MOSSR, plate = MOSSR, gnd = GREEN, tft = GREEN, banana = false, ov = "berries",
    props = { { "blueberry", 176 }, { "bindle", 288 }, { "sapling", 202 } } },
  ["yoru-quillmoss"] = { kind = "stone", shape = "gothic", wood = NITE, frame = STONE, blocks = true, straps = false, roof = VIO, plate = OAK, lant = "orb", ov = "night",
    props = { { "mossstump", 184 }, { "plumes", 286 }, { "mushroom", 270, "#7fd0f0" } } },
}

local function cottage(p)
  for y = 60, 205 do for x = 0, 479 do
    local n = vn(x, y, 6, 3) * .5 + vn(x, y, 2.3, 9) * .5
    local v = .64 + (n - .5) * .4 - (y - 70) / 136 * .1 + (hash(x, y, 2) > .96 and .1 or 0)
    P(x, y, p.wall[GX.idx(v, { .2, .35, .5, .6, .8 })])
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
    P(x, y, p.roof[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 64, 67 do for x = 0, 479 do local cur = c:get(x, y); if cur and not rm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .4 - (y - 64) * .08)) end end end
  grass(function(x) return 206 + floor(sin(x / 30) * 1.2) end, GREEN, 5)
  -- flagstone path
  local pm = HP.mask()
  for y = 206, 269 do local hw = 30 + (y - 206) * .5; for x = floor(240 - hw), floor(240 + hw) do pm:set(x, y) end end
  stones(function(x, y) return pm:has(x, y) end, 190, 206, 290, 269, STONE, { rh = 8, seed = 11, wmin = 9, wvar = 10, shade = function(x, y) return -1 end })
  window(130, 116, 166, 152, p.shut or TEAL, true, p.fl)
  window(372, 116, 408, 152, p.shut or TEAL, true, p.fl)
  step(204, 276, 205, STONE)
  local DM = door(DP(p, { shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, frame = TIMB, wood = BARN, seed = 3, pw = 7, straps = { 150, 186 } }))
  plate(240, 84, p.plate or TIMB)
  FIN(p, DM, { arm = true })
  for i = 1, 26 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  flowers(14, 12, 210, 266, p.fl, function(x) return x > 190 and x < 290 end)
  for x = 20, 96, 11 do tuft(x, 204, GREEN) end
end

local function burrow(p)
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
    P(x, y, (p.hill or GREEN)[GX.idx(v)])
  end)
  for i = 1, 240 do   -- grass blades
    local x, y = 30 + floor(hash(i, 1, 9) * 420), 56 + floor(hash(i, 2, 9) * 146)
    if hm:has(x, y) and hm:has(x, y - 2) and free(x, y) then P(x, y, GREEN[6]); P(x, y + 1, GREEN[3]) end
  end
  -- sign gantry
  for _, x in ipairs{ 210, 268 } do local pm = rect(x, 64, x + 2, 100); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 }) end
  local bar = rect(208, 70, 272, 73); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  plate(240, 84, p.plate or OAK, { w = 40 })
  -- door
  local ring = dmask("round", 204 - 6, 135 - 6, 275 + 6, 203 + 6)
  local DM = door(DP(p, { shape = "round", x0 = 207, y0 = 135, x1 = 272, y1 = 203, f = 5, frame = STONE, wood = GOLD, seed = 6, pw = 8, blocks = true, straps = { 150, 183 }, kx = 240, ky = 170 }))
  for x = 206, 274 do if hash(x, 1, 8) > .5 then GX.tuft(c, x, 130 - floor(abs(x - 240) ^ 2 / 60) + 6, R4(GREEN)) end end
  step(210, 270, 205, STONE, { h = 4 })
  -- front ground
  for i = 1, 14 do tuft(floor(hash(i, 1, 6) * 470) + 6, 210 + floor(hash(i, 2, 6) * 56), GREEN) end
  flowers(16, 21, 70, 190, { "#f0809c", "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x, y) return (x > 195 and x < 285 and y > 60) or (x > 285 and x < 330 and y < 150) end)
  FIN(p, DM, { post = { TIMB, 206 } })
end

local function treehouse(p)
  sky({ "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8" }, 7, 215)
  c:cloud(24, 110, 46, "#f8f0e0", "#d6e6f0"); c:cloud(410, 130, 40, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 172 + 8 * sin(x / 44) + 4 * sin(x / 13) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 215, 5)
  hills(function(x) return 190 + 6 * sin(x / 31 + 2) end, { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 6)
  grass(function(x) return 207 + floor(sin(x / 28) * 1.3) end, GREEN, 8)
  local tm = GX.trunk(c, 150, 326, 30, 208, R4(p.wall or OAK), 4, { moss = { hi = GREEN[5], base = GREEN[4], shade = GREEN[3], deep = GREEN[2] } })
  for _, b in ipairs{ { 30, 34, 72, 40 }, { 130, 24, 84, 34 }, { 250, 20, 90, 34 }, { 370, 30, 84, 38 }, { 450, 40, 56, 34 }, { 70, 52, 56, 22 }, { 230, 44, 70, 24 }, { 400, 54, 56, 20 } } do
    GX.foliage(c, b[1], b[2], b[3], b[4], R4(b[1] % 2 == 0 and GREEN or LEAF), b[1] + 3)
  end
  -- limb stubs and bark knots
  for _, k in ipairs{ { 168, 120 }, { 310, 190 } } do
    local km = c:ellipse(k[1], k[2], 3, 4); c:rim(km, INK); c:fillMask(km, OAK[2]); P(k[1] - 1, k[2] - 2, OAK[3])
  end
  -- door
  local DM = door(DP(p, { shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 5, frame = TIMB, wood = TEAL, seed = 9, pw = 7, straps = { 152, 184 } }))
  for i = 0, 14 do local lx = 213 + floor(i * 3.4); P(lx, 133 + floor(abs(i - 7) / 3), GREEN[4 + i % 2]); P(lx, 132 + floor(abs(i - 7) / 3), GREEN[5]) end
  step(208, 272, 205, TIMB)
  plate(240, 84, p.plate or TIMB)
  for i = 0, 5 do P(205 + i * 8, 77 + i % 2 * 2, LEAF[4]); P(206 + i * 8, 78 + i % 2 * 2, LEAF[5]) end
  if not p.noladder then
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
  end
  if not p.nofungus then
  for _, f in ipairs{ { 288, 156, 8 }, { 292, 168, 6 }, { 284, 178, 5 } } do
    local fm = c:ellipse(f[1], f[2], f[3], 2); fm:cut(rect(f[1] - f[3] - 1, f[2] - 6, f[1] + f[3] + 1, f[2] - 1))
    fm:cut(rect(f[1] - f[3] - 1, f[2] - 6, f[1] - f[3] - 1, f[2] + 6))
    fm = c:ellipse(f[1], f[2], f[3], 3):clip(rect(f[1] - f[3] - 1, f[2] - 1, f[1] + f[3] + 1, f[2] + 3))
    c:rim(fm, INK); fm:each(function(x, y) P(x, y, (y == f[2] - 1 or y == f[2]) and "#f2a060" or ((y >= f[2] + 2) and "#c4622c" or "#e08040")) end)
    P(f[1] - 2, f[2] - 1, "#ffd8a0"); P(f[1] + 2, f[2] + 1, "#ffd8a0")
  end
  end
  for i = 1, 20 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  for x = 134, 160, 9 do tuft(x, 208, GREEN) end
  flowers(10, 31, 214, 266, { "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x) return x > 160 and x < 330 end)
  FIN(p, DM, nil)
end

local function hut(p)
  sky({ "#8ec8e8", "#a8d8ec", "#c4e4ee", "#f0e8cc", "#f8dcb0" }, 3, 215)
  c:cloud(30, 70, 46, "#fff4e0", "#f0d0b0"); c:cloud(400, 52, 40, "#fff4e0", "#f0d0b0")
  hills(function(x) return 176 + 8 * sin(x / 60 + 1) end, { "#a8784c", "#bc8c58", "#d0a468", "#e0bc7c", "#ecd096", "#f4e0ac" }, 215, 4)
  grass(function(x) return 207 + floor(sin(x / 22) * 1.2) end, (p.gnd or SAND), 9, { tex = .3 })
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
  if p.banana ~= false then banana(44, 206, 1); banana(436, 206, 1.1) end
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
    P(x, y, (p.wall or DIRT)[max(1, min(6, t + 1))])
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
    P(x, y, p.roof[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .45 - (y - 73) * .1)) end end end
  local fin = c:ellipse(240, 6, 3, 4); c:rim(fin, INK); c:fillMask(fin, THATCH[3])
  -- details
  local bar = rect(190, 100, 290, 102)
  step(204, 276, 205, TIMB, { h = 4 })
  local DM = door(DP(p, { shape = "rect", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, frame = TIMB, wood = DIRT, woven = true, seed = 2, kx = 255, ky = 178 }))
  for y = 138, 202, 16 do for x = DX0 - 4, DX1 + 4, 1 do if x < DX0 or x > DX1 then P(x, y, DIRT[6]); P(x, y + 1, TIMB[2]) end end end
  plate(240, 84, p.plate or DIRT, { w = 44 })
  for i = 1, 16 do tuft(floor(hash(i, 1, 6) * 470) + 6, 214 + floor(hash(i, 2, 6) * 52), (p.tft or SANDT)) end
  for i = 1, 9 do
    local x, y = 20 + floor(hash(i, 3, 6) * 440), 216 + floor(hash(i, 4, 6) * 48)
    if free(x, y) and not (x > 190 and x < 290) then c:fillMask(rect(x, y, x + 2, y + 1), "#a8906a"); P(x, y, "#c8b088"); P(x, y + 2, "#7a6040") end
  end
  FIN(p, DM, nil)
end

local function stonehouse(p)
  sky({ "#a4c8e8", "#b8d4ec", "#cce0f0", "#e0ecf4", "#f0f0ec" }, 6, 215)
  c:cloud(30, 84, 50, "#f8f0e0", "#d6e6f0"); c:cloud(410, 60, 44, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 168 + 10 * sin(x / 50) end, { "#58708a", "#6c88a0", "#84a0b4", "#9cb6c6", "#b4cad4", "#cadce0" }, 215, 3)
  hills(function(x) return 190 + 7 * sin(x / 33 + 1) end, { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 7)
  grass(function(x) return 207 + floor(sin(x / 26) * 1.2) end, GREEN, 10)
  local function cyl(x, y) local s = (x - 240) / 100; return (s > .82) and -2 or ((s > .55) and -1 or ((s < -.85) and -1 or 0)) end
  local wm = rect(140, 66, 340, 206)
  c:rim(wm, INK)
  stones(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, p.wall or STONE, { rh = 9, seed = 5, shade = cyl })
  moss(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, 13, function(x, y) return .56 + (206 - y) / 150 * .22 + ((x < 150 or x > 330) and -.1 or 0) end, 5)
  -- roof cone (slate)
  local rm = HP.mask()
  for y = 12, 72 do
    local t = (y - 12) / 60
    local hw = 5 + (t ^ .9) * 132
    for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end
  end
  c:rim(rm, INK)
  stones(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, p.roof or SBLUE, { rh = 6, seed = 8, wmin = 8, wvar = 6, shade = function(x, y) local s = (x - 240) / 130; return (s > .5) and -1 or ((s < -.2) and 1 or 0) end })
  moss(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, 17, function(x, y) return .66 - (72 - y) / 200 end, 4)
  local fin = c:ellipse(240, 10, 3, 4); c:rim(fin, INK); c:fillMask(fin, STONE[4]); P(239, 8, STONE[6])
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#2a1830", .5 - (y - 73) * .12)) end end end
  -- plinth and ground
  stones(function(x, y) return y >= 196 and y <= 206 and abs(x - 240) < 114 end, 126, 196, 354, 206, STONE, { rh = 6, seed = 20, wmin = 12, shade = function() return -1 end })
  for x = 126, 354 do if abs(x - 240) < 114 then P(x, 195, INK) end end
  -- door (oak, iron, stone voussoirs)
  step(204, 276, 205, STONE)
  local DM = door(DP(p, { shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 6, frame = STONE, wood = OAK, seed = 4, pw = 6, blocks = true, straps = { 150, 184 }, kx = 252, ky = 176 }))
  plate(240, 84, p.plate or OAK)
  for i = 1, 18 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  flowers(9, 41, 212, 266, { "#c8b8ec", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)
  FIN(p, DM, nil)
end

---------------------------------------------------------------- BOAT: houseboat door on a dock, water, duck
local function boat(p)
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
    P(x, y, (y >= 214 and y <= 217) and CREAM[(s > .7) and 4 or 5] or (p.hull or SBLUE)[max(1, min(6, t))])
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
    P(x, y, (p.wall or TEAL)[max(1, min(6, t))])
  end)
  -- roof and chimney
  local ch = rect(274, 28, 288, 60); c:rim(ch, INK); stones(function(x, y) return ch:has(x, y) end, 274, 28, 288, 60, BARN, { rh = 5, seed = 4, wmin = 7, wvar = 4 })
  for k, p in ipairs{ { 280, 20, 4 }, { 286, 10, 5 }, { 294, 0, 6 } } do local sm = c:ellipse(p[1], p[2], p[3], p[3] - 1); c:rim(sm, INK); c:fillMask(sm, CREAM[5]); P(p[1] - 1, p[2] - 1, CREAM[6]) end
  local rm = HP.mask()
  for y = 46, 69 do local ins = floor((70 - y) * .3); for x = 142 + ins, 338 - ins do rm:set(x, y) end end
  c:rim(rm, INK)
  rm:each(function(x, y)
    local t = (y - 46) // 4
    local col = (p.roof or BARN)[max(1, min(6, 5 - t))]
    if (x // 9) % 2 == 0 and y > 52 then col = (p.roof or BARN)[max(1, min(6, 5 - t - 1))] end
    P(x, y, col)
  end)
  for x = 142, 338 do P(x, 69, (p.roof or BARN)[2]) end
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
  local DM = door(DP(p, { shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, frame = CREAM, wood = SBLUE, seed = 5, pw = 7, straps = nil, kx = 254, ky = 178 }))
  plate(240, 84, p.plate or OAK)
  FIN(p, DM, nil)
end


local K = { cottage = cottage, burrow = burrow, treehouse = treehouse, hut = hut, stone = stonehouse, boat = boat }
local p = PAR[name]
p.slug = name
K[p.kind](p)
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end
build(NAME)

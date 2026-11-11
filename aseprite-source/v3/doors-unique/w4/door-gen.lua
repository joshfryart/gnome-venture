-- door.lua: a villager's front door seen straight on, 480x270, six habitats. Param: name=cottage|burrow|treehouse|hut|stone|boat (or all)
-- Run: AppRun -b --script-param name=cottage --script door.lua   -> out/door-<name>.png/.aseprite
-- Contract: door centred (240,170) [x218..261, y136..204], blank name plate at (240,84), lantern at (300,120), basket spot (350,206) left empty.
local V3 = "/home/user/gnome-venture/aseprite-source/v3"
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, sin, cos, sqrt, abs = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs
local INK = "#2b1c26"
local NAME = app.params.name or "clementine-moss"
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
-- ===== clementine-moss (snail): goggles, headband, spiral door
local function headband()
  local m = rect(8, 124, 470, 130); c:rim(m, INK)
  m:each(function(x, y) local t = (y == 124) and 5 or ((y >= 129) and 2 or 4); if y == 126 and x % 6 < 3 then t = 3 end; P(x, y, BLUEW[t]) end)
end
local function goggle(cx, cy)
  S.glow(cx, cy, 32, "#ffd070", .45)
  local ring = c:ellipse(cx, cy, 18, 18); c:rim(ring, INK)
  ring:each(function(x, y) local l = lit(x, y, cx, cy, 18); P(x, y, GOLD[l > .5 and 6 or (l > 0 and 5 or (l > -.5 and 4 or 3))]) end)
  local gm = c:ellipse(cx, cy, 13, 13); c:rim(gm, INK)
  gm:each(function(x, y) local l = lit(x, y, cx, cy, 13); P(x, y, l > .2 and "#ffe9a0" or (l > -.4 and "#ffd070" or "#f0a848")) end)
  for k = 0, 6 do P(cx - 9 + k, cy - 6 - floor(k * .5 * (1 - k / 14)), "#fff8dc") end
  P(cx - 8, cy - 3, "#fff8dc"); P(cx + 5, cy + 6, "#fff2b0")
  for _, a in ipairs{ 0, 1.57, 3.14, 4.71 } do local bx, by = floor(cx + cos(a + .78) * 15.5 + .5), floor(cy + sin(a + .78) * 15.5 + .5); P(bx, by, GOLD[2]); P(bx - 1, by - 1, GOLD[6]) end
end
local function spiral(cx, cy, R)
  local pts = {}
  for t = 0, 15.7, .04 do local r = 1.5 + t * (R - 1.5) / 15.7; pts[#pts + 1] = { floor(cx + cos(t) * r + .5), floor(cy + sin(t) * r * .9 + .5) } end
  for _, p in ipairs(pts) do P(p[1] + 1, p[2] + 1, BLUEW[1]) end
  for _, p in ipairs(pts) do P(p[1], p[2], "#f4e6c8"); P(p[1] - 1, p[2], "#e8cfa4") end
  P(cx, cy, "#fff2dc")
end
local function trail()
  for y = 205, 268 do
    local x = 232 + floor(sin(y / 8) * 6) - floor((y - 205) * .3)
    if y > 209 or (x > 203 and x < 277) then P(x, y, "#e6f2ff"); P(x + 1, y, "#9ab4e0"); if y % 5 == 0 then P(x - 1, y, "#f8fcff"); P(x, y - 1, "#f8fcff") end end
  end
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
-- ===== bracken-spurwing (beetle): elytra door, antenna wires, pea trellis, acorn mailbox
local function elytra()
  for y = 138, 200 do if ((y - 169) / 32) ^ 2 < 1 then for _, x in ipairs{ 239, 240 } do if ((x + .5 - 240) / 31) ^ 2 + ((y + .5 - 169) / 33) ^ 2 < .9 then P(x, y, INK) end end end end
  for _, s in ipairs{ { 224, 158, 4 }, { 256, 158, 4 }, { 222, 182, 3 }, { 258, 182, 3 }, { 229, 146, 2 }, { 251, 146, 2 }, { 232, 196, 2 }, { 248, 196, 2 } } do
    local m = c:ellipse(s[1], s[2], s[3], s[3]); c:fillMask(m, INK); P(s[1] - 1, s[2] - 1, "#5a2a44")
  end
  for a = 3.5, 4.5, .06 do local x, y = floor(240 - 28 + cos(a + .6) * 7 + 0), floor(170 + sin(a + 1.0) * 24); P(235 - 20 + floor((a - 3.5) * 8), 150 + floor((a - 3.5) * 14), "#f8a888") end
end
local function antennae()
  for _, sd in ipairs{ -1, 1 } do
    local prev
    for t = 0, 1, .02 do
      local x = floor(240 + sd * (7 + 20 * t + 6 * math.sin(t * 5)) + .5)
      local y = floor(130 - 20 * t * (1 - .3 * t) + .5)
      if t > .9 then y = y + 1 end
      P(x + 1, y + 1, INK); P(x, y, IRON[5])
      prev = { x, y }
    end
    local bm = c:ellipse(prev[1], prev[2], 3, 3); c:rim(bm, INK); c:fillMask(bm, GOLD[4]); P(prev[1] - 1, prev[2] - 1, GOLD[6]); P(prev[1] + 1, prev[2] + 1, GOLD[2])
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
-- ===== old-twigg (stick-insect mystic): moon door, herbs, chimes, orb staff
local function moonstars()
  S.glow(240, 158, 20, "#ffd070", .3)
  local m = c:ellipse(240, 158, 10, 10); m:cut(c:ellipse(245, 155, 9, 9)); c:rim(m, INK)
  m:each(function(x, y) P(x, y, (x + y < 394) and "#fff6cc" or "#ffe08a") end)
  for _, s in ipairs{ { 226, 146 }, { 252, 148 }, { 227, 178 }, { 251, 184 }, { 234, 190 } } do
    P(s[1], s[2], "#fff6cc"); for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do P(s[1] + d[1], s[2] + d[2], "#ffd24a") end
  end
end
local function herbs(x)
  local violet = (x == 172)
  for y = 96, 104 do P(x, y, "#7a5a30") end
  P(x - 1, 95, INK); P(x, 94, INK); P(x + 1, 95, INK)
  c:fillMask(rect(x - 2, 105, x + 2, 106), INK); c:fillMask(rect(x - 1, 105, x + 1, 105), "#c8a060")
  for k = -3, 3, 2 do for y = 107, 112 do P(x + k * (y - 106) // 6, y, "#6a8a4a") end end
  for k = -3, 3, 2 do
    local fx = x + k * 2 // 1; local m = c:ellipse(fx, 117, 2, 5); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, violet and ((xx < fx) and VIO[5] or VIO[3]) or ((xx < fx) and "#f8c050" or "#e08830")) end)
    P(fx - 1, 114, violet and VIO[6] or "#ffe08a")
  end
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
local function staff(x)
  S.glow(x + 8, 114, 17, "#9be8f0", .4)
  local sm = c:line({ { x, 206 }, { x + 4, 176 }, { x + 2, 150 }, { x + 9, 124 } }, 3); c:rim(sm, INK)
  sm:each(function(xx, yy) P(xx, yy, ((xx + yy // 3) % 5 == 0) and TIMB[3] or ((xx < x + 4 + (206 - yy) // 40) and TIMB[5] or TIMB[4])) end)
  local ring = c:ellipse(x + 9, 116, 6, 6); ring:cut(c:ellipse(x + 9, 116, 3, 3)); c:rim(ring, INK); c:fillMask(ring, TIMB[4])
  local orb = c:ellipse(x + 9, 116, 3, 3); c:fillMask(orb, "#9be8f0"); P(x + 8, 115, "#e8ffff"); P(x + 10, 118, "#58c4d0")
  for _, y in ipairs{ 160, 190 } do c:fillMask(rect(x + 1, y, x + 5, y + 1), "#c8a060") end   -- wrapped cord
end

local function clementine()
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
    P(x, y, MOSSR[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 64, 67 do for x = 0, 479 do local cur = c:get(x, y); if cur and not rm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .4 - (y - 64) * .08)) end end end
  grass(function(x) return 206 + floor(sin(x / 30) * 1.2) end, GREEN, 5)
  -- flagstone path
  local pm = HP.mask()
  for y = 206, 269 do local hw = 30 + (y - 206) * .5; for x = floor(240 - hw), floor(240 + hw) do pm:set(x, y) end end
  stones(function(x, y) return pm:has(x, y) end, 190, 206, 290, 269, STONE, { rh = 8, seed = 11, wmin = 9, wvar = 10, shade = function(x, y) return -1 end })
  headband()
  goggle(148, 128); goggle(388, 128)
  step(204, 276, 205, STONE)
  door{ shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, frame = TIMB, wood = BLUEW, seed = 3, pw = 7, kx = 254, ky = 180 }
  spiral(240, 166, 11)
  trail()
  can(176, 205); cabbages()
  plate(240, 84, BLUEW)
  lantern(300, 120, { arm = true })
  for i = 1, 26 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  flowers(14, 12, 210, 266, { "#8fc0f0", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)
  for x = 20, 96, 11 do tuft(x, 204, GREEN) end
end
local function bracken()
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
  door{ shape = "round", x0 = 207, y0 = 135, x1 = 272, y1 = 203, f = 5, frame = STONE, wood = REDW, seed = 6, pw = 8, blocks = true, kx = 256, ky = 186 }
  elytra()
  for x = 206, 274 do if hash(x, 1, 8) > .5 then GX.tuft(c, x, 130 - floor(abs(x - 240) ^ 2 / 60) + 6, R4(GREEN)) end end
  step(210, 270, 205, STONE, { h = 4 })
  -- front ground
  for i = 1, 14 do tuft(floor(hash(i, 1, 6) * 470) + 6, 210 + floor(hash(i, 2, 6) * 56), GREEN) end
  flowers(16, 21, 70, 190, { "#f0809c", "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x, y) return (x > 195 and x < 285 and y > 60) or (x > 285 and x < 330 and y < 150) end)
  trellis(168); acorn(286, 206); antennae()
  lantern(300, 120, { post = { TIMB, 206 } })
end
local function twigg()
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
  door{ shape = "rect", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, frame = TIMB, wood = VIO, woven = true, seed = 2, kx = 255, ky = 186 }
  moonstars()
  for y = 138, 202, 16 do for x = DX0 - 4, DX1 + 4, 1 do if x < DX0 or x > DX1 then P(x, y, DIRT[6]); P(x, y + 1, TIMB[2]) end end end
  plate(240, 84, VIO, { w = 44 })
  herbs(172); herbs(192); chimes(206); staff(196)
  for i = 1, 16 do tuft(floor(hash(i, 1, 6) * 470) + 6, 214 + floor(hash(i, 2, 6) * 52), { "#6a502e", "#8a6a34", "#a8863c", "#c2a04a", "#d8b862", "#e8cc7c" }) end
  for i = 1, 9 do
    local x, y = 20 + floor(hash(i, 3, 6) * 440), 216 + floor(hash(i, 4, 6) * 48)
    if free(x, y) and not (x > 190 and x < 290) then c:fillMask(rect(x, y, x + 2, y + 1), "#a8906a"); P(x, y, "#c8b088"); P(x, y + 2, "#7a6040") end
  end
  lantern(300, 120)
end


local F = { ["clementine-moss"] = clementine, ["bracken-spurwing"] = bracken, ["old-twigg"] = twigg }
F[name]()
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end

for _, n in ipairs(NAME == "all" and { "clementine-moss", "bracken-spurwing", "old-twigg" } or { NAME }) do build(n) end

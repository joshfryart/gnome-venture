-- door.lua: a villager's front door seen straight on, 480x270, six habitats. Param: name=cottage|burrow|treehouse|hut|stone|boat (or all)
-- Run: AppRun -b --script-param name=cottage --script door.lua   -> out/door-<name>.png/.aseprite
-- Contract: door centred (240,170) [x218..261, y136..204], blank name plate at (240,84), lantern at (300,120), basket spot (350,206) left empty.
local V3 = "/home/user/gnome-venture/aseprite-source/v3"
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, sin, cos, sqrt, abs = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs
local INK = "#2b1c26"
local NAME = app.params.name or "all"
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
    elseif shape == "point" then
      local hh = (y1 - y0 + 1) * .38
      if y < y0 + hh then local t = (y - y0 + .5) / hh; local hw = (w / 2) * (1 - (1 - t) ^ 2.2); ok = abs(x + .5 - cx) <= hw end
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

---------------------------------------------------------------- w2: ramps, overlays, props
local ORG = {"#4a2210","#7a3a1a","#b8561e","#e07a2a","#f4a64a","#fcd08a"}
local PNK = {"#4a1a3a","#7a2a5a","#b04880","#d868a0","#f090c0","#fcc4de"}
local YEL = {"#4a3410","#7a5a18","#b08a24","#e0b43a","#f4d060","#fce898"}
local SLT = {"#1e2434","#323c54","#4a5878","#6a7a9c","#8c9cbc","#b4c4dc"}
local PLM = {"#2a1430","#4a2450","#703474","#9a4c94","#bc70b4","#dca0d4"}
local TLW = {"#12303a","#1e4c58","#2e6e78","#44909a","#6cb4b8","#a0d8d4"}
local TAN = {"#5a3a24","#7a5436","#a07848","#c49a60","#e0bc80","#f4dca8"}
local SND = {"#6a5238","#8a6e4a","#a8895e","#c8aa7c","#e0c8a0","#f2e4c4"}
local DKS = {"#1c1c2c","#2e2e44","#44445e","#5e5e7c","#7c7c9a","#a0a0bc"}
local PEACH = {"#8a6050","#b48468","#d4a888","#ecc8a8","#f8e0c4","#fff0dc"}
local SAGEP = {"#6a7c5c","#8a9c7a","#a8bc96","#c4d4b0","#dce8c8","#f0f6e0"}
local OLV = {"#3a4a1e","#586a2c","#7a8c3c","#9aae52","#bccc74","#dce8a0"}
local AUTUMN = {"#5a2210","#8a3a14","#c25a1c","#e08030","#f2a64a","#fccc78"}
local BLOSS = {"#7a3a5a","#b05a80","#d878a0","#f098b8","#f8b8cc","#fcdce6"}
local function q(m, x, y, col) if m:has(x, y) then P(x, y, col) end end
local function qe(m, cx, cy, rx, ry, fn, rim)
  local e = c:ellipse(cx, cy, rx, ry)
  e:each(function(x, y)
    if m == nil or m:has(x, y) then
      local edge = rim and not (e:has(x + 1, y) and e:has(x - 1, y) and e:has(x, y + 1) and e:has(x, y - 1))
      P(x, y, edge and INK or fn(x, y))
    end
  end)
  return e
end
local function shadow(x, y, rx)
  c:ellipse(x, y, rx, 2):each(function(xx, yy) local cur = c:get(xx, yy); if cur then P(xx, yy, mixc(cur, "#2a1830", .3)) end end)
end
local function knob(kx, ky)
  c:fillMask(rect(kx - 2, ky - 2, kx + 2, ky + 2), INK)
  c:fillMask(rect(kx - 1, ky - 1, kx + 1, ky + 1), GOLD[4]); P(kx - 1, ky - 1, GOLD[6]); P(kx + 1, ky + 1, GOLD[2])
  P(kx, ky + 4, INK); P(kx, ky + 5, INK)
end
local function cxy(o) return (o.x0 + o.x1) // 2, (o.y0 + o.y1) // 2 end

-------- door overlays: OV[id](o, mask, args)
local OV = {}
OV.stripes = function(o, m)
  for y = o.y0, o.y1 do local r = (y - o.y0) % 14
    if r >= 7 then for x = o.x0, o.x1 do q(m, x, y, (r == 7) and "#8a5a20" or ((r == 13) and INK or "#4a2c14")) end end end
end
OV.plaid = function(o, m)
  for y = o.y0, o.y1 do for x = o.x0, o.x1 do if m:has(x, y) then
    local vx, hy = (x - o.x0) % 12 < 3, (y - o.y0) % 14 < 3
    local cur = c:get(x, y)
    if vx and hy then P(x, y, mixc(cur, "#7a2230", .7)) elseif vx then P(x, y, mixc(cur, "#e8493b", .6)) elseif hy then P(x, y, mixc(cur, "#3f9150", .6)) end
  end end end
end
local function lattice(o, m, lc, dots, st)
  for y = o.y0, o.y1 do for x = o.x0, o.x1 do if m:has(x, y) then
    local a, b = ((x - o.x0) + (y - o.y0) * .8) % st, ((x - o.x0) - (y - o.y0) * .8) % st
    if a < 1.3 and b < 1.3 then P(x, y, dots[(floor((x - o.x0) / st) + floor((y - o.y0) / st)) % #dots + 1])
    elseif a < 1.3 or b < 1.3 then P(x, y, lc) end
  end end end
end
OV.hex = function(o, m) lattice(o, m, o.wood[1], { o.wood[5], o.wood[6], o.wood[4] }, 14) end
OV.gems = function(o, m) lattice(o, m, o.wood[6], { "#ff5a8a", "#ffd24a", "#7af0e0", "#c8a8ff" }, 12) end
OV.leaf = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local W = o.wood
  for y = o.y0 + 3, o.y1 do q(m, cx, y, W[6]); q(m, cx + 1, y, W[2]) end
  for y = o.y0 + 10, o.y1 - 6, 8 do for k = 1, 9 do
    q(m, cx - k, y + k // 2 * 1 - 4 + k, W[5]); q(m, cx + 1 + k, y + k - 4, W[5]); q(m, cx - k, y + k - 3, W[2]); q(m, cx + 1 + k, y + k - 3, W[2])
  end end
end
OV.sun = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 26
  for k = 0, 11 do local a = k * .5236
    for r = 9, 13 do q(m, floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5), (r < 12) and "#ffd24a" or "#fff2a0") end end
  qe(m, cx, cy, 7, 7, function(x, y) local l = lit(x, y, cx, cy, 7); return l > .3 and "#fff2a0" or (l > -.4 and "#ffd24a" or "#e8a030") end, true)
end
OV.port = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 26
  qe(m, cx, cy, 11, 11, function(x, y) local l = lit(x, y, cx, cy, 11); return GOLD[l > .5 and 6 or (l > 0 and 5 or (l > -.5 and 4 or 3))] end, true)
  qe(m, cx, cy, 8, 8, function(x, y) return (y < cy) and SBLUE[5] or SBLUE[4] end, true)
  for k = 0, 5 do q(m, cx - 5 + k, cy - 2 - k + 2, SBLUE[6]) end
  for x = cx - 8, cx + 8 do q(m, x, cy, GOLD[2]) end
end
OV.window = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local y0 = o.y0 + 14
  for y = y0 - 1, y0 + 19 do for x = cx - 9, cx + 9 do
    local inside = (x >= cx - 7 and x <= cx + 7 and y >= y0 + 1 and y <= y0 + 17)
    local border = not inside
    if border then q(m, x, y, (x == cx - 9 or y == y0 - 1) and INK or TIMB[4]) else q(m, x, y, (y < y0 + 9) and SBLUE[5] or SBLUE[4]) end
  end end
  for y = y0 + 1, y0 + 17 do q(m, cx, y, TIMB[3]) end
  for x = cx - 7, cx + 7 do q(m, x, y0 + 9, TIMB[3]) end
  for k = 0, 4 do q(m, cx - 6 + k, y0 + 7 - k, SBLUE[6]) end
  for x = cx - 10, cx + 10 do q(m, x, y0 + 20, TIMB[2]) end
  for y = y0 + 1, y0 + 6 do q(m, cx - 7, y, "#f090c0"); q(m, cx + 7, y, "#f090c0"); q(m, cx - 6, y, "#fcc4de") end
end
OV.petals = function(o, m, a)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 30; local pc = a and a.pet or "#fff2dc"
  for k = 0, 7 do local an = k * .7854
    qe(m, floor(cx + cos(an) * 10 + .5), floor(cy + sin(an) * 10 + .5), 4, 4, function(x, y) return (x + y < cx + cy + 2) and "#ffffff" or pc end, true) end
  qe(m, cx, cy, 5, 5, function(x, y) return (x + y < cx + cy) and "#ffe38a" or "#e8a030" end, true)
end
OV.lily = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 44
  for k = 1, 3 do local rx = 6 + k * 5
    for t = 0, 6.28, .05 do q(m, floor(cx + cos(t) * rx + .5), floor(cy + 6 + sin(t) * rx * .28 + .5), SBLUE[6]) end end
  qe(m, cx, cy, 13, 6, function(x, y) return (y < cy) and "#5aa84a" or "#3f8c40" end, true)
  for x = cx, cx + 13 do q(m, x, cy, INK) end
  for k = 0, 7 do local an = k * .7854
    qe(m, floor(cx - 2 + cos(an) * 4 + .5), floor(cy - 4 + sin(an) * 3 + .5), 2, 2, function() return "#f8a0c8" end, false) end
  qe(m, cx - 2, cy - 4, 1, 1, function() return "#ffe38a" end, false)
end
OV.spots = function(o, m)
  local cx = (o.x0 + o.x1) // 2
  for _, s in ipairs{ { -11, 14, 3 }, { 9, 22, 2 }, { -4, 33, 3 }, { 11, 40, 3 }, { -12, 50, 2 }, { 3, 56, 2 }, { -1, 8, 2 } } do
    qe(m, cx + s[1], o.y0 + s[2], s[3], s[3], function(x, y) return (x + y > cx + s[1] + o.y0 + s[2] + 1) and "#e8cfa4" or "#fff8e8" end, false) end
end
OV.feather = function(o, m)
  local ax, ay, bx, by = o.x0 + 7, o.y0 + 52, o.x1 - 6, o.y0 + 8
  for t = 0, 1, .015 do
    local x, y = ax + (bx - ax) * t, ay + (by - ay) * t
    local w = sin(t * 3.14) * 6 + 1
    for k = 1, floor(w) do q(m, floor(x + k * .7), floor(y + k * .7), (k % 2 == 0) and "#f4e6c8" or "#fff6e0"); q(m, floor(x - k * .7), floor(y - k * .7), (k % 2 == 0) and "#c8a878" or "#e8d0a0") end
    q(m, floor(x), floor(y), INK)
  end
end
OV.notes = function(o, m)
  local cy = (o.y0 + o.y1) // 2 - 6
  for i = 0, 4 do for x = o.x0 + 2, o.x1 - 2 do q(m, x, cy - 8 + i * 4, o.wood[1]) end end
  for _, n in ipairs{ { 6, 1 }, { 14, 3 }, { 22, 0 }, { 30, 2 }, { 37, 4 } } do
    local x, y = o.x0 + n[1], cy - 8 + n[2] * 2 + 1
    for dx = 0, 3 do q(m, x + dx, y, "#fff2dc"); q(m, x + dx, y + 1, "#fff2dc") end
    q(m, x, y, "#fff2dc"); q(m, x + 3, y + 1, "#c8a878")
    for yy = y - 10, y do q(m, x + 3, yy, "#fff2dc") end
  end
end
OV.knit = function(o, m)
  for y = o.y0 + 2, o.y1, 4 do for x = o.x0 + ((y - o.y0) // 4 % 2) * 2, o.x1, 4 do
    q(m, x, y, o.wood[6]); q(m, x + 1, y + 1, o.wood[5]); q(m, x + 2, y, o.wood[6]); q(m, x + 1, y + 2, o.wood[3]); q(m, x, y + 1, o.wood[3])
  end end
end
OV.pebbles = function(o, m)
  local G = { STONE[3], STONE[4], STONE[5] }
  for i = 1, 18 do
    local px, py = o.x0 + 3 + floor(hash(i, 1, 4) * 38), o.y0 + 6 + floor(hash(i, 2, 4) * 56)
    if not (px > 248 and py > 180) then
      local r = 3 + floor(hash(i, 3, 4) * 2); local g = G[1 + floor(hash(i, 4, 4) * 3)]
      qe(m, px, py, r, r - 1, function(x, y) return (x + y < px + py) and STONE[6] or g end, false)
      c:ellipse(px, py, r, r - 1):each(function(x, y) if m:has(x, y) and not c:ellipse(px, py, r, r - 1):has(x, y + 1) then P(x, y, INK) end end)
    end
  end
end
OV.splat = function(o, m)
  local cols = { "#e8493b", "#3f6cb4", "#ffd24a", "#3fb0a0", "#f090c0", "#fff2dc" }
  for i = 1, 9 do
    local px, py = o.x0 + 4 + floor(hash(i, 5, 4) * 36), o.y0 + 6 + floor(hash(i, 6, 4) * 50)
    local col = cols[i % #cols + 1]
    qe(m, px, py, 3, 2 + i % 2, function(x, y) return col end, true)
    if i % 3 == 0 then for y = py + 3, py + 7 do q(m, px, y, col) end end
  end
end
OV.berries = function(o, m)
  local cx = (o.x0 + o.x1) // 2
  for _, g in ipairs{ { -9, 20 }, { 6, 32 }, { -4, 46 } } do
    for _, d in ipairs{ { 0, 0 }, { 5, 1 }, { 2, 5 }, { -3, 5 }, { 7, 6 }, { 3, 10 } } do
      qe(m, cx + g[1] + d[1], o.y0 + g[2] + d[2], 2, 2, function(x, y) return (x + y < cx + g[1] + d[1] + o.y0 + g[2] + d[2]) and "#8a5ac0" or "#3c2050" end, true) end
    q(m, cx + g[1] + 2, o.y0 + g[2] - 4, "#3f9150"); q(m, cx + g[1] + 3, o.y0 + g[2] - 4, "#3f9150"); q(m, cx + g[1] + 1, o.y0 + g[2] - 3, "#3f9150")
  end
end
OV.gear = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 28
  for k = 0, 7 do local an = k * .7854; local tx, ty = floor(cx + cos(an) * 12 + .5), floor(cy + sin(an) * 12 + .5)
    for dx = -2, 2 do for dy = -2, 2 do q(m, tx + dx, ty + dy, (abs(dx) == 2 or abs(dy) == 2) and INK or GOLD[4]) end end end
  qe(m, cx, cy, 9, 9, function(x, y) local l = lit(x, y, cx, cy, 9); return GOLD[l > .4 and 6 or (l > -.2 and 5 or 3)] end, true)
  qe(m, cx, cy, 3, 3, function() return "#3a2030" end, true)
end
OV.scales = function(o, m)
  local W = o.wood
  for r = 0, 14 do local sy = o.y0 + 2 + r * 5
    for sx = o.x0 - 3 + (r % 2) * 3, o.x1 + 3, 6 do
      q(m, sx - 2, sy, W[2]); q(m, sx - 2, sy + 1, W[2]); q(m, sx - 1, sy + 2, W[2]); q(m, sx, sy + 2, W[2]); q(m, sx + 1, sy + 2, W[2]); q(m, sx + 2, sy + 1, W[2]); q(m, sx + 2, sy, W[2])
      q(m, sx - 1, sy + 1, W[6]); q(m, sx, sy, W[5])
    end end
end
OV.spiral = function(o, m) spiral((o.x0 + o.x1) // 2, o.y0 + 30, 12) end

---------------------------------------------------------------- props: PR[id](x, y, a, b); (x,y) = ground-centre unless noted
local PR = {}
PR.ladder = function(lx)
  local ax0, ax1 = lx - 8, lx + 8
  local peg = rect(ax0 - 2, 92, ax1 + 2, 95); c:rim(peg, INK); S.obj(peg, TIMB, { base = 4, lit = 1, shade = 1 })
  for y = 96, 202 do
    local xo = floor(sin(y / 26) * 1.4 + .5)
    for _, rx in ipairs{ lx - 7 + xo, lx + 7 + xo } do P(rx - 1, y, INK); P(rx, y, DIRT[5]); P(rx + 1, y, DIRT[2]) end
    if (y - 96) % 10 == 5 then for x = lx - 8 + xo, lx + 8 + xo do P(x, y, INK); P(x, y + 1, (x < lx + xo) and TIMB[5] or TIMB[3]); P(x, y + 2, INK) end end
  end
end
PR.shelf = function(x, y, a)
  for _, f in ipairs{ { x, y, 8 }, { x + 4, y + 12, 6 }, { x - 4, y + 22, 5 } } do
    local fm = c:ellipse(f[1], f[2], f[3], 3):clip(rect(f[1] - f[3] - 1, f[2] - 1, f[1] + f[3] + 1, f[2] + 3))
    c:rim(fm, INK); fm:each(function(xx, yy) P(xx, yy, (yy == f[2] - 1 or yy == f[2]) and "#f2a060" or ((yy >= f[2] + 2) and "#c4622c" or "#e08040")) end)
    P(f[1] - 2, f[2] - 1, "#ffd8a0"); P(f[1] + 2, f[2] + 1, "#ffd8a0")
  end
end
PR.skep = function(x, y)
  shadow(x, y, 12)
  for _, lx in ipairs{ x - 8, x + 7 } do c:fillMask(rect(lx, y - 5, lx + 1, y), INK) end
  local tb = rect(x - 11, y - 7, x + 11, y - 5); c:rim(tb, INK); S.obj(tb, TIMB, { base = 4, lit = 1, shade = 1 })
  local e = c:ellipse(x, y - 17, 9, 10):clip(rect(x - 10, y - 28, x + 10, y - 8)); c:rim(e, INK)
  e:each(function(xx, yy) local band = (yy - y) // 4; local t = (band % 2 == 0) and 5 or 4
    if (yy - y) % 4 == 0 then t = 3 end; if xx < x - 3 then t = t + 1 elseif xx > x + 4 then t = t - 1 end
    P(xx, yy, THATCH[max(1, min(6, t))]) end)
  c:fillMask(rect(x - 2, y - 12, x + 2, y - 9), INK); c:fillMask(rect(x - 1, y - 11, x + 1, y - 10), "#2a1a10")
  P(x, y - 29, INK); P(x - 1, y - 28, THATCH[3]); P(x + 1, y - 28, THATCH[3]); P(x, y - 28, THATCH[5])
  for k = 0, 2 do P(x + 8, y - 8 + k * 2, "#f4c030"); end
end
PR.rod = function(x, y)
  local rm = c:line({ { x, y }, { x + 10, y - 56 } }, 2); c:rim(rm, INK); rm:each(function(xx, yy) P(xx, yy, (xx + yy) % 7 == 0 and TIMB[3] or TIMB[5]) end)
  for yy = y - 55, y - 26 do P(x + 10 + (yy - y + 55) // 14, yy, "#e8e0d0") end
  qe(nil, x + 12, y - 22, 2, 3, function(xx, yy) return (yy < y - 22) and "#e8493b" or "#fff6e0" end, true)
  P(x + 12, y - 18, INK); P(x + 12, y - 17, INK)
  for k = 0, 3 do P(x - 1, y - 14 - k * 8, "#c8a060") end
end
PR.pail = function(x, y)
  shadow(x, y, 9)
  local m = HP.mask(); for yy = y - 14, y do local ins = (yy - (y - 14)) // 7; for xx = x - 7 + ins, x + 7 - ins do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) local t = (xx < x - 3) and 5 or ((xx > x + 3) and 3 or 4); if yy == y - 14 then t = 6 elseif yy >= y - 1 then t = 2 end; P(xx, yy, IRON[t]) end)
  for xx = x - 5, x + 5 do P(xx, y - 14, "#78bccc"); P(xx, y - 13, "#a8dce0") end
  for k = 0, 3 do P(x - 6 + k * 4, y - 8, IRON[2]) end
  local h = c:line({ { x - 7, y - 14 }, { x, y - 24 }, { x + 7, y - 14 } }, 1); c:fillMask(h, INK)
  P(x - 3, y - 11, "#e8f4f8")
end
PR.boots = function(x, y, a)
  local col = a or { "#e0b43a", "#b08a24", "#fce898" }
  for k, bx in ipairs{ x - 6, x + 6 } do
    local m = rect(bx - 3, y - 14, bx + 3, y - 3); m:add(rect(bx - 3 - (k == 1 and 4 or 0), y - 4, bx + 3 + (k == 2 and 4 or 0), y))
    c:rim(m, INK); m:each(function(xx, yy) local t = col[2]; if xx < bx - 1 then t = col[3] elseif yy >= y - 1 then t = INK end; P(xx, yy, t) end)
    for xx = bx - 3, bx + 3 do P(xx, y - 14, col[3]) end
    P(bx - 2, y - 11, "#fff8e0")
  end
end
PR.cattails = function(x, y)
  shadow(x, y, 12)
  for k, d in ipairs{ -8, -3, 2, 7 } do
    local h = 34 + (k * 7) % 14
    for yy = y, y - h, -1 do local xx = x + d + floor((y - yy) * (k % 2 == 0 and .08 or -.08)); P(xx, yy, GREEN[(k % 2) + 3]); if yy % 5 == 0 then P(xx + 1, yy, GREEN[2]) end end
    local hx, hy = x + d + floor(h * (k % 2 == 0 and .08 or -.08)), y - h
    local hm = rect(hx - 1, hy - 10, hx + 1, hy - 2); hm:add(rect(hx, hy - 12, hx, hy - 11)); c:rim(hm, INK)
    hm:each(function(xx, yy) P(xx, yy, (xx == hx - 1) and "#a8704a" or ((xx == hx + 1) and "#5a3420" or "#7a4a2c")) end)
  end
  for k = -1, 1, 2 do for t = 0, 18 do P(x + k * (3 + t // 2), y - t - floor(t * t / 40), GREEN[(t % 2) + 4]) end end
end
PR.barrel = function(x, y)
  shadow(x, y, 14)
  local m = S.rr(x - 11, y - 26, x + 11, y, 3); c:rim(m, INK); S.planks(m, TIMB, { w = 5, base = 4, seed = 3 })
  for _, hy in ipairs{ y - 20, y - 6 } do for xx = x - 11, x + 11 do if m:has(xx, hy) then P(xx, hy, IRON[4]); P(xx, hy + 1, IRON[2]) end end end
  local top = c:ellipse(x, y - 26, 11, 3); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, (xx + yy < x + y - 25) and "#a8dce0" or "#52a0b8") end)
  P(x - 4, y - 27, "#ffffff"); P(x - 3, y - 27, "#e8f4f8")
end
PR.pumpkin = function(x, y)
  shadow(x, y, 16)
  for _, p in ipairs{ { x + 6, y - 6, 8, 6 }, { x - 8, y - 5, 6, 5 } } do
    qe(nil, p[1], p[2], p[3], p[4], function(xx, yy) local l = lit(xx, yy, p[1], p[2], p[3]); local t = (l > .4) and ORG[5] or ((l > -.2) and ORG[4] or ORG[3]); if (xx - p[1]) % 4 == 0 then t = ORG[2] end; return t end, true)
    for yy = p[2] - p[4], p[2] + p[4] do if (yy % 3) ~= 0 then P(p[1], yy, ORG[3]) end end
    P(p[1], p[2] - p[4] - 1, "#5a3c1c"); P(p[1], p[2] - p[4] - 2, "#5a3c1c"); P(p[1] + 1, p[2] - p[4] - 2, "#3f9150")
  end
end
PR.planter = function(x, y)
  shadow(x, y, 14)
  local m = S.rr(x - 13, y - 10, x + 13, y, 2); c:rim(m, INK); S.planks(m, TIMB, { w = 6, base = 3, seed = 5 })
  local soil = rect(x - 12, y - 12, x + 12, y - 9); c:rim(soil, INK); c:fillMask(soil, DIRT[2]); for xx = x - 10, x + 10, 3 do P(xx, y - 11, DIRT[3]) end
  for _, sx in ipairs{ x - 7, x, x + 7 } do
    for yy = y - 12, y - 20, -1 do P(sx, yy, GREEN[4]) end
    qe(nil, sx - 3, y - 21, 3, 2, function() return LEAF[4] end, true); qe(nil, sx + 3, y - 22, 3, 2, function() return LEAF[5] end, true)
  end
end
PR.sproutpot = function(x, y)
  shadow(x, y, 10)
  local m = HP.mask(); for yy = y - 14, y do local ins = (yy - y + 14) // 5; for xx = x - 8 + ins, x + 8 - ins do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) local t = (xx < x - 3) and ORG[5] or ((xx > x + 3) and ORG[3] or ORG[4]); if yy <= y - 12 then t = ORG[5] elseif yy == y - 11 then t = ORG[2] end; P(xx, yy, t) end)
  for yy = y - 15, y - 28, -1 do P(x, yy, GREEN[4]) end
  qe(nil, x - 5, y - 28, 5, 3, function(xx, yy) return (yy < y - 28) and LEAF[5] or LEAF[4] end, true)
  qe(nil, x + 5, y - 31, 5, 3, function(xx, yy) return (yy < y - 31) and LEAF[6] or LEAF[4] end, true)
  P(x - 7, y - 28, LEAF[6])
end
PR.bookstack = function(x, y)
  shadow(x, y, 16)
  local bc = { { "#b0343a", "#ec7a58" }, { "#3f6cb4", "#82b4e4" }, { "#3f8c50", "#86b06a" }, { "#9a4c94", "#dca0d4" } }
  local yy = y
  for i, w in ipairs{ 24, 20, 22, 17 } do
    local bx = x - w // 2 + ((i % 2 == 0) and 1 or -1)
    local m = rect(bx, yy - 6, bx + w, yy); c:rim(m, INK)
    m:each(function(xx, y2) local t = bc[i][1]; if y2 == yy - 6 then t = bc[i][2] end; if xx > bx + w - 3 and y2 > yy - 5 and y2 < yy - 1 then t = "#f8ecd0" end; P(xx, y2, t) end)
    P(bx + 4, yy - 3, "#ffd24a"); P(bx + 5, yy - 3, "#ffd24a")
    yy = yy - 6
  end
  local ink = rect(x - 3, yy - 6, x + 3, yy); c:rim(ink, INK); c:fillMask(ink, "#2f4a8c"); c:fillMask(rect(x - 2, yy - 6, x + 2, yy - 5), "#82b4e4")
  local ql = c:line({ { x + 3, yy - 5 }, { x + 10, yy - 20 } }, 2); c:rim(ql, INK); c:fillMask(ql, "#fff6e0"); P(x + 10, yy - 20, "#e8cfa4")
end
PR.violin = function(x, y)
  local bm = c:ellipse(x, y - 14, 8, 11); c:rim(bm, INK)
  bm:each(function(xx, yy) local l = lit(xx, yy, x, y - 14, 10); P(xx, yy, ORG[l > .3 and 5 or (l > -.3 and 4 or 3)]) end)
  for yy = y - 16, y - 10 do P(x - 8, yy, INK); P(x + 8, yy, INK) end
  P(x - 4, y - 16, INK); P(x - 4, y - 15, INK); P(x - 4, y - 14, INK); P(x + 4, y - 16, INK); P(x + 4, y - 15, INK); P(x + 4, y - 14, INK)
  for yy = y - 25, y - 4 do P(x, yy, "#3a2030") end
  local nk = rect(x - 1, y - 40, x + 1, y - 24); c:rim(nk, INK); c:fillMask(nk, "#5a3420"); c:fillMask(rect(x - 3, y - 45, x + 3, y - 41), INK); c:fillMask(rect(x - 2, y - 44, x + 2, y - 42), ORG[4])
  c:fillMask(rect(x - 4, y - 5, x + 4, y - 4), "#3a2030")
  local bow = c:line({ { x + 13, y }, { x + 18, y - 38 } }, 1); c:fillMask(bow, INK); P(x + 14, y - 8, "#fff6e0"); P(x + 15, y - 20, "#fff6e0")
  shadow(x + 4, y, 12)
end
PR.washline = function(x0, x1, y)
  for _, px in ipairs{ x0, x1 } do local pm = rect(px, y, px + 2, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 }) end
  for x = x0 + 3, x1 - 1 do local sy = y + 2 + floor(sin((x - x0) / (x1 - x0) * 3.1416) * 6); P(x, sy, INK); P(x, sy + 1, "#e8e0d0") end
  for i, cx in ipairs{ x0 + 12, x0 + 28, x0 + 46 } do
    local sy = y + 2 + floor(sin((cx - x0) / (x1 - x0) * 3.1416) * 6) + 2
    local cols = { "#e8493b", "#ffd24a", "#8fc0f0" }; local col = cols[i]
    local m = rect(cx, sy, cx + 6, sy + 9); m:add(rect(cx, sy + 8, cx + 8, sy + 11)); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (xx < cx + 2) and mixc(col, "#ffffff", .3) or col) end)
    for xx = cx, cx + 6 do P(xx, sy + 3, "#fff2dc") end
  end
end
PR.wallclock = function(x, y)
  S.glow(x, y, 14, "#ffd070", .25)
  qe(nil, x, y, 9, 9, function(xx, yy) local l = lit(xx, yy, x, y, 9); return GOLD[l > .5 and 6 or (l > 0 and 5 or 3)] end, true)
  qe(nil, x, y, 6, 6, function() return "#fff6e0" end, true)
  for k = 0, 11 do local a = k * .5236; P(floor(x + cos(a) * 5 + .5), floor(y + sin(a) * 5 + .5), INK) end
  for t = 0, 4 do P(x, y - t, INK) end; for t = 0, 3 do P(x + t, y, "#b0343a") end
  P(x, y, INK)
  for yy = y + 10, y + 15 do P(x, yy, IRON[4]) end; c:fillMask(rect(x - 2, y + 16, x + 2, y + 18), INK); c:fillMask(rect(x - 1, y + 16, x + 1, y + 17), GOLD[4])
end
PR.sundial = function(x, y)
  shadow(x, y, 14)
  local pm = rect(x - 5, y - 18, x + 5, y); c:rim(pm, INK); S.obj(pm, STONE, { base = 4, lit = 1, shade = 1 })
  for xx = x - 6, x + 6 do P(xx, y - 1, INK) end
  local top = c:ellipse(x, y - 21, 13, 4); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, (xx + yy < x + y - 20) and STONE[6] or STONE[5]) end)
  for k = 0, 6 do local a = 3.4 + k * .4; P(floor(x + cos(a) * 10), floor(y - 21 + sin(a) * 2.6), STONE[2]) end
  local g = HP.mask(); for k = 0, 8 do g:set(x + 2 - k // 3, y - 22 - k); end
  c:rim(g, INK); g:each(function(xx, yy) P(xx, yy, GOLD[5]) end)
end
PR.cairn = function(x, y, a)
  shadow(x, y, 14)
  local yy = y
  for i, s in ipairs{ { 0, 12, 7 }, { 1, 9, 6 }, { -1, 7, 5 }, { 0, 4, 4 } } do
    local cy = yy - s[3]
    qe(nil, x + s[1], cy, s[2], s[3], function(xx, y2) local l = lit(xx, y2, x + s[1], cy, s[2]); return STONE[l > .4 and 6 or (l > -.2 and 5 or (l > -.6 and 4 or 3))] end, true)
    if i == 1 then P(x - 5, cy + 1, GREEN[4]); P(x - 4, cy + 2, GREEN[3]); P(x + 6, cy + 2, GREEN[4]) end
    yy = yy - s[3] * 2 + 1
  end
end
PR.birdhouse = function(x, y)   -- (x,y) = top of the rope
  for yy = y, y + 8 do P(x, yy, "#c8a060") end
  local b = rect(x - 7, y + 14, x + 7, y + 27); c:rim(b, INK); S.planks(b, TIMB, { w = 3, base = 5, seed = 2 })
  local r = HP.mask(); for yy = y + 8, y + 14 do local hw = 3 + (yy - y - 8) * 1.2; for xx = floor(x - hw), floor(x + hw) do r:set(xx, yy) end end
  c:rim(r, INK); r:each(function(xx, yy) P(xx, yy, (xx < x) and "#e8493b" or "#b0343a") end)
  qe(nil, x, y + 20, 2, 2, function() return "#2a1a10" end, true)
  c:fillMask(rect(x - 2, y + 25, x + 2, y + 26), "#a07848")
end
PR.bunting = function(x0, y0, x1, y1, cols)
  for x = x0, x1 do local t = (x - x0) / (x1 - x0); local y = floor(y0 + (y1 - y0) * t + sin(t * 3.1416) * 7); P(x, y, INK) end
  local i = 0
  for x = x0 + 5, x1 - 4, 9 do
    i = i + 1; local t = (x - x0) / (x1 - x0); local y = floor(y0 + (y1 - y0) * t + sin(t * 3.1416) * 7)
    local f = HP.mask(); for k = 0, 8 do for xx = x - 3 + k // 3, x + 3 - k // 3 do f:set(xx, y + 1 + k) end end
    c:rim(f, INK); local col = cols[i % #cols + 1]; f:each(function(xx, yy) P(xx, yy, (xx < x) and mixc(col, "#ffffff", .25) or col) end)
  end
end
PR.crate = function(x, y)
  shadow(x, y, 18)
  for _, b in ipairs{ { x - 14, y - 15, x + 4, y }, { x + 6, y - 11, x + 20, y }, { x - 9, y - 29, x + 7, y - 15 } } do
    local m = rect(b[1], b[2], b[3], b[4]); c:rim(m, INK); S.planks(m, TIMB, { w = 4, base = 4, seed = b[1] })
    for xx = b[1], b[3] do P(xx, b[2] + 1, TIMB[6]); P(xx, b[4] - 1, TIMB[2]) end
    for k = 0, 8 do local px = b[1] + 1 + k * (b[3] - b[1] - 2) // 8; local py = b[2] + 1 + k * (b[4] - b[2] - 2) // 8; P(px, py, TIMB[2]) end
  end
end
PR.bigflower = function(x, y, col)
  col = col or "#ffd24a"
  for yy = y, y - 44, -1 do P(x, yy, GREEN[3]); P(x + 1, yy, GREEN[4]) end
  qe(nil, x - 7, y - 16, 6, 2, function() return LEAF[4] end, true); qe(nil, x + 8, y - 26, 6, 2, function() return LEAF[5] end, true)
  for k = 0, 11 do local a = k * .5236; qe(nil, floor(x + cos(a) * 8 + .5), floor(y - 48 + sin(a) * 8 + .5), 2, 2, function(xx, yy) return (xx + yy < x + y - 48) and mixc(col, "#ffffff", .4) or col end, true) end
  qe(nil, x, y - 48, 6, 6, function(xx, yy) local l = lit(xx, yy, x, y - 48, 6); return (l > .2) and "#7a4a2c" or "#4a2c1a" end, true)
  P(x - 2, y - 50, "#a8704a"); P(x + 1, y - 46, "#2a1a10"); P(x - 1, y - 47, "#2a1a10")
end
PR.bush = function(x, y, bc)
  shadow(x, y, 22)
  for _, d in ipairs{ { -12, -9, 11 }, { 12, -9, 11 }, { 0, -14, 13 } } do discPaint(x + d[1], y + d[2], d[3], GREEN) end
  for i = 1, 14 do local bx, by = x - 18 + floor(hash(i, 1, 8) * 36), y - 24 + floor(hash(i, 2, 8) * 20)
    qe(nil, bx, by, 2, 2, function(xx, yy) return (xx + yy < bx + by) and "#8a5ac0" or (bc or "#3c2050") end, true) end
end
PR.pinwheel = function(x, y)
  for yy = y, y - 38, -1 do P(x, yy, INK); P(x + 1, yy, TIMB[4]) end
  local cols = { "#e8493b", "#ffd24a", "#3f9fd0", "#f090c0" }
  for k = 0, 3 do
    local a = k * 1.5708 + .3
    local tm = HP.mask()
    for t = 0, 10 do for w = 0, t // 2 do tm:set(floor(x + cos(a) * t + cos(a + 1.57) * w * .6), floor(y - 40 + sin(a) * t + sin(a + 1.57) * w * .6)) end end
    c:rim(tm, INK); c:fillMask(tm, cols[k + 1]); P(floor(x + cos(a) * 6), floor(y - 40 + sin(a) * 6), "#ffffff")
  end
  c:fillMask(rect(x - 1, y - 41, x + 1, y - 39), "#ffe38a"); P(x, y - 40, INK)
end
PR.easel = function(x, y)
  shadow(x, y, 16)
  for _, l in ipairs{ { x - 14, y, x - 2, y - 60 }, { x + 14, y, x + 2, y - 60 }, { x, y - 6, x, y - 56 } } do
    local m = c:line({ { l[1], l[2] }, { l[3], l[4] } }, 2); c:rim(m, INK); S.obj(m, TIMB, { base = 4, lit = 1, shade = 1 })
  end
  local cv = rect(x - 13, y - 52, x + 13, y - 20); c:rim(cv, INK); c:fillMask(cv, "#f8f0e0")
  for xx = x - 12, x + 12 do P(xx, y - 21, "#d8c8a8") end
  for yy = y - 51, y - 38 do for xx = x - 12, x + 12 do P(xx, yy, (yy < y - 46 + floor(sin(xx / 4) * 1.5)) and "#82b4e4" or "#98c8ec") end end
  for xx = x - 12, x + 12 do local gy = y - 38 + floor(sin(xx / 5) * 2); for yy = gy, y - 22 do P(xx, yy, (yy % 4 == 0) and "#5a9c4a" or "#7ab85a") end end
  for xx = x - 4, x + 1 do P(xx, y - 28, "#ffd24a"); P(xx, y - 29, "#e8493b") end; P(x + 6, y - 44, "#fff6e0"); P(x + 7, y - 44, "#fff6e0")
  local pm = rect(x + 15, y - 8, x + 24, y); c:rim(pm, INK); c:fillMask(pm, "#dcdce8"); c:fillMask(rect(x + 16, y - 8, x + 23, y - 7), "#e8493b"); P(x + 19, y - 8, "#3f6cb4")
  local br = c:line({ { x + 22, y - 9 }, { x + 26, y - 20 } }, 1); c:fillMask(br, INK); P(x + 26, y - 21, "#3f6cb4")
end
PR.crystals = function(x, y)
  shadow(x, y, 16)
  for _, s in ipairs{ { -9, 20, 4, "#c8a8ff" }, { 0, 32, 5, "#7af0e0" }, { 9, 24, 4, "#ff8ab8" }, { -3, 16, 3, "#ffd24a" } } do
    local m = HP.mask(); for yy = 0, s[2] do local hw = (yy < s[2] - 8) and s[3] or max(0, floor(s[3] * (s[2] - yy) / 8)); for xx = x + s[1] - hw, x + s[1] + hw do m:set(xx, y - yy) end end
    c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, (xx < x + s[1]) and mixc(s[4], "#ffffff", .5) or s[4]) end)
    P(x + s[1] - 1, y - s[2] + 8, "#ffffff")
  end
  S.glow(x, y - 16, 20, "#c8a8ff", .25)
end
PR.grapes = function(x, y)   -- (x,y) = top of the vine
  for yy = y - 6, y + 4 do P(x, yy, "#3f8c40") end
  qe(nil, x - 4, y + 1, 4, 2, function() return LEAF[4] end, true); qe(nil, x + 5, y + 2, 3, 2, function() return LEAF[5] end, true)
  for r = 0, 5 do for k = 0, 4 - r // 1 do
    local gx, gy = x - (4 - r) + k * 2 + (r % 2), y + 6 + r * 4
    qe(nil, gx, gy, 2, 2, function(xx, yy) return (xx + yy < gx + gy) and "#8a5ac0" or "#4a2468" end, true)
  end end
end
PR.leafbrella = function(x, y)
  shadow(x, y, 12)
  local st = c:line({ { x, y }, { x + 2, y - 36 } }, 1); c:fillMask(st, INK)
  local lm = HP.mask(); for t = 0, 1, .03 do local lx, ly = x + 2 + cos(3.3 + t * 2.2) * 20 * (0.5 + t), y - 38 + sin(3.3 + t * 2.2) * 9; GX.disc(lm, floor(lx), floor(ly), 3) end
  GX.disc(lm, x - 12, y - 34, 6); GX.disc(lm, x + 14, y - 34, 6); GX.disc(lm, x + 1, y - 40, 7)
  c:rim(lm, INK); lm:each(function(xx, yy) local l = lit(xx, yy, x, y - 36, 16); P(xx, yy, LEAF[l > .3 and 5 or (l > -.3 and 4 or 3)]) end)
  for xx = x - 14, x + 16, 1 do P(xx, y - 35 + floor(abs(xx - x) / 8), LEAF[2]) end
  for k = -2, 2 do for t = 0, 8 do P(x + 1 + k * t // 2, y - 36 - 4 + t // 2 + abs(k) * t // 3, LEAF[6]) end end
end
PR.fruitbowl = function(x, y)
  shadow(x, y, 16)
  local st = c:ellipse(x, y - 5, 11, 5):clip(rect(x - 12, y - 8, x + 12, y)); c:rim(st, INK); S.planks(st, TIMB, { w = 5, base = 4, seed = 7 })
  local bm = c:ellipse(x, y - 14, 11, 7):clip(rect(x - 12, y - 14, x + 12, y - 5)); c:rim(bm, INK); bm:each(function(xx, yy) P(xx, yy, (xx < x - 3) and "#a8e0d0" or ((xx > x + 5) and "#3f8c94" or "#58c4c0")) end)
  for i, f in ipairs{ { -6, "#e8493b" }, { 0, "#ffd24a" }, { 6, "#f08838" }, { -2, "#9a4c94" } } do
    local fx, fy = x + f[1], y - 17 - (i == 4 and 4 or 0)
    qe(nil, fx, fy, 4, 4, function(xx, yy) return (xx + yy < fx + fy) and mixc(f[2], "#ffffff", .35) or f[2] end, true)
    P(fx, fy - 5, "#5a3c1c"); P(fx + 1, fy - 5, "#3f9150")
  end
end
PR.stump = function(x, y)
  shadow(x, y, 16)
  local m = rect(x - 11, y - 13, x + 11, y); m:add(rect(x - 14, y - 4, x + 14, y)); c:rim(m, INK)
  m:each(function(xx, yy) local t = (xx < x - 4) and 5 or ((xx > x + 5) and 3 or 4); if (xx + yy // 2) % 5 == 0 then t = t - 1 end; P(xx, yy, OAK[t]) end)
  local top = c:ellipse(x, y - 13, 11, 4); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, ((abs(xx - x) + abs(yy - y + 13) * 2) % 5 == 0) and OAK[4] or OAK[5]) end)
  P(x, y - 13, OAK[3]); P(x + 1, y - 13, OAK[3])
  for xx = x - 10, x - 6 do P(xx, y - 10, GREEN[4]); P(xx, y - 9, GREEN[3]) end
end
PR.cheese = function(x, y)
  shadow(x, y, 14)
  local m = HP.mask(); for yy = y - 16, y do local hw = floor((yy - y + 16) * 1.2); for xx = x - hw, x + hw do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, (xx < x) and "#ffe070" or "#e8b030") end)
  for xx = x - 19, x + 19 do if m:has(xx, y - 1) then P(xx, y - 1, "#c88a20") end end
  for _, h in ipairs{ { -4, -4 }, { 5, -7 }, { 2, -2 }, { -9, -2 } } do c:fillMask(rect(x + h[1], y + h[2], x + h[1] + 2, y + h[2] + 1), "#b87a18") end
end
PR.scroll = function(x, y)
  for yy = y - 8, y do P(x, yy, "#c8a060") end
  local m = rect(x - 6, y, x + 6, y + 22); c:rim(m, INK); c:fillMask(m, "#f4e6c8")
  for xx = x - 6, x + 6 do P(xx, y + 21, "#c8a878") end
  for _, w in ipairs{ 4, 8, 12, 16 } do for xx = x - 4, x + 3 - (w % 8 == 0 and 2 or 0) do P(xx, y + w, "#7a5a30") end end
  for _, yy in ipairs{ y - 1, y + 23 } do c:fillMask(rect(x - 8, yy, x + 8, yy + 1), INK); c:fillMask(rect(x - 7, yy, x + 7, yy), TIMB[5]) end
  P(x + 4, y + 18, "#e8493b")
end
PR.cane = function(x, y)
  local m = c:line({ { x, y }, { x + 1, y - 40 }, { x + 7, y - 46 }, { x + 11, y - 40 } }, 2); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, ((xx + yy // 3) % 4 == 0) and TIMB[3] or TIMB[5]) end)
  c:fillMask(rect(x - 1, y - 30, x + 2, y - 28), "#c8a060")
  shadow(x, y, 6)
end
PR.mushroomset = function(x, y)
  mushroom(x, y, 4, "#e8493b"); mushroom(x + 14, y + 3, 2, "#e8493b"); mushroom(x - 10, y + 4, 2, "#f5809f")
end
PR.acorn = function(x, y) acorn(x, y) end
PR.herbs = function(x) herbs(x) end
PR.chimes = function(x) chimes(x) end
PR.can = function(x, y) can(x, y) end
PR.staff = function(x) staff(x) end
PR.trellis = function(x) trellis(x) end
PR.trail = function() trail() end

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

---------------------------------------------------------------- the 20 villagers
local ENV = {
  sand = { sky = { "#8ec8e8", "#a8d8ec", "#c4e4ee", "#f0e8cc", "#f8dcb0" }, cl = { "#fff4e0", "#f0d0b0" }, hill = { "#a8784c", "#bc8c58", "#d0a468", "#e0bc7c", "#ecd096", "#f4e0ac" }, grass = { "#97754a", "#b8935e", "#d0b078", "#e8d09a", "#f0dcaa", "#f8e8bc" }, tuft = { "#6a502e", "#8a6a34", "#a8863c", "#c2a04a", "#d8b862", "#e8cc7c" }, side = "banana" },
  meadow = { sky = { "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8" }, cl = { "#f8f0e0", "#d6e6f0" }, hill = { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, grass = GREEN, tuft = GREEN, side = "bush", flowers = { "#f0809c", "#ffd24a", "#fff2dc" }, pebble = "#a8a890" },
  rocks = { sky = { "#a4b4c8", "#b8c4d4", "#ccd4e0", "#dce0e8", "#eceef0" }, cl = { "#f4f4f4", "#d0d8e4" }, hill = { "#4a566e", "#5c6a84", "#74829c", "#8e9cb4", "#aab6ca", "#c4cedc" }, grass = { "#4a5a4a", "#627464", "#7a8e78", "#94a892", "#aec0aa", "#c4d4c0" }, tuft = { "#4a5a4a", "#627464", "#7a8e78", "#94a892", "#aec0aa", "#c4d4c0" }, side = "rocks", pebble = "#8a8a9a" },
  dawn = { sky = { "#b8a4d8", "#d0b0d8", "#e8c0d8", "#f8d0cc", "#fce0c0" }, cl = { "#fff0e8", "#f0c8d8" }, hill = { "#5a4a7a", "#6e5c90", "#8a74a8", "#a88cc0", "#c4a8d4", "#dcc4e4" }, grass = { "#4a6a48", "#5e8458", "#78a068", "#94bc7c", "#b0d494", "#cce8ac" }, tuft = { "#4a6a48", "#5e8458", "#78a068", "#94bc7c", "#b0d494", "#cce8ac" }, side = "bush", flowers = { "#f8a0c8", "#c8b8ec", "#fff2dc" }, pebble = "#b098a8" },
}
local V = {
 ["auntie-mossbead"] = { kind = "treehouse", shape = "arch", frame = TIMB, wood = PLM, ov = "scales", plate = TIMB, trunk = OAK, fol1 = GREEN, fol2 = LEAF, seed = 9, straps = { 152, 184 },
   props = { { "ladder", 186 }, { "fruitbowl", 116, 206 }, { "birdhouse", 286, 132 } } },
 ["bramble-mossfoot"] = { kind = "treehouse", shape = "round", frame = OAK, wood = REDW, ov = "spots", plate = OAK, trunk = TIMB, fol1 = LEAF, fol2 = GREEN, seed = 4, fseed = 33, fl = { "#f0809c", "#fff2dc", "#c8b8ec" },
   props = { { "shelf", 288, 156 }, { "mushroomset", 124, 206 }, { "stump", 84, 206 } } },
 ["ember-seedwell"] = { kind = "treehouse", shape = "arch", frame = TIMB, wood = BARN, ov = "spiral", plate = TIMB, trunk = OAK, fol1 = AUTUMN, fol2 = ORG, seed = 12, fl = { "#ffd24a", "#fff2dc", "#f0809c" },
   props = { { "sproutpot", 126, 206 }, { "acorn", 292, 206 }, { "trail" } } },
 ["ivy-brambleby"] = { kind = "treehouse", shape = "point", frame = TIMB, wood = MOSSR, ov = "leaf", plate = OAK, trunk = SND, fol1 = LEAF, fol2 = GREEN, seed = 15,
   props = { { "ladder", 186 }, { "grapes", 280, 138 } } },
 ["juniper-seedwell"] = { kind = "treehouse", shape = "arch", frame = TIMB, wood = YEL, ov = "stripes", plate = YEL, trunk = OAK, fol1 = BLOSS, fol2 = GREEN, seed = 17, fl = { "#f8b8cc", "#fff2dc", "#ffd24a" },
   props = { { "ladder", 186 }, { "skep", 114, 206 }, { "bigflower", 84, 206, "#ffd24a" } } },
 ["sorrel-inkcap"] = { kind = "treehouse", shape = "rect", frame = OAK, wood = DKS, ov = "feather", plate = TAN, trunk = TAN, fol1 = TLW, fol2 = GREEN, seed = 21,
   props = { { "bookstack", 112, 206 }, { "scroll", 284, 132 }, { "shelf", 280, 168 } } },
 ["burdock-puddlejump"] = { kind = "boat", shape = "arch", frame = CREAM, wood = ORG, ov = "port", plate = OAK, cabin = TEAL, roof = BARN, hull = SBLUE, ring = true, seed = 5,
   props = { { "bunting", 156, 100, 212, 100, { "#e8493b", "#ffd24a", "#f090c0", "#3f9fd0" } }, { "leafbrella", 176, 204 }, { "crate", 424, 200 } } },
 ["nutmeg-rootstock"] = { kind = "boat", shape = "rect", frame = OAK, wood = GREEN, ov = "gear", plate = OAK, cabin = OLV, roof = SLT, hull = REDW, port = true, seed = 8, chim = DKS,
   props = { { "planter", 178, 204 }, { "sproutpot", 296, 204 }, { "barrel", 432, 200 } } },
 ["coral-pennyfeather"] = { kind = "stone", shape = "arch", frame = STONE, wood = SLT, ov = "plaid", plate = OAK, stone = STONE, roof = BARN, seed = 6, straps = { 150, 184 },
   props = { { "rod", 160, 206 }, { "pail", 194, 206 }, { "boots", 292, 206 } } },
 ["lyra-fiddlewing"] = { kind = "stone", shape = "arch", frame = OAK, wood = TAN, ov = "notes", plate = YEL, stone = SND, roof = YEL, seed = 14, sseed = 9, fl = { "#ffd24a", "#fff2dc", "#f0809c" },
   props = { { "violin", 174, 206 }, { "bunting", 146, 98, 210, 100, { "#ffd24a", "#fff2dc", "#82b4e4", "#f090c0" } }, { "sproutpot", 428, 206 } } },
 ["tobias-trundle"] = { kind = "stone", shape = "round", frame = STONE, wood = GOLD, ov = "hex", plate = SLT, stone = DKS, roof = SLT, roofmoss = true, moss = .08, seed = 3, sseed = 12,
   props = { { "sundial", 158, 206 }, { "cane", 292, 206 }, { "stump", 432, 206 } } },
 ["ginger-thornwhistle"] = { kind = "hut", env = ENV.sand, shape = "arch", frame = TIMB, wood = PNK, ov = "sun", plate = PNK, roof = THATCH, seed = 11,
   props = { { "pinwheel", 176, 206 }, { "chimes", 194 }, { "pumpkin", 436, 206 } } },
 ["hazel-brambleby"] = { kind = "hut", env = ENV.meadow, shape = "rect", frame = OAK, wood = BLUEW, ov = "berries", plate = OAK, wall = SND, roof = MOSSR, woven = true, seed = 7,
   props = { { "bush", 108, 206 }, { "herbs", 188 }, { "bush", 432, 206, "#e8493b" } } },
 ["pebble-barkley"] = { kind = "hut", env = ENV.rocks, shape = "rect", frame = STONE, wood = REDW, ov = "pebbles", plate = STONE, wall = SND, roof = DKS, seed = 13,
   props = { { "cairn", 166, 206 }, { "cairn", 112, 206 }, { "fruitbowl", 432, 206 } } },
 ["woad"] = { kind = "hut", env = ENV.dawn, shape = "arch", frame = TIMB, wood = SND, ov = "splat", plate = PLM, wall = SAGEP, roof = PLM, seed = 19,
   props = { { "easel", 158, 206 }, { "birdhouse", 282, 134 }, { "can", 420, 205 } } },
 ["marigold-tuftwhistle"] = { kind = "cottage", shape = "arch", frame = TIMB, wood = CREAM, ov = "knit", plate = ORG, wall = PEACH, roof = ORG, shut = YEL, seed = 3,
   box1 = { "#e8493b", "#ffd24a", "#f0809c" }, box2 = { "#ffd24a", "#f08838", "#fff2dc" },
   props = { { "washline", 36, 96, 156 }, { "bigflower", 188, 206, "#ffa020" }, { "pumpkin", 440, 206 } } },
 ["pomeroy-crumbworth"] = { kind = "cottage", shape = "point", frame = STONE, wood = VIO, ov = "window", plate = VIO, wall = SAGEP, roof = SLT, shut = PNK, seed = 6, beam = OAK,
   box1 = { "#c8b8ec", "#fff2dc", "#f0809c" }, box2 = { "#82b4e4", "#fff2dc", "#ffd24a" },
   props = { { "wallclock", 194, 118 }, { "cheese", 440, 206 }, { "can", 120, 205 } } },
 ["nettle-thornwhistle"] = { kind = "burrow", shape = "round", frame = STONE, wood = TEAL, ov = "gems", plate = OAK, hill = OLV, post = TIMB, seed = 6, fl = { "#c8a8ff", "#ffd24a", "#fff2dc" },
   props = { { "crystals", 150, 206 }, { "staff", 412 } } },
 ["reed-hollowell"] = { kind = "burrow", shape = "round", frame = STONE, wood = SBLUE, ov = "lily", plate = OAK, hill = MOSSR, far = { "#2c5a58", "#3a6e6a", "#4c8480", "#62a09a", "#7ab8b0", "#98ccc4" }, post = TIMB, seed = 7, fl = { "#f8a0c8", "#fff2dc", "#82b4e4" },
   props = { { "cattails", 158, 206 }, { "barrel", 424, 206 } } },
 ["zinnia-fuzzbottom"] = { kind = "burrow", shape = "round", frame = OAK, wood = ORG, ov = "petals", ova = { pet = "#fff2dc" }, plate = TIMB, hill = GREEN, post = TIMB, seed = 9, fl = { "#f08838", "#ffd24a", "#f0809c" },
   props = { { "bigflower", 156, 206, "#f08838" }, { "skep", 424, 206 } } },
}
local p = V[name]
K[p.kind](p)
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end

local ORDER = { "auntie-mossbead", "bramble-mossfoot", "burdock-puddlejump", "coral-pennyfeather", "ember-seedwell", "ginger-thornwhistle", "hazel-brambleby", "ivy-brambleby", "juniper-seedwell", "lyra-fiddlewing", "marigold-tuftwhistle", "nettle-thornwhistle", "nutmeg-rootstock", "pebble-barkley", "pomeroy-crumbworth", "reed-hollowell", "sorrel-inkcap", "tobias-trundle", "woad", "zinnia-fuzzbottom" }
for _, n in ipairs(NAME == "all" and ORDER or { NAME }) do
  local ok, err = pcall(build, n)
  if not ok then print("FAIL " .. n .. ": " .. tostring(err)) end
end

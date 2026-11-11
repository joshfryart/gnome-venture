local LIST = {"auntie-saffira","bramble-sunpatch","captain-pipi-shellback","cricket-hollowell","fennick-barkley","gloam","hazel-dewberry","jasper-burrowman","kestrel-petalwing","madder-quillfeather","moss-petalwing","nocturna","oakley-mossfoot","pebble-leafwhisker","poppy-puddlejump","rowan-burrowman","sorrel-petalwing","tumble-seedwell","wren-thimblewick"}
-- door.lua: a villager's front door seen straight on, 480x270, six habitats. Param: name=cottage|burrow|treehouse|hut|stone|boat (or all)
-- Run: AppRun -b --script-param name=cottage --script door.lua   -> out/door-<name>.png/.aseprite
-- Contract: door centred (240,170) [x218..261, y136..204], blank name plate at (240,84), lantern at (300,120), basket spot (350,206) left empty.
local V3 = "/home/user/gnome-venture/aseprite-source/v3"
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, sin, cos, sqrt, abs = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs
local INK = "#2b1c26"
local NAME = app.params.name or "auntie-saffira"
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
  if o.body then o.body(cx, cy); return end
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

-- ===================== w3: ramps, prop library, overlays
local PR, OV, H, LB = {}, {}, {}, {}
local pi = math.pi
local R = { TIMB=TIMB, OAK=OAK, CREAM=CREAM, ROSE=ROSE, GREEN=GREEN, LEAF=LEAF, SBLUE=SBLUE, BARN=BARN, GOLD=GOLD, STONE=STONE, TEAL=TEAL, VIOLET=VIOLET, PINK=PINK, DIRT=DIRT, IRON=IRON, BLUEW=BLUEW, REDW=REDW, VIO=VIO, MOSSR=MOSSR, THATCH=THATCH,
  YEL   = {"#6a4a14","#a07a22","#d4a63a","#f0c85a","#f8e08a","#fff2bc"},
  ORG   = {"#4a1e12","#7e3418","#b8501e","#e07a30","#f4a04e","#fccc8a"},
  PLUM  = {"#241230","#3e2250","#603a74","#865a98","#ac82bc","#d4b0e0"},
  MINT  = {"#1e3c3a","#2e5e54","#468070","#68a48a","#98c8a8","#c8e8c4"},
  NAVY  = {"#141c38","#1f2f5a","#2e4a84","#4468a8","#6a8cc8","#9ab6e4"},
  CORAL = {"#4a1a2a","#7c2c3c","#b8465a","#e0707a","#f4a0a0","#fcd0cc"},
  PASTEL= {"#7a3a58","#a85a7c","#d482a4","#f0a8c4","#f8c8dc","#fde4ee"},
  PEACH = {"#6a3a2a","#a45c3c","#d88a5a","#f0b080","#f8d0a0","#fce8c8"},
  LAV   = {"#3e3468","#5c4e92","#8478b8","#a89cd4","#c8bee8","#e4def6"},
  NIGHT = {"#140e20","#221838","#342856","#4c3c78","#6a5a9a","#9484bc"},
  SAGE  = {"#2c4234","#44624a","#648464","#88a880","#b0c8a0","#d4e4c0"},
}
local function bx(x0, y0, x1, y1, r, band)
  local m = rect(x0, y0, x1, y1); c:rim(m, INK)
  m:each(function(x, y)
    local t = 4
    if y == y0 or x == x0 then t = 5 elseif y == y1 or x == x1 then t = 3 end
    if band and (x - x0) % band == 0 and x > x0 then t = 3 end
    P(x, y, r[t])
  end)
  return m
end
local function ball(cx, cy, rx, ry, r)
  local m = c:ellipse(cx, cy, rx, ry); c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, cx, cy, max(rx, ry)); P(x, y, r[l > .6 and 5 or (l > .1 and 4 or (l > -.5 and 3 or 2))]) end)
  return m
end
local function ln(pts, w, r, t)   -- inked line with a flat ramp colour
  local m = c:line(pts, w); c:rim(m, INK); c:fillMask(m, r[t or 4]); return m
end
local function pxs(list, col) for _, q in ipairs(list) do P(q[1], q[2], col) end end

---------------------------------------------------------------- ground props (y = baseline)
function PR.bench(x, y, cush)
  bx(x + 2, y - 8, x + 4, y, TIMB); bx(x + 25, y - 8, x + 27, y, TIMB)
  bx(x + 3, y - 20, x + 26, y - 17, TIMB); bx(x + 4, y - 17, x + 5, y - 11, TIMB); bx(x + 24, y - 17, x + 25, y - 11, TIMB)
  bx(x, y - 11, x + 29, y - 8, OAK)
  bx(x + 7, y - 14, x + 22, y - 11, cush or R.CORAL)
end
function PR.barrel(x, y, fill)
  local m = rect(x - 8, y - 17, x + 8, y); m:cut(rect(x - 8, y - 17, x - 8, y - 17)); m:cut(rect(x + 8, y - 17, x + 8, y - 17)); c:rim(m, INK)
  m:each(function(xx, yy)
    local t = (xx < x - 4) and 5 or ((xx > x + 3) and 3 or 4)
    if xx > x + 6 then t = 2 end
    if (xx - x + 8) % 5 == 0 then t = t - 1 end
    if yy == y - 17 then t = 6 end
    P(xx, yy, OAK[max(1, t)])
  end)
  for _, yy in ipairs{ y - 13, y - 4 } do for xx = x - 8, x + 8 do P(xx, yy, IRON[3]); P(xx, yy + 1, IRON[5]) end end
  if fill == "apples" then
    for _, q in ipairs{ { -4, -19 }, { 2, -20 }, { 5, -17 }, { -1, -17 } } do ball(x + q[1], y + q[2], 3, 3, R.REDW) end
  elseif fill == "green" then
    for i = -7, 7 do local h = 3 + floor(hash(i, 1, 8) * 5); for k = 0, h do P(x + i, y - 18 - k, GREEN[(k > h - 2) and 5 or 3]) end end
  end
end
function PR.crates(x, y)
  for _, q in ipairs{ { x, y, 12 }, { x + 14, y, 10 }, { x + 2, y - 11, 11 } } do
    local s = q[3]; bx(q[1], q[2] - s, q[1] + s, q[2], TIMB)
    for k = 1, s - 2 do P(q[1] + k, q[2] - s + k, TIMB[2]); P(q[1] + s - k, q[2] - s + k, TIMB[2]) end
  end
end
function PR.pot(x, y, col)
  local m = rect(x - 5, y - 8, x + 5, y); m:cut(rect(x - 5, y, x - 4, y)); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, R.ORG[(xx < x - 2) and 5 or ((xx > x + 2) and 3 or 4)]) end)
  for xx = x - 6, x + 6 do P(xx, y - 9, INK) end
  c:fillMask(rect(x - 6, y - 10, x + 6, y - 8), R.ORG[5]); for xx = x - 7, x + 7 do P(xx, y - 11, INK) end
  for yy = y - 20, y - 11 do P(x, yy, GREEN[4]) end
  for k = 0, 3 do P(x - 2 - k, y - 14 - k // 2, GREEN[5]); P(x + 2 + k, y - 16 - k // 2, GREEN[5]) end
  ball(x, y - 21, 4, 4, { "#5a2a44", "#8a3a5c", col, col, "#fff2dc", "#fff8f0" }); P(x, y - 21, "#ffd24a")
end
function PR.sunflower(x, y, h)
  for yy = y - h, y do P(x, yy, INK); P(x + 1, yy, GREEN[3]) end
  for k = 0, 5 do P(x - 2 - k, y - h // 2 - k // 2, GREEN[5]); P(x - 2 - k, y - h // 2 - k // 2 + 1, GREEN[3]) end
  for i = 0, 11 do local a = i * pi / 6; P(floor(x + 1 + cos(a) * 8 + .5), floor(y - h + sin(a) * 8 + .5), INK) end
  ball(x + 1, y - h, 7, 7, GOLD)
  ball(x + 1, y - h, 3, 3, { "#2a1810", "#3c2418", "#4a2e1c", "#5a3a22", "#7a5030", "#8a6038" })
  P(x - 3, y - h - 5, "#fff2a0")
end
function PR.pumpkin(x, y, r)
  local m = ball(x, y - r + 1, r, r - 1, R.ORG)
  for _, dx in ipairs{ -r // 2, 0, r // 2 } do for yy = y - 2 * r + 3, y - 1 do if m:has(x + dx, yy) then P(x + dx, yy, R.ORG[2]) end end end
  c:fillMask(rect(x - 1, y - 2 * r, x + 1, y - 2 * r + 2), INK); P(x, y - 2 * r + 1, GREEN[3])
end
function PR.wheelbarrow(x, y, load)
  for _, q in ipairs{ { 4, 6 }, { 14, 3 } } do end
  ln({ { x + 22, y - 12 }, { x + 36, y - 20 } }, 2, TIMB, 4)
  ln({ { x + 16, y - 6 }, { x + 18, y } }, 2, TIMB, 3)
  local tm = rect(x, y - 12, x + 22, y - 6); for k = 0, 2 do tm:cut(rect(x + k * 0, y - 6 + 0, x, y - 6)) end
  c:rim(tm, INK)
  tm:each(function(xx, yy) local t = (yy == y - 12) and 5 or ((yy >= y - 7) and 2 or 3); if xx < x + 3 then t = t + 1 end; P(xx, yy, R.TEAL[min(6, t + 1)]) end)
  ball(x + 4, y - 4, 5, 5, IRON); P(x + 4, y - 4, GOLD[5])
  if load == "pumpkins" then PR.pumpkin(x + 6, y - 11, 4); PR.pumpkin(x + 15, y - 11, 4) end
  if load == "soil" then for xx = x + 1, x + 21 do local h = 2 + floor(hash(xx, 1, 3) * 3); for k = 0, h do P(xx, y - 13 - k, DIRT[2 + k % 3]) end end end
end
function PR.shovel(x, y)
  ln({ { x, y - 2 }, { x + 10, y - 44 } }, 2, TIMB, 4)
  c:fillMask(rect(x + 8, y - 49, x + 14, y - 46), INK); P(x + 10, y - 47, TIMB[5]); P(x + 12, y - 47, TIMB[5])
  local bl = c:ellipse(x - 1, y - 6, 4, 6); bl:cut(rect(x - 6, y - 14, x + 4, y - 11)); c:rim(bl, INK)
  bl:each(function(xx, yy) P(xx, yy, IRON[(xx < x - 1) and 5 or 3]) end)
  P(x - 2, y - 9, IRON[6])
end
function PR.vegrows(x0, x1, y, kind)
  local pm = rect(x0, y, x1, y + 14); c:rim(pm, INK)
  pm:each(function(xx, yy) local t = ((yy - y) % 5 < 2) and 3 or 2; if (yy - y) % 5 == 0 then t = 4 end; P(xx, yy, DIRT[t]) end)
  for yy = y + 3, y + 12, 5 do
    for xx = x0 + 4, x1 - 4, 8 do
      if kind == "carrot" then
        P(xx, yy, "#e8843c"); P(xx + 1, yy, "#f4a04e"); P(xx, yy + 1, "#c0602c")
        for k = 1, 5 do P(xx + (k % 3) - 1 + (k > 3 and 1 or 0), yy - k, GREEN[3 + k % 3]) end
      else
        ball(xx + 1, yy - 1, 4, 3, GREEN); P(xx - 1, yy - 2, GREEN[6]); P(xx + 1, yy - 1, GREEN[2])
      end
    end
  end
end
function PR.logs(x, y)
  for _, q in ipairs{ { 6, 6 }, { 17, 6 }, { 28, 6 }, { 11, 16 }, { 22, 16 } } do
    local cx, cy = x + q[1], y - q[2]
    ball(cx, cy, 5, 5, TIMB); ball(cx, cy, 3, 3, { OAK[3], OAK[4], OAK[5], OAK[5], OAK[6], OAK[6] }); P(cx, cy, OAK[3]); P(cx + 1, cy, OAK[3])
  end
end
function PR.mailbox(x, y, col)
  bx(x, y - 22, x + 2, y, TIMB)
  bx(x - 6, y - 32, x + 9, y - 22, col); for xx = x - 5, x + 8 do P(xx, y - 33, INK) end
  bx(x + 9, y - 36, x + 11, y - 28, R.CORAL)
end
function PR.pinwheel(x, y, h, cols)
  for yy = y - h, y do P(x, yy, INK); P(x + 1, yy, TIMB[4]) end
  local hy = y - h
  local q = { { 1, -1 }, { 1, 1 }, { -1, 1 }, { -1, -1 } }
  for i, d in ipairs(q) do
    for a = 1, 6 do for b = 0, a - 1 do
      local px, py = x + d[1] * a, hy + d[2] * b * (i % 2 == 1 and 1 or 1)
      if i % 2 == 0 then px, py = x + d[1] * b, hy + d[2] * a end
      P(px, py, cols[i]); if b == a - 1 then P(px, py, INK) end
    end end
  end
  P(x, hy, GOLD[5]); P(x + 1, hy, GOLD[3])
end
function PR.signpost(x, y)
  bx(x, y - 44, x + 3, y, TIMB)
  local b1 = bx(x - 15, y - 42, x + 3, y - 34, OAK); P(x - 16, y - 38, INK); P(x - 15, y - 38, OAK[4])
  local b2 = bx(x + 1, y - 30, x + 19, y - 22, OAK); P(x + 20, y - 26, INK); P(x + 19, y - 26, OAK[4])
end
function PR.skep(x, y)
  bx(x - 11, y - 2, x + 11, y, TIMB)
  local m = c:ellipse(x, y - 10, 9, 10):clip(rect(x - 10, y - 21, x + 10, y - 3)); c:rim(m, INK)
  m:each(function(xx, yy)
    local t = (xx < x - 3) and 5 or ((xx > x + 3) and 3 or 4)
    if (yy - y) % 4 == 0 then t = t - 1 end
    P(xx, yy, R.YEL[max(1, t)])
  end)
  c:fillMask(rect(x - 2, y - 7, x + 2, y - 3), INK); P(x - 1, y - 7, "#2a1810")
  P(x, y - 21, INK)
end
function PR.broom(x, y)
  ln({ { x + 9, y - 40 }, { x, y - 6 } }, 2, TIMB, 4)
  local m = rect(x - 5, y - 8, x + 5, y); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, R.YEL[((xx + yy) % 3 == 0) and 3 or 4]) end)
  for xx = x - 5, x + 5 do P(xx, y - 8, ((xx % 2) == 0) and IRON[4] or IRON[3]) end
end
function PR.yarnbasket(x, y)
  ln({ { x - 4, y - 14 }, { x + 7, y - 30 } }, 1, IRON, 5); ln({ { x + 5, y - 14 }, { x - 4, y - 30 } }, 1, IRON, 5)
  P(x + 7, y - 31, GOLD[5]); P(x - 4, y - 31, GOLD[5])
  ball(x - 5, y - 13, 5, 5, R.CORAL); ball(x + 5, y - 14, 5, 5, TEAL); ball(x, y - 18, 4, 4, R.LAV)
  for k = 0, 8 do P(x - 5 + k, y - 12 + (k % 3), R.CORAL[2]) end
  local m = rect(x - 10, y - 9, x + 10, y); m:cut(rect(x - 10, y, x - 10, y)); c:rim(m, INK)
  m:each(function(xx, yy) local a, b = floor(xx / 3), floor(yy / 3); local t = ((a + b) % 2 == 0) and 4 or 3; if yy == y - 9 then t = 6 end; if yy >= y - 1 then t = 2 end; P(xx, yy, DIRT[t]) end)
  for xx = x - 11, x + 11 do P(xx, y - 10, INK) end; for xx = x - 10, x + 10 do P(xx, y - 9, DIRT[6]) end
end
function PR.telescope(x, y)
  ln({ { x, y - 22 }, { x - 9, y } }, 2, TIMB, 4); ln({ { x, y - 22 }, { x + 9, y } }, 2, TIMB, 3); ln({ { x, y - 22 }, { x, y } }, 1, TIMB, 4)
  local t = c:line({ { x - 12, y - 14 }, { x + 14, y - 32 } }, 6); c:rim(t, INK)
  t:each(function(xx, yy) local d = (xx * .8 + yy * .6); P(xx, yy, GOLD[(yy < (y - 14) - (xx - x + 12) * .69 - 1) and 5 or ((yy > (y - 14) - (xx - x + 12) * .69 + 2) and 3 or 4)]) end)
  for _, k in ipairs{ 6, 12, 19 } do local bx0, by0 = x - 12 + k, floor(y - 14 - k * .69); for d = -3, 3 do P(bx0 + (d > 0 and 0 or 0), by0 + d, IRON[3]) end end
  ball(x + 15, y - 33, 3, 3, { "#2a4a6a", "#4a7a9a", "#78bccc", "#a8dce0", "#d4f0f4", "#fff" })
end
function PR.buoy(x, y, a, b)
  bx(x, y - 24, x + 2, y, TIMB)
  local lr = c:ellipse(x + 1, y - 18, 8, 8); lr:cut(c:ellipse(x + 1, y - 18, 3, 3)); c:rim(lr, INK)
  lr:each(function(xx, yy) local k = floor((math.atan(yy - y + 18, xx - x - 1) + pi) / .7854); P(xx, yy, (k % 2 == 0) and a or b) end)
  P(x - 4, y - 24, "#ffffffaa" and "#fff2dc")
end
function PR.coil(x, y)
  local m = c:ellipse(x, y - 4, 11, 5); c:rim(m, INK)
  m:each(function(xx, yy) local d = sqrt(((xx - x) / 11) ^ 2 + ((yy - y + 4) / 5) ^ 2); local t = (floor(d * 5) % 2 == 0) and 5 or 3; if yy < y - 5 then t = min(6, t + 1) end; P(xx, yy, CREAM[t]) end)
  c:fillMask(c:ellipse(x, y - 4, 3, 1), INK)
end
function PR.oar(x, y, col)
  ln({ { x, y }, { x + 6, y - 36 } }, 2, TIMB, 4)
  local bl = c:line({ { x + 6, y - 36 }, { x + 9, y - 56 } }, 6); c:rim(bl, INK)
  bl:each(function(xx, yy) P(xx, yy, col[(xx < x + 7 + (y - 36 - yy) * -.15) and 5 or 3]) end)
  for yy = y - 52, y - 40, 2 do P(x + 8 + floor((y - 36 - yy) * -.15), yy, col[6]) end
end
function PR.lobsterpot(x, y)
  local m = c:ellipse(x, y - 8, 11, 8):clip(rect(x - 12, y - 17, x + 12, y - 1)); c:rim(m, INK)
  m:each(function(xx, yy) local t = (yy < y - 12) and 5 or 3; if ((xx + yy) % 4 == 0) or ((xx - yy) % 4 == 0) then P(xx, yy, DIRT[6]) else P(xx, yy, DIRT[t - 1]) end end)
  c:fillMask(rect(x - 3, y - 7, x + 3, y - 1), INK); P(x - 4, y - 8, DIRT[6])
  P(x, y - 17, INK); for k = 1, 5 do P(x + k, y - 18 - k // 2, "#c8a060") end
  ball(x + 7, y - 24, 2, 2, { "#7a2230", "#b0343a", "#e8493b", "#e8493b", "#ff9a8a", "#fff" })
end
function PR.fishingrod(x, y)
  local rod = c:line({ { x, y }, { x + 6, y - 28 }, { x + 18, y - 54 } }, 2); c:rim(rod, INK); c:fillMask(rod, TIMB[5])
  ball(x + 5, y - 22, 3, 3, IRON)
  for yy = y - 52, y - 24 do P(x + 20 + (y - 52 - yy) // 9, yy, "#e6f2ff") end
  ball(x + 17, y - 22, 3, 3, { "#7a2230", "#b0343a", "#e8493b", "#e8493b", "#ff9a8a", "#fff" })
end
function PR.berrybush(x, y, col)
  for _, q in ipairs{ { -8, 0, 7 }, { 8, 1, 7 }, { 0, -5, 8 } } do ball(x + q[1], y + q[2] - 6, q[3], q[3] - 1, GREEN) end
  for _, q in ipairs{ { -9, -8 }, { -2, -12 }, { 6, -9 }, { 11, -4 }, { -5, -3 }, { 2, -5 } } do ball(x + q[1], y + q[2], 2, 2, { "#2a1030", col[1], col[2], col[2], col[3], "#fff" }) end
end
function PR.bookstack(x, y, cols)
  local h = 0
  for i, cc in ipairs(cols) do
    local w = 22 - i * 3 + (i % 2) * 2
    bx(x - 11 + (i % 2) * 2, y - h - 6, x - 11 + (i % 2) * 2 + w, y - h, cc)
    for xx = x - 8 + (i % 2) * 2, x - 8 + (i % 2) * 2 + w - 6, w - 6 do P(xx, y - h - 3, GOLD[5]) end
    h = h + 6
  end
end
function PR.stool(x, y, kettle)
  bx(x - 8, y - 11, x + 8, y - 8, OAK); bx(x - 6, y - 8, x - 4, y, TIMB); bx(x + 4, y - 8, x + 6, y, TIMB)
  if kettle then
    ln({ { x + 5, y - 17 }, { x + 11, y - 22 } }, 2, kettle, 4)
    ball(x, y - 17, 7, 6, kettle); c:fillMask(rect(x - 2, y - 24, x + 2, y - 23), INK); P(x, y - 24, kettle[5])
    local h = c:line({ { x - 5, y - 21 }, { x - 1, y - 28 }, { x + 4, y - 22 } }, 1); c:rim(h, INK); c:fillMask(h, IRON[4])
    P(x - 4, y - 19, kettle[6]); P(x - 3, y - 20, kettle[6])
  end
end
function PR.spool(x, y, col, h)
  for _, q in ipairs{ { y - h, y - h + 3 }, { y - 3, y } } do bx(x - 9, q[1], x + 9, q[2], OAK) end
  local m = rect(x - 7, y - h + 4, x + 7, y - 4); c:rim(m, INK)
  m:each(function(xx, yy) local t = (xx < x - 2) and 5 or ((xx > x + 3) and 3 or 4); if (yy % 2) == 0 then t = t - 1 end; P(xx, yy, col[max(1, t)]) end)
  for k = 0, 24 do P(x + 9 + k, y - 1 + floor(sin(k / 3) * 1.5 + .5), col[4]); P(x + 9 + k, y, col[2]) end
end
function PR.thimblePot(x, y)
  local m = c:ellipse(x, y - 14, 9, 8):clip(rect(x - 10, y - 24, x + 10, y - 12)); m:add(rect(x - 9, y - 14, x + 9, y)); c:rim(m, INK)
  m:each(function(xx, yy)
    local t = (xx < x - 3) and 5 or ((xx > x + 4) and 3 or 4); if xx > x + 7 then t = 2 end
    if ((xx + (yy // 3) * 2) % 4 == 0) and yy % 3 == 0 then t = t - 1 end
    P(xx, yy, IRON[max(1, min(6, t + 1))])
  end)
  for xx = x - 10, x + 10 do P(xx, y - 3, INK); P(xx, y - 2, IRON[5]) end
  for k = 0, 4 do P(x - 3 + k * 2, y - 24 - (k % 2), GREEN[4]); P(x - 3 + k * 2, y - 25 - (k % 2), GREEN[5]) end
  ball(x - 1, y - 28, 3, 3, { "#7a3a58", "#c46890", "#f0a8c4", "#f0a8c4", "#fde4ee", "#fff" })
end
function PR.breadrack(x, y)
  bx(x - 17, y - 14, x + 17, y - 11, OAK); bx(x - 15, y - 11, x - 12, y, TIMB); bx(x + 12, y - 11, x + 15, y, TIMB)
  for _, q in ipairs{ { -11, 7, 3 }, { -3, 8, 3 }, { 5, 6, 3 } } do ball(x + q[1], y - 14 - q[3], q[2], q[3] + 1, R.ORG); P(x + q[1] - 2, y - 16 - q[3], R.ORG[6]); P(x + q[1] + 1, y - 14 - q[3], R.ORG[2]); P(x + q[1] - 1, y - 14 - q[3], R.ORG[2]) end
  ball(x + 13, y - 18, 5, 4, R.PEACH); for k = -4, 4, 2 do P(x + 13 + k, y - 18, R.PEACH[2]) end
end
function PR.crystal(x, y)
  for _, q in ipairs{ { -9, 8, 22 }, { 0, 10, 30 }, { 10, 7, 18 } } do
    local cx, w, h = x + q[1], q[2] // 2, q[3]
    local m = HP.mask()
    for dy = 0, h - 1 do local hw = (dy < 8) and floor(w * dy / 8 + .5) or w; for xx = cx - hw, cx + hw do m:set(xx, y - h + dy + 1) end end
    c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, R.LAV[(xx < cx - 1) and 5 or ((xx > cx + 1) and 3 or 4)]) end)
    P(cx - 1, y - h + 5, R.LAV[6]); P(cx - 1, y - h + 6, R.LAV[6])
  end
end
function PR.candlestack(x, y)
  bx(x - 7, y - 10, x + 7, y, TIMB)
  for _, q in ipairs{ { -4, 10 }, { 1, 14 }, { 5, 8 } } do
    local m = bx(x + q[1] - 1, y - 10 - q[2], x + q[1] + 1, y - 11, CREAM)
    P(x + q[1], y - 12 - q[2], "#ffe08a"); P(x + q[1], y - 13 - q[2], "#fff6cc"); P(x + q[1], y - 14 - q[2], "#ffd24a")
    P(x + q[1] + 2, y - 10 - q[2] // 2, CREAM[5]); P(x + q[1] + 2, y - 9 - q[2] // 2, CREAM[5])
  end
  S.glow(x, y - 20, 14, "#ffd070", .3)
end
function PR.easel(x, y)
  ln({ { x, y - 46 }, { x - 12, y } }, 2, TIMB, 4); ln({ { x, y - 46 }, { x + 12, y } }, 2, TIMB, 3); ln({ { x, y - 40 }, { x, y - 6 } }, 1, TIMB, 4)
  bx(x - 13, y - 14, x + 13, y - 12, TIMB)
  local cv = bx(x - 12, y - 44, x + 12, y - 18, CREAM)
  for _, q in ipairs{ { -8, -38, 6, "#e8493b" }, { -1, -34, 7, "#3f8c8c" }, { 5, -30, 5, "#ffd24a" }, { -9, -27, 5, "#7a5ac8" }, { 3, -41, 4, "#f0809c" } } do
    for k = 0, q[3] do P(x + q[1] + k, y + q[2] + floor(sin(k) * 2) + k // 3, q[4]); P(x + q[1] + k, y + q[2] + 1 + floor(sin(k) * 2) + k // 3, q[4]) end
  end
  ball(x + 19, y - 4, 4, 2, R.CREAM); P(x + 17, y - 5, "#e8493b"); P(x + 20, y - 5, "#3f8c8c")
end
function PR.cairn(x, y, n)
  local ws = { 14, 11, 8, 5 }; local yy = y
  for i = 1, n do
    local w = ws[i]; ball(x, yy - 3, w // 2 + 1, 3, STONE); P(x - 2, yy - 5, STONE[6]); yy = yy - 5
  end
end
function PR.fence(x0, x1, y)
  for xx = x0, x1, 7 do
    local m = rect(xx, y - 14, xx + 3, y); m:cut(rect(xx, y - 14, xx, y - 14)); m:cut(rect(xx + 3, y - 14, xx + 3, y - 14)); c:rim(m, INK)
    m:each(function(x2, y2) P(x2, y2, (x2 == xx) and CREAM[6] or CREAM[4]) end); P(xx + 1, y - 15, INK); P(xx + 2, y - 15, INK)
  end
  for _, yy in ipairs{ y - 10, y - 4 } do for xx = x0, x1 + 3 do P(xx, yy, INK); P(xx, yy + 1, CREAM[3]) end end
end
function PR.seedsack(x, y)
  local m = c:ellipse(x, y - 9, 10, 9):clip(rect(x - 11, y - 18, x + 11, y)); m:add(rect(x - 10, y - 9, x + 10, y)); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, R.PEACH[(xx < x - 3) and 5 or ((xx > x + 4) and 3 or 4)]) end)
  for xx = x - 4, x + 4 do P(xx, y - 18, INK) end; c:fillMask(rect(x - 3, y - 19, x + 3, y - 17), R.PEACH[3]); for xx = x - 4, x + 4 do P(xx, y - 17, CORALX or R.CORAL[4]) end
  for _, q in ipairs{ { 14, -1 }, { 17, 0 }, { 13, 1 }, { 19, -1 }, { 16, 1 } } do P(x + q[1], y + q[2] - 1, "#4a3022"); P(x + q[1] + 1, y + q[2] - 1, "#946a38") end
  P(x - 2, y - 7, R.CORAL[2]); P(x - 1, y - 7, R.CORAL[2]); P(x, y - 7, R.CORAL[2])
end
function PR.tomatoes(x, y)
  bx(x - 1, y - 40, x + 1, y, TIMB)
  for yy = y - 38, y - 4, 8 do for k = 0, 6 do P(x - 3 - k, yy + k // 3, GREEN[4]); P(x + 3 + k, yy + 2 + k // 3, GREEN[4]); P(x - 3 - k, yy + 1 + k // 3, GREEN[3]); P(x + 3 + k, yy + 3 + k // 3, GREEN[3]) end end
  for _, q in ipairs{ { -8, -12 }, { 8, -22 }, { -9, -28 }, { 7, -6 }, { -7, -3 } } do ball(x + q[1], y + q[2], 3, 3, R.REDW) end
end
function PR.grapevine(x, y)
  bx(x - 2, y - 56, x, y, TIMB); bx(x - 14, y - 54, x + 12, y - 51, TIMB)
  for yy = y - 2, y - 54, -1 do local vx = floor(x - 1 + 5 * sin(yy / 6)); P(vx - 1, yy, INK); P(vx + 1, yy, INK); P(vx, yy, GREEN[(yy % 4 < 2) and 5 or 4]) end
  for _, q in ipairs{ { -8, -44 }, { 7, -34 }, { -7, -22 } } do
    ball(x + q[1] + 6, y + q[2] - 4, 5, 3, LEAF)
    for row = 0, 3 do for k = 0, 3 - row do ball(x + q[1] + k * 4 + row * 2 - 6, y + q[2] + row * 4 + 6, 2, 2, R.VIO) end end
  end
end
function PR.quillink(x, y)
  local q = c:line({ { x - 2, y - 18 }, { x + 4, y - 48 }, { x + 16, y - 66 } }, 1); c:rim(q, INK); c:fillMask(q, CREAM[5])
  local vane = c:ellipse(x + 8, y - 48, 5, 14); vane:cut(rect(x - 2, y - 36, x + 6, y - 30)); c:rim(vane, INK)
  vane:each(function(xx, yy) P(xx, yy, ((xx + yy) % 5 == 0) and R.PEACH[3] or ((xx < x + 8) and R.PEACH[5] or R.PEACH[4])) end)
  ln({ { x - 1, y - 18 }, { x + 11, y - 60 } }, 1, CREAM, 3)
  local pot = c:ellipse(x - 2, y - 7, 11, 7):clip(rect(x - 14, y - 14, x + 10, y)); c:rim(pot, INK)
  pot:each(function(xx, yy) P(xx, yy, R.NAVY[(xx < x - 5) and 5 or ((xx > x + 3) and 2 or 3)]) end)
  c:fillMask(rect(x - 6, y - 15, x + 2, y - 12), INK); c:fillMask(rect(x - 5, y - 14, x + 1, y - 13), "#2a2a5a"); P(x - 4, y - 14, "#8aa0e0")
end
function PR.cactus(x, y, h)
  local m = rect(x - 4, y - h, x + 4, y); m:cut(rect(x - 4, y - h, x - 4, y - h)); m:cut(rect(x + 4, y - h, x + 4, y - h))
  for _, a in ipairs{ { -12, -h // 2, -4, -h // 2 + 8 }, { 4, -h // 2 - 6, 12, -h // 2 + 8 } } do end
  local arm1 = rect(x - 12, y - h // 2 - 2, x - 5, y - h // 2 + 2); arm1:add(rect(x - 12, y - h // 2 - 12, x - 9, y - h // 2 + 2))
  local arm2 = rect(x + 5, y - h // 2 - 8, x + 12, y - h // 2 - 4); arm2:add(rect(x + 9, y - h // 2 - 16, x + 12, y - h // 2 - 4))
  local all = HP.mask(); all:add(m):add(arm1):add(arm2); c:rim(all, INK)
  all:each(function(xx, yy) local t = (xx < x - 1 and xx > x - 4) and 5 or ((xx > x + 1 and xx < x + 5) and 3 or 4); if (xx - x) % 4 == 0 then t = 3 end; P(xx, yy, R.SAGE[min(6, t + 1)]) end)
  for yy = y - h + 3, y - 3, 6 do P(x - 2, yy, "#fff2dc"); P(x + 2, yy + 2, "#fff2dc") end
  ball(x, y - h - 2, 2, 2, { "#7a3a58", "#c46890", "#f0809c", "#f0809c", "#fde4ee", "#fff" })
end
function PR.stakes() end

---------------------------------------------------------------- wall / hanging props
function PR.bunting(x0, x1, y, cols, sag)
  sag = sag or 8
  local pts = {}
  for x = x0, x1 do local t = (x - x0) / (x1 - x0); local yy = floor(y + sag * (1 - (2 * t - 1) ^ 2) + .5); P(x, yy, INK); pts[x] = yy end
  local i = 0
  for x = x0 + 4, x1 - 6, 9 do
    i = i + 1; local cc = cols[i % #cols + 1]; local y0 = pts[x] + 1
    for k = 0, 6 do for xx = x + floor(k * .45), x + 6 - floor(k * .45) do P(xx, y0 + k, (xx == x + floor(k * .45) and k < 5) and R.CREAM[6] or cc) end end
    for k = 0, 6 do P(x + floor(k * .45) - 1, y0 + k, INK); P(x + 7 - floor(k * .45), y0 + k, INK) end
    for xx = x + 3, x + 3 do P(xx, y0 + 7, INK) end
  end
end
function PR.lights(x0, x1, y, sag, col)
  for x = x0, x1 do local t = (x - x0) / (x1 - x0); P(x, floor(y + sag * (1 - (2 * t - 1) ^ 2) + .5), INK) end
  local i = 0
  for x = x0 + 5, x1 - 4, 10 do
    i = i + 1; local t = (x - x0) / (x1 - x0); local yy = floor(y + sag * (1 - (2 * t - 1) ^ 2) + .5)
    S.glow(x, yy + 5, 9, col[i % #col + 1], .35)
    c:fillMask(rect(x - 1, yy + 1, x + 1, yy + 2), INK); ball(x, yy + 5, 2, 3, { "#6a2010", col[1], col[i % #col + 1], col[i % #col + 1], "#fff0c0", "#fff" })
  end
end
function PR.mobile(x, y)
  bx(x - 16, y, x + 16, y + 2, TIMB); for yy = y - 7, y - 1 do P(x, yy, INK) end
  for _, q in ipairs{ { -12, 12, 0 }, { 0, 20, 1 }, { 12, 14, 2 } } do
    for yy = y + 3, y + q[2] do P(x + q[1], yy, INK) end
    local cx, cy = x + q[1], y + q[2] + 5
    if q[3] == 0 then
      local m = c:ellipse(cx, cy, 5, 5); m:cut(c:ellipse(cx + 3, cy - 2, 4, 4)); c:rim(m, INK); c:fillMask(m, "#ffe08a"); P(cx - 4, cy, "#fff6cc")
    elseif q[3] == 1 then
      local m = rect(cx - 1, cy - 6, cx + 1, cy + 6); m:add(rect(cx - 6, cy - 1, cx + 6, cy + 1)); m:add(c:ellipse(cx, cy, 3, 3)); c:rim(m, INK); c:fillMask(m, "#ffd24a"); P(cx, cy, "#fff6cc")
    else
      ball(cx, cy, 4, 4, R.LAV); P(cx - 1, cy - 2, "#fff")
    end
  end
end
function PR.bell(x, y)
  bx(x, y - 10, x + 3, y + 10, TIMB); bx(x - 14, y - 10, x + 2, y - 7, TIMB)
  for yy = y - 6, y - 3 do P(x - 10, yy, INK) end
  local b = c:ellipse(x - 10, y + 1, 6, 6):clip(rect(x - 17, y - 5, x - 3, y + 3)); b:add(rect(x - 16, y + 3, x - 4, y + 6)); c:rim(b, INK)
  b:each(function(xx, yy) P(xx, yy, GOLD[(xx < x - 11) and 6 or ((xx > x - 8) and 3 or 4)]) end)
  P(x - 10, y + 8, INK); P(x - 10, y + 9, GOLD[4]); P(x - 9, y + 9, INK); P(x - 11, y + 9, INK)
end
function PR.wreath(x, y, col)
  local r = c:ellipse(x, y, 12, 12); r:cut(c:ellipse(x, y, 6, 6)); c:rim(r, INK)
  r:each(function(xx, yy) P(xx, yy, GREEN[2 + floor(hash(xx, yy, 7) * 4)]) end)
  for i = 0, 7 do local a = i * pi / 4 + .4; ball(floor(x + cos(a) * 9 + .5), floor(y + sin(a) * 9 + .5), 2, 2, { "#5a2a44", col[1], col[2], col[2], col[3], "#fff" }) end
  for k = 0, 3 do P(x - 3 - k, y + 12 + k // 2, "#e8493b"); P(x + 3 + k, y + 12 + k // 2, "#e8493b") end
  P(x, y + 12, INK); P(x - 1, y + 12, "#e8493b"); P(x + 1, y + 12, "#e8493b")
end
function PR.hangpots(x, y)
  for _, dx in ipairs{ -8, 8 } do for yy = y - 12, y do P(x + dx, yy, INK) end end
  for k = 0, 8 do P(x - 8 + k * 2, y - 12 - 0, INK) end
  P(x, y - 20, INK); for yy = y - 20, y - 12 do P(x, yy, IRON[4]) end
  bx(x - 12, y, x + 12, y + 8, R.ORG)
  for xx = x - 11, x + 11 do local h = 3 + floor(hash(xx, 2, 6) * 5); for k = 1, h do P(xx, y - k, GREEN[(k > h - 2) and 5 or 3]) end end
  for xx = x - 10, x + 10, 6 do P(xx, y + 9, GREEN[4]); P(xx, y + 10, GREEN[4]); P(xx + 1, y + 11, GREEN[3]); P(xx + 2, y + 12, GREEN[3]) end
  for _, q in ipairs{ { -7, -4 }, { 1, -7 }, { 8, -5 } } do ball(x + q[1], y + q[2], 2, 2, R.LAV) end
end
function PR.chilis(x, y, col)
  for yy = y, y + 4 do P(x, yy, INK) end; P(x - 1, y - 1, INK); P(x, y - 2, INK); P(x + 1, y - 1, INK)
  for i = 0, 5 do
    local yy = y + 5 + i * 6; local s = (i % 2 == 0) and -1 or 1
    P(x, yy, "#6aa838"); P(x, yy + 1, INK)
    for k = 0, 5 do P(x + s * 2 + s * (k // 3), yy + 1 + k, INK); P(x + s * 1 + s * (k // 3), yy + 1 + k, col[(k < 2) and 2 or 1]) end
    P(x + s, yy + 2, col[3])
  end
end
function PR.shelfjars(x, y)
  bx(x - 18, y, x + 18, y + 3, TIMB); bx(x - 14, y + 3, x - 12, y + 8, TIMB); bx(x + 12, y + 3, x + 14, y + 8, TIMB)
  for i, q in ipairs{ -12, -2, 8 } do
    local m = rect(q, y - 11, q + 8, y - 1); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (yy < y - 8) and "#ffd24a" or ((xx < q + 3) and "#f8c050" or "#e08830")) end)
    c:fillMask(rect(q - 1, y - 14, q + 9, y - 12), INK); c:fillMask(rect(q, y - 13, q + 8, y - 13), R.YEL[5]); P(q + 1, y - 8, "#fff2a0"); P(q + 1, y - 7, "#fff2a0")
  end
end
function PR.net(x, y)
  local m = HP.mask()
  for yy = 0, 28 do local hw = 16 - floor(yy * .5); for xx = x - hw, x + hw do m:set(xx, y + yy) end end
  c:rim(m, INK)
  m:each(function(xx, yy) if ((xx + yy) % 5 == 0) or ((xx - yy) % 5 == 0) then P(xx, yy, DIRT[5]) else P(xx, yy, DIRT[2]) end end)
  for k = -14, 14, 7 do ball(x + k, y - 1, 2, 2, { "#7a3418", "#c0602c", "#e8843c", "#e8843c", "#fcd098", "#fff" }) end
  for xx = x - 17, x + 17 do P(xx, y - 3, INK); P(xx, y - 2, DIRT[4]) end
end
function PR.scrollrack(x, y)
  bx(x - 20, y + 10, x + 20, y + 13, TIMB)
  for i, q in ipairs{ -14, -4, 6, 14 } do
    local m = bx(q - 3, y - 6 + (i % 2) * 3, q + 3, y + 9, CREAM)
    P(q, y - 6 + (i % 2) * 3, CREAM[6]); for xx = q - 3, q + 3 do P(xx, y + 2, R.CORAL[3]) end
    P(q - 1, y + 5, R.PEACH[2]); P(q + 1, y + 6, R.PEACH[2])
  end
end
function PR.chimney(x, y, h)
  bx(x - 5, y, x + 5, y + h, R.CORAL); for xx = x - 7, x + 7 do P(xx, y - 1, INK) end; c:fillMask(rect(x - 7, y - 3, x + 7, y - 2), INK); c:fillMask(rect(x - 6, y - 3, x + 6, y - 2), IRON[4])
  for k, p in ipairs{ { 2, -10, 4 }, { 7, -20, 5 }, { 15, -31, 6 } } do ball(x + p[1], y + p[2], p[3], p[3] - 1, CREAM) end
end
function PR.bunting2() end

---------------------------------------------------------------- lamp bodies
function LB.paper(col) return function(cx, cy)
  c:fillMask(rect(cx - 2, cy - 11, cx + 2, cy - 9), INK)
  ball(cx, cy, 7, 8, col); for _, d in ipairs{ -4, 0, 4 } do for yy = cy - 6, cy + 6 do if (d == 0) or (abs(yy - cy) < 6 - abs(d) * .5) then P(cx + d, yy, col[2]) end end end
  c:fillMask(rect(cx - 3, cy - 8, cx + 3, cy - 7), INK); c:fillMask(rect(cx - 3, cy + 7, cx + 3, cy + 8), INK)
  c:fillMask(rect(cx - 2, cy - 4, cx + 1, cy + 2), "#ffe08a"); P(cx - 2, cy - 4, "#fff6cc")
  for yy = cy + 9, cy + 13 do P(cx, yy, INK) end; P(cx - 1, cy + 14, INK); P(cx, cy + 14, col[5]); P(cx + 1, cy + 14, INK)
end end
function LB.jar(cx, cy)
  c:fillMask(rect(cx - 2, cy - 11, cx + 2, cy - 9), INK)
  c:fillMask(rect(cx - 5, cy - 8, cx + 5, cy + 7), INK); c:fillMask(rect(cx - 4, cy - 7, cx + 4, cy + 6), "#d4f0f4")
  c:fillMask(rect(cx - 3, cy - 5, cx + 3, cy + 4), "#ffe08a"); c:fillMask(c:ellipse(cx, cy, 2, 2), "#fff6cc")
  for xx = cx - 4, cx + 4 do P(xx, cy - 7, IRON[4]); P(xx, cy - 6, IRON[3]) end; P(cx - 4, cy - 3, "#fff"); P(cx - 4, cy - 2, "#fff")
  P(cx + 3, cy + 5, "#e8a840"); P(cx, cy + 7, INK)
end
function LB.star(cx, cy)
  local m = rect(cx - 2, cy - 8, cx + 2, cy + 8); m:add(rect(cx - 8, cy - 2, cx + 8, cy + 2)); m:add(c:ellipse(cx, cy, 5, 5))
  c:rim(m, INK); m:each(function(x, y) P(x, y, ((x + y) < cx + cy) and "#fff6cc" or "#ffd24a") end); c:fillMask(c:ellipse(cx, cy, 2, 2), "#fff")
  for yy = cy - 11, cy - 9 do P(cx, yy, INK) end
end

---------------------------------------------------------------- door overlays (centre cx,cy)
function OV.crocus(cx, cy)
  for y = cy + 2, cy + 22 do P(cx, y, INK); P(cx + 1, y, GREEN[4]) end
  for k = 0, 8 do P(cx - 2 - k, cy + 20 - k, GREEN[5]); P(cx - 2 - k, cy + 21 - k, GREEN[3]); P(cx + 3 + k, cy + 17 - k, GREEN[5]); P(cx + 3 + k, cy + 18 - k, GREEN[3]) end
  ball(cx - 6, cy - 2, 4, 8, R.VIO); ball(cx + 8, cy - 2, 4, 8, R.VIO); ball(cx + 1, cy - 6, 5, 10, R.VIO)
  P(cx + 1, cy - 14, R.VIO[6]); pxs({ { cx - 1, cy + 4 }, { cx + 1, cy + 4 }, { cx + 3, cy + 4 } }, "#ffd24a"); P(cx + 1, cy + 3, "#ff9a30")
end
function OV.apple(cx, cy)
  ln({ { cx + 1, cy - 8 }, { cx + 3, cy - 14 } }, 2, TIMB, 4); ball(cx + 8, cy - 12, 6, 3, LEAF)
  ball(cx, cy + 1, 11, 10, R.REDW); P(cx - 4, cy - 4, R.REDW[6]); P(cx - 5, cy - 3, R.REDW[6]); P(cx - 5, cy - 2, R.REDW[6]); P(cx, cy - 8, R.REDW[2]); P(cx + 1, cy - 8, R.REDW[2])
end
function OV.lilypad(cx, cy)
  ball(cx, cy + 2, 13, 11, LEAF)
  for k = 0, 13 do P(cx + k, cy + 2 - floor(k * .45), INK) end
  for k = 0, 12 do P(cx + k, cy + 3 - floor(k * .45), R.GREEN[1]) end
  for i = 0, 4 do local a = i * 1.2566; ball(floor(cx - 3 + cos(a) * 4 + .5), floor(cy - 1 + sin(a) * 4 + .5), 2, 2, R.PASTEL) end
  P(cx - 3, cy - 1, "#ffd24a"); P(cx - 2, cy - 1, "#ffd24a")
end
function OV.cross()
  for _, y in ipairs{ 150, 186 } do bx(220, y, 259, y + 4, TIMB) end
  local d = c:line({ { 223, 191 }, { 256, 147 } }, 4); c:rim(d, INK); d:each(function(x, y) P(x, y, TIMB[((x + y) % 7 < 2) and 3 or 4]) end)
  for _, q in ipairs{ { 224, 152 }, { 255, 152 }, { 224, 188 }, { 255, 188 } } do P(q[1], q[2], GOLD[5]) end
end
function OV.petals(cx, cy)
  for i = 0, 7 do local a = i * pi / 4; ball(floor(cx + cos(a) * 10 + .5), floor(cy + sin(a) * 10 + .5), 4, 4, R.PASTEL) end
  ball(cx, cy, 5, 5, GOLD); pxs({ { cx - 2, cy - 1 }, { cx + 1, cy + 2 }, { cx + 2, cy - 2 } }, GOLD[2])
end
function OV.sun(cx, cy)
  for i = 0, 11 do local a = i * pi / 6; for r = 11, 16 do P(floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5), (r < 15) and GOLD[5] or GOLD[3]) end end
  ball(cx, cy, 9, 9, GOLD); P(cx - 4, cy - 4, GOLD[6]); P(cx - 3, cy - 5, GOLD[6])
end
function OV.wheel(cx, cy)
  for i = 0, 7 do local a = i * pi / 4; ln({ { cx, cy }, { floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5) } }, 1, GOLD, 4) end
  local r = c:ellipse(cx, cy, 12, 12); r:cut(c:ellipse(cx, cy, 8, 8)); c:rim(r, INK); r:each(function(x, y) local l = lit(x, y, cx, cy, 12); P(x, y, GOLD[l > .3 and 5 or (l > -.4 and 4 or 3)]) end)
  for i = 0, 7 do local a = i * pi / 4; ball(floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5), 2, 2, GOLD) end
  ball(cx, cy, 3, 3, GOLD)
end
function OV.batwing(cx, cy)
  for _, s in ipairs{ -1, 1 } do
    local m = HP.mask()
    for dx = 2, 18 do
      local top = cy - 6 - floor(dx * .55)
      local bot = cy + 6 - floor(dx * .15) + floor(3 * abs(sin(dx * pi / 6.2)))
      for y = top, bot do m:set(cx + s * dx, y) end
    end
    c:rim(m, INK); m:each(function(x, y) P(x, y, R.LAV[(y < cy - 4 - abs(x - cx) * .4) and 5 or ((y > cy + 6) and 3 or 4)]) end)
    for k = 4, 16, 4 do for y = cy - 4 - floor(k * .4), cy + 4 do P(cx + s * k, y, R.LAV[3]) end end
  end
  ball(cx, cy, 4, 8, R.NIGHT); P(cx - 2, cy - 9, R.NIGHT[5]); P(cx + 2, cy - 9, R.NIGHT[5]); P(cx - 1, cy - 3, "#ffd24a"); P(cx + 1, cy - 3, "#ffd24a")
end
function OV.leaf(cx, cy)
  ball(cx, cy, 11, 17, LEAF)
  for y = cy - 16, cy + 18 do P(cx, y, LEAF[6]) end
  for k = 1, 5 do for d = 1, 6 do P(cx - d, cy - 14 + k * 5 + d // 2 - 5 + 5, LEAF[2]); P(cx + d, cy - 14 + k * 5 + d // 2 - 5 + 5, LEAF[2]) end end
end
function OV.ripple(cx, cy)
  for _, r in ipairs{ 5, 10, 15 } do
    for i = 0, 79 do local a = i * pi / 40; local x, y = floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r * .55 + .5); P(x + 1, y + 1, R.BLUEW[2]); P(x, y, R.BLUEW[6]) end
  end
  for i = 0, 79 do local a = i * pi / 40; P(floor(cx + cos(a) * 5 + .5), floor(cy + sin(a) * 2.75 + .5), "#fff") end
  P(cx, cy, "#b4d6f4")
end
function OV.hex(cx, cy)
  for _, q in ipairs{ { 0, 0, 1 }, { -12, 0, 0 }, { 12, 0, 0 }, { -6, -10, 0 }, { 6, -10, 0 }, { -6, 10, 0 }, { 6, 10, 0 } } do
    local x, y = cx + q[1], cy + q[2]
    local m = rect(x - 4, y - 5, x + 4, y + 5); m:cut(rect(x - 4, y - 5, x - 3, y - 4)); m:cut(rect(x + 3, y - 5, x + 4, y - 4)); m:cut(rect(x - 4, y + 4, x - 3, y + 5)); m:cut(rect(x + 3, y + 4, x + 4, y + 5))
    c:rim(m, INK); m:each(function(xx, yy) local l = (xx < x and yy < y) and 5 or ((xx > x and yy > y) and 3 or 4); P(xx, yy, (q[3] == 1) and R.ORG[l] or GOLD[l]) end)
  end
end
function OV.feather(cx, cy)
  local sp = {}
  for i = 0, 40 do local t = i / 40; sp[i] = { floor(cx - 7 + 12 * t + sin(t * 3) * 2 + .5), floor(cy + 24 - 46 * t + .5) } end
  for i = 6, 38 do local p = sp[i]; local len = floor(9 * (1 - abs(i / 40 - .5) * 1.3)); for k = 1, len do P(p[1] - k, p[2] + k // 2, (k > len - 2) and R.LAV[6] or R.LAV[4]); P(p[1] + k, p[2] + k // 2, (k > len - 2) and R.LAV[5] or R.LAV[3]) end end
  for i = 0, 40 do P(sp[i][1], sp[i][2], INK); P(sp[i][1] + 1, sp[i][2], "#fff2dc") end
end
function OV.scroll(cx, cy)
  bx(cx - 10, cy - 12, cx + 10, cy + 12, CREAM)
  bx(cx - 13, cy - 16, cx + 13, cy - 12, R.PEACH); bx(cx - 13, cy + 12, cx + 13, cy + 16, R.PEACH)
  for i = 0, 4 do for x = cx - 7, cx + 7 - (i % 3) * 2 do if hash(x, i, 4) > .25 then P(x, cy - 8 + i * 4, "#8a6a5a") end end end
  ball(cx + 6, cy + 7, 3, 3, R.CORAL)
end
function OV.dots(cx, cy, cols)
  cols = cols or { "#ffd24a", "#fff2dc", "#8fc0f0" }
  for i, q in ipairs{ { 228, 150, 4 }, { 250, 148, 3 }, { 236, 168, 5 }, { 253, 172, 3 }, { 229, 188, 3 }, { 246, 190, 4 }, { 224, 168, 2 }, { 247, 160, 2 } } do
    local m = c:ellipse(q[1], q[2], q[3], q[3]); c:fillMask(m, cols[i % #cols + 1]); P(q[1] - 1, q[2] - 1, "#fff")
  end
end
function OV.poppy(cx, cy)
  for k = 0, 24 do P(cx + floor(sin(k / 5) * 2), cy + 4 + k, INK); P(cx + 1 + floor(sin(k / 5) * 2), cy + 4 + k, GREEN[4]) end
  for k = 0, 7 do P(cx - 2 - k, cy + 18 - k // 2, GREEN[5]); P(cx + 4 + k, cy + 14 - k // 2, GREEN[5]) end
  for _, d in ipairs{ { -5, -2 }, { 6, -2 }, { 0, -8 }, { 0, 4 } } do ball(cx + d[1], cy + d[2], 5, 5, R.REDW) end
  ball(cx, cy - 2, 3, 3, { "#140e10", "#2a1820", "#3a2430", "#3a2430", "#5a3a48", "#7a5a68" })
end
function OV.lattice(cx, cy)
  local m = c:ellipse(cx, cy, 22, 28)
  m:each(function(x, y) if ((x + y) % 9 < 2) or ((x - y) % 9 < 2) then P(x, y, ((x + y) % 9 == 0 or (x - y) % 9 == 0) and "#f8d890" or "#c88a44") end end)
  for i = 0, 40 do local a = i * pi / 20; P(floor(cx + cos(a) * 22 + .5), floor(cy + sin(a) * 28 + .5), "#f4c878") end
  for _, q in ipairs{ { cx, cy }, { cx - 9, cy }, { cx + 9, cy }, { cx, cy - 10 }, { cx, cy + 10 } } do P(q[1], q[2], "#6a2a1a") end
end
function OV.grapes(cx, cy)
  ln({ { cx, cy - 14 }, { cx + 1, cy - 8 } }, 2, TIMB, 4); ball(cx + 9, cy - 12, 7, 3, LEAF); ball(cx - 8, cy - 11, 6, 3, LEAF)
  for row = 0, 5 do for k = 0, 5 - row do ball(cx - (5 - row) * 2 + k * 4 + 1, cy - 6 + row * 5, 3, 3, R.VIO) end end
  for _, q in ipairs{ { cx - 3, cy - 6 }, { cx + 3, cy - 1 } } do P(q[1], q[2], R.VIO[6]) end
end
function OV.button(cx, cy)
  ball(cx, cy, 13, 13, CREAM)
  for i = 0, 63 do local a = i * pi / 32; P(floor(cx + cos(a) * 9 + .5), floor(cy + sin(a) * 9 + .5), CREAM[3]) end
  for _, d in ipairs{ { -3, -3 }, { 2, -3 }, { -3, 2 }, { 2, 2 } } do c:fillMask(rect(cx + d[1], cy + d[2], cx + d[1] + 1, cy + d[2] + 1), INK) end
  for k = 0, 4 do P(cx - 3 + k, cy - 3 + k, "#e8493b"); P(cx + 2 - k, cy - 3 + k, "#e8493b"); P(cx - 2 + k, cy - 3 + k, "#e8493b") end
end
function OV.moon(cx, cy) moonstars() end

-- ===================== w3: parameterised homes
local function roofPaint(rm, ramp, kind, seed)
  rm:each(function(x, y)
    if kind == "tiles" then
      local row = floor(y / 8); local xx = (x + (row % 2) * 6) % 12; local yy = y % 8
      local cell = (x + (row % 2) * 6) // 12
      local v = .58 + (hash(cell, row, seed) - .5) * .3 - x / 480 * .1
      if yy >= 7 - floor(2.6 * ((xx - 6) / 6) ^ 2) then v = v - .3 elseif yy == 0 then v = v + .16 end
      if xx == 0 then v = v - .2 end
      P(x, y, ramp[GX.idx(v)])
    else
      local row0 = floor((y + 1.8 * sin(x / 6 + floor(y / 11) * 1.7)) / 11)
      local t = (y + floor(2 * sin(x / 6 + row0 * 1.7))) % 11
      local v = .55 + (hash(x // 1, row0, seed) - .5) * .35 + (vn(x, y, 4, 7) - .5) * .25 - x / 480 * .1
      if t < 2 then v = v - .32 elseif t >= 8 then v = v + .18 end
      if hash(x, y // 3, 8) > .9 then v = v - .15 end
      P(x, y, ramp[GX.idx(v)])
    end
  end)
end
local function mkdoor(p, kind)
  local d = p.door
  local o = { shape = d.shape or "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = d.f or 4, frame = R[d.frame], wood = R[d.wood], seed = d.seed or 3, pw = d.pw or 7, straps = d.straps, woven = d.woven, blocks = d.blocks, kx = d.kx or 254, ky = d.ky or 182 }
  if kind == "burrow" then o.shape = "round"; o.x0, o.y0, o.x1, o.y1 = 207, 135, 272, 203; o.f = 5; o.blocks = true; o.kx = d.kx or 257; o.ky = d.ky or 186 end
  door(o)
end
local function applyOv(p, kind)
  local cy = (kind == "burrow") and 169 or 166
  local e = p.ov
  if e then OV[e[1]](240, e[3] or cy, e[2]) end
end
local function runProps(p) for _, f in ipairs(p.props or {}) do f() end end
local function lamp(p)
  local st = p.lamp or "hang"
  local o = {}
  if st == "post" then o.post = { TIMB, 206 }
  elseif st == "paper" then o.body = LB.paper(R[p.lampcol or "CORAL"])
  elseif st == "jar" then o.body = LB.jar
  elseif st == "star" then o.body = LB.star end
  if st == "postpaper" then o.post = { TIMB, 206 }; o.body = LB.paper(R[p.lampcol or "CORAL"]) end
  lantern(300, 120, o)
end
local function groundtufts(p, ramp, y0, n)
  for i = 1, n or 20 do tuft(floor(hash(i, 1, 6) * 470) + 6, (y0 or 212) + floor(hash(i, 2, 6) * 54), ramp or GREEN) end
  flowers(p.nfl or 10, p.seed or 12, 212, 266, p.fl or { "#f0809c", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)
end

---------------------------------------------------------------- COTTAGE
function H.cottage(p)
  local W, BM = R[p.wall], R[p.beam or "TIMB"]
  for y = 60, 205 do for x = 0, 479 do
    local n = vn(x, y, 6, 3) * .5 + vn(x, y, 2.3, 9) * .5
    local v = .64 + (n - .5) * .4 - (y - 70) / 136 * .1 + (hash(x, y, 2) > .96 and .1 or 0)
    P(x, y, W[GX.idx(v, { .2, .35, .5, .6, .8 })])
  end end
  local function beam(m) c:rim(m, INK); S.obj(m, BM, { base = 4, lit = 1, shade = 1 }); S.planks(m, BM, { w = 99, vert = false, base = 4, seed = 2 }) end
  for _, x in ipairs{ 0, 100, 392, 470 } do beam(rect(x, 66, x + 8, 196)) end
  beam(rect(0, 66, 479, 76)); beam(rect(0, 186, 479, 193))
  if p.braces ~= false then
    for _, b in ipairs{ { 108, 80, 130, 106 }, { 392, 80, 372, 106 }, { 8, 180, 34, 150 }, { 470, 180, 444, 150 } } do
      local bm = c:line({ { b[1], b[2] }, { b[3], b[4] } }, 4); c:rim(bm, INK); S.obj(bm, BM, { base = 4, lit = 1, shade = 1 })
    end
  end
  stones(function(x, y) return y >= 194 and y <= 205 end, 0, 194, 479, 205, STONE, { rh = 6, seed = 4, wmin = 9 })
  local rm = HP.mask()
  for x = 0, 479 do
    local yb = 63 + floor(3 * sin(x / 7) + 2 * sin(x / 3.3 + 1))
    if p.roofkind == "tiles" then yb = 63 + floor(2 * abs(sin(x / 6))) end
    for y = 0, yb do rm:set(x, y) end
  end
  roofPaint(rm, R[p.roof], p.roofkind or "thatch", 6)
  c:rim(rm, INK)
  for y = 64, 67 do for x = 0, 479 do local cur = c:get(x, y); if cur and not rm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .4 - (y - 64) * .08)) end end end
  grass(function(x) return 206 + floor(sin(x / 30) * 1.2) end, GREEN, 5)
  local pm = HP.mask()
  for y = 206, 269 do local hw = 30 + (y - 206) * .5; for x = floor(240 - hw), floor(240 + hw) do pm:set(x, y) end end
  stones(function(x, y) return pm:has(x, y) end, 190, 206, 290, 269, STONE, { rh = 8, seed = 11, wmin = 9, wvar = 10, shade = function(x, y) return -1 end })
  local wn = p.win or 0
  local sh = R[p.shut or "TEAL"]
  if wn == 1 or wn == 3 then window(130, 116, 166, 152, sh, true, p.wcols or { "#f0809c", "#ffd24a", "#e8493b", "#c8b8ec" }) end
  if wn == 2 or wn == 3 then window(372, 116, 408, 152, sh, true, p.wcols2 or p.wcols or { "#ffd24a", "#f5a0c0", "#fff2dc", "#e8493b" }) end
  step(204, 276, 205, STONE)
  mkdoor(p); applyOv(p)
  plate(240, 84, R[p.plate or "TIMB"])
  runProps(p)
  lamp(p)
  groundtufts(p, GREEN, 212, 22)
  for x = 20, 96, 11 do tuft(x, 204, GREEN) end
end

---------------------------------------------------------------- BURROW
function H.burrow(p)
  sky({ "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#e0f0f2" }, 2, 200)
  c:cloud(40, 66, 54, "#f8f0e0", "#d6e6f0"); c:cloud(380, 44, 44, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 150 + 10 * sin(x / 40) + 5 * sin(x / 15) end, { "#3c6e5a", "#4c8068", "#6a9c7c", "#86b494", "#a4cca8", "#bcdcb4" }, 215, 3)
  grass(function(x) return 207 + floor(sin(x / 25) * 1.2) end, GREEN, 4)
  local hm = HP.mask()
  for y = 40, 214 do for x = 20, 460 do if ((x - 240) / 222) ^ 2 + ((y - 215) / 172) ^ 2 <= 1 then hm:set(x, y) end end end
  hm = GX.rough(hm, 5, 1); c:rim(hm, INK)
  hm:each(function(x, y)
    local nx, ny = (x - 240) / 222, (y - 215) / 172
    local nz = sqrt(max(0, 1 - nx * nx - ny * ny))
    local v = .5 + (-nx * .35 - ny * .3 + nz * .25) + (vn(x, y, 7, 4) - .5) * .3
    if hash(x, y // 4, 3) > .93 then v = v - .12 end
    P(x, y, GREEN[GX.idx(v)])
  end)
  for i = 1, 240 do local x, y = 30 + floor(hash(i, 1, 9) * 420), 56 + floor(hash(i, 2, 9) * 146); if hm:has(x, y) and hm:has(x, y - 2) and free(x, y) then P(x, y, GREEN[6]); P(x, y + 1, GREEN[3]) end end
  for _, f in ipairs(p.back or {}) do f() end
  for _, x in ipairs{ 210, 268 } do local pm = rect(x, 64, x + 2, 100); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 }) end
  local bar = rect(208, 70, 272, 73); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  plate(240, 84, R[p.plate or "OAK"], { w = 40 })
  mkdoor(p, "burrow"); applyOv(p, "burrow")
  for x = 206, 274 do if hash(x, 1, 8) > .5 then GX.tuft(c, x, 130 - floor(abs(x - 240) ^ 2 / 60) + 6, R4(GREEN)) end end
  step(210, 270, 205, STONE, { h = 4 })
  for i = 1, 14 do tuft(floor(hash(i, 1, 6) * 470) + 6, 210 + floor(hash(i, 2, 6) * 56), GREEN) end
  flowers(14, 21, 70, 190, p.fl or { "#f0809c", "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x, y) return (x > 195 and x < 285 and y > 60) or (x > 285 and x < 330 and y < 150) end)
  runProps(p)
  lamp(p)
end

---------------------------------------------------------------- TREEHOUSE
function H.treehouse(p)
  sky(p.sky or { "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8" }, 7, 215)
  c:cloud(24, 110, 46, p.cl1 or "#f8f0e0", p.cl2 or "#d6e6f0"); c:cloud(410, 130, 40, p.cl1 or "#f8f0e0", p.cl2 or "#d6e6f0")
  hills(function(x) return 172 + 8 * sin(x / 44) + 4 * sin(x / 13) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 215, 5)
  hills(function(x) return 190 + 6 * sin(x / 31 + 2) end, { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 6)
  grass(function(x) return 207 + floor(sin(x / 28) * 1.3) end, GREEN, 8)
  local BK = R[p.bark or "OAK"]
  GX.trunk(c, 150, 326, 30, 208, R4(BK), 4, { moss = { hi = GREEN[5], base = GREEN[4], shade = GREEN[3], deep = GREEN[2] } })
  local FA, FB = R[p.fa or "GREEN"], R[p.fb or "LEAF"]
  for _, b in ipairs{ { 30, 34, 72, 40 }, { 130, 24, 84, 34 }, { 250, 20, 90, 34 }, { 370, 30, 84, 38 }, { 450, 40, 56, 34 }, { 70, 52, 56, 22 }, { 230, 44, 70, 24 }, { 400, 54, 56, 20 } } do
    GX.foliage(c, b[1], b[2], b[3], b[4], R4(b[1] % 2 == 0 and FA or FB), b[1] + 3)
  end
  for _, k in ipairs{ { 168, 120 }, { 310, 190 } } do local km = c:ellipse(k[1], k[2], 3, 4); c:rim(km, INK); c:fillMask(km, BK[2]); P(k[1] - 1, k[2] - 2, BK[3]) end
  mkdoor(p); applyOv(p)
  for i = 0, 14 do local lx = 213 + floor(i * 3.4); P(lx, 133 + floor(abs(i - 7) / 3), GREEN[4 + i % 2]); P(lx, 132 + floor(abs(i - 7) / 3), GREEN[5]) end
  step(208, 272, 205, TIMB)
  plate(240, 84, R[p.plate or "TIMB"])
  for i = 0, 5 do P(205 + i * 8, 77 + i % 2 * 2, LEAF[4]); P(206 + i * 8, 78 + i % 2 * 2, LEAF[5]) end
  if p.ladder then
    local lx = 186; local ax0, ax1 = lx - 8, lx + 8
    local peg = rect(ax0 - 2, 92, ax1 + 2, 95); c:rim(peg, INK); S.obj(peg, TIMB, { base = 4, lit = 1, shade = 1 })
    for y = 96, 202 do
      local xo = floor(sin(y / 26) * 1.4 + .5)
      for _, rx in ipairs{ lx - 7 + xo, lx + 7 + xo } do P(rx - 1, y, INK); P(rx, y, DIRT[5]); P(rx + 1, y, DIRT[2]) end
      if (y - 96) % 10 == 5 then for x = lx - 8 + xo, lx + 8 + xo do P(x, y, INK); P(x, y + 1, (x < lx + xo) and TIMB[5] or TIMB[3]); P(x, y + 2, INK) end end
    end
  end
  if p.fungus then
    for _, f in ipairs{ { 288, 156, 8 }, { 292, 168, 6 }, { 284, 178, 5 } } do
      local fm = c:ellipse(f[1], f[2], f[3], 3):clip(rect(f[1] - f[3] - 1, f[2] - 1, f[1] + f[3] + 1, f[2] + 3))
      c:rim(fm, INK); fm:each(function(x, y) P(x, y, (y == f[2] - 1 or y == f[2]) and "#f2a060" or ((y >= f[2] + 2) and "#c4622c" or "#e08040")) end)
      P(f[1] - 2, f[2] - 1, "#ffd8a0"); P(f[1] + 2, f[2] + 1, "#ffd8a0")
    end
  end
  for i = 1, 20 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  for x = 134, 160, 9 do tuft(x, 208, GREEN) end
  flowers(10, 31, 214, 266, p.fl or { "#ffd24a", "#fff2dc", "#c8b8ec" }, function(x) return x > 160 and x < 330 end)
  runProps(p)
  lamp(p)
end

---------------------------------------------------------------- HUT
function H.hut(p)
  sky(p.sky or { "#8ec8e8", "#a8d8ec", "#c4e4ee", "#f0e8cc", "#f8dcb0" }, 3, 215)
  c:cloud(30, 70, 46, "#fff4e0", "#f0d0b0"); c:cloud(400, 52, 40, "#fff4e0", "#f0d0b0")
  hills(function(x) return 176 + 8 * sin(x / 60 + 1) end, p.hill or { "#a8784c", "#bc8c58", "#d0a468", "#e0bc7c", "#ecd096", "#f4e0ac" }, 215, 4)
  local GR = p.ground or { "#97754a", "#b8935e", "#d0b078", "#e8d09a", "#f0dcaa", "#f8e8bc" }
  grass(function(x) return 207 + floor(sin(x / 22) * 1.2) end, GR, 9, { tex = .3 })
  local function banana(bx0, by, sc)
    for k = 1, 7 do
      local a = -2.7 + k * .32; local lm = HP.mask()
      for t = 0, 1, .04 do local px, py = bx0 + cos(a) * 46 * sc * t, by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t; GX.disc(lm, floor(px), floor(py), max(1, floor(5 * sc * (1 - t) + 1))) end
      c:rim(lm, INK); S.obj(lm, GREEN, { base = (k % 2 == 0) and 4 or 3, lit = 2, shade = 2 })
      for t = 0, 1, .05 do P(floor(bx0 + cos(a) * 46 * sc * t), floor(by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t), GREEN[6]) end
    end
    local tm = rect(bx0 - 3, by - 50 * sc, bx0 + 3, by); c:rim(tm, INK); S.obj(tm, LEAF, { base = 3 })
  end
  local function bamboo(bx0, by)
    for i, dx in ipairs{ -10, 0, 9 } do
      local h = ({ 130, 160, 112 })[i]; local m = rect(bx0 + dx, by - h, bx0 + dx + 5, by); c:rim(m, INK)
      m:each(function(x, y) local t = (x < bx0 + dx + 2) and 5 or ((x > bx0 + dx + 3) and 3 or 4); if (by - y) % 26 < 2 then t = 2 end; P(x, y, R.SAGE[min(6, t + 1)]) end)
      for k = 1, 4 do local yy = by - h + 20 + k * 22 - 10; for d = 1, 8 do P(bx0 + dx + 5 + d, yy - d // 2, GREEN[4]); P(bx0 + dx + 5 + d, yy - d // 2 + 1, GREEN[3]); P(bx0 + dx - d, yy - d // 2 - 3, GREEN[5]) end end
    end
  end
  local pl = p.plants or "banana"
  if pl == "banana" then banana(44, 206, 1); banana(436, 206, 1.1)
  elseif pl == "bamboo" then bamboo(50, 206); bamboo(432, 206)
  elseif pl == "cactus" then PR.cactus(52, 206, 62); PR.cactus(436, 206, 74) end
  local W = R[p.wall or "DIRT"]
  local wm = rect(142, 70, 338, 206)
  wm:each(function(x, y)
    local k = floor((x - 142) / 4); local t = 4 + ((hash(k, 1, 3) > .5) and 0 or -1)
    if (x - 142) % 4 == 0 then t = 2 elseif (x - 142) % 4 == 1 then t = t + 1 end
    if (y - 70) % 24 < 3 then t = (y - 70) % 24 == 0 and 6 or 3; if (y - 70) % 24 == 2 then t = 2 end end
    if hash(x, y // 6, 3) > .94 then t = t - 1 end
    local s = (x - 240) / 98; if s > .6 then t = t - 1 end
    P(x, y, W[max(1, min(6, t + 1))])
  end)
  c:rim(wm, INK)
  for _, x in ipairs{ 142, 332 } do local pm = rect(x, 70, x + 6, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 1, shade = 2 }); for y = 82, 200, 24 do for xx = x, x + 6 do P(xx, y, TIMB[2]) end end end
  local RF = R[p.roof or "THATCH"]
  local rm = HP.mask()
  for y = 6, 72 do local t = (y - 6) / 66; local hw = 6 + (t ^ .8) * 132 + floor(2 * sin(y / 5)); for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end end
  for x = 100, 380 do local hw = abs(x - 240); if hw > 100 then for y = 62, 74 do if hash(x, 5, 4) > .2 then rm:set(x, y) end end end end
  rm:each(function(x, y)
    local row = floor((y + 1.6 * sin(x / 5)) / 9); local t = (y + floor(1.6 * sin(x / 5))) % 9
    local s = (x - 240) / 138
    local v = .62 - s * .22 + (hash(x, row, 5) - .5) * .3 + (vn(x, y, 4, 7) - .5) * .2
    if t < 2 then v = v - .3 elseif t >= 6 then v = v + .15 end
    if hash(x, y // 4, 5) > .88 then v = v - .14 end
    P(x, y, RF[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .45 - (y - 73) * .1)) end end end
  local fin = c:ellipse(240, 6, 3, 4); c:rim(fin, INK); c:fillMask(fin, RF[3])
  step(204, 276, 205, TIMB, { h = 4 })
  mkdoor(p); applyOv(p)
  for y = 138, 202, 16 do for x = DX0 - 4, DX1 + 4, 1 do if x < DX0 or x > DX1 then P(x, y, DIRT[6]); P(x, y + 1, TIMB[2]) end end end
  plate(240, 84, R[p.plate or "TIMB"], { w = 44 })
  runProps(p)
  for i = 1, 16 do tuft(floor(hash(i, 1, 6) * 470) + 6, 214 + floor(hash(i, 2, 6) * 52), p.tuft or { "#6a502e", "#8a6a34", "#a8863c", "#c2a04a", "#d8b862", "#e8cc7c" }) end
  for i = 1, 9 do
    local x, y = 20 + floor(hash(i, 3, 6) * 440), 216 + floor(hash(i, 4, 6) * 48)
    if free(x, y) and not (x > 190 and x < 290) then c:fillMask(rect(x, y, x + 2, y + 1), "#a8906a"); P(x, y, "#c8b088"); P(x, y + 2, "#7a6040") end
  end
  lamp(p)
end

---------------------------------------------------------------- STONE
function H.stone(p)
  sky(p.sky or { "#a4c8e8", "#b8d4ec", "#cce0f0", "#e0ecf4", "#f0f0ec" }, 6, 215)
  c:cloud(30, 84, 50, p.cl1 or "#f8f0e0", p.cl2 or "#d6e6f0"); c:cloud(410, 60, 44, p.cl1 or "#f8f0e0", p.cl2 or "#d6e6f0")
  hills(function(x) return 168 + 10 * sin(x / 50) end, p.hill1 or { "#58708a", "#6c88a0", "#84a0b4", "#9cb6c6", "#b4cad4", "#cadce0" }, 215, 3)
  hills(function(x) return 190 + 7 * sin(x / 33 + 1) end, p.hill2 or { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 7)
  grass(function(x) return 207 + floor(sin(x / 26) * 1.2) end, GREEN, 10)
  local function cyl(x, y) local s = (x - 240) / 100; return (s > .82) and -2 or ((s > .55) and -1 or ((s < -.85) and -1 or 0)) end
  local wm = rect(140, 66, 340, 206); c:rim(wm, INK)
  stones(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, R[p.wall or "STONE"], { rh = 9, seed = 5, shade = cyl })
  moss(function(x, y) return wm:has(x, y) end, 140, 66, 340, 206, 13, function(x, y) return .56 + (206 - y) / 150 * .22 + ((x < 150 or x > 330) and -.1 or 0) end, 5)
  local rm = HP.mask()
  for y = 12, 72 do local t = (y - 12) / 60; local hw = 5 + (t ^ .9) * 132; for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end end
  c:rim(rm, INK)
  stones(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, R[p.roof or "SBLUE"], { rh = 6, seed = 8, wmin = 8, wvar = 6, shade = function(x, y) local s = (x - 240) / 130; return (s > .5) and -1 or ((s < -.2) and 1 or 0) end })
  moss(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, 17, function(x, y) return .66 - (72 - y) / 200 end, 4)
  local fin = c:ellipse(240, 10, 3, 4); c:rim(fin, INK); c:fillMask(fin, STONE[4]); P(239, 8, STONE[6])
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#2a1830", .5 - (y - 73) * .12)) end end end
  stones(function(x, y) return y >= 196 and y <= 206 and abs(x - 240) < 114 end, 126, 196, 354, 206, STONE, { rh = 6, seed = 20, wmin = 12, shade = function() return -1 end })
  for x = 126, 354 do if abs(x - 240) < 114 then P(x, 195, INK) end end
  step(204, 276, 205, STONE)
  p.door.f = 6; p.door.blocks = true
  mkdoor(p)
  moss(function(x, y) local fm = dmask("arch", DX0 - 6, DY0 - 6, DX1 + 6, DY1); return fm:has(x, y) and not dmask("arch", DX0, DY0, DX1, DY1):has(x, y) end, 210, 128, 270, 204, 31, function(x, y) return .6 + (y - 128) / 400 end, 4)
  applyOv(p)
  plate(240, 84, R[p.plate or "OAK"])
  for i = 1, 18 do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), GREEN) end
  flowers(9, 41, 212, 266, p.fl or { "#c8b8ec", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)
  runProps(p)
  lamp(p)
end

---------------------------------------------------------------- BOAT
function H.boat(p)
  sky(p.sky or { "#8ec4ea", "#a4d4ee", "#bce2f2", "#d4eef6", "#eaf4ee" }, 4, 150)
  c:cloud(44, 80, 52, p.cl1 or "#f8f0e0", p.cl2 or "#d6e6f0"); c:cloud(396, 56, 46, p.cl1 or "#f8f0e0", p.cl2 or "#d6e6f0")
  hills(function(x) return 128 + 8 * sin(x / 45) + 3 * sin(x / 12) end, p.hill or { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 152, 3)
  local WT = p.water or { "#1e4a6a", "#2a6a8a", "#3a86a4", "#52a0b8", "#78bccc", "#a8dce0" }
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
  local HU, TR = R[p.hull or "SBLUE"], R[p.trim or "CREAM"]
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
    P(x, y, (y >= 214 and y <= 217) and TR[(s > .7) and 4 or 5] or HU[max(1, min(6, t))])
  end)
  for _, px in ipairs{ 170, 210, 270, 310 } do
    local pm = c:ellipse(px, 226, 4, 4); c:rim(pm, INK); c:fillMask(pm, HU[2]); c:fillMask(c:ellipse(px, 226, 3, 3), "#a8d4ec"); P(px - 2, 224, "#e8f4f8"); P(px + 2, 228, "#6aa0c0")
  end
  for x = 130, 350 do if abs(x - 240) < 108 then local cur = c:get(x, 241); if cur then P(x, 241, WT[2]); P(x, 242, WT[3]) end end end
  for x = 150, 330, 4 do P(x, 243, WT[5]); P(x + 1, 243, WT[5]) end
  local tire = HP.mask(); for y = 222, 235 do for x = 338, 345 do tire:set(x, y) end end
  c:rim(tire, INK); tire:each(function(x, y) P(x, y, (x < 341) and "#5a5a6e" or "#34344a") end)
  local WL = R[p.wall or "TEAL"]
  local cm = rect(152, 66, 328, 205); c:rim(cm, INK)
  cm:each(function(x, y)
    local t = 4
    if p.pat == "vert" then
      if (x - 152) % 8 == 0 then t = 2 elseif (x - 152) % 8 == 1 then t = 5 end
    else
      if (y - 66) % 7 == 0 then t = 2 elseif (y - 66) % 7 == 1 then t = 5 end
    end
    if (x - 152) > 160 then t = t - 1 end
    if hash(x, y // 7, 3) > .96 then t = t - 1 end
    P(x, y, WL[max(1, min(6, t))])
  end)
  if p.chim ~= false then
    local ch = rect(274, 28, 288, 60); c:rim(ch, INK); stones(function(x, y) return ch:has(x, y) end, 274, 28, 288, 60, R[p.chimr or "BARN"], { rh = 5, seed = 4, wmin = 7, wvar = 4 })
    for k, q in ipairs{ { 280, 20, 4 }, { 286, 10, 5 }, { 294, 0, 6 } } do local sm = c:ellipse(q[1], q[2], q[3], q[3] - 1); c:rim(sm, INK); c:fillMask(sm, CREAM[5]); P(q[1] - 1, q[2] - 1, CREAM[6]) end
  end
  local RF = R[p.roof or "BARN"]
  local rk = p.roofkind or "pitch"
  local rm = HP.mask()
  if rk == "pitch" then
    for y = 46, 69 do local ins = floor((70 - y) * .3); for x = 142 + ins, 338 - ins do rm:set(x, y) end end
    c:rim(rm, INK)
    rm:each(function(x, y)
      local t = (y - 46) // 4; local col = RF[max(1, min(6, 5 - t))]
      if (x // 9) % 2 == 0 and y > 52 then col = RF[max(1, min(6, 5 - t - 1))] end
      P(x, y, col)
    end)
    for x = 142, 338 do P(x, 69, RF[2]) end
  elseif rk == "flat" then
    for y = 54, 69 do for x = 142, 338 do rm:set(x, y) end end
    c:rim(rm, INK)
    rm:each(function(x, y) local t = (y == 54) and 6 or ((y <= 56) and 5 or ((y >= 67) and 2 or 4)); if x < 146 then t = min(6, t + 1) end; if x > 334 then t = t - 1 end; P(x, y, RF[max(1, t)]) end)
    for x = 150, 330, 12 do P(x, 60, RF[3]); P(x, 61, RF[3]) end
    if p.roofdeco == "plants" then
      for x = 146, 334, 3 do local h = 3 + floor(hash(x, 4, 5) * 6); for k = 0, h do P(x, 53 - k, GREEN[(k > h - 2) and 5 or 3]) end end
      for x = 152, 330, 17 do ball(x, 46 - floor(hash(x, 1, 2) * 3), 3, 3, { "#7a2230", "#b0343a", "#e8493b", "#e8493b", "#ff9a8a", "#fff" }) end
    elseif p.roofdeco == "rail" then
      for x = 144, 336, 8 do bx(x, 42, x + 1, 53, CREAM) end
      bx(142, 41, 338, 44, CREAM)
    end
  else   -- dome / barrel roof with stripes
    for y = 34, 69 do local t = (y - 34) / 35; local hw = floor(98 * sqrt(1 - (1 - t) ^ 2) + .5) + 2; for x = 240 - hw, 240 + hw do rm:set(x, y) end end
    c:rim(rm, INK)
    rm:each(function(x, y)
      local s = floor((x - 142) / 14) % 2; local lx = (x - 240) / 100
      local t = (s == 0) and 4 or 5; if lx > .5 then t = t - 1 end; if lx < -.6 then t = t + 1 end
      if y < 38 + abs(x - 240) // 14 then t = t + 1 end
      if (x - 142) % 14 == 0 then t = 2 end
      P(x, y, RF[max(1, min(6, t))])
    end)
    for x = 142, 338 do P(x, 69, RF[2]) end
  end
  for y = 70, 73 do for x = 152, 328 do local cur = c:get(x, y); if cur and cur ~= INK then P(x, y, mixc(cur, "#102a30", .4 - (y - 70) * .09)) end end end
  local dk = rect(140, 204, 340, 210); c:rim(dk, INK)
  dk:each(function(x, y) local t = (y == 204) and 6 or ((y >= 209) and 2 or 4); if (x % 15) == 0 and y > 205 then t = 2 end; P(x, y, OAK[t]) end)
  if p.port == "round" or p.port == nil then
    local pm = c:ellipse(185, 128, 12, 12); c:rim(pm, INK); c:fillMask(pm, GOLD[3])
    local pg = c:ellipse(185, 128, 9, 9); c:rim(pg, GOLD[1]); c:fillMask(pg, SBLUE[4])
    pg:each(function(x, y) if y < 128 then P(x, y, SBLUE[5]) end end)
    for k = 0, 5 do P(180 + k, 124 - k + 3, SBLUE[6]) end
    for x = 177, 193 do P(x, 128, GOLD[2]) end; for y = 120, 136 do P(185, y, GOLD[2]) end
  elseif p.port == "square" then
    local fm = rect(172, 114, 198, 142); c:rim(fm, INK); S.obj(fm, R[p.portr or "CREAM"], { base = 4 })
    local gm = rect(176, 118, 194, 138); gm:each(function(x, y) P(x, y, (y < 128) and SBLUE[5] or SBLUE[4]) end)
    c:fillMask(rect(176, 127, 194, 128), TIMB[3]); c:fillMask(rect(184, 118, 185, 138), TIMB[3])
    for k = 0, 5 do P(178 + k, 126 - k, SBLUE[6]) end
  end
  if p.ring then
    local a, b = p.ring[1], p.ring[2]
    local lr = c:ellipse(318, 168, 8, 8); lr:cut(c:ellipse(318, 168, 3, 3)); c:rim(lr, INK)
    lr:each(function(x, y) local a2 = floor((math.atan(y - 168, x - 318) + 3.1416) / .7854); P(x, y, (a2 % 2 == 0) and a or b) end)
    P(313, 162, "#ff9a8a")
  end
  mkdoor(p); applyOv(p)
  plate(240, 84, R[p.plate or "OAK"])
  runProps(p)
  lamp(p)
end

-- ===================== w3: per-villager parameter table
PR.acorn, PR.herbs, PR.chimes, PR.can = acorn, herbs, chimes, can
local function pp(id, ...) local a = { ... }; return function() assert(PR[id], "no prop " .. id); PR[id](table.unpack(a)) end end
local DUSK = { "#6a5a9a", "#8a72b0", "#b48ac0", "#e0a0a8", "#f8c8a0" }
local V = {}
V["auntie-saffira"] = { home = "cottage", wall = "YEL", beam = "TIMB", roof = "THATCH", win = 3, shut = "TEAL", plate = "TIMB",
  door = { shape = "arch", wood = "TEAL", frame = "TIMB", straps = { 150, 186 } }, ov = { "crocus" }, lamp = "hang", fl = { "#c8b8ec", "#ffd24a", "#fff2dc" },
  props = { pp("yarnbasket", 190, 205), pp("bench", 40, 205, R.LAV), pp("bunting", 12, 205, 80, { "#e8493b", "#ffd24a", "#7fd0c4", "#c8b8ec" }, 7), pp("bunting", 280, 468, 80, { "#ffd24a", "#f0809c", "#7fd0c4" }, 7), pp("pot", 436, 205, "#c8b8ec") } }
V["cricket-hollowell"] = { home = "cottage", wall = "PEACH", beam = "OAK", roof = "BARN", roofkind = "tiles", win = 2, shut = "GREEN", plate = "OAK",
  door = { shape = "round", wood = "GREEN", frame = "TIMB", f = 4 }, ov = { "apple" }, lamp = "post", fl = { "#e8493b", "#ffd24a", "#fff2dc" },
  props = { pp("barrel", 66, 205, "apples"), pp("logs", 140, 205), pp("acorn", 286, 206), pp("berrybush", 436, 205, { "#7a2230", "#b0343a", "#e8493b" }) } }
V["fennick-barkley"] = { home = "cottage", wall = "MINT", beam = "TIMB", roof = "PLUM", roofkind = "tiles", win = 1, shut = "VIO", plate = "TIMB", wcols = { "#c8b8ec", "#ffd24a", "#7fd0c4" },
  door = { shape = "rect", wood = "VIO", frame = "TIMB" }, ov = { "lilypad" }, lamp = "jar", fl = { "#c8b8ec", "#7fd0c4", "#fff2dc" },
  props = { pp("stool", 190, 205, R.TEAL), pp("bookstack", 440, 205, { R.CORAL, R.NAVY, R.YEL }), pp("herbs", 344), pp("herbs", 366), pp("pot", 60, 205, "#7fd0c4") } }
V["jasper-burrowman"] = { home = "cottage", wall = "SBLUE", beam = "OAK", roof = "MOSSR", win = 2, shut = "OAK", plate = "OAK", wcols2 = { "#fff2dc", "#ffd24a", "#8fc0f0" },
  door = { shape = "rect", wood = "OAK", frame = "STONE", f = 4 }, ov = { "cross" }, lamp = "hang", fl = { "#8fc0f0", "#ffd24a", "#fff2dc" },
  props = { pp("wheelbarrow", 50, 205, "pumpkins"), pp("shovel", 170, 206), pp("vegrows", 392, 468, 214, "lettuce"), pp("fence", 100, 164, 205) } }
V["kestrel-petalwing"] = { home = "cottage", wall = "PASTEL", beam = "TIMB", roof = "CORAL", roofkind = "tiles", win = 0, plate = "ROSE",
  door = { shape = "arch", wood = "ROSE", frame = "CREAM", f = 4 }, ov = { "petals" }, lamp = "paper", lampcol = "CORAL", fl = { "#f0809c", "#ffd24a", "#fff2dc" },
  props = { pp("skep", 60, 205), pp("wreath", 166, 128, { "#fff2dc", "#f8c8dc", "#ffd24a" }), pp("pinwheel", 440, 205, 34, { "#f0809c", "#ffd24a", "#7fd0c4", "#c8b8ec" }), pp("pot", 150, 205, "#f0809c"), pp("pot", 384, 205, "#fff2dc") } }
V["bramble-sunpatch"] = { home = "boat", wall = "YEL", roof = "ORG", roofkind = "flat", roofdeco = "plants", hull = "TEAL", trim = "CREAM", port = "round", ring = { "#f08030", "#fff2dc" }, plate = "OAK", chimr = "ORG",
  door = { shape = "arch", wood = "REDW", frame = "CREAM", f = 4 }, ov = { "sun" }, lamp = "hang",
  props = { pp("sunflower", 168, 204, 36), pp("sunflower", 184, 204, 26), pp("tomatoes", 280, 204), pp("tomatoes", 300, 204) } }
V["captain-pipi-shellback"] = { home = "boat", wall = "CREAM", roof = "BARN", roofkind = "pitch", hull = "NAVY", trim = "GOLD", port = "round", ring = { "#e8493b", "#fff2dc" }, plate = "OAK", pat = "horiz",
  door = { shape = "arch", wood = "NAVY", frame = "GOLD", f = 4 }, ov = { "wheel" }, lamp = "hang",
  props = { pp("telescope", 174, 204), pp("coil", 198, 204), pp("bell", 290, 150), pp("buoy", 264, 204, "#e8493b", "#fff2dc") } }
V["gloam"] = { home = "boat", wall = "NIGHT", roof = "PLUM", roofkind = "dome", hull = "IRON", trim = "PLUM", port = "square", portr = "PLUM", plate = "PLUM", chim = true, chimr = "STONE", pat = "vert",
  sky = DUSK, hill = { "#2c2048", "#443272", "#5a4488", "#7258a0", "#9072b8", "#b094d0" }, water = { "#140e30", "#1e1848", "#2c2868", "#403a88", "#5a58a8", "#8a88c8" }, cl1 = "#d8b8d8", cl2 = "#9a78b8",
  door = { shape = "arch", wood = "PLUM", frame = "IRON", f = 4 }, ov = { "batwing" }, lamp = "paper", lampcol = "REDW",
  props = { pp("candlestack", 176, 204), pp("barrel", 200, 204, "green"), pp("lights", 156, 326, 100, 9, { "#ff9a8a", "#ffd070", "#e8493b" }), pp("crates", 268, 204) } }
V["moss-petalwing"] = { home = "boat", wall = "MINT", roof = "VIOLET", roofkind = "dome", hull = "CORAL", trim = "CREAM", port = "square", portr = "CREAM", plate = "OAK", chim = false, pat = "vert",
  door = { shape = "rect", wood = "VIO", frame = "CREAM", f = 4 }, ov = { "leaf" }, lamp = "star",
  props = { pp("easel", 178, 204), pp("pinwheel", 280, 204, 30, { "#7a5ac8", "#7fd0c4", "#ffd24a", "#f0809c" }), pp("crates", 292, 204), pp("pot", 158, 204, "#c8b8ec") } }
V["oakley-mossfoot"] = { home = "boat", wall = "GREEN", roof = "YEL", roofkind = "dome", hull = "TEAL", trim = "CREAM", port = "none", ring = false, plate = "OAK", chim = false, pat = "horiz",
  door = { shape = "arch", wood = "NAVY", frame = "CREAM", f = 4 }, ov = { "ripple" }, lamp = "hang",
  props = { pp("fishingrod", 160, 204), pp("lobsterpot", 198, 204), pp("net", 298, 168), pp("buoy", 270, 204, "#ffd24a", "#fff2dc") } }
V["rowan-burrowman"] = { home = "boat", wall = "OAK", roof = "BLUEW", roofkind = "pitch", hull = "GOLD", trim = "CREAM", port = "round", ring = false, plate = "OAK", chimr = "STONE", pat = "vert",
  door = { shape = "arch", wood = "BLUEW", frame = "GOLD", f = 4 }, ov = { "hex" }, lamp = "jar",
  props = { pp("skep", 172, 204), pp("oar", 198, 204, R.BLUEW), pp("shelfjars", 290, 160), pp("coil", 296, 204) } }
V["sorrel-petalwing"] = { home = "boat", wall = "LAV", roof = "ROSE", roofkind = "pitch", hull = "BARN", trim = "CREAM", port = "round", ring = { "#f0809c", "#fff2dc" }, plate = "OAK", chimr = "PLUM",
  door = { shape = "arch", wood = "PLUM", frame = "ROSE", f = 4 }, ov = { "feather" }, lamp = "hang",
  props = { pp("bookstack", 172, 204, { R.PLUM, R.CORAL, R.TEAL }), pp("pot", 198, 204, "#fff2dc"), pp("hangpots", 286, 150), pp("pot", 268, 204, "#f0809c") } }
V["madder-quillfeather"] = { home = "hut", wall = "DIRT", roof = "THATCH", plants = "bamboo", plate = "TIMB",
  door = { shape = "rect", wood = "REDW", frame = "TIMB", woven = true }, ov = { "scroll" }, lamp = "hang",
  props = { pp("quillink", 176, 205), pp("scrollrack", 296, 160), pp("bookstack", 112, 205, { R.NAVY, R.REDW, R.GOLD }), pp("bookstack", 214, 205, { R.CORAL, R.TEAL }) } }
V["pebble-leafwhisker"] = { home = "hut", wall = "SAGE", roof = "MOSSR", plants = "cactus", plate = "OAK", sky = { "#8ec8e8", "#b0d8ec", "#d0e8ee", "#f4ecd0", "#f8e4bc" },
  door = { shape = "arch", wood = "TEAL", frame = "TIMB", pw = 6 }, ov = { "dots" }, lamp = "post",
  props = { pp("cairn", 188, 206, 4), pp("cairn", 116, 206, 3), pp("signpost", 288, 206), pp("cairn", 420, 206, 2) } }
V["poppy-puddlejump"] = { home = "hut", wall = "ORG", roof = "THATCH", plants = "none", plate = "TIMB", ground = { "#7a8a3c", "#98a850", "#b4c468", "#cad884", "#dae8a0", "#eaf4bc" }, hill = { "#6a8a4a", "#80a05c", "#98b870", "#b0cc88", "#c8dca0", "#e0ecb8" },
  tuft = GREEN,
  door = { shape = "arch", wood = "GREEN", frame = "TIMB", woven = false }, ov = { "poppy" }, lamp = "paper", lampcol = "ORG",
  props = { pp("vegrows", 392, 468, 214, "carrot"), pp("can", 262, 205), pp("pot", 196, 205, "#e8493b"), pp("chilis", 168, 96, { "#7a2230", "#b0343a", "#e8493b" }), pp("pot", 152, 205, "#e8493b"), pp("sunflower", 70, 205, 40), pp("pumpkin", 100, 207, 7) } }
V["nocturna"] = { home = "stone", wall = "STONE", roof = "PLUM", plate = "OAK", sky = { "#5a4a8a", "#7a64a8", "#a484bc", "#d89ab0", "#f8c0a0" }, hill1 = { "#2c2048", "#443272", "#5a4488", "#7258a0", "#9072b8", "#b094d0" }, cl1 = "#e8c0d0", cl2 = "#a884b8",
  door = { shape = "arch", wood = "VIO", frame = "STONE" }, ov = { "moon" }, lamp = "jar", fl = { "#c8b8ec", "#fff2dc", "#ffd24a" },
  props = { pp("mobile", 178, 104), pp("crystal", 184, 205), pp("telescope", 290, 205), pp("chimes", 160) } }
V["tumble-seedwell"] = { home = "burrow", plate = "OAK",
  door = { wood = "PASTEL", frame = "STONE" }, ov = { "lattice" }, lamp = "post",
  back = { function() PR.chimney(170, 100, 30) end },
  props = { pp("breadrack", 176, 206), pp("seedsack", 286, 206), pp("sunflower", 124, 206, 34) } }
V["hazel-dewberry"] = { home = "treehouse", bark = "OAK", ladder = true, fungus = false, plate = "TIMB",
  door = { shape = "arch", wood = "ROSE", frame = "TIMB", f = 5, straps = { 152, 184 } }, ov = { "grapes" }, lamp = "hang",
  props = { pp("grapevine", 296, 206), pp("hangpots", 160, 136), pp("pot", 120, 206, "#c8b8ec"), pp("pot", 136, 206, "#ffd24a") } }
V["wren-thimblewick"] = { home = "treehouse", bark = "TIMB", ladder = false, fungus = true, plate = "TIMB", fa = "LEAF", fb = "GREEN",
  sky = { "#a8b8e0", "#c8c0e4", "#e8c8e0", "#f8d0c8", "#fce0b8" }, cl1 = "#fff0e8", cl2 = "#f0c8d0",
  door = { shape = "round", wood = "TEAL", frame = "TIMB", f = 5 }, ov = { "button" }, lamp = "hang",
  props = { pp("spool", 184, 206, R.CORAL, 30), pp("thimblePot", 118, 206), pp("bunting", 150, 330, 98, { "#e8493b", "#ffd24a", "#7fd0c4", "#c8b8ec", "#f0809c" }, 6) } }

local order = {}
for _, e in ipairs(LIST) do order[#order + 1] = e end

local v = V[name]
H[v.home](v)
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end
for _, n in ipairs(NAME == "all" and LIST or { NAME }) do build(n) end

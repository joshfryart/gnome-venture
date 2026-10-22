-- extras-pixel/sunflower: animated puzzle image (redraw of puzzles/sunflower.gif), Stitched Toy scene.
-- 400x300, 24 frames x 70 ms, loops forever, opaque background. Drawn on a 200x150 grid, written at 2x nearest.
-- Motion: sunflower sways on its stem (head + leaves ride the bending stem), a bee circles the head twice
-- per loop, clouds drift right (wrapping periods chosen so the loop is seamless).
-- Families: sky = water (stepped bands), hills/stem/leaves = moss/leaf, petals = gold (+ gold bounce as a
-- second base), seed disc = soil, clouds = soil cream (pale), bee = gold + dusk.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local pi, sin, cos, abs, floor, sqrt = math.pi, math.sin, math.cos, math.abs, math.floor, math.sqrt
local W, H, NF = 200, 150, 24

-- grab a finished sub-canvas as a pixel list {x,y,hex}
local function grab(cv)
  cv:finish()
  local list = {}
  for k, h in pairs(cv.pix) do
    local x, y = cv:xy(k)
    if cv:inside(x, y) then list[#list+1] = { x, y, h } end
  end
  return list, cv.W
end
local function blit(c, spr, ox, oy, flip)
  local list, w = spr[1], spr[2]
  for _, p in ipairs(list) do
    local x = flip and (w - 1 - p[1]) or p[1]
    c:px(ox + x, oy + p[2], p[3])
  end
end

---------------------------------------------------------------- sunflower head (drawn once)
local HS, HC = 74, 36.5
local head
do
  local h = GV.canvas{ w = HS, h = HS, mode = "scene", ol = 2, olx = 1 }
  local function petal(a, r0, r1, Wd)
    local m = h:mask()
    local ux, uy = sin(a), -cos(a)
    for y = 0, HS-1 do for x = 0, HS-1 do
      local dx, dy = x - HC, y - HC
      local t = dx*ux + dy*uy
      local n = -dx*uy + dy*ux
      if t >= r0 and t <= r1 then
        local f = (t - r0) / (r1 - r0)
        local w = Wd * (sin(pi * (0.18 + 0.82*f)) ^ 0.7)
        if f < 0.25 then w = Wd end
        if abs(n) <= w then m:set(x, y) end
      end
    end end
    return m
  end
  local N, step, rot = 16, 2*pi/16, 0.1
  local FRONT = GV.ramp("gold")
  local BACK  = GV.ramp("#d0862a")
  local back, fronts = h:mask(), {}
  for i = 0, N-1 do back:add(petal((i + 0.5)*step + rot, 11, 30, 4.3)) end
  local all = back:copy()
  for i = 0, N-1 do local m = petal(i*step + rot, 11, 31, 3.8); fronts[i] = m; all:add(m) end
  local light = all:closed(3)
  h:part(back, BACK, { light = light, gloss = false, outline = false, cres = 5 })
  local order = {}
  for i = 0, N-1 do order[#order+1] = i end
  local function lit(i) local a = i*step + rot return sin(a) + -cos(a) end -- larger = lower-right
  table.sort(order, function(p, q) return lit(p) > lit(q) end)
  for _, i in ipairs(order) do
    h:part(fronts[i], FRONT, { light = light, gloss = false, outline = false, cres = 5 })
  end
  -- stitched midrib on every front petal (thread gold, 2 on / 1 off)
  for i = 0, N-1 do
    local a = i*step + rot
    local ux, uy = sin(a), -cos(a)
    h:seam({ { floor(HC + ux*16 + 0.5), floor(HC + uy*16 + 0.5) }, { floor(HC + ux*27 + 0.5), floor(HC + uy*27 + 0.5) } })
  end
  -- enamel gloss on the upper-left petals
  for _, i in ipairs({ 13, 14 }) do
    local a = i*step + rot
    local ux, uy = sin(a), -cos(a)
    h:gloss(fronts[i], FRONT, { floor(HC + ux*21 - uy*1.5), floor(HC + uy*21 + ux*1.5) })
  end
  h:outline(all)
  -- seed disc (soil) with edge stitch, darker seed eye, floret lattice
  local disc = h:ellipse(HC, HC, 13.5, 13.5)
  local eye  = h:ellipse(HC, HC, 7, 7)
  local DISC = GV.ramp("#7a4a1f")
  local EYE  = GV.ramp("#4e2a16", { gloss = "#9a6b3f", dot = "#c9a96e", rim = "#7a4a1f" })
  h:part(disc, DISC, { outline = false, stitch = true, gloss = { 27, 27 } })
  h:part(eye, EYE, { outline = false, gloss = false, contact = false })
  for y = 0, HS-1 do for x = 0, HS-1 do
    local r = sqrt((x - HC)^2 + (y - HC)^2)
    local cur = h:get(x, y)
    if r < 6.2 and (x + 2*y) % 5 == 0 and cur ~= EYE.gloss and cur ~= EYE.rim then
      h:px(x, y, (cur == EYE.shade or cur == EYE.deep) and "#7a4a1f" or "#b8661a")
    elseif r > 8.3 and r < 10.6 and (x + y) % 4 == 0 and (x - y) % 4 == 2 then
      if cur == DISC.base or cur == DISC.shade or cur == DISC.rim then
        h:px(x, y, (cur == DISC.shade) and "#b8661a" or "#c9a96e")
      end
    end
  end end
  head = { grab(h) }
end

---------------------------------------------------------------- leaves (drawn once, anchored at the base)
local function makeLeaf(cw, ch, bx, by, tx, ty, Wd, bend)
  local l = GV.canvas{ w = cw, h = ch, mode = "scene", ol = 1, olx = 1 }
  local ax, ay = tx - bx, ty - by
  local len = sqrt(ax*ax + ay*ay)
  local ux, uy = ax/len, ay/len
  local m = l:mask()
  for y = 0, ch-1 do for x = 0, cw-1 do
    local dx, dy = x + 0.5 - bx, y + 0.5 - by
    local t = (dx*ux + dy*uy) / len
    if t >= 0 and t <= 1 then
      local n = (-dx*uy + dy*ux) - bend*sin(pi*t)
      local w = math.max(1.1, Wd * (sin(pi * t) ^ 0.75))
      if t > 0.12 and abs(n) <= w then m:set(x, y) end
      if t <= 0.12 and abs(n) <= 1.1 then m:set(x, y) end
    end
  end end
  l:part(m, "leaf", {})
  local pts = {}
  for s = 0.14, 0.86, 0.12 do
    local px = bx + ux*len*s - uy*bend*sin(pi*s)
    local py = by + uy*len*s + ux*bend*sin(pi*s)
    pts[#pts+1] = { floor(px), floor(py) }
  end
  l:seam(pts)
  return { grab(l) }, bx, by
end
local leafR1, r1x, r1y = makeLeaf(36, 22, 2, 15, 33, 5, 5.2, -2.2)
local leafL,  lx,  ly  = makeLeaf(40, 22, 37, 13, 2, 6, 5.4, 2.0)
local leafR2, r2x, r2y = makeLeaf(28, 16, 2, 11, 25, 4, 3.8, -1.5)

---------------------------------------------------------------- bee (wings up / down), faces right
local function makeBee(up)
  local b = GV.canvas{ w = 18, h = 15, mode = "scene", ol = 1, olx = 1 }
  local body = b:ellipse(7.5, 9, 4.5, 3)
  b:part(body, "gold", { gloss = { 5, 7 } })
  for _, sx in ipairs({ 6, 9 }) do
    for y = 0, 14 do
      if body:has(sx, y) and body:has(sx, y-1) and body:has(sx, y+1) then b:px(sx, y, "#3e2f66") end
    end
  end
  b:part(b:ellipse(13, 8.5, 2.5, 2.5), "dusk", { gloss = false })
  b:eye(13, 7, true)
  b:px(2, 9, "#2a1a10")
  local WING = GV.ramp("#c8ecdc")
  if up then
    b:part(b:ellipse(7, 3.5, 2.5, 3), WING, { flat = true })
    b:part(b:ellipse(10.5, 4, 1.5, 2.5), WING, { flat = true })
  else
    b:part(b:ellipse(5.5, 6, 3, 1.5), WING, { flat = true })
    b:part(b:ellipse(9.5, 5.5, 2, 1.5), WING, { flat = true })
  end
  return { grab(b) }
end
local beeUp, beeDn = makeBee(true), makeBee(false)

---------------------------------------------------------------- clouds (pale felt cushions)
local function makeCloud(cw, ch, blobs, baseR)
  local k = GV.canvas{ w = cw, h = ch, mode = "scene", ol = 1, olx = 1 }
  local m = k:mask()
  for _, e in ipairs(blobs) do m:add(k:ellipse(e[1], e[2], e[3], e[4])) end
  m:add(k:rrect(baseR[1], baseR[2], baseR[3], baseR[4], 3))
  k:part(m, GV.ramp("#f1ece0"), {})
  return { grab(k) }
end
local cloudBig = makeCloud(52, 27, { {14, 15, 8, 6.5}, {25, 10, 11, 8.5}, {37, 14, 8, 7} }, { 4, 13, 47, 22 })
local cloudSm  = makeCloud(32, 17, { {9, 9, 5.5, 4}, {16, 6.5, 6.5, 4.5}, {23, 9, 4.5, 3.5} }, { 3, 8, 28, 13 })

---------------------------------------------------------------- static background (sky, sun, hills)
local SKY = { "#5a86b8", "#6a9cc8", "#7fb3d6", "#8fcbd8", "#acdce0", "#c8ecdc" }
local SUNX, SUNY = 30, 22
local function farY(x) return floor(95 - 5*cos((x - 30)/40)) end
local function midY(x) return floor(107 + 3*sin(x/27 + 2)) end
local function meaY(x) return floor(118 + 2*sin(x/19)) end
local function botY(x) return floor(140 + 1.5*sin(x/13 + 1)) end
local BG = {}
for y = 0, H-1 do for x = 0, W-1 do
  local col
  if y >= botY(x) then col = "#2f5a2a"
  elseif y >= meaY(x) then col = (y == meaY(x)) and "#6a9a3a" or "#4a8a3e"
  elseif y >= midY(x) then col = (y == midY(x)) and "#a4b86a" or "#7ab55c"
  elseif y >= farY(x) then col = (y == farY(x)) and "#c8d77a" or "#a4b86a"
  else
    local v = math.min(5, floor(y / 96 * 6))
    local r = sqrt((x - SUNX)^2 + (y - SUNY)^2)
    local g = r < 19 and 5 or (r < 30 and 4 or (r < 43 and 3 or (r < 58 and 2 or 0)))
    col = SKY[math.max(v, g) + 1]
    if r < 7.5 then col = "#fff1c8" elseif r < 9 then col = "#f5cf6a" end
  end
  BG[#BG+1] = { x, y, col }
end end

-- grass blades and meadow flowers (deterministic)
local seed = 7
local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
local BLADES = {}
for i = 1, 150 do
  local x = rnd(W)
  local y0 = meaY(x) + 1 + rnd(30)
  if i % 4 == 0 then y0 = meaY(x) + 1 end
  local hgt = 3 + rnd(5)
  local tilt = rnd(3) - 1
  local col = (y0 >= botY(x)) and "#4a8a3e" or ((i % 3 == 0) and "#6a9a3a" or "#2f5a2a")
  if y0 <= meaY(x) + 2 then col = "#2f5a2a" end
  for j = 0, hgt - 1 do
    BLADES[#BLADES+1] = { x + ((j >= hgt - 2) and tilt or 0), y0 - j, col }
  end
end
local FL = {
  { 6, 134, "#f1ece0", "#e8a317" }, { 24, 132, "#f5cf6a", "#b8661a" }, { 34, 136, "#8fcbd8", "#f5cf6a" },
  { 46, 133, "#f1ece0", "#e8a317" }, { 62, 141, "#f1ece0", "#e8a317" }, { 72, 130, "#f5cf6a", "#b8661a" },
  { 86, 140, "#8fcbd8", "#f5cf6a" }, { 128, 138, "#f5cf6a", "#b8661a" }, { 122, 145, "#f1ece0", "#e8a317" },
  { 142, 125, "#f1ece0", "#e8a317" }, { 158, 126, "#8fcbd8", "#f5cf6a" }, { 170, 131, "#f1ece0", "#e8a317" },
  { 184, 134, "#f5cf6a", "#b8661a" }, { 194, 143, "#f1ece0", "#e8a317" }, { 14, 145, "#f5cf6a", "#b8661a" },
}
local FLROWS = { ".pp.", "pccp", "pcco", ".po." }

---------------------------------------------------------------- frames
local spr = Sprite(W*2, H*2, ColorMode.RGB)
for _ = 2, NF do spr:newEmptyFrame() end
local BASEX, BASEY = 105, 152
local REST = { 105, 62 }
local function stemAt(t, hx, hy, lean)
  local p0x, p0y = BASEX, BASEY
  local p1x, p1y = BASEX + lean*0.35, 112
  local p2x, p2y = hx + 0.5, hy + 10
  local a, b, cc = (1-t)^2, 2*(1-t)*t, t^2
  return a*p0x + b*p1x + cc*p2x, a*p0y + b*p1y + cc*p2y
end
local checks = {}
for f = 0, NF-1 do
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1 }
  for _, p in ipairs(BG) do c:px(p[1], p[2], p[3]) end
  -- clouds: small row (period 200/3, shifts one period per loop), big row (period 100, one period per loop)
  local ps, pb = 200/3, 100
  local offS, offB = f * ps / NF, f * pb / NF
  for kk = -1, 3 do blit(c, cloudSm, floor(-10 + offS + kk*ps + 0.5), 1) end
  for kk = -1, 2 do blit(c, cloudBig, floor(58 + offB + kk*pb + 0.5), 12) end
  -- sway
  local ph = 2*pi*f/NF
  local dx = floor(4.5*sin(ph) + 0.5)
  local dy = floor(1.2*sin(2*ph + 0.6) + 0.5)
  local hx, hy = REST[1] + dx, REST[2] + dy
  -- leaves ride the stem
  local function leafAt(spr2, ax, ay, t)
    local sx, sy = stemAt(t, hx, hy, dx)
    local rx, ry = stemAt(t, REST[1], REST[2], 0)
    blit(c, spr2, floor(rx + 0.5) - ax + floor(sx - rx + 0.5), floor(ry + 0.5) - ay + floor(sy - ry + 0.5))
  end
  leafAt(leafL, lx, ly, 0.33)
  leafAt(leafR1, r1x - 1, r1y, 0.58)
  leafAt(leafR2, r2x - 1, r2y, 0.16)
  -- stem
  local pts = {}
  for i = 0, 12 do local sx, sy = stemAt(i/12, hx, hy, dx) pts[#pts+1] = { floor(sx), floor(sy) } end
  c:part(c:line(pts, 3), "moss", { gloss = false })
  -- grass in front
  for _, p in ipairs(BLADES) do c:px(p[1], p[2], p[3]) end
  for _, q in ipairs(FL) do
    c:paint(FLROWS, q[1], q[2], { p = q[3], c = q[4], o = "#2a1a10" })
  end
  -- head
  blit(c, head, hx - 36, hy - 36)
  -- bee: clockwise orbit around the head, two laps per loop, wings flap every frame
  local a = 2*pi*f/12
  local bx = hx + 0.5 + 40*cos(a)
  local by = hy - 10 + 17*sin(a)
  local left = sin(a + 0.1) > 0
  blit(c, (f % 2 == 0) and beeUp or beeDn, floor(bx - 9 + 0.5), floor(by - 8 + 0.5), left)

  local img = c:image()
  spr:newCel(spr.layers[1], spr.frames[f+1], img, Point(0, 0))
  spr.frames[f+1].duration = 0.07
  checks[#checks+1] = GV.check(img)
end
app.activeSprite = spr
app.command.BackgroundFromLayer()
pcall(function() app.fs.makeAllDirectories(O .. "aseprite") end)
pcall(function() app.fs.makeAllDirectories(O .. "png") end)
spr:saveAs(O .. "aseprite/sunflower.aseprite")
spr:saveCopyAs(O .. "png/sunflower.gif")
local maxc, semi, bw = 0, 0, 0
for _, t in ipairs(checks) do maxc = math.max(maxc, t.colours) semi = semi + t.semi bw = bw + t.bw end
print(GV.report(checks[1]) .. string.format(" | frames=%d maxColours=%d semiAll=%d bwAll=%d", #checks, maxc, semi, bw))
spr:close()

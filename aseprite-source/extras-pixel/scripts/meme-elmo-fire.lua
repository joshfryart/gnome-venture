-- puzzles/elmo-fire.gif redraw (pass 2): a red felt puppet, whole body, arms flung up, grinning in front of
-- roaring flames. 360x246 (source 498x339 aspect), 24 frames x 60 ms, loops forever, solid background.
-- Drawn on a 180x123 half grid (scene mode, no halo), written at 2x nearest.
-- Flames: a heat field from periodic value noise scrolled upward by whole lattice periods per loop, plus
-- tongue columns with whole-number cycles, so the flicker wraps seamlessly. Look-alike only: no logos/text.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H, N = 180, 123, 24
local TAU = math.pi * 2
local floor, sin, cos, exp, max, min = math.floor, math.sin, math.cos, math.exp, math.max, math.min

local SKY = { "#1c0d10", "#24101a", "#2e1418", "#3a1a16" }                       -- smoky dark, umber family
local fur = GV.ramp("#d6322b", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a" }) -- ember base, red family
local nose = GV.ramp("#f08a24")                                                   -- ember orange
local eyeR = GV.ramp("#f1ece0")                                                   -- soil cream, pale
-- heat bands, cool to hot: smoke glow, deep, red, ember, orange, gold, pale gold, cream core
local HEAT = { { 0.05, "#4a2214" }, { 0.16, "#6b1b2c" }, { 0.26, "#ae2a2a" }, { 0.36, "#e0501f" },
  { 0.47, "#f08a24" }, { 0.58, "#e8a317" }, { 0.70, "#f5cf6a" }, { 0.83, "#fff1c8" } }

-- deterministic hash in [0,1)
local function hash(a, b, s)
  local h = (a * 374761393 + b * 668265263 + (s or 0) * 2147483647) % 4294967296
  h = ((h ~ (h >> 13)) * 1274126177) % 4294967296
  return (h ~ (h >> 16)) % 65536 / 65536
end
-- value noise periodic in x (px cells) and y (py cells)
local function vnoise(x, y, cw, ch, px, py, s)
  local fx, fy = x / cw, y / ch
  local ix, iy = floor(fx), floor(fy)
  local tx, ty = fx - ix, fy - iy
  tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
  local function v(i, j) return hash(i % px, j % py, s) end
  local a = v(ix, iy) + (v(ix + 1, iy) - v(ix, iy)) * tx
  local b = v(ix, iy + 1) + (v(ix + 1, iy + 1) - v(ix, iy + 1)) * tx
  return a + (b - a) * ty
end

-- tall tongue columns: {x, width, height boost, cycles, phase}
local TONG = {}
for i = 0, 10 do
  TONG[#TONG+1] = { x = 8 + i * 16.4 + hash(i, 1, 5) * 8, w = 5 + hash(i, 2, 5) * 6, b = 0.18 + hash(i, 3, 5) * 0.32,
    k = 1 + floor(hash(i, 4, 5) * 3), p = hash(i, 5, 5) * TAU }
end

local function heatAt(x, y, f)
  local t = f / N
  local up = (H - y) / H                                  -- 0 at bottom, 1 at top
  -- noise scrolls up by exactly one period (or two) per loop
  local n1 = vnoise(x + 3 * sin(TAU * t + y * 0.06), y + t * 8 * 24, 12, 24, 15, 8, 1)
  local n2 = vnoise(x, y + t * 2 * 16 * 8, 6, 8, 30, 16, 2)
  local n3 = vnoise(x, y + t * 3 * 8 * 8, 3, 8, 60, 8, 3)
  local v = n1 * 0.64 + n2 * 0.28 + n3 * 0.08
  local col = 0
  for _, g in ipairs(TONG) do
    local sway = 4 * sin(TAU * g.k * t + g.p + y * 0.05) * up
    local d = (x - g.x - sway) / g.w
    col = col + g.b * (0.75 + 0.25 * sin(TAU * g.k * t + g.p)) * exp(-d * d)
  end
  local core = 0.30 * exp(-((x - 90) / 48) ^ 2) * exp(-((y - 72) / 60) ^ 2)   -- bright heart behind the puppet
  return v * 0.95 + col + core + 0.18 - up * 0.95
end

local function drawFire(c, f)
  c:bands(c:rect(0, 0, W - 1, H - 1), SKY)
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local h = heatAt(x, y, f)
      local col
      for _, b in ipairs(HEAT) do if h >= b[1] then col = b[2] end end
      if col then c:px(x, y, col) end
    end
  end
  -- detached licks: blobs that break off tongue tips and rise (one rise per loop, whole cycles)
  for i = 0, 6 do
    local ph = (f / N + i / 7) % 1
    local x = floor(12 + i * 25 + hash(i, 9, 7) * 10 + 4 * sin(TAU * ph * 2 + i))
    local y = floor(50 - ph * 46 - hash(i, 8, 7) * 10)
    local r = 3.5 * (1 - ph)
    if r >= 1.2 then
      c:fill(c:ellipse(x, y, r * 0.8, r * 1.3), ph < 0.5 and "#e0501f" or "#ae2a2a")
      if r >= 2.2 then c:fill(c:ellipse(x, y + 1, r * 0.35, r * 0.6), "#f08a24") end
    end
  end
  -- sparks: rise with a zig-zag and wrap once per loop; some leave a 2 px streak
  for i = 0, 27 do
    local ph = (f / N * (1 + i % 2) + hash(i, 1, 11)) % 1
    local x = floor(hash(i, 2, 11) * (W - 4) + 2 + 3 * sin(TAU * ph * 3 + i))
    local y = floor(H - 6 - ph * (H + 4))
    local col = (i % 4 == 0) and "#fff1c8" or ((i % 4 == 1) and "#f5cf6a" or ((i % 4 == 2) and "#f08a24" or "#e8a317"))
    if y >= 0 then
      c:px(x, y, col)
      if i % 3 == 0 then c:px(x, y + 1, "#e0501f") end
      if i % 5 == 0 then c:px(x + 1, y, col) end
    end
  end
end

-- fuzzy felt: tufts on the silhouette edge (keyed to puppet-local coords so they ride with the sway)
local function tuft(c, m, ox, oy, seed)
  local ring = m:grow(1):cut(m)
  ring:each(function(x, y) if hash(x - ox, y - oy, seed) < 0.33 then m:set(x, y) end end)
  local e = m:edge()
  e:each(function(x, y) if hash(x - ox, y - oy, seed + 1) < 0.18 then m:del(x, y) end end)
  return m
end
-- flecks of tone inside the fur, never on gloss, outline or the eyes/nose (only on fur tones)
local function flecks(c, m, ox, oy)
  local swap = { [fur.base] = fur.shade, [fur.shade] = fur.deep, [fur.rim] = fur.base }
  local lift = { [fur.base] = fur.rim, [fur.shade] = fur.base }
  m:each(function(x, y)
    local cur = c:get(x, y)
    local hv = hash(x - ox, y - oy, 41)
    if hv < 0.06 and swap[cur] and cur ~= fur.shade then c:px(x, y, swap[cur])
    elseif hv > 0.965 and lift[cur] and (x - ox) + (y - oy) < 150 then c:px(x, y, lift[cur]) end
  end)
end

local function drawFrame(f)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  drawFire(c, f)

  local t = f / N
  local sx = floor(2.5 * sin(TAU * t) + 0.5)                    -- body sway, one cycle per loop
  local hx = sx + floor(1.2 * sin(TAU * t - 0.9) + 0.5)         -- head lags the body
  local hy = (sin(TAU * 2 * t) > 0.35) and 1 or 0               -- bob on the beat
  local cx = 90 + sx
  local hcx = 90 + hx
  -- arms: hands wave out of phase, elbows follow at half
  local function arm(side)
    local wob = TAU * 2 * t + (side < 0 and 0 or 2.2)
    local hxo, hyo = 3 * sin(wob), 2.5 * cos(wob)
    local sh = { cx + side * 20, 86 }
    local el = { cx + side * 36 + hxo * 0.4, 66 + hyo * 0.4 }
    local ha = { cx + side * 47 + hxo, 44 + hyo }
    local m = c:line({ sh, el, ha }, 9)
    m:add(c:ellipse(ha[1], ha[2] - 3, 6.5, 6))
    -- four spread fingers
    for k = 0, 3 do
      local a = -1.95 + side * (0.15 + k * 0.42) + 0.12 * sin(wob + k)
      local fx, fy = ha[1] + cos(a) * 7, ha[2] - 3 + sin(a) * 7
      local tx, ty = ha[1] + cos(a) * 11, ha[2] - 3 + sin(a) * 11
      m:add(c:line({ { fx, fy }, { tx, ty } }, 3))
    end
    return m
  end
  local armL, armR = arm(-1), arm(1)
  local body = c:ellipse(cx, 94, 25, 21)
  body:add(c:rrect(cx - 24, 92, cx + 24, 110, 11))
  local feet = c:ellipse(cx - 12, 113, 9, 5):add(c:ellipse(cx + 12, 113, 9, 5))
  local head = c:ellipse(hcx, 60 + hy, 25, 19)
  local all = armL:copy():add(armR):add(body):add(feet):add(head)
  local ox, oy = cx, 0
  tuft(c, armL, ox, oy, 3); tuft(c, armR, ox, oy, 5); tuft(c, body, ox, oy, 7); tuft(c, head, hcx, hy, 9)
  local p = c:build{
    { "feet", feet, fur, { cres = 3 } },
    { "armL", armL, fur, { cres = 3, light = all } },
    { "armR", armR, fur, { cres = 3 } },
    { "body", body, fur, { cres = 6 } },
    { "head", head, fur, { cres = 6, gloss = { hcx - 15, 50 + hy } } },
  }
  flecks(c, all:grow(1), cx, 0)
  c:stitch(c:ellipse(cx, 94, 25, 21):add(c:rrect(cx - 24, 92, cx + 24, 110, 11)), { side = "lit" })

  local b = hy
  local ex = hcx
  -- open grinning mouth (opens wider on the beat)
  local mo = (sin(TAU * 2 * t + 0.6) > 0) and 1 or 0
  local mouth = c:ellipse(ex, 68 + b, 12, 4.5 + mo):cut(c:rect(ex - 13, 60 + b, ex + 13, 65 + b))
  c:fill(mouth, "#35161f")
  c:fill(c:rect(ex - 6, 70 + b + mo, ex + 5, 71 + b + mo):clip(mouth), "#6b1b2c")
  -- big ping-pong eyes, pupils rolled up; blink on frames 16-18
  local blink = (f == 16 or f == 18) and 1 or ((f == 17) and 2 or 0)
  for s = -1, 1, 2 do
    local cxE = ex + s * 7.5
    local eye = c:ellipse(cxE, 49 + b, 7, 6)
    c:part(eye, eyeR, { pale = true, cres = 2, gloss = (blink == 0) and { cxE - 4.5, 46 + b } or false, contact = false })
    local px = (s < 0) and floor(cxE - 0.5) or floor(cxE - 2.5)
    local dart = (sin(TAU * t) > 0.6) and 1 or 0
    if blink < 2 then
      c:fill(c:rect(px + dart, 46 + b, px + 3 + dart, 49 + b), "#2a1a10")
      if blink == 0 then c:px(px + dart, 46 + b, "#f1ece0") end
    end
    if blink > 0 then -- felt lid drops over the ball: half on 16/18, nearly shut on 17
      local ly = (blink == 1) and 47 or 52
      local lid = eye:copy():clip(c:rect(cxE - 8, 40 + b, cxE + 8, ly + b))
      c:fill(lid, fur.base)
      lid:each(function(x, y) if not lid:has(x - 1, y) or not lid:has(x, y - 1) then c:px(x, y, fur.rim) end end)
      c:fill(c:rect(cxE - 7, ly + 1 + b, cxE + 7, ly + 1 + b):clip(eye), "#4a2c1a")
    end
  end
  -- orange nose
  c:part(c:ellipse(ex, 60 + b, 5.5, 4.5), nose, { cres = 2, gloss = { ex - 3, 57 + b } })
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "elmo-fire"
for f = 1, N do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(f - 1)
  if f == 1 then spr.cels[1].image = img; img:saveAs(G .. "elmo-fire-still.png") else spr:newCel(layer, f, img) end
  spr.frames[f].duration = 0.06
  local t = GV.check(img)
  if f == 1 or f == 13 then print("frame " .. f .. ": " .. GV.report(t)) end
  assert(t.semi == 0 and t.bw <= 8) -- only the pale eye dots are #ffffff
end
pcall(function() app.fs.makeAllDirectories(O .. "puzzles-gif") end)
spr:saveAs(O .. "puzzles-gif/elmo-fire.aseprite")
spr:saveCopyAs(G .. "elmo-fire.gif")
spr:close()
print("saved")

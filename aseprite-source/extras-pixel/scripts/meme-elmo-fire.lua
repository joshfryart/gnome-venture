-- puzzles/elmo-fire.gif redraw (pass 3): a red felt puppet, whole body, arms flung up, grinning in front of
-- roaring flames. 360x246 (source 498x339 aspect), 24 frames x 60 ms, loops forever, solid background.
-- Drawn on a 180x123 half grid (scene mode, no halo), written at 2x nearest.
-- Flames: layered tongue silhouettes (back row tall and dark, front row short and hot) combined by max so
-- every tongue reads as clean concentric bands; the bed, sway and flicker use whole-number cycles per loop
-- and the edge wobble scrolls by whole lattice periods, so the loop is seamless. Look-alike only: no logos/text.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H, N = 180, 123, 24
local TAU = math.pi * 2
local floor, sin, cos, exp, max, min, abs = math.floor, math.sin, math.cos, math.exp, math.max, math.min, math.abs

local SKY = { "#1c0d10", "#24101a", "#2e1418", "#3a1a16" }                       -- smoky dark, umber family
local fur = GV.ramp("#d6322b", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a" }) -- ember base, red family
local nose = GV.ramp("#f08a24")                                                   -- ember orange
local eyeR = GV.ramp("#f1ece0")                                                   -- soil cream, pale
-- heat bands, cool to hot: smoke glow, deep, red, ember, orange, gold, pale gold, cream core
local HEAT = { { 0.06, "#4a2214" }, { 0.16, "#6b1b2c" }, { 0.27, "#ae2a2a" }, { 0.40, "#e0501f" },
  { 0.53, "#f08a24" }, { 0.66, "#e8a317" }, { 0.79, "#f5cf6a" }, { 0.91, "#fff1c8" } }

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

-- tongues: {x, base half-width, height, heat (0..1 at the base), cycles per loop, phase}
local TONG = {}
local function addTongues(n, pitch, w0, w1, h0, h1, heat, seed)
  for i = 0, n - 1 do
    TONG[#TONG+1] = { x = pitch * (i + 0.5) + (hash(i, 1, seed) - 0.5) * pitch * 0.6, w = w0 + hash(i, 2, seed) * (w0 and (w1 - w0) or 0),
      h = h0 + hash(i, 3, seed) * (h1 - h0), heat = heat, k = 1 + floor(hash(i, 4, seed) * 3), p = hash(i, 5, seed) * TAU,
      amp = 3 + hash(i, 6, seed) * 4 }
  end
end
addTongues(9, 20, 11, 16, 76, 116, 0.84, 21)  -- back row: tall and wide, red/orange
addTongues(13, 14, 8, 12, 30, 64, 0.98, 23)    -- front row: short, hot
addTongues(18, 10, 6, 9, 12, 26, 1.0, 25)       -- bed licks: small cream nubs along the bottom

local function heatAt(x, y, f)
  local t = f / N
  -- edge wobble: scrolls up by whole periods per loop, keeps tongue edges from being perfect contours
  local wob = (vnoise(x, y + t * 10 * 8, 7, 10, 26, 8, 1) - 0.5) * 0.28
  local v = 0
  for _, g in ipairs(TONG) do
    local flick = 0.78 + 0.22 * sin(TAU * g.k * t + g.p)
    local h = g.h * flick
    local u = (H - 2 - y) / h                               -- 0 at the base, 1 at the tip
    if u >= 0 and u < 1 then
      local axis = g.x + g.amp * sin(TAU * g.k * t + g.p + u * 2.6) * u * u
      local w = g.w * (1 - u) ^ 0.7 + 0.6
      local d = abs(x - axis) / w + wob * (0.4 + u)
      if d < 1 then
        local val = (1 - d * d) * g.heat * (1 - 0.66 * u)
        if val > v then v = val end
      end
    end
  end
  -- bed: the fire floor, hard cream at the very bottom fading up through the bands
  local bed = 1.05 - (H - 1 - y) * 0.045 + wob * 0.5
  if bed > v then v = bed end
  return v
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
  -- detached licks: teardrops that break off tongue tips and rise (one rise per loop, whole cycles)
  for i = 0, 6 do
    local ph = (f / N + i / 7) % 1
    local x = floor(12 + i * 25 + hash(i, 9, 7) * 10 + 4 * sin(TAU * ph * 2 + i))
    local y = floor(48 - ph * 44 - hash(i, 8, 7) * 10)
    local r = 3.5 * (1 - ph)
    if r >= 1.2 then
      local m = c:ellipse(x, y, r * 0.8, r * 1.2)
      m:add(c:ellipse(x, y - r * 1.1, r * 0.35, r * 0.8))
      c:fill(m, ph < 0.45 and "#e0501f" or "#ae2a2a")
      if r >= 2.2 then c:fill(c:ellipse(x, y + 1, r * 0.35, r * 0.6), ph < 0.25 and "#e8a317" or "#f08a24") end
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
  -- big ping-pong eyes, pupils rolled up; blink on frames 16-18 (half, shut, half)
  local blink = (f == 16 or f == 18) and 1 or ((f == 17) and 2 or 0)
  local inner = head:shrink(2)                                  -- lids are felt: they never cross the head edge
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
    if blink == 1 then
      -- half blink: a felt lid (the same fur as the head, outline ring covered too) drops to the pupil's middle,
      -- with one shade line for its edge. Nothing bright or dark rings the eye, so it reads as a lid.
      local ly = 48 + b
      local lid = eye:grow(3):clip(c:rect(cxE - 11, 38 + b, cxE + 11, ly)):clip(inner)
      c:fill(lid, fur.base)
      c:fill(c:rect(cxE - 7, ly, cxE + 7, ly):clip(eye), fur.shade)
    elseif blink == 2 then
      -- shut: the ball is gone, only a downward lash curve of deep fur shows where the eye is
      c:fill(eye:grow(3):clip(inner), fur.base)
      local curve = c:ellipse(cxE, 46 + b, 7, 5):cut(c:ellipse(cxE, 45 + b, 7, 5)):clip(c:rect(cxE - 7, 48 + b, cxE + 7, 52 + b))
      c:fill(curve, fur.deep)
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

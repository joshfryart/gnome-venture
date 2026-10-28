-- puzzles/elmo-fire.gif redraw (pass 4): a red felt puppet, whole body, arms flung up, open-mouthed grin, in front of
-- roaring flames. 360x246 (source 498x339 aspect), 24 frames x 60 ms, loops forever, solid background.
-- Drawn on a 180x123 half grid (scene mode, no halo), written at 2x nearest.
-- Flames: four rows of tongue silhouettes (far dim smoke-red, back, front, bed) combined by max into concentric heat
-- bands. Each tongue has its own tip exponent, belly bulge, curl and a lean that follows one travelling draft gust;
-- a scrolling erosion field bites tips into forks and loose licks; 1 px band islands are cleaned for felt patches.
-- Sky is a stepped radial glow. Every cycle (sway, flicker, gust, noise scroll by whole periods) is whole per loop,
-- so the loop is seamless. Look-alike only: no logos/text.
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

-- tongues: {x, base half-width, height, heat, cycles per loop, phase, draft lean, curl, tip exponent, bulge}
-- tip exponent e: low = blunt rounded tip, high = narrow; bulge fattens the belly so no two tongues share a profile
local TONG = {}
local function addTongues(n, pitch, w0, w1, h0, h1, heat, seed, lean)
  for i = 0, n - 1 do
    local r = function(k) return hash(i, k, seed) end
    TONG[#TONG+1] = { x = pitch * (i + 0.5) + (r(1) - 0.5) * pitch * 0.7, w = w0 + r(2) * (w1 - w0),
      h = h0 + (r(3) ^ 0.8) * (h1 - h0), heat = heat, k = 1 + floor(r(4) * 3), p = r(5) * TAU,
      curl = 2 + r(6) * 5, lean = lean * (r(7) < 0.2 and -0.5 or (0.5 + r(7))),
      e = 0.35 + r(8) * 0.6, bul = r(9) * 0.4 }
  end
end
addTongues(8, 24, 14, 22, 100, 128, 0.36, 29, 14) -- far row: tall dim smoke-red tongues that fill the upper sky
addTongues(10, 18, 9, 17, 64, 118, 0.84, 31, 11)  -- back row: tall, some reach the top, lean hardest in the draft
addTongues(13, 14, 7, 12, 30, 70, 0.98, 33, 6)    -- front row: shorter, hot
addTongues(18, 10, 5, 9, 12, 28, 1.0, 35, 2)      -- bed licks: small nubs along the bottom
-- fire glow behind the puppet: a few hot broad tongues so the brightest fire sits behind him, as in the source
TONG[#TONG+1] = { x = 70, w = 20, h = 92, heat = 0.95, k = 1, p = 0.4, curl = 4, lean = 6, e = 0.5, bul = 0.25 }
TONG[#TONG+1] = { x = 108, w = 20, h = 98, heat = 0.95, k = 2, p = 2.1, curl = 5, lean = 8, e = 0.45, bul = 0.3 }

local function heatAt(x, y, f)
  local t = f / N
  -- edge wobble (y period 80, scrolls 1 period per loop)
  local wob = (vnoise(x, y + t * 80, 7, 10, 26, 8, 1) - 0.5) * 0.24
  -- erosion (y period 90, scrolls 1 period per loop): bites the edges and upper part of each tongue into forks and
  -- loose licks that travel upward through it; the belly of a tongue stays solid
  local ero = vnoise(x, y + t * 90, 8, 9, 23, 10, 2)
  local v = 0
  for _, g in ipairs(TONG) do
    local flick = 0.8 + 0.2 * sin(TAU * g.k * t + g.p)
    local h = g.h * flick
    local u = (H - 2 - y) / h                               -- 0 at the base, 1 at the tip
    if u >= 0 and u < 1 then
      local gust = 0.6 + 0.4 * sin(TAU * t - g.x / 45)      -- one draft gust per loop, travelling across
      local axis = g.x + g.lean * gust * u ^ 1.6 + g.curl * sin(TAU * g.k * t + g.p + u * 3.4) * u * u * (1 + u)
      local w = g.w * (1 - u) ^ g.e * (1 + g.bul * sin(math.pi * u)) + 0.5
      local d = abs(x - axis) / w + wob * (0.4 + u)
      if d < 1 then
        local val = (1 - d * d) * g.heat * (1 - 0.62 * u) - max(0, ero - 0.45) * (u * u * 1.8 + d * d * 0.5)
        if val > v then v = val end
      end
    end
  end
  -- bed: the fire floor, its height rolls along the bottom (x period 180 = W, one period per loop)
  local bn = vnoise(x + t * 180, 0, 9, 1, 20, 1, 3)
  local bed = 1.05 - (H - 1 - y) * (0.025 + 0.06 * bn) + wob * 0.5
  if bed > v then v = bed end
  return v
end

-- sky: stepped radial glow, hot behind the puppet, cooling to smoky dark in the corners (ellipse, wider than tall)
local GLOW = { "#4a2214", "#3a1a16", "#2e1418", "#24101a", "#1c0d10" }
local function skyAt(x, y, f)
  local pulse = 3 * sin(TAU * 2 * f / N)                    -- breathes twice per loop
  local d = math.sqrt(((x - 90) / 1.25) ^ 2 + (y - 92) ^ 2) / (128 + pulse)
  return GLOW[min(#GLOW, max(1, floor(d * #GLOW) + 1))]
end

local function drawFire(c, f)
  -- heat to band index, then drop 1 px islands so every band is a clean felt patch
  local idx = {}
  for y = 0, H - 1 do
    local row = {}
    for x = 0, W - 1 do
      local h, k = heatAt(x, y, f), 0
      for i, b in ipairs(HEAT) do if h >= b[1] then k = i end end
      row[x] = k
    end
    idx[y] = row
  end
  for pass = 1, 2 do
    for y = 1, H - 2 do
      for x = 1, W - 2 do
        local k = idx[y][x]
        local n = { idx[y-1][x], idx[y+1][x], idx[y][x-1], idx[y][x+1] }
        if n[1] ~= k and n[2] ~= k and n[3] ~= k and n[4] ~= k then
          local cnt, best, bk = {}, 0, k
          for _, q in ipairs(n) do cnt[q] = (cnt[q] or 0) + 1; if cnt[q] > best then best, bk = cnt[q], q end end
          idx[y][x] = bk
        end
      end
    end
  end
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local k = idx[y][x]
      c:px(x, y, k > 0 and HEAT[k][2] or skyAt(x, y, f))
    end
  end
  -- detached licks: flames that break off and rise into the dark, shrinking and cooling (one rise per loop)
  for i = 0, 8 do
    local ph = (f / N + i / 9 + hash(i, 7, 7) * 0.05) % 1
    local top = 6 + hash(i, 8, 7) * 14
    local x0 = 8 + i * 20 + hash(i, 9, 7) * 10
    local x = floor(x0 + 6 * ph * (0.6 + 0.4 * sin(TAU * f / N - x0 / 45)) + 2 * sin(TAU * ph * 2 + i))
    local y = floor(62 - ph * (62 - top))
    local r = (2.6 + hash(i, 6, 7) * 1.6) * (1 - ph)
    if r >= 1.1 then
      local m = c:ellipse(x, y, r * 0.8, r * 1.1)
      m:add(c:ellipse(x + (i % 2 == 0 and 1 or -1) * r * 0.3, y - r * 1.1, r * 0.35, r * 0.9))
      c:fill(m, ph < 0.35 and "#e0501f" or (ph < 0.65 and "#ae2a2a" or "#6b1b2c"))
      if r >= 2.2 then c:fill(c:ellipse(x, y + 1, r * 0.35, r * 0.55), ph < 0.25 and "#e8a317" or "#f08a24") end
    end
  end
  -- embers: rise with a zig-zag, drift with the draft, wrap once or twice per loop; far ones dim and single px
  for i = 0, 39 do
    local ph = (f / N * (1 + i % 2) + hash(i, 1, 11)) % 1
    local x = floor(hash(i, 2, 11) * (W - 4) + 2 + 3 * sin(TAU * ph * 3 + i) + 5 * ph) % W
    local y = floor(H - 6 - ph * (H + 4))
    local far = i % 3 == 2
    local col = far and ((ph > 0.6) and "#6b1b2c" or "#ae2a2a")
      or ((i % 4 == 0) and "#fff1c8" or ((i % 4 == 1) and "#f5cf6a" or ((i % 4 == 2) and "#f08a24" or "#e8a317")))
    if y >= 0 then
      c:px(x, y, col)
      if not far and i % 3 == 0 then c:px(x, y + 1, "#e0501f") end
      if not far and i % 5 == 0 and x + 1 < W then c:px(x + 1, y, col) end
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
      local a = -1.95 + side * (-0.1 + k * 0.5) + 0.1 * sin(wob + k)
      local fx, fy = ha[1] + cos(a) * 7, ha[2] - 3 + sin(a) * 7
      local tx, ty = ha[1] + cos(a) * 12.5, ha[2] - 3 + sin(a) * 12.5
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
  local mouth = c:ellipse(ex, 67 + b, 14, 6.5 + mo):cut(c:rect(ex - 15, 58 + b, ex + 15, 64 + b))
  c:fill(mouth, "#35161f")
  c:fill(c:rect(ex - 7, 71 + b + mo, ex + 6, 72 + b + mo):clip(mouth), "#6b1b2c")
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

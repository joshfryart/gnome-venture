-- puzzles/elmo-fire.gif redraw: a red felt puppet, arms flung up, grinning in front of roaring flames.
-- 360x246 (source 498x339 aspect), 16 frames x 50 ms, loops forever, solid background (as the original).
-- Drawn on a 180x123 half grid (scene mode, no halo), written at 2x nearest.
-- Flames use whole-number cycles per loop so the flicker wraps seamlessly. Look-alike only: no logos/text.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H, N = 180, 123, 16
local TAU = math.pi * 2

local SKY = { "#1c0d10", "#24101a", "#2e1418", "#3a1a16", "#4a2214" } -- smoky dark, umber family
local fur = GV.ramp("#d6322b", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a" }) -- ember base, red family
local nose = GV.ramp("#f08a24")                                                   -- ember orange
local eyeR = GV.ramp("#f1ece0")                                                   -- soil cream, pale
local goldR = GV.R.gold

-- tongue sets: {x, base width, height, amp, cycles, phase}
local function tongues(seed, n, y0, hmin, hmax, wmin, wmax)
  local t, r = {}, seed
  local function rnd() r = (r * 1103515245 + 12345) % 2147483648 return r / 2147483648 end
  for i = 0, n - 1 do
    t[#t+1] = { x = (i + 0.3 + rnd() * 0.4) * W / n, w = wmin + rnd() * (wmax - wmin),
      h = hmin + rnd() * (hmax - hmin), a = 4 + rnd() * 6, k = 1 + math.floor(rnd() * 3),
      p = rnd() * TAU, s = (rnd() < 0.5 and 1 or 2), y0 = y0 }
  end
  return t
end
local BACK = tongues(7, 9, H + 2, 70, 105, 22, 34)
local MID  = tongues(31, 11, H + 2, 45, 75, 16, 24)
local CORE = tongues(99, 13, H + 2, 20, 42, 10, 16)

local function flameMask(c, set, f)
  local m = c:mask()
  for _, t in ipairs(set) do
    local ph = TAU * t.k * f / N + t.p
    local h = t.h + t.a * math.sin(ph)
    local sway = 3 * math.sin(TAU * t.s * f / N + t.p * 1.7)
    local x, y0, w = t.x, t.y0, t.w
    m:add(c:poly({ {x - w/2, y0}, {x - w*0.45 + sway*0.3, y0 - h*0.45}, {x - w*0.18 + sway*0.7, y0 - h*0.8},
      {x + sway, y0 - h}, {x + w*0.22 + sway*0.6, y0 - h*0.7}, {x + w*0.45 + sway*0.2, y0 - h*0.4}, {x + w/2, y0} }))
  end
  return m
end

local function drawFrame(f)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:bands(c:rect(0, 0, W-1, H-1), SKY)

  -- three flame layers, back to front
  c:part(flameMask(c, BACK, f), "flame", { cres = 5, gloss = false, contact = false })
  c:part(flameMask(c, MID, f), nose, { cres = 4, gloss = false, contact = false, outline = false })
  c:part(flameMask(c, CORE, f), goldR, { cres = 3, gloss = false, contact = false, outline = false })

  -- embers drifting up (period 64 px over 16 frames = 4 px/frame, wraps)
  for i = 0, 13 do
    local x = (i * 37 + 11) % W + math.floor(2 * math.sin(TAU * (f / N) + i))
    local y = H - 8 - ((f * 4 + i * 23) % 64) * 1.6
    local col = (i % 3 == 0) and "#fff1c8" or ((i % 3 == 1) and "#f5cf6a" or "#f08a24")
    c:fill(c:rect(x, math.floor(y), x + 1, math.floor(y) + 1), col)
  end

  -- puppet: tiny 1 px bob on the beat (2 cycles per loop)
  local b = (math.sin(TAU * 2 * f / N) > 0.3) and 1 or 0
  local cx = 90
  local armL = c:line({ {cx - 18, 100 + b}, {cx - 34, 82 + b}, {cx - 46, 62 + b} }, 9)
  armL:add(c:ellipse(cx - 47, 58 + b, 6, 5.5))
  local armR = c:line({ {cx + 18, 100 + b}, {cx + 34, 82 + b}, {cx + 46, 62 + b} }, 9)
  armR:add(c:ellipse(cx + 47, 58 + b, 6, 5.5))
  local body = c:rrect(cx - 26, 88 + b, cx + 26, H + 4, 10)
  local head = c:ellipse(cx, 76 + b, 23, 18)
  local p = c:build{
    { "armL", armL, fur, { stitch = { side = "lit" }, cres = 3 } },
    { "armR", armR, fur, { cres = 3 } },
    { "body", body, fur, { stitch = { side = "lit" }, cres = 6 } },
    { "head", head, fur, { cres = 6, gloss = { cx - 15, 66 + b } } },
  }
  -- neck seam where head meets body
  c:seam({ {cx - 18, 92 + b}, {cx - 8, 95 + b}, {cx + 8, 95 + b}, {cx + 18, 92 + b} })
  -- open grinning mouth
  local mouth = c:ellipse(cx, 84 + b, 11, 5):cut(c:rect(cx - 12, 77 + b, cx + 12, 81 + b))
  c:fill(mouth, "#35161f")
  c:fill(c:rect(cx - 6, 86 + b, cx + 5, 87 + b):clip(mouth), "#6b1b2c")
  -- big ping-pong eyes, pupils rolled up
  c:part(c:ellipse(cx - 7.5, 64 + b, 7, 6), eyeR, { pale = true, cres = 2, gloss = { cx - 12, 61 + b }, contact = false })
  c:part(c:ellipse(cx + 7.5, 64 + b, 7, 6), eyeR, { pale = true, cres = 2, gloss = { cx + 4, 61 + b }, contact = false })
  c:fill(c:rect(cx - 8, 61 + b, cx - 5, 64 + b), "#2a1a10")
  c:fill(c:rect(cx + 5, 61 + b, cx + 8, 64 + b), "#2a1a10")
  c:px(cx - 8, 61 + b, "#f1ece0"); c:px(cx + 5, 61 + b, "#f1ece0")
  -- orange nose
  c:part(c:ellipse(cx, 74 + b, 5, 4), nose, { cres = 2, gloss = { cx - 3, 72 + b } })
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "elmo-fire"
for f = 1, N do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(f - 1)
  if f == 1 then spr.cels[1].image = img else spr:newCel(layer, f, img) end
  spr.frames[f].duration = 0.05
  local t = GV.check(img)
  if f == 1 or f == 9 then print("frame " .. f .. ": " .. GV.report(t)) end
  assert(t.semi == 0 and t.bw <= 8) -- only the pale eye dots are #ffffff
end
pcall(function() app.fs.makeAllDirectories(O .. "puzzles-gif") end)
spr:saveAs(O .. "puzzles-gif/elmo-fire.aseprite")
spr:saveCopyAs(G .. "elmo-fire.gif")
spr:close()
print("saved")

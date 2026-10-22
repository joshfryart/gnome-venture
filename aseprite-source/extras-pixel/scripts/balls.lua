-- puzzles/balls.gif redraw: four stitched felt balls bouncing in turn in front of a low brick curb.
-- 360x270, 20 frames x 60 ms, loops forever, solid background (as the original).
-- Drawn on a 180x135 half grid (scene mode, no halo), written at 2x nearest.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local W, H, N = 180, 135, 20

-- bounce curve measured from the original: drop fraction by frames since contact (0 = on the ground, 10 = apex)
local DROP = { [0]=1.0, 0.945, 0.755, 0.6, 0.445, 0.318, 0.209, 0.118, 0.055, 0.009, 0.0 }
-- squash (x scale, y scale) near contact
local SQ = { [0]={1.36, 0.64}, {1.10, 0.91}, {1.04, 0.97} }
local FLOOR = 104 -- bottom row of a ball on the ground

-- balls: centre x, radius, apex bottom row, frame it lands on, ramp, seam style
local BALLS = {
  { x = 27.5, r = 11,   apex = 35, land = 1,  ramp = "red",            seam = "band"  },
  { x = 69,   r = 12.5, apex = 43, land = 16, ramp = "gold",           seam = "arc"   },
  { x = 110.5,r = 14,   apex = 50, land = 11, ramp = "water",          seam = "tennis"},
  { x = 152,  r = 15.5, apex = 57, land = 6,  ramp = "moss",           seam = "cross" },
}

local soil = GV.ramp("#9a6b3f")
local brick = GV.ramp("#c98a5e") -- soil family, between #9a6b3f and #c9a96e
local SKY = { "#fbe8c6", "#f9e0bb", "#f6d8b0", "#f3d0a6", "#f0c89c" }

local function drawFrame(f)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:bands(c:rect(0, 0, W-1, H-1), SKY)

  -- ground: felt soil strip with a hem seam
  c:part(c:rect(-3, 111, W+2, H+2), soil, { cres = 6, gloss = false })
  c:seam({ {0, 115}, {W-1, 115} })
  for _, p in ipairs({ {14, 122}, {47, 127}, {83, 121}, {121, 126}, {160, 122} }) do
    c:paint({ ".pp", "ppp" }, p[1], p[2], { p = soil.shade })
  end

  -- low brick curb: 15 px bricks every 30 px
  for x = 0, W, 30 do
    c:part(c:rrect(x, 102, x + 14, 107, 1), brick, { cres = 2, gloss = false })
  end

  -- balls (shadows first so a landing ball sits on its own shadow)
  local state = {}
  for i, b in ipairs(BALLS) do
    local t = (f - b.land) % N
    if t > 10 then t = N - t end
    local sq = SQ[t] or { 1, 1 }
    local rx, ry = b.r * sq[1], b.r * sq[2]
    local bottom = FLOOR - (FLOOR - b.apex) * (1 - DROP[t])
    state[i] = { t = t, rx = rx, ry = ry, cy = bottom - ry + 0.5, h = 1 - DROP[t] }
  end
  for i, b in ipairs(BALLS) do
    local s = state[i]
    if s.h < 0.5 then
      local w = b.r * 1.25 * (1 - s.h) + (s.t == 0 and 3 or 0)
      c:fill(c:ellipse(b.x, 108, w, 1.5), soil.deep)
    end
  end
  for i, b in ipairs(BALLS) do
    local s = state[i]
    local cx, cy, rx, ry = b.x, s.cy, s.rx, s.ry
    local m = c:ellipse(cx, cy, rx, ry)
    c:part(m, b.ramp, { cres = math.max(3, math.floor(ry * 0.45)), gloss = { cx - rx * 0.55, cy - ry * 0.55 } })
    local function P(u, v) return { math.floor(cx + u * rx + 0.5), math.floor(cy + v * ry + 0.5) } end
    local pts = {}
    if b.seam == "band" then            -- equator band, slightly smiling
      for k = -10, 10 do local u = k / 11 pts[#pts+1] = P(u, 0.12 + 0.18 * (1 - u*u)) end
      c:seam(pts)
      local bp = P(-0.05, -0.62) c:button(bp[1] - 2, bp[2] - 2)
    elseif b.seam == "arc" then         -- cream felt panel down one meridian, seamed on both edges
      local panel = c:ellipse(cx + rx * 0.3, cy, rx * 0.42, ry):clip(m:shrink(1))
      c:part(panel, GV.ramp("#f1ece0"), { light = m, outline = false, contour = false, contact = false,
        gloss = false, rim = false, pale = true, cres = math.max(3, math.floor(ry * 0.45)) })
      local p2 = {}
      for k = -10, 10 do local v = k / 11
        pts[#pts+1] = P(0.3 - 0.42 * math.sqrt(1 - v*v), v); p2[#p2+1] = P(0.3 + 0.42 * math.sqrt(1 - v*v), v) end
      c:seam(pts, { gap = "#b8661a" }); c:seam(p2, { gap = "#b8661a" })
    elseif b.seam == "tennis" then      -- tennis-ball S curve
      for k = 0, 20 do local a = math.pi * (k / 20) pts[#pts+1] = P(-0.85 + 1.7 * k / 20, 0.45 * math.cos(a) - 0.05) end
      c:seam(pts)
    else                                -- cross of two panel seams with a button where they meet
      for k = -10, 10 do local u = k / 11 pts[#pts+1] = P(u, 0.1 + 0.2 * (1 - u*u)) end
      c:seam(pts)
      local pv = {}
      for k = -10, 10 do local v = k / 11 pv[#pv+1] = P(0.1 + 0.25 * (1 - v*v), v) end
      c:seam(pv)
      local bp = P(0.32, 0.28) c:button(bp[1] - 2, bp[2] - 2)
    end
  end
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "balls"
for f = 1, N do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(f)
  if f == 1 then spr.cels[1].image = img else spr:newCel(layer, f, img) end
  spr.frames[f].duration = 0.06
  local t = GV.check(img)
  if f == 1 or f == 11 then print("frame " .. f .. ": " .. GV.report(t)) end
  assert(t.semi == 0 and t.bw == 0)
end
pcall(function() app.fs.makeAllDirectories(O .. "aseprite") app.fs.makeAllDirectories(O .. "png") end)
spr:saveAs(O .. "aseprite/balls.aseprite")
spr:saveCopyAs(O .. "png/balls.gif")
spr:close()
print("saved")

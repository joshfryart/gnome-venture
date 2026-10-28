-- puzzles/homer-hedge.gif redraw: a bald felt-puppet dad backs slowly into a felt hedge and vanishes.
-- 320x240 (source aspect), 22 frames, per-frame ms (hold, sink, empty), loops forever, solid background.
-- Drawn on a 160x120 half grid (scene mode, no halo), written at 2x nearest.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H = 160, 120

-- timing from the source (29 x 120 ms): ~6 frames still, 22 sinking, 1 empty
local SINK = 20
local FR = { { p = 0, ms = 720 } }
for i = 1, SINK do FR[#FR+1] = { p = i / SINK, ms = 130 } end
FR[#FR+1] = { p = 1.2, ms = 240 }

local moss = GV.R.moss
local wood = GV.R.wood
local yel = GV.ramp("#f2c32e")             -- gold family, cartoon yellow skin
local muz = GV.ramp("#c9a96e")             -- soil family stubble
local shirt = GV.ramp("#f1ece0")           -- soil cream, pale
local shorts = GV.ramp("#4a62b8")          -- water family blue
local HEDGE = { "#6aa54e", "#5f9a46", "#55903f", "#4a8a3e", "#43803a" }

local CX = 88 -- the face the hedge closes on
local JIT = { [0]=0, 1, 2, 1, 0, -1, -2, -1 }
local function win(p, y) -- visible span of the dad on row y
  local q = math.min(p, 1)
  local j = JIT[y % 8]
  local hl = 34 * (1 - q) ^ 0.9 + (q < 1 and 2 or -9)
  local hr = 28 * (1 - q) ^ 1.4 + (q < 1 and 1 or -9)
  -- the body goes faster than the head
  if y > 48 then hl, hr = hl - 4 * q, hr - 3 * q end
  return CX - hl + j, CX + hr - j
end

local function drawFrame(p)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:bands(c:rect(0, 0, W-1, H-1), HEDGE, { dir = "v" })
  -- fence rail across the top
  c:part(c:rect(-3, -3, W+2, 8), wood, { cres = 3, gloss = false })
  c:seam({ {0, 5}, {W-1, 5} })
  for x = 18, W, 40 do c:paint({ "dd", "dd" }, x, 2, { d = wood.deep }) end
  -- leaf tufts all over the hedge (fixed)
  local rng = 7
  local function R(n) rng = (rng * 1103515245 + 12345) % 2147483648 return rng % n end
  for _ = 1, 70 do
    local x, y = R(W - 4), 12 + R(H - 14)
    local t = R(3)
    if t == 0 then c:paint({ "s.s", ".s." }, x, y, { s = moss.shade })
    elseif t == 1 then c:paint({ ".g", "g." }, x, y, { g = moss.rim })
    else c:paint({ "d.d", "d.d", ".d." }, x, y, { d = moss.deep }) end
  end

  -- the dad, clipped to the closing window
  local vis = c:mask()
  for y = 0, H-1 do local a, b = win(p, y) for x = math.ceil(a), math.floor(b) do vis:set(x, y) end end
  local function P(m, ramp, o) m:clip(vis):closed(1) m:clip(vis) m = m:shrink(1):grow(1):clip(vis) if m:count() >= 6 then c:part(m, ramp, o) return true end end
  P(c:rect(62, 106, 112, H+2), shorts, { cres = 3, gloss = false })
  local body = c:ellipse(86, 88, 25, 34):clip(c:rect(0, 50, W, 109))
  P(body, shirt, { cres = 6, pale = true, gloss = { 70, 62 } })
  P(c:rrect(103, 64, 111, 104, 3), yel, { cres = 3, gloss = false })
  P(c:rrect(80, 44, 96, 54, 3), yel, { cres = 2, gloss = false })               -- neck
  P(c:rrect(77, 12, 99, 46, 9), yel, { cres = 4, gloss = { 84, 17 } })         -- head
  P(c:ellipse(86, 41, 10, 6.5), muz, { cres = 2, gloss = false })              -- stubble muzzle
  P(c:ellipse(96, 30, 2.5, 3.5), yel, { flat = true })                         -- ear
  P(c:rrect(71, 29, 80, 35, 2), yel, { cres = 2, gloss = false })              -- nose
  local function V(x, y) return vis:has(x, y) end
  if V(74, 23) and V(78, 23) then c:eye(74, 21) end
  if V(80, 23) and V(84, 23) then c:eye(80, 22) end
  local det = c:mask()
  det:add(c:line({ {86, 13}, {88, 10}, {91, 12} }, 1)):add(c:line({ {90, 14}, {93, 11}, {95, 14} }, 1))
  det:add(c:line({ {79, 44}, {85, 45}, {90, 43} }, 1))                          -- mouth
  det:clip(vis) c:fill(det, "#4a2c1a")
  local col = {}
  for k = 0, 8 do col[#col+1] = { 74 + k * 3, 54 + (k % 2) } end
  if vis:count() > 40 then
    c:seam({ {75, 55}, {86, 60}, {97, 55} })
    if V(84, 60) and V(88, 63) then c:button(84, 60) end
  end

  -- leafy lips of the hedge where it swallows him
  if p > 0 then
    for y = 12, H-1, 4 do
      local a, b = win(p, y)
      a, b = math.ceil(a), math.floor(b)
      local any = false
      for x = a, b do if vis:has(x, y) and c:get(x, y) ~= nil then any = true end end
      if any then
        local lips = { a - 2, b }
        for i, x in ipairs(lips) do
          if y < 112 then
            c:paint({ ".gr.", "gbbs", ".ss." }, x - (i == 1 and 1 or 0), y - 1, { g = moss.gloss, r = moss.rim, b = moss.base, s = moss.shade })
          end
        end
      end
    end
  end
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "homer-hedge"
for f, fr in ipairs(FR) do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(fr.p)
  if f == 1 then spr.cels[1].image = img else spr:newCel(layer, f, img) end
  spr.frames[f].duration = fr.ms / 1000
  local t = GV.check(img)
  assert(t.semi == 0 and t.bw <= 8, "frame " .. f .. ": " .. GV.report(t))
end
pcall(function() app.fs.makeAllDirectories(O .. "puzzles-gif") end)
spr:saveAs(O .. "puzzles-gif/homer-hedge.aseprite")
spr:saveCopyAs(G .. "homer-hedge.gif")
spr:close()
print("saved " .. #FR .. " frames")

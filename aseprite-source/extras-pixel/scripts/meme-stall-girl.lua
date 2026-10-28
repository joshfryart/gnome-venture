-- puzzles/stall-girl.gif redraw: a felt schoolgirl calls out at a little food stall, then turns to us, mouth open.
-- 240x238 (source 498x494 aspect), 21 frames x 100 ms, loops forever, solid background.
-- Drawn on a 120x119 half grid (scene mode, no halo), written at 2x nearest.
-- Off-palette families borrowed: teal mist from water (#3f8fb0 / gloss #c8ecdc), dress from petal (#e46a9b).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local OUT = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H, N = 120, 119, 21

local hair  = "dusk"
local dress = GV.ramp("#e46a9b")
local robe  = GV.ramp("#9a6b3f")
local cloth = GV.ramp("#f1ece0")
local curtain = GV.ramp("#8b8f96")
local glass = GV.ramp("#a9d6ea")
local MIST = { "#c8ecdc", "#a9d6c8", "#8fc4b6", "#77b0a4", "#5f9a90" }
local U, R = "#2a1a10", "#ae2a2a"

-- turn amount per frame: 0 = profile looking at the stall, 1 = facing us
local function turnOf(f)
  if f <= 5 then return 0 elseif f == 6 then return 0.35 elseif f == 7 then return 0.7 end
  return 1
end
-- mouth per frame: 2 = wide open, 1 = small open
local function mouthOf(f)
  if f <= 7 then return (f % 3 == 0) and 1 or 2 end
  return ((f // 2) % 2 == 0) and 2 or 1
end

local function stall(c, f)
  -- frame posts and top sign board
  c:part(c:rect(62, -3, 122, 9), "red", { cres = 3, gloss = false })
  c:part(c:rrect(80, 2, 100, 6, 1), cloth, { flat = true, outline = false })
  c:part(c:rect(62, 8, 68, 122), "red", { cres = 2, gloss = false })
  -- back window
  c:part(c:rect(71, 12, 88, 44), glass, { cres = 3, gloss = false })
  c:fill(c:rect(79, 12, 79, 44), "#5a86b8"); c:fill(c:rect(71, 27, 88, 27), "#5a86b8")
  -- vendor: robe, bald head, little eyes
  c:part(c:rrect(88, 38, 114, 60, 6), robe, { cres = 4 })
  c:seam({ {101, 42}, {101, 58} })
  c:part(c:ellipse(101, 31, 7.5, 8.5), "skin", { cres = 3, gloss = { 97, 26 } })
  local blink = (f == 14)
  if blink then
    c:fill(c:rect(97, 32, 99, 32), U); c:fill(c:rect(103, 32, 105, 32), U)
  else
    c:paint({ "uu", "uu" }, 97, 31, { u = U }); c:paint({ "uu", "uu" }, 103, 31, { u = U })
  end
  c:fill(c:rect(99, 37, 103, 37), "#8a4234")
  -- row of red bags on the counter
  for i, x in ipairs({ 70, 77, 84, 91, 98, 105, 112 }) do
    local y = (i % 2 == 0) and 52 or 54
    c:part(c:rrect(x, y, x + 7, 64, 2), "red", { cres = 2, gloss = { x + 2, y + 2 } })
    c:fill(c:rect(x + 2, y - 1, x + 5, y), "#8a4f2a")
  end
  -- grey curtain with a cream hanging sign (plain shapes, no lettering)
  c:part(c:rect(69, 65, 122, 122), curtain, { cres = 5, gloss = false })
  for x = 74, 118, 9 do c:seam({ { x, 67 }, { x, 118 } }) end
  c:part(c:rrect(78, 68, 104, 122, 2), cloth, { cres = 4, gloss = false, stitch = true })
  for _, y in ipairs({ 74, 84, 94, 104 }) do
    c:fill(c:rrect(83, y, 89, y + 5, 2), R)
    c:fill(c:rrect(93, y, 99, y + 5, 2), "#3e2f66")
  end
end

local function girl(c, f)
  local t, mo = turnOf(f), mouthOf(f)
  local dx = math.floor(-6 * (1 - t) + 0.5) -- face slides right in profile
  local hx = 36
  -- back hair
  local back = c:ellipse(hx - 1, 40, 19, 20):add(c:poly({ { 16, 40 }, { 56, 40 }, { 58, 100 }, { 14, 100 } }))
  c:part(back, hair, { cres = 6, gloss = false })
  -- arms and neck (skin), dress
  c:part(c:rrect(16, 76, 23, 122, 3), "skin", { cres = 2, gloss = false })
  c:part(c:rrect(49, 76, 56, 122, 3), "skin", { cres = 2, gloss = false })
  c:part(c:rect(32, 56, 40, 74), "skin", { cres = 2, gloss = false })
  local d = c:rrect(21, 70, 51, 122, 6):cut(c:ellipse(36, 70, 5, 3.5))
  c:part(d, dress, { cres = 7, stitch = { side = "lit" } })
  c:seam({ { 22, 74 }, { 30, 72 } }); c:seam({ { 42, 72 }, { 50, 74 } })
  -- face
  local fx = hx - dx
  c:part(c:ellipse(fx, 45, 14 - 1 * (1 - t), 15), "skin", { cres = 4, gloss = { fx - 8, 38 } })
  -- fringe and side locks
  local fr = c:ellipse(hx, 36, 16, 13):clip(c:rect(0, 0, W, 37))
  for i = -2, 2 do
    local x = hx + i * 5 - dx // 2
    fr:add(c:poly({ { x - 3, 36 }, { x + 3, 36 }, { x, 41 } }))
  end
  if t < 1 then -- profile: hair covers the back (left) of the head
    fr:add(c:rrect(19, 34, math.floor(fx - 6 + 6 * t), 70, 3))
  else
    fr:add(c:rect(18, 36, 22, 68)):add(c:rect(50, 36, 54, 68))
  end
    c:part(fr, hair, { cres = 5, gloss = { hx - 8, 28 } })
  -- eyes and mouth
  local mx
  if t == 0 then
    c:eye(fx + 3, 42); mx = fx + 7
    c:px(fx + 12, 46, GV.R.skin.shade)
  elseif t < 1 then
    c:eye(fx - 5, 42); c:eye(fx + 5, 42); mx = fx + 3
  else
    c:eye(fx - 9, 42); c:eye(fx + 5, 42); mx = fx
  end
  if mo == 2 then
    c:paint({ ".uuuuuu.", "uurrrruu", "urrrrrru", "urrrrrru", ".uuuuuu." }, mx - 4, 51, { u = U, r = R })
  else
    c:paint({ ".uuuu.", "uurruu", "urrrru", ".uuuu." }, mx - 3, 52, { u = U, r = R })
  end
end

local function drawFrame(f)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:bands(c:rect(0, 0, W - 1, H - 1), MIST, { dir = "h" })
  -- misty stairs: stepped diagonal rails at the left
  for k = 0, 2 do
    local x0 = -4 + k * 14
    c:fill(c:line({ { x0, 118 }, { x0 + 40, 0 } }, 2), "#4a8a7e")
    for y = 6, 116, 10 do
      local x = x0 + math.floor((118 - y) * 40 / 118)
      c:fill(c:rect(x - 6, y, x, y), "#77b0a4")
    end
  end
  stall(c, f)
  girl(c, f)
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "stall-girl"
for f = 1, N do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(f)
  if f == 1 then spr.cels[1].image = img else spr:newCel(layer, f, img) end
  spr.frames[f].duration = 0.1
  local t = GV.check(img)
  if f == 1 or f == 10 then print("frame " .. f .. ": " .. GV.report(t)) end
  assert(t.semi == 0 and t.bw == 0)
end
pcall(function() app.fs.makeAllDirectories(O .. "puzzles-gif") end)
spr:saveAs(O .. "puzzles-gif/stall-girl.aseprite")
spr:saveCopyAs(OUT .. "stall-girl.gif")
spr:close()
print("saved")

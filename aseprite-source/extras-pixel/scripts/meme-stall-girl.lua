-- puzzles/stall-girl.gif redraw (pass 3): a felt schoolgirl calls out at a little food stall, then turns to us, mouth open.
-- 300x298 (source 498x494 aspect), 23 frames x 100 ms, loops forever, solid background.
-- Drawn on a 150x149 half grid (scene mode, no halo), written at 2x nearest.
-- Off-palette families borrowed: teal mist from water (#3f8fb0 / gloss #c8ecdc), top from ember 300 + petal
-- (coral #e8735a), dark brown hair from soil (#3d2a1c / #7a4a1f / #9a6b3f).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local OUT = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H, N = 150, 149, 23

local hair  = GV.ramp("#5e3a22", { gloss = "#9a6b3f", dot = "#c9a96e", rim = "#7a4a1f", shade = "#3d2a1c",
                                   deep = "#33221a", bounce = "#4e2f1e" })
local top   = GV.ramp("#e8735a")
local robe  = GV.ramp("#9a6b3f")
local cloth = GV.ramp("#f1ece0")
local curtain = GV.ramp("#8b8f96")
local glass = GV.ramp("#a9d6ea")
local rail  = GV.ramp("#4f9a45")
local MIST = { "#5f9a90", "#77b0a4", "#8fc4b6", "#a9d6c8", "#c8ecdc" }
local U, R, RD, INK = "#2a1a10", "#dd3a2a", "#6b1b2c", "#4a2c1a"

local function lerp(a, b, t) return a + (b - a) * t end
local function rd(v) return math.floor(v + 0.5) end

-- turn amount per frame: 0 = profile looking at the stall, 1 = facing us (eased)
-- 0..0.3 profile, 0.3..0.6 three-quarter (far eye peeks past the hair edge), 0.6+ front
local TURN = { [7] = 0.12, [8] = 0.32, [9] = 0.48, [10] = 0.64, [11] = 0.85, [12] = 0.96 }
local function turnOf(f) if f <= 6 then return 0 end return TURN[f] or 1 end
-- mouth: 2 = wide open, 1 = half open
local MOUTH = { 2, 2, 1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 1, 2, 2, 1 }
-- hair lag during the turn (tips swing behind the head)
local SWAY = { [8] = 1, [9] = 2, [10] = 2, [11] = 2, [12] = 1, [13] = -1 }

local function stall(c, f)
  -- red header beam with a cream plaque
  c:part(c:rect(80, -3, 152, 13), "red", { cres = 4, gloss = { 86, 1 } })
  c:part(c:rrect(104, 1, 132, 9, 2), cloth, { flat = true })
  c:fill(c:rect(109, 4, 114, 5), INK); c:fill(c:rect(117, 4, 120, 5), INK); c:fill(c:rect(123, 4, 128, 5), INK)
  -- left post
  c:part(c:rect(80, 12, 88, 152), "red", { cres = 3, gloss = false })
  -- back window
  c:part(c:rect(93, 18, 114, 58), glass, { cres = 4, gloss = false })
  c:fill(c:rect(103, 18, 104, 58), "#6f98c4"); c:fill(c:rect(93, 37, 114, 38), "#6f98c4")
  -- vendor: robe, bald head, kind face
  c:part(c:rrect(112, 50, 148, 80, 7), robe, { cres = 5 })
  c:seam({ { 130, 54 }, { 130, 78 } })
  c:part(c:ellipse(130, 39, 9.5, 10.5), "skin", { cres = 4, gloss = { 124, 32 } })
    if f == 18 then
    c:fill(c:rect(124, 40, 126, 40), U); c:fill(c:rect(133, 40, 135, 40), U)
  else
    c:eye(124, 38, true); c:eye(133, 38, true)
  end
  c:fill(c:rect(123, 36, 126, 36), "#c9c5bc"); c:fill(c:rect(133, 36, 136, 36), "#c9c5bc") -- white brows
  c:paint({ "u...u", ".uuu." }, 128, 45, { u = "#8a4234" })
  -- a row of red sweet bags on the counter
  for i, x in ipairs({ 92, 103, 114, 125, 136 }) do
    local y = (i % 2 == 0) and 64 or 67
    c:part(c:rrect(x, y, x + 10, 84, 3), "red", { cres = 3, gloss = { x + 2, y + 3 } })
    c:fill(c:rect(x + 3, y - 2, x + 7, y - 1), "#8a4f2a")
    c:paint({ "..c..", ".c.c.", "..c.." }, x + 3, y + 8, { c = "#ffc27a" })
  end
  -- grey curtain with a cream hanging sign: simple brush strokes, no lettering
  c:part(c:rect(88, 86, 152, 152), curtain, { cres = 6, gloss = false })
  for x = 92, 148, 11 do c:seam({ { x, 89 }, { x, 146 } }) end
  c:part(c:rrect(100, 89, 128, 152, 2), cloth, { cres = 4, gloss = false, stitch = true })
  -- brush-stroke marks: short dashes of varied length, read as writing from afar
  local rows = { { 106, 121, 96, INK }, { 109, 118, 99, INK }, { 106, 122, 106, INK }, { 108, 120, 109, INK },
                 { 106, 116, 116, INK }, { 110, 121, 119, INK }, { 107, 121, 128, R }, { 109, 119, 131, R },
                 { 107, 121, 138, R } }
  for _, r in ipairs(rows) do
    c:fill(c:rect(r[1], r[3], r[2], r[3] + 1), r[4])
  end
end

local function girl(c, f)
  local t, mo, sw = turnOf(f), MOUTH[f], SWAY[f] or 0
  local by = (mo == 2) and 0 or 1 -- tiny bob with each call
  local hx, hy = 50, 50 + by
  local fx = rd(lerp(hx + 8, hx, t))
  -- back hair: long, straight, pointed tips (sits further left in profile)
  local bx = hx - rd(lerp(6, 0, t))
  local back = c:ellipse(bx, hy - 5, 22, 24)
  local pts = { { bx - 22, hy - 5 }, { bx + 23, hy - 5 } }
  for i = 0, 6 do
    pts[#pts + 1] = { rd(bx + 23 - i * 7.5 + sw), 118 + by - ((i % 2 == 0) and 0 or 5) }
  end
  back:add(c:poly(pts))
  c:part(back, hair, { cres = 7, gloss = false })
  -- arms, neck, top
  local nar = rd(lerp(4, 0, t)) -- body a touch narrower in profile
  c:part(c:rrect(24 + nar, 88, 33 + nar, 152, 4), "skin", { cres = 3, gloss = false })
  c:part(c:rrect(67 - nar, 88, 76 - nar, 152, 4), "skin", { cres = 3, gloss = false })
  c:part(c:rect(hx - 4, 64, hx + 3, 86), "skin", { cres = 3, gloss = false })
  -- top stops at the arms' inner edge and the armholes reach past it, so no spike of felt is left at a shoulder
  local d = c:rrect(32 + nar, 83, 66 - nar, 152, 6):cut(c:ellipse(hx, 82, 7, 5))
  d:cut(c:ellipse(26 + nar, 87, 6, 6)):cut(c:ellipse(72 - nar, 87, 6, 6)) -- sleeveless armholes
  c:part(d, top, { cres = 8, stitch = { side = "lit" }, gloss = { 39, 96 } })
  c:seam({ { hx - 9, 86 }, { hx - 4, 89 }, { hx + 4, 89 }, { hx + 9, 86 } })
  -- face (with a small nose bump in profile)
  local frx = rd(lerp(15, 18, t))
  local face = c:ellipse(fx, hy, frx, 19)
  if t < 0.3 then face:add(c:rect(fx + frx, hy + 3, fx + frx + 1, hy + 5)) end
  c:part(face, "skin", { cres = 3, gloss = { fx - 10, hy - 9 } })
  -- fringe + side hair
  local frc = hx + rd(lerp(3, 0, t))
  local fr = c:ellipse(frc, hy - 9, 21, 17):clip(c:rect(0, 0, W, hy - 8))
  for i = -3, 3 do
    local x = hx + i * 6 + rd(lerp(4, 0, t))
    local dep = (i % 2 == 0) and 6 or 4
    fr:add(c:poly({ { x - 4, hy - 8 }, { x + 4, hy - 8 }, { x, hy - 8 + dep } }))
  end
  if t < 0.3 then fr:clip(c:rect(0, 0, fx + frx - 3, H)) -- profile: the brow line follows the face
  elseif t < 0.6 then fr:clip(c:rect(0, 0, fx + frx - 1, H)) end
  local edge = rd(lerp(hx - 1, hx - 16, t)) -- back of the head covers the face in profile
  fr:add(c:poly({ { bx - 22, hy - 10 }, { edge, hy - 10 }, { edge, hy + 30 }, { edge - 3, hy + 48 }, { bx - 22, hy + 50 } }))
  if t >= 0.6 then
    local rx0 = rd(lerp(hx + 22, hx + 16, (t - 0.6) / 0.4))
    fr:add(c:poly({ { rx0, hy - 10 }, { hx + 23, hy - 10 }, { hx + 23, hy + 50 }, { rx0 + 3, hy + 48 }, { rx0, hy + 30 } }))
  end
  c:part(fr, hair, { cres = 5, gloss = { hx - 10, hy - 19 } })
  -- eyes with a bold upper lid
  local function eye(x, y)
    c:eye(x, y)
    c:fill(c:rect(x - 1, y - 1, x + 5, y - 1), U); c:px(x - 1, y, U); c:px(x + 5, y, U)
  end
  local ey = hy + 1
  eye(rd(lerp(hx + 13, hx + 6, t)), ey)
  if t >= 0.6 then eye(rd(lerp(hx - 1, hx - 10, t)), ey)
  elseif t >= 0.3 then -- three-quarter: the far eye is a narrow one just past the hair edge
    local fxr = rd(lerp(hx - 1, hx - 10, t))
    if fxr > edge + 1 then c:eye(fxr, ey + 1, true); c:fill(c:rect(fxr - 1, ey, fxr + 3, ey), U) end
  end
  -- mouth: big open cheerful mouth
  local my = hy + 9
  local L = { u = U, r = RD, t = R }
  if t < 0.3 then
    local mx = fx + frx - 7
    if mo == 2 then
      c:paint({ "uuuuu.", "urrrru", "urrrtu", ".urttu", "..uuu." }, mx - 1, my, L)
    else
      c:paint({ "uuuu.", "urrtu", ".uuu." }, mx, my + 1, L)
    end
  elseif t < 0.6 then -- three-quarter: medium mouth, sitting toward the near cheek
    local mx = rd(lerp(hx + 8, hx, t)) + 2
    if mo == 2 then
      c:paint({ ".uuuuuuu.", "urrrrrrru", "urrrrtrru", ".urtttru.", "..uuuuu.." }, mx - 4, my, L)
    else
      c:paint({ ".uuuuu.", "urrttru", ".uuuuu." }, mx - 3, my + 1, L)
    end
  else
    local mx = rd(lerp(hx + 8, hx, t))
    if mo == 2 then
      c:paint({ ".uuuuuuuuu.", "urrrrrrrrru", "urrrrrrrrru", ".urrrttrru.", "..urttttu..", "...uuuuu..." }, mx - 5, my, L)
    else
      c:paint({ ".uuuuuuu.", "urrrrrrru", "urrtttrru", ".uuuuuuu." }, mx - 4, my + 1, L)
    end
  end
end

local function drawFrame(f)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:bands(c:rect(0, 0, W - 1, H - 1), MIST, { dir = "h" })
  -- misty stairs climbing to the upper left, with a green hand rail
  for y = 4, 148, 9 do
    local x = math.floor((148 - y) * 0.42) - 2
    c:fill(c:rect(0, y, x, y + 1), "#77b0a4")
    c:fill(c:rect(x + 1, y, x + 2, y + 8), "#4a8a7e")
  end
  c:part(c:line({ { 2, 148 }, { 70, -2 } }, 3), rail, { flat = true })
  for y = 20, 140, 30 do
    local x = 2 + math.floor((148 - y) * 68 / 150)
    c:part(c:rect(x - 1, y, x, y + 26), rail, { flat = true })
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
  if f == 1 then spr.cels[1].image = img; img:saveAs(OUT .. "stall-girl-still.png")
  else spr:newCel(layer, f, img) end
  spr.frames[f].duration = 0.1
  local t = GV.check(img)
  if f == 1 or f == 9 or f == 15 then print("frame " .. f .. ": " .. GV.report(t)) end
  assert(t.semi == 0 and t.bw == 0)
end
pcall(function() app.fs.makeAllDirectories(O .. "puzzles-gif") end)
spr:saveAs(O .. "puzzles-gif/stall-girl.aseprite")
spr:saveCopyAs(OUT .. "stall-girl.gif")
spr:close()
print("saved")

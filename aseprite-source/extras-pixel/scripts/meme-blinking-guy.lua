-- puzzles/blinking-guy.gif redraw (pass 2): a felt-puppet close-up doing the slow disbelieving blink,
-- eyes shifting, brows climbing, lopsided forced smile, in front of dark felt bokeh. Generic puppet, not a likeness.
-- Framed like the source: face fills the frame and bleeds off the left and bottom, hair off the top,
-- jaw, ear and bokeh on the right. 544x640, 22 key frames with per-frame ms, loops forever.
-- Drawn on a 272x320 half grid (scene mode, no halo), written at 2x nearest.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H = 272, 320
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local function r(v) return floor(v + 0.5) end

local hair  = GV.ramp("#e0b25a")            -- gold family, lighter base for blond felt
local brow  = GV.ramp("#b07a45")            -- wood base, darker blond brows
local white = GV.ramp("#f1ece0")            -- soil cream (pale)
local iris  = GV.R.water
local SK = GV.R.skin                        -- skin: base e9b98a, bounce d9885a, shade c47a52, deep 8a4234
local LASH, UMB = "#2a1a10", "#4a2c1a"
local BG = { "#1e2a50", "#22305a", "#263562", "#2a3c6c", "#22305a" }

-- key poses (source: 97 frames x 30 ms). lid 0 open .. 1 shut, gx/gy gaze, br brow lift (-2..7),
-- sk extra lift on his left brow (skeptical), ox/oy head shift, sm forced smile 0..1, ms duration
local K = {
  { lid=0.00, gx= 0.1, gy=0,   br= 0,   sk=0, ox=0, oy=0,  sm=0.15, ms=420 },
  { lid=0.25, gx= 0.1, gy=0.3, br=-0.5, sk=0, ox=0, oy=0,  sm=0.15, ms=110 },
  { lid=0.55, gx= 0.0, gy=0.6, br=-1,   sk=0, ox=0, oy=1,  sm=0.10, ms=120 },
  { lid=0.82, gx= 0.0, gy=0.8, br=-1.5, sk=0, ox=1, oy=1,  sm=0.10, ms=140 },
  { lid=1.00, gx= 0.0, gy=1,   br=-2,   sk=0, ox=1, oy=2,  sm=0.10, ms=420 },
  { lid=0.75, gx=-0.3, gy=0.5, br=-0.5, sk=0, ox=1, oy=2,  sm=0.15, ms=90  },
  { lid=0.40, gx=-0.7, gy=0.2, br=1.5,  sk=0, ox=2, oy=1,  sm=0.20, ms=90  },
  { lid=0.12, gx=-1.0, gy=0,   br=3,    sk=1, ox=2, oy=0,  sm=0.25, ms=230 },
  { lid=0.08, gx=-1.0, gy=0,   br=3.5,  sk=1, ox=3, oy=0,  sm=0.25, ms=260 },
  { lid=0.50, gx=-0.6, gy=0.5, br=2,    sk=1, ox=3, oy=0,  sm=0.25, ms=80  },
  { lid=0.90, gx=-0.2, gy=0.8, br=0.5,  sk=0, ox=3, oy=1,  sm=0.30, ms=90  },
  { lid=0.45, gx= 0.3, gy=0.3, br=2.5,  sk=1, ox=3, oy=0,  sm=0.35, ms=80  },
  { lid=0.10, gx= 0.8, gy=0,   br=4.5,  sk=2, ox=2, oy=0,  sm=0.50, ms=200 },
  { lid=0.00, gx= 0.6, gy=0,   br=5.5,  sk=2, ox=2, oy=-1, sm=0.70, ms=160 },
  { lid=0.00, gx= 0.2, gy=0,   br=6.5,  sk=3, ox=1, oy=-1, sm=0.90, ms=200 },
  { lid=0.00, gx= 0.0, gy=0,   br=7,    sk=3, ox=1, oy=-2, sm=1.00, ms=520 },
  { lid=0.00, gx=-0.2, gy=0,   br=7,    sk=3, ox=1, oy=-2, sm=1.00, ms=300 },
  { lid=0.15, gx= 0.0, gy=0,   br=6,    sk=2, ox=1, oy=-1, sm=0.90, ms=130 },
  { lid=0.00, gx= 0.0, gy=0,   br=4,    sk=1, ox=0, oy=-1, sm=0.65, ms=160 },
  { lid=0.00, gx= 0.1, gy=0,   br=2,    sk=0, ox=0, oy=0,  sm=0.40, ms=160 },
  { lid=0.00, gx= 0.1, gy=0,   br=0.5,  sk=0, ox=0, oy=0,  sm=0.20, ms=200 },
}

-- column-span mask: f(x) -> y0, y1 (inclusive, floats)
local function spans(c, x0, x1, f)
  local m = c:mask()
  for x = floor(x0), math.ceil(x1) do
    local a, b = f(x)
    if a then for y = math.ceil(a - 0.5), floor(b + 0.5) do m:set(x, y) end end
  end
  return m
end

local function drawFrame(p)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, cx = 100, cy = 140 }
  c:bands(c:rect(0, 0, W-1, H-1), BG, { dir = "radial", cx = 240, cy = 150, r = 240 })
  -- felt bokeh discs (fixed), mostly in the strip right of the jaw
  local bok = { {238, 30, 12, "#8fcbd8"}, {262, 84, 9, "#c8ecdc"}, {232, 120, 10, "#5a86b8"},
    {258, 160, 14, "#3f8fb0"}, {236, 206, 11, "#8fcbd8"}, {262, 246, 13, "#3f8fb0"},
    {226, 280, 10, "#f5cf6a"}, {256, 306, 12, "#5a86b8"}, {266, 8, 8, "#f5cf6a"}, {214, 312, 8, "#3f8fb0"} }
  for _, b in ipairs(bok) do
    c:part(c:ellipse(b[1], b[2], b[3], b[3]), GV.ramp(b[4]), { cres = 4, outline = false, gloss = false })
  end

  local X, Y = p.ox, p.oy
  local function P(pts) local o = {} for i, q in ipairs(pts) do o[i] = { q[1] + X, q[2] + Y } end return o end

  -- ear (peeks out behind the cheek, under the sideburn)
  c:part(c:ellipse(204 + X, 150 + Y, 11, 22), "skin", { cres = 5, gloss = false })
  c:fill(c:line(P{ {206, 136}, {210, 146}, {209, 160}, {204, 166} }, 2), SK.shade)

  -- head: bleeds off left and bottom; temple, cheekbone, jaw angle and chin on the right
  local face = c:poly(P{ {-16, -16}, {186, -16}, {193, 40}, {198, 88}, {200, 126}, {199, 160},
    {195, 198}, {189, 236}, {181, 266}, {170, 292}, {158, 316}, {150, 340}, {-16, 340} })
  c:part(face, "skin", { cres = 13, deep = 5, gloss = { 30 + X, 166 + Y } })
  -- chin pad and jaw shade line: gives the lower face a structure
  c:fill(c:line(P{ {98, 308}, {116, 304}, {136, 306} }, 2), SK.bounce)
  c:fill(c:line(P{ {176, 196}, {172, 228}, {162, 262} }, 2), SK.bounce)

  -- hair: felt mass off the top, swept fringe of tufts pointing down-left, sideburn over the ear
  local hm = c:poly(P{ {-16, -16}, {232, -16}, {226, 30}, {220, 70}, {216, 112}, {210, 132}, {204, 120},
    {200, 96}, {196, 78}, {190, 70}, {180, 74}, {172, 66}, {160, 60}, {150, 64}, {140, 68}, {128, 60},
    {116, 56}, {106, 62}, {94, 66}, {84, 58}, {70, 52}, {58, 58}, {46, 64}, {36, 56}, {22, 50}, {8, 56}, {-4, 62}, {-16, 62} })
  c:part(hm, hair, { cres = 14, deep = 6, gloss = { 60 + X, 14 + Y } })
  -- strands: shade lines from the tuft roots up and to the right
  local strands = { {4, 54, 40, 18}, {40, 54, 84, 16}, {88, 58, 130, 22}, {136, 60, 176, 28},
    {176, 66, 204, 34}, {206, 100, 214, 64} }
  local inner = hm:shrink(2)
  for _, s in ipairs(strands) do
    local mx, my = (s[1] + s[3]) / 2 + 4, (s[2] + s[4]) / 2 + 2
    c:fill(c:line(P{ {s[1], s[2]}, {mx, my}, {s[3], s[4]} }, 2):clip(inner), hair.shade)
  end
  c:seam(P{ {6, 30}, {50, 32}, {100, 36}, {150, 42}, {196, 52} })

  -- eyes: almond whites, iris + pupil + glint, lid that follows the almond down to a closed curve
  local EYES = { { ex = 60, ey = 140, rx = 24, ry = 13, side = -1 }, { ex = 152, ey = 133, rx = 21, ry = 12, side = 1 } }
  for _, e in ipairs(EYES) do
    local ex, ey, rx, ry = e.ex + X, e.ey + Y, e.rx, e.ry
    local function top(x) local u = (x - ex) / rx if math.abs(u) > 1 then return nil end
      return ey - ry * (1 - u * u) ^ 0.55 - 1.5 * u * e.side end
    local function bot(x) local u = (x - ex) / rx if math.abs(u) > 1 then return nil end
      return ey + ry * 0.7 * (1 - u * u) ^ 0.75 - 1.5 * u * e.side end
    local wm = spans(c, ex - rx, ex + rx, function(x) local a = top(x) if a then return a, bot(x) end end)
    -- socket: upper lid crease rides with the brow; lower lid line pushes up with the smile
    local crease = {}
    for k = -6, 6 do local u = k / 7 local x = ex + u * (rx + 1)
      crease[#crease + 1] = { r(x), r(top(x) - 6 - max(0, p.br) * 0.35 - (1 - p.lid) * 1) } end
    c:fill(c:line(crease, 2), SK.shade)
    c:part(wm, white, { flat = true, rim = false, outline = false, contour = false, contact = false })
    local ix, iy = ex + p.gx * (rx - 11), ey + 1 + p.gy * 2
    c:fill(c:ellipse(ix, iy, 10, 10):clip(wm), iris.base)
    c:fill(c:ellipse(ix, iy, 10, 10):cut(c:ellipse(ix - 2, iy - 2, 10, 10)):clip(wm), iris.deep)
    c:fill(c:ellipse(ix - 2, iy - 3, 6, 3):clip(c:ellipse(ix, iy, 8, 8)):clip(wm), iris.rim)
    c:fill(c:ellipse(ix, iy, 4.5, 4.5):clip(wm), LASH)
    c:fill(c:rect(ix - 5, iy - 5, ix - 3, iy - 3):clip(wm), "#fff3c8")
    -- upper lid
    local edge, cl = {}, p.lid >= 0.99
    local lm = c:mask()
    for x = floor(ex - rx), math.ceil(ex + rx) do
      local a = top(x)
      if a then
        local b = bot(x) + 1
        local yy = a + (b - a) * p.lid
        for y = math.ceil(a - 0.5) - 1, floor(yy + 0.5) do lm:set(x, y) end
        if (x - ex) % 3 == 0 or x == floor(ex - rx) then edge[#edge + 1] = { x, r(yy) } end
      end
    end
    edge[#edge + 1] = { r(ex + rx), r(top(ex + rx) or ey) }
    if p.lid > 0 then c:fill(lm, p.lid > 0.6 and SK.rim or SK.base) end
    -- lower lid line under the white
    local lo = {}
    for k = -6, 6 do local u = k / 7 local x = ex + u * rx
      lo[#lo + 1] = { r(x), r(bot(x) + 2 - p.sm * 1.5) } end
    c:fill(c:line(lo, 2), SK.bounce)
    c:fill(c:line(edge, 3), LASH)
    if cl then -- closed: little lash flicks at the outer end
      local ox = ex + e.side * (rx - 3)
      local by = bot(ox) + 1
      c:fill(c:line({ { r(ox), r(by) }, { r(ox + e.side * 4), r(by + 3) } }, 2), LASH)
      local ox2 = ex + e.side * (rx - 10)
      c:fill(c:line({ { r(ox2), r(bot(ox2) + 2) }, { r(ox2 + e.side * 2), r(bot(ox2) + 5) } }, 2), LASH)
    end
    -- brow: thick inner end, tapering outer end; inner end climbs more (disbelief), his left brow more again
    local lift = p.br + (e.side > 0 and p.sk or 0)
    local inX, outX = ex - e.side * 28, ex + e.side * 28
    local by = ey - 22
    local b1 = { r(inX), r(by + 4 - lift * 1.6) }
    local b2 = { r(ex - e.side * 4), r(by - 3 - lift * 1.3) }
    local b3 = { r(outX), r(by + 1 - lift * 0.8) }
    local bm = c:line({ b1, b2 }, 9):add(c:line({ b2, { r((b2[1] + b3[1]) / 2), r((b2[2] + b3[2]) / 2 - 1) } }, 8))
    bm:add(c:line({ { r((b2[1] + b3[1]) / 2), r((b2[2] + b3[2]) / 2 - 1) }, b3 }, 5))
    c:part(bm, brow, { flat = true, outline = false, contact = false })
    -- worry crease between the brows when they climb
    if e.side < 0 and p.br >= 4 then
      c:fill(c:line(P{ {104, 104 - floor(p.br)}, {106, 112 - floor(p.br)} }, 2), SK.shade)
    end
  end

  -- nose: bridge shade on the dark side, wings, round felt tip, nostrils
  c:fill(c:line(P{ {120, 132}, {126, 150}, {132, 172}, {134, 184} }, 3), SK.shade)
  c:fill(c:line(P{ {104, 136}, {100, 160}, {98, 180} }, 2), SK.bounce)
  local wings = c:ellipse(100 + X, 201 + Y, 8, 6):add(c:ellipse(136 + X, 199 + Y, 9, 7))
  c:part(wings, "skin", { cres = 5, gloss = false, outline = false, contour = SK.shade, contact = false })
  c:part(c:ellipse(118 + X, 192 + Y, 18, 13), "skin", { cres = 8, deep = 3, outline = false, contour = SK.shade, gloss = { 108 + X, 184 + Y } })
  c:fill(c:ellipse(104 + X, 206 + Y, 4, 1.5), SK.deep); c:fill(c:ellipse(132 + X, 205 + Y, 5, 1.5), SK.deep)
  c:fill(c:line(P{ {98, 210}, {116, 212}, {140, 209} }, 2), SK.shade)
  c:fill(c:line(P{ {112, 220}, {111, 232} }, 2), SK.bounce)      -- philtrum

  -- lopsided forced smile: lips pressed, his left corner (viewer right) hauled up, cheek fold deepens
  local s = p.sm
  local mid = {}
  local N = 12
  local function mouthY(u)
    local liftR = (u > 0) and (u ^ 2) * (6 + 16 * s) or 0
    local liftL = (u < 0) and (u * u) * (-2 + 4 * s) or 0
    return 250 - liftR - liftL + 2.5 * s * (1 - u * u) - 3 * u
  end
  local function mouthX(u) return 116 + u * (44 + (u > 0 and 4 * s or 2 * s)) end
  for k = -N, N do local u = k / N mid[#mid + 1] = { r(mouthX(u) + X), r(mouthY(u) + Y) } end
  -- lips: thin upper lip, fuller lower lip, both narrower than the mouth line
  local up = spans(c, mouthX(-0.82) + X, mouthX(0.8) + X, function(x)
    local u = (x - X - 116) / 46 if math.abs(u) > 1 then return nil end
    local yy = mouthY(math.max(-1, math.min(1, u))) + Y
    local bow = (math.abs(u + 0.02) < 0.12) and 1 or 0
    return yy - 4.5 * (1 - u * u) ^ 0.6 - 1 + bow, yy end)
  c:fill(up, SK.shade)
  local lo = spans(c, mouthX(-0.75) + X, mouthX(0.7) + X, function(x)
    local u = (x - X - 116) / 46 if math.abs(u) > 1 then return nil end
    local yy = mouthY(math.max(-1, math.min(1, u))) + Y
    return yy, yy + 2 + 8 * (1 - u * u) ^ 0.7 - 2 * s end)
  c:part(lo, GV.ramp("#d9885a"), { cres = 4, deep = 0, outline = false, contour = false, contact = false, gloss = false })
  c:fill(c:line({ { r(mouthX(-0.25) + X), r(mouthY(-0.25) + Y + 4) }, { r(mouthX(0.05) + X), r(mouthY(0.05) + Y + 4) } }, 2), SK.gloss)
  c:fill(c:line(mid, 3), UMB)
  -- corners: a hard tuck on his left, a soft dot on his right
  local R1 = mid[#mid]
  c:fill(c:line({ { R1[1] - 1, R1[2] + 1 }, { R1[1] + 3, R1[2] - 2 } }, 2), UMB)
  c:fill(c:line({ { R1[1] + 3, R1[2] - 6 }, { R1[1] + 6, R1[2] - 1 }, { R1[1] + 5, R1[2] + 5 } }, 2), SK.shade)
  local L1 = mid[1]
  c:fill(c:line({ { L1[1] - 2, L1[2] }, { L1[1], L1[2] } }, 2), SK.shade)
  -- cheek folds (nasolabial): the right one swings out and up with the smile
  local fo = {}
  for k = 0, 6 do local t = k / 6
    fo[#fo + 1] = { r(150 + X + t * (16 + 8 * s) + math.sin(t * 3.1) * (4 + 6 * s)), r(204 + Y + t * (40 - 10 * s)) } end
  c:fill(c:line(fo, 2), SK.shade)
  if s > 0.35 then
    c:fill(c:line(P{ {84, 214}, {76, 232}, {74, 246 - floor(s * 6)} }, 2), SK.bounce)
  end
  -- under-lip shadow
  c:fill(c:line(P{ {104, 276 - floor(2 * s)}, {118, 278 - floor(2 * s)}, {134, 275 - floor(3 * s)} }, 2), SK.bounce)
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "blinking-guy"
for f, p in ipairs(K) do
  if f > 1 then spr:newEmptyFrame(f) end
  local img = drawFrame(p)
  if f == 1 then spr.cels[1].image = img else spr:newCel(layer, f, img) end
  spr.frames[f].duration = p.ms / 1000
  local t = GV.check(img)
  if f == 1 or f == 5 then print("frame " .. f .. ": " .. GV.report(t)) end
  assert(t.semi == 0 and t.bw == 0)
  if f == 1 then img:saveAs(G .. "blinking-guy-still.png") end
end
pcall(function() app.fs.makeAllDirectories(O .. "puzzles-gif") end)
spr:saveAs(O .. "puzzles-gif/blinking-guy.aseprite")
spr:saveCopyAs(G .. "blinking-guy.gif")
spr:close()
print("saved")

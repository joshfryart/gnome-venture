-- puzzles/blinking-guy.gif redraw: a felt-puppet face doing the slow disbelieving blink,
-- eyes shifting, forced half-smile, in front of dark felt bokeh. Generic puppet, not a likeness.
-- 544x640 (source aspect), 18 key frames with per-frame ms, loops forever, solid background.
-- Drawn on a 272x320 half grid (scene mode, no halo), written at 2x nearest.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/puzzles/"
local W, H = 272, 320

local hair  = GV.ramp("#e0b25a")            -- gold family, lighter base for blond felt
local brow  = GV.ramp("#c08a44")            -- wood/gold, darker blond
local white = GV.ramp("#f1ece0")            -- soil cream (pale)
local iris  = "water"
local shirt = GV.ramp("#5b6470")            -- stone
local lip   = GV.ramp("#d9885a")            -- skin bounce tone as base
local BG = { "#1e2a50", "#22305a", "#263562", "#2a3c6c", "#22305a" }

-- key poses measured from the 97-frame source (30 ms each):
-- lid 0 open .. 1 shut, gx/gy gaze, br brow lift, ox/oy head shift, sm smile, ms duration
local K = {
  { lid=0.00, gx= 0.0, gy=0, br=0, ox=0, oy=0, sm=0.3, ms=240 },
  { lid=0.30, gx= 0.0, gy=1, br=0, ox=0, oy=0, sm=0.3, ms=90  },
  { lid=0.60, gx= 0.0, gy=1, br=0, ox=0, oy=1, sm=0.3, ms=120 },
  { lid=0.85, gx= 0.0, gy=1, br=0, ox=0, oy=1, sm=0.3, ms=150 },
  { lid=1.00, gx= 0.0, gy=1, br=0, ox=1, oy=2, sm=0.3, ms=300 },
  { lid=0.80, gx=-0.2, gy=0, br=1, ox=1, oy=2, sm=0.4, ms=90  },
  { lid=0.45, gx=-0.4, gy=0, br=2, ox=2, oy=1, sm=0.4, ms=90  },
  { lid=0.10, gx=-0.6, gy=0, br=3, ox=2, oy=0, sm=0.5, ms=180 },
  { lid=0.05, gx=-0.9, gy=0, br=3, ox=3, oy=0, sm=0.5, ms=210 },
  { lid=0.50, gx=-0.6, gy=1, br=2, ox=3, oy=0, sm=0.5, ms=90  },
  { lid=0.80, gx=-0.3, gy=1, br=1, ox=3, oy=1, sm=0.5, ms=90  },
  { lid=0.40, gx= 0.3, gy=0, br=2, ox=3, oy=0, sm=0.6, ms=90  },
  { lid=0.05, gx= 0.8, gy=0, br=4, ox=2, oy=0, sm=0.7, ms=210 },
  { lid=0.00, gx= 0.5, gy=0, br=5, ox=2, oy=-1,sm=0.8, ms=150 },
  { lid=0.00, gx= 0.0, gy=0, br=6, ox=1, oy=-1,sm=0.9, ms=300 },
  { lid=0.00, gx=-0.2, gy=0, br=6, ox=1, oy=-1,sm=0.9, ms=240 },
  { lid=0.00, gx= 0.0, gy=0, br=5, ox=0, oy=0, sm=0.8, ms=150 },
  { lid=0.00, gx= 0.0, gy=0, br=3, ox=0, oy=0, sm=0.5, ms=120 },
}

local function drawFrame(p)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, cx = 110, cy = 150 }
  c:bands(c:rect(0, 0, W-1, H-1), BG, { dir = "radial", cx = 236, cy = 120, r = 260 })
  -- felt bokeh discs (fixed)
  local bok = { {236, 40, 13, "#8fcbd8"}, {258, 96, 9, "#c8ecdc"}, {226, 128, 11, "#5a86b8"},
    {262, 168, 14, "#3f8fb0"}, {240, 214, 10, "#8fcbd8"}, {258, 262, 15, "#3f8fb0"},
    {222, 300, 9, "#f5cf6a"}, {250, 8, 8, "#f5cf6a"}, {12, 10, 9, "#5a86b8"} }
  for _, b in ipairs(bok) do
    c:part(c:ellipse(b[1], b[2], b[3], b[3]), GV.ramp(b[4]), { cres = 4, outline = false, gloss = false })
  end

  local X, Y = p.ox, p.oy
  -- shirt, neck, ear, head
  c:part(c:rrect(10, 292, 214, 340, 18), shirt, { cres = 8, gloss = false })
  c:seam({ {14, 302}, {210, 302} })
  c:button(100, 306)
  c:part(c:rect(60 + X, 250, 170 + X, 300), "skin", { cres = 10, gloss = false })
  c:part(c:ellipse(214 + X, 190 + Y, 14, 26), "skin", { cres = 6, gloss = false })
  local head = c:ellipse(112 + X, 175 + Y, 104, 120)
  head:cut(c:rect(0, 286, W, H))
  c:part(head, "skin", { cres = 22, deep = 8, gloss = { 40 + X, 120 + Y } })

  -- hair: felt cap with a swept fringe, seamed hairline
  local hm = c:ellipse(116 + X, 98 + Y, 116, 66):cut(c:rect(0, 112 + Y, W, H))
  hm:add(c:poly({ {6 + X, 92 + Y}, {40 + X, 128 + Y}, {84 + X, 108 + Y}, {130 + X, 122 + Y},
    {176 + X, 104 + Y}, {222 + X, 128 + Y}, {232 + X, 92 + Y} }))
  hm:cut(c:rect(0, 0, W, 2))
  c:part(hm, hair, { cres = 14, gloss = { 70 + X, 60 + Y }, stitch = { side = "lit" } })
  c:seam({ {14 + X, 100 + Y}, {40 + X, 122 + Y}, {84 + X, 103 + Y}, {130 + X, 116 + Y}, {176 + X, 99 + Y}, {218 + X, 120 + Y} })

  -- eyes
  local EYES = { { 70 + X, 170 + Y }, { 154 + X, 168 + Y } }
  for i, e in ipairs(EYES) do
    local ex, ey, rx, ry = e[1], e[2], 22, 13
    local wm = c:ellipse(ex, ey, rx, ry)
    c:part(wm, white, { cres = 6, gloss = false, rim = false })
    local ix, iy = ex + p.gx * 9, ey + p.gy * 2
    c:part(c:ellipse(ix, iy, 10, 10):clip(wm), iris, { cres = 4, gloss = false, outline = false, contact = false })
    c:fill(c:ellipse(ix + 0.5, iy + 0.5, 4.5, 4.5):clip(wm), "#2a1a10")
    c:fill(c:rect(ix - 4, iy - 5, ix - 2, iy - 3):clip(wm), "#f1ece0")
    -- upper lid comes down over the eye
    local cut = math.floor(ey - ry - 2 + p.lid * (2 * ry + 4))
    if p.lid > 0 then
      local lm = wm:grow(1):clip(c:rect(0, 0, W, cut))
      c:part(lm, "skin", { flat = true, rim = false, outline = false, contour = false, contact = false })
    end
    -- lash line on the lid edge (curved when shut)
    local pts = {}
    for k = -6, 6 do
      local u = k / 6
      local yy = (p.lid >= 0.99) and (ey + 3 * (1 - u * u)) or math.max(cut, ey - ry * math.sqrt(1 - u * u))
      pts[#pts + 1] = { math.floor(ex + u * (rx - 1) + 0.5), math.floor(yy + 0.5) }
    end
    c:fill(c:line(pts, 3), "#4a2c1a")
    -- brow: inner end lifts more when he raises them
    local by = ey - 30 - p.br * 2
    local inner = (i == 1) and 1 or -1
    local bp = { { ex - 24 * inner, by + 3 + p.br * 0.3 }, { ex, by - 3 }, { ex + 22 * inner, by - p.br * 0.8 } }
    for _, q in ipairs(bp) do q[1], q[2] = math.floor(q[1] + 0.5), math.floor(q[2] + 0.5) end
    c:part(c:line(bp, 7), brow, { flat = true, outline = false, contact = false })
  end

  -- nose
  c:part(c:poly({ {104 + X, 180 + Y}, {120 + X, 180 + Y}, {136 + X, 224 + Y}, {98 + X, 224 + Y} }),
    "skin", { cres = 8, gloss = false, outline = false, contour = "#c47a52", contact = false })
  c:part(c:ellipse(118 + X, 226 + Y, 20, 12), "skin", { cres = 7, gloss = { 108 + X, 220 + Y } })
  c:px(108 + X, 232 + Y, "#8a4234"); c:px(129 + X, 232 + Y, "#8a4234")

  -- forced half-smile: lip pad, then a mouth line lifted at his left corner
  local s = p.sm
  c:part(c:ellipse(116 + X, 266 + Y, 30, 6), lip, { flat = true, outline = false, contact = false })
  local mp = {}
  for k = -8, 8 do
    local u = k / 8
    local lift = (u > 0) and (u * u * (6 + 6 * s)) or (u * u * 2)
    mp[#mp + 1] = { math.floor(116 + X + u * 34 + 0.5), math.floor(262 + Y - lift + 1.5 * (1 - u * u) * s + 0.5) }
  end
  c:fill(c:line(mp, 3), "#4a2c1a")
  local cx2, cy2 = mp[#mp][1], mp[#mp][2]
  c:fill(c:line({ { cx2 - 2, cy2 - 3 }, { cx2 + 2, cy2 + 3 } }, 2), "#c47a52") -- dimple crease
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

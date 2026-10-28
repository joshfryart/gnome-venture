-- variety-act-h17.lua : regional rest-stop scenes (group h17) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h17.lua
-- Frame (5 grid px wooden frame) is copied from the shipped act-hand.png; interior is x 5..68, y 5..49.
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "aseprite-source/extras-pixel/png/")
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local FRAME_SRC = ROOT .. "game/assets/img/acts/act-hand.png"
local only = app.params.only
local floor = math.floor
local function rnd(v) return floor(v + 0.5) end

local INK, UMB = "#2a1a10", "#4a2c1a"
local W, H = 72, 54

---------------------------------------------------------------- helpers
local function new() return GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 0, cres = 2, deep = 1 } end

-- flat (or shaded) outlined prop part
local function part(c, m, hex, o)
  o = o or {}
  local ov = {}
  if not o.shade then ov.rim = hex end
  local op = { flat = not o.shade, gloss = false, cres = o.cres or 2, deep = o.deep or 1, contact = false }
  if o.noline then op.outline = false; op.contour = false end
  return c:part(m, GV.ramp(hex, ov), op)
end
-- plain fill with no outline
local function fl(c, m, hex) c:fill(m, hex); return m end
local function R(c, x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end

local FRAME
local function frame(c)
  if not FRAME then FRAME = Image{ fromFile = FRAME_SRC } end
  for gy = 0, H - 1 do for gx = 0, W - 1 do
    if not (gx >= 5 and gx <= 68 and gy >= 5 and gy <= 49) then
      local v = FRAME:getPixel(gx * 2, gy * 2)
      if app.pixelColor.rgbaA(v) > 0 then
        c:px(gx, gy, string.format("#%02x%02x%02x", app.pixelColor.rgbaR(v), app.pixelColor.rgbaG(v), app.pixelColor.rgbaB(v)))
      end
    end
  end end
end

local function finish(c, slug)
  frame(c)
  local ase, png = ASE .. "variety-act-" .. slug .. ".aseprite", OUT .. "act-" .. slug .. ".png"
  local t = c:save(ase, png)
  print(slug, GV.report(t))
  assert(t.semi == 0 and t.bw == 0)
  -- the shipped frame has a 2x2 transparent notch at each corner: clear them, then rewrite both files
  local spr = app.open(ase)
  local img = spr.cels[1].image
  for _, p in ipairs({ { 0, 0 }, { 142, 0 }, { 0, 106 }, { 142, 106 } }) do
    for dx = 0, 1 do for dy = 0, 1 do img:putPixel(p[1] + dx, p[2] + dy, 0) end end
  end
  spr:saveAs(ase)
  spr:saveCopyAs(png)
  spr:close()
end

-- rng
local seed = 7
local function rand() seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648 end

-- sky + hills + grass for a daylight meadow. g = grass line.
local function day(c, g, opt)
  opt = opt or {}
  local sky = opt.sky or { "#a8d4e0", "#bcdde4", "#cfe8e6" }
  c:bands(R(c, 0, 0, W - 1, g), sky, { dir = "v" })
  if opt.cloud ~= false then
    local cx = opt.cloud or 14
    c:fill(c:ellipse(cx, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(cx + 4, 8, 5, 2), "#f4eee0")
  end
  local hc = opt.hill or "#5e8a44"
  c:fill(c:ellipse(18, g + 2, 34, 11), hc)
  c:fill(c:ellipse(60, g + 3, 30, 9), opt.hill2 or "#4e8a3c")
  c:fill(R(c, 0, g, W - 1, H - 1), opt.grass or "#7ea85a")
  c:fill(R(c, 0, g, W - 1, g), opt.edge or "#9cc070")
  for i = 1, 14 do
    local x, y = floor(rand() * 66) + 3, g + 2 + floor(rand() * (H - g - 4))
    c:px(x, y, "#5e8a44"); c:px(x + 1, y - 1, "#5e8a44")
  end
end

-- a pine built of stacked row-triangles (snow caps optional)
local function pine(c, x, yb, h, snow)
  part(c, R(c, x - 1, yb - 3, x, yb), "#5e3f28", { noline = true })
  local tiers = 3
  local th = floor((h - 2) / 2)
  local m = c:mask()
  local caps = c:mask()
  for t = 0, tiers - 1 do
    local top = yb - 3 - h + 2 + t * floor((h - 4) / tiers)
    local hh = th
    local w = 2 + t * 2
    for i = 0, hh - 1 do
      local hw = floor(i * w / (hh - 1) + 0.5)
      m:add(c:rect(x - hw - 1, top + i, x + hw, top + i))
      if i <= 1 then caps:add(c:rect(x - hw - 1, top + i, x + hw, top + i)) end
    end
  end
  part(c, m, "#2f5a2a")
  if snow then c:fill(caps, "#f4f8fa") end
end

---------------------------------------------------------------- the gnome
-- Parametric by scale s (1 = the 10x18 gnome of the shipped cards). Base units: x cells from the centre, u rows up from the feet row.
-- o: d = facing (1 right, -1 left), s = scale, upper = no legs, sit = seated (hips at oy, legs forward), walk = 1/-1 stride,
--    eyes = "open"|"shut"|"happy", hat = hex, arms = { {a={dx,u}, b={dx,u}, front=bool, nohand=bool}, ... } (base units from feet-centre)
-- returns sil, G where G.P(dx,u) -> absolute x,y ; G.hat = hat mask ; G.tip = x,y of the hat tip
local function gnome(c, ox, oy, o)
  o = o or {}
  local d, s = o.d or 1, o.s or 1
  local BODY, BEARD, SKIN, BOOT = "#4a6e9a", "#f4eee0", "#f0c8a0", "#5a3a22"
  local hatc = o.hat or "#c0442e"
  local hatd = (o.hat and "#8a4a1a") or "#8e2e1e"
  local sil = c:mask()
  local function X(v) return ox + rnd(v * s) end
  local function Yp(u) return oy - rnd(u * s) end
  local function rx(x0, x1)
    if d < 0 then x0, x1 = -x1, -x0 end
    return ox + rnd(x0 * s), ox + math.max(rnd(x0 * s), rnd((x1 + 1) * s) - 1)
  end
  local function ry(u0, u1)
    local y0, y1 = oy + 1 - rnd((u1 + 1) * s), oy - rnd(u0 * s)
    if y0 > y1 then y0 = y1 end
    return y0, y1
  end
  local function rc(x0, u0, x1, u1) -- rect in base cell units (x mirrored by facing)
    local a, b = rx(x0, x1); local e, f = ry(u0, u1)
    return c:rect(a, e, b, f)
  end
  local function sym(x0, u0, x1, u1) -- symmetric rect (no mirroring)
    local a, b = ox + rnd(x0 * s), ox + math.max(rnd(x0 * s), rnd((x1 + 1) * s) - 1)
    local e, f = ry(u0, u1)
    return c:rect(a, e, b, f)
  end
  local function pp(m, hex)
    c:part(m, GV.ramp(hex, { rim = hex }), { flat = true, gloss = false, contact = false, outline = false, contour = false })
    sil:add(m)
  end
  local G = {}
  function G.P(dx, u) return X(dx), Yp(u) end
  -- legs
  if not o.upper then
    if o.sit then
      pp(rc(2, 0, 7, 2), BODY)                  -- thigh forward
      pp(rc(6, -4, 7, 0), BODY)                 -- shin
      pp(rc(6, -6, 9, -5), BOOT)                -- boot
    else
      local bl, br = { -4, 0, -1, 1 }, { 1, 0, 4, 1 }
      if o.walk and o.walk > 0 then br = { 2, 1, 5, 2 } elseif o.walk and o.walk < 0 then bl = { -5, 1, -2, 2 } end
      pp(sym(bl[1], bl[2], bl[3], bl[4]), BOOT); pp(sym(br[1], br[2], br[3], br[4]), BOOT)
      pp(sym(bl[1] + 1, bl[2] + 2, bl[3] - 1, bl[2] + 3), BODY); pp(sym(br[1] + 1, br[2] + 2, br[3] - 1, br[2] + 3), BODY)
    end
  end
  pp(sym(-4, 2, 4, 8), BODY)
  local function arms(front)
    for _, a in ipairs(o.arms or {}) do
      if (a.front or false) == front then
        local t = math.max(2, rnd(2 * s))
        local ax, ay = X(a.a[1]), Yp(a.a[2])
        local bx, by = X(a.b[1]), Yp(a.b[2])
        pp(c:line({ { ax, ay }, { bx, by } }, t), a.sleeve or BODY)
        if not a.nohand then
          local hs = math.max(2, rnd(2 * s))
          pp(c:rect(bx - 0, by - 0, bx + hs - 1, by + hs - 1):shift(-floor(hs / 2) + 0, -floor(hs / 2)), SKIN)
        end
      end
    end
  end
  arms(false)
  local beard = sym(-3, 5, 3, 9); beard:add(sym(-3, 5, 3, 9)); beard:add(sym(-2, 2, 2, 5))
  local bb = c:rect(ox + rnd(-3 * s), select(1, ry(2, 9)), ox + rnd(4 * s) - 1, select(2, ry(2, 9)))
  -- round the beard bottom corners
  bb:del(ox + rnd(-3 * s), select(2, ry(2, 9))); bb:del(ox + rnd(4 * s) - 1, select(2, ry(2, 9)))
  pp(bb, BEARD)
  -- face
  pp(sym(-3, 10, 3, 11), SKIN)
  local fy0, fy1 = ry(10, 11)
  local ey = fy1
  local c1, c2 = (d > 0) and -1 or -2, (d > 0) and 2 or 1
  local e1a, e1b = ox + rnd(c1 * s), ox + rnd(c2 * s)
  local eh = math.max(1, rnd(s))
  local function eye(x, col) for k = 0, eh - 1 do c:px(x, ey - k, col) end end
  if o.eyes == "shut" then
    eye(e1a, "#8a4a34"); eye(e1b, "#8a4a34")
    c:px(e1a - 1, ey - eh + 1, "#8a4a34"); c:px(e1b + 1, ey - eh + 1, "#8a4a34")
  elseif o.eyes == "happy" then
    c:px(e1a, ey - eh, INK); c:px(e1b, ey - eh, INK)
    c:px(e1a - 1, ey - eh + 1, INK); c:px(e1a + 1, ey - eh + 1, INK); c:px(e1b - 1, ey - eh + 1, INK); c:px(e1b + 1, ey - eh + 1, INK)
    c:px(e1a, ey - eh + 1, "#f0c8a0"); c:px(e1b, ey - eh + 1, "#f0c8a0")
  else
    eye(e1a, INK); eye(e1b, INK)
  end
  local nx = ox + d * rnd(3 * s) + (d < 0 and 0 or 0)
  for yy = fy1 - math.max(0, rnd(s) - 1), fy1 do c:px(nx, yy, "#e08a7a") end
  arms(true)
  -- hat: cone with a bent tip, then the brim
  local hy0, _ = ry(13, 18)
  local _, hy1 = ry(13, 13)
  local hat = c:mask()
  local n = hy1 - hy0
  for yy = hy0, hy1 do
    local fr = (n == 0) and 1 or (yy - hy0) / n
    local hw = rnd(fr * 3.2 * s)
    local shift = (yy - hy0 <= math.max(1, rnd(s))) and -d or 0
    hat:add(c:rect(ox - hw + shift, yy, ox + hw + shift, yy))
  end
  local by0, by1 = ry(12, 12)
  local brim = c:rect(ox + rnd(-4 * s), by0, ox + rnd(5 * s) - 1, by1)
  hat:add(brim)
  pp(hat, hatc)
  pp(brim, hatd)
  G.hat = hat; G.tipx, G.tipy = ox - d, hy0
  if o.band then c:fill(c:rect(ox + rnd(-3 * s), hy1 - 1, ox + rnd(3 * s), hy1 - 1), o.band) end
  c:outline(sil, { ol = 1, olx = 0 })
  return sil, G
end

local function arm(a, b, front, nohand) return { a = a, b = b, front = front, nohand = nohand } end



---------------------------------------------------------------- h17 helpers
local function ln(c, pts, t, col) c:fill(c:line(pts, t), col) end
local function puff(c, x, y, col) c:fill(c:ellipse(x, y, 2, 1), col or "#f4f8fa"); c:fill(R(c, x - 1, y + 1, x, y + 1), col or "#f4f8fa") end
local function room(c, wall, line, fy, floor, fline)
  c:fill(R(c, 0, 0, W - 1, fy - 1), wall)
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, fy - 1), line) end
  fl(c, R(c, 0, 5, W - 1, 6), "#8a5a35")
  c:fill(R(c, 0, fy, W - 1, H - 1), floor)
  for y = fy + 3, H - 1, 4 do fl(c, R(c, 0, y, W - 1, y), fline) end
  fl(c, R(c, 0, fy, W - 1, fy), fline)
end
local S = {}
local DONE = {}
local function scene(slug, fn) S[slug] = function() finish(fn(), slug) end; DONE[#DONE + 1] = slug end
local function sparkle(c, x, y, a, b) a = a or "#fff1c8"; b = b or "#f5cf6a"
  c:px(x, y, a); c:px(x - 1, y, b); c:px(x + 1, y, b); c:px(x, y - 1, b); c:px(x, y + 1, b) end
local function bamboo(c, x, y0, y1, w, col, nodec)
  part(c, R(c, x, y0, x + (w or 2), y1), col or "#7ab55c", { noline = true })
  for y = y0 + 4, y1, 7 do fl(c, R(c, x, y, x + (w or 2), y), nodec or "#4e8a3c") end
end

---------------------------------------------------------------- scenes
-- 1 pink rice: gnome folds a rice paddle through a tub of rosy rice beside a steaming stove
scene("r_ea_redbean_rice", function()
  seed = 61
  local c = new()
  room(c, "#c9a96e", "#b8965c", 41, "#8a5a35", "#6b3b2a")
  part(c, R(c, 44, 31, 66, 47), "#8b8f96", { shade = true })
  fl(c, R(c, 50, 38, 60, 47), "#2a1a10"); fl(c, R(c, 52, 42, 58, 47), "#e0501f"); fl(c, R(c, 54, 44, 56, 47), "#ffd86a")
  part(c, R(c, 46, 20, 64, 30), "#d9a660"); fl(c, R(c, 46, 25, 64, 25), "#a8703e")
  part(c, R(c, 45, 30, 65, 31), "#6b3b2a")
  part(c, c:poly({ { 55, 12 }, { 65, 20 }, { 45, 20 } }), "#e8c48a")
  fl(c, R(c, 55, 10, 55, 11), "#6b3b2a")
  for i, p in ipairs({ { 53, 9 }, { 58, 7 }, { 54, 6 }, { 60, 11 } }) do puff(c, p[1], p[2], "#f6d4d8") end
  -- tub of pink rice
  part(c, c:rrect(4, 37, 24, 47, 2), "#b07a45", { shade = true })
  fl(c, R(c, 5, 41, 23, 41), "#6b3b2a"); fl(c, R(c, 5, 45, 23, 45), "#6b3b2a")
  part(c, c:ellipse(14, 37, 10, 3), "#e8a0a8")
  c:fill(c:ellipse(14, 36, 7, 1), "#f6c4c8")
  for _, p in ipairs({ { 8, 37 }, { 12, 38 }, { 17, 37 }, { 20, 36 }, { 14, 35 } }) do c:px(p[1], p[2], "#8e2e3e") end
  -- bowl of red beans
  part(c, c:ellipse(41, 47, 4, 2), "#e8e0cc"); c:fill(c:ellipse(41, 46, 3, 1), "#8e2e3e"); c:px(40, 46, "#b8465a")
  local _, G = gnome(c, 31, 47, { d = -1, eyes = "happy", arms = { arm({ 4, 6 }, { 5, 3 }, false), arm({ -4, 7 }, { -9, 10 }, true) } })
  local hx, hy = G.P(-9, 10)
  ln(c, { { hx, hy }, { hx - 7, hy - 5 } }, 2, "#d9a660")
  part(c, c:ellipse(hx - 9, hy - 6, 3, 2), "#e8c48a"); c:fill(c:ellipse(hx - 9, hy - 6, 2, 1), "#f0a0a8")
  return c
end)

-- 2 reeling silk: cocoons float in a warm basin, one thread winds onto a wheel
scene("r_ea_reel_silk", function()
  seed = 62
  local c = new()
  room(c, "#d4cbb4", "#c4baa0", 41, "#8a5a35", "#6b3b2a")
  -- window slit with light
  part(c, R(c, 8, 12, 20, 24), "#a8d4e0"); fl(c, R(c, 14, 12, 14, 24), "#8a5a35"); fl(c, R(c, 8, 18, 20, 18), "#8a5a35")
  -- reel wheel on a frame
  part(c, R(c, 51, 36, 53, 47), "#8a5a35", { noline = true }); part(c, R(c, 58, 36, 60, 47), "#8a5a35", { noline = true })
  part(c, c:ellipse(56, 29, 11, 11), "#8a5a35")
  c:fill(c:ellipse(56, 29, 8, 8), "#d4cbb4"); c:fill(c:ellipse(56, 29, 8, 8), "#d4cbb4")
  for _, d in ipairs({ { 0, -8 }, { 0, 8 }, { -8, 0 }, { 8, 0 }, { -6, -6 }, { 6, 6 }, { -6, 6 }, { 6, -6 } }) do ln(c, { { 56, 29 }, { 56 + d[1], 29 + d[2] } }, 1, "#a8703e") end
  c:fill(c:ellipse(56, 29, 3, 3), "#f4eee0"); c:fill(c:ellipse(56, 29, 3, 3):clip(R(c, 56, 0, 70, 70)), "#e8dcc0")
  c:fill(c:ellipse(56, 29, 9, 9):clip(R(c, 56, 0, 70, 30)), "#f4eee0"); c:fill(c:ellipse(56, 29, 7, 7):clip(R(c, 56, 0, 70, 30)), "#d4cbb4")
  for _, d in ipairs({ { 0, -8 }, { 6, -6 }, { 8, 0 } }) do ln(c, { { 56, 29 }, { 56 + d[1], 29 + d[2] } }, 1, "#a8703e") end
  c:fill(c:ellipse(56, 29, 2, 2), "#8a5a35")
  fl(c, R(c, 56, 17, 56, 18), "#8a5a35")
  -- table + basin
  part(c, R(c, 4, 36, 40, 38), "#b07a45")
  fl(c, R(c, 4, 36, 40, 36), "#d9a660")
  part(c, R(c, 6, 39, 7, 44), "#8a5a35", { noline = true }); part(c, R(c, 36, 39, 37, 44), "#8a5a35", { noline = true })
  part(c, c:poly({ { 10, 28 }, { 32, 28 }, { 29, 36 }, { 13, 36 } }), "#c9783a", { shade = true })
  c:fill(c:ellipse(21, 28, 11, 2), "#e8a060"); c:fill(c:ellipse(21, 28, 9, 1), "#a8d4e0")
  for _, p in ipairs({ { 15, 28 }, { 19, 28 }, { 23, 28 }, { 27, 28 }, { 17, 29 }, { 25, 29 } }) do
    c:fill(c:ellipse(p[1], p[2], 1.5, 1), "#f4eee0"); c:px(p[1], p[2], "#e8dcc0")
  end
  puff(c, 16, 24, "#f4f8fa"); puff(c, 22, 21, "#f4f8fa"); puff(c, 27, 24, "#f4f8fa")
  local gx, gy = 38, 22
  part(c, R(c, gx - 1, gy - 2, gx, 35), "#6b3b2a", { noline = true })
  fl(c, R(c, gx - 3, gy - 2, gx + 1, gy - 2), "#6b3b2a")
  ln(c, { { 21, 27 }, { 36, 22 } }, 1, "#fffdf4"); ln(c, { { 36, 22 }, { 45, 28 } }, 1, "#fffdf4")
  gnome(c, 41, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 9, 12 }, true) } })
  return c
end)

-- 3 dragonfly kite: bamboo frame, one wing painted; gnome brushes red onto the next
scene("r_ea_dragonfly_kite", function()
  seed = 63
  local c = new()
  room(c, "#cdbfa0", "#bdae8c", 42, "#a8703e", "#8a5a35")
  for _, x in ipairs({ 8, 11, 14 }) do part(c, R(c, x, 8, x + 1, 44), "#a8c060", { noline = true }); for y = 14, 40, 9 do fl(c, R(c, x, y, x + 1, y), "#6a8a3c") end end
  -- easel legs
  part(c, R(c, 47, 38, 48, 47), "#8a5a35", { noline = true })
  -- wings (frame outlines + paper)
  local function wing(cx, cy, rx, ry, col)
    part(c, c:ellipse(cx, cy, rx, ry), col or "#f4eee0")
    c:fill(c:line({ { cx - rx, cy }, { cx + rx, cy } }, 1), "#d9a660")
  end
  wing(39, 22, 7, 2, "#f4eee0"); wing(57, 22, 7, 2, "#f4eee0")
  wing(41, 30, 6, 2, "#f4eee0"); wing(55, 30, 6, 2, "#dd3a2a")
  fl(c, R(c, 36, 22, 44, 22), "#d9a660"); fl(c, R(c, 52, 22, 62, 22), "#d9a660")
  -- body
  part(c, R(c, 46, 20, 50, 42), "#3f8a5a")
  for y = 24, 40, 4 do fl(c, R(c, 46, y, 50, y), "#2a6a42") end
  part(c, c:ellipse(48, 15, 5, 4), "#3f8a5a")
  fl(c, R(c, 44, 13, 46, 15), "#fffdf4"); fl(c, R(c, 50, 13, 52, 15), "#fffdf4"); c:px(45, 14, INK); c:px(51, 14, INK)
  -- tail ribbon
  ln(c, { { 48, 42 }, { 46, 45 }, { 49, 47 } }, 1, "#dd3a2a")
  -- paint pot and gnome
  part(c, R(c, 28, 43, 33, 47), "#c0442e"); fl(c, R(c, 28, 43, 33, 43), "#8e2e1e")
  local _, G = gnome(c, 20, 47, { d = 1, s = 1.2, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 9, 12 }, true) } })
  local hx, hy = G.P(9, 12)
  ln(c, { { hx, hy }, { hx + 7, hy - 2 } }, 1, "#8a5a35"); fl(c, R(c, hx + 7, hy - 3, hx + 9, hy - 1), "#dd3a2a")
  c:px(60, 34, "#dd3a2a"); c:px(63, 36, "#dd3a2a")
  return c
end)

-- 4 straw belts: gnome wraps a fat straw belt round a crooked pine
scene("r_ea_pine_belts", function()
  seed = 64
  local c = new()
  day(c, 38, { sky = { "#c4d8cc", "#d6e2cc", "#e2e8c8" }, cloud = 56 })
  pine(c, 12, 39, 22); pine(c, 62, 38, 20)
  fl(c, R(c, 10, 31, 14, 34), "#e0b84c"); fl(c, R(c, 60, 30, 64, 33), "#e0b84c")
  -- big crooked trunk
  part(c, R(c, 41, 18, 46, 46), "#6b4a2e", { noline = true })
  part(c, R(c, 43, 10, 47, 20), "#6b4a2e", { noline = true })
  fl(c, R(c, 43, 24, 43, 44), "#4a3220")
  for _, t in ipairs({ { 44, 17, 16, 7 }, { 44, 12, 13, 6 }, { 44, 7, 9, 5 } }) do
    part(c, c:poly({ { t[1], t[2] }, { t[1] + t[3], t[2] + t[4] + 2 }, { t[1] - t[3], t[2] + t[4] + 2 } }), "#2f5a2a")
  end
  -- the belt
  part(c, R(c, 39, 31, 48, 37), "#e0b84c")
  for x = 40, 47, 2 do ln(c, { { x, 31 }, { x + 1, 37 } }, 1, "#b08a30") end
  fl(c, R(c, 39, 34, 48, 34), "#f0d070")
  -- pests heading for the belt
  c:px(43, 41, INK); c:px(44, 42, INK); c:px(45, 40, INK)
  -- straw bundle and gnome
  part(c, c:ellipse(18, 46, 6, 3), "#e0b84c"); fl(c, R(c, 14, 45, 22, 45), "#f0d070"); fl(c, R(c, 15, 47, 21, 47), "#b08a30")
  gnome(c, 31, 47, { d = 1, eyes = "open", arms = { arm({ 4, 6 }, { 9, 8 }, true), arm({ -4, 6 }, { 4, 10 }, false) } })
  c:px(37, 33, "#f0d070"); c:px(38, 35, "#f0d070")
  return c
end)

-- 5 teahouse screens: a fresh white sheet pressed onto the holey screen
scene("r_ea_teahouse_screens", function()
  seed = 65
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 39), "#8a5a35")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#b8c07a")
  for x = 6, W - 1, 12 do fl(c, R(c, x, 40, x, H - 1), "#8a9a52") end
  fl(c, R(c, 0, 40, W - 1, 41), "#6b3b2a")
  local px0 = { 5, 21, 37, 53 }
  for i, x0 in ipairs(px0) do
    local paper = (i == 4) and "#e8dcb0" or "#f6f2e4"
    fl(c, R(c, x0, 7, x0 + 15, 39), paper)
    for yy = 14, 32, 9 do fl(c, R(c, x0, yy, x0 + 15, yy), "#6b3b2a") end
    for xx = 4, 12, 4 do fl(c, R(c, x0 + xx, 7, x0 + xx, 39), "#6b3b2a") end
    fl(c, R(c, x0, 7, x0, 39), "#4a2c1a"); fl(c, R(c, x0 + 15, 7, x0 + 15, 39), "#4a2c1a")
  end
  fl(c, R(c, 5, 7, 68, 7), "#4a2c1a"); fl(c, R(c, 5, 39, 68, 39), "#4a2c1a")
  -- finger holes
  for _, h in ipairs({ { 41, 17 }, { 42, 18 }, { 46, 22 }, { 47, 23 }, { 43, 27 }, { 49, 28 }, { 56, 12 }, { 57, 13 } }) do fl(c, R(c, h[1], h[2], h[1] + 1, h[2] + 1), "#3a2418") end
  -- paste bucket and roll
  part(c, R(c, 56, 41, 64, 48), "#b07a45"); fl(c, R(c, 56, 43, 64, 43), "#6b3b2a"); fl(c, R(c, 56, 46, 64, 46), "#6b3b2a")
  fl(c, R(c, 57, 40, 63, 41), "#f4eee0")
  part(c, R(c, 44, 44, 52, 48), "#f6f2e4"); fl(c, R(c, 44, 44, 44, 48), "#d9d2b8")
  -- gnome pressing a new sheet
  part(c, R(c, 15, 15, 29, 33), "#fffdf4")
  fl(c, R(c, 15, 15, 29, 15), "#e0dcc8"); fl(c, R(c, 15, 15, 15, 33), "#e0dcc8")
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 13 }, true), arm({ 4, 7 }, { 7, 12 }, true) } })
  c:px(34, 20, "#fffdf4"); c:px(35, 22, "#fffdf4")
  return c
end)

-- 6 persimmon strings (autumn): hanging strings of orange fruit under the eaves
scene("r_ea_persimmon_strings", function()
  seed = 66
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#d8c49a")
  for x = 3, W - 1, 8 do fl(c, R(c, x, 12, x, 38), "#c0aa7e") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#c9a96e")
  fl(c, R(c, 0, 39, W - 1, 39), "#a8703e")
  -- eave: dark tiles with scalloped edge and beam
  c:fill(R(c, 0, 0, W - 1, 9), "#4a4a5a")
  for x = 0, W - 1, 4 do fl(c, R(c, x, 4, x, 9), "#3a3a48"); fl(c, R(c, x + 1, 10, x + 2, 10), "#4a4a5a") end
  part(c, R(c, 0, 11, W - 1, 13), "#6b3b2a")
  fl(c, R(c, 0, 11, W - 1, 11), "#8a5a35")
  local strs = { { 11, 4 }, { 21, 5 }, { 31, 3 }, { 45, 5 }, { 56, 4 }, { 65, 3 } }
  for _, s in ipairs(strs) do
    ln(c, { { s[1], 14 }, { s[1], 14 + s[2] * 5 } }, 1, "#8a5a35")
    for i = 0, s[2] - 1 do
      local y = 17 + i * 5
      c:fill(c:ellipse(s[1], y, 2, 2), "#e8742a"); c:px(s[1] - 1, y - 1, "#f4a050"); c:fill(R(c, s[1] - 1, y - 2, s[1] + 1, y - 2), "#4e8a3c")
      c:outline(c:ellipse(s[1], y, 2, 2))
    end
  end
  fl(c, R(c, 8, 48, 14, 48), "#b8965c")
  c:px(18, 44, "#c8802a"); c:px(19, 45, "#c8802a"); c:px(52, 46, "#c8802a"); c:px(60, 44, "#b8661a"); c:px(8, 41, "#c8802a")
  gnome(c, 38, 47, { d = -1, eyes = "happy", s = 1.1, arms = { arm({ 4, 6 }, { 5, 3 }, false), arm({ -4, 8 }, { -3, 16 }, true) } })
  c:px(42, 26, "#8a5a35")
  return c
end)

-- 7 feather shuttle kick: a heel flick sends the feathered shuttle up
scene("r_ea_shuttle_kick", function()
  seed = 67
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#c8dce0", "#d8e6e0", "#e6ece0" }, { dir = "v" })
  c:fill(R(c, 0, 31, W - 1, 38), "#e6ece0")
  -- shop fronts
  part(c, R(c, 5, 14, 24, 38), "#b07a45"); part(c, R(c, 48, 10, 68, 38), "#c4623a")
  fl(c, R(c, 8, 20, 20, 30), "#6b3b2a"); fl(c, R(c, 52, 18, 64, 30), "#6b3b2a")
  fl(c, R(c, 9, 21, 19, 29), "#e8c48a"); fl(c, R(c, 53, 19, 63, 29), "#a8d4e0")
  local n = 0
  for x = 5, 24, 4 do fl(c, R(c, x, 14, x + 3, 17), (n % 2 == 0) and "#dd3a2a" or "#f4eee0"); n = n + 1 end
  c:outline(R(c, 5, 14, 24, 17))
  ln(c, { { 24, 11 }, { 38, 14 }, { 48, 10 } }, 1, "#5e3f28")
  for _, p in ipairs({ { 28, 14, "#dd3a2a" }, { 36, 15, "#f5cf6a" } }) do part(c, c:ellipse(p[1], p[2] + 1, 2, 2), p[3]) end
  -- cobbled lane
  c:fill(R(c, 0, 38, W - 1, H - 1), "#c9b496")
  for y = 40, 50, 4 do for x = (y % 8 == 0) and 2 or 6, W - 1, 8 do fl(c, R(c, x, y, x + 4, y), "#a8946e") end end
  -- gnome balancing, kicking leg up
  local ox, oy = 28, 43
  local BODY, BOOT = "#4a6e9a", "#5a3a22"
  local function leg(pts, w, col) c:part(c:line(pts, w), GV.ramp(col, { rim = col }), { flat = true, gloss = false, contact = false, outline = false, contour = false }) end
  leg({ { ox - 2, 40 }, { ox - 2, 45 } }, 2, BODY)
  fl(c, R(c, ox - 4, 46, ox, 47), BOOT)
  leg({ { ox + 1, 40 }, { ox + 7, 39 }, { ox + 6, 44 } }, 2, BODY)
  fl(c, R(c, ox + 5, 45, ox + 9, 46), BOOT)
  gnome(c, ox, oy, { d = 1, upper = true, eyes = "open", arms = { arm({ -4, 7 }, { -9, 11 }, false), arm({ 4, 7 }, { 9, 12 }, true) } })
  -- shuttle: coin base + feathers
  local sx, sy = ox + 10, 28
  part(c, c:ellipse(sx, sy + 2, 2, 1), "#e8a317")
  for i, col in ipairs({ "#dd3a2a", "#3f8fb0", "#f5cf6a" }) do
    ln(c, { { sx - 2 + (i - 1) * 2, sy + 1 }, { sx - 3 + (i - 1) * 3, sy - 5 } }, 2, col)
  end
  for _, p in ipairs({ { sx + 6, sy + 6 }, { sx + 9, sy + 2 }, { sx - 5, sy + 8 } }) do c:px(p[1], p[2], "#f5cf6a") end
  return c
end)

-- 8 spinning tops: two whirling tops in a chalk ring, carvers crouched either side
scene("r_ea_spinning_tops", function()
  seed = 68
  local c = new()
  room(c, "#9a6a45", "#845830", 33, "#c9a96e", "#b8965c")
  part(c, R(c, 4, 10, 18, 26), "#6b3b2a"); fl(c, R(c, 6, 12, 16, 24), "#e8c48a")
  for _, p in ipairs({ { 8, 14 }, { 12, 15 }, { 9, 19 }, { 14, 21 }, { 7, 22 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), ({ "#dd3a2a", "#3f8fb0", "#4f9a45" })[(p[1] % 3) + 1]) end
  -- chalk ring
  c:fill(c:ellipse(36, 44, 22, 6), "#f4eee0"); c:fill(c:ellipse(36, 44, 20, 5), "#c9a96e")
  local function top(x, y, a, b)
    c:fill(c:poly({ { x - 4, y - 5 }, { x + 4, y - 5 }, { x, y + 1 } }), a)
    c:outline(c:poly({ { x - 4, y - 5 }, { x + 4, y - 5 }, { x, y + 1 } }))
    fl(c, R(c, x - 3, y - 4, x + 3, y - 4), b)
    fl(c, R(c, x - 4, y - 6, x + 4, y - 6), b); fl(c, R(c, x - 1, y - 8, x, y - 7), "#8a5a35")
  end
  top(29, 43, "#dd3a2a", "#f5cf6a"); top(43, 44, "#3f8fb0", "#f4eee0")
  -- spin marks
  fl(c, R(c, 24, 44, 25, 44), "#f4eee0"); fl(c, R(c, 33, 46, 34, 46), "#f4eee0"); fl(c, R(c, 47, 45, 48, 45), "#f4eee0"); fl(c, R(c, 39, 42, 40, 42), "#f4eee0")
  sparkle(c, 36, 36)
  gnome(c, 9, 47, { d = 1, s = 1, eyes = "open", arms = { arm({ 4, 6 }, { 8, 3 }, true) } })
  gnome(c, 63, 47, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 6 }, { -8, 3 }, true) } })
  return c
end)

-- 9 paddle boats (summer): a long painted boat, drummer at the prow, paddles flashing
scene("r_ea_paddle_race", function()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#8cc8e8", "#a8d8ec", "#c4e4ee" }, { dir = "v" })
  c:fill(c:ellipse(60, 10, 4, 4), "#f5e6a8")
  c:fill(c:ellipse(16, 22, 26, 5), "#5e8a44"); c:fill(c:ellipse(52, 23, 24, 4), "#4e8a3c")
  c:fill(R(c, 0, 22, W - 1, H - 1), "#3f8fb0")
  for y = 25, 49, 4 do for x = (y % 8 == 1) and 3 or 9, W - 1, 12 do fl(c, R(c, x, y, x + 4, y), "#6cb4d0") end end
  fl(c, R(c, 8, 24, 8, 27), "#8a5a35"); fl(c, R(c, 9, 24, 12, 26), "#f4eee0")
  -- main boat hull
  part(c, c:poly({ { 4, 35 }, { 58, 35 }, { 62, 31 }, { 63, 36 }, { 56, 43 }, { 8, 43 } }), "#dd3a2a", { shade = true })
  fl(c, R(c, 6, 37, 57, 37), "#f5cf6a"); fl(c, R(c, 8, 41, 54, 41), "#f5cf6a")
  -- dragon head at the prow
  part(c, c:poly({ { 60, 27 }, { 66, 27 }, { 67, 31 }, { 62, 33 }, { 59, 33 } }), "#4f9a45")
  c:px(64, 29, "#fffdf4"); fl(c, R(c, 61, 25, 62, 26), "#f5cf6a")
  -- paddlers
  for i, x in ipairs({ 14, 26, 38 }) do
    local hat = ({ "#c0442e", "#e8a317", "#3f6fb0" })[i]
    gnome(c, x, 41, { d = 1, upper = true, hat = (i > 1) and hat or nil, eyes = "open", arms = { arm({ 4, 7 }, { 7, 4 }, true) } })
    ln(c, { { x + 5, 36 }, { x + 12, 45 } }, 1, "#f4eee0")
    part(c, c:ellipse(x + 13, 46, 2, 1), "#f4eee0"); fl(c, R(c, x + 9, 47, x + 16, 47), "#e8f4f4")
  end
  -- drum and drummer
  gnome(c, 52, 41, { d = 1, upper = true, hat = "#4f9a45", eyes = "happy", arms = { arm({ -4, 7 }, { -9, 12 }, false), arm({ 4, 7 }, { 6, 14 }, true) } })
  part(c, c:rrect(56, 35, 62, 42, 2), "#c0442e"); fl(c, R(c, 56, 37, 62, 37), "#f5cf6a"); fl(c, R(c, 56, 40, 62, 40), "#f5cf6a")
  fl(c, R(c, 58, 33, 60, 34), "#f5cf6a")
  -- spray
  for _, p in ipairs({ { 6, 44 }, { 20, 46 }, { 33, 47 }, { 46, 46 }, { 54, 45 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#e8f4f4") end
  c:px(16, 40, "#e8f4f4"); c:px(30, 42, "#e8f4f4")
  return c
end)

-- 10 knucklebones: a toss over a blanket, a camel waiting behind
scene("r_ea_knucklebones", function()
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#e8d4a8", "#f0dcae", "#f4e4bc" }, { dir = "v" })
  c:fill(c:ellipse(14, 31, 28, 8), "#d9b878"); c:fill(c:ellipse(60, 32, 26, 7), "#d0ae6e")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#e0c488")
  for _, p in ipairs({ { 6, 44 }, { 62, 46 }, { 66, 38 }, { 10, 36 }, { 30, 36 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#c8a860") end
  -- tent
  part(c, c:poly({ { 15, 15 }, { 26, 34 }, { 4, 34 } }), "#f4eee0"); c:fill(c:poly({ { 15, 22 }, { 19, 34 }, { 11, 34 } }), "#6b3b2a")
  fl(c, R(c, 15, 12, 15, 14), "#8a5a35"); fl(c, R(c, 16, 12, 18, 13), "#dd3a2a")
  -- camel
  local cx = 56
  part(c, R(c, cx - 8, 25, cx + 8, 33), "#c4966a")
  part(c, c:ellipse(cx - 4, 24, 3, 3), "#c4966a"); part(c, c:ellipse(cx + 3, 24, 3, 3), "#c4966a")
  part(c, R(c, cx + 8, 18, cx + 10, 28), "#c4966a"); part(c, R(c, cx + 8, 17, cx + 13, 20), "#c4966a")
  c:px(cx + 11, 18, INK)
  for _, dx in ipairs({ -7, -4, 3, 6 }) do part(c, R(c, cx + dx, 33, cx + dx + 1, 40), "#a8784a", { noline = true }) end
  fl(c, R(c, cx - 8, 28, cx + 8, 28), "#dd3a2a")
  -- blanket
  part(c, c:poly({ { 12, 40 }, { 60, 40 }, { 66, 50 }, { 6, 50 } }), "#c0442e")
  c:fill(c:poly({ { 14, 42 }, { 58, 42 }, { 62, 48 }, { 10, 48 } }), "#f4eee0")
  c:fill(c:poly({ { 16, 43 }, { 56, 43 }, { 59, 47 }, { 13, 47 } }), "#3f6fb0")
  for x = 22, 50, 8 do c:fill(c:poly({ { x, 44 }, { x + 3, 45 }, { x, 46 }, { x - 3, 45 } }), "#f5cf6a") end
  -- bones: two landed, three in the air
  local function bone(x, y)
    part(c, R(c, x, y, x + 2, y + 2), "#f4eee0"); c:px(x + 1, y + 1, "#8a5a35")
  end
  bone(40, 44); bone(46, 46); bone(20, 45)
  bone(37, 30); bone(41, 25); bone(34, 26)
  sparkle(c, 44, 31)
  gnome(c, 26, 46, { d = 1, sit = true, eyes = "happy", arms = { arm({ 3, 7 }, { 9, 13 }, true), arm({ -3, 6 }, { -6, 3 }, false) } })
  return c
end)

-- 11 whisperwood beasts: a panda, a bird, shy eyes in the thicket, and a tick in the book
scene("r_ea_whisperwood_beasts", function()
  seed = 71
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#b4d8b0", "#a4cc9c", "#94c08c", "#86b480" }, { dir = "v" })
  c:fill(R(c, 0, 38, W - 1, H - 1), "#6e9a50")
  c:fill(R(c, 0, 38, W - 1, 38), "#8ab864")
  for _, x in ipairs({ 6, 14, 22 }) do bamboo(c, x, 5, 40, 2, "#8cc06a", "#5e8a44") end
  for _, x in ipairs({ 33, 41, 62, 66 }) do bamboo(c, x, 5, 40, 2, "#7ab55c", "#4e8a3c") end
  fl(c, R(c, 8, 8, 9, 14), "#5e8a44")
  -- leaves
  for _, p in ipairs({ { 10, 14 }, { 24, 18 }, { 36, 12 }, { 60, 16 }, { 44, 20 } }) do ln(c, { { p[1], p[2] }, { p[1] + 4, p[2] - 1 } }, 1, "#4e8a3c"); ln(c, { { p[1], p[2] + 2 }, { p[1] - 4, p[2] + 1 } }, 1, "#5e8a44") end
  -- shy eyes in the thicket
  fl(c, R(c, 28, 26, 31, 30), "#2f5a2a"); c:px(29, 28, "#f4eee0"); c:px(31, 28, "#f4eee0")
  -- panda eating bamboo
  local px, py = 52, 47
  part(c, c:ellipse(px, py - 6, 7, 7), "#f4eee0")
  part(c, R(c, px - 8, py - 4, px - 5, py + 1), "#2a2a30"); part(c, R(c, px + 5, py - 4, px + 8, py + 1), "#2a2a30")
  part(c, R(c, px - 6, py - 2, px - 3, py), "#2a2a30"); part(c, R(c, px + 3, py - 2, px + 6, py), "#2a2a30")
  part(c, c:ellipse(px, py - 15, 5, 4), "#f4eee0")
  fl(c, R(c, px - 5, py - 20, px - 3, py - 18), "#2a2a30"); fl(c, R(c, px + 3, py - 20, px + 5, py - 18), "#2a2a30")
  fl(c, R(c, px - 4, py - 16, px - 2, py - 14), "#2a2a30"); fl(c, R(c, px + 2, py - 16, px + 4, py - 14), "#2a2a30")
  c:px(px - 3, py - 15, "#f4eee0"); c:px(px + 3, py - 15, "#f4eee0"); fl(c, R(c, px - 1, py - 13, px, py - 13), "#2a2a30")
  fl(c, R(c, px - 7, py - 8, px - 5, py - 3), "#2a2a30")
  part(c, R(c, px - 8, py - 12, px - 7, py - 4), "#8cc06a", { noline = true })
  -- small blue bird
  part(c, c:ellipse(15, 22, 2, 2), "#3f8fb0"); fl(c, R(c, 17, 22, 18, 22), "#f5cf6a"); c:px(15, 21, INK)
  -- gnome with the little tally book
  local _, G = gnome(c, 26, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 0, 9 }, false, true), arm({ 4, 7 }, { 6, 9 }, true, true) } })
  local bx, by = G.P(2, 10)
  part(c, R(c, bx - 1, by - 3, bx + 7, by + 3), "#8a5a35")
  fl(c, R(c, bx, by - 2, bx + 6, by + 2), "#f4eee0"); fl(c, R(c, bx + 3, by - 2, bx + 3, by + 2), "#c9b89a")
  fl(c, R(c, bx + 1, by - 1, bx + 2, by), "#3f8a42"); c:px(bx + 1, by, "#3f8a42"); c:px(bx + 2, by - 1, "#3f8a42")
  fl(c, R(c, bx + 4, by - 1, bx + 5, by - 1), "#a8a09a"); fl(c, R(c, bx + 4, by + 1, bx + 5, by + 1), "#a8a09a")
  fl(c, R(c, bx - 2, by + 1, bx, by + 3), "#f0c8a0")
  return c
end)

-- 12 pearlwave shells: a row of fresh shells at the tideline, one held up
scene("r_ea_pearlwave_shells", function()
  seed = 72
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 17), { "#a8d8ec", "#bde4f0", "#d0eef4" }, { dir = "v" })
  c:fill(c:ellipse(12, 9, 6, 2), "#f4eee0"); c:fill(c:ellipse(16, 7, 4, 2), "#f4eee0")
  c:bands(R(c, 0, 18, W - 1, 27), { "#3f9ab8", "#4eaec8", "#62c0d4", "#7ccfd8" }, { dir = "v" })
  for x = 2, W - 1, 9 do fl(c, R(c, x, 22, x + 3, 22), "#a8e0ea") end
  c:fill(R(c, 0, 28, W - 1, 36), "#d8c49a")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#e8d8b0")
  -- foam line
  for x = 0, W - 1 do fl(c, R(c, x, 28 + ((x // 4) % 2), x, 29 + ((x // 4) % 2)), "#f4fafa") end
  for x = 3, W - 1, 6 do c:px(x, 33, "#c8b284") end
  for _, p in ipairs({ { 10, 44 }, { 30, 49 }, { 60, 47 }, { 48, 42 }, { 66, 41 } }) do c:px(p[1], p[2], "#d0bc8c") end
  -- shells in a line
  local sy = 40
  -- scallop (pink fan)
  part(c, c:poly({ { 38, sy + 5 }, { 33, sy - 1 }, { 37, sy - 3 }, { 41, sy - 3 }, { 45, sy - 1 }, { 40, sy + 5 } }), "#f0a8b8")
  for _, x in ipairs({ 36, 39, 42 }) do ln(c, { { 39, sy + 4 }, { x, sy - 2 } }, 1, "#d8788c") end
  fl(c, R(c, 37, sy + 5, 41, sy + 6), "#d8788c")
  -- spiral
  part(c, c:ellipse(50, sy + 2, 4, 3), "#f4eee0"); fl(c, R(c, 49, sy + 1, 51, sy + 1), "#c9a870"); c:px(50, sy + 2, "#c9a870"); c:px(52, sy + 3, "#c9a870")
  -- cone
  part(c, c:poly({ { 58, sy + 4 }, { 62, sy + 4 }, { 61, sy - 3 }, { 59, sy - 3 } }), "#e8c48a")
  fl(c, R(c, 59, sy, 61, sy), "#a8703e"); fl(c, R(c, 59, sy + 2, 61, sy + 2), "#a8703e")
  -- star shell and pearl
  part(c, c:ellipse(66, sy + 5, 2, 2), "#f4a46a"); c:px(66, sy + 5, "#fff1c8")
  c:fill(c:ellipse(30, sy + 6, 1, 1), "#fbf6ea"); c:px(29, sy + 5, "#fffdf4")
  -- gnome holding a shell up to look at it
  local _, G = gnome(c, 18, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 8, 15 }, true, true) } })
  local sx, sy2 = G.P(9, 16)
  part(c, c:poly({ { sx, sy2 + 3 }, { sx - 3, sy2 - 1 }, { sx, sy2 - 3 }, { sx + 3, sy2 - 1 } }), "#f0a8b8")
  fl(c, R(c, sx - 1, sy2 + 3, sx + 1, sy2 + 4), "#f0c8a0")
  sparkle(c, sx + 4, sy2 - 4)
  c:px(8, 49, "#c0442e"); c:px(9, 49, "#c0442e"); c:px(10, 49, "#c0442e")
  return c
end)

-- 13 terrace kites: a sky of kites on long strings above the stepped paddies
scene("r_ea_terrace_kites", function()
  seed = 73
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#8cc8e8", "#a4d4ec", "#bce0ee", "#d0eaf0" }, { dir = "v" })
  c:fill(c:ellipse(60, 28, 22, 8), "#7aa8a0"); c:fill(c:ellipse(12, 30, 20, 8), "#88b4a0")
  -- terraces
  c:fill(R(c, 0, 34, W - 1, H - 1), "#8cc060")
  local gs = { { 34, "#6ea04a" }, { 38, "#4e8a3c" }, { 42, "#7ab55c" }, { 46, "#5e9a44" }, { 50, "#8cc060" } }
  for _, g in ipairs(gs) do
    c:fill(c:ellipse(36, g[1] + 10, 46, 9), g[2])
    c:fill(c:ellipse(36, g[1] + 10, 46, 9):clip(R(c, 0, g[1], W - 1, g[1] + 1)), "#a8d8a0")
  end
  for _, p in ipairs({ { 14, 38 }, { 44, 41 }, { 60, 45 }, { 24, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#a8d8e0") end
  -- gnome with string reel
  local _, G = gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 8 }, { 8, 14 }, true, true) } })
  local hx, hy = G.P(8, 14)
  part(c, R(c, hx - 1, hy - 2, hx + 1, hy + 2), "#8a5a35")
  -- kites: diamond, delta, round, diamond
  local function kite(x, y, kind, col, col2)
    local hx2, hy2 = hx, hy
    ln(c, { { hx2, hy2 }, { x, y + 4 } }, 1, "#fffdf4")
    if kind == "d" then
      part(c, c:poly({ { x, y - 5 }, { x + 4, y }, { x, y + 5 }, { x - 4, y } }), col); ln(c, { { x, y - 5 }, { x, y + 5 } }, 1, col2); ln(c, { { x - 4, y }, { x + 4, y } }, 1, col2)
    elseif kind == "t" then
      part(c, c:poly({ { x, y - 4 }, { x + 6, y + 3 }, { x - 6, y + 3 } }), col); ln(c, { { x, y - 4 }, { x, y + 3 } }, 1, col2)
    else
      part(c, c:ellipse(x, y, 4, 4), col); fl(c, R(c, x - 1, y - 1, x + 1, y + 1), col2)
    end
    ln(c, { { x, y + 5 }, { x - 2, y + 8 }, { x + 1, y + 10 } }, 1, col2)
    fl(c, R(c, x - 3, y + 8, x - 2, y + 8), col2); c:px(x + 1, y + 10, col2)
  end
  kite(28, 11, "d", "#dd3a2a", "#f5cf6a")
  kite(44, 16, "t", "#f5cf6a", "#dd3a2a")
  kite(58, 9, "r", "#3f6fb0", "#f4eee0")
  kite(63, 24, "d", "#4f9a45", "#f4eee0")
  return c
end)

-- 14 jujube bun: five buns on the counter, one split open to show the red date
scene("r_ea_jujube_bun", function()
  seed = 74
  local c = new()
  room(c, "#c9a96e", "#b8965c", 38, "#8a5a35", "#6b3b2a")
  -- steamer stack with steam on a shelf
  part(c, R(c, 46, 14, 64, 20), "#d9a660"); fl(c, R(c, 46, 17, 64, 17), "#a8703e")
  part(c, R(c, 47, 21, 63, 26), "#d9a660"); fl(c, R(c, 47, 24, 63, 24), "#a8703e")
  part(c, c:poly({ { 55, 8 }, { 65, 14 }, { 45, 14 } }), "#e8c48a")
  puff(c, 52, 6, "#f4f8fa"); puff(c, 60, 7, "#f4f8fa")
  part(c, R(c, 6, 14, 24, 15), "#8a5a35")
  part(c, R(c, 8, 8, 12, 13), "#c0442e"); part(c, R(c, 15, 9, 20, 13), "#3f8fb0")
  -- gnome behind the counter holding the opened bun
  local _, G = gnome(c, 34, 44, { d = 1, upper = true, eyes = "happy", arms = { arm({ -4, 7 }, { -8, 12 }, true, true), arm({ 4, 7 }, { 8, 12 }, true, true) } })
  local lx, ly = G.P(-8, 12); local rx2, ry2 = G.P(8, 12)
  part(c, c:ellipse(lx, ly - 1, 3, 3), "#fbf6ea"); fl(c, R(c, lx - 1, ly + 1, lx + 1, ly + 2), "#f0c8a0")
  part(c, c:ellipse(rx2, ry2 - 1, 3, 3), "#fbf6ea"); fl(c, R(c, rx2 - 1, ry2 + 1, rx2 + 1, ry2 + 2), "#f0c8a0")
  part(c, c:ellipse((lx + rx2) // 2, ly - 8, 2, 2), "#c0442e"); c:px((lx + rx2) // 2 - 1, ly - 9, "#e87a6a")
  sparkle(c, (lx + rx2) // 2 + 4, ly - 12); sparkle(c, (lx + rx2) // 2 - 5, ly - 10)
  -- counter and buns
  part(c, R(c, 3, 40, 68, 48), "#b07a45")
  fl(c, R(c, 3, 40, 68, 40), "#d9a660"); fl(c, R(c, 3, 44, 68, 44), "#8a4f2a")
  for i, x in ipairs({ 9, 21, 47, 59 }) do
    part(c, c:ellipse(x, 38, 4, 3), "#fbf6ea"); c:fill(R(c, x - 3, 39, x + 3, 39), "#fbf6ea")
    c:px(x, 36, "#e0d8c4"); c:px(x - 1, 37, "#e0d8c4"); c:px(x + 1, 37, "#e0d8c4")
  end
  part(c, c:ellipse(66, 38, 3, 3), "#fbf6ea")
  return c
end)

-- 15 lotus pods (summer): four showerhead pods on the pond, one popping with seeds
scene("r_ea_lotus_pods", function()
  seed = 75
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#a8d8ec", "#bde4f0", "#d0eef4" }, { dir = "v" })
  c:fill(c:ellipse(10, 8, 7, 2), "#f4eee0")
  c:fill(c:ellipse(40, 22, 40, 6), "#7ab55c")
  c:fill(R(c, 0, 21, W - 1, H - 1), "#4aa0a0")
  for y = 24, 48, 4 do for x = (y % 8 == 0) and 2 or 7, W - 1, 11 do fl(c, R(c, x, y, x + 4, y), "#6cc0b8") end end
  -- lily pads
  for _, p in ipairs({ { 30, 42 }, { 46, 46 }, { 58, 40 }, { 36, 31 } }) do
    part(c, c:ellipse(p[1], p[2], 5, 2), "#4e9a48"); fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#4aa0a0"); c:px(p[1] - 2, p[2] - 1, "#7ab55c")
  end
  -- pods on tall stems
  local pods = { { 36, 21, false }, { 46, 16, true }, { 55, 23, false }, { 64, 19, false } }
  for _, p in ipairs(pods) do
    local x, y = p[1], p[2]
    part(c, R(c, x, y + 3, x + 1, 44), "#5e9a44", { noline = true })
    part(c, c:poly({ { x - 1, y + 4 }, { x + 2, y + 4 }, { x + 5, y }, { x - 4, y } }), p[3] and "#c8d86a" or "#7ab55c")
    part(c, c:ellipse(x, y, 5, 2), p[3] and "#d8e480" or "#8cc062")
    for _, dx in ipairs({ -3, -1, 1, 3 }) do c:px(x + dx, y, p[3] and "#5e7a2a" or "#4e7a38") end
    c:px(x - 2, y - 1, "#4e7a38"); c:px(x + 2, y - 1, "#4e7a38")
  end
  -- seeds popping out of the ripe one
  for _, s in ipairs({ { 43, 11 }, { 47, 9 }, { 50, 12 }, { 45, 7 } }) do c:fill(R(c, s[1], s[2], s[1] + 1, s[2] + 1), "#f4eee0") end
  sparkle(c, 52, 8)
  -- pink lotus blossom in front
  part(c, c:ellipse(26, 40, 4, 3), "#f09ab8"); part(c, c:poly({ { 26, 33 }, { 29, 40 }, { 23, 40 } }), "#f6b8cf")
  fl(c, R(c, 26, 36, 26, 40), "#f09ab8")
  -- jetty and gnome
  part(c, R(c, 4, 41, 19, 44), "#b07a45"); fl(c, R(c, 4, 41, 19, 41), "#d9a660")
  part(c, R(c, 6, 45, 7, 49), "#6b3b2a", { noline = true }); part(c, R(c, 16, 45, 17, 49), "#6b3b2a", { noline = true })
  gnome(c, 11, 40, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 10, 14 }, true) } })
  return c
end)

-- 16 cricket cages: four woven cages on a pole, the gnome cups an ear to the loud one
scene("r_ea_cricket_cages", function()
  seed = 76
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#c8dce0", "#d8e6e0", "#e6ece0" }, { dir = "v" })
  c:fill(R(c, 0, 39, W - 1, H - 1), "#c9b496")
  for y = 42, 50, 4 do for x = (y % 8 == 2) and 2 or 6, W - 1, 8 do fl(c, R(c, x, y, x + 4, y), "#a8946e") end end
  -- stall awning and pole
  local n = 0
  for x = 4, 67, 4 do fl(c, R(c, x, 5, x + 3, 9), (n % 2 == 0) and "#3f8a5a" or "#f4eee0"); fl(c, R(c, x + 1, 10, x + 2, 10), (n % 2 == 0) and "#3f8a5a" or "#f4eee0"); n = n + 1 end
  part(c, R(c, 5, 11, 66, 12), "#8a5a35")
  part(c, R(c, 5, 11, 6, 40), "#8a5a35", { noline = true }); part(c, R(c, 65, 11, 66, 40), "#8a5a35", { noline = true })
  local cages = { { 17, 10, 16 }, { 32, 12, 21 }, { 48, 13, 17 }, { 60, 11, 22 } }
  for i, cg in ipairs(cages) do
    local x, y = cg[1], cg[3]
    ln(c, { { x, 13 }, { x, y - 4 } }, 1, "#6b3b2a")
    part(c, c:poly({ { x - 4, y + 5 }, { x - 4, y }, { x - 2, y - 3 }, { x + 2, y - 3 }, { x + 4, y }, { x + 4, y + 5 } }), "#d9bc84")
    for dx = -2, 2, 2 do fl(c, R(c, x + dx, y - 2, x + dx, y + 4), "#a8703e") end
    fl(c, R(c, x - 4, y + 5, x + 4, y + 5), "#8a5a35")
    if i == 3 then c:px(x - 1, y + 3, "#3f8a42"); c:px(x, y + 3, "#3f8a42"); c:px(x + 1, y + 3, "#3f8a42") end
  end
  -- sound from the loud one
  for _, p in ipairs({ { 41, 19 }, { 41, 20 }, { 40, 21 }, { 40, 22 }, { 41, 23 }, { 38, 20 }, { 38, 21 }, { 37, 22 } }) do c:px(p[1], p[2], "#5a3a80") end
  for _, p in ipairs({ { 54, 19 }, { 54, 20 }, { 55, 21 }, { 55, 22 }, { 54, 23 }, { 57, 20 }, { 57, 21 }, { 58, 22 } }) do c:px(p[1], p[2], "#5a3a80") end
  c:px(48, 11, "#f5cf6a")
  -- table at right
  part(c, R(c, 44, 36, 66, 38), "#b07a45"); fl(c, R(c, 44, 36, 66, 36), "#d9a660")
  part(c, R(c, 46, 39, 47, 47), "#8a5a35", { noline = true }); part(c, R(c, 63, 39, 64, 47), "#8a5a35", { noline = true })
  part(c, c:ellipse(50, 34, 3, 2), "#8cc06a"); part(c, c:ellipse(58, 34, 4, 2), "#e8c48a")
  gnome(c, 34, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 6, 12 }, true) } })
  return c
end)

-- 17 pound rice cakes: mallet raised over the tub, a partner ready to turn the dough
scene("r_ea_pound_ricecake", function()
  seed = 77
  local c = new()
  day(c, 38, { cloud = 56, sky = { "#c4dce0", "#d4e6e2", "#e2ece2" } })
  -- low mill hut at the back
  part(c, R(c, 4, 22, 22, 38), "#c9a96e"); fl(c, R(c, 8, 28, 14, 38), "#6b3b2a")
  part(c, c:poly({ { 13, 13 }, { 26, 23 }, { 0, 23 } }), "#8a5a35")
  -- stone mortar on a stump
  part(c, R(c, 28, 44, 46, 48), "#8a5a35")
  part(c, c:rrect(25, 36, 49, 46, 3), "#8b8f96", { shade = true })
  part(c, c:ellipse(37, 36, 12, 3), "#a8aeb4")
  c:fill(c:ellipse(37, 36, 9, 2), "#fbf6ea"); c:fill(R(c, 33, 35, 37, 35), "#ffffee")
  puff(c, 33, 31, "#f4f8fa"); puff(c, 40, 29, "#f4f8fa"); puff(c, 36, 26, "#f4f8fa")
  -- mallet gnome
  local _, G = gnome(c, 14, 47, { d = 1, s = 1.2, eyes = "open", arms = { arm({ 4, 7 }, { 9, 16 }, true), arm({ -4, 7 }, { 6, 13 }, false) } })
  local hx, hy = G.P(8, 15)
  ln(c, { { hx - 2, hy + 2 }, { hx + 8, hy - 6 } }, 2, "#a8703e")
  part(c, c:poly({ { hx + 5, hy - 12 }, { hx + 13, hy - 6 }, { hx + 10, hy - 1 }, { hx + 3, hy - 7 } }), "#8a5a35", { shade = true })
  fl(c, R(c, hx + 7, hy - 8, hx + 8, hy - 7), "#d9a660")
  -- partner turning the dough with a wet hand
  gnome(c, 58, 47, { d = -1, hat = "#4f9a45", sit = true, eyes = "open", arms = { arm({ -3, 7 }, { -9, 7 }, true) } })
  c:px(48, 38, "#f4f8fa")
  sparkle(c, 30, 20)
  return c
end)

-- 18 pole the raft: planted pole, bamboo raft, green gorge and white water
scene("r_ea_pole_rapids", function()
  seed = 78
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 14), { "#c8e0dc", "#d4e8e0", "#e0f0e8" }, { dir = "v" })
  c:fill(R(c, 0, 15, W - 1, H - 1), "#3f9a98")
  -- cliffs with mist
  c:fill(c:poly({ { 0, 0 }, { 20, 0 }, { 17, 14 }, { 20, 26 }, { 10, 36 }, { 14, 54 }, { 0, 54 } }), "#3f7a48")
  c:fill(c:poly({ { 72, 0 }, { 50, 0 }, { 54, 12 }, { 50, 24 }, { 58, 38 }, { 56, 54 }, { 72, 54 } }), "#4a8a50")
  c:fill(c:poly({ { 0, 0 }, { 11, 0 }, { 10, 12 }, { 12, 24 }, { 6, 34 }, { 8, 54 }, { 0, 54 } }), "#2f5a38")
  c:fill(c:poly({ { 72, 0 }, { 60, 0 }, { 62, 12 }, { 60, 24 }, { 64, 38 }, { 64, 54 }, { 72, 54 } }), "#386a42")
  for _, p in ipairs({ { 14, 10 }, { 12, 22 }, { 52, 8 }, { 54, 20 }, { 58, 32 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#7ab55c") end
  c:fill(c:ellipse(36, 15, 20, 3), "#e8f2ec"); c:fill(c:ellipse(18, 18, 8, 2), "#e8f2ec")
  -- river bands
  for y = 20, 52, 5 do for x = (y % 10 == 0) and 18 or 24, 54, 12 do fl(c, R(c, x, y, x + 5, y), "#7ccfd0") end end
  for _, p in ipairs({ { 22, 30 }, { 46, 34 }, { 28, 47 }, { 50, 46 }, { 20, 40 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#f4fafa"); fl(c, R(c, p[1] + 1, p[2] + 1, p[1] + 3, p[2] + 1), "#e0f0f0") end
  -- raft
  for i = 0, 3 do part(c, c:rrect(18, 42 + i * 2, 52, 43 + i * 2, 1), "#d8c060") end
  fl(c, R(c, 18, 43, 52, 43), "#f0dc80"); fl(c, R(c, 18, 47, 52, 47), "#a89030")
  for _, x in ipairs({ 24, 44 }) do fl(c, R(c, x, 42, x + 1, 48), "#8a5a35") end
  -- pole planted in the river bed
  ln(c, { { 46, 26 }, { 37, 50 } }, 2, "#e8c48a")
  fl(c, R(c, 33, 49, 40, 51), "#f4fafa")
  local _, G = gnome(c, 33, 42, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 9 }, true), arm({ 4, 6 }, { 5, 3 }, true) } })
  -- spray
  for _, p in ipairs({ { 12, 44 }, { 54, 45 }, { 20, 50 }, { 46, 50 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#fbfdfe") end
  return c
end)

-- 19 jade dragonfly (night): a green glimmer over the camp, a hushed gnome pointing
scene("r_ea_jade_dragonfly", function()
  seed = 79
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1a2848", "#22345a", "#2c4068", "#38507a" }, { dir = "v" })
  for _, p in ipairs({ { 8, 8 }, { 20, 6 }, { 55, 8 }, { 66, 14 }, { 12, 20 }, { 62, 24 }, { 30, 10 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- dark valley hills and the lair
  c:fill(c:poly({ { 0, 34 }, { 14, 22 }, { 30, 30 }, { 44, 18 }, { 58, 28 }, { 72, 20 }, { 72, 36 }, { 0, 36 } }), "#1a2a44")
  c:fill(c:poly({ { 40, 30 }, { 44, 22 }, { 48, 30 } }), "#0e1a28"); c:fill(c:poly({ { 43, 30 }, { 44, 26 }, { 45, 30 } }), "#3f7a58")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#2c4a3a"); fl(c, R(c, 0, 34, W - 1, 34), "#3a5a46")
  c:fill(c:ellipse(36, 48, 30, 4), "#34583e")
  -- tent and little fire
  part(c, c:poly({ { 60, 28 }, { 68, 42 }, { 52, 42 } }), "#8a6a44"); c:fill(c:poly({ { 60, 33 }, { 63, 42 }, { 57, 42 } }), "#f5cf6a")
  part(c, c:poly({ { 46, 42 }, { 50, 46 }, { 42, 46 } }), "#e0501f"); c:fill(c:poly({ { 46, 44 }, { 48, 46 }, { 44, 46 } }), "#ffd86a")
  -- the dragonfly with a halo and trail
  local dx, dy = 30, 14
  for a = 0, 360, 30 do local x = dx + rnd(math.cos(math.rad(a)) * 7); local y = dy + rnd(math.sin(math.rad(a)) * 5); if (x + y) % 2 == 0 then c:px(x, y, "#2c6a60") end end
  c:fill(c:ellipse(dx - 4, dy - 2, 4, 1), "#a8f0c8"); c:fill(c:ellipse(dx + 4, dy - 2, 4, 1), "#a8f0c8")
  c:fill(c:ellipse(dx - 3, dy + 1, 3, 1), "#7ad8a8"); c:fill(c:ellipse(dx + 3, dy + 1, 3, 1), "#7ad8a8")
  c:fill(R(c, dx - 1, dy - 2, dx, dy + 4), "#3fc088"); c:px(dx - 1, dy - 3, "#d8ffe8"); c:px(dx, dy - 3, "#d8ffe8")
  for _, p in ipairs({ { 38, 16 }, { 42, 18 }, { 47, 17 }, { 52, 20 }, { 24, 10 }, { 20, 12 } }) do c:px(p[1], p[2], "#8ae8b8") end
  -- gnome with a finger to the sky
  local _, G = gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 9, 17 }, true) } })
  return c
end)

-- 20 blossom fall (spring): petals on the tea tray under a cherry tree
scene("r_ea_blossom_fall", function()
  seed = 80
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#c4e0ec", "#d4e8ee", "#e4f0ee" }, { dir = "v" })
  -- teahouse wall at right
  c:fill(R(c, 36, 12, 68, 38), "#c9a96e")
  part(c, R(c, 40, 18, 64, 36), "#f6f2e4")
  for x = 40, 64, 6 do fl(c, R(c, x, 18, x, 36), "#6b3b2a") end
  fl(c, R(c, 40, 27, 64, 27), "#6b3b2a")
  part(c, c:poly({ { 52, 6 }, { 70, 14 }, { 34, 14 } }), "#4a4a5a")
  -- veranda deck
  c:fill(R(c, 0, 38, W - 1, H - 1), "#b07a45")
  for y = 41, 49, 4 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  fl(c, R(c, 0, 38, W - 1, 38), "#d9a660")
  -- cherry tree
  part(c, R(c, 6, 20, 10, 40), "#6b4a2e", { noline = true })
  part(c, c:ellipse(11, 14, 12, 8), "#f6a8c4", { shade = true })
  part(c, c:ellipse(24, 10, 9, 6), "#f4b8d0", { shade = true })
  c:fill(c:ellipse(8, 11, 3, 1), "#fbd8e4"); c:fill(c:ellipse(22, 8, 3, 1), "#fbd8e4")
  -- low table, tray, pot, cups
  part(c, R(c, 22, 40, 52, 43), "#8a5a35"); fl(c, R(c, 22, 40, 52, 40), "#a8703e")
  part(c, R(c, 28, 38, 46, 39), "#c0442e")
  part(c, c:rrect(32, 31, 41, 38, 2), "#3f6a5a", { shade = true }); fl(c, R(c, 41, 32, 43, 33), "#3f6a5a"); fl(c, R(c, 30, 33, 32, 36), "#3f6a5a")
  fl(c, R(c, 35, 29, 38, 30), "#2f5a4a")
  part(c, R(c, 44, 35, 47, 38), "#f4eee0"); part(c, R(c, 27, 35, 30, 38), "#f4eee0")
  puff(c, 36, 26, "#f4f8fa")
  gnome(c, 14, 47, { d = 1, sit = true, eyes = "happy", arms = { arm({ 3, 7 }, { 9, 9 }, true) } })
  -- petals
  seed = 90
  for i = 1, 22 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 42)
    c:px(x, y, "#f6a8c4"); if i % 3 == 0 then c:px(x + 1, y, "#fbd8e4") end
  end
  for _, p in ipairs({ { 38, 37 }, { 30, 38 }, { 42, 38 }, { 34, 39 } }) do c:px(p[1], p[2], "#f6a8c4") end
  return c
end)

-- 21 thousand gates: a tunnel of red gates glowing in the evening, a gate-keeper sweeping
scene("r_ea_thousand_gates", function()
  seed = 81
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#f0a868", "#e8825e", "#d8645e", "#a85078" }, { dir = "v" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#9a6a56")
  c:fill(c:poly({ { 36, 26 }, { 72, 54 }, { 0, 54 } }), "#c49a72")
  c:fill(c:poly({ { 36, 26 }, { 54, 54 }, { 18, 54 } }), "#d8b088")
  -- gates far to near
  for i = 1, 7 do
    local t = i / 7
    local k = 1 - t
    local hw = rnd(4 + 26 * k * k + 6 * k)
    local top = rnd(26 - 20 * k - 4 * k * k)
    local bot = rnd(27 + 14 * k)
    local pw = math.max(1, rnd(1 + 3 * k))
    local col = (i % 2 == 0) and "#e0501f" or "#d44020"
    -- inside glow
    c:fill(R(c, 36 - hw + pw, top + pw + 1, 36 + hw - pw, bot), (i == 7) and "#ffd8a0" or "#f08a50")
    c:fill(R(c, 36 - hw, top, 36 - hw + pw - 1, bot), col); c:fill(R(c, 36 + hw - pw + 1, top, 36 + hw, bot), col)
    c:fill(R(c, 36 - hw - 1, top, 36 + hw + 1, top + pw), "#2a1a10"); c:fill(R(c, 36 - hw - 1, top + 1, 36 + hw + 1, top + pw), col)
    c:fill(R(c, 36 - hw, top + pw + 2, 36 + hw, top + pw + 2 + math.max(0, pw - 1)), col)
    c:fill(R(c, 36 - hw - 1, top - 1, 36 + hw + 1, top - 1), "#2a1a10")
  end
  local _, G = gnome(c, 36, 50, { d = 1, s = 1.15, eyes = "open", arms = { arm({ -4, 7 }, { -2, 4 }, false), arm({ 4, 7 }, { 6, 3 }, true) } })
  -- broom
  ln(c, { { 44, 24 }, { 40, 46 } }, 1, "#8a5a35")
  part(c, c:poly({ { 38, 46 }, { 44, 46 }, { 46, 51 }, { 36, 51 } }), "#d9a660")
  for x = 38, 45, 2 do fl(c, R(c, x, 48, x, 51), "#a8703e") end
  for _, p in ipairs({ { 14, 44 }, { 20, 48 }, { 54, 46 }, { 60, 50 } }) do c:px(p[1], p[2], "#e8825e") end
  return c
end)

-- 22 quilt table (frost): only the head peeks from the heavy quilt, warm glow below
scene("r_ea_quilt_table", function()
  seed = 82
  local c = new()
  room(c, "#9a6a45", "#845830", 40, "#7a4a2a", "#5e3320")
  -- frosted window
  part(c, R(c, 8, 10, 24, 28), "#8ea4bd"); fl(c, R(c, 16, 10, 16, 28), "#6b3b2a"); fl(c, R(c, 8, 19, 24, 19), "#6b3b2a")
  seed = 12
  for i = 1, 10 do c:px(9 + floor(rand() * 14), 11 + floor(rand() * 16), "#fbfdfe") end
  fl(c, R(c, 8, 28, 24, 29), "#d3deea")
  -- hanging lamp
  fl(c, R(c, 52, 6, 52, 14), "#3d2a1c"); part(c, R(c, 49, 14, 55, 19), "#ffd86a"); fl(c, R(c, 50, 15, 54, 18), "#fff1c8")
  -- gnome behind the table
  gnome(c, 36, 37, { d = 1, upper = true, eyes = "shut", arms = { arm({ -4, 7 }, { -8, 3 }, true), arm({ 4, 7 }, { 8, 3 }, true) } })
  -- the quilt: top surface and drape
  part(c, c:poly({ { 12, 35 }, { 60, 35 }, { 66, 38 }, { 6, 38 } }), "#e0c488")
  c:fill(R(c, 6, 39, 66, 48), "#c0442e")
  local cols = { "#c0442e", "#3f6fb0", "#e8c48a", "#4f9a45" }
  for j = 0, 2 do for i = 0, 9 do
    local x0 = 6 + i * 6
    c:fill(R(c, x0, 39 + j * 3, x0 + 5, 41 + j * 3), cols[((i + j) % 4) + 1])
  end end
  fl(c, R(c, 6, 38, 66, 38), "#2a1a10"); fl(c, R(c, 6, 48, 66, 48), "#f4eee0")
  for i = 0, 10 do fl(c, R(c, 6 + i * 6, 48, 6 + i * 6, 49), "#f4eee0") end
  -- charcoal glow under the hem
  c:fill(R(c, 20, 49, 52, 49), "#f08a24"); fl(c, R(c, 28, 49, 44, 49), "#ffd86a")
  c:fill(c:ellipse(36, 50, 22, 1), "#c8641e")
  fl(c, R(c, 34, 40, 38, 41), "#ffd86a")
  c:px(66, 36, "#ffe08a")
  return c
end)

-- 23 plant out seedlings (rain): knee-deep in the paddy with a bundle of green shoots
scene("r_sea_plant_seedlings", function()
  seed = 83
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#8a9eb0", "#9aacba", "#aab8c4" }, { dir = "v" })
  c:fill(c:ellipse(14, 22, 26, 8), "#6a8a70"); c:fill(c:ellipse(58, 23, 24, 7), "#5e8068")
  c:fill(c:ellipse(30, 21, 14, 3), "#c8d4d4")
  c:fill(R(c, 0, 22, W - 1, H - 1), "#8aa49c")
  for y = 24, 50, 4 do fl(c, R(c, 0, y, W - 1, y), "#7a948c") end
  -- rows of seedlings in the water
  for r = 0, 3 do
    local y = 27 + r * 6 + r * r
    for x = 6 + (r % 2) * 3, 66, 7 do
      fl(c, R(c, x, y, x, y - 2), "#4e8a3c"); c:px(x - 1, y - 2, "#6ab04c"); c:px(x + 1, y - 2, "#6ab04c")
      fl(c, R(c, x - 1, y + 1, x + 1, y + 1), "#7aa098")
    end
  end
  -- gnome standing in the water
  local _, G = gnome(c, 33, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 7 }, false), arm({ 4, 7 }, { 8, 4 }, true) } })
  -- bundle in the free hand
  local bx, by = G.P(-7, 8)
  part(c, R(c, bx - 3, by - 4, bx - 1, by + 1), "#4e8a3c"); c:px(bx - 3, by - 5, "#6ab04c"); c:px(bx - 1, by - 5, "#6ab04c"); c:px(bx - 2, by - 6, "#6ab04c")
  fl(c, R(c, bx - 3, by, bx - 1, by), "#d9a660")
  fl(c, R(c, bx - 1, by - 1, bx + 1, by + 1), "#f0c8a0")
  -- water over the legs
  c:fill(R(c, 24, 43, 44, 49), "#8aa49c")
  for x = 24, 44, 3 do fl(c, R(c, x, 43, x + 1, 43), "#c8d8d4") end
  fl(c, R(c, 26, 46, 30, 46), "#a8bcb4"); fl(c, R(c, 36, 48, 42, 48), "#a8bcb4")
  local px2, py2 = G.P(8, 4)
  fl(c, R(c, px2 - 1, py2 + 3, px2 + 1, py2 + 5), "#4e8a3c")
  -- rain
  seed = 33
  for i = 1, 34 do
    local x, y = 6 + floor(rand() * 60), 5 + floor(rand() * 42)
    c:px(x, y, "#dce8f0"); c:px(x - 1, y + 1, "#dce8f0")
    if i % 3 == 0 then c:px(x - 2, y + 2, "#dce8f0") end
  end
  return c
end)

-- 24 mangosteen: a cut half shows white segments, a whole fruit shows its petals
scene("r_sea_mangosteen_count", function()
  seed = 84
  local c = new()
  day(c, 36, { cloud = 52, sky = { "#b4dcd0", "#c8e4d0", "#d8ecd0" } })
  -- tree with purple fruit
  part(c, R(c, 8, 20, 11, 38), "#6b4a2e", { noline = true })
  part(c, c:ellipse(10, 14, 13, 8), "#2f6a3a", { shade = true })
  c:fill(c:ellipse(7, 11, 3, 1), "#4e9a48")
  for _, p in ipairs({ { 6, 18 }, { 15, 17 }, { 12, 22 } }) do part(c, c:ellipse(p[1], p[2], 2, 2), "#6a2a7a"); c:px(p[1] - 1, p[2] - 1, "#a868b8") end
  -- crate with fruit
  part(c, R(c, 46, 38, 66, 48), "#b07a45"); fl(c, R(c, 46, 41, 66, 41), "#8a5a35"); fl(c, R(c, 46, 45, 66, 45), "#8a5a35")
  for _, x in ipairs({ 50, 57, 63 }) do
    part(c, c:ellipse(x, 36, 3, 3), "#5a2a6a"); c:px(x - 2, 35, "#a868b8"); fl(c, R(c, x - 1, 33, x + 1, 33), "#4e8a3c")
  end
  -- the half held up
  local _, G = gnome(c, 30, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 7 }, { -6, 3 }, false), arm({ 4, 8 }, { 9, 13 }, true, true) } })
  local hx, hy = G.P(9, 16)
  part(c, c:ellipse(hx, hy, 6, 6), "#5a2a6a")
  c:fill(c:ellipse(hx, hy, 5, 5), "#fbf6ea")
  for _, d in ipairs({ { 0, -5 }, { 5, -2 }, { 3, 4 }, { -3, 4 }, { -5, -2 } }) do ln(c, { { hx, hy }, { hx + d[1], hy + d[2] } }, 1, "#d8c8a0") end
  c:fill(c:ellipse(hx, hy, 1, 1), "#d8c8a0")
  fl(c, R(c, hx - 2, hy + 6, hx + 2, hy + 7), "#f0c8a0")
  sparkle(c, hx + 8, hy - 6)
  -- petals fruit on the ground
  part(c, c:ellipse(18, 47, 3, 2), "#5a2a6a")
  for _, p in ipairs({ { 18, 46 }, { 17, 48 }, { 19, 48 }, { 16, 47 }, { 20, 47 } }) do c:px(p[1], p[2], "#6ab04c") end
  return c
end)

for _, s2 in ipairs(DONE) do
  if not only or only == s2 then seed = 7; S[s2]() end
end

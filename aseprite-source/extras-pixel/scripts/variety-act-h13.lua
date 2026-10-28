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

-- extra helpers (h13)
local function spark(c, x, y)
  c:px(x, y, "#fff1c8"); c:px(x - 1, y, "#f5cf6a"); c:px(x + 1, y, "#f5cf6a"); c:px(x, y - 1, "#f5cf6a"); c:px(x, y + 1, "#f5cf6a")
end
local function note(c, x, y, col)
  col = col or "#f4eee0"
  c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y - 1, col); c:px(x + 1, y - 2, col); c:px(x + 1, y - 3, col); c:px(x + 2, y - 3, col)
end
local function drop(c, x, y, col) col = col or "#7cc9e0"; c:px(x, y, col); c:px(x, y + 1, col) end
local function tuft(c, x, y, col) c:px(x, y, col); c:px(x + 1, y - 1, col); c:px(x - 1, y - 1, col) end
-- acacia: umbrella tree
local function acacia(c, x, yb, w, h, col)
  part(c, R(c, x - 1, yb - h, x, yb), "#5e3f28", { noline = true })
  c:fill(c:line({ { x, yb - h + 3 }, { x - w // 2, yb - h - 1 } }, 1), "#5e3f28")
  c:fill(c:line({ { x, yb - h + 3 }, { x + w // 2, yb - h - 1 } }, 1), "#5e3f28")
  part(c, c:ellipse(x, yb - h - 2, w, 3), col or "#4e8a3c", { shade = true })
  c:fill(c:ellipse(x - 2, yb - h - 3, w // 2, 1), "#7ab55c")
end
local function sunrays(c, x, y, r, col)
  for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 1, 1 }, { -1, -1 }, { 1, -1 }, { -1, 1 } }) do
    c:px(x + d[1] * (r + 2), y + d[2] * (r + 2), col); c:px(x + d[1] * (r + 3), y + d[2] * (r + 3), col)
  end
end
local function zebra(c, x, y, d)
  local m = c:rect(x, y, x + 7, y + 3)
  part(c, m, "#f4eee0")
  for _, k in ipairs({ 1, 3, 5 }) do fl(c, R(c, x + k, y, x + k, y + 3), "#2a1a10") end
  local hx = (d > 0) and x + 8 or x - 2
  part(c, R(c, hx, y - 1, hx + 1, y + 1), "#2a1a10")
  fl(c, R(c, (d > 0) and x + 6 or x + 1, y - 1, (d > 0) and x + 7 or x + 2, y), "#f4eee0")
  fl(c, R(c, x + 1, y + 4, x + 1, y + 5), "#2a1a10"); fl(c, R(c, x + 6, y + 4, x + 6, y + 5), "#2a1a10")
end
local function wildebeest(c, x, y, d)
  part(c, R(c, x, y, x + 7, y + 3), "#6a6a70")
  local hx = (d > 0) and x + 8 or x - 2
  part(c, R(c, hx, y, hx + 1, y + 2), "#3a3a40")
  c:px((d > 0) and hx + 1 or hx, y - 1, "#e8e0c8")
  fl(c, R(c, x + 1, y + 4, x + 1, y + 5), "#3a3a40"); fl(c, R(c, x + 6, y + 4, x + 6, y + 5), "#3a3a40")
end
local function pot(c, x, yb, rx, h, col, water)
  part(c, c:ellipse(x, yb - h // 2, rx, h // 2 + 1), col, { shade = true })
  fl(c, R(c, x - rx + 2, yb - h, x + rx - 2, yb - h), "#3a2418")
  if water then fl(c, R(c, x - rx + 3, yb - h, x + rx - 3, yb - h), water) end
end
local function bubble(c, x0, y0, x1, y1, tx, ty)
  part(c, c:rrect(x0, y0, x1, y1, 3), "#f4eee0")
  c:fill(c:poly({ { tx - 2, y1 }, { tx + 2, y1 }, { tx, ty } }), "#f4eee0")
end

local S = {}

-- 1. spin_tops: two carvers face off over a flat stone, seed-pod tops spinning
function S.r_wca_spin_tops()
  seed = 61
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#c9a46a")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#b8905a") end
  part(c, R(c, 8, 17, 36, 18), "#6b4a2e")
  for i = 0, 5 do part(c, c:ellipse(11 + i * 5, 14, 2, 2), (i % 2 == 0) and "#8a5a35" or "#5e8a44") end
  fl(c, R(c, 46, 7, 66, 7), "#6b4a2e")
  for i = 0, 3 do fl(c, R(c, 49 + i * 5, 8, 49 + i * 5, 11), "#e8c48a"); part(c, c:ellipse(49 + i * 5, 13, 1, 2), "#8a5a35") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#a87a4a")
  for _, p in ipairs({ { 8, 45 }, { 20, 49 }, { 52, 48 }, { 66, 44 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#8a5a35") end
  part(c, c:ellipse(36, 46, 14, 3), "#9aa0a6", { shade = true })
  -- tops: one spinning true, one tilting
  part(c, c:poly({ { 29, 36 }, { 35, 36 }, { 32, 44 } }), "#b8661a"); fl(c, R(c, 30, 38, 34, 38), "#e8c48a"); fl(c, R(c, 32, 33, 32, 35), "#6b3b2a")
  part(c, c:poly({ { 40, 37 }, { 46, 39 }, { 41, 44 } }), "#5e8a44"); fl(c, R(c, 42, 39, 44, 40), "#e8c48a")
  for _, p in ipairs({ { 27, 40 }, { 26, 42 }, { 37, 40 }, { 48, 43 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:px(31, 31, "#f5cf6a"); c:px(33, 30, "#f5cf6a")
  gnome(c, 12, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 5 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  gnome(c, 60, 47, { d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ -4, 7 }, { -8, 6 }, true), arm({ 4, 7 }, { 5, 11 }, false) } })
  finish(c, "r_wca_spin_tops")
end

-- 2. canopy_calls: eyes shut under the great trees, notebook open, a bird singing
function S.r_wca_canopy_calls()
  seed = 62
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 42), { "#1f4a2e", "#2a5e38", "#376f40", "#4a8248", "#5e9650" }, { dir = "v" })
  c:fill(c:ellipse(36, 4, 40, 10), "#1a3f28"); c:fill(c:ellipse(10, 10, 14, 8), "#1f4a2e"); c:fill(c:ellipse(62, 9, 14, 8), "#1f4a2e")
  for i = 0, 9 do c:px(10 + i * 6, 12 + (i % 3) * 3, "#7ab55c"); c:px(11 + i * 6, 12 + (i % 3) * 3, "#7ab55c") end
  for _, x in ipairs({ 20, 28, 36, 44 }) do c:fill(c:line({ { x, 9 }, { x - 5, 46 } }, 1), "#8fc462") end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#3d5a34")
  c:fill(R(c, 0, 43, W - 1, 43), "#4e6e3e")
  part(c, R(c, 6, 6, 13, 48), "#5e3f28", { shade = true }); fl(c, R(c, 9, 10, 9, 44), "#4a2c1a")
  part(c, R(c, 57, 6, 64, 48), "#6b4a2e", { shade = true }); fl(c, R(c, 61, 10, 61, 44), "#4a2c1a")
  c:fill(c:line({ { 13, 24 }, { 24, 22 } }, 2), "#5e3f28")
  c:fill(c:line({ { 57, 20 }, { 47, 18 } }, 2), "#6b4a2e")
  -- bird on the right branch
  part(c, c:ellipse(49, 15, 3, 2), "#4a8fd0"); fl(c, R(c, 52, 14, 52, 14), "#f4c040"); c:px(48, 14, INK)
  fl(c, R(c, 45, 16, 46, 17), "#3a6fb0")
  for i = 0, 2 do c:px(53 + i, 11 + (i % 2) * 2, "#f4eee0"); c:px(55 + i, 9 + (i % 2) * 2, "#f4eee0") end
  note(c, 39, 11); note(c, 31, 14, "#f5cf6a")
  c:px(22, 21, "#f4eee0"); c:px(21, 20, "#f4eee0")
  for _, p in ipairs({ { 18, 47 }, { 50, 46 }, { 28, 48 } }) do tuft(c, p[1], p[2], "#5e8a44") end
  part(c, R(c, 26, 42, 41, 46), "#8a5a35"); fl(c, R(c, 27, 42, 40, 42), "#a8703e")
  local _, G = gnome(c, 34, 41, { d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 8 }, { 7, 6 }, true) } })
  local nx, ny = G.P(5, 7)
  part(c, R(c, nx, ny - 1, nx + 5, ny + 3), "#f4eee0"); fl(c, R(c, nx + 1, ny, nx + 4, ny), "#8a4a34"); fl(c, R(c, nx + 1, ny + 2, nx + 3, ny + 2), "#8a4a34")
  fl(c, R(c, nx - 1, ny + 1, nx, ny + 2), "#f0c8a0")
  -- ear arcs
  for _, p in ipairs({ { 41, 29 }, { 42, 30 }, { 42, 31 }, { 41, 32 } }) do c:px(p[1], p[2], "#f4eee0") end
  finish(c, "r_wca_canopy_calls")
end

-- 3. talking_drum: hourglass drum squeezed under the arm, sound rings leaving it
function S.r_wca_talking_drum()
  seed = 63
  local c = new()
  day(c, 34, { grass = "#c9a96e", edge = "#d9bc84", hill = "#b89a58", hill2 = "#a88a4a", cloud = 56, sky = { "#e8d8a8", "#f0e2b4", "#f4ecc4" } })
  -- indigo cloths hanging behind
  fl(c, R(c, 4, 9, 68, 9), "#6b4a2e")
  for i, x in ipairs({ 8, 22, 36, 50, 60 }) do
    local w = (i % 2 == 0) and 7 or 9
    fl(c, R(c, x, 10, x + w, 24 + (i % 3) * 2), (i % 2 == 0) and "#2a4a8a" or "#a8442e")
    for y = 12, 22, 4 do fl(c, R(c, x + 1, y, x + w - 1, y), "#f4eee0") end
  end
  part(c, c:poly({ { 25, 31 }, { 31, 34 }, { 39, 34 }, { 46, 31 }, { 46, 43 }, { 39, 40 }, { 31, 40 }, { 25, 43 } }), "#a8582f")
  part(c, c:ellipse(25, 37, 1, 6), "#e8c48a"); part(c, c:ellipse(46, 37, 1, 6), "#e8c48a")
  c:fill(c:line({ { 27, 33 }, { 31, 39 }, { 34, 35 }, { 38, 39 }, { 41, 35 }, { 44, 41 } }, 1), "#f4eee0")
  c:fill(c:line({ { 27, 41 }, { 31, 35 }, { 34, 39 }, { 38, 35 }, { 41, 39 }, { 44, 33 } }, 1), "#e8c48a")
  gnome(c, 20, 47, { d = 1, eyes = "happy", arms = { arm({ 3, 9 }, { 9, 6 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  -- the drum rests against the body; the free arm swings a curved stick
  c:fill(c:line({ { 50, 44 }, { 51, 36 }, { 49, 32 } }, 1), "#6b3b2a"); c:fill(R(c, 48, 31, 49, 32), "#b8661a")
  fl(c, R(c, 50, 43, 52, 46), "#f0c8a0")
  for k = 0, 2 do
    local x = 54 + k * 3
    c:fill(c:line({ { x, 37 - k }, { x + 1, 35 - k }, { x + 1, 33 - k }, { x, 31 - k } }, 1), (k == 0) and "#7a4a2a" or "#a8582f")
  end
  note(c, 58, 24, "#2a4a8a"); note(c, 63, 19, "#a8442e")
  for _, p in ipairs({ { 8, 48 }, { 62, 47 }, { 38, 49 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  finish(c, "r_wca_talking_drum")
end

-- 4. goldsand_shells: golden beach, a shell held up to the light, tray with hollows
function S.r_wca_goldsand_shells()
  seed = 64
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#7cc9d8", "#6ab8cc", "#58a8c4", "#4898b8" }, { dir = "v" })
  c:fill(R(c, 0, 12, W - 1, 12), "#a8dce8")
  c:fill(c:ellipse(60, 8, 4, 4), "#fff1c8")
  c:fill(R(c, 0, 23, W - 1, H - 1), "#e8c878")
  c:fill(R(c, 0, 23, W - 1, 25), "#c8a458")
  for x = 5, 68, 3 do c:px(x, 23 + ((x * 7) % 3), "#fbfdfe") end
  for x = 4, 68, 6 do c:fill(R(c, x, 19, x + 3, 19), "#fbfdfe") end
  for x = 8, 66, 9 do c:px(x, 16, "#fbfdfe") end
  -- far jetty
  part(c, R(c, 40, 18, 64, 20), "#8a5a35")
  for _, x in ipairs({ 42, 50, 58, 63 }) do fl(c, R(c, x, 21, x, 23), "#5e3f28") end
  for _, p in ipairs({ { 20, 8 }, { 28, 6 } }) do c:px(p[1], p[2], "#fbfdfe"); c:px(p[1] + 1, p[2] - 1, "#fbfdfe"); c:px(p[1] + 2, p[2], "#fbfdfe") end
  -- shell line
  local cols = { "#f4eee0", "#e8a8a8", "#e8a317", "#c4623a" }
  for i = 0, 11 do
    local x = 8 + i * 5
    part(c, c:ellipse(x, 29 + (i % 2), 2, 1), cols[(i % 4) + 1], { noline = true }); c:px(x, 29 + (i % 2), "#8a5a35")
  end
  for _, p in ipairs({ { 10, 41 }, { 30, 47 }, { 60, 33 }, { 46, 49 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2]), "#c8a458") end
  -- tray with hollows
  part(c, R(c, 36, 39, 64, 47), "#8a5a35")
  fl(c, R(c, 37, 40, 63, 40), "#a8703e")
  for i = 0, 5 do
    local x = 40 + i * 4
    for j = 0, 1 do
      c:fill(c:ellipse(x, 42 + j * 3, 1, 1), "#4a2c1a")
      if (i + j) % 2 == 0 then c:px(x, 42 + j * 3, cols[(i + j) % 4 + 1]) end
    end
  end
  local _, G = gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(9, 16)
  part(c, c:ellipse(hx, hy - 1, 3, 2), "#e8a8a8"); c:px(hx - 1, hy - 1, "#f4eee0"); c:px(hx + 1, hy, "#c4623a")
  spark(c, hx + 5, hy - 5); spark(c, hx - 3, hy - 7)
  finish(c, "r_wca_goldsand_shells")
end

-- 5. ripe_shea: four fallen fruits, three green and one soft golden one
function S.r_wca_ripe_shea()
  seed = 65
  local c = new()
  day(c, 34, { sky = { "#f0e0a8", "#f4e8b8", "#f8f0c8" }, hill = "#b89a58", hill2 = "#a88a4a", grass = "#c8b468", edge = "#dcc87c", cloud = false })
  c:fill(c:ellipse(12, 12, 4, 4), "#ffe070"); sunrays(c, 12, 12, 4, "#ffe070")
  -- shea tree
  part(c, R(c, 50, 18, 54, 48), "#5e3f28", { shade = true }); fl(c, R(c, 52, 22, 52, 44), "#4a2c1a")
  c:fill(c:line({ { 52, 22 }, { 40, 16 } }, 2), "#5e3f28"); c:fill(c:line({ { 53, 22 }, { 64, 15 } }, 2), "#5e3f28")
  part(c, c:ellipse(51, 12, 18, 8), "#3f7a3a", { shade = true }); part(c, c:ellipse(60, 15, 8, 5), "#4e8a3c", { shade = true })
  c:fill(c:ellipse(44, 9, 5, 2), "#6aa84c")
  for _, p in ipairs({ { 44, 14 }, { 56, 17 }, { 36, 13 } }) do part(c, c:ellipse(p[1], p[2], 1, 2), "#8ab84c", { noline = true }) end
  for i = 0, 3 do
    local x = 28 + i * 8
    local ripe = (i == 2)
    part(c, c:ellipse(x, 44, 3, 3), ripe and "#d8d058" or "#3f7a3a")
    c:px(x - 1, 43, ripe and "#fff0a0" or "#6aa84c")
    if ripe then c:px(x + 1, 45, "#c8a028") end
  end
  spark(c, 44, 38); spark(c, 49, 39)
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 4 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  for _, p in ipairs({ { 22, 48 }, { 60, 49 }, { 38, 49 }, { 8, 49 } }) do tuft(c, p[1], p[2], "#a89048") end
  finish(c, "r_wca_ripe_shea")
end

-- 6. tuned_shaker: three beaded gourd shakers, one raised to the ear
function S.r_wca_tuned_shaker()
  seed = 66
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#b8905a")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 44), "#a8804a") end
  fl(c, R(c, 0, 8, W - 1, 8), "#6b4a2e")
  for i = 0, 3 do
    local x = 12 + i * 15
    fl(c, R(c, x, 9, x, 12), "#e8c48a")
    part(c, c:ellipse(x, 15, 3, 3), "#c8a028"); part(c, c:ellipse(x, 11, 1, 2), "#c8a028", { noline = true })
  end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#8a5a35")
  local _, G = gnome(c, 22, 49, { s = 1.4, d = 1, upper = true, eyes = "shut", arms = { arm({ 4, 7 }, { 8, 16 }, true, true), arm({ -4, 6 }, { 6, 7 }, false, true) } })
  -- raised shaker beside the ear
  local sx, sy = G.P(9, 18)
  part(c, c:ellipse(sx, sy - 1, 3, 4), "#c8a028"); fl(c, R(c, sx - 1, sy - 6, sx, sy - 5), "#8a5a35")
  for _, p in ipairs({ { 0, -2 }, { 2, -1 }, { 0, 1 }, { -2, 0 }, { 2, 2 }, { -1, -3 } }) do c:px(sx + p[1], sy + p[2], "#c4423a") end
  fl(c, R(c, sx - 1, sy + 3, sx + 1, sy + 5), "#f0c8a0")
  c:fill(c:line({ { sx + 6, sy - 5 }, { sx + 8, sy - 3 }, { sx + 6, sy - 1 } }, 1), "#f4eee0")
  note(c, sx + 9, sy - 6, "#f5cf6a")
  -- bench with two idle shakers
  part(c, R(c, 4, 38, 68, 42), "#a8703e"); fl(c, R(c, 4, 38, 68, 38), "#d9a660")
  fl(c, R(c, 6, 43, 8, 49), "#6b3b2a"); fl(c, R(c, 62, 43, 64, 49), "#6b3b2a")
  for i, x in ipairs({ 44, 56 }) do
    part(c, c:ellipse(x, 35, 4, 3), (i == 1) and "#c8a028" or "#8aa84c")
    fl(c, R(c, x + 4, 34, x + 8, 35), "#8a5a35")
    for _, p in ipairs({ { -2, -1 }, { 0, 0 }, { 2, -1 }, { -1, 1 }, { 1, 1 } }) do c:px(x + p[1], 35 + p[2], "#f4eee0") end
  end
  c:px(41, 37, "#e46a9b"); c:px(52, 37, "#3f8fb0"); c:px(63, 37, "#e8a317")
  finish(c, "r_wca_tuned_shaker")
end

-- 7. pangolin_hollow: night, lantern held up to a great trunk with four hollows
function S.r_wca_pangolin_hollow()
  seed = 67
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#141a38", "#1a2248", "#222c58", "#2c3868" }, { dir = "v" })
  for _, p in ipairs({ { 8, 8 }, { 14, 20 }, { 24, 10 }, { 66, 10 }, { 62, 24 }, { 20, 28 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(12, 11, 4, 4), "#f5e6a8"); c:fill(c:ellipse(14, 10, 3, 3), "#1a2248")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#253f33")
  part(c, R(c, 29, 5, 62, 48), "#5e3f28", { shade = true })
  for _, x in ipairs({ 32, 44, 58 }) do fl(c, R(c, x, 6, x, 46), "#4a2c1a") end
  fl(c, R(c, 29, 44, 62, 48), "#4a2c1a")
  part(c, c:ellipse(46, 6, 22, 5), "#1f4a2e", { shade = true })
  for _, h in ipairs({ { 38, 18 }, { 53, 18 }, { 38, 35 }, { 53, 35 } }) do
    part(c, c:ellipse(h[1], h[2], 5, 6), "#140a06")
    fl(c, R(c, h[1] - 3, h[2] - 4, h[1] + 3, h[2] - 4), "#2a1a10")
  end
  -- pangolin curled in the lower right hollow
  part(c, c:ellipse(53, 36, 4, 4), "#a8805a")
  for _, p in ipairs({ { -2, -1 }, { 0, -2 }, { 2, -1 }, { -1, 1 }, { 1, 1 }, { 0, 3 }, { -3, 2 } }) do c:px(53 + p[0 + 1], 36 + p[2], "#6b4a2e") end
  c:px(51, 38, "#e8c48a"); c:px(52, 38, "#2a1a10")
  -- warm lantern light on the ground and trunk
  local lx, ly = 24, 33
  c:fill(c:ellipse(18, 47, 14, 2), "#4a6a4a")
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 12 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 24, 28, 24, 30), "#3d2a1c")
  part(c, R(c, 22, 31, 26, 36), "#ffd86a", { cres = 1 }); fl(c, R(c, 23, 32, 25, 34), "#fff1c8"); fl(c, R(c, 22, 30, 26, 30), "#3d2a1c")
  for _, p in ipairs({ { 28, 34 }, { 28, 38 }, { 30, 31 }, { 20, 38 }, { 29, 41 } }) do c:px(p[1], p[2], "#f8c070") end
  finish(c, "r_wca_pangolin_hollow")
end

-- 8. pound_yam: a long pestle, a tall mortar, the cook turning the yam
function S.r_wca_pound_yam()
  seed = 68
  local c = new()
  day(c, 33, { grass = "#c9a96e", edge = "#d9bc84", hill = "#b89a58", hill2 = "#a88a4a", cloud = 58, sky = { "#e8d8a8", "#f0e2b4", "#f4ecc4" } })
  -- thatched hut far right
  part(c, R(c, 56, 24, 68, 38), "#b8744a"); part(c, c:poly({ { 62, 12 }, { 70, 25 }, { 54, 25 } }), "#c8a028")
  part(c, R(c, 60, 30, 64, 38), "#4a2c1a")
  -- mortar
  part(c, c:poly({ { 31, 31 }, { 47, 31 }, { 44, 38 }, { 45, 47 }, { 33, 47 }, { 34, 38 } }), "#8a5a35", { shade = true })
  c:fill(c:ellipse(39, 31, 8, 2), "#4a2c1a"); c:fill(c:ellipse(39, 31, 6, 1), "#f4eee0")
  fl(c, R(c, 35, 40, 43, 40), "#6b3b2a")
  -- yam pile
  part(c, c:ellipse(16, 47, 5, 2), "#e8d8b0"); part(c, c:ellipse(22, 48, 3, 1), "#c8a878")
  -- pestle
  part(c, R(c, 35, 9, 37, 31), "#c08a52")
  part(c, R(c, 34, 24, 38, 27), "#a8703e")
  gnome(c, 26, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 16 }, true), arm({ 4, 7 }, { 9, 11 }, true) } })
  gnome(c, 54, 47, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 7 }, { -8, 5 }, true) } })
  for _, p in ipairs({ { 31, 27 }, { 43, 27 }, { 47, 29 }, { 30, 29 } }) do c:px(p[1], p[2], "#f4f8fa"); c:px(p[1] + (p[1] > 39 and 1 or -1), p[2] - 1, "#f4f8fa") end
  c:px(40, 27, "#f4eee0"); c:px(41, 26, "#f4eee0")
  finish(c, "r_wca_pound_yam")
end

-- 9. haul_dugout: storm coming, canoe rolled up the beach on logs
function S.r_wca_haul_dugout()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#3a2860", "#4a3274", "#5e3e86", "#7a5498", "#9a6aa4" }, { dir = "v" })
  c:fill(c:ellipse(18, 8, 18, 5), "#2a1c48"); c:fill(c:ellipse(52, 6, 20, 5), "#2a1c48"); c:fill(c:ellipse(36, 12, 12, 3), "#34255a")
  -- lightning
  c:fill(c:line({ { 60, 10 }, { 56, 16 }, { 60, 17 }, { 55, 24 } }, 1), "#ffe880")
  c:fill(R(c, 0, 27, W - 1, 35), "#3a3a7a")
  for x = 3, 66, 7 do c:fill(R(c, x, 29 + (x % 3) * 2, x + 3, 29 + (x % 3) * 2), "#d8d8f0") end
  c:fill(R(c, 0, 36, W - 1, H - 1), "#c8a468")
  c:fill(R(c, 0, 36, W - 1, 38), "#a88a58")
  for x = 4, 66, 4 do c:px(x, 37, "#e8dcc0") end
  for x = 8, 64, 8 do c:px(x, 40, "#8a6a3a") end
  -- logs under canoe
  for _, x in ipairs({ 34, 44, 54 }) do part(c, c:ellipse(x, 46, 3, 2), "#8a5a35"); c:px(x, 46, "#e8c48a") end
  -- canoe hull
  part(c, c:poly({ { 28, 37 }, { 64, 35 }, { 66, 38 }, { 62, 44 }, { 32, 45 }, { 26, 40 } }), "#a8582f", { shade = true })
  c:fill(R(c, 31, 37, 62, 38), "#4a2c1a")
  fl(c, R(c, 31, 41, 63, 41), "#8a4220")
  c:fill(R(c, 64, 34, 66, 35), "#e8c48a")
  gnome(c, 18, 47, { s = 1.2, d = 1, walk = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 10, 10 }, true), arm({ -4, 7 }, { 8, 7 }, true) } })
  for _, p in ipairs({ { 6, 44 }, { 10, 40 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#f4eee0") end
  c:px(25, 33, "#f4eee0"); c:px(24, 36, "#f4eee0")
  finish(c, "r_wca_haul_dugout")
end

-- 10. spider_stories: night in the Hollow, the old silverback spider tells a tale
function S.r_wca_spider_stories()
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 42), { "#161a34", "#1c2040", "#222850" }, { dir = "v" })
  part(c, R(c, 5, 5, 14, 48), "#5e3f28", { shade = true }); fl(c, R(c, 10, 8, 10, 46), "#4a2c1a")
  part(c, R(c, 60, 5, 68, 48), "#5e3f28", { shade = true })
  c:fill(R(c, 0, 43, W - 1, H - 1), "#2c3a30")
  -- web
  local wx, wy = 52, 24
  for _, d in ipairs({ { 16, 0 }, { -16, 0 }, { 0, 17 }, { 0, -17 }, { 11, 11 }, { -11, 11 }, { 11, -11 }, { -11, -11 } }) do
    c:fill(c:line({ { wx, wy }, { wx + d[1], wy + d[2] } }, 1), "#8a94b0")
  end
  for _, r in ipairs({ 6, 11, 16 }) do c:fill(c:ellipse(wx, wy, r, r):cut(c:ellipse(wx, wy, r - 1, r - 1)), "#8a94b0") end
  -- spider: silverback
  local sx, sy = 52, 26
  for _, d in ipairs({ { -8, -5 }, { -9, -1 }, { -8, 4 }, { -6, 8 }, { 8, -5 }, { 9, -1 }, { 8, 4 }, { 6, 8 } }) do
    c:fill(c:line({ { sx, sy }, { sx + d[1], sy + d[2] } }, 1), "#2a1a30")
  end
  part(c, c:ellipse(sx, sy + 2, 5, 4), "#c8ccd8"); fl(c, R(c, sx - 1, sy, sx + 1, sy + 4), "#e8ecf4")
  part(c, c:ellipse(sx, sy - 3, 3, 2), "#8a90a0")
  c:px(sx - 1, sy - 3, "#ffd86a"); c:px(sx + 1, sy - 3, "#ffd86a")
  -- story bubble above the gnome
  bubble(c, 17, 8, 38, 22, 24, 27)
  c:fill(c:ellipse(24, 14, 3, 3), "#f5cf6a")
  c:fill(c:poly({ { 31, 19 }, { 35, 19 }, { 33, 11 } }), "#c0442e"); c:fill(R(c, 30, 19, 36, 19), "#8e2e1e")
  c:px(28, 11, "#f5cf6a")
  -- listener on a log
  part(c, R(c, 14, 44, 40, 47), "#6b4a2e"); fl(c, R(c, 15, 44, 39, 44), "#8a5a35")
  gnome(c, 26, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 6, 5 }, true) } })
  for _, p in ipairs({ { 44, 12 }, { 20, 33 }, { 42, 36 }, { 63, 42 }, { 38, 30 } }) do c:px(p[1], p[2], "#e8e050"); c:px(p[1] + 1, p[2], "#8a9a30") end
  finish(c, "r_wca_spider_stories")
end

-- 11. library_roof: dusk on the flat mud roof, over the river and the town, a scroll between two friends
function S.r_wca_library_roof()
  seed = 71
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 31), { "#3b2f66", "#4e3a78", "#7a4a88", "#b45a7c", "#e8825e", "#f0a868" }, { dir = "v" })
  for _, p in ipairs({ { 12, 7 }, { 30, 5 }, { 58, 9 }, { 66, 18 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(40, 31, 6, 6):clip(R(c, 0, 0, W, 30)), "#ffd86a")
  -- town of flat roofs
  for _, b in ipairs({ { 14, 26, 8, 7 }, { 24, 24, 7, 9 }, { 33, 27, 6, 6 }, { 48, 25, 9, 8 }, { 58, 27, 8, 6 } }) do
    fl(c, R(c, b[1], b[2], b[1] + b[3], 33), "#5a3a5a"); c:px(b[1] + 2, b[2] + 3, "#ffd86a")
  end
  c:fill(R(c, 0, 33, W - 1, 38), "#8a5a7a")
  for x = 4, 66, 6 do c:fill(R(c, x, 35, x + 3, 35), "#f0a868"); c:fill(R(c, x + 2, 37, x + 5, 37), "#e8825e") end
  -- roof
  part(c, R(c, 0, 38, W - 1, H - 1), "#b08a5a")
  fl(c, R(c, 0, 38, W - 1, 39), "#c8a470")
  for _, x in ipairs({ 5, 61 }) do
    part(c, c:poly({ { x, 38 }, { x + 1, 22 }, { x + 5, 22 }, { x + 6, 38 } }), "#c8a470")
    for _, y in ipairs({ 26, 31, 36 }) do c:px(x - 1, y, "#4a2c1a"); c:px(x + 7, y, "#4a2c1a") end
    fl(c, R(c, x + 2, 19, x + 3, 21), "#b08a5a"); c:px(x + 2, 18, "#f4eee0")
  end
  -- mat
  part(c, R(c, 12, 41, 58, 48), "#c0442e")
  for x = 14, 56, 5 do fl(c, R(c, x, 41, x + 1, 48), "#f4eee0") end
  gnome(c, 24, 42, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 8, 8 }, true, true) } })
  gnome(c, 48, 42, { d = -1, sit = true, hat = "#3f6fb0", eyes = "happy", arms = { arm({ -3, 8 }, { -8, 8 }, true, true) } })
  part(c, R(c, 31, 32, 40, 36), "#f4eee0"); fl(c, R(c, 32, 33, 39, 33), "#8a4a34"); fl(c, R(c, 32, 35, 37, 35), "#8a4a34")
  fl(c, R(c, 30, 31, 31, 37), "#d9bc84"); fl(c, R(c, 40, 31, 41, 37), "#d9bc84")
  finish(c, "r_wca_library_roof")
end

-- 12. baobab_tales: the vast baobab, stallholders trading stories in its shade
function S.r_wca_baobab_tales()
  seed = 72
  local c = new()
  day(c, 36, { grass = "#c8b468", edge = "#dcc87c", hill = "#b89a58", hill2 = "#a88a4a", cloud = 52, sky = { "#c8e0e0", "#d8e8d8", "#e8ecd0" } })
  -- shade patch
  c:fill(c:ellipse(40, 46, 34, 5), "#a89048")
  -- baobab
  local tr = c:ellipse(19, 40, 17, 11):add(c:rect(9, 17, 29, 40)):add(c:ellipse(19, 24, 12, 8))
  part(c, tr, "#a8805a", { shade = true })
  for _, p in ipairs({ { 10, 28, 4 }, { 14, 24, 3 }, { 22, 27, 4 }, { 26, 33, 3 }, { 12, 41, 4 }, { 24, 43, 4 }, { 16, 47, 5 } }) do c:fill(R(c, p[1], p[2], p[1] + p[3], p[2]), "#8a6a46") end
  c:fill(c:ellipse(18, 34, 3, 2), "#5e3f28")
  for _, b in ipairs({ { 10, 15, 4, 8 }, { 19, 14, 20, 6 }, { 28, 15, 34, 9 } }) do c:fill(c:line({ { b[1], b[2] }, { b[3], b[4] } }, 3), "#8a6a46") end
  for _, p in ipairs({ { 6, 8 }, { 20, 7 }, { 34, 10 } }) do part(c, c:ellipse(p[1], p[2], 6, 3), "#4e8a3c", { shade = true }) end
  -- market goods
  part(c, c:ellipse(44, 46, 4, 2), "#c4623a"); part(c, c:ellipse(66, 47, 3, 2), "#e8a317")
  for i = 0, 2 do c:fill(c:ellipse(43 + i * 2, 44, 1, 1), "#e8a317") end
  gnome(c, 46, 47, { d = -1, eyes = "happy", arms = { arm({ -4, 8 }, { -9, 14 }, true), arm({ 4, 7 }, { 8, 12 }, false) } })
  gnome(c, 60, 44, { d = -1, sit = true, hat = "#4f9a45", eyes = "open", arms = { arm({ -3, 8 }, { -6, 5 }, true) } })
  note(c, 38, 24, "#6b3b2a")
  c:fill(R(c, 36, 28, 37, 28), "#f4eee0")
  finish(c, "r_wca_baobab_tales")
end

-- 13. cool_jar: heat outside, a sweating clay jar in deep shade, drinking from the ladle
function S.r_wca_cool_jar()
  seed = 73
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#ffe9a0", "#fff0b4", "#fff4c8", "#fff8d8" }, { dir = "v" })
  c:fill(c:ellipse(60, 12, 5, 5), "#ffd040"); sunrays(c, 60, 12, 5, "#ffd040")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#e8d098")
  for x = 46, 66, 5 do c:fill(R(c, x, 30, x + 2, 30), "#f0b858"); c:fill(R(c, x + 1, 33, x + 3, 33), "#f0b858"); c:fill(R(c, x, 36, x + 2, 36), "#f0b858") end
  -- shade shelter (deep shade)
  c:fill(R(c, 5, 14, 46, 49), "#5e4a3a")
  c:fill(R(c, 5, 14, 46, 18), "#4a382c")
  part(c, c:poly({ { 5, 14 }, { 8, 6 }, { 46, 6 }, { 49, 14 } }), "#c8a028")
  for x = 10, 44, 4 do fl(c, R(c, x, 8, x, 13), "#a88020") end
  part(c, R(c, 5, 14, 6, 48), "#6b4a2e", { noline = true }); part(c, R(c, 45, 14, 46, 48), "#6b4a2e", { noline = true })
  -- jar
  part(c, c:ellipse(34, 40, 8, 8), "#b8663a", { shade = true })
  part(c, R(c, 29, 29, 39, 32), "#a8582f"); fl(c, R(c, 28, 28, 40, 28), "#6b3b2a")
  for _, p in ipairs({ { 30, 37 }, { 36, 35 }, { 38, 41 }, { 31, 43 }, { 34, 46 } }) do drop(c, p[1], p[2], "#a8e0f0") end
  -- ladle on its string
  fl(c, R(c, 40, 18, 40, 28), "#e8c48a")
  fl(c, R(c, 39, 28, 41, 28), "#8a5a35")
  gnome(c, 16, 47, { d = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 7, 13 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  part(c, c:ellipse(25, 33, 2, 2), "#8a5a35"); c:fill(R(c, 20, 34, 24, 34), "#8a5a35"); c:px(25, 32, "#a8e0f0")
  for _, p in ipairs({ { 27, 38 }, { 24, 30 } }) do drop(c, p[1], p[2]) end
  finish(c, "r_wca_cool_jar")
end

-- 14. roast_beans: ceremony hut, beans shaken in a long-handled pan, fragrant smoke
function S.r_esa_roast_beans()
  seed = 74
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#c8a070")
  for y = 4, 36, 6 do fl(c, R(c, 0, y, W - 1, y), "#b88a5a") end
  part(c, R(c, 8, 10, 22, 24), "#6ab8d8"); fl(c, R(c, 15, 10, 15, 24), "#8a5a35"); fl(c, R(c, 8, 17, 22, 17), "#8a5a35")
  fl(c, R(c, 8, 8, 22, 9), "#a8703e")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#6a5438")
  for i = 0, 22 do local x = 3 + (i * 3) % 66; c:fill(R(c, x, 41 + (i * 5) % 8, x, 43 + (i * 5) % 8), "#4e8a3c"); c:px(x + 1, 42 + (i * 5) % 8, "#7ab55c") end
  -- jebena and cups
  part(c, c:poly({ { 56, 30 }, { 62, 30 }, { 64, 40 }, { 54, 40 } }), "#2a2a30"); fl(c, R(c, 57, 28, 61, 29), "#2a2a30"); c:px(59, 27, "#2a2a30")
  c:fill(c:line({ { 55, 32 }, { 51, 28 } }, 1), "#2a2a30"); c:fill(c:line({ { 63, 32 }, { 65, 36 }, { 63, 39 } }, 1), "#2a2a30")
  for i = 0, 2 do part(c, R(c, 40 + i * 5, 46, 42 + i * 5, 48), "#f4eee0") end
  -- brazier and pan
  part(c, c:poly({ { 38, 38 }, { 50, 38 }, { 48, 47 }, { 40, 47 } }), "#3a3a42")
  c:fill(R(c, 40, 38, 48, 38), "#e0501f"); c:px(42, 38, "#ffd86a"); c:px(46, 38, "#ffd86a")
  c:fill(c:line({ { 44, 36 }, { 20, 33 } }, 1), "#6b3b2a")
  part(c, c:ellipse(44, 35, 6, 2), "#4a4a52")
  for _, x in ipairs({ 41, 43, 45, 47 }) do c:px(x, 34, "#6b3b2a") end
  gnome(c, 14, 43, { d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 8 }, { 8, 5 }, true, true) } })
  fl(c, R(c, 20, 32, 22, 34), "#f0c8a0")
  -- smoke
  for i, p in ipairs({ { 44, 31 }, { 46, 27 }, { 44, 23 }, { 47, 19 }, { 50, 15 }, { 54, 12 } }) do
    fl(c, c:ellipse(p[1], p[2], 2, 1), (i % 2 == 0) and "#e8ecf0" or "#cfdcdc")
  end
  finish(c, "r_esa_roast_beans")
end

-- 15. flamingo_pose: one-legged in the pink shallows, a flamingo copying
function S.r_esa_flamingo_pose()
  seed = 75
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#f8d8c8", "#f8e0d0", "#fceadc" }, { dir = "v" })
  c:fill(c:ellipse(14, 9, 8, 2), "#fffaf0"); c:fill(c:ellipse(18, 7, 5, 2), "#fffaf0")
  c:fill(R(c, 0, 21, W - 1, H - 1), "#e8a8b8")
  c:bands(R(c, 0, 21, W - 1, H - 1), { "#f0b8c4", "#e8a8b8", "#e098ac", "#d88aa0" }, { dir = "v" })
  c:fill(R(c, 0, 21, W - 1, 21), "#fff0e8")
  -- far flock
  for i = 0, 10 do
    local x = 6 + i * 6
    c:fill(R(c, x, 22 + (i % 2), x + 2, 23 + (i % 2)), "#f06890"); c:px(x + 2, 21 + (i % 2), "#f06890"); c:px(x, 25 + (i % 2), "#c05878")
  end
  local function flamingo(x, yw, L)
    local by = yw - L - 2
    fl(c, R(c, x, by + 2, x, yw), "#d84870")
    fl(c, R(c, x + 1, by + 2, x + 1, by + 3), "#d84870"); fl(c, R(c, x + 2, by + 3, x + 2, by + 4), "#d84870")
    c:fill(c:line({ { x - 3, by - 1 }, { x - 5, by - 4 }, { x - 3, by - 6 }, { x - 5, by - 8 - L // 3 } }, 2), "#f06890")
    part(c, c:ellipse(x, by, 5, 2), "#f06890")
    fl(c, R(c, x - 1, by, x + 2, by + 1), "#d84870"); c:px(x + 4, by + 1, "#d84870")
    local hy = by - 8 - L // 3
    part(c, R(c, x - 7, hy - 1, x - 5, hy + 1), "#f06890", { noline = true })
    fl(c, R(c, x - 9, hy + 1, x - 7, hy + 2), "#2a1a10"); c:px(x - 6, hy, INK)
    for dx = -3, 3 do c:px(x + dx, yw + 1, "#fff0e8") end
  end
  flamingo(56, 38, 8)
  flamingo(13, 33, 4)
  -- gnome balancing on one leg, arms out
  local gx, gy = 30, 41
  local _, G = gnome(c, gx, gy, { d = 1, upper = true, eyes = "shut", arms = { arm({ -4, 7 }, { -9, 11 }, false), arm({ 4, 7 }, { 9, 11 }, true) } })
  fl(c, R(c, gx - 3, gy - 2, gx - 1, gy), "#4a6e9a"); fl(c, R(c, gx - 3, gy + 1, gx - 1, gy + 3), "#5a3a22")
  fl(c, R(c, gx + 1, gy - 2, gx + 4, gy - 1), "#4a6e9a"); fl(c, R(c, gx + 4, gy - 2, gx + 5, gy + 1), "#5a3a22")
  for dx = -6, 2 do if dx % 2 == 0 then c:px(gx + dx, gy + 4, "#fff0e8") end end
  finish(c, "r_esa_flamingo_pose")
end

-- 16. herd_crossing: raft waiting while the great herd wades across; gnome calls the gap with a notched stick
function S.r_esa_herd_crossing()
  seed = 76
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#a8d4e0", "#c0dce0", "#e0e4c0", "#f0e0a8" }, { dir = "v" })
  c:fill(c:ellipse(20, 8, 8, 2), "#f4eee0")
  c:fill(R(c, 0, 20, W - 1, 28), "#c8b468"); c:fill(R(c, 0, 20, W - 1, 20), "#dcc87c")
  acacia(c, 10, 22, 8, 7, "#4e8a3c"); acacia(c, 58, 22, 10, 9, "#3f7a3a")
  for x = 24, 52, 5 do c:fill(R(c, x, 17, x + 2, 18), "#e8d8a0") end
  c:fill(R(c, 0, 29, W - 1, H - 1), "#6a9aa4")
  c:bands(R(c, 0, 29, W - 1, H - 1), { "#7aa8ae", "#6a9aa4", "#5a8a98" }, { dir = "v" })
  for x = 3, 66, 7 do c:fill(R(c, x, 33 + (x % 4) * 3, x + 3, 33 + (x % 4) * 3), "#a8d0d4") end
  -- the herd
  zebra(c, 8, 30, 1); wildebeest(c, 19, 31, 1); zebra(c, 30, 30, 1); wildebeest(c, 41, 32, 1); zebra(c, 52, 31, 1); zebra(c, 61, 30, 1)
  for _, x in ipairs({ 8, 19, 30, 41, 52, 61 }) do c:fill(R(c, x, 36, x + 7, 36), "#d8ecee") end
  -- raft with a post and rope
  part(c, R(c, 4, 42, 42, 47), "#a8703e")
  for x = 10, 38, 7 do fl(c, R(c, x, 42, x, 47), "#6b3b2a") end
  fl(c, R(c, 4, 42, 42, 42), "#c08a52")
  part(c, R(c, 36, 32, 38, 42), "#6b4a2e", { noline = true })
  c:fill(c:line({ { 37, 34 }, { 58, 38 }, { 66, 40 } }, 1), "#e0c88a")
  local _, G = gnome(c, 24, 42, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local sx, sy = G.P(8, 16)
  part(c, R(c, sx, sy - 9, sx + 1, sy + 2), "#c08a52", { noline = true })
  for k = 0, 3 do c:px(sx - 1, sy - 8 + k * 3, "#4a2c1a") end
  fl(c, R(c, sx - 1, sy, sx + 1, sy + 2), "#f0c8a0")
  finish(c, "r_esa_herd_crossing")
end

-- 17. coffeecloud_path: terraces lost in cloud, gnome carrying a basket down the path to the picker
function S.r_esa_coffeecloud_path()
  seed = 77
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#dde6e8", "#e4ecec", "#eaf0ee", "#e4ecec" }, { dir = "v" })
  -- terraces, fading upward
  local tcols = { "#c4d4cc", "#b4cabc", "#9cbc9c", "#7aa87a", "#5e9a5e", "#4e8a4e" }
  for i, col in ipairs(tcols) do
    local y = 14 + (i - 1) * 6
    c:fill(R(c, 0, y, W - 1, y + 5), col)
    c:fill(R(c, 0, y, W - 1, y), (i < 4) and "#dde6e8" or "#9cc070")
    for x = (i % 2) * 2 + 2, W - 3, 4 do
      c:px(x, y + 2, (i < 3) and "#a8c0b0" or "#2f5a2a")
      if i > 3 then c:px(x + 1, y + 3, "#dd3a2a") end
    end
  end
  -- fog banks
  for _, e in ipairs({ { 12, 20, 16, 3 }, { 54, 17, 18, 3 }, { 34, 29, 22, 3 }, { 10, 33, 14, 3 }, { 60, 35, 12, 3 }, { 30, 12, 14, 2 } }) do
    c:fill(c:ellipse(e[1], e[2], e[3], e[4]), "#eef3f2")
    c:fill(c:ellipse(e[1] + 2, e[2] + 1, e[3] - 3, e[4] - 1), "#e4ecec")
  end
  -- path
  c:fill(c:line({ { 66, 38 }, { 46, 42 }, { 28, 40 }, { 12, 45 } }, 2), "#c8a470")
  c:fill(R(c, 0, 46, W - 1, H - 1), "#5e9a5e")
  c:fill(R(c, 0, 46, W - 1, 46), "#9cc070")
  -- the picker, waiting at the bottom (left)
  gnome(c, 14, 47, { d = 1, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 8 }, { 8, 14 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  -- carrier with a big basket on the back, lantern in hand
  local _, G = gnome(c, 46, 47, { d = -1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -9, 9 }, true), arm({ 4, 8 }, { 7, 11 }, false, true) } })
  local bx, by = G.P(8, 10)
  part(c, R(c, bx - 2, by - 6, bx + 6, by + 5), "#c08a52")
  for yy = by - 4, by + 4, 3 do fl(c, R(c, bx - 2, yy, bx + 6, yy), "#8a5a35") end
  for xx = bx, bx + 4, 4 do fl(c, R(c, xx, by - 6, xx, by + 5), "#8a5a35") end
  for _, p in ipairs({ { 0, -8 }, { 2, -7 }, { 4, -8 }, { 6, -7 } }) do c:fill(c:ellipse(bx + p[1], by + p[2], 1, 1), "#dd3a2a") end
  fl(c, R(c, bx - 3, by - 4, bx - 2, by - 2), "#6b3b2a")
  finish(c, "r_esa_coffeecloud_path")
end

-- 18. first_rains: market stops, every pot is out catching the rain, grinning in the smell of wet clay
function S.r_esa_first_rains()
  seed = 78
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#566272", "#627080", "#728090", "#8290a0" }, { dir = "v" })
  c:fill(c:ellipse(14, 8, 16, 4), "#3e4858"); c:fill(c:ellipse(52, 7, 18, 4), "#3e4858")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#b8583a")
  c:fill(R(c, 0, 34, W - 1, 35), "#8a4028")
  c:fill(c:ellipse(30, 47, 10, 1), "#d8a090"); c:fill(c:ellipse(56, 45, 8, 1), "#d8a090")
  -- stall behind
  part(c, R(c, 42, 20, 43, 38), "#6b3b2a", { noline = true }); part(c, R(c, 66, 20, 67, 38), "#6b3b2a", { noline = true })
  local n = 0
  for x = 40, 66, 4 do fl(c, R(c, x, 16, x + 3, 22), (n % 2 == 0) and "#2a4a8a" or "#f4eee0"); n = n + 1 end
  c:outline(R(c, 40, 16, 68, 22))
  part(c, R(c, 44, 31, 65, 36), "#8a5a35")
  for _, x in ipairs({ 48, 55, 61 }) do part(c, c:ellipse(x, 29, 2, 2), "#c8a028") end
  -- pots and bowls out in the rain
  pot(c, 12, 48, 4, 8, "#c4623a", "#7cc9e0"); pot(c, 22, 46, 3, 5, "#a8582f", "#7cc9e0")
  pot(c, 40, 48, 4, 9, "#8a4220", "#7cc9e0"); pot(c, 52, 47, 5, 4, "#c4623a", "#7cc9e0"); pot(c, 62, 48, 3, 7, "#a8582f", "#7cc9e0")
  gnome(c, 31, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -8, 15 }, false), arm({ 4, 8 }, { 8, 15 }, true) } })
  -- rain
  seed = 15
  for i = 1, 46 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 40)
    c:px(x, y, "#c8e0f0"); c:px(x - 1, y + 1, "#c8e0f0"); if i % 3 == 0 then c:px(x - 2, y + 2, "#c8e0f0") end
  end
  for _, p in ipairs({ { 10, 41 }, { 14, 41 }, { 23, 41 }, { 38, 40 }, { 41, 40 }, { 60, 40 } }) do c:px(p[1], p[2], "#e8f4fc") end
  finish(c, "r_esa_first_rains")
end

-- 19. wrap_stoneplants: frosty karoo dawn, straw round the pebble-like succulents
function S.r_esa_wrap_stoneplants()
  seed = 79
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#6a6a9a", "#9a7aa8", "#d89aa0", "#f0b888", "#f8d098" }, { dir = "v" })
  c:fill(c:ellipse(18, 31, 5, 5):clip(R(c, 0, 0, W, 30)), "#ffe8a0")
  c:fill(c:poly({ { 40, 31 }, { 44, 22 }, { 64, 22 }, { 70, 31 } }), "#8a5a58"); c:fill(R(c, 44, 22, 64, 22), "#a87a68")
  c:fill(c:ellipse(12, 31, 14, 3), "#9a6a60")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#b8986a")
  c:fill(R(c, 0, 31, W - 1, 33), "#a8845a")
  seed = 79
  for i = 1, 22 do local x, y = 5 + floor(rand() * 63), 35 + floor(rand() * 14); c:px(x, y, "#8a6a46"); c:px(x + 1, y, "#8a6a46") end
  for i = 1, 16 do c:px(5 + floor(rand() * 63), 33 + floor(rand() * 16), "#f4f8fa") end
  -- stone plants: pebble pairs with a slit
  local function lith(x, y, wrapped)
    if wrapped then
      part(c, c:ellipse(x, y, 4, 3), "#d8b848")
      for dx = -3, 3, 2 do c:px(x + dx, y - 1, "#a88828") end
      fl(c, R(c, x - 3, y, x + 3, y), "#8a5a35"); c:px(x, y - 4, "#d8b848"); c:px(x - 1, y - 3, "#d8b848")
    else
      part(c, c:ellipse(x, y, 3, 2), "#9a8a7a"); fl(c, R(c, x, y - 1, x, y + 1), "#5e5248"); c:px(x - 2, y, "#8aa07a"); c:px(x + 2, y - 1, "#8aa07a")
      c:px(x - 1, y - 1, "#f4f8fa"); c:px(x + 1, y + 2, "#f4f8fa")
    end
  end
  lith(36, 41, true); lith(46, 45, false); lith(56, 41, false); lith(62, 47, false); lith(30, 47, false); lith(52, 36, true)
  -- straw bag
  part(c, c:ellipse(15, 47, 6, 4), "#e8c84a", { shade = true }); fl(c, R(c, 11, 44, 19, 44), "#a88828")
  for _, p in ipairs({ { 11, 41 }, { 14, 40 }, { 18, 41 }, { 21, 44 } }) do c:fill(c:line({ { p[1], p[2] + 3 }, { p[1] + 1, p[2] } }, 1), "#e8c84a") end
  gnome(c, 28, 40, { s = 1.15, d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 8, 3 }, true) } })
  spark(c, 40, 38); spark(c, 58, 44)
  finish(c, "r_esa_wrap_stoneplants")
end

-- 20. snowcrown_dawn: the white peak floats on the cloud at first light
function S.r_esa_snowcrown_dawn()
  seed = 80
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 40), { "#2e3a7a", "#4a4a8a", "#8a5a9a", "#d87a9a", "#f0a08a", "#f8c890" }, { dir = "v" })
  for _, p in ipairs({ { 10, 7 }, { 20, 11 }, { 58, 8 }, { 66, 14 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- the peak
  c:fill(c:poly({ { 40, 10 }, { 52, 28 }, { 28, 28 } }), "#e4e8f4")
  c:fill(c:poly({ { 40, 10 }, { 52, 28 }, { 42, 28 }, { 40, 21 }, { 43, 16 } }), "#f8d0d8")
  c:fill(c:poly({ { 40, 10 }, { 28, 28 }, { 34, 28 }, { 38, 20 } }), "#aab4d8")
  c:fill(R(c, 36, 17, 38, 17), "#7a84b0"); c:fill(R(c, 41, 22, 46, 22), "#e8a8b8")
  c:px(40, 10, "#f8f8ff")
  -- cloud hiding the base
  for _, e in ipairs({ { 14, 33, 14, 4 }, { 32, 35, 14, 3 }, { 50, 33, 16, 4 }, { 66, 35, 10, 3 }, { 24, 29, 8, 2 }, { 56, 29, 8, 2 }, { 40, 31, 10, 3 } }) do
    c:fill(c:ellipse(e[1], e[2], e[3], e[4]), "#f8e8e0")
    c:fill(c:ellipse(e[1], e[2] + 1, e[3] - 2, e[4] - 1), "#e8c8cc")
  end
  c:fill(c:ellipse(40, 29, 12, 2), "#f8e8e0")
  -- stone viewing terrace
  part(c, R(c, 0, 41, W - 1, H - 1), "#6a6a7a")
  for x = 0, W - 1, 9 do fl(c, R(c, x, 41, x + 5, 44), "#7a7a8a"); c:px(x + 1, 42, "#9a9aa8") end
  fl(c, R(c, 0, 45, W - 1, 45), "#4a4a5a")
  for x = 5, 66, 12 do fl(c, R(c, x, 46, x + 5, 46), "#5a5a6a") end
  gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 15 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 25, 31, 27, 33), "#f0c8a0")
  c:px(30, 24, "#f8d0d8"); c:px(48, 26, "#f8d0d8")
  finish(c, "r_esa_snowcrown_dawn")
end

-- 21. weaver_nest: on a stool beneath the acacia, rehanging the fallen woven nest as the owner scolds
function S.r_esa_weaver_nest()
  seed = 81
  local c = new()
  day(c, 38, { grass = "#c8b468", edge = "#dcc87c", hill = "#b89a58", hill2 = "#a88a4a", cloud = 12, sky = { "#c8e0e0", "#d8e8d8", "#e8ecd0" } })
  part(c, R(c, 52, 20, 55, 48), "#5e3f28", { shade = true })
  c:fill(c:line({ { 53, 24 }, { 40, 20 }, { 34, 21 } }, 2), "#5e3f28")
  c:fill(c:line({ { 54, 26 }, { 66, 20 } }, 2), "#5e3f28")
  part(c, c:ellipse(52, 11, 20, 6), "#3f7a3a", { shade = true })
  c:fill(c:ellipse(44, 9, 8, 2), "#6aa84c")
  -- a nest already hanging
  fl(c, R(c, 60, 15, 60, 18), "#6b4a2e"); part(c, c:ellipse(60, 21, 3, 3), "#d8b848"); c:px(60, 23, "#4a2c1a")
  -- stool and gnome
  part(c, R(c, 16, 43, 30, 46), "#a8703e"); part(c, R(c, 17, 47, 18, 48), "#6b3b2a", { noline = true }); part(c, R(c, 28, 47, 29, 48), "#6b3b2a", { noline = true })
  local _, G = gnome(c, 23, 43, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 16 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local nx, ny = G.P(10, 17)
  part(c, c:ellipse(nx, ny - 1, 4, 4), "#d8b848")
  for dx = -2, 2, 2 do c:px(nx + dx, ny - 2, "#a88828"); c:px(nx + dx + 1, ny, "#a88828") end
  fl(c, R(c, nx - 1, ny + 2, nx + 1, ny + 3), "#3a2418")
  fl(c, R(c, nx - 4, ny + 1, nx - 3, ny + 2), "#f0c8a0")
  -- weaver bird scolding
  part(c, c:ellipse(40, 16, 3, 2), "#f4c040"); part(c, R(c, 38, 13, 40, 15), "#2a1a10", { noline = true })
  fl(c, R(c, 36, 15, 37, 15), "#e08a30"); c:px(43, 17, "#c89020"); fl(c, R(c, 42, 14, 44, 15), "#c89020")
  c:px(34, 13, "#f4eee0"); c:px(33, 15, "#f4eee0"); c:px(34, 17, "#f4eee0")
  for _, p in ipairs({ { 44, 46 }, { 62, 47 }, { 10, 48 } }) do tuft(c, p[1], p[2], "#a89048") end
  finish(c, "r_esa_weaver_nest")
end

-- 22. honeyguide: following the chattering bird towards the wild hive
function S.r_esa_honeyguide()
  seed = 82
  local c = new()
  day(c, 36, { grass = "#a8b868", edge = "#c0d078", hill = "#7a9a4a", hill2 = "#6a8a3c", cloud = 54, sky = { "#b8dce0", "#cce4e0", "#e0ecd0" } })
  -- hive tree
  part(c, R(c, 59, 14, 62, 44), "#6b4a2e", { shade = true })
  c:fill(c:line({ { 60, 20 }, { 52, 16 } }, 2), "#6b4a2e")
  part(c, c:ellipse(58, 11, 11, 6), "#3f7a3a", { shade = true }); c:fill(c:ellipse(53, 9, 4, 2), "#6aa84c")
  fl(c, R(c, 52, 17, 52, 19), "#e8c48a")
  part(c, c:ellipse(52, 23, 3, 5), "#c8902a"); for _, y in ipairs({ 21, 24 }) do fl(c, R(c, 50, y, 54, y), "#8a5a1a") end
  c:px(52, 27, "#4a2c1a")
  for _, p in ipairs({ { 48, 22 }, { 56, 25 }, { 49, 28 }, { 55, 20 } }) do c:px(p[1], p[2], "#f5cf6a"); c:px(p[1] + 1, p[2] - 1, "#f4f8fa") end
  for _, p in ipairs({ { 8, 38 }, { 44, 40 } }) do part(c, c:ellipse(p[1], p[2], 5, 3), "#4e8a3c", { shade = true }) end
  -- trail of bird flights
  for _, p in ipairs({ { 24, 28 }, { 28, 26 }, { 31, 25 } }) do c:px(p[1], p[2], "#e8f0d0") end
  -- the bird
  part(c, c:ellipse(38, 24, 3, 2), "#8a6a46"); fl(c, R(c, 37, 25, 39, 25), "#e8d8b0")
  fl(c, R(c, 34, 23, 35, 24), "#6b4a2e"); c:px(41, 23, "#2a1a10"); c:px(42, 24, "#e8a317")
  fl(c, R(c, 36, 21, 38, 22), "#6b4a2e"); c:px(35, 21, "#6b4a2e")
  note(c, 30, 15, "#f5cf6a"); note(c, 36, 12, "#f5cf6a")
  -- gnome pointing, honeycomb in the other hand
  local _, G = gnome(c, 22, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true), arm({ -4, 7 }, { -7, 7 }, false, true) } })
  local hx, hy = G.P(-8, 7)
  part(c, R(c, hx - 2, hy - 1, hx + 2, hy + 3), "#e8a317"); c:px(hx, hy, "#8a5a1a"); c:px(hx - 1, hy + 2, "#8a5a1a"); c:px(hx + 1, hy + 2, "#8a5a1a")
  for _, p in ipairs({ { 38, 46 }, { 48, 48 }, { 6, 47 } }) do tuft(c, p[1], p[2], "#6a8a3c") end
  finish(c, "r_esa_honeyguide")
end

-- 23. thumb_piano: three sour tines, thumbs plinking, a candle-lit inn evening
function S.r_esa_thumb_piano()
  seed = 83
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 49), "#6b4a2e")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 49), "#5a3c24") end
  part(c, R(c, 46, 8, 63, 24), "#2a3a68"); fl(c, R(c, 54, 8, 54, 24), "#6b3b2a"); fl(c, R(c, 46, 16, 63, 16), "#6b3b2a")
  c:fill(c:ellipse(59, 12, 2, 2), "#f5e6a8"); c:px(50, 11, "#f4eee0"); c:px(51, 21, "#f4eee0")
  -- lantern on a shelf
  part(c, R(c, 6, 20, 20, 21), "#8a5a35")
  part(c, R(c, 10, 11, 15, 19), "#ffd86a", { cres = 1 }); fl(c, R(c, 11, 13, 14, 17), "#fff1c8"); fl(c, R(c, 10, 10, 15, 10), "#3d2a1c")
  for _, p in ipairs({ { 8, 14 }, { 17, 14 }, { 8, 8 }, { 17, 8 } }) do c:px(p[1], p[2], "#f8c070") end
  c:fill(R(c, 0, 44, W - 1, H - 1), "#8a5a35"); fl(c, R(c, 0, 44, W - 1, 44), "#a8703e")
  local _, G = gnome(c, 34, 47, { s = 1.5, d = 1, upper = true, eyes = "shut", arms = { arm({ -4, 7 }, { -3, 9 }, true, true), arm({ 4, 7 }, { 3, 9 }, true, true) } })
  -- the thumb piano: wooden box, metal tongues, the three sour ones tinted
  local kx, ky = 25, 40
  part(c, R(c, kx, ky, kx + 18, ky + 7), "#c08a52")
  fl(c, R(c, kx, ky, kx + 18, ky), "#d9a660"); c:fill(c:ellipse(kx + 9, ky + 4, 2, 1), "#4a2c1a")
  for i = 0, 8 do
    local len = 8 - math.abs(i - 4) * 1
    local sour = (i == 1 or i == 5 or i == 7)
    fl(c, R(c, kx + 1 + i * 2, ky - len + 2, kx + 1 + i * 2, ky), sour and "#e8643a" or "#d8dce4")
    if sour then c:px(kx + 2 + i * 2, ky - len + 2, "#e8643a") end
  end
  fl(c, R(c, kx + 8, ky + 1, kx + 10, ky + 1), "#8a5a35")
  fl(c, R(c, kx - 2, ky - 1, kx + 1, ky + 1), "#f0c8a0"); fl(c, R(c, kx + 17, ky - 1, kx + 20, ky + 1), "#f0c8a0")
  note(c, 52, 34, "#f5cf6a"); note(c, 58, 28, "#e8643a"); note(c, 61, 38, "#f4eee0")
  finish(c, "r_esa_thumb_piano")
end

-- 24. teff_injera: batter swirled in one slow spiral onto the clay griddle over the fire
function S.r_esa_teff_injera()
  seed = 84
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#c8a070")
  for y = 4, 38, 6 do fl(c, R(c, 0, y, W - 1, y), "#b88a5a") end
  part(c, R(c, 8, 9, 22, 20), "#6ab8d8"); fl(c, R(c, 15, 9, 15, 20), "#8a5a35")
  fl(c, R(c, 8, 7, 22, 8), "#a8703e")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#6a5438")
  for i = 0, 20 do local x = 3 + (i * 3) % 66; c:fill(R(c, x, 43 + (i * 5) % 6, x, 45 + (i * 5) % 6), "#8a6a46") end
  -- fire under the griddle
  for _, x in ipairs({ 31, 52 }) do part(c, R(c, x, 40, x + 3, 48), "#8b8f96") end
  part(c, c:poly({ { 36, 48 }, { 38, 42 }, { 42, 38 }, { 46, 42 }, { 49, 48 } }), "#e0501f")
  c:fill(c:poly({ { 39, 48 }, { 41, 43 }, { 43, 43 }, { 46, 48 } }), "#f08a24"); c:fill(c:ellipse(42, 46, 2, 2), "#ffd86a")
  -- griddle with spiral batter
  part(c, c:ellipse(42, 36, 17, 5), "#4a2c24")
  c:fill(c:ellipse(42, 36, 15, 4), "#a07a50")
  for t = 0, 60 do
    local a = t * 0.34
    local rr = (t / 60) * 14
    local px_, py_ = floor(42 + rr * math.cos(a) + 0.5), floor(36 + rr * 0.27 * math.sin(a) + 0.5); c:px(px_, py_, "#f4e4c0"); c:px(px_ + 1, py_, "#f4e4c0")
  end
  for _, p in ipairs({ { 33, 36 }, { 38, 34 }, { 47, 37 }, { 51, 36 }, { 44, 39 }, { 40, 38 } }) do c:px(p[1], p[2], "#a88a64") end
  -- gnome pouring from a jug
  local _, G = gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local jx, jy = G.P(9, 14)
  part(c, R(c, jx, jy - 4, jx + 5, jy + 1), "#8a4220"); fl(c, R(c, jx + 6, jy - 4, jx + 7, jy - 3), "#8a4220"); fl(c, R(c, jx, jy - 4, jx + 5, jy - 4), "#e8d8b0")
  fl(c, R(c, jx - 1, jy - 1, jx, jy + 1), "#f0c8a0")
  c:fill(R(c, jx + 7, jy - 2, jx + 7, 35), "#f4e4c0")
  -- injera stack in a basket and a lid
  part(c, c:ellipse(62, 47, 6, 2), "#c08a52")
  for i = 0, 2 do part(c, c:ellipse(62, 45 - i * 2, 5, 1), "#e8d8b0"); c:px(60 + i, 45 - i * 2, "#a88a64"); c:px(64 - i, 44 - i * 2, "#a88a64") end
  finish(c, "r_esa_teff_injera")
end

local order = {}
for line in io.lines(app.params.list or "/tmp/claude-0/-home-user-gnome-venture/1b9189c1-3b2f-55fd-a82b-d2ac35c1c228/scratchpad/lists/h13.txt") do
  if #line > 0 then order[#order + 1] = line end
end
for _, s2 in ipairs(order) do
  if (not only or only == s2) and S[s2] then seed = 7; S[s2]() end
end

-- variety-act-h12.lua : Do-tab scenes for 24 regional rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h12.lua   (params BEFORE --script)
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

---------------------------------------------------------------- scenes

---------------------------------------------------------------- shared helpers
local function sunball(c, x, y, r, col) c:fill(c:ellipse(x, y, r, r), col or "#f5e6a8") end
local function tree(c, x, yb, h, rx, ry, col, col2)
  part(c, R(c, x - 1, yb - h, x + 1, yb), "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - h - 1, rx, ry), col or "#3f8a42", { shade = true })
  if col2 then c:fill(c:ellipse(x - 2, yb - h - 3, rx - 3, ry - 3), col2) end
end
local function rain(c, n, col, x0, x1, y0, y1)
  col = col or "#d8e6ee"; x0 = x0 or 6; x1 = x1 or 67; y0 = y0 or 6; y1 = y1 or 46
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col); c:px(x, y + 1, col); c:px(x - 1, y + 2, col)
  end
end
-- gnome lying on his back, head at left (d=1) or right (d=-1); y = surface the body rests on
local function lying(c, x, y, d, o)
  o = o or {}
  d = d or 1
  local function X(v) return x + d * v end
  local sil = c:mask()
  local function pp(m, hex) c:part(m, GV.ramp(hex, { rim = hex }), { flat = true, gloss = false, contact = false, outline = false, contour = false }); sil:add(m) end
  local function rr(a, b, e, f) local x0, x1 = X(a), X(b); if x0 > x1 then x0, x1 = x1, x0 end return c:rect(x0, y - f, x1, y - e) end
  pp(rr(15, 17, 0, 3), "#5a3a22")            -- boots
  pp(rr(5, 15, 1, 5), "#4a6e9a")             -- body + legs
  pp(rr(3, 8, 1, 4), "#f4eee0")              -- beard on chest
  pp(rr(-3, 3, 1, 5), "#f0c8a0")             -- head
  pp(rr(-1, 2, 2, 3), "#f4eee0")
  local hat = c:mask()
  for i = 0, 8 do local hh = math.max(1, floor(5 - i * 0.55)); hat:add(rr(-3 - i, -3 - i, 1 + floor(i / 3), 1 + hh + floor(i / 3))) end
  pp(hat, o.hat or "#c0442e")
  pp(rr(-3, -2, 1, 6), o.brim or "#8e2e1e")
  if o.arms then pp(rr(2, 9, 5, 7), "#4a6e9a"); pp(rr(8, 10, 6, 8), "#f0c8a0") end
  c:px(X(-2), y - 4, "#8a4a34"); c:px(X(0), y - 4, "#8a4a34")
  c:outline(sil, { ol = 1, olx = 0 })
  return sil
end
-- yellow weaverbird, facing d
local function bird(c, x, y, d, wing)
  local o = "#2a1a10"
  c:fill(c:ellipse(x, y, 2, 1), "#f5cf6a"); c:px(x + d * 2, y - 1, "#e8a317"); c:px(x + d * 3, y, "#c06020")
  c:px(x + d, y - 1, o); c:px(x - d * 3, y + 1, "#e8a317")
  if wing then c:px(x - d, y - 2, "#e8a317"); c:px(x - d * 2, y - 3, "#e8a317") else c:px(x - d, y + 1, "#e8a317") end
end
local function pot(c, cx, cy, rx, ry, col, rim)
  part(c, c:ellipse(cx, cy, rx, ry), col, { shade = true })
  part(c, c:ellipse(cx, cy - ry + 1, rx, 2), rim or "#3a2a22")
end
local function puff(c, x, y, r, col) c:fill(c:ellipse(x, y, r, math.max(1, r - 1)), col or "#f4f8fa") end

local S = {}

---------------------------------------------------------------- scenes A
-- hanging garden ruins: stepped terraces with moss and hanging vines, gnome pats a mossy step
function S.r_mena_hanging_garden()
  seed = 61
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#8fcbe0", "#a8d8e4", "#c4e4e6", "#e0eed8" }, { dir = "v" })
  c:fill(c:ellipse(12, 9, 6, 2), "#f4eee0")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#d9bc84"); c:fill(R(c, 0, 36, W - 1, 36), "#e8d0a0")
  c:fill(c:ellipse(14, 37, 22, 4), "#c9a96e")
  -- terraces
  local steps = { { 36, 47, 38 }, { 44, 47, 30 }, { 52, 47, 22 }, { 59, 47, 14 } }
  for i, s in ipairs(steps) do
    local x0, yt = s[1], s[3]
    part(c, R(c, x0, yt, 68, 48), (i % 2 == 0) and "#cfb07a" or "#d9bc84")
    fl(c, R(c, x0 + 1, yt, 68, yt + 1), "#6aa04a")
    for x = x0 + 2, 67, 3 do if (x + i) % 2 == 0 then c:px(x, yt + 2, "#6aa04a") end end
    fl(c, R(c, x0 + 3, yt + 4, 68, yt + 4), "#b8965c")
    -- vines hanging from the lip
    for k = 0, 2 do
      local vx = x0 + 3 + k * 4 + (i % 2) * 2
      if vx < 67 then
        fl(c, R(c, vx, yt + 2, vx, yt + 5 + (k + i) % 3 * 2), "#4e8a3c")
        c:px(vx + 1, yt + 4 + (k % 2), "#6aa04a"); c:px(vx - 1, yt + 6 + (k % 2), "#6aa04a")
      end
    end
  end
  -- palm at top
  c:fill(c:line({ { 64, 14 }, { 64, 8 } }, 1), "#6b4a2e")
  for _, f in ipairs({ { -5, 1 }, { 5, 1 }, { -4, -3 }, { 4, -3 }, { 0, -4 } }) do
    c:fill(c:line({ { 64, 8 }, { 64 + f[1], 8 + f[2] } }, 2), "#3f8a42")
  end
  -- broken arch/column on the left
  part(c, R(c, 8, 22, 13, 40), "#cfb07a"); part(c, R(c, 7, 20, 14, 22), "#d9bc84")
  fl(c, R(c, 9, 22, 12, 23), "#6aa04a"); fl(c, R(c, 9, 25, 9, 31), "#4e8a3c"); fl(c, R(c, 12, 27, 12, 34), "#4e8a3c")
  part(c, R(c, 16, 35, 22, 40), "#cfb07a"); fl(c, R(c, 16, 35, 22, 35), "#6aa04a")
  -- gnome patting the moss on the first step
  gnome(c, 27, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 5 }, { 8, 8 }, true) } })
  for _, p in ipairs({ { 22, 30 }, { 18, 28 }, { 31, 24 } }) do c:px(p[1], p[2], "#f5cf6a") end
  finish(c, "r_mena_hanging_garden")
end

-- courtyard nap: gnome asleep on a cushioned bench, fig tree and a trickling fountain
function S.r_mena_courtyard_nap()
  seed = 62
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e8d2a0"); c:fill(R(c, 0, 0, W - 1, 14), "#a8d4e0")
  c:fill(R(c, 0, 14, W - 1, 15), "#f4eee0")
  -- wall with archway
  part(c, R(c, 0, 15, W - 1, 38), "#f0e0bc", { noline = true })
  part(c, c:rrect(26, 18, 46, 38, 8), "#d9a660")
  c:fill(c:rrect(28, 20, 44, 38, 7), "#3f7a8a"); c:fill(R(c, 28, 28, 44, 38), "#3f7a8a")
  c:fill(R(c, 36, 20, 36, 38), "#2f5a6a"); c:fill(R(c, 30, 24, 34, 24), "#5aa0b0")
  for x = 2, 70, 6 do fl(c, R(c, x, 16, x + 2, 16), "#d9bc84") end
  -- tile floor
  c:fill(R(c, 0, 38, W - 1, H - 1), "#c9a96e")
  for y = 40, 50, 4 do fl(c, R(c, 0, y, W - 1, y), "#b8965c") end
  for x = 4, 70, 9 do for y = 38, 50, 4 do c:px(x + (y % 8), y + 1, "#b8965c") end end
  -- fig tree on the left
  tree(c, 11, 40, 20, 10, 8, "#3f7a3a", "#4e9a48")
  for _, p in ipairs({ { 7, 21 }, { 13, 24 }, { 17, 19 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#7a3a6a") end
  -- fountain on the right
  part(c, c:ellipse(59, 43, 10, 4), "#c9c5bc", { shade = true })
  c:fill(c:ellipse(59, 43, 8, 3), "#4aa8c8")
  part(c, R(c, 58, 31, 60, 42), "#c9c5bc")
  part(c, c:ellipse(59, 31, 4, 2), "#c9c5bc"); c:fill(c:ellipse(59, 31, 2, 1), "#4aa8c8")
  fl(c, R(c, 55, 32, 55, 40), "#8fd8e8"); fl(c, R(c, 63, 32, 63, 40), "#8fd8e8"); c:px(59, 29, "#8fd8e8"); c:px(59, 28, "#cfeef4")
  -- bench with cushion and the sleeper
  part(c, R(c, 22, 40, 24, 47), "#6b3b2a", { noline = true }); part(c, R(c, 45, 40, 47, 47), "#6b3b2a", { noline = true })
  part(c, R(c, 20, 38, 49, 41), "#8a5a35")
  lying(c, 31, 38, 1)
  part(c, R(c, 20, 38, 49, 39), "#c0442e"); fl(c, R(c, 22, 38, 47, 38), "#e8825e")
  for x = 24, 46, 6 do c:px(x, 39, "#f5cf6a") end
  -- sleepy bubbles
  puff(c, 40, 31, 1, "#f4f8fa"); puff(c, 43, 27, 2, "#f4f8fa"); puff(c, 47, 22, 2, "#f4f8fa")
  finish(c, "r_mena_courtyard_nap")
end

-- weaverbirds: golden millet, gnome swinging a rattle at a yellow flock
function S.r_wca_weaverbirds()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#9fd0e0", "#bcdde0", "#dce8d0", "#f0eac0" }, { dir = "v" })
  c:fill(c:ellipse(14, 9, 7, 2), "#f4eee0")
  c:fill(c:ellipse(20, 31, 34, 8), "#c8b060"); c:fill(c:ellipse(64, 32, 30, 7), "#b8a050")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#c9a050")
  tree(c, 62, 32, 12, 8, 3, "#5e8a3a")
  c:fill(R(c, 54, 20, 70, 20), "#5e8a3a")
  -- millet rows, heavy heads
  local function stalk(x, yb, h)
    fl(c, R(c, x, yb - h, x, yb), "#7a9a40")
    part(c, R(c, x - 1, yb - h - 4, x + 1, yb - h), "#e8a317")
    c:px(x, yb - h - 3, "#f5cf6a")
  end
  for row = 0, 2 do
    local yb = 36 + row * 6
    for x = 7 + (row * 3) % 5, 67, 6 do
      if not (x > 22 and x < 36 and row == 2) then stalk(c.W and x or x, yb + 3, 8 + row * 2) end
    end
  end
  gnome(c, 29, 48, { d = 1, eyes = "open", arms = { arm({ -4, 12 }, { -8, 17 }, false), arm({ 4, 12 }, { 8, 18 }, true) } })
  -- rattle held up
  part(c, R(c, 37, 24, 38, 29), "#8a5a35", { noline = true }); part(c, c:ellipse(37, 22, 2, 3), "#c0442e")
  c:px(33, 24, "#fff8e0"); c:px(41, 26, "#fff8e0"); c:px(40, 20, "#fff8e0")
  -- fleeing flock + some on the heads
  bird(c, 46, 14, 1, true); bird(c, 52, 10, 1, false); bird(c, 58, 17, 1, true); bird(c, 62, 11, 1, false); bird(c, 50, 22, 1, false)
  bird(c, 12, 27, -1, true); bird(c, 20, 31, -1, false)
  finish(c, "r_wca_weaverbirds")
end

-- hippo count: dawn river, ears and eyes in the shallows, gnome counting on his fingers from the jetty
function S.r_wca_hippo_count()
  seed = 64
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#6a6aa0", "#9a7ab0", "#d890a0", "#f0aa88", "#f8d080" }, { dir = "v" })
  c:fill(c:ellipse(40, 29, 7, 6):clip(R(c, 0, 0, W, 28)), "#fff0a8")
  c:fill(c:ellipse(12, 28, 24, 4), "#4a5a78"); c:fill(c:ellipse(64, 28, 22, 3), "#566888")
  c:bands(R(c, 0, 28, W - 1, H - 1), { "#7a8aa8", "#6a8ab0", "#5a8ab4", "#4a7aa8" }, { dir = "v" })
  for _, p in ipairs({ { 14, 33, 8 }, { 50, 31, 6 }, { 30, 40, 6 }, { 60, 45, 7 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#bcd4e4") end
  -- hippos: humps with ears + eyes + nostrils
  local function hippo(x, y, s)
    part(c, c:ellipse(x, y, 7 * s, 5 * s):clip(R(c, 0, 0, W, y)), "#9a8494", { shade = true })
    c:fill(R(c, x - 3, y - 3, x + 3, y - 1), "#b89aa4"); c:px(x - 2, y - 2, "#6a4a5a"); c:px(x + 2, y - 2, "#6a4a5a")
    part(c, R(c, x - 6 * s, y - 1, x + 6 * s, y + 1), "#8a7a8a", { noline = true })
    fl(c, R(c, x - 5 * s, y, x + 5 * s, y), "#bcd4e4")
    c:px(x - 4, y - 5, "#2a1a10"); c:px(x + 4, y - 5, "#2a1a10")
    part(c, R(c, x - 6, y - 7, x - 5, y - 5), "#b89aa4", { noline = true })
    part(c, R(c, x + 5, y - 7, x + 6, y - 5), "#b89aa4", { noline = true })
    
  end
  hippo(18, 35, 1); hippo(33, 37, 1); hippo(46, 34, 1); hippo(57, 38, 1)
  hippo(24, 42, 1)
  -- jetty with the ferry-keeper gnome counting
  part(c, R(c, 44, 43, 68, 46), "#8a5a35"); fl(c, R(c, 44, 43, 68, 43), "#a8703e")
  for _, x in ipairs({ 47, 58, 66 }) do part(c, R(c, x, 46, x + 1, 50), "#5e3f28", { noline = true }) end
  gnome(c, 58, 43, { d = -1, eyes = "open", arms = { arm({ 4, 7 }, { 4, 3 }, false), arm({ -4, 9 }, { -8, 15 }, true) } })
  fl(c, R(c, 47, 40, 47, 42), "#8a5a35"); fl(c, R(c, 46, 39, 48, 39), "#dd3a2a")
  for _, p in ipairs({ { 20, 29 }, { 30, 30 }, { 52, 29 } }) do puff(c, p[1], p[2], 3, "#f0d8d8") end
  finish(c, "r_wca_hippo_count")
end

-- canopy bridge: rope bridge between two trunk platforms, gnome carrying a parcel
function S.r_wca_canopy_bridge()
  seed = 65
  local c = new()
  c:bands(R(c, 0, 0, W - 1, H - 1), { "#3f7a58", "#4a8a60", "#5a9a68", "#6aa870", "#7ab478" }, { dir = "v" })
  for _, p in ipairs({ { 12, 36 }, { 28, 40 }, { 42, 38 }, { 58, 41 }, { 66, 37 } }) do c:fill(c:ellipse(p[1], p[2], 10, 6), "#4a8a58") end
  for _, p in ipairs({ { 20, 44 }, { 36, 46 }, { 52, 45 } }) do c:fill(c:ellipse(p[1], p[2], 12, 6), "#3f7a50") end
  for _, p in ipairs({ { 18, 12 }, { 40, 8 }, { 60, 12 } }) do c:fill(c:ellipse(p[1], p[2], 8, 3), "#2f6a48") end
  -- trunks
  part(c, R(c, 4, 5, 13, 49), "#6b4a2e"); part(c, R(c, 60, 5, 68, 49), "#6b4a2e")
  for _, x in ipairs({ 7, 10, 63, 66 }) do fl(c, R(c, x, 8, x, 46), "#5e3f28") end
  -- platforms
  part(c, R(c, 4, 29, 18, 31), "#a8703e"); part(c, R(c, 55, 29, 68, 31), "#a8703e")
  part(c, R(c, 4, 20, 5, 29), "#8a5a35", { noline = true }); part(c, R(c, 67, 20, 68, 29), "#8a5a35", { noline = true })
  -- bridge: sagging planks and rope rails
  local function sag(x) local t = (x - 18) / (55 - 18); return 30 + floor(4 * 4 * t * (1 - t) + 0.5) end
  for x = 18, 55 do fl(c, R(c, x, sag(x) - 1, x, sag(x)), "#a8703e") end
  for x = 20, 54, 3 do fl(c, R(c, x, sag(x) - 1, x, sag(x) + 1), "#6b4a2e") end
  for x = 18, 55 do c:px(x, sag(x) - 14 + (x < 28 and 0 or 0) + 0, "#e0c88a") end
  for x = 20, 54, 6 do fl(c, R(c, x, sag(x) - 13, x, sag(x) - 1), "#c8a870") end
  -- parcel-bearing gnome in the middle
  gnome(c, 36, sag(36) - 1, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 10 }, true) } })
  part(c, R(c, 40, 13, 47, 21), "#d9bc84"); fl(c, R(c, 43, 13, 43, 21), "#c0442e"); fl(c, R(c, 40, 16, 47, 16), "#c0442e")
  -- far platform keeper's lantern and a few leaves in front
  fl(c, R(c, 62, 24, 62, 28), "#3d2a1c"); part(c, R(c, 61, 21, 63, 24), "#ffd86a")
  for _, p in ipairs({ { 20, 6 }, { 34, 5 }, { 48, 7 } }) do part(c, c:ellipse(p[1], p[2], 5, 2), "#2f6a48", { noline = true }) end
  finish(c, "r_wca_canopy_bridge")
end

-- dust mats: red dust flying as the gnome beats a woven mat on the rail
function S.r_wca_dust_mats()
  seed = 66
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#e8b890", "#ecc4a0", "#f0d0b0", "#f4dcc0" }, { dir = "v" })
  part(c, R(c, 0, 12, W - 1, 36), "#d8a070", { noline = true })
  for x = 0, 70, 7 do fl(c, R(c, x, 12, x, 36), "#c8905e") end
  part(c, R(c, 0, 8, W - 1, 14), "#8a4a2a")
  for x = 3, 66, 8 do fl(c, R(c, x, 9, x + 4, 9), "#a8602e") end
  c:fill(R(c, 0, 36, W - 1, H - 1), "#c0804a"); c:fill(R(c, 0, 36, W - 1, 36), "#d09a64")
  for _, p in ipairs({ { 6, 44 }, { 20, 48 }, { 40, 46 }, { 62, 49 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#a8602e") end
  -- rail with two hanging mats
  part(c, R(c, 26, 22, 27, 38), "#6b3b2a", { noline = true }); part(c, R(c, 64, 22, 65, 38), "#6b3b2a", { noline = true })
  part(c, R(c, 24, 21, 66, 23), "#8a5a35")
  local function mat(x0, x1, ya, yb, cols)
    local n = 0
    for x = x0, x1 do fl(c, R(c, x, ya, x, yb), cols[(floor((x - x0) / 3)) % #cols + 1]) end
    for y = ya + 3, yb, 4 do fl(c, R(c, x0, y, x1, y), "#2a1a10") end
    c:outline(R(c, x0, ya, x1, yb))
  end
  mat(30, 44, 24, 44, { "#c0442e", "#f4eee0", "#2f5a8a" })
  mat(48, 62, 24, 42, { "#e8a317", "#3f6a8a", "#f4eee0" })
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 11, 14 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  c:fill(c:line({ { 25, 33 }, { 31, 28 } }, 1), "#6b3b2a")
  -- dust clouds blown to the right, with wind dashes
  for _, p in ipairs({ { 38, 30, 4 }, { 44, 26, 3 }, { 52, 32, 4 }, { 58, 28, 3 }, { 40, 40, 3 }, { 56, 38, 3 }, { 64, 30, 3 }, { 34, 46, 3 }, { 48, 47, 3 }, { 62, 46, 3 } }) do
    puff(c, p[1], p[2], p[3], "#d88a50"); c:px(p[1] - 1, p[2] - 1, "#e8a870")
  end
  for _, y in ipairs({ 16, 20, 28 }) do fl(c, R(c, 8 + y, y, 16 + y, y), "#f4dcc0") end
  finish(c, "r_wca_dust_mats")
end

-- market drum: gnome drumming a big laced drum, hungry eyes on the stew pot
function S.r_wca_market_drum()
  seed = 67
  local c = new()
  day(c, 30, { cloud = 56, sky = { "#a8d4e0", "#c4e0e4", "#e0ecd8" }, grass = "#c9a050", edge = "#d9b46a", hill = "#7a9a40", hill2 = "#6a8a38" })
  c:fill(R(c, 0, 30, W - 1, H - 1), "#c9a050"); c:fill(R(c, 0, 30, W - 1, 30), "#d9b46a")
  -- stalls with awnings
  local function stall(x0, x1, col1, col2)
    part(c, R(c, x0 + 1, 18, x0 + 2, 36), "#6b4a2e", { noline = true }); part(c, R(c, x1 - 2, 18, x1 - 1, 36), "#6b4a2e", { noline = true })
    local n = 0
    for x = x0, x1 - 1, 3 do fl(c, R(c, x, 13, x + 2, 19), (n % 2 == 0) and col1 or col2); n = n + 1 end
    c:outline(R(c, x0, 13, x1 - 1, 19))
    part(c, R(c, x0 + 1, 31, x1 - 2, 35), "#a8703e")
  end
  stall(5, 30, "#c0442e", "#f4eee0"); stall(44, 68, "#2f8a8a", "#f5cf6a")
  -- stew pot on the left stall
  pot(c, 18, 29, 5, 3, "#3a2a22", "#6b4a3a")
  c:fill(c:ellipse(18, 27, 3, 1), "#c4623a"); puff(c, 17, 22, 1); puff(c, 19, 19, 2)
  part(c, R(c, 8, 28, 11, 30), "#f4eee0"); fl(c, R(c, 9, 28, 10, 28), "#c4623a")
  -- the drum
  part(c, R(c, 31, 33, 41, 47), "#8a4a2a", { shade = true })
  fl(c, R(c, 31, 33, 41, 34), "#8a4a2a")
  part(c, c:ellipse(36, 33, 6, 2), "#f0d9a0")
  for x = 32, 40, 2 do fl(c, R(c, x, 36, x + 1, 37), "#f4eee0"); fl(c, R(c, x + 1, 38, x + 2, 39), "#f4eee0") end
  fl(c, R(c, 31, 44, 41, 44), "#5e2f1e")
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 11, 13 }, true), arm({ -4, 9 }, { -2, 12 }, false) } })
  c:fill(c:line({ { 33, 28 }, { 36, 32 } }, 1), "#e0c88a"); c:fill(c:line({ { 38, 28 }, { 36, 32 } }, 1), "#e0c88a")
  -- sound arcs
  for i = 0, 2 do for _, s in ipairs({ -1, 1 }) do fl(c, R(c, 36 + s * (8 + i * 3), 30 - i * 2, 36 + s * (8 + i * 3), 32 - i * 2), "#fff1c8") end end
  for _, p in ipairs({ { 56, 47 }, { 62, 45 }, { 52, 44 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#c4623a", { shade = true }) end
  finish(c, "r_wca_market_drum")
end

-- mangrove maze: misty channels between stilt roots, gnome poling a little boat
function S.r_wca_mangrove_maze()
  seed = 68
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#b8c8c4", "#c4d2cc", "#d0dcd4", "#dce4da" }, { dir = "v" })
  c:bands(R(c, 0, 28, W - 1, H - 1), { "#a8bcc0", "#98b0b8", "#88a4b0", "#7898a8" }, { dir = "v" })
  local function mang(x, yb, w, h, col, cr)
    part(c, c:ellipse(x, yb - h, w, h * 0.45):clip(R(c, 0, 0, W, yb)), cr, { noline = true })
    for k = -2, 2 do
      local ex = x + k * floor(w / 2.2)
      c:fill(c:line({ { x + floor(k * 1.2), yb - floor(h * 0.7) }, { ex, yb } }, 1), col)
    end
  end
  mang(10, 30, 9, 14, "#9aaaa0", "#9ab0a4"); mang(30, 31, 8, 12, "#9aaaa0", "#9ab0a4"); mang(54, 30, 9, 14, "#9aaaa0", "#9ab0a4")
  mang(66, 31, 7, 12, "#9aaaa0", "#9ab0a4")
  mang(20, 36, 11, 18, "#5e7a58", "#6a8a62"); mang(50, 37, 11, 18, "#5e7a58", "#6a8a62")
  mang(5, 46, 12, 26, "#3f5a40", "#4a6a4c"); mang(68, 46, 12, 26, "#3f5a40", "#4a6a4c")
  -- ripples
  for _, p in ipairs({ { 14, 40 }, { 26, 47 }, { 40, 42 }, { 58, 46 }, { 62, 40 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#c4d8dc") end
  -- boat + gnome with pole
  part(c, c:poly({ { 24, 42 }, { 48, 42 }, { 44, 47 }, { 28, 47 } }), "#8a5a35")
  fl(c, R(c, 26, 42, 46, 42), "#a8703e")
  gnome(c, 36, 43, { d = 1, upper = false, eyes = "open", arms = { arm({ 4, 8 }, { 8, 12 }, true), arm({ -4, 7 }, { -3, 10 }, false) } })
  c:fill(c:line({ { 46, 20 }, { 45, 50 } }, 1), "#6b4a2e")
  fl(c, R(c, 42, 49, 49, 49), "#c4d8dc")
  -- fog wisps in front
  for _, p in ipairs({ { 12, 24, 7 }, { 54, 22, 8 }, { 34, 34, 8 }, { 62, 34, 6 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2] + 1), "#e8eee8") end
  finish(c, "r_wca_mangrove_maze")
end

---------------------------------------------------------------- scenes B
-- surf launch: gnome shoves the painted canoe into the breakers from the stern
function S.r_wca_surf_launch()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#8fcbe0", "#a8d8e4", "#c4e4e6" }, { dir = "v" })
  c:fill(c:ellipse(60, 8, 7, 2), "#f4eee0")
  c:bands(R(c, 0, 20, W - 1, 36), { "#2f8aa8", "#3a9ab8", "#4aaac4", "#5abad0" }, { dir = "v" })
  -- breakers: foam bands
  for _, b in ipairs({ { 4, 22, 20 }, { 34, 24, 26 }, { 8, 28, 22 }, { 40, 30, 24 }, { 14, 34, 18 } }) do
    fl(c, R(c, b[1], b[2], b[1] + b[3], b[2]), "#f4f8fa"); fl(c, R(c, b[1] + 2, b[2] + 1, b[1] + b[3] - 3, b[2] + 1), "#a8e0e8")
  end
  fl(c, R(c, 0, 37, W - 1, 38), "#f4f8fa")
  -- sand, wet edge
  c:fill(R(c, 0, 39, W - 1, H - 1), "#e8d098"); c:fill(R(c, 0, 39, W - 1, 41), "#c8aa72")
  for _, p in ipairs({ { 8, 46 }, { 22, 49 }, { 50, 48 }, { 62, 45 } }) do c:px(p[1], p[2], "#c8aa72"); c:px(p[1] + 1, p[2], "#c8aa72") end
  -- palm on the left
  c:fill(c:line({ { 9, 40 }, { 8, 20 } }, 2), "#7a5a38")
  for _, f in ipairs({ { -7, 3 }, { 7, 3 }, { -5, -2 }, { 6, -2 }, { 0, -4 } }) do c:fill(c:line({ { 8, 19 }, { 8 + f[1], 19 + f[2] } }, 2), "#3f8a42") end
  -- the canoe, painted bands, bow in the surf
  local hull = c:poly({ { 20, 40 }, { 64, 31 }, { 66, 34 }, { 54, 44 }, { 24, 47 } })
  part(c, hull, "#c0442e")
  c:fill(hull:copy():clip(c:poly({ { 30, 30 }, { 38, 30 }, { 34, 50 }, { 26, 50 } })), "#f5cf6a")
  c:fill(hull:copy():clip(c:poly({ { 46, 30 }, { 52, 30 }, { 48, 50 }, { 42, 50 } })), "#2f8a8a")
  fl(c, c:line({ { 21, 41 }, { 65, 32 } }, 1), "#8e2e1e")
  fl(c, R(c, 56, 44, 66, 45), "#f4f8fa")
  gnome(c, 13, 47, { d = 1, eyes = "open", arms = { arm({ 4, 5 }, { 10, 8 }, true), arm({ -4, 5 }, { 2, 3 }, false) } })
  c:px(10, 49, "#c8aa72"); c:px(16, 49, "#c8aa72")
  finish(c, "r_wca_surf_launch")
end

-- gorilla glade: gnome sits mossy and still at dawn while a gorilla family feeds
function S.r_wca_gorilla_glade()
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#f0c8a0", "#f4d8a8", "#e8dcb0", "#c8d8a8", "#a8c898" }, { dir = "v" })
  for x = 4, 66, 7 do part(c, R(c, x, 5, x + 1 + (x % 3), 36), "#4a5a3a", { noline = true }) end
  for _, p in ipairs({ { 8, 8 }, { 24, 6 }, { 44, 7 }, { 62, 9 } }) do c:fill(c:ellipse(p[1], p[2], 9, 4), "#3f6a3a") end
  c:fill(R(c, 0, 33, W - 1, H - 1), "#5e8a44"); c:fill(R(c, 0, 33, W - 1, 34), "#8ab060")
  c:fill(c:ellipse(30, 40, 28, 5), "#6a9a4c")
  for _, p in ipairs({ { 10, 14 }, { 40, 22 }, { 56, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 12, p[2]), "#f4e8c8") end
  -- gorilla (right), with a leaf
  local DK, MD, FC = "#2c2c36", "#3e3e4a", "#6a6a76"
  -- big gorilla (right): wide body, head forward, long arms, a leaf at its mouth
  part(c, c:ellipse(58, 40, 10, 9), DK, { shade = true })
  part(c, c:line({ { 51, 33 }, { 47, 47 } }, 4), DK, { noline = true })
  part(c, c:ellipse(53, 28, 5, 5), MD, { shade = true })
  part(c, c:ellipse(53, 23, 3, 2), DK, { noline = true })
  c:fill(R(c, 49, 28, 52, 31), FC); c:px(50, 27, "#f4eee0"); c:px(53, 27, "#f4eee0"); fl(c, R(c, 49, 26, 54, 26), "#1c1c24")
  part(c, c:line({ { 66, 34 }, { 68, 47 } }, 3), DK, { noline = true })
  fl(c, R(c, 47, 30, 49, 31), "#4e9a48"); fl(c, R(c, 46, 29, 48, 29), "#7ab55c")
  part(c, c:line({ { 55, 34 }, { 50, 31 } }, 2), DK, { noline = true })
  -- baby gorilla
  part(c, c:ellipse(39, 44, 4, 3), DK, { shade = true })
  part(c, c:ellipse(36, 41, 3, 3), MD, { shade = true }); c:fill(R(c, 34, 41, 36, 42), FC); c:px(35, 40, "#f4eee0")
  -- gnome sitting like a stone, moss on hat and shoulders
  local _, G = gnome(c, 22, 47, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 6 }, { 6, 3 }, true) } })
  local mc = { "#5e9a48", "#7ab55c" }
  G.hat:each(function(x, y) if (x * 3 + y * 5) % 7 == 0 then c:px(x, y, mc[1]) end end)
  for _, p in ipairs({ { 18, 38 }, { 19, 39 }, { 26, 38 }, { 25, 37 }, { 18, 41 }, { 21, 29 }, { 24, 30 } }) do c:px(p[1], p[2], mc[2]) end
  for _, p in ipairs({ { 10, 44 }, { 12, 47 }, { 34, 49 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#8ab060") end
  finish(c, "r_wca_gorilla_glade")
end

-- rain gourds: downpour from a thatched eave, gnome holds a calabash under the spout
function S.r_wca_rain_gourds()
  seed = 71
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#7a8a9a", "#8a9aa8", "#98a8b4", "#a8b6bf" }, { dir = "v" })
  c:fill(c:ellipse(16, 8, 10, 3), "#6a7888"); c:fill(c:ellipse(52, 6, 12, 3), "#6a7888")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#b8562e"); c:fill(R(c, 0, 34, W - 1, 35), "#c8683a")
  c:fill(c:ellipse(30, 47, 22, 3), "#4a7a98"); c:fill(c:ellipse(30, 47, 12, 1), "#8ab4c8")
  -- hut
  part(c, R(c, 44, 22, 68, 40), "#c0804a")
  part(c, R(c, 52, 28, 58, 40), "#5e3f28")
  part(c, c:poly({ { 56, 8 }, { 71, 24 }, { 41, 24 } }), "#c8a050")
  for y = 12, 22, 3 do fl(c, R(c, 44 + (y - 12), y, 68 - (y - 12), y), "#a88438") end
  -- stream from the eave
  fl(c, R(c, 44, 24, 45, 24), "#8ab4d8")
  fl(c, R(c, 44, 25, 44, 36), "#a8d4ec"); fl(c, R(c, 45, 27, 45, 34), "#8ab4d8")
  -- gourds on the ground
  local function gourd(x, y, full)
    part(c, c:ellipse(x, y, 3, 3), "#d9a660", { shade = true }); part(c, R(c, x - 1, y - 6, x, y - 3), "#d9a660", { noline = true })
    fl(c, R(c, x - 1, y - 6, x, y - 6), "#8a5a2a")
    if full then c:fill(R(c, x - 1, y - 6, x, y - 5), "#7ab4d8") end
  end
  gourd(54, 48, true); gourd(62, 47, true); gourd(10, 47, false)
  gnome(c, 34, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 14 }, true, true) } })
  c:fill(R(c, 40, 17, 46, 21), "#8a5a2a")
  part(c, c:ellipse(43, 21, 4, 3), "#d9a660", { shade = true })
  c:fill(R(c, 41, 19, 45, 19), "#7ab4d8")
  rain(c, 55, "#dfeaf2")
  for _, p in ipairs({ { 14, 36 }, { 24, 40 }, { 60, 44 } }) do fl(c, R(c, p[0 + 1] - 1, p[2], p[1] + 1, p[2]), "#c8dce8") end
  finish(c, "r_wca_rain_gourds")
end

-- indigo vat: lifting green cloth from the vat, it turns blue as it hits the air
function S.r_wca_indigo_vat()
  seed = 72
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#a8d4e0", "#c4e0e4", "#e0ecd8" }, { dir = "v" })
  c:fill(R(c, 0, 34, W - 1, H - 1), "#c9a070"); c:fill(R(c, 0, 34, W - 1, 34), "#d9b888")
  -- drying line with finished cloths
  part(c, R(c, 4, 12, 5, 36), "#6b4a2e", { noline = true }); part(c, R(c, 66, 12, 67, 36), "#6b4a2e", { noline = true })
  fl(c, R(c, 5, 13, 66, 13), "#8a5a35")
  local cl = { { 8, 20, "#2f4a98" }, { 20, 16, "#3a62b0" }, { 52, 22, "#1f3a78" }, { 61, 18, "#4a78c0" } }
  for _, k in ipairs(cl) do
    part(c, R(c, k[1], 14, k[1] + 7, 14 + k[2] - 8), k[3])
    fl(c, R(c, k[1] + 2, 17, k[1] + 5, 17), "#f4eee0"); fl(c, R(c, k[1] + 3, 16, k[1] + 4, 18), "#f4eee0")
  end
  -- vat
  part(c, R(c, 40, 38, 56, 49), "#8a4a2a", { shade = true })
  part(c, c:ellipse(48, 38, 9, 3), "#6b3b2a")
  c:fill(c:ellipse(48, 38, 7, 2), "#14204a"); fl(c, R(c, 44, 38, 47, 38), "#3a4a8a")
  for x = 41, 55, 4 do fl(c, R(c, x, 42, x, 47), "#6b3b2a") end
  -- the gnome hauls cloth up on a stick
  gnome(c, 26, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 10, 14 }, true), arm({ -4, 7 }, { 0, 12 }, false) } })
  c:fill(c:line({ { 35, 24 }, { 43, 27 } }, 1), "#8a5a35")
  -- cloth: green at the top turning blue below it
  local cols = { "#6a9a58", "#4a8a78", "#3a78a0", "#2f5a98", "#1f3a78" }
  for i, col in ipairs(cols) do
    local y0 = 24 + (i - 1) * 3
    part(c, R(c, 39, y0, 47, y0 + 3), col, { noline = true })
  end
  c:outline(R(c, 39, 24, 47, 37))
  fl(c, R(c, 46, 36, 47, 38), "#1f3a78"); fl(c, R(c, 42, 38, 42, 39), "#14204a")
  c:px(41, 40, "#3a4a8a"); c:px(44, 40, "#3a4a8a")
  finish(c, "r_wca_indigo_vat")
end

-- shea butter: kneading the pale fat in a wooden bowl, nuts and pestle at hand
function S.r_wca_shea_butter()
  seed = 73
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 36), "#c0804a")
  for x = 0, 70, 6 do fl(c, R(c, x, 0, x, 36), "#a8683a") end
  part(c, R(c, 48, 6, 62, 20), "#a8d4e0"); fl(c, R(c, 54, 6, 55, 20), "#8a5a35"); fl(c, R(c, 48, 13, 62, 13), "#8a5a35")
  -- shelf with calabash jar
  part(c, R(c, 6, 14, 22, 15), "#8a5a35"); part(c, c:ellipse(12, 11, 3, 3), "#d9a660"); part(c, R(c, 16, 9, 20, 13), "#c4623a")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#8a5a35"); c:fill(R(c, 0, 36, W - 1, 38), "#a8703e")
  for y = 42, 50, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  gnome(c, 33, 38, { upper = true, s = 1.25, eyes = "open", arms = { arm({ -5, 5 }, { -8, 1 }, true, true), arm({ 5, 5 }, { 8, 1 }, true, true) } })
  -- bowl with pale fat
  part(c, c:ellipse(33, 43, 16, 4), "#6b3b2a", { shade = true })
  part(c, R(c, 18, 43, 48, 49), "#8a4a2a", { shade = true })
  fl(c, R(c, 18, 43, 48, 44), "#6b3b2a")
  c:fill(c:ellipse(33, 43, 13, 3), "#f4eee0"); c:fill(c:ellipse(30, 43, 8, 2), "#fff8e8"); c:fill(R(c, 36, 44, 41, 44), "#e8dcb8")
  -- kneading hands in the fat
  fl(c, R(c, 24, 41, 27, 43), "#f0c8a0"); fl(c, R(c, 39, 41, 42, 43), "#f0c8a0")
  c:outline(R(c, 24, 41, 27, 43)); c:outline(R(c, 39, 41, 42, 43))
  -- nuts pile + mortar and pestle
  for _, p in ipairs({ { 7, 46 }, { 11, 47 }, { 9, 44 }, { 14, 45 }, { 5, 49 }, { 13, 49 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#5e3f28") end
  part(c, c:rrect(54, 40, 65, 49, 2), "#8b8f96", { shade = true }); c:fill(c:ellipse(59, 41, 4, 1), "#4a4e56")
  part(c, c:line({ { 62, 41 }, { 66, 30 } }, 2), "#6b4a2e")
  c:px(23, 36, "#fff8e0")
  puff(c, 52, 36, 1, "#f4f8fa")
  finish(c, "r_wca_shea_butter")
end

-- shell egusi: sitting by the spring, pinching seeds into a bowl while a rival sheller races on
function S.r_wca_shell_egusi()
  seed = 74
  local c = new()
  day(c, 33, { cloud = 50, grass = "#c9a050", edge = "#d9b46a", hill = "#7a9a40", hill2 = "#6a8a38" })
  c:fill(R(c, 0, 33, W - 1, H - 1), "#c9a050")
  -- spring pool with rim, flat white seeds drying on a cloth
  part(c, c:ellipse(52, 36, 14, 4), "#8b8f96", { shade = true }); c:fill(c:ellipse(52, 36, 11, 3), "#5ab4c8"); fl(c, R(c, 47, 36, 53, 36), "#b8e8e0")
  -- rotten melon heap
  for _, p in ipairs({ { 8, 41 }, { 14, 42 }, { 11, 38 } }) do part(c, c:ellipse(p[1], p[2], 4, 3), "#a8b040", { shade = true }); fl(c, R(c, p[1] - 2, p[2], p[1] + 1, p[2]), "#6a7a28") end
  -- rival gnome in the background racing
  gnome(c, 40, 42, { s = 0.7, d = -1, sit = true, hat = "#3f8a5a", eyes = "open", arms = { arm({ -3, 6 }, { -5, 3 }, true) } })
  -- the sheller on a stool, a seed between thumb and finger, bowl of white seeds in front
  part(c, R(c, 18, 38, 29, 47), "#8a5a35"); fl(c, R(c, 18, 38, 29, 39), "#a8703e")
  gnome(c, 24, 38, { d = 1, s = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 8, 5 }, true) } })
  part(c, c:ellipse(50, 47, 8, 2), "#8a4a2a", { shade = true })
  part(c, R(c, 43, 44, 57, 48), "#8a4a2a", { shade = true }); c:fill(c:ellipse(50, 44, 7, 2), "#f4eee0")
  for x = 46, 54, 2 do c:px(x, 44, "#fff8e8") end
  for _, p in ipairs({ { 33, 46 }, { 36, 47 }, { 39, 45 }, { 62, 47 }, { 65, 45 } }) do c:px(p[1], p[2], "#e8c48a"); c:px(p[1] + 1, p[2], "#f4eee0") end
  finish(c, "r_wca_shell_egusi")
end

-- ember yams: charred yam split open, steam rising, buried yams in the glowing pit
function S.r_wca_ember_yams()
  seed = 75
  local c = new()
  day(c, 33, { cloud = 14, sky = { "#9ccce0", "#b4d8e0", "#d0e4dc" }, hill = "#5e8a44", hill2 = "#4e8a3c", grass = "#8aa860", edge = "#a8c070" })
  -- tent at the back
  part(c, c:poly({ { 54, 14 }, { 68, 33 }, { 40, 33 } }), "#e8d2a0"); c:fill(c:poly({ { 54, 22 }, { 58, 33 }, { 50, 33 } }), "#6b3b2a")
  -- embers pit with ash ring
  part(c, c:ellipse(49, 45, 14, 4), "#8b8f96", { shade = true })
  c:fill(c:ellipse(49, 45, 11, 3), "#3a2a22")
  for x = 40, 58 do if (x * 7) % 5 < 3 then c:px(x, 44 + (x % 2), "#e0501f") end end
  for x = 41, 57, 4 do c:px(x, 45, "#ffd86a") end
  fl(c, R(c, 44, 44, 47, 45), "#6a2a1a"); fl(c, R(c, 52, 45, 55, 46), "#6a2a1a")
  for _, p in ipairs({ { 45, 38 }, { 51, 36 }, { 56, 40 } }) do c:px(p[1], p[2], "#f08a24") end
  -- log seat
  part(c, R(c, 5, 43, 17, 47), "#8a5a35"); fl(c, R(c, 6, 43, 16, 43), "#a8703e")
  -- gnome holds up a split yam: charred skin, fluffy white inside
  gnome(c, 28, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 8, 13 }, true, true), arm({ -4, 8 }, { 9, 13 }, false, true) } })
  part(c, c:ellipse(37, 25, 5, 3), "#2a2224"); c:fill(c:ellipse(37, 25, 4, 2), "#fff8e8"); c:fill(R(c, 33, 24, 41, 24), "#e8dcb8")
  c:px(34, 27, "#4a3a2a"); c:px(40, 28, "#4a3a2a")
  fl(c, R(c, 33, 27, 34, 28), "#f0c8a0"); fl(c, R(c, 40, 27, 41, 28), "#f0c8a0")
  puff(c, 36, 20, 2); puff(c, 39, 16, 2); puff(c, 36, 12, 1)
  finish(c, "r_wca_ember_yams")
end

-- egusi soup: stirring a big clay pot of thick green soup at the inn hearth
function S.r_wca_egusi_soup()
  seed = 76
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#c0804a")
  for x = 0, 70, 6 do fl(c, R(c, x, 0, x, 38), "#a8683a") end
  fl(c, R(c, 0, 12, W - 1, 12), "#6b3b2a")
  -- shelf with okra pods and a jar
  part(c, R(c, 6, 19, 26, 20), "#8a5a35")
  for i = 0, 4 do part(c, c:poly({ { 8 + i * 3, 15 }, { 11 + i * 3, 15 }, { 10 + i * 3, 19 } }), "#4e9a48", { noline = true }) end
  part(c, R(c, 28, 12, 33, 19), "#d9a660"); fl(c, R(c, 29, 11, 32, 11), "#8a5a2a")
  part(c, R(c, 44, 8, 60, 20), "#e8d2a0"); fl(c, R(c, 45, 12, 59, 12), "#c9a96e")  -- little window
  c:fill(R(c, 0, 38, W - 1, H - 1), "#8a6a50")
  for y = 42, 50, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b4a38") end
  -- hearth of clay bricks with fire
  part(c, R(c, 36, 36, 64, 49), "#a85a3a")
  for y = 38, 48, 3 do fl(c, R(c, 36, y, 64, y), "#8a4a2a") end
  c:fill(c:poly({ { 42, 49 }, { 46, 40 }, { 54, 40 }, { 58, 49 } }), "#2a1a10")
  c:fill(c:poly({ { 46, 49 }, { 50, 41 }, { 54, 49 } }), "#e0501f"); c:fill(c:poly({ { 48, 49 }, { 50, 44 }, { 52, 49 } }), "#ffd86a")
  -- big pot, green soup visible, okra on top
  part(c, c:ellipse(50, 30, 15, 8), "#3a2a22", { shade = true })
  part(c, R(c, 36, 27, 64, 37), "#6a3a2a", { shade = true })
  fl(c, R(c, 36, 27, 64, 28), "#4a2a1a")
  part(c, c:ellipse(50, 27, 14, 3), "#4a2a1a")
  c:fill(c:ellipse(50, 27, 12, 2), "#4e9a48"); c:fill(c:ellipse(48, 27, 7, 1), "#7ab55c")
  for _, p in ipairs({ { 42, 27 }, { 54, 27 }, { 58, 26 } }) do c:px(p[1], p[2], "#a8d070") end
  puff(c, 46, 19, 2); puff(c, 52, 15, 2); puff(c, 48, 11, 1)
  -- gnome stirring with a long paddle
  gnome(c, 23, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 12 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  c:fill(c:line({ { 32, 30 }, { 47, 28 } }, 1), "#e0c88a"); fl(c, R(c, 45, 27, 48, 28), "#e0c88a")
  part(c, c:ellipse(13, 46, 4, 2), "#f4eee0"); part(c, c:ellipse(7, 48, 3, 2), "#d9a660")
  finish(c, "r_wca_egusi_soup")
end

---------------------------------------------------------------- scenes C
-- roselle cordial: dipping honey into a pitcher of sunset-red steeped calyces
function S.r_wca_roselle_cordial()
  seed = 77
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#9ccce0", "#c4dce0", "#f0dcc0", "#f4c8a0" }, { dir = "v" })
  c:fill(c:ellipse(60, 28, 14, 5), "#8aaa58"); c:fill(c:ellipse(12, 30, 22, 6), "#7a9a48")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#8aa860"); c:fill(R(c, 0, 32, W - 1, 32), "#a8c070")
  -- roselle bush with red calyces
  for _, p in ipairs({ { 8, 27 }, { 16, 24 }, { 62, 25 }, { 54, 28 } }) do
    fl(c, R(c, p[1], p[2], p[1], 36), "#4a7a3a")
    for _, q in ipairs({ { -2, 2 }, { 2, 5 }, { -2, 8 } }) do part(c, c:ellipse(p[1] + q[1], p[2] + q[2], 2, 2), "#c0182e", { noline = true }); c:px(p[1] + q[1], p[2] + q[2] - 1, "#e8485a") end
    c:fill(c:ellipse(p[1], p[2] - 2, 3, 2), "#4a8a3c")
  end
  -- table
  part(c, R(c, 28, 38, 66, 40), "#a8703e"); part(c, R(c, 30, 40, 31, 49), "#6b3b2a", { noline = true }); part(c, R(c, 63, 40, 64, 49), "#6b3b2a", { noline = true })
  -- big glass pitcher of red cordial
  part(c, R(c, 36, 24, 48, 38), "#a02030")
  c:fill(R(c, 37, 25, 39, 37), "#d84a5a"); c:fill(R(c, 36, 24, 48, 25), "#f4c8c8")
  part(c, R(c, 49, 26, 52, 33), "#a02030", { noline = true }); c:fill(R(c, 50, 28, 51, 31), "#8a5a35")
  c:px(44, 28, "#f4eee0"); c:px(41, 33, "#f4eee0")
  -- honey jar and little glasses
  part(c, R(c, 56, 31, 62, 38), "#e8a317"); c:fill(R(c, 57, 32, 58, 36), "#ffd86a"); part(c, R(c, 56, 29, 62, 30), "#8a5a2a")
  part(c, R(c, 31, 33, 34, 38), "#b83040"); part(c, R(c, 53, 34, 55, 38), "#b83040")
  gnome(c, 18, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 9 }, { 9, 17 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  -- honey dipper held over the pitcher, a drop falling
  c:fill(c:line({ { 28, 29 }, { 38, 20 } }, 1), "#8a5a35"); part(c, c:ellipse(40, 19, 2, 2), "#e8a317", { noline = true })
  fl(c, R(c, 41, 21, 41, 22), "#ffd86a"); c:px(41, 24, "#ffd86a")
  for _, p in ipairs({ { 8, 38 }, { 12, 43 } }) do part(c, R(c, p[1], p[2], p[1] + 5, p[2] + 2), "#a02030"); c:px(p[1] + 1, p[2], "#d84a5a") end
  finish(c, "r_wca_roselle_cordial")
end

-- mud walls: the whole village plasters the library wall from a pole scaffold
function S.r_wca_mud_walls()
  seed = 78
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 12), { "#8fcbe0", "#a8d8e4", "#c4e4e6" }, { dir = "v" })
  -- wall with pinnacles
  for x = 8, 66, 18 do part(c, c:poly({ { x + 3, 6 }, { x + 8, 14 }, { x - 2, 14 } }), "#c8905e", { noline = true }); fl(c, R(c, x + 3, 5, x + 3, 6), "#e8d2a0") end
  part(c, R(c, 4, 13, 69, 49), "#c8905e", { noline = true })
  c:fill(R(c, 5, 13, 68, 14), "#d8a870")
  for x = 10, 66, 8 do fl(c, R(c, x, 15, x, 46), "#b87c4a") end
  -- protruding pole stubs
  for x = 8, 66, 9 do for _, y in ipairs({ 18, 40 }) do part(c, R(c, x, y, x + 2, y + 1), "#6b4a2e", { noline = true }); fl(c, R(c, x + 3, y, x + 3, y + 1), "#3a2a1c") end end
  -- fresh pale plaster patch with trowel smears
  c:fill(R(c, 30, 24, 52, 34), "#e8c898")
  for y = 25, 33, 3 do fl(c, R(c, 31, y, 51, y), "#d8b888") end
  c:outline(R(c, 30, 24, 52, 34))
  -- scaffold plank on poles
  part(c, R(c, 8, 36, 56, 37), "#8a5a35"); c:fill(R(c, 8, 36, 56, 36), "#a8703e")
  part(c, R(c, 10, 38, 11, 49), "#6b4a2e", { noline = true }); part(c, R(c, 54, 38, 55, 49), "#6b4a2e", { noline = true })
  fl(c, R(c, 10, 43, 55, 44), "#6b4a2e")
  -- gnome plastering, bucket on the plank
  gnome(c, 26, 36, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 9, 12 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  part(c, R(c, 40, 31, 47, 36), "#8a5a35"); c:fill(R(c, 41, 31, 46, 32), "#a8703e"); c:fill(R(c, 40, 30, 47, 31), "#6b3b2a")
  c:fill(c:line({ { 41, 30 }, { 43, 25 }, { 46, 30 } }, 1), "#3a2a1c")
  part(c, R(c, 36, 28, 38, 29), "#d8b888", { noline = true }); c:px(37, 27, "#d8b888")
  -- villagers far left on a second plank, tiny
  gnome(c, 14, 28, { s = 0.5, d = 1, hat = "#4f9a45", upper = true, eyes = "open" })
  for _, p in ipairs({ { 62, 48 }, { 48, 49 } }) do c:fill(c:ellipse(p[1], p[2], 3, 1), "#a8703e") end
  finish(c, "r_wca_mud_walls")
end

-- yam mounds: gnome heaping a tall soft hill with a long hoe, stakes ready
function S.r_wca_yam_mounds()
  seed = 79
  local c = new()
  day(c, 31, { cloud = 50, sky = { "#9fd0e0", "#bcdde0", "#dce8d0" }, hill = "#7a9a40", hill2 = "#6a8a38", grass = "#b8602e", edge = "#c8743a" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#a85a30"); c:fill(R(c, 0, 31, W - 1, 31), "#b8683a")
  for i = 0, 3 do fl(c, R(c, 4 + i * 5, 36 + i * 3, 12 + i * 5, 36 + i * 3), "#8a4a28") end
  -- finished mounds with stakes and vines
  local function mound(x, y, w, h, vine)
    part(c, c:ellipse(x, y, w, h):clip(R(c, 0, 0, W, y)), "#8a4a2a", { shade = true })
    c:fill(c:ellipse(x - 2, y - floor(h / 2), floor(w / 3), 1), "#a8603a")
    part(c, R(c, x, y - h - 9, x, y - 2), "#6b4a2e", { noline = true })
    if vine then for k = 0, 2 do c:px(x - 1, y - h - 5 + k * 3, "#4e9a48"); c:px(x + 1, y - h - 6 + k * 3, "#4e9a48") end end
  end
  mound(46, 37, 8, 7, true); mound(60, 36, 7, 6, true); mound(52, 46, 9, 7, false)
  mound(64, 47, 6, 5, false)
  -- the mound being built, gnome hoeing soil up
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 3 }, true), arm({ -3, 8 }, { 5, 8 }, false) } })
  c:fill(c:line({ { 24, 33 }, { 34, 44 } }, 1), "#8a5a35"); part(c, R(c, 34, 44, 37, 46), "#8b929c")
  part(c, c:ellipse(40, 47, 6, 3), "#8a4a2a", { shade = true })
  for _, p in ipairs({ { 36, 41 }, { 40, 42 }, { 38, 39 } }) do c:px(p[1], p[2], "#a8603a") end
  fl(c, R(c, 3, 44, 5, 44), "#c8743a"); c:px(10, 49, "#8a4a28")
  finish(c, "r_wca_yam_mounds")
end

-- rainy weeds: okra rows drowning in green, the gnome wrenching up a big clump
function S.r_wca_rainy_weeds()
  seed = 80
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#6a7684", "#7a8694", "#8a96a2", "#9aa6b0" }, { dir = "v" })
  c:fill(c:ellipse(18, 10, 12, 3), "#5a6674"); c:fill(c:ellipse(56, 8, 14, 3), "#5a6674")
  c:fill(c:ellipse(14, 29, 22, 5), "#4e6a3a"); c:fill(c:ellipse(60, 30, 22, 4), "#4a6836")
  c:fill(R(c, 0, 28, W - 1, H - 1), "#6a3a28"); c:fill(R(c, 0, 28, W - 1, 28), "#7a4a34")
  for y = 34, 48, 5 do fl(c, R(c, 0, y, W - 1, y), "#583020") end
  -- okra plants almost hidden by a green tangle
  local function okra(x, yb, h)
    fl(c, R(c, x, yb - h, x, yb), "#4a7a3a")
    c:fill(c:ellipse(x - 2, yb - h + 2, 2, 1), "#5e9a48"); c:fill(c:ellipse(x + 2, yb - h + 4, 2, 1), "#5e9a48")
    part(c, c:poly({ { x + 1, yb - h + 6 }, { x + 3, yb - h + 6 }, { x + 2, yb - h + 10 } }), "#7ab55c", { noline = true })
  end
  for _, p in ipairs({ { 8, 38, 10 }, { 38, 40, 11 }, { 50, 37, 10 }, { 64, 39, 10 } }) do okra(p[1], p[2], p[3]) end
  local function weed(x, y, r)
    part(c, c:ellipse(x, y, r, floor(r * 0.7)), "#4e9a48", { shade = true })
    c:fill(c:ellipse(x - 1, y - 1, floor(r / 2), 1), "#7ab55c")
  end
  for _, p in ipairs({ { 10, 44, 6 }, { 26, 46, 5 }, { 44, 46, 6 }, { 58, 45, 6 }, { 8, 38, 4 }, { 38, 41, 5 }, { 50, 40, 5 }, { 64, 41, 4 } }) do weed(p[1], p[2], p[3]) end
  -- gnome yanking a clump with both hands, roots dangling
  gnome(c, 30, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 12 }, true, true), arm({ -4, 7 }, { 6, 12 }, false, true) } })
  weed(40, 33, 5)
  fl(c, R(c, 36, 36, 36, 38), "#8a5a35"); fl(c, R(c, 40, 37, 40, 39), "#8a5a35"); fl(c, R(c, 43, 36, 43, 38), "#8a5a35")
  fl(c, R(c, 36, 38, 37, 38), "#6b3b2a"); c:px(39, 40, "#6b3b2a")
  rain(c, 50, "#d0e0ea")
  finish(c, "r_wca_rainy_weeds")
end

-- smoke kiln: gnome on a stool adds a clay ring to the cracked round smoking oven, boats and drying fish behind
function S.r_wca_smoke_kiln()
  seed = 81
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#8fcbe0", "#a8d8e4", "#c4e4e6" }, { dir = "v" })
  c:bands(R(c, 0, 24, W - 1, 32), { "#3a9ab8", "#4aaac4", "#5abad0" }, { dir = "v" })
  fl(c, R(c, 8, 28, 24, 28), "#f4f8fa"); fl(c, R(c, 36, 30, 46, 30), "#f4f8fa")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#e8d098"); c:fill(R(c, 0, 32, W - 1, 33), "#c8aa72")
  -- boats in the distance
  part(c, c:poly({ { 48, 26 }, { 62, 26 }, { 59, 29 }, { 51, 29 } }), "#c0442e"); fl(c, R(c, 54, 20, 54, 26), "#6b4a2e"); c:fill(c:poly({ { 55, 20 }, { 60, 25 }, { 55, 25 } }), "#f4eee0")
  -- drying rack with fish on the right
  part(c, R(c, 51, 36, 52, 48), "#6b4a2e", { noline = true }); part(c, R(c, 66, 36, 67, 48), "#6b4a2e", { noline = true })
  part(c, R(c, 50, 36, 68, 37), "#8a5a35")
  for _, x in ipairs({ 54, 59, 64 }) do part(c, c:ellipse(x, 41, 1, 3), "#a8b0b8", { noline = true }); c:px(x, 38, "#2a1a10") end
  -- kiln: stacked clay rings, a crack, door arch, new ring on top
  local rings = { { 38, 49, "#b86a3a" }, { 33, 43, "#c07440" }, { 28, 37, "#b86a3a" } }
  for i, r in ipairs({ { 41, 49, 11, "#b86a3a" }, { 35, 41, 10, "#c07440" }, { 30, 35, 9, "#b86a3a" }, { 26, 29, 8, "#c07440" } }) do
    part(c, R(c, 30 - r[3], r[1], 30 + r[3], r[2] > 0 and r[1] + 7 or r[1]), r[4])
  end
  c:fill(R(c, 20, 41, 40, 48), "#b86a3a"); c:fill(R(c, 20, 40, 40, 40), "#d09060")
  c:fill(c:poly({ { 26, 48 }, { 28, 43 }, { 32, 43 }, { 34, 48 } }), "#2a1a10")
  c:fill(c:ellipse(30, 47, 2, 1), "#e0501f")
  for _, p in ipairs({ { 24, 36 }, { 25, 37 }, { 24, 38 }, { 36, 31 }, { 35, 32 } }) do c:px(p[1], p[2], "#6b3b2a") end
  -- the new ring: wet dark clay, a lump pressed on
  part(c, R(c, 22, 20, 38, 24), "#8a4a2a"); c:fill(R(c, 23, 20, 37, 20), "#a8603a")
  -- gnome on a stool
  part(c, R(c, 7, 40, 17, 47), "#8a5a35"); fl(c, R(c, 7, 40, 17, 41), "#a8703e")
  gnome(c, 12, 40, { d = 1, upper = false, eyes = "open", arms = { arm({ 4, 9 }, { 11, 14 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  part(c, c:ellipse(46, 47, 4, 2), "#8a4a2a", { shade = true })
  for _, p in ipairs({ { 28, 14, 3 }, { 31, 9, 2 }, { 28, 5, 2 } }) do puff(c, p[1], p[2], p[3], "#cfd4d8") end
  finish(c, "r_wca_smoke_kiln")
end

-- seed pits: an old board of little pits, a grandmother who never loses, sowing seeds
function S.r_wca_seed_pits()
  seed = 82
  local c = new()
  day(c, 31, { cloud = 14, sky = { "#9fd0e0", "#bcdde0", "#dce8d0" }, hill = "#7a9a40", hill2 = "#6a8a38", grass = "#c9a050", edge = "#d9b46a" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#c9a050")
  -- hut in background
  part(c, R(c, 44, 18, 66, 31), "#c0804a"); part(c, c:poly({ { 55, 7 }, { 69, 19 }, { 41, 19 } }), "#c8a050"); part(c, R(c, 52, 23, 57, 31), "#5e3f28")
  tree(c, 8, 33, 14, 7, 5, "#4e8a3c")
  -- mat + board in perspective
  part(c, c:poly({ { 14, 39 }, { 58, 39 }, { 63, 50 }, { 9, 50 } }), "#c0442e")
  fl(c, R(c, 12, 44, 60, 44), "#f5cf6a")
  part(c, c:poly({ { 23, 41 }, { 49, 41 }, { 52, 48 }, { 20, 48 } }), "#8a5a35")
  c:fill(c:poly({ { 24, 42 }, { 48, 42 }, { 50, 47 }, { 22, 47 } }), "#a8703e")
  for i = 0, 5 do
    local x = 26 + i * 4
    c:fill(c:ellipse(x + (i > 2 and 1 or 0), 43, 1, 1), "#3a2412"); c:fill(c:ellipse(x - 1 + (i > 2 and 2 or 0) , 46, 1, 1), "#3a2412")
  end
  for _, p in ipairs({ { 26, 43 }, { 38, 43 }, { 42, 43 }, { 25, 46 }, { 33, 46 }, { 37, 46 }, { 42, 46 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- the players: grandmother on the right never loses
  gnome(c, 62, 39, { d = -1, sit = true, hat = "#8a5aa0", eyes = "happy", arms = { arm({ -4, 6 }, { -9, 3 }, true) } })
  gnome(c, 10, 39, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 9, 5 }, true) } })
  -- seeds in the air
  for _, p in ipairs({ { 27, 38 }, { 29, 36 }, { 31, 37 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1] + 1, p[2], "#e8c48a") end
  finish(c, "r_wca_seed_pits")
end

-- clap and jump: a ring of children clapping while the gnome leaps and flings out a foot
function S.r_wca_clap_jump()
  seed = 83
  local c = new()
  day(c, 33, { cloud = 52, sky = { "#9fd0e0", "#bcdde0", "#dce8d0" }, hill = "#7a9a40", hill2 = "#6a8a38", grass = "#c9a050", edge = "#d9b46a" })
  c:fill(R(c, 0, 33, W - 1, H - 1), "#c9a050")
  part(c, c:poly({ { 12, 14 }, { 22, 33 }, { 2, 33 } }), "#e8d2a0"); c:fill(c:poly({ { 12, 22 }, { 15, 33 }, { 9, 33 } }), "#6b3b2a")
  tree(c, 64, 34, 14, 7, 5, "#4e8a3c")
  fl(c, c:ellipse(36, 48, 8, 2), "#a8803c")
  -- clappers
  gnome(c, 14, 47, { s = 0.85, d = 1, hat = "#e8a317", eyes = "open", arms = { arm({ 3, 8 }, { 8, 10 }, true), arm({ 3, 6 }, { 8, 11 }, true) } })
  gnome(c, 58, 47, { s = 0.85, d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -3, 8 }, { -8, 10 }, true), arm({ -3, 6 }, { -8, 11 }, true) } })
  gnome(c, 25, 49, { s = 0.7, d = 1, hat = "#3f6fb0", eyes = "happy", arms = { arm({ 3, 7 }, { 7, 9 }, true) } })
  -- the jumper, airborne, one foot flung out
  gnome(c, 38, 40, { d = 1, walk = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -9, 13 }, false), arm({ 4, 8 }, { 9, 13 }, true) } })
  for _, p in ipairs({ { 28, 39 }, { 29, 37 }, { 48, 39 }, { 47, 37 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2] + 1, "#fff1c8") end
  fl(c, R(c, 40, 20, 41, 20), "#fff1c8")
  finish(c, "r_wca_clap_jump")
end

-- dugout paddle race: two dugouts neck and neck, the ferry crowd cheering from the bank
function S.r_wca_paddle_race()
  seed = 84
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 14), { "#9fd0e0", "#bcdde0", "#dce8d0" }, { dir = "v" })
  c:fill(c:ellipse(60, 7, 8, 2), "#f4eee0")
  c:fill(R(c, 0, 14, W - 1, 20), "#6a9a48"); c:fill(R(c, 0, 14, W - 1, 14), "#8ab060")
  c:bands(R(c, 0, 20, W - 1, H - 1), { "#4aa8c8", "#3a98b8", "#2f88a8", "#2a7898" }, { dir = "v" })
  -- cheering crowd on the bank
  local hats = { "#e8a317", "#4f9a45", "#3f6fb0", "#c0442e", "#8a5aa0", "#e8825e" }
  for i = 0, 5 do
    local x = 8 + i * 11
    gnome(c, x, 20, { s = 0.5, d = 1, upper = true, hat = hats[i + 1], eyes = "open", arms = { arm({ 4, 7 }, { 6, 14 }, true) } })
  end
  fl(c, R(c, 36, 9, 36, 20), "#6b4a2e"); c:fill(c:poly({ { 37, 9 }, { 44, 11 }, { 37, 13 } }), "#dd3a2a")
  local function canoe(x0, x1, y, col)
    part(c, c:poly({ { x0, y }, { x1, y }, { x1 - 3, y + 4 }, { x0 + 4, y + 4 } }), col)
    fl(c, R(c, x0 + 1, y, x1 - 1, y), "#c8a870")
  end
  -- far dugout: rival
  canoe(30, 62, 30, "#8a5a35")
  gnome(c, 54, 30, { s = 0.9, d = 1, upper = true, hat = "#3f6fb0", eyes = "open", arms = { arm({ 4, 7 }, { 10, 4 }, true) } })
  c:fill(c:line({ { 53, 21 }, { 60, 33 } }, 1), "#e0c88a")
  fl(c, R(c, 20, 32, 29, 32), "#f4f8fa"); fl(c, R(c, 14, 35, 24, 35), "#c4e8f0")
  -- near dugout: the gnome digging deep
  canoe(20, 56, 42, "#c0442e")
  fl(c, R(c, 28, 43, 48, 43), "#f5cf6a")
  gnome(c, 46, 42, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 8 }, { 10, 4 }, true), arm({ -4, 8 }, { 2, 11 }, false) } })
  c:fill(c:line({ { 45, 28 }, { 53, 46 } }, 1), "#e0c88a"); part(c, R(c, 52, 46, 55, 49), "#e0c88a", { noline = true })
  fl(c, R(c, 8, 44, 19, 44), "#f4f8fa"); fl(c, R(c, 4, 47, 15, 47), "#c4e8f0"); fl(c, R(c, 55, 49, 60, 49), "#f4f8fa")
  finish(c, "r_wca_paddle_race")
end

local order = { "r_mena_hanging_garden", "r_mena_courtyard_nap", "r_wca_weaverbirds", "r_wca_hippo_count", "r_wca_canopy_bridge", "r_wca_dust_mats", "r_wca_market_drum", "r_wca_mangrove_maze",
  "r_wca_surf_launch", "r_wca_gorilla_glade", "r_wca_rain_gourds", "r_wca_indigo_vat", "r_wca_shea_butter", "r_wca_shell_egusi", "r_wca_ember_yams", "r_wca_egusi_soup",
  "r_wca_roselle_cordial", "r_wca_mud_walls", "r_wca_yam_mounds", "r_wca_rainy_weeds", "r_wca_smoke_kiln", "r_wca_seed_pits", "r_wca_clap_jump", "r_wca_paddle_race" }
for _, s2 in ipairs(order) do
  if (not only or only == s2) and S[s2] then seed = 7; S[s2]() end
end

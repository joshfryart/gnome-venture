-- variety-act-g18.lua : Do-tab scenes for 15 orchard/workshop rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g18.lua  (params BEFORE --script)
-- Gnome sprite + frame copied from variety-act-g5.lua (frame pixel-exact from act-hand.png).
-- Frame (5 grid px wooden frame) is copied from the shipped act-hand.png; interior is x 5..68, y 5..49.
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "aseprite-source/extras-pixel/png/")
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local FRAME_SRC = ROOT .. "game/assets/img/acts/act-hand.png"
local only = app.params.only and app.params.only:gsub("^w4_", "")
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
  slug = "w4_" .. slug
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

---------------------------------------------------------------- shared bits (g18)
local function apple(c, x, y, col, hl)
  c:fill(c:ellipse(x, y, 2, 2), col or "#c8321e")
  c:px(x - 1, y - 1, hl or "#f08a6a")
  c:px(x, y - 3, "#5e3f28")
end
local function bigapple(c, x, y, col)
  part(c, c:ellipse(x, y, 3, 3), col or "#c8321e")
  c:px(x - 1, y - 1, "#f08a6a"); c:px(x, y - 4, "#5e3f28"); c:px(x + 1, y - 4, "#4e8a3c")
end
local function trunk(c, x, y0, y1, w, col)
  part(c, R(c, x - floor(w / 2), y0, x - floor(w / 2) + w - 1, y1), col or "#6b4a2e", { noline = true })
end
local function canopy(c, x, y, rx, ry, col, col2)
  part(c, c:ellipse(x, y, rx, ry), col or "#3f8a42", { shade = true })
  c:fill(c:ellipse(x - floor(rx / 3), y - floor(ry / 3), floor(rx / 3), floor(ry / 4)), col2 or "#6aae56")
end
local function dots(c, list, col)
  for _, p in ipairs(list) do c:px(p[1], p[2], col); c:px(p[1] + 1, p[2], col); c:px(p[1], p[2] + 1, col) end
end
local function bubble(c, x0, y0, x1, y1, tx, ty)
  part(c, c:rrect(x0, y0, x1, y1, 3), "#f4eee0")
  c:fill(c:poly({ { tx - 2, y1 }, { tx + 2, y1 }, { tx, y1 + 4 } }), "#f4eee0")
end
local function sparkle(c, x, y, a, b)
  a = a or "#fff1c8"; b = b or "#f5cf6a"
  c:px(x, y, a); c:px(x - 1, y, b); c:px(x + 1, y, b); c:px(x, y - 1, b); c:px(x, y + 1, b)
end
local function wasp(c, x, y)
  fl(c, R(c, x, y, x + 2, y + 1), "#f0c030"); c:px(x + 1, y, "#2a1a10"); c:px(x + 1, y + 1, "#2a1a10")
  c:px(x - 1, y, "#2a1a10")
  c:px(x + 1, y - 1, "#f4f8fa"); c:px(x + 2, y - 1, "#f4f8fa")
end
local function jar(c, x, y, w, h, body, lid)
  part(c, R(c, x, y, x + w - 1, y + h - 1), body or "#b8e0e8")
  fl(c, R(c, x, y - 2, x + w - 1, y - 1), lid or "#8a5a35")
end

local S = {}

-- 1. apprentice_tales (night, workshop): old hand telling a tale, bubble with the five-legged chair
function S.apprentice_tales()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#4a3a52")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 38), "#3a2c42") end
  fl(c, R(c, 0, 38, W - 1, 39), "#2a1c2c")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#6b4630")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#4a2c1a") end
  -- night window
  part(c, R(c, 52, 9, 66, 25), "#8a5a35")
  c:fill(R(c, 54, 11, 64, 23), "#1e2a52"); fl(c, R(c, 59, 11, 59, 23), "#8a5a35"); fl(c, R(c, 54, 17, 64, 17), "#8a5a35")
  c:fill(c:ellipse(56, 13, 1, 1), "#f5e6a8"); c:px(62, 14, "#f4eee0"); c:px(61, 21, "#f4eee0")
  -- shelf of tools + lamp, glowing
  part(c, R(c, 28, 20, 48, 21), "#8a5a35")
  part(c, R(c, 31, 12, 34, 19), "#8b929c"); fl(c, R(c, 32, 9, 33, 12), "#6b3b2a")
  part(c, R(c, 36, 15, 40, 19), "#aeb4bc")
  part(c, R(c, 42, 14, 46, 19), "#ffd86a", { shade = true, cres = 1 }); fl(c, R(c, 43, 15, 45, 18), "#fff1c8")
  part(c, R(c, 42, 12, 46, 13), "#3d2a1c")
  for _, p in ipairs({ { 40, 11 }, { 49, 14 }, { 49, 20 }, { 39, 22 } }) do c:px(p[1], p[2], "#f8c070") end
  -- workbench right with mug, other gnome behind it
  gnome(c, 58, 42, { d = -1, upper = true, hat = "#e8a317", eyes = "happy", arms = { arm({ 5, 7 }, { 7, 10 }, true) } })
  part(c, R(c, 47, 38, 70, 42), "#a8703e"); fl(c, R(c, 48, 38, 69, 38), "#d9a660")
  part(c, R(c, 49, 43, 51, 50), "#8a5a35", { noline = true }); part(c, R(c, 66, 43, 68, 50), "#8a5a35", { noline = true })
  part(c, R(c, 52, 35, 55, 38), "#d9a660")
  -- storyteller on a stool
  part(c, R(c, 11, 41, 27, 43), "#a8703e", { noline = false })
  for _, x in ipairs({ 12, 25 }) do part(c, R(c, x, 44, x + 1, 50), "#8a5a35", { noline = true }) end
  gnome(c, 18, 41, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 7 }, { -7, 13 }, false), arm({ 4, 7 }, { 8, 12 }, true) } })
  -- the tale: a chair with five legs
  bubble(c, 12, 4, 34, 21, 22, 21)
  fl(c, R(c, 17, 6, 18, 12), "#8a5a35"); fl(c, R(c, 28, 6, 29, 12), "#8a5a35"); fl(c, R(c, 17, 6, 29, 7), "#a8703e")
  fl(c, R(c, 20, 8, 20, 11), "#8a5a35"); fl(c, R(c, 23, 8, 23, 11), "#8a5a35"); fl(c, R(c, 26, 8, 26, 11), "#8a5a35")
  part(c, R(c, 15, 12, 31, 14), "#b07a45")
  for _, x in ipairs({ 15, 19, 23, 27, 31 }) do fl(c, R(c, x, 15, x, 19), "#6b3b2a") end
  c:px(37, 28, "#ffd86a")
  finish(c, "apprentice_tales")
end

-- 2. ladder_steady: gnome holding the foot of a leaning ladder; picker swaying at the top; an apple drops
function S.ladder_steady()
  seed = 61
  local c = new()
  day(c, 36, { cloud = 14 })
  -- big old tree
  trunk(c, 52, 24, 44, 5, "#6b4a2e"); trunk(c, 52, 18, 28, 3, "#7a5a3a")
  canopy(c, 48, 15, 20, 11, "#3f8a42", "#6aae56")
  canopy(c, 61, 18, 9, 8, "#4e9a48", "#7ab55c")
  for _, p in ipairs({ { 36, 20 }, { 43, 24 }, { 50, 22 }, { 58, 24 }, { 62, 14 }, { 54, 10 }, { 41, 9 } }) do apple(c, p[1], p[2]) end
  -- ladder leaning on the tree
  local function rail(x0, y0, x1, y1) part(c, c:line({ { x0, y0 }, { x1, y1 } }, 2), "#b07a45", { noline = true }) end
  part(c, c:line({ { 28, 47 }, { 37, 14 } }, 2), "#b07a45"); part(c, c:line({ { 35, 47 }, { 44, 14 } }, 2), "#b07a45")
  for i = 0, 6 do
    local t = i / 7
    local y = 44 - i * 4
    local xa = 28 + (47 - y) * 9 / 33
    fl(c, R(c, floor(xa), y, floor(xa) + 8, y), "#6b3b2a")
  end
  -- picker at the top
  gnome(c, 40, 22, { s = 0.9, d = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 9, 17 }, true), arm({ -4, 8 }, { -8, 15 }, false) } })
  -- sway marks
  for _, p in ipairs({ { 28, 14 }, { 27, 19 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 2), "#f4eee0"); c:px(p[1] + 1, p[2] + 3, "#f4eee0") end
  -- steadier at the foot
  gnome(c, 22, 47, { s = 1.15, d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 11 }, true), arm({ -4, 6 }, { 6, 8 }, false) } })
  -- basket and falling apple
  part(c, R(c, 8, 42, 16, 47), "#c9a060"); fl(c, R(c, 8, 44, 16, 44), "#a07a40")
  apple(c, 10, 41); apple(c, 14, 41, "#e8b030", "#f8e090")
  apple(c, 31, 31); fl(c, R(c, 31, 25, 31, 27), "#f4eee0")
  finish(c, "ladder_steady")
end

-- 3. wasp_windfalls (autumn): gnome holds up a jam jar, wasps swarm to it from the fallen apples
function S.wasp_windfalls()
  seed = 71
  local c = new()
  day(c, 33, { cloud = 50, sky = { "#e0cf9c", "#e8d8a8", "#efe2b8" }, hill = "#8a8a3a", hill2 = "#7a7a32", grass = "#9aa04a", edge = "#b8b45a" })
  trunk(c, 11, 14, 40, 6, "#6b4a2e")
  canopy(c, 11, 11, 15, 8, "#b86a2a", "#d8903a")
  for _, p in ipairs({ { 0, 0 } }) do end
  dots(c, { { 28, 11 }, { 30, 15 }, { 33, 9 } }, "#d8903a")
  -- windfalls on the ground
  local fa = { { 8, 44, "#c8321e" }, { 14, 47, "#e8b030" }, { 21, 45, "#c8321e" }, { 50, 46, "#e8b030" }, { 58, 44, "#c8321e" }, { 64, 47, "#c8321e" }, { 40, 48, "#a8581e" } }
  for _, f in ipairs(fa) do apple(c, f[1], f[2], f[3]) end
  c:px(14, 46, "#6b3b2a"); c:px(21, 46, "#6b3b2a")
  gnome(c, 38, 47, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -9, 15 }, true, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  -- jam jar held up high, with a cloth lid
  local jx, jy = 26, 24
  part(c, R(c, jx, jy, jx + 5, jy + 7), "#b8e0e8"); c:fill(R(c, jx + 1, jy + 3, jx + 4, jy + 6), "#c0243a")
  fl(c, R(c, jx - 1, jy - 1, jx + 6, jy), "#f4eee0")
  fl(c, R(c, 28, 32, 30, 33), "#f0c8a0")
  -- wasp swarm: drifting from the windfalls to the jar, one on the hat
  for _, p in ipairs({ { 18, 38 }, { 22, 33 }, { 15, 29 }, { 22, 22 }, { 32, 20 }, { 46, 36 }, { 52, 40 }, { 30, 14 } }) do wasp(c, p[1], p[2]) end
  wasp(c, 41, 15)
  c:px(21, 31, "#f4eee0"); c:px(17, 34, "#f4eee0"); c:px(24, 27, "#f4eee0")
  -- basket (the pickers')
  part(c, R(c, 58, 38, 67, 43), "#c9a060"); fl(c, R(c, 58, 40, 67, 40), "#a07a40")
  finish(c, "wasp_windfalls")
end

-- 4. cherry_net (summer): flinging a net over the cherry tree while starlings dive
function S.cherry_net()
  seed = 81
  local c = new()
  day(c, 36, { cloud = 12, sky = { "#92cfe8", "#a8dcee", "#bfe6ee" } })
  trunk(c, 50, 24, 44, 5, "#6b4a2e")
  canopy(c, 49, 17, 17, 12, "#2f8a3a", "#4ea64a")
  canopy(c, 36, 24, 8, 6, "#3f9a40", "#5eb450")
  local ch = { { 40, 12 }, { 46, 10 }, { 53, 11 }, { 58, 14 }, { 44, 17 }, { 50, 16 }, { 56, 19 }, { 38, 22 }, { 62, 20 }, { 49, 22 }, { 42, 24 }, { 32, 23 } }
  for _, p in ipairs(ch) do
    fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#d0182e"); fl(c, R(c, p[1] + 2, p[2] + 1, p[2] + 3, p[2] + 2), "#d0182e")
  end
  -- the net: thrown from the gnome's hands up over the tree
  local nm = c:poly({ { 14, 26 }, { 22, 12 }, { 34, 4 }, { 52, 5 }, { 62, 12 }, { 56, 30 }, { 36, 32 }, { 27, 30 }, { 27, 27 } })
  local pts = {}
  nm:each(function(x, y) if (x + y) % 5 == 0 or (x - y) % 5 == 0 then pts[#pts + 1] = { x, y } end end)
  for _, p in ipairs(pts) do c:px(p[1], p[2], "#f4ecd0") end
  -- gnome with arms thrown up holding the net's edge
  gnome(c, 18, 47, { s = 1.15, d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -3, 17 }, false), arm({ 4, 8 }, { 7, 18 }, true) } })
  -- starlings
  local function bird(x, y, d, up)
    fl(c, R(c, x, y, x + 3, y + 1), "#2a2a40"); c:px(x + (d > 0 and 4 or -1), y, "#e8b030")
    c:px(x + 1, y + (up and -1 or 2), "#2a2a40"); c:px(x + 2, y + (up and -2 or 3), "#2a2a40"); c:px(x + 3, y + (up and -1 or 2), "#2a2a40")
    c:px(x + 2, y, "#5a7a9a")
  end
  bird(10, 12, 1, true); bird(14, 20, 1, false); bird(28, 7, 1, true); bird(64, 6, -1, false); bird(66, 26, -1, true)
  for _, p in ipairs({ { 40, 44 }, { 58, 47 }, { 30, 46 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#9cc070") end
  finish(c, "cherry_net")
end

-- 5. frost_pots (dawn, frost): glowing pots set along the bud rows, gnome carrying one
function S.frost_pots()
  seed = 91
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#6a78a8", "#8a88b4", "#b498b8", "#d8a8b0", "#f0bca0", "#f8d0a0" }, { dir = "v" })
  c:fill(c:ellipse(30, 34, 36, 8), "#7a88a8"); c:fill(c:ellipse(66, 34, 24, 7), "#8490b0")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#c8d8e4")
  c:fill(R(c, 0, 33, W - 1, 33), "#e4eef4")
  c:fill(R(c, 0, 44, W - 1, H - 1), "#b8cadb")
  -- distant tree row
  for _, x in ipairs({ 6, 18, 30, 42, 54, 66 }) do
    c:fill(R(c, x, 28, x + 1, 33), "#5a4a52"); c:fill(c:ellipse(x, 25, 4, 4), "#8a8aa0"); c:px(x - 1, 24, "#f0d0e0"); c:px(x + 2, 26, "#f0d0e0")
  end
  -- two close trees with budding twigs and frost
  for _, x in ipairs({ 14, 57 }) do
    trunk(c, x, 24, 44, 4, "#5a4a3e")
    part(c, c:ellipse(x, 16, 11, 9), "#7a8aa0", { shade = true })
    for _, p in ipairs({ { -6, -2 }, { -2, -5 }, { 3, -4 }, { 6, 0 }, { 0, 1 }, { -4, 3 }, { 4, 4 } }) do
      fl(c, R(c, x + p[1], 16 + p[2], x + p[1] + 1, 16 + p[2] + 1), "#f4b8cf")
    end
    c:fill(R(c, x - 6, 8, x + 5, 9), "#f4f8fa")
  end
  -- glowing pots set along the row
  local function pot(x, y, glow)
    if glow then c:fill(c:ellipse(x + 1, y - 1, 6, 3), "#e8d8c0"); c:fill(c:ellipse(x + 1, y - 1, 3, 2), "#f8c878") end
    part(c, R(c, x - 1, y, x + 3, y + 3), "#2a2226")
    fl(c, R(c, x, y - 1, x + 2, y), "#ff8a28"); c:px(x + 1, y - 1, "#ffd86a")
    c:px(x + 1, y - 3, "#e8a060"); c:px(x + 2, y - 5, "#e8a060")
  end
  pot(8, 44, true); pot(22, 42, true); pot(56, 43, true); pot(63, 46, true)
  -- gnome with mitten, carrying a pot
  local _, G = gnome(c, 36, 47, { d = 1, eyes = "open", arms = { arm({ 4, 6 }, { 8, 6 }, true, true), arm({ -4, 6 }, { 6, 5 }, false, true) } })
  local px_, py_ = G.P(8, 6)
  pot(px_ - 1, py_ - 1, false)
  c:fill(c:ellipse(px_ + 1, py_ - 1, 4, 3), "#f8c878"); c:fill(c:ellipse(px_ + 1, py_ - 1, 2, 1), "#ffd86a")
  part(c, R(c, px_ - 2, py_ - 1, px_ + 4, py_ + 2), "#2a2226")
  fl(c, R(c, px_ - 1, py_ - 2, px_ + 3, py_ - 2), "#ff8a28"); fl(c, R(c, px_, py_ - 3, px_ + 2, py_ - 3), "#ffd86a")
  fl(c, R(c, px_ - 3, py_ - 1, px_ - 2, py_ + 1), "#c0443e"); fl(c, R(c, px_ + 5, py_ - 1, px_ + 6, py_ + 1), "#c0443e")
  -- frosted hat tip + breath
  G.hat:each(function(x, y) if y <= G.tipy + 2 then c:px(x, y, "#f4f8fa") end end)
  fl(c, R(c, 41, 37, 42, 37), "#f4f8fa"); fl(c, R(c, 43, 35, 44, 35), "#f4f8fa")
  for _, p in ipairs({ { 10, 30 }, { 30, 20 }, { 44, 12 }, { 64, 40 }, { 26, 38 }, { 52, 30 } }) do c:px(p[1], p[2], "#fbfdfe") end
  finish(c, "frost_pots")
end

-- 6. bruise_sort: three heaps (perfect / press / hedgehog), gnome checks one apple against the light
function S.bruise_sort()
  seed = 101
  local c = new()
  -- shed-side orchard yard: plank wall behind, dirt floor
  c:fill(R(c, 0, 0, W - 1, 31), "#9a7a52")
  for x = 0, W - 1, 5 do fl(c, R(c, x, 0, x, 31), "#7e6040") end
  fl(c, R(c, 0, 12, W - 1, 12), "#7e6040")
  c:bands(R(c, 0, 32, W - 1, H - 1), { "#b89c68", "#c0a470", "#c8ac78" }, { dir = "v" })
  fl(c, R(c, 0, 32, W - 1, 32), "#6b4a2e")
  -- three heaps along the floor
  local function heap(cx, y, rows, cols, cf)
    for r = 0, rows - 1 do
      local n = cols - r
      for i = 0, n - 1 do
        local x = cx - (n - 1) * 2 + i * 4 + (r % 2)
        c:fill(c:ellipse(x, y - r * 3, 2, 2), cf[(i + r) % #cf + 1])
        c:px(x - 1, y - r * 3 - 1, "#fbd0b8")
      end
    end
  end
  part(c, R(c, 25, 41, 39, 47), "#b07a45"); fl(c, R(c, 25, 43, 39, 43), "#8a5a35")
  heap(32, 40, 3, 3, { "#d0262a", "#e04a2a" })
  part(c, R(c, 41, 41, 55, 47), "#8a5a35"); fl(c, R(c, 41, 43, 55, 43), "#6b3b2a")
  heap(48, 40, 2, 3, { "#8a6030", "#a07a30", "#7a5028" })
  for _, p in ipairs({ { 46, 38 }, { 51, 39 }, { 44, 36 } }) do c:px(p[1], p[2], "#4a2c1a") end
  -- hedgehog (facing left) with a wormy apple, bottom right
  part(c, c:ellipse(63, 45, 4, 3), "#6b4a2e")
  for x = 60, 66, 2 do fl(c, R(c, x, 41, x, 42), "#4a2c1a") end
  fl(c, R(c, 58, 45, 60, 46), "#e8c8a0"); c:px(59, 45, "#2a1a10")
  c:fill(c:ellipse(57, 48, 2, 1), "#b8d860"); c:px(56, 47, "#e08a8a"); c:px(55, 47, "#e08a8a")
  -- window with a bit of daylight on the wall
  part(c, R(c, 34, 4, 50, 22), "#8a5a35"); c:fill(R(c, 36, 6, 48, 20), "#cfe8e6"); fl(c, R(c, 42, 6, 42, 20), "#8a5a35"); fl(c, R(c, 36, 13, 48, 13), "#8a5a35")
  fl(c, R(c, 38, 8, 40, 9), "#f4f8fa")
  -- gnome inspecting one apple, held up to the light
  gnome(c, 14, 48, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 15 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  apple(c, 25, 27, "#d0262a")
  c:px(25, 28, "#e8d8b0")
  sparkle(c, 30, 23); c:px(22, 21, "#f5cf6a")
  finish(c, "bruise_sort")
end

-- 7. apple_chutney: big gnome stirring the copper pan over the fire; jars with cloth hats on a stump
function S.apple_chutney()
  seed = 111
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 30), "#b8a078")
  for y = 0, 30, 5 do fl(c, R(c, 0, y, W - 1, y), "#9a8460") end
  for y = 2, 30, 10 do for x = 0, W - 1, 12 do fl(c, R(c, x + (y % 20 == 2 and 6 or 0), y, x + (y % 20 == 2 and 6 or 0), y + 4), "#9a8460") end end
  c:fill(R(c, 0, 31, W - 1, H - 1), "#7a9a58")
  fl(c, R(c, 0, 31, W - 1, 31), "#98b870")
  c:fill(c:ellipse(40, 47, 30, 4), "#8ea868")
  -- fire under the pan, tripod
  part(c, c:poly({ { 53, 38 }, { 56, 44 }, { 57, 48 }, { 47, 48 }, { 49, 44 } }), "#e0501f")
  c:fill(c:poly({ { 53, 41 }, { 55, 45 }, { 55, 48 }, { 50, 48 }, { 51, 45 } }), "#ffd86a")
  for _, p in ipairs({ { 44, 49 }, { 60, 49 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#8b8f96", { shade = true }) end
  part(c, c:line({ { 46, 36 }, { 49, 46 } }, 2), "#3d2a1c", { noline = true }); part(c, c:line({ { 60, 36 }, { 57, 46 } }, 2), "#3d2a1c", { noline = true })
  -- copper pan seen from above-front: dark bubbling chutney in a wide rim
  part(c, c:rrect(44, 31, 62, 39, 3), "#b8601e", { shade = true })
  fl(c, R(c, 46, 33, 47, 37), "#e8a060")
  part(c, c:ellipse(53, 29, 11, 4), "#d98a40")
  c:fill(c:ellipse(53, 29, 9, 3), "#5a2418")
  for _, p in ipairs({ { 48, 29 }, { 52, 28 }, { 57, 29 }, { 60, 28 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#a8503a"); c:px(p[1], p[2], "#d08a50") end
  part(c, R(c, 40, 29, 42, 31), "#a8581e"); part(c, R(c, 64, 29, 66, 31), "#a8581e")
  for i = 0, 2 do fl(c, c:ellipse(51 + i * 3 - (i % 2) * 2, 21 - i * 4, 2, 1), "#f4f4f0") end
  -- gnome stirring with a long wooden spoon
  local _, G = gnome(c, 28, 47, { s = 1.25, d = 1, eyes = "shut", arms = { arm({ 4, 7 }, { 9, 11 }, true), arm({ -4, 6 }, { 4, 8 }, false) } })
  part(c, c:line({ { 38, 36 }, { 52, 28 } }, 2), "#b07a45", { noline = true })
  c:fill(R(c, 50, 28, 54, 30), "#b07a45")
  -- stump with finished jars (gingham lids)
  part(c, R(c, 3, 38, 15, 48), "#8a5a35"); c:fill(c:ellipse(9, 38, 6, 2), "#c08a52")
  fl(c, R(c, 6, 41, 6, 47), "#5e2f1e")
  jar(c, 4, 34, 4, 4, "#8a3a1a", "#c0243a"); jar(c, 10, 33, 4, 5, "#8a3a1a", "#f4eee0")
  c:px(5, 32, "#e04a4a"); c:px(11, 31, "#f4eee0")
  apple(c, 17, 46); c:fill(c:ellipse(21, 47, 1, 1), "#e8d8a0"); c:px(21, 47, "#d0a850")
  finish(c, "apple_chutney")
end

-- 8. currant_tart: brick bothy oven glowing, gnome draws out a lattice tart on a peel; currant bushes
function S.currant_tart()
  seed = 121
  local c = new()
  day(c, 33, { cloud = 20, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- brick oven dome
  part(c, c:ellipse(52, 36, 17, 14):clip(R(c, 0, 0, W, 47)), "#a8502e", { shade = true })
  part(c, R(c, 35, 36, 69, 47), "#a8502e")
  for y = 22, 46, 4 do fl(c, R(c, 36, y, 68, y), "#7a3a22") end
  for y = 24, 44, 8 do for x = 40, 66, 8 do fl(c, R(c, x, y, x, y + 3), "#7a3a22") end end
  for y = 26, 46, 8 do for x = 44, 66, 8 do fl(c, R(c, x, y, x, y + 3), "#7a3a22") end end
  part(c, R(c, 49, 12, 53, 22), "#7a3a22")
  fl(c, R(c, 51, 5, 51, 10), "#d8d8d0"); fl(c, R(c, 52, 2, 53, 4), "#d8d8d0")
  -- glowing arched mouth
  part(c, c:rrect(44, 33, 60, 47, 5), "#2a1a10")
  c:fill(c:rrect(46, 36, 58, 47, 4), "#e0501f"); c:fill(c:rrect(48, 40, 56, 47, 3), "#ffd86a")
  -- currant bush at left with purple + green berries
  part(c, c:ellipse(9, 38, 9, 7), "#3f8a42", { shade = true })
  for _, p in ipairs({ { 5, 35 }, { 9, 33 }, { 12, 37 }, { 6, 40 }, { 11, 41 }, { 15, 40 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#4a2a6a"); c:px(p[1], p[2], "#8a5ab0") end
  for _, p in ipairs({ { 8, 36 }, { 14, 35 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#b8d870") end
  -- gnome in front, peel with a hot tart
  gnome(c, 30, 47, { s = 1.1, d = 1, eyes = "happy", arms = { arm({ 4, 7 }, { 8, 8 }, true, true), arm({ -4, 6 }, { 3, 7 }, false, true) } })
  part(c, c:line({ { 33, 40 }, { 47, 38 } }, 2), "#b07a45", { noline = true })
  part(c, R(c, 42, 34, 54, 38), "#b07a45")
  part(c, c:ellipse(48, 35, 7, 3), "#d9a660")
  c:fill(c:ellipse(48, 35, 5, 2), "#6a2a7a")
  for x = 44, 52, 2 do c:px(x, 35, "#e8c48a") end
  fl(c, R(c, 44, 34, 52, 34), "#e8c48a"); fl(c, R(c, 44, 36, 52, 36), "#e8c48a")
  fl(c, R(c, 40, 41, 41, 42), "#8a4aa8"); fl(c, R(c, 39, 38, 40, 39), "#8a4aa8")
  for i = 0, 1 do fl(c, c:ellipse(46 + i * 4, 26 - i * 3, 1, 1), "#f4f4f0") end
  c:px(14, 47, "#4a2a6a"); c:px(20, 48, "#b8d870")
  finish(c, "currant_tart")
end

-- 9. ginger_cordial: working the screw press, golden juice running into a jug; ginger root on a barrel
function S.ginger_cordial()
  seed = 131
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#a8c0b0")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 38), "#98b0a0") end
  fl(c, R(c, 0, 30, W - 1, 30), "#6b4a2e")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#8a5a35")
  for y = 43, 51, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- small window
  part(c, R(c, 52, 7, 65, 22), "#8a5a35"); c:fill(R(c, 54, 9, 63, 20), "#cfe8e6"); fl(c, R(c, 58, 9, 58, 20), "#8a5a35"); fl(c, R(c, 54, 14, 63, 14), "#8a5a35")
  c:fill(c:ellipse(60, 12, 1, 1), "#f4eee0")
  -- the press: tray, slatted basket, screw, long lever
  part(c, R(c, 28, 41, 54, 45), "#6b3b2a")
  part(c, c:rrect(32, 26, 50, 41, 2), "#b07a45")
  for x = 35, 47, 4 do fl(c, R(c, x, 27, x, 40), "#7a4a2a") end
  fl(c, R(c, 32, 31, 50, 31), "#6b3b2a"); fl(c, R(c, 32, 36, 50, 36), "#6b3b2a")
  part(c, R(c, 40, 18, 42, 26), "#6b4a2e", { noline = true })
  part(c, c:line({ { 52, 15 }, { 41, 19 }, { 27, 31 } }, 2), "#8a5a35", { noline = true })
  part(c, R(c, 38, 24, 44, 25), "#8a5a35")
  -- juice runs from a spout into a jug in front
  fl(c, R(c, 38, 38, 42, 39), "#6b3b2a"); fl(c, R(c, 42, 39, 42, 47), "#e8b030"); c:px(41, 39, "#ffe08a")
  part(c, R(c, 38, 46, 46, 50), "#d9a660"); fl(c, R(c, 39, 47, 45, 47), "#e8b030")
  -- gnome heaving on the lever
  gnome(c, 18, 49, { s = 1.15, d = 1, walk = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 8 }, { 6, 12 }, false) } })
  -- ginger on a barrel + apples
  part(c, R(c, 57, 34, 67, 47), "#a8703e"); fl(c, R(c, 57, 37, 67, 37), "#6b3b2a"); fl(c, R(c, 57, 43, 67, 43), "#6b3b2a")
  fl(c, R(c, 58, 34, 66, 34), "#c08a52")
  part(c, R(c, 58, 31, 65, 33), "#d9b87a"); part(c, R(c, 60, 28, 62, 31), "#d9b87a"); part(c, R(c, 64, 29, 66, 32), "#d9b87a")
  fl(c, R(c, 59, 32, 59, 32), "#8a6a3a"); fl(c, R(c, 63, 32, 63, 32), "#8a6a3a")
  apple(c, 50, 48, "#e8b030", "#f8e090"); apple(c, 54, 48)
  finish(c, "ginger_cordial")
end

-- 10. graft_pear (spring): old pear trunk with a new twig bound in, gnome on a stool, wax and twine
function S.graft_pear()
  seed = 141
  local c = new()
  day(c, 38, { cloud = 56, sky = { "#b0d8ee", "#c4e4f0", "#d6eef0" } })
  -- gnarled trunk with a few blossoms
  part(c, c:poly({ { 18, 49 }, { 22, 36 }, { 24, 22 }, { 20, 12 }, { 27, 12 }, { 34, 20 }, { 37, 36 }, { 41, 49 } }), "#7a5a3e")
  c:fill(R(c, 24, 20, 25, 44), "#5e3f28"); c:fill(R(c, 31, 28, 31, 46), "#8e6a48")
  part(c, c:line({ { 22, 14 }, { 12, 9 }, { 9, 6 } }, 3), "#7a5a3e", { noline = true })
  part(c, c:line({ { 31, 18 }, { 40, 11 }, { 44, 8 } }, 3), "#7a5a3e", { noline = true })
  for _, p in ipairs({ { 8, 6 }, { 14, 8 }, { 10, 12 }, { 42, 8 }, { 46, 12 }, { 38, 12 }, { 17, 14 } }) do
    c:fill(c:ellipse(p[1], p[2], 2, 2), "#f4eee0"); c:px(p[1], p[2], "#f4b8cf")
  end
  for _, p in ipairs({ { 6, 9 }, { 40, 5 }, { 12, 4 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#7ab55c") end
  -- the graft: clean cut, new twig bound with twine, waxed
  part(c, c:line({ { 31, 31 }, { 40, 24 }, { 44, 17 } }, 2), "#9ac060", { noline = true })
  c:fill(R(c, 43, 14, 46, 16), "#4e9a48"); c:px(47, 15, "#7ab55c"); c:px(42, 15, "#7ab55c")
  c:fill(R(c, 28, 29, 34, 33), "#e8d0a0")
  for y = 29, 33, 2 do fl(c, R(c, 28, y, 34, y), "#c8a870") end
  part(c, c:ellipse(31, 34, 3, 2), "#e8b838")
  c:px(30, 33, "#fff0a8")
  -- gnome on a stool, binding
  part(c, R(c, 46, 42, 56, 44), "#b07a45"); part(c, R(c, 47, 45, 48, 49), "#8a5a35", { noline = true }); part(c, R(c, 54, 45, 55, 49), "#8a5a35", { noline = true })
  gnome(c, 51, 42, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -9, 12 }, true), arm({ 4, 6 }, { 6, 3 }, false) } })
  fl(c, R(c, 40, 30, 42, 31), "#f0c8a0")
  -- twine ball + wax pot on the ground
  c:fill(c:ellipse(63, 46, 3, 3), "#d9bc84"); c:px(62, 45, "#f0dca4"); fl(c, R(c, 60, 46, 66, 46), "#a8884e")
  part(c, R(c, 8, 44, 14, 48), "#8a5a35"); fl(c, R(c, 9, 44, 13, 44), "#e8b838")
  sparkle(c, 36, 9); sparkle(c, 56, 18)
  finish(c, "graft_pear")
end

-- 11. thin_fruitlets (spring): snipping a crowded cluster down to one; cuttings drop into a bucket
function S.thin_fruitlets()
  seed = 151
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#b4dcee", "#c8e6ee", "#d8eef0" }, { dir = "v" })
  c:fill(R(c, 0, 35, W - 1, H - 1), "#7ea85a"); fl(c, R(c, 0, 35, W - 1, 35), "#9cc070")
  -- big leafy branch across the top
  part(c, c:line({ { 4, 8 }, { 30, 12 }, { 66, 7 } }, 3), "#6b4a2e", { noline = true })
  for _, p in ipairs({ { 8, 6 }, { 17, 14 }, { 26, 8 }, { 36, 15 }, { 45, 8 }, { 56, 14 }, { 64, 6 }, { 22, 18 }, { 52, 5 } }) do
    part(c, c:ellipse(p[1], p[2], 4, 3), "#4e9a48", { shade = true })
  end
  -- crowded clusters (left, middle) and a thinned one with a single big apple (right)
  local function tiny(x, y) c:fill(R(c, x, y, x + 2, y + 2), "#8ac048"); c:px(x, y, "#b8e070") end
  for _, p in ipairs({ { 14, 18 }, { 17, 19 }, { 12, 21 }, { 16, 22 }, { 19, 21 } }) do tiny(p[1], p[2]) end
  for _, p in ipairs({ { 32, 20 }, { 35, 21 }, { 31, 23 }, { 34, 24 }, { 37, 23 } }) do tiny(p[1], p[2]) end
  fl(c, R(c, 16, 16, 16, 18), "#5e3f28"); fl(c, R(c, 34, 17, 34, 19), "#5e3f28")
  fl(c, R(c, 56, 16, 56, 19), "#5e3f28")
  part(c, c:ellipse(56, 23, 4, 4), "#9ccc4c"); c:px(54, 21, "#d8f088"); c:px(55, 21, "#d8f088")
  -- gnome reaching up with snips
  local _, G = gnome(c, 26, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 17 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(7, 17)
  fl(c, R(c, hx + 1, hy - 3, hx + 2, hy - 1), "#aeb4bc"); fl(c, R(c, hx + 3, hy - 4, hx + 4, hy - 2), "#aeb4bc")
  c:px(hx + 2, hy - 2, "#6b3b2a")
  -- trimmed fruitlets falling into a bucket
  for _, p in ipairs({ { 41, 29 }, { 44, 35 } }) do tiny(p[1], p[2]) end
  tiny(46, 40)
  part(c, R(c, 44, 41, 56, 48), "#8b929c"); fl(c, R(c, 44, 41, 56, 42), "#aeb4bc"); fl(c, R(c, 45, 45, 55, 45), "#6b6e78")
  tiny(46, 39); tiny(50, 39); tiny(53, 40)
  for _, p in ipairs({ { 62, 44 }, { 65, 46 }, { 60, 47 } }) do tiny(p[1], p[2]) end
  finish(c, "thin_fruitlets")
end

-- 12. pip_spitting: pip flying in an arc to the bucket, pickers cheering behind
function S.pip_spitting()
  seed = 161
  local c = new()
  day(c, 34, { cloud = 36, sky = { "#9cd0e4", "#b4dcea", "#cce8ec" } })
  trunk(c, 8, 18, 34, 4, "#6b4a2e"); canopy(c, 8, 14, 11, 8, "#3f8a42", "#6aae56")
  for _, p in ipairs({ { 4, 15 }, { 11, 17 }, { 9, 11 } }) do apple(c, p[1], p[2]) end
  -- spectators on a hay bale
  part(c, R(c, 43, 40, 67, 47), "#d8b860"); for x = 46, 64, 4 do fl(c, R(c, x, 41, x, 46), "#b8963c") end
  fl(c, R(c, 43, 40, 67, 40), "#e8cc78")
  gnome(c, 50, 40, { d = -1, upper = true, hat = "#4f9a45", eyes = "happy", arms = { arm({ 5, 7 }, { 8, 15 }, true), arm({ -5, 7 }, { -8, 15 }, true) } })
  gnome(c, 61, 40, { d = -1, upper = true, hat = "#e8a317", eyes = "open", arms = { arm({ -5, 7 }, { -8, 14 }, true) } })
  -- bucket target
  part(c, c:poly({ { 33, 39 }, { 41, 39 }, { 40, 47 }, { 34, 47 } }), "#aeb4bc")
  fl(c, R(c, 33, 38, 41, 39), "#d0d6dc"); fl(c, R(c, 34, 42, 40, 42), "#8b929c")
  c:px(36, 40, "#f4eee0")
  -- the spitter
  gnome(c, 16, 47, { s = 1.15, d = 1, walk = 1, eyes = "shut", arms = { arm({ -4, 7 }, { -8, 11 }, false), arm({ 4, 6 }, { 5, 3 }, true) } })
  -- three arcs: high (long dots), straight (low), far; pip in flight
  local function pip(x, y) c:px(x, y, "#2a1a10"); c:px(x + 1, y, "#2a1a10") end
  local function arc(x0, y0, x1, y1, h, step, col)
    for i = 0, step do
      local t = i / step
      local x = floor(x0 + (x1 - x0) * t + 0.5)
      local y = floor(y0 + (y1 - y0) * t - 4 * h * t * (1 - t) + 0.5)
      if i % 2 == 0 then c:px(x, y, col) end
    end
  end
  arc(22, 31, 37, 38, 20, 22, "#f4f8fa")
  arc(22, 31, 34, 33, 4, 14, "#f4eee0")
  pip(30, 18); pip(29, 28)
  c:px(29, 27, "#f4f8fa")
  fl(c, R(c, 22, 31, 24, 31), "#f4f8fa")
  for _, p in ipairs({ { 28, 48 }, { 50, 49 }, { 62, 48 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#9cc070") end
  finish(c, "pip_spitting")
end

-- 13. apple_bobbing (dusk, autumn): gnome surfaces dripping with an apple in his teeth
function S.apple_bobbing()
  seed = 171
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#4a3a78", "#6a4a86", "#9a5a88", "#c86a76", "#e8886a", "#f0a870" }, { dir = "v" })
  c:fill(c:ellipse(14, 34, 28, 9), "#3a3060"); c:fill(c:ellipse(60, 33, 28, 8), "#40356a")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#6a7a40"); fl(c, R(c, 0, 34, W - 1, 34), "#8a8a48")
  for _, p in ipairs({ { 10, 8 }, { 28, 6 }, { 52, 9 }, { 64, 14 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- orange leaves drifting and on the ground
  for _, p in ipairs({ { 8, 40 }, { 14, 46 }, { 60, 44 }, { 66, 47 }, { 56, 38 }, { 6, 30 }, { 62, 24 }, { 22, 22 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2]), "#d8782a"); c:px(p[1] + 2, p[2] - 1, "#e8a030") end
  -- lantern string
  c:fill(c:line({ { 5, 11 }, { 20, 16 }, { 36, 13 }, { 52, 17 }, { 68, 12 } }, 1), "#3d2a1c")
  for _, p in ipairs({ { 20, 17 }, { 36, 14 }, { 52, 18 } }) do
    part(c, R(c, p[1] - 1, p[2], p[1] + 1, p[2] + 3), "#ffd86a", { cres = 1 }); c:px(p[1], p[2] + 1, "#fff1c8")
  end
  -- gnome behind the tub, an apple in his teeth, beard dripping
  local _, G = gnome(c, 36, 44, { s = 1.25, d = 1, upper = true, eyes = "shut", arms = { arm({ -5, 6 }, { -9, 12 }, true), arm({ 5, 6 }, { 9, 12 }, true) } })
  local ax, ay = G.P(0, 9)
  part(c, c:ellipse(ax, ay, 2, 2), "#d0262a"); c:px(ax - 1, ay - 1, "#f08a6a"); c:px(ax, ay - 3, "#5e3f28")
  for _, p in ipairs({ { ax - 4, ay + 3 }, { ax + 4, ay + 4 }, { ax - 6, ay + 6 } }) do c:px(p[1], p[2], "#8fd8e8"); c:px(p[1], p[2] + 1, "#8fd8e8") end
  -- the tub: hooped staves, rim ellipse, water and floating apples
  part(c, R(c, 18, 40, 54, 49), "#a8703e")
  for x = 22, 50, 6 do fl(c, R(c, x, 41, x, 48), "#7a4a2a") end
  fl(c, R(c, 18, 43, 54, 43), "#6b6e78"); fl(c, R(c, 18, 47, 54, 47), "#6b6e78")
  part(c, c:ellipse(36, 40, 18, 4), "#c08a52")
  c:fill(c:ellipse(36, 40, 16, 3), "#4a8ab0"); c:fill(R(c, 24, 40, 30, 40), "#8fd8e8"); c:fill(R(c, 42, 41, 48, 41), "#6aaed0")
  for _, p in ipairs({ { 25, 40 }, { 31, 41 }, { 41, 39 }, { 47, 40 }, { 52, 40 } }) do
    c:fill(c:ellipse(p[1], p[2], 2, 1), "#d0262a"); c:px(p[1] - 1, p[2] - 1, "#f08a6a"); c:px(p[1] + 1, p[2] - 2, "#4e8a3c")
  end
  -- splashes
  for _, p in ipairs({ { 28, 35 }, { 44, 34 }, { 22, 38 }, { 50, 37 } }) do c:px(p[1], p[2], "#bfeaf4"); c:px(p[1], p[2] + 1, "#8fd8e8") end
  finish(c, "apple_bobbing")
end

-- 14. apple_kinds: a row of different old apples on a table, gnome tastes a slice, orchard rows behind
function S.apple_kinds()
  seed = 181
  local c = new()
  day(c, 30, { cloud = 52, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- orchard rows: small trees with differing fruit
  local rows = { { 8, "#d0262a" }, { 20, "#e8b030" }, { 32, "#a8d048" }, { 44, "#8a5a2a" }, { 56, "#c8501e" }, { 66, "#d0262a" } }
  for _, r in ipairs(rows) do
    fl(c, R(c, r[1], 24, r[1] + 1, 30), "#6b4a2e"); part(c, c:ellipse(r[1], 21, 5, 4), "#4e9a48", { shade = true })
    c:px(r[1] - 2, 21, r[2]); c:px(r[1] + 2, 20, r[2]); c:px(r[1], 23, r[2])
  end
  c:fill(R(c, 0, 31, W - 1, H - 1), "#8ea868"); fl(c, R(c, 0, 31, W - 1, 31), "#a8c078")
  -- the gnome tastes a slice
  local _, G = gnome(c, 18, 44, { s = 1.45, d = 1, upper = true, eyes = "happy", arms = { arm({ 4, 6 }, { 5, 13 }, true, true), arm({ -4, 6 }, { -5, 4 }, false, true) } })
  local sx, sy = G.P(5, 13)
  part(c, R(c, sx - 1, sy - 3, sx + 2, sy + 1), "#f4eecc"); c:px(sx, sy - 1, "#c8a060")
  fl(c, R(c, sx - 2, sy + 1, sx - 1, sy + 3), "#f0c8a0")
  -- table with an apple of each kind
  part(c, R(c, 4, 38, 69, 42), "#b07a45"); fl(c, R(c, 5, 38, 68, 38), "#d9a660")
  part(c, R(c, 8, 43, 10, 49), "#8a5a35", { noline = true }); part(c, R(c, 63, 43, 65, 49), "#8a5a35", { noline = true })
  local ks = { { 31, "#d0262a", "#f08a6a" }, { 38, "#9ccc4c", "#d8f088" }, { 45, "#e8b030", "#f8e090" }, { 52, "#8a5a2a", "#b8864a" }, { 59, "#7a1e2a", "#b04a5a" }, { 65, "#e07a2a", "#f8b070" } }
  for _, k in ipairs(ks) do
    part(c, c:ellipse(k[1], 35, 3, 3), k[2]); c:px(k[1] - 1, 34, k[3]); c:px(k[1], 31, "#5e3f28")
  end
  -- striped one and a cut half
  for y = 33, 36, 1 do c:px(45 + ((y % 2 == 0) and 1 or -1), y, "#d0262a") end
  c:px(31, 34, "#f08a6a")
  c:px(52, 36, "#8a6a3a"); c:px(51, 35, "#8a6a3a"); c:px(53, 34, "#8a6a3a")
  part(c, c:ellipse(18, 40, 2, 1), "#f4eecc")
  finish(c, "apple_kinds")
end

-- 15. ripe_pear: four pears on a stall, gnome presses the neck of the soft one
function S.ripe_pear()
  seed = 191
  local c = new()
  day(c, 38, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- picker's tent behind
  part(c, c:poly({ { 49, 4 }, { 71, 40 }, { 27, 40 } }), "#e8d2a0")
  c:fill(c:poly({ { 49, 4 }, { 71, 40 }, { 60, 40 } }), "#d6bc88")
  c:fill(c:poly({ { 49, 16 }, { 54, 29 }, { 44, 29 } }), "#5e3f2a")
  fl(c, R(c, 49, 2, 49, 5), "#8a5a35"); fl(c, R(c, 50, 2, 53, 3), "#c0443e")
  for y = 20, 36, 8 do fl(c, R(c, 36, y, 62, y), "#b8965c") end
  -- sill / plank table with four pears
  part(c, R(c, 31, 41, 69, 43), "#b07a45"); fl(c, R(c, 32, 41, 68, 41), "#d9a660")
  part(c, R(c, 34, 44, 35, 49), "#8a5a35", { noline = true }); part(c, R(c, 65, 44, 66, 49), "#8a5a35", { noline = true })
  local function pear(x, y, body, hi, blush)
    part(c, c:ellipse(x, y - 2, 3, 3), body)
    part(c, R(c, x - 1, y - 8, x + 1, y - 4), body)
    c:fill(R(c, x - 1, y - 6, x + 1, y - 5), body)
    c:px(x - 1, y - 3, hi); c:px(x - 1, y - 2, hi)
    fl(c, R(c, x, y - 10, x, y - 9), "#5e3f28"); c:px(x + 1, y - 10, "#4e8a3c"); c:px(x + 2, y - 10, "#4e8a3c")
    if blush then c:px(x + 1, y - 1, blush); c:px(x + 2, y - 2, blush) end
  end
  pear(43, 41, "#e8d048", "#fff0a0", "#e87a4a")
  pear(51, 41, "#5e9a3a", "#8ac060")
  pear(58, 41, "#6aa43e", "#98cc68")
  pear(65, 41, "#4e8a38", "#7ab45a")
  -- gnome pressing the soft pear's neck with a thumb
  gnome(c, 24, 48, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 12, 12 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  sparkle(c, 46, 25); sparkle(c, 40, 24)
  fl(c, R(c, 3, 40, 4, 41), "#f4eee0"); c:px(8, 46, "#e8c48a")
  finish(c, "ripe_pear")
end

local order = { "apprentice_tales", "ladder_steady", "wasp_windfalls", "cherry_net", "frost_pots", "bruise_sort", "apple_chutney", "currant_tart", "ginger_cordial", "graft_pear", "thin_fruitlets", "pip_spitting", "apple_bobbing", "apple_kinds", "ripe_pear" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end

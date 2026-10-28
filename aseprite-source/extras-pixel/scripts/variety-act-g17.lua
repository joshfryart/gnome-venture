-- variety-act-g17.lua : Do-tab scenes for 15 workshop rest-stop activities (w4_*) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g17.lua   (params BEFORE --script)
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
local S = {}

-- plank-walled barn interior. wall = {base, groove}, g = floor line
local function barn(c, g, wall, floorc, groove)
  wall = wall or "#c9a96e"; groove = groove or "#b8965c"; floorc = floorc or "#8a5a35"
  c:fill(R(c, 0, 0, W - 1, g), wall)
  for x = 3, W - 1, 6 do fl(c, R(c, x, 0, x, g), groove) end
  c:fill(R(c, 0, g, W - 1, g), "#6b3b2a")
  c:fill(R(c, 0, g + 1, W - 1, H - 1), floorc)
  for y = g + 4, H - 1, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
end
local function mallet(c, x, y, ang) -- handle from (x,y) going up-left/right ; head at end. ang 1 = head up-right
  c:fill(c:line({ { x, y }, { x + 3 * ang, y - 9 } }, 2), "#8a5a35")
  part(c, R(c, x + 3 * ang - 3, y - 13, x + 3 * ang + 3, y - 9), "#b07a45")
end
local function motion(c, pts, col) for _, p in ipairs(pts) do fl(c, R(c, p[1], p[2], p[3], p[4]), col or "#fff8e0") end end

-- 1. wobbly_stool: a three-legged stool, one leg short; clamp on the joint and a mallet tapping it home
-- 1. wobbly_stool: a three-legged stool, one leg short; clamp on the joint and a mallet tapping it home
function S.w4_wobbly_stool()
  seed = 61
  local c = new()
  barn(c, 38, "#c9a96e", "#8a5a35")
  part(c, R(c, 8, 10, 22, 22), "#8a5a35"); c:fill(R(c, 10, 12, 20, 20), "#a8d4e0"); fl(c, R(c, 15, 12, 15, 20), "#8a5a35"); fl(c, R(c, 10, 16, 20, 16), "#8a5a35")
  part(c, R(c, 52, 17, 66, 18), "#a8703e"); part(c, R(c, 55, 11, 60, 16), "#c0442e")
  -- stool: seat tilted (left edge higher), legs splayed; the right leg is too short and hangs above the floor
  part(c, c:line({ { 31, 31 }, { 27, 45 } }, 3), "#8a5a35", { noline = true })
  part(c, c:line({ { 41, 32 }, { 41, 47 } }, 3), "#9a6a3a", { noline = true })
  part(c, c:line({ { 50, 31 }, { 53, 41 } }, 3), "#8a5a35", { noline = true })
  part(c, c:poly({ { 27, 27 }, { 55, 29 }, { 55, 32 }, { 27, 30 } }), "#b07a45")
  fl(c, R(c, 29, 27, 53, 28), "#d9a660")
  c:fill(R(c, 53, 42, 55, 43), "#7a4a2a"); c:fill(R(c, 46, 47, 56, 47), "#7a4a2a")
  -- the clamp: thin bar between the left and middle legs, red screw handle
  fl(c, R(c, 29, 38, 42, 38), "#8b929c"); part(c, R(c, 28, 36, 30, 41), "#6e7480", { noline = true }); part(c, R(c, 41, 36, 43, 41), "#6e7480", { noline = true })
  fl(c, R(c, 44, 37, 47, 37), "#c0442e"); fl(c, R(c, 46, 35, 46, 39), "#c0442e")
  -- wobble marks
  motion(c, { { 22, 26, 22, 29 }, { 20, 28, 20, 30 }, { 58, 27, 58, 30 }, { 60, 29, 60, 31 } }, "#6b3b2a")
  -- gnome with a mallet, arm up
  gnome(c, 13, 47, { s = 1.1, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 13 }, true) } })
  c:fill(c:line({ { 22, 33 }, { 25, 28 } }, 2), "#8a5a35")
  part(c, R(c, 23, 22, 29, 26), "#b07a45")
  finish(c, "w4_wobbly_stool")
end

-- 2. bird_box: nailing a bird box to a tree, blue tit waiting on a branch
function S.w4_bird_box()
  seed = 62
  local c = new()
  day(c, 38, { cloud = 14, sky = { "#b0d8e4", "#c4e2e6", "#d4ecea" } })
  -- tree trunk and crown
  part(c, R(c, 44, 8, 52, 48), "#7a5030", { noline = true })
  for _, y in ipairs({ 14, 22, 30, 41 }) do fl(c, R(c, 46, y, 46, y + 3), "#5e3f28") end
  part(c, c:ellipse(48, 9, 17, 7), "#3f8a42", { shade = true })
  part(c, c:ellipse(60, 14, 8, 5), "#4e9a46", { shade = true })
  -- branch with the bird
  part(c, R(c, 52, 20, 64, 22), "#7a5030", { noline = true })
  part(c, c:ellipse(60, 18, 2, 2), "#4a88c8"); c:fill(c:ellipse(60, 18, 1, 1), "#f0d84a"); c:px(63, 18, "#f0b84a"); c:px(61, 17, INK)
  fl(c, R(c, 56, 19, 58, 19), "#3a68a0")
  -- the box on the trunk: slanted roof, round hole
  part(c, R(c, 38, 28, 53, 40), "#c08a52")
  fl(c, R(c, 38, 31, 53, 31), "#a06a3a"); fl(c, R(c, 38, 35, 53, 35), "#a06a3a")
  part(c, c:poly({ { 35, 28 }, { 56, 28 }, { 53, 22 }, { 38, 22 } }), "#a8581f")
  fl(c, R(c, 38, 24, 53, 24), "#c8702f")
  c:fill(c:ellipse(46, 33, 2, 2), "#2a1a10")
  part(c, R(c, 43, 38, 49, 38), "#8a5a35", { noline = true })
  for _, p in ipairs({ { 39, 29 }, { 52, 29 }, { 39, 39 }, { 52, 39 } }) do c:px(p[1], p[2], "#e8e0c8") end
  -- gnome with hammer and a fistful of nails in the mouth-hand
  gnome(c, 22, 47, { s = 1.15, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 4 }, false), arm({ 4, 8 }, { 8, 14 }, true) } })
  part(c, R(c, 31, 33, 36, 36), "#6e7480"); c:fill(c:line({ { 30, 38 }, { 34, 33 } }, 2), "#8a5a35")
  -- tap marks and shavings
  motion(c, { { 37, 27, 37, 27 }, { 36, 29, 36, 29 }, { 35, 26, 35, 26 } }, "#fff8e0")
  motion(c, { { 14, 49, 16, 49 }, { 30, 49, 31, 49 }, { 38, 47, 39, 47 } }, "#e8c48a")
  fl(c, R(c, 8, 44, 12, 45), "#e8c48a")
  finish(c, "w4_bird_box")
end

-- 3. snail_glaze: dusk, lamplight; painting a pot with silvery snail-trail glaze, a snail on the rim, kiln glowing
-- 3. snail_glaze: dusk, lamplight; painting a pot with silvery snail-trail glaze, a snail on the pot, kiln glowing
function S.w4_snail_glaze()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 40), { "#2a3258", "#37426a", "#46527a", "#6a5a86" }, { dir = "v" })
  for _, st in ipairs({ { 10, 9 }, { 24, 7 }, { 60, 8 }, { 66, 18 } }) do c:px(st[1], st[2], "#f4eee0") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#4a3a2e")
  fl(c, R(c, 0, 41, W - 1, 41), "#6b5a48")
  part(c, c:rrect(4, 24, 24, 44, 4), "#8a6a58", { shade = true })
  c:fill(c:rrect(9, 31, 19, 41, 3), "#3a2418")
  c:fill(c:rrect(10, 33, 18, 41, 3), "#e0501f"); c:fill(c:rrect(12, 36, 16, 41, 2), "#ffd86a")
  part(c, R(c, 11, 17, 17, 24), "#6b5a50", { noline = true }); fl(c, R(c, 12, 14, 15, 16), "#8a7a70")
  part(c, R(c, 28, 37, 68, 40), "#6b4a2e"); fl(c, R(c, 28, 37, 68, 37), "#8a6a40")
  part(c, R(c, 30, 41, 33, 49), "#5e3f28", { noline = true }); part(c, R(c, 63, 41, 66, 49), "#5e3f28", { noline = true })
  -- the pot: belly, neck, flared rim
  part(c, c:ellipse(54, 30, 8, 7), "#b86a42", { shade = true })
  part(c, R(c, 50, 20, 58, 24), "#b86a42", { noline = true })
  part(c, R(c, 48, 18, 60, 20), "#a85a38")
  fl(c, R(c, 50, 22, 50, 24), "#d08a62")
  -- silver swirl trail winding round the belly, ending at the snail
  local sw = { { 49, 31 }, { 51, 27 }, { 55, 26 }, { 58, 28 }, { 58, 32 }, { 55, 35 }, { 52, 34 }, { 52, 31 }, { 55, 30 } }
  for i = 1, #sw - 1 do c:fill(c:line({ sw[i], sw[i + 1] }, 1), "#dde8f4") end
    -- snail on the rim, trail running down the side into the swirl
  part(c, R(c, 52, 16, 58, 17), "#e0c8a8", { noline = true })
  part(c, c:ellipse(56, 14, 2, 2), "#d0a060"); c:px(55, 14, "#8a5a35"); c:px(56, 13, "#8a5a35"); c:px(57, 14, "#8a5a35"); c:px(51, 15, "#e0c8a8"); c:px(50, 14, INK); c:px(51, 13, INK)
  fl(c, R(c, 59, 17, 59, 17), "#dde8f4"); fl(c, R(c, 60, 18, 60, 22), "#dde8f4")
  -- gnome with a brush, painting
  gnome(c, 38, 40, { s = 1, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 11 }, true) } })
  c:fill(c:line({ { 47, 29 }, { 50, 28 } }, 1), "#8a5a35"); fl(c, R(c, 50, 28, 51, 29), "#dde8f4")
  fl(c, R(c, 40, 5, 40, 11), "#3a2418"); part(c, R(c, 37, 12, 43, 17), "#e8a317"); fl(c, R(c, 38, 13, 42, 16), "#fff1c8")
  fl(c, R(c, 36, 11, 44, 11), "#3a2418")
  motion(c, { { 35, 19, 35, 19 }, { 45, 19, 45, 19 }, { 40, 21, 40, 21 } }, "#f5cf6a")
  -- sparkle on the glaze
  for _, p in ipairs({ { 60, 25 }, { 47, 33 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#fff1c8"); c:px(p[1], p[2] - 1, "#fff1c8") end
  finish(c, "w4_snail_glaze")
end

-- 4. turn_dibber: foot-treadle lathe, gnome sits and works a chisel as a pointed dibber spins, shavings curl
function S.w4_turn_dibber()
  seed = 64
  local c = new()
  barn(c, 40, "#b99a6e", "#7a4f2e", "#a8895c")
  -- tool rack on the wall
  part(c, R(c, 8, 12, 30, 13), "#7a4a2a")
  for i = 0, 3 do part(c, R(c, 10 + i * 5, 14, 11 + i * 5, 20 + (i % 2) * 2), "#8b929c", { noline = true }); fl(c, R(c, 10 + i * 5, 10, 11 + i * 5, 13), "#c0442e") end
  -- lathe bed and headstocks
  part(c, R(c, 28, 33, 66, 35), "#5e3f28")
  part(c, R(c, 28, 24, 33, 33), "#6b4a2e"); part(c, R(c, 61, 24, 66, 33), "#6b4a2e")
  part(c, R(c, 33, 29, 36, 29), "#8b929c", { noline = true }); fl(c, R(c, 58, 29, 60, 29), "#8b929c")
  -- spinning oak: blank on the left, pointed dibber on the right
  part(c, R(c, 34, 25, 47, 33), "#c08a52")
  c:fill(c:poly({ { 47, 25 }, { 58, 29 }, { 47, 33 } }), "#c08a52"); c:outline(c:poly({ { 47, 25 }, { 58, 29 }, { 47, 33 } }))
  fl(c, R(c, 36, 27, 47, 27), "#e0b070"); fl(c, R(c, 36, 31, 46, 31), "#a06a3a")
  fl(c, R(c, 38, 25, 38, 33), "#a06a3a"); fl(c, R(c, 43, 25, 43, 33), "#a06a3a")
  -- chisel on a rest, shavings
  part(c, R(c, 40, 35, 52, 36), "#8a5a35", { noline = true })
  for _, p in ipairs({ { 49, 22 }, { 52, 20 }, { 55, 22 }, { 50, 18 } }) do
    c:fill(c:ellipse(p[1], p[2], 2, 1), "#f0d9a0"); c:px(p[1] - 1, p[2], "#c8a060")
  end
  for _, p in ipairs({ { 36, 42 }, { 42, 44 }, { 49, 43 }, { 56, 45 }, { 62, 43 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#f0d9a0"); c:px(p[1], p[2], "#c8a060") end
  -- treadle and flywheel
  part(c, R(c, 36, 44, 62, 46), "#7a4a2a")
  -- gnome standing at the lathe, chisel forward
  gnome(c, 18, 48, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 12, 11 }, true) } })
  c:fill(c:line({ { 29, 36 }, { 40, 33 } }, 2), "#8b929c"); fl(c, R(c, 27, 36, 30, 38), "#8a5a35")
  finish(c, "w4_turn_dibber")
end

-- 5. rocking_horse: big horse half carved, gnome with mallet and gouge at the head, curls underfoot
-- 5. rocking_horse: big horse half carved, gnome with mallet and gouge at the head, curls underfoot
function S.w4_rocking_horse()
  seed = 65
  local c = new()
  barn(c, 40, "#c4a874", "#8a5a35")
  part(c, R(c, 8, 10, 22, 22), "#8a5a35"); c:fill(R(c, 10, 12, 20, 20), "#a8d4e0"); fl(c, R(c, 15, 12, 15, 20), "#8a5a35")
  -- rocker: a curved plank
  local rk = c:ellipse(30, 38, 22, 9):clip(R(c, 0, 43, W, 60)):cut(c:ellipse(30, 38, 22, 7))
  rk:add(c:ellipse(30, 38, 22, 9):clip(R(c, 0, 43, W, 60)):cut(c:ellipse(30, 36, 22, 8)))
  part(c, c:rect(10, 44, 50, 46), "#8a5a35")
  part(c, c:line({ { 10, 44 }, { 14, 47 }, { 46, 47 }, { 50, 44 } }, 2), "#7a4a2a")
  -- legs
  part(c, c:line({ { 22, 33 }, { 18, 44 } }, 3), "#b07a45", { noline = true }); part(c, c:line({ { 27, 33 }, { 25, 44 } }, 3), "#9a6a3a", { noline = true })
  part(c, c:line({ { 40, 33 }, { 43, 44 } }, 3), "#9a6a3a", { noline = true }); part(c, c:line({ { 45, 33 }, { 49, 44 } }, 3), "#b07a45", { noline = true })
  -- body (right half sanded smooth + lighter, left still rough), neck and head leaning forward
  part(c, c:rrect(20, 24, 47, 34, 3), "#c08a52")
  c:fill(R(c, 33, 26, 45, 26), "#e0b070")
  fl(c, R(c, 22, 28, 27, 28), "#a06a3a"); fl(c, R(c, 24, 31, 30, 31), "#a06a3a"); fl(c, R(c, 21, 26, 25, 26), "#a06a3a")
  part(c, c:poly({ { 42, 26 }, { 48, 13 }, { 57, 13 }, { 59, 19 }, { 53, 19 }, { 51, 28 } }), "#d9a660")
  c:px(55, 16, INK); c:px(58, 18, "#8a5a35")
  part(c, c:poly({ { 50, 12 }, { 51, 8 }, { 54, 12 } }), "#d9a660")
  part(c, R(c, 45, 14, 47, 24), "#7a3a22", { noline = true })
  part(c, c:line({ { 20, 25 }, { 16, 28 }, { 16, 34 } }, 2), "#7a3a22", { noline = true })
  -- gnome on the right, chisel at the head
  gnome(c, 62, 47, { s = 1.1, d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 14 }, true) } })
  c:fill(c:line({ { 53, 33 }, { 57, 21 } }, 1), "#8b929c")
  for _, p in ipairs({ { 12, 49 }, { 40, 49 }, { 56, 48 }, { 29, 49 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#f0d9a0"); c:px(p[1], p[2], "#c8a060") end
  for _, p in ipairs({ { 58, 22 }, { 60, 20 } }) do c:px(p[1], p[2], "#fff8e0") end
  finish(c, "w4_rocking_horse")
end

local function rain(c, n, x0, x1, y0, y1, col)
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col or "#d6eaf2"); c:px(x, y + 1, col or "#d6eaf2"); c:px(x, y + 2, col or "#d6eaf2")
  end
end

-- 6. rain_catcher: rainy yard; brass funnels on poles, copper pipe running into a kettle, gnome with a spanner
function S.w4_rain_catcher()
  seed = 66
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#7e8ea0", "#8d9bab", "#9ca8b6", "#aab5c0" }, { dir = "v" })
  c:fill(c:ellipse(14, 8, 14, 3), "#6a7888"); c:fill(c:ellipse(52, 6, 16, 3), "#6a7888")
  c:fill(c:ellipse(18, 37, 34, 9), "#4e7a44"); c:fill(c:ellipse(60, 38, 28, 8), "#456e3e")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#5a8a4c"); fl(c, R(c, 0, 36, W - 1, 36), "#6a9a58")
  fl(c, R(c, 4, 46, 14, 46), "#8fb4cc"); fl(c, R(c, 40, 48, 52, 48), "#8fb4cc")
  -- little shed with a gutter on its roof edge
  part(c, R(c, 4, 22, 22, 40), "#a8703e")
  for x = 7, 20, 4 do fl(c, R(c, x, 23, x, 40), "#8a5a35") end
  part(c, c:poly({ { 2, 22 }, { 24, 22 }, { 20, 16 }, { 6, 16 } }), "#7a4a2a")
  part(c, R(c, 8, 28, 14, 40), "#5e3f28")
  part(c, R(c, 1, 22, 25, 23), "#c8703a")
  -- downspout into a big funnel on a pole
  part(c, R(c, 25, 23, 26, 34), "#c8703a", { noline = true })
  part(c, R(c, 29, 33, 30, 42), "#8a5a35", { noline = true })
  part(c, c:poly({ { 23, 28 }, { 36, 28 }, { 32, 34 }, { 27, 34 } }), "#e0b04a")
  fl(c, R(c, 24, 28, 35, 28), "#f4d878")
  -- copper pipe snaking down and across to the kettle
  part(c, c:line({ { 28, 35 }, { 28, 41 }, { 44, 41 } }, 2), "#c8703a")
  fl(c, R(c, 29, 41, 43, 41), "#e0905a")
  -- kettle at the end of the pipe, filling up (water showing in the spout window)
  part(c, c:rrect(44, 34, 60, 46, 3), "#aeb4bc", { shade = true })
  part(c, R(c, 46, 31, 58, 34), "#8b929c"); fl(c, R(c, 50, 29, 54, 30), "#6b3b2a")
  part(c, c:poly({ { 59, 38 }, { 64, 33 }, { 65, 35 }, { 60, 42 } }), "#aeb4bc")
  c:fill(R(c, 46, 41, 58, 45), "#4a88b0"); fl(c, R(c, 47, 41, 52, 41), "#8cc4dc")
  fl(c, R(c, 44, 40, 44, 41), "#e0905a")
  -- falling water droplet from the pipe mouth
  c:px(41, 43, "#8cc4dc"); c:px(41, 45, "#8cc4dc")
  -- gnome with a spanner
  gnome(c, 15, 48, { s = 1.1, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 14 }, true) } })
  c:fill(c:line({ { 23, 34 }, { 27, 31 } }, 2), "#8b929c")
  rain(c, 60, 6, 68, 6, 49)
  -- puddle splashes
  for _, p in ipairs({ { 10, 47 }, { 48, 49 }, { 20, 45 } }) do c:px(p[1], p[2], "#d6eaf2"); c:px(p[1] + 2, p[2] - 1, "#d6eaf2") end
  finish(c, "w4_rain_catcher")
end

-- 7. dovetail_lesson: workbench close-up; a tail board and pin board held together at a dovetail, student with chisel, teacher nodding
-- 7. dovetail_lesson: workbench; two boards sliding together at a dovetail, student with chisel, teacher nodding
function S.w4_dovetail_lesson()
  seed = 67
  local c = new()
  barn(c, 34, "#a88a62", "#8e7050", "#7a4f2e")
  part(c, c:poly({ { 8, 10 }, { 8, 15 }, { 30, 14 }, { 30, 11 } }), "#aeb4bc")
  part(c, R(c, 30, 9, 34, 16), "#8a5a35")
  for x = 10, 28, 2 do c:px(x, 15, "#6e7480") end
  part(c, R(c, 52, 9, 54, 22), "#8a5a35", { noline = true }); part(c, R(c, 52, 20, 62, 22), "#8a5a35", { noline = true })
  part(c, R(c, 2, 34, 69, 38), "#b07a45"); fl(c, R(c, 2, 34, 69, 34), "#d9a660")
  part(c, R(c, 6, 39, 10, 49), "#6b4a2e", { noline = true }); part(c, R(c, 62, 39, 66, 49), "#6b4a2e", { noline = true })
  -- the joint, top-down: dark pin board on the right, light tail board on the left; tails flare to fit the sockets
  local dark = c:rect(32, 16, 58, 33)
  c:fill(dark, "#6b3b2a"); c:outline(dark)
  local light = c:rect(20, 16, 32, 33)
  for _, yc in ipairs({ 22, 28 }) do light:add(c:poly({ { 32, yc - 2 }, { 44, yc - 5 }, { 44, yc + 5 }, { 32, yc + 3 } })) end
  c:fill(light, "#ecc888"); c:outline(light)
  fl(c, R(c, 22, 18, 31, 18), "#f0cc8a"); fl(c, R(c, 46, 18, 56, 18), "#8a5a35")
  fl(c, R(c, 22, 24, 30, 24), "#c8905a"); fl(c, R(c, 22, 30, 30, 30), "#c8905a")
  motion(c, { { 16, 22, 18, 22 }, { 15, 26, 18, 26 } }, "#fff8e0")
  gnome(c, 11, 48, { s = 1.15, d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 14 }, true) } })
  c:fill(c:line({ { 19, 34 }, { 22, 30 } }, 1), "#8b929c"); part(c, R(c, 18, 33, 20, 37), "#c0442e", { noline = true })
  gnome(c, 62, 48, { s = 1.2, d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ -4, 6 }, { 0, 8 }, true), arm({ 4, 6 }, { 0, 7 }, true, true) } })
  motion(c, { { 66, 20, 67, 20 }, { 67, 22, 68, 22 } }, "#6b3b2a")
  finish(c, "w4_dovetail_lesson")
end

local function note(c, x, y, col) -- tiny 8th note
  fl(c, R(c, x, y, x + 1, y), col); fl(c, R(c, x + 1, y - 4, x + 1, y), col); fl(c, R(c, x + 2, y - 4, x + 3, y - 3), col)
end
local function kettle(c, x, y, hex, o) -- x,y = bottom-left of a ~9x8 kettle
  part(c, c:rrect(x, y - 8, x + 9, y, 2), hex, { shade = true })
  part(c, R(c, x + 2, y - 10, x + 7, y - 8), "#8b929c")
  fl(c, R(c, x + 4, y - 11, x + 5, y - 11), "#6b3b2a")
  part(c, c:poly({ { x + 9, y - 3 }, { x + 13, y - 7 }, { x + 14, y - 6 }, { x + 10, y - 1 } }), hex)
  fl(c, R(c, x + 2, y - 6, x + 2, y - 3), "#e8ecf0")
end

-- 8. kettle_whistleoff: two gnomes behind a bench with three kettles: one whistles, one hisses steam, one rattles its lid off
-- 8. kettle_whistleoff: two gnomes behind a bench with three kettles: one whistles, one hisses steam, one rattles its lid off
function S.w4_kettle_whistleoff()
  seed = 68
  local c = new()
  barn(c, 40, "#6a5a4a", "#4a3a2e", "#5a4a3c")
  part(c, R(c, 6, 14, 66, 15), "#8a5a35")
  for i, x in ipairs({ 8, 22, 40, 54 }) do kettle(c, x, 14, ({ "#8b929c", "#b08a5a", "#8b929c", "#b08a5a" })[i]) end
  part(c, R(c, 2, 36, 69, 40), "#a06a3a"); fl(c, R(c, 2, 36, 69, 36), "#c08a52")
  part(c, R(c, 6, 41, 10, 49), "#5e3f28", { noline = true }); part(c, R(c, 62, 41, 66, 49), "#5e3f28", { noline = true })
  gnome(c, 11, 40, { s = 1.1, d = 1, upper = true, eyes = "happy", arms = { arm({ 4, 5 }, { 8, 9 }, true) } })
  gnome(c, 63, 40, { s = 1.1, d = -1, upper = true, hat = "#4f9a45", eyes = "shut", arms = { arm({ -4, 5 }, { -8, 9 }, true) } })
  kettle(c, 18, 36, "#d86a3a")
  note(c, 22, 24, "#f5cf6a"); note(c, 28, 18, "#f5cf6a")
  fl(c, R(c, 20, 26, 24, 26), "#f4f8fa")
  kettle(c, 31, 36, "#8aa0b4")
  for i = 0, 3 do fl(c, c:ellipse(35 + (i % 2) * 2, 22 - i * 3, 2, 1), "#e8f0f4") end
  kettle(c, 44, 36, "#5a9a6a")
  part(c, R(c, 46, 21, 51, 23), "#8b929c"); c:px(48, 20, "#6b3b2a")
  motion(c, { { 42, 29, 42, 32 }, { 40, 30, 40, 33 }, { 45, 24, 45, 25 }, { 53, 24, 53, 25 } }, "#f4eee0")
  finish(c, "w4_kettle_whistleoff")
end

-- 9. paper_gliders: long barn, chalk line on the floor, a folded glider mid-flight, apprentices watching
-- 9. paper_gliders: long barn, chalk line on the floor, a folded glider mid-flight, apprentice cheering
function S.w4_paper_gliders()
  seed = 69
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 30), "#8a6a48")
  for x = 2, W - 1, 8 do fl(c, R(c, x, 0, x, 30), "#6b4a30") end
  part(c, R(c, 4, 8, 16, 14), "#a8d4e0"); fl(c, R(c, 10, 8, 10, 14), "#6b4a30")
  part(c, R(c, 52, 12, 66, 30), "#6b4a30"); fl(c, R(c, 59, 12, 59, 30), "#8a5a35")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#b8905a"); fl(c, R(c, 0, 31, W - 1, 31), "#8a5a35")
  for _, y in ipairs({ 36, 41, 46 }) do fl(c, R(c, 0, y, W - 1, y), "#9a7444") end
  for _, p in ipairs({ { 20, 32, 36 }, { 44, 37, 41 }, { 12, 42, 46 }, { 60, 32, 36 }, { 34, 42, 46 } }) do fl(c, R(c, p[1], p[2], p[1], p[3]), "#9a7444") end
  -- chalk line running toward the viewer
  c:fill(c:line({ { 49, 32 }, { 56, 50 } }, 2), "#f4f0e4")
  for _, y in ipairs({ 36, 42, 47 }) do c:px(51 + (y - 32) // 3, y, "#b8905a") end
  -- the glider, nose down, flying right, motion lines behind
  part(c, c:poly({ { 49, 24 }, { 32, 16 }, { 36, 25 } }), "#f4f8fa")
  c:fill(c:poly({ { 49, 24 }, { 36, 25 }, { 40, 21 } }), "#cfdbe6")
  fl(c, R(c, 33, 17, 36, 18), "#f4f8fa"); fl(c, R(c, 38, 21, 40, 22), "#aab8c8")
  motion(c, { { 22, 15, 29, 15 }, { 18, 19, 27, 19 }, { 23, 23, 30, 23 } }, "#f4eee0")
  gnome(c, 14, 48, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -7, 6 }, false), arm({ 4, 11 }, { 11, 18 }, true) } })
  gnome(c, 62, 49, { s = 1, d = -1, hat = "#e8a317", eyes = "happy", arms = { arm({ -4, 8 }, { -7, 15 }, true), arm({ 4, 8 }, { 7, 15 }, false) } })
  -- crumpled failures on the floor
  for _, p in ipairs({ { 30, 44 }, { 37, 47 }, { 41, 41 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#f4f8fa", { noline = true }); c:px(p[1] - 1, p[2], "#cfdbe6"); c:px(p[1] + 1, p[2] + 1, "#8a6a48") end
  finish(c, "w4_paper_gliders")
end

local function gear(c, x, y, r, hex)
  c:fill(c:ellipse(x, y, r, r), hex)
  for _, a in ipairs({ { 0, -1 }, { 0, 1 }, { 1, 0 }, { -1, 0 } }) do c:fill(R(c, x + a[1] * (r + 1) - (a[1] == 0 and 1 or 0), y + a[2] * (r + 1) - (a[2] == 0 and 1 or 0), x + a[1] * (r + 1) + (a[1] == 0 and 1 or 0) * 1, y + a[2] * (r + 1) + (a[2] == 0 and 1 or 0) * 1), hex) end
  c:fill(c:ellipse(x, y, 1, 1), "#4a3a2e")
end
local function roundclock(c, x, y, r, frame, hands)
  part(c, c:ellipse(x, y, r, r), frame, { shade = true })
  c:fill(c:ellipse(x, y, r - 2, r - 2), "#f4eee0")
  hands = hands or { 0, -r + 3, r - 3, 0 }
  c:fill(c:line({ { x, y }, { x + hands[1], y + hands[2] } }, 1), INK)
  c:fill(c:line({ { x, y }, { x + hands[3], y + hands[4] } }, 1), INK)
end

-- 10. clock_wall: a wall full of clocks, gnome on a stool opening a little one to show its gears
-- 10. clock_wall: a wall full of clocks, gnome opening a little one to show its gears
function S.w4_clock_wall()
  seed = 70
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#5a4a52")
  for x = 3, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#4c3c46") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#6b3b2a")
  fl(c, R(c, 0, 41, W - 1, 41), "#4a2c1a")
  roundclock(c, 14, 13, 8, "#c08a52", { 3, -3, 0, -5 })
  part(c, R(c, 28, 12, 40, 24), "#8a5a35")
  part(c, c:poly({ { 26, 12 }, { 42, 12 }, { 34, 4 } }), "#a8581f")
  c:fill(R(c, 32, 15, 36, 19), "#2a1a10"); c:px(34, 17, "#e8a317"); c:px(35, 16, "#c0442e")
  fl(c, R(c, 33, 24, 33, 30), "#e8a317"); part(c, c:ellipse(33, 31, 2, 2), "#e8a317")
  part(c, R(c, 47, 5, 56, 38), "#7a4a2a")
  c:fill(R(c, 49, 7, 54, 12), "#f4eee0"); c:fill(c:line({ { 51, 9 }, { 53, 8 } }, 1), INK); c:px(51, 10, INK)
  c:fill(R(c, 49, 15, 54, 33), "#3a2a20"); fl(c, R(c, 51, 15, 51, 27), "#d9a660"); part(c, c:ellipse(52, 28, 2, 2), "#e8a317")
  roundclock(c, 64, 12, 5, "#4a8a6a", { 2, -2, 0, -3 })
  roundclock(c, 64, 28, 5, "#c0442e", { -2, 0, 0, -3 })
  gnome(c, 16, 48, { s = 1.15, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 9 }, true) } })
  part(c, R(c, 28, 38, 36, 46), "#c08a52"); c:fill(R(c, 29, 39, 35, 45), "#6b5a4a")
  gear(c, 32, 42, 1, "#e8c04a"); gear(c, 31, 33, 1, "#e8c04a")
  motion(c, { { 28, 31, 28, 31 }, { 34, 31, 34, 31 }, { 31, 28, 31, 28 } }, "#f5cf6a")
  finish(c, "w4_clock_wall")
end

-- 11. pegboard_tools: pegboard wall, every tool over its painted outline; the gnome lifts one down to look at it
function S.w4_pegboard_tools()
  seed = 71
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 41), "#b8905a")
  for y = 8, 40, 4 do for x = 8, 68, 4 do c:px(x, y, "#8a6a40") end end
  c:fill(R(c, 0, 42, W - 1, H - 1), "#6b3b2a"); fl(c, R(c, 0, 42, W - 1, 42), "#4a2c1a")
  local OL = "#7a5530"
  -- tool = painted outline shape (dark) then the real tool 1px up-left
  local function outl(m) m:shift(1, 1):each(function(x, y) c:px(x, y, OL) end) end
  -- hammer
  local m = c:rect(10, 8, 20, 10); m:add(c:rect(14, 10, 15, 22)); outl(m)
  part(c, R(c, 14, 10, 15, 22), "#8a5a35", { noline = true }); part(c, R(c, 10, 8, 20, 10), "#8b929c")
  -- tenon saw
  m = c:poly({ { 26, 10 }, { 40, 10 }, { 40, 19 }, { 26, 15 } }); m:add(c:rect(40, 9, 44, 19)); outl(m)
  part(c, c:poly({ { 25, 9 }, { 39, 9 }, { 39, 18 }, { 25, 14 } }), "#aeb4bc"); part(c, R(c, 39, 8, 43, 18), "#a8703e")
  for x = 27, 37, 2 do c:px(x, 14 - (x - 25) // 4, "#6e7480") end
  -- try square
  m = c:rect(50, 8, 52, 24); m:add(c:rect(50, 22, 62, 24)); outl(m)
  part(c, R(c, 49, 7, 51, 23), "#a8703e"); part(c, R(c, 49, 21, 61, 23), "#8b929c")
  -- row 2: mallet, drawknife, brace (empty outline = the one in the gnome's hand)
  m = c:rect(8, 30, 17, 36); m:add(c:rect(12, 36, 13, 41)); outl(m)
  part(c, R(c, 12, 35, 13, 40), "#8a5a35", { noline = true }); part(c, R(c, 7, 29, 16, 35), "#b07a45")
  m = c:rect(24, 28, 36, 29); m:add(c:rect(24, 28, 25, 36)); m:add(c:rect(36, 28, 37, 36)); outl(m)
  part(c, R(c, 23, 27, 35, 28), "#aeb4bc"); part(c, R(c, 23, 27, 24, 35), "#8a5a35", { noline = true }); part(c, R(c, 35, 27, 36, 35), "#8a5a35", { noline = true })
  -- the missing rasp: outline only on the board (right), gnome holds the real one
  m = c:rect(46, 28, 62, 33); m:add(c:rect(62, 29, 66, 32)); outl(m)
  outl(c:rect(46, 28, 62, 33)); outl(c:rect(62, 29, 66, 32))
  -- gnome carrying the rasp, looking at it
  gnome(c, 36, 48, { s = 1.1, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 12, 14 }, true) } })
  part(c, R(c, 47, 30, 58, 33), "#8b929c"); part(c, R(c, 58, 31, 63, 33), "#a8703e")
  for x = 48, 57, 2 do c:px(x, 31, "#6e7480") end
  finish(c, "w4_pegboard_tools")
end

-- 12. screw_drawer: cabinet of five labelled drawers, one pulled out full of screws, the rest holding odd things
function S.w4_screw_drawer()
  seed = 72
  local c = new()
  barn(c, 42, "#6a5a4a", "#5a4a3a", "#7a4f2e")
  -- cabinet
  part(c, R(c, 22, 6, 66, 44), "#a8703e")
  local ys = { 8, 16, 24, 32 }
  for i, y in ipairs(ys) do
    part(c, R(c, 24, y, 64, y + 6), "#c08a52")
    fl(c, R(c, 25, y + 1, 63, y + 1), "#d9a660")
    part(c, R(c, 29, y + 2, 36, y + 5), "#f4eee0", { noline = true })
    fl(c, R(c, 30, y + 3, 35, y + 3), "#8a6a50")
    part(c, R(c, 43, y + 2, 47, y + 4), "#e8a317", { noline = true })
  end
  -- the pulled-out drawer (second): jutting toward the viewer on the left, screws spilling
  part(c, R(c, 8, 20, 36, 29), "#c08a52")
  c:fill(R(c, 10, 21, 34, 25), "#4a3a2e")
  for x = 11, 33, 3 do fl(c, R(c, x, 22, x, 24), "#d6dce4"); c:px(x + 1, 22, "#8b929c") end
  fl(c, R(c, 12, 23, 14, 23), "#f4f8fa"); fl(c, R(c, 25, 22, 27, 22), "#f4f8fa")
  part(c, R(c, 12, 27, 18, 28), "#e8a317", { noline = true })
  -- a dropped screw or two
  c:px(30, 44, "#d6dce4"); c:px(31, 45, "#8b929c")
  -- tinker pointing at the answer
  gnome(c, 56, 49, { s = 1, d = -1, eyes = "happy", arms = { arm({ -4, 8 }, { -9, 14 }, true), arm({ 4, 6 }, { 2, 3 }, false) } })
  finish(c, "w4_screw_drawer")
end

-- 13. padlock_key: a tinker's strongbox with a big padlock; gnome tries one of four identical keys, the ring dangling
function S.w4_padlock_key()
  seed = 73
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 41), "#4a5a6a")
  c:bands(R(c, 0, 0, W - 1, 41), { "#3f4e5e", "#465666", "#4e5e6e" }, { dir = "v" })
  for x = 0, W - 1, 8 do for y = 2, 40, 6 do fl(c, R(c, x + ((y // 6) % 2) * 4, y, x + ((y // 6) % 2) * 4 + 6, y), "#38465a") end end
  c:fill(R(c, 0, 42, W - 1, H - 1), "#7a5a3a"); fl(c, R(c, 0, 42, W - 1, 42), "#5e3f28")
  for y = 46, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#5e3f28") end
  -- lantern on the wall
  fl(c, R(c, 12, 5, 12, 9), "#2a1a10"); part(c, R(c, 9, 10, 15, 16), "#e8a317"); fl(c, R(c, 10, 11, 14, 15), "#fff1c8")
  c:px(7, 13, "#f5cf6a"); c:px(17, 13, "#f5cf6a")
  -- strongbox: iron-banded chest with a big brass padlock
  part(c, R(c, 30, 28, 66, 45), "#8a5a35")
  part(c, c:rrect(30, 22, 66, 30, 3), "#9a6a3a")
  fl(c, R(c, 32, 24, 64, 24), "#c08a52")
  part(c, R(c, 36, 22, 39, 45), "#5b6470", { noline = true }); part(c, R(c, 57, 22, 60, 45), "#5b6470", { noline = true })
  fl(c, R(c, 37, 24, 37, 44), "#8a909a"); fl(c, R(c, 58, 24, 58, 44), "#8a909a")
  part(c, R(c, 45, 24, 51, 28), "#5b6470", { noline = true })
  -- padlock: shackle and body, keyhole
  part(c, c:rrect(44, 24, 52, 38, 3), "#aeb4bc", { noline = false })
  c:fill(c:rrect(46, 27, 50, 38, 1), "#4a5a6a")
  part(c, R(c, 43, 33, 53, 41), "#e8b040")
  fl(c, R(c, 44, 34, 52, 34), "#fff1c8")
  c:fill(c:ellipse(48, 36, 1, 1), "#2a1a10"); c:px(48, 38, "#2a1a10")
  -- gnome kneeling, key in the lock, ring of three more keys dangling from his fingers
  gnome(c, 20, 47, { s = 1.15, d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 12, 7 }, true) } })
  c:fill(c:line({ { 36, 38 }, { 43, 36 } }, 1), "#e8c048")
  part(c, R(c, 40, 35, 44, 37), "#e8c048", { noline = true })
  part(c, c:ellipse(37, 40, 2, 2), "#aeb4bc", { noline = true }); c:fill(c:ellipse(37, 40, 1, 1), "#7a5a3a")
  for i, dx in ipairs({ -1, 1, 3 }) do
    c:fill(c:line({ { 36 + dx, 42 }, { 36 + dx, 46 } }, 1), "#e8c048")
    c:px(36 + dx - 1, 46, "#e8c048"); c:px(36 + dx + 1, 46, "#e8c048")
  end
  finish(c, "w4_padlock_key")
end

-- 14. hoop_driver: cooper's yard; hammer and driver bang an iron hoop down a rain barrel
function S.w4_hoop_driver()
  seed = 74
  local c = new()
  day(c, 36, { cloud = 52, sky = { "#b4dae4", "#c8e4e8", "#d8eeea" } })
  -- plank fence
  for x = 5, 66, 5 do part(c, R(c, x, 24, x + 3, 38), "#b07a45", { noline = true }); fl(c, R(c, x, 24, x + 3, 24), "#d9a660") end
  fl(c, R(c, 4, 29, 68, 29), "#744626"); fl(c, R(c, 4, 34, 68, 34), "#744626")
  -- the barrel: bulging staves, hoops only on the lower half, loose staves at the top
  part(c, c:ellipse(38, 33, 13, 15), "#b8803e", { shade = true })
  for x = 28, 48, 4 do fl(c, R(c, x, 20, x, 46), "#8a5a35") end
  fl(c, R(c, 27, 20, 49, 21), "#744626")
  c:fill(c:ellipse(38, 19, 11, 2), "#d9a660"); c:fill(c:ellipse(38, 19, 8, 1), "#a8703e")
  for _, y in ipairs({ 36, 42 }) do
    local m = R(c, 26, y, 50, y + 1):clip(c:ellipse(38, 33, 13, 15))
    c:fill(m, "#5b6470"); fl(c, R(c, 30, y, 46, y), "#8a909a")
  end
  -- the hoop being driven: a loose ring higher up with a gap below
  local ring = R(c, 26, 28, 50, 29):clip(c:ellipse(38, 33, 13, 15))
  c:fill(ring, "#8a909a"); fl(c, R(c, 29, 28, 47, 28), "#aeb4bc")
  -- driver + gnome with a big mallet
  gnome(c, 14, 48, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 20 }, true) } })
  c:fill(c:line({ { 24, 28 }, { 26, 18 } }, 2), "#8a5a35")
  part(c, R(c, 21, 13, 31, 18), "#b07a45")
  part(c, R(c, 26, 27, 30, 30), "#8b929c")
  motion(c, { { 31, 12, 33, 12 }, { 33, 15, 35, 15 }, { 31, 25, 31, 26 } }, "#fff8e0")
  -- spare hoops leaning on the fence
  for i, x in ipairs({ 60, 64 }) do
    local m = c:ellipse(x, 42, 3, 5); c:fill(m, "#8a909a"); c:fill(c:ellipse(x, 42, 1, 3), "#7ea85a"); c:outline(m)
  end
  finish(c, "w4_hoop_driver")
end

-- 15. rope_walk_yarns: the long rope shed; the rope-maker walks backwards twisting hemp, talking; a tall-tale bubble
-- 15. rope_walk_yarns: the long rope shed; the rope-maker walks backwards twisting hemp from a wheel, talking; a tall-tale bubble
function S.w4_rope_walk_yarns()
  seed = 75
  local c = new()
  barn(c, 40, "#c2a470", "#a88a58", "#8a5a35")
  -- long shed: windows letting in daylight, posts with pegs receding to the right
  for _, x in ipairs({ 20, 44 }) do
    part(c, R(c, x, 9, x + 9, 18), "#8a5a35"); c:fill(R(c, x + 1, 10, x + 8, 17), "#a8d4e0"); fl(c, R(c, x + 4, 10, x + 4, 17), "#8a5a35")
  end
  for _, x in ipairs({ 6, 30, 54 }) do
    part(c, R(c, x, 4, x + 2, 40), "#6b4a2e", { noline = true })
    part(c, R(c, x + 3, 34, x + 5, 35), "#aeb4bc", { noline = true })
  end
  -- the long rope sagging between the pegs, to the spinning wheel on the right
  local pts = { { 24, 36 }, { 31, 37 }, { 36, 38 }, { 42, 37 }, { 50, 36 }, { 56, 35 } }
  c:fill(c:line(pts, 2), "#d9bc7a")
  for i = 1, #pts - 1 do c:px(pts[i][1] + 2, pts[i][2], "#b89a5a") end
  c:px(40, 37, "#b89a5a"); c:px(48, 36, "#b89a5a")
  -- wheel on a frame
  part(c, R(c, 58, 28, 66, 40), "#6b4a2e", { noline = true })
  part(c, c:ellipse(62, 31, 5, 5), "#a8703e", { shade = true }); c:fill(c:ellipse(62, 31, 3, 3), "#c2a470")
  fl(c, R(c, 62, 27, 62, 35), "#a8703e"); fl(c, R(c, 58, 31, 66, 31), "#a8703e"); c:px(62, 31, "#4a3a2e")
  part(c, R(c, 56, 34, 58, 36), "#d9bc7a", { noline = true })
  -- the rope-maker, mid-stride walking backwards, hemp bundle at his belt, rope in his hand
  gnome(c, 24, 48, { s = 1.2, d = 1, walk = -1, eyes = "open", arms = { arm({ 4, 9 }, { 9, 8 }, true) } })
  part(c, c:ellipse(17, 38, 3, 4), "#d9bc7a"); for y = 35, 41, 2 do fl(c, R(c, 15, y, 19, y), "#b89a5a") end
  -- speech bubble, a knot inside
  part(c, c:rrect(6, 6, 24, 16, 3), "#f4eee0")
  c:fill(c:poly({ { 10, 16 }, { 14, 16 }, { 11, 21 } }), "#f4eee0")
  c:fill(c:line({ { 9, 12 }, { 13, 8 }, { 17, 12 }, { 13, 14 }, { 13, 10 }, { 22, 9 } }, 1), "#b88a4a")
  finish(c, "w4_rope_walk_yarns")
end

local order = { "w4_wobbly_stool", "w4_bird_box", "w4_snail_glaze", "w4_turn_dibber", "w4_rocking_horse", "w4_rain_catcher", "w4_dovetail_lesson", "w4_kettle_whistleoff", "w4_paper_gliders", "w4_clock_wall", "w4_pegboard_tools", "w4_screw_drawer", "w4_padlock_key", "w4_hoop_driver", "w4_rope_walk_yarns" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end

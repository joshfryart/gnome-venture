-- firefly (flyer) tables from specs/firefly.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "firefly", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 36}
S.ramps = {main = {"#6c5c7c", "#4d405e", "#3b3049", "#30263c"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#6c5c7c", "#4d405e", "#3b3049", "#30263c", "#f08a4c", "#c45c4a", "#dcb98c", "#c3944f", "#56644f", "#f4c24a", "#f0dcb4"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#4d405e",
  bshade = h"#3b3049",
  bhi = h"#6c5c7c",
  deep = h"#30263c",
  head = h"#4d405e",
  hat = h"#f08a4c",
  hatshade = h"#c45c4a",
  wing = h"#3b3049",
  belly = h"#dcb98c",
  acc = h"#dcb98c",
  accs = h"#c3944f",
  eye = h"#dcb98c",
  q = h"#f4c24a",
  qshade = h"#f0dcb4",
  qhi = h"#f4c24a",
  ink = h"#30263c", arm = h"#4d405e", fbase = h"#3b3049", fshade = h"#30263c"}
S.bw, S.top = 16, 9
S.quirk = {w = 3, h = 4, anchor = "chest", hex = "#f4c24a"}

-- Stage 3 (Opus): hand-placed pixel art for one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local b, hd = o.body, o.head
  local walk = frame >= 3
  local s = o.armL                      -- wing spread: 2 open, 1 down-stroke, 0 half, -1 closed
  local top = species.T + 1 + hd         -- first painted row (outline sits one above)
  local G, TAG, cur = {}, {}, "x"
  local floor, ceil, sqrt, rad, cos, sin = math.floor, math.ceil, math.sqrt, math.rad, math.cos, math.sin
  local function P(x, y, c)
    if c and x >= 1 and x <= 62 and y >= top and y <= 70 then G[y * 64 + x] = c; TAG[y * 64 + x] = cur end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function tag(x, y) return TAG[y * 64 + x] end
  local function mx(x) return 63 - x end
  local function lit(nx, ny, r)
    local d = nx * 0.55 + ny * 0.83
    if d > 0.92 and r.deep then return r.deep end
    if d > 0.42 then return r.shade end
    if d < -0.55 then return r.hi end
    return r.base
  end
  local function paint(r, x, y, nx, ny)
    if type(r) == "function" then return r(x, y, nx, ny) end
    if type(r) == "table" then return lit(nx, ny, r) end
    return r
  end
  local function E(cx, cy, rx, ry, r)
    for y = floor(cy - ry - 1), ceil(cy + ry + 1) do
      for x = floor(cx - rx - 1), ceil(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, paint(r, x, y, nx, ny)) end
      end
    end
  end
  -- rotated ellipse from (x0,y0) along (dx,dy), length L, half width w
  local function limb(x0, y0, dx, dy, L, w, r)
    local n = sqrt(dx * dx + dy * dy); dx, dy = dx / n, dy / n
    local cx, cy, R = x0 + dx * L / 2, y0 + dy * L / 2, L / 2 + w
    for y = floor(cy - R), ceil(cy + R) do
      for x = floor(cx - R), ceil(cx + R) do
        local px, py = x - cx, y - cy
        local u, v = (px * dx + py * dy) / (L / 2), (-px * dy + py * dx) / w
        if u * u + v * v <= 1 then P(x, y, paint(r, x, y, u * dx - v * dy, u * dy + v * dx)) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local ch = row:sub(i, i)
        if ch ~= "." then P(x0 + i - 1, y0 + j - 1, map[ch]) end
      end
    end
  end
  -- paint pixels of part `back` that touch part `front` with colour c (inner separation line)
  local function sep(back, front, c)
    local list = {}
    for k, t in pairs(TAG) do
      if t == back then
        local x, y = k % 64, k // 64
        for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
          if tag(x + d[1], y + d[2]) == front then list[#list + 1] = k; break end
        end
      end
    end
    for _, k in ipairs(list) do G[k] = c end
  end
  local function wingdir(sg, e) e = rad(e); return sg * cos(e), -sin(e) end
  -- firefly: orange shield cap, plum body, cream belly plate, glowing bulb (quirk)
  local BD = {hi = H"#6c5c7c", base = H"#4d405e", shade = H"#3b3049", deep = H"#30263c"}
  local ELY = {hi = H"#6c5c7c", base = H"#3b3049", shade = H"#30263c", deep = H"#30263c"}
  local OR = {hi = H"#f08a4c", base = H"#f08a4c", shade = H"#c45c4a", deep = H"#c45c4a"}
  local CR, CRS, BAND = H"#dcb98c", H"#c3944f", H"#56644f"
  local MEM = {hi = H"#f0dcb4", base = H"#dcb98c", shade = H"#c3944f", deep = H"#c3944f"}
  local GLOW, GHI = H"#f4c24a", H"#f0dcb4"
  local FACE = {hi = BD.hi, base = BD.hi, shade = BD.base, deep = BD.shade}
  local EW = walk and ({[2] = 42, [1] = 14, [0] = -18, [-1] = -60})[s] or -58
  local bulbmap = {g = GLOW, c = GHI, b = BAND}
  local swing = walk and (s >= 1 and -1 or (s < 0 and 1 or 0)) or 0
  local function bulb(x0, y0)   -- 3x4 glow bulb with a band cap
    cur = "bulb"
    stamp(x0, y0, {".b.", "cgg", "cgg", "ggg", ".g."}, bulbmap)
  end
  local function spill()   -- warm light from the bulb on nearby plum pixels
    local L = {}
    for k, t in pairs(TAG) do if t == "bulb" and G[k] ~= BAND then L[#L + 1] = k end end
    for _, k in ipairs(L) do
      local x, y = k % 64, k // 64
      for dy = -2, 2 do for dx = -2, 2 do
        local t = tag(x + dx, y + dy)
        if (t == "body" or t == "arm" or t == "wing") and math.abs(dx) + math.abs(dy) >= 2 and math.abs(dx) + math.abs(dy) <= 3 then
          local c = get(x + dx, y + dy)
          if c == BD.base or c == BD.shade or c == BD.deep then G[(y + dy) * 64 + x + dx] = BD.hi end
        end
      end end
    end
  end
  local function eye(x, y)   -- cream eye with ink pill pupil and glint
    stamp(x - 1, y - 1, {".cc.", "cppc", "cppc", ".cp."}, {c = GHI, p = INK})
    P(x, y, GHI)
  end
  local function antenna(x0, y0, x1, y1, knob)
    cur = "ant"
    line(x0, y0, x1, y1, BD.shade)
    P(x1, y1, knob); P(x1 + (x1 < x0 and -1 or 1), y1, knob)
  end
  local function foot(cx, lift, r)
    local bot = 70 + lift
    cur = "leg"
    for y = 63 + b, bot - 2 do P(cx, y, r.shade); P(cx + 1, y, r.deep) end
    E(cx + 0.5, bot - 0.5, 2.2, 1.6, r)
  end
  local function wing(sg, sx, sy, e, L, mem)
    local dx, dy = wingdir(sg, e)
    if mem then
      local mx_, my_ = wingdir(sg, e - 32)
      cur = "mem"; limb(sx, sy + 2, mx_, my_, L + 2, 3.6, function(x, y, nx, ny)
        local px, py = x - sx, y - sy - 2
        local v = -px * my_ + py * mx_
        if math.abs(v) < 0.6 and (px * mx_ + py * my_) > 3 then return CRS end
        return lit(nx, ny, MEM)
      end)
    end
    cur = "wing"; limb(sx, sy, dx, dy, L, 3, ELY)
    -- elytra rim highlight along the leading edge
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR = o.footR, o.footL   -- front: viewer-left is creature right
    if not front then ftVL, ftVR = o.footL, o.footR end
    if front then
      wing(-1, 26, 44 + b, EW, 14, walk); wing(1, 37, 44 + b, EW, 14, walk)
    end
    foot(26, ftVL, BD); foot(36, ftVR, BD)
    -- body
    cur = "body"
    E(31.5, 53 + b, 10.5, 12.5, BD)
    if front then
      cur = "belly"
      E(31.5, 55 + b, 6.2, 9.5, function(x, y, nx, ny)
        local yy = y - b
        if yy >= 61 then return (yy == 61 and nx < 0.1) and GHI or GLOW end
        if yy % 3 == 0 then return CRS end
        if nx > 0.6 then return CRS end
        return CR
      end)
    else
      cur = "body"
      for _, yy in ipairs({53, 57, 61}) do
        for x = 23, 40 do if get(x, yy + b) and tag(x, yy + b) == "body" then P(x, yy + b, BD.shade) end end
      end
      cur = "glow"
      for x = 20, 43 do for yy = 62, 66 do
        if tag(x, yy + b) == "body" then P(x, yy + b, (yy == 62 and x < 30) and GHI or GLOW) end
      end end
      for x = 20, 43 do if tag(x, 61 + b) == "body" then P(x, 61 + b, BD.deep) end end
    end
    -- belt band
    cur = "band"
    for x = 21, 42 do
      for yy = 47, 48 do if get(x, yy + b) then P(x, yy + b, (yy == 48 and x > 36) and BD.deep or BAND) end end
    end
    -- kerchief (front) / collar (back)
    cur = "band"
    for j = 0, 3 do for x = 26 + j, 37 - j do P(x, 39 + j + b, BAND) end end
    if front then P(31, 40 + b, CR); P(32, 40 + b, CR) end
    -- little front legs (arms)
    cur = "arm"
    local aa = walk and (s >= 1 and -1 or 1) or 0
    limb(23, 43 + b, -0.45, 1, 7, 1.8, BD); limb(40, 43 + b, 0.45, 1, 7, 1.8, BD)
    P(20 , 49 + b + aa, BD.base); P(43, 49 + b + aa, BD.shade)
    -- quirk bulb
    if front then bulb(23 + swing, 49 + b) else bulb(30 + swing, 65 + b) end
    if not front then cur = "bulb"; P(31 + swing, 64 + b, BAND) end
    -- head
    cur = "face"
    E(31.5, 31 + hd, 9.6, 7.2, FACE)
    if front then
      E(31.5, 34.5 + hd, 4.3, 2.5, function(x, y, nx, ny) return ny > 0.5 and CRS or CR end)
      eye(26, 29 + hd); eye(36, 29 + hd)
      P(24, 33 + hd, OR.shade); P(25, 33 + hd, OR.shade); P(38, 33 + hd, OR.shade); P(39, 33 + hd, OR.shade)
      P(31, 33 + hd, BD.deep); P(32, 33 + hd, BD.deep); P(31, 32 + hd, BD.shade); P(32, 32 + hd, BD.shade)
      P(29, 35 + hd, INK); P(30, 36 + hd, INK); P(31, 36 + hd, INK); P(32, 36 + hd, INK); P(33, 36 + hd, INK); P(34, 35 + hd, INK)
    end
    -- shield cap
    cur = "cap"
    E(31.5, 21 + hd, 11.6, front and 6.6 or 7.6, function(x, y, nx, ny)
      if ny > 0.72 then return OR.shade end
      return lit(nx, ny, OR)
    end)
    if front then
      stamp(29, 18 + hd, {".dd.", "dddd", ".dd."}, {d = BD.deep}); P(29, 18 + hd, BD.shade)
    else
      for y = 16, 26 do P(31, y + hd, OR.shade) end
    end
    P(24, 18 + hd, GHI); P(25, 17 + hd, GHI)
    -- antennae
    antenna(28, 15 + hd, 25, top, BD.hi); antenna(35, 15 + hd, 38, top, BD.hi)
    if not front then
      wing(-1, 29, 43 + b, walk and EW or -80, walk and 15 or 19, walk)
      wing(1, 34, 43 + b, walk and EW or -80, walk and 15 or 19, walk)
      if not walk then cur = "wing"; for y = 44, 60 do P(31, y + b, BD.deep); P(32, y + b, BD.deep) end end
    end
    sep("wing", "body", BD.deep)
    sep("mem", "body", BD.deep)
    sep("body", "arm", BD.deep)
    sep("body", "bulb", BD.deep)
    sep("belly", "bulb", BD.deep)
    sep("band", "bulb", BD.deep)
    sep("face", "cap", OR.shade)
    spill()
  else
    -- side, facing right; near side = creature right
    local e = walk and EW or -58
    -- far wing
    if walk then
      local dx, dy = wingdir(-1, e + 12)
      cur = "fwing"; limb(28, 42 + b, dx, dy, 13, 3.2, {hi = ELY.base, base = ELY.shade, shade = ELY.deep, deep = ELY.deep})
    end
    foot(29, o.footL, {hi = BD.shade, base = BD.shade, shade = BD.deep, deep = BD.deep})
    foot(34, o.footR, BD)
    cur = "body"
    E(23.5, 58 + b, 7.5, 7.5, BD)          -- abdomen, back-left
    E(30.5, 52 + b, 9, 12, BD)              -- thorax
    for _, yy in ipairs({55, 59, 63}) do
      for x = 16, 26 do if tag(x, yy + b) == "body" and get(x, yy + b) then P(x, yy + b, BD.shade) end end
    end
    cur = "glow"
    for x = 14, 24 do for yy = 54, 66 do
      if tag(x, yy + b) == "body" and x + (66 - yy) * 0.6 <= 22 then
        P(x, yy + b, (x <= 17 and yy <= 61) and GHI or GLOW)
      end
    end end
    cur = "belly"
    E(35.5, 55 + b, 3.6, 8.5, function(x, y, nx, ny)
      if tag(x, y) ~= "body" then return nil end
      if (y - b) % 3 == 0 then return CRS end
      return nx > 0.4 and CRS or CR
    end)
    cur = "band"
    for x = 16, 40 do for yy = 47, 48 do if get(x, yy + b) then P(x, yy + b, BAND) end end end
    for x = 30, 38 do P(x, 40 + b, BAND); if x >= 32 then P(x, 41 + b, BAND) end end
    P(37, 42 + b, BAND); P(36, 42 + b, BAND)
    bulb(16 + swing, 63 + b); cur = "bulb"; P(17 + swing, 62 + b, BAND)
    -- head
    cur = "face"
    E(37.5, 31 + hd, 8.2, 7, FACE)
    E(43, 32 + hd, 3.5, 3, FACE)
    E(44, 33.5 + hd, 2.6, 2.2, function(x, y, nx, ny) return ny > 0.5 and CRS or CR end)
    eye(41, 28 + hd)
    P(39, 33 + hd, OR.shade); P(40, 33 + hd, OR.shade)
    P(46, 32 + hd, BD.shade); P(46, 33 + hd, BD.deep)
    P(43, 35 + hd, INK); P(44, 35 + hd, INK); P(45, 34 + hd, INK)
    cur = "cap"
    E(34, 21 + hd, 11, 6.6, function(x, y, nx, ny)
      if ny > 0.7 then return OR.shade end
      return lit(nx, ny, OR)
    end)
    stamp(34, 18 + hd, {".dd", "ddd"}, {d = BD.deep})
    P(27, 17 + hd, GHI); P(28, 17 + hd, GHI)
    antenna(39, 15 + hd, 43, top, BD.hi)
    -- near arm
    cur = "arm"
    limb(35, 44 + b, 0.8, 1, 7, 1.7, BD)
    -- near wing (lies along the back)
    local dx, dy = wingdir(-1, e)
    if walk then
      local m1, m2 = wingdir(-1, e - 24)
      cur = "mem"; limb(27, 45 + b, m1, m2, 13, 3.3, MEM)
    end
    cur = "wing"; limb(27, 43 + b, dx, dy, 15, 3.4, ELY)
    sep("fwing", "body", BD.deep)
    sep("wing", "body", BD.deep)
    sep("mem", "body", BD.deep)
    sep("body", "arm", BD.deep)
    sep("belly", "arm", BD.deep)
    sep("body", "bulb", BD.deep)
    sep("face", "cap", OR.shade)
    sep("face", "cap", OR.shade)
    spill()
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S

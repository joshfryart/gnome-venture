-- stick-insect (six-legged) tables from specs/stick-insect.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "stick-insect", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 7, W = 34}
S.ramps = {main = {"#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c9b6f2", "#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a", "#9a6e48", "#d9668a", "#a8496e", "#6e4a44", "#7cc35a", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#7f5cc4",
  bshade = h"#5c4196",
  bhi = h"#a88ae0",
  deep = h"#3f2c6a",
  head = h"#7f5cc4",
  hat = h"#9a6e48",
  hatshade = h"#9a6e48",
  wing = h"#5c4196",
  belly = h"#9a6e48",
  acc = h"#9a6e48",
  accs = h"#9a6e48",
  eye = h"#9a6e48",
  q = h"#6e4a44",
  qshade = h"#7cc35a",
  qhi = h"#6e4a44",
  ink = h"#3f2c6a", arm = h"#7f5cc4", fbase = h"#5c4196", fshade = h"#3f2c6a"}
S.bw, S.top = 20, 8
S.quirk = {w = 5, h = 3, anchor = "crown", hex = "#6e4a44"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
-- Stage 3 (Opus): sturdy 2 px limbs with knee knobs, bright lilac body with a dashed dorsal stripe,
-- clear hooded head with two antennae, twig-hat quirk. One 64x80 frame, hard pixels, outline via N.outline.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd = o.body, o.head
  local fL, fR, aL, aR = o.footL, o.footR, o.armL, o.armR
  local floor, abs, max = math.floor, math.abs, math.max
  local K = h(species.outline)
  local LL, HI, BA, SH, DP = h"#c9b6f2", h"#a88ae0", h"#7f5cc4", h"#5c4196", h"#3f2c6a"
  local FACE, BARK = h"#9a6e48", h"#6e4a44"
  local PINK, PINKS, LEAF = h"#d9668a", h"#a8496e", h"#7cc35a"
  local SL, SD = h"#aaa9b8", h"#74758c"
  local wi = frame - 2
  local walking = frame >= 3
  local SWAY = {0, 1, 1, 0, -1, -1}
  local sw = walking and SWAY[wi] or 0
  local tsw = walking and -({0, 0, 1, 1, 0, -1})[wi] or 0
  local G = {}
  local MIR, MC = false, 0
  local function P(x, y, c)
    x, y = floor(x), floor(y)
    if MIR then x = MC - x end
    if c and x >= 0 and x <= 63 and y >= 0 and y <= 79 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[floor(y) * 64 + floor(x)] end
  local function ell(cx, cy, rx, ry, fn)
    for y = floor(cy - ry - 1), floor(cy + ry + 1) do
      for x = floor(cx - rx - 1), floor(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, fn(x, y, nx, ny)) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  -- 2 px thick segment: steep -> second pixel at x+1, shallow -> at y+1
  local function thick(x0, y0, x1, y1, ca, cb)
    local n = max(abs(x1 - x0), abs(y1 - y0), 1)
    local steep = abs(y1 - y0) >= abs(x1 - x0)
    for i = 0, n do
      local x, y = floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5)
      if steep then P(x + 1, y, cb) else P(x, y + 1, cb) end
    end
    for i = 0, n do
      local x, y = floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5)
      P(x, y, ca)
    end
  end
  local function rows(x0, y0, t, map)
    for j, row in ipairs(t) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  -- leg tones: tone 1 = lit near leg, 2 = shaded near leg (right side), 3 = far leg
  local TONES = {
    {fa = HI, fb = BA, ta = BA, tb = SH, k1 = LL, k2 = HI},
    {fa = BA, fb = HI, ta = SH, tb = BA, k1 = HI, k2 = BA},
    {fa = SH, fb = BA, ta = DP, tb = SH, k1 = BA, k2 = SH},
  }
  -- hip -> knee (femur) -> foot (tibia); 3x2 knee knob; 3 px bark tarsus pointing dir
  local function leg(hx, hy, kx, ky, fx, lift, dir, tone)
    local t = TONES[tone]
    local fy = 70 + lift
    thick(hx, hy, kx, ky, t.fa, t.fb)
    thick(kx, ky, fx, fy - 1, t.ta, t.tb)
    P(kx - 1, ky - 1, t.k1); P(kx, ky - 1, t.k1); P(kx + 1, ky - 1, t.k2)
    P(kx - 1, ky, t.k2); P(kx, ky, t.k2); P(kx + 1, ky, t.k2)
    P(fx, fy, BARK); P(fx + 1, fy, BARK); P(fx + (dir < 0 and -1 or 2), fy, BARK)
  end
  local function twig(x, y)
    rows(x + tsw, y, {
      "LL...LL",
      ".LTTTL.",
      "TTTTTTT",
      ".T...T.",
    }, {T = BARK, L = LEAF})
  end
  local function ant(x0, y0, pts, c, tip)
    local px, py = x0, y0
    for _, p in ipairs(pts) do line(px, py, x0 + p[1], y0 + p[2], c); px, py = x0 + p[1], y0 + p[2] end
    if tip then P(px, py, tip) end
  end

  -- ground shadow (rows 65-70; the outline lands on 71)
  ell(32, 67.5, 14.5, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)

  if view == "front" or view == "back" then
    local front = view == "front"
    local CX = 31.5 + sw
    local cx = floor(CX)            -- left of the two centre columns
    MC = 2 * cx + 1                 -- mirror: x -> MC - x
    -- tripods (front view: viewer-left = creature right)
    local vl_mid, vr_mid, vl_rear, vr_rear = fL, fR, fR, fL
    if not front then vl_mid, vr_mid, vl_rear, vr_rear = fR, fL, fL, fR end
    local function pair(hy, ky, kxo, fxo, liftL, liftR)
      local inl, inr = liftL < 0 and 2 or 0, liftR < 0 and 2 or 0
      leg(cx - 3, hy + b, cx - kxo, ky + b + liftL, cx - fxo + inl, liftL, -1, 1)
      MIR = true
      leg(cx - 3, hy + b, cx - kxo, ky + b + liftR, cx - fxo + inr, liftR, -1, 2)
      MIR = false
    end
    pair(41, 31, 12, 14, vl_mid, vr_mid)    -- middle pair: wide knees above the body
    pair(47, 40, 7, 9, vl_rear, vr_rear)     -- rear pair, inner stance
    -- long body: thorax, ringed abdomen tapering to a tip
    for y = 28, 62 do
      local hw = y < 44 and 4 or (y < 50 and 3 or (y < 56 and 3 or (y < 60 and 2 or 1)))
      local odd = (y >= 50 and y < 56) and 1 or 0      -- 5 px rows sit on the left column
      local x0, x1 = cx + 1 - hw, cx + hw - odd
      local yy = y + b
      for x = x0, x1 do
        local i = x - x0
        local c = HI
        if i == 0 then c = (x1 - x0 >= 3) and LL or HI
        elseif i == 1 and x1 - x0 >= 5 then c = LL end
        if x == x1 then c = SH elseif x == x1 - 1 and x1 - x0 >= 4 then c = BA end
        P(x, yy, c)
      end
      -- segment rings on the abdomen
      if y >= 45 and (y - 45) % 4 == 3 then for x = x0 + 1, x1 do P(x, yy, (x == x1) and DP or SH) end end
      -- dashed dorsal / ventral stripe down the centre
      if y >= 32 then
        local seg = (y - 32) % 4
        if seg < 2 then P(cx, yy, front and BA or SH); if y < 50 then P(cx + 1, yy, front and BA or SH) end end
      end
    end
    if not front then -- folded wing cases on the thorax back
      for y = 30, 42 do P(cx - 2, y + b, LL); P(cx + 3, y + b, BA) end
      for y = 29, 43 do P(cx, y + b, (y % 2 == 0) and SH or HI); P(cx + 1, y + b, SH) end
    end
    -- forelegs held like arms: shoulder -> elbow out -> hands folded at the middle
    local function arm(a, mir)
      MIR = mir
      local ey = 37 + b - a
      thick(cx - 3, 30 + b, cx - 7, ey, mir and BA or HI, mir and SH or BA)
      thick(cx - 7, ey, cx - 2, 42 + b - 2 * a, mir and SH or BA, mir and BA or SH)
      P(cx - 8, ey - 1, mir and HI or LL); P(cx - 7, ey - 1, mir and HI or LL); P(cx - 8, ey, mir and BA or HI); P(cx - 6, ey - 1, BA)
      P(cx - 1, 42 + b - 2 * a, BARK); P(cx - 1, 43 + b - 2 * a, BARK)
      MIR = false
    end
    if front then arm(aR, false); arm(aL, true) else arm(aL, false); arm(aR, true) end
    -- bow at the collar (front) or between the shoulders (back)
    rows(cx - 2, 27 + b, {
      "DD.DD",
      "dDkDd",
      "d...d",
    }, {d = PINKS, D = PINK, k = PINKS})
    -- antennae: 1 px, curling outward, tips at y 8
    ant(cx - 2, 13 + hd, {{-1, -1}, {-2, -3}, {-4, -5}, {-6, -5}}, BA, LL)
    ant(cx + 3, 13 + hd, {{1, -1}, {2, -3}, {4, -5}, {6, -5}}, BA, LL)
    -- head: hood
    local hcx, hcy = cx + 0.5, 19 + hd
    ell(hcx, hcy, 6.3, 7.1, function(x, y, nx, ny)
      local s = nx * 0.6 + ny * 0.8
      if s > 0.6 then return SH end
      if s > 0.25 then return BA end
      if s < -0.55 then return LL end
      return HI
    end)
    P(cx, 26 + hd, BA); P(cx + 1, 26 + hd, SH); P(cx, 27 + hd, BA); P(cx + 1, 27 + hd, SH)
    if front then
      ell(hcx, hcy + 1.6, 4.4, 4.8, function(x, y, nx, ny)
        if nx * 0.6 + ny * 0.8 > 0.8 then return BARK end
        return FACE
      end)
      for x = cx - 3, cx + 4 do if get(x, 16 + hd) == FACE then P(x, 16 + hd, BA) end end
      for _, e in ipairs({cx - 2, cx + 2}) do
        P(e, 19 + hd, LL); P(e + 1, 19 + hd, K)
        P(e, 20 + hd, K); P(e + 1, 20 + hd, K)
      end
      P(cx, 21 + hd, BARK); P(cx + 1, 21 + hd, BARK)
      P(cx - 1, 23 + hd, K); P(cx, 24 + hd, K); P(cx + 1, 24 + hd, K); P(cx + 2, 23 + hd, K)
      P(cx - 3, 22 + hd, PINK); P(cx + 4, 22 + hd, PINK)
    else
      for y = 14, 25 do P(cx + 1, y + hd, BA) end
      for y = 15, 20 do P(cx - 2, y + hd, LL) end
    end
    twig(cx - 3, 9 + hd)

  else -- side, facing right
    local SA = {-3, -1, 1, 3, 1, -1}
    local sa = walking and SA[wi] or 0
    local sb = -sa
    local function bx(y) return floor(36 - (y - 27) * 0.26 + 0.5) end
    -- far legs (dark): middle = tripod B (footR), rear = tripod A (footL)
    leg(bx(41) + 1, 41 + b, bx(41) + 6 + floor(sb / 2), 34 + b + fR, 40 + sb, fR, 1, 3)
    leg(bx(47), 47 + b, bx(47) - 4 + floor(sa / 2), 40 + b + fL, 27 + sa, fL, -1, 3)
    local function arm(a, far)
      local sx = bx(31)
      local ex, ey = sx + 4, 38 + b
      local hx, hy = sx + 9 + a, 33 + b - a
      thick(sx, 31 + b, ex, ey, far and SH or HI, far and DP or BA)
      thick(ex, ey, hx, hy, far and SH or BA, far and DP or SH)
      P(ex, ey - 1, far and BA or LL); P(ex + 1, ey - 1, far and SH or HI)
      P(hx + 1, hy, BARK); P(hx + 2, hy, BARK)
    end
    arm(aL, true)
    -- body: thorax 5, abdomen 4 then 3, ringed
    for y = 27, 62 do
      local w = y < 44 and 5 or (y < 54 and 4 or 3)
      local x0 = bx(y) - floor(w / 2)
      local yy = y + b
      for x = x0, x0 + w - 1 do
        local i = x - x0
        local c = HI
        if i == 0 then c = LL elseif i == w - 1 then c = SH elseif i == w - 2 and w > 3 then c = BA end
        P(x, yy, c)
      end
      if y >= 45 and (y - 45) % 4 == 3 then for x = x0 + 1, x0 + w - 1 do P(x, yy, (x == x0 + w - 1) and DP or SH) end end
      if y >= 31 and (y - 31) % 4 < 2 then P(x0, yy, HI) end  -- dashed light stripe along the back
    end
    -- near legs: middle = tripod A (footL), rear = tripod B (footR)
    leg(bx(41) + 1, 41 + b, bx(41) + 7 + floor(sa / 2), 35 + b + fL, 42 + sa, fL, 1, 1)
    leg(bx(47), 47 + b, bx(47) - 8 + floor(sb / 2), 42 + b + fR, 25 + sb, fR, -1, 1)
    rows(bx(28) - 1, 27 + b, {"dDd", "dkD", "d.d"}, {d = PINKS, D = PINK, k = PINKS})
    arm(aR, false)
    -- head: hood capsule, face on the right
    local hcx, hcy = 39.5, 19 + hd
    ant(39, 13 + hd, {{1, -2}, {3, -4}, {5, -5}, {8, -5}}, BA, LL)
    ell(hcx, hcy, 5.9, 6.9, function(x, y, nx, ny)
      local s = nx * 0.6 + ny * 0.8
      if s > 0.6 then return SH end
      if s > 0.25 then return BA end
      if s < -0.55 then return LL end
      return HI
    end)
    ell(hcx + 2.2, hcy + 1.5, 3.8, 4.6, function(x, y, nx, ny)
      if ny > 0.75 then return BARK end
      return FACE
    end)
    for x = 39, 44 do if get(x, 16 + hd) == FACE then P(x, 16 + hd, BA) end end
    P(42, 19 + hd, LL); P(43, 19 + hd, K); P(42, 20 + hd, K); P(43, 20 + hd, K)
    P(46, 21 + hd, FACE); P(46, 22 + hd, BARK)
    P(43, 23 + hd, K); P(44, 23 + hd, K); P(45, 22 + hd, K)
    P(40, 22 + hd, PINK)
    P(37, 26 + hd, BA); P(38, 26 + hd, HI)
    twig(34, 9 + hd)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, K)
end
return S

-- stick-insect (six-legged) tables from specs/stick-insect.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "stick-insect", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 7, W = 34}
S.ramps = {main = {"#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a", "#9a6e48", "#d9668a", "#a8496e", "#6e4a44", "#7cc35a", "#aaa9b8", "#74758c"}
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
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd = o.body, o.head
  local floor, abs = math.floor, math.abs
  local K = h(species.outline)
  local HI, BA, SH, DP = h"#a88ae0", h"#7f5cc4", h"#5c4196", h"#3f2c6a"
  local FACE, BARK = h"#9a6e48", h"#6e4a44"
  local PINK, PINKS, LEAF = h"#d9668a", h"#a8496e", h"#7cc35a"
  local SL, SD = h"#aaa9b8", h"#74758c"
  local function P(x, y, c) N.px(img, floor(x), floor(y), c) end
  local function R(x, y, w, hh, c) N.rect(img, x, y, w, hh, c) end
  local function E(x, y, w, hh, c) N.ellipse(img, x, y, w, hh, c) end
  local function rows(x0, y0, t, map)
    for j, row in ipairs(t) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(abs(x1 - x0), abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  -- twig leg: hip -> knee (2 px thigh) -> foot (1 px shin), knee knob, toe at the sole
  local function leg(hx, hy, kx, ky, fx, lift, dir, far)
    local fy = 70 + lift
    local lit = far and BARK or FACE
    line(hx, hy + 1, kx, ky + 1, BARK); line(hx, hy, kx, ky, lit)
    line(kx, ky, fx, fy, lit)
    if not far then line(kx + 1, ky + 1, fx + 1, fy - 1, BARK) end
    P(kx, ky - 1, lit)
    P(fx + dir, fy, BARK)
  end
  -- foreleg held like an arm: shoulder -> elbow -> hand (2 px nub)
  local function arm(sx, sy, ex, ey, hx, hy, far)
    local lit = far and BARK or FACE
    line(sx, sy + 1, ex, ey + 1, BARK); line(sx, sy, ex, ey, lit)
    line(ex, ey, hx, hy, lit)
    P(hx, hy + 1, BARK); P(hx + 1, hy, lit)
  end
  -- quirk: twig hat (twig + two 2x1 leaves), sways on x with the walk
  local sway = (frame == 4 or frame == 5) and 1 or ((frame == 7 or frame == 8) and -1 or 0)
  local function twig(x, y)
    rows(x + sway, y, {
      "LL...LL",
      "LLT.TLL",
      "..TTT..",
      "TTTTTTT",
    }, {T = BARK, L = LEAF})
  end
  local function hood(x, y, w, hh)
    E(x, y, w, hh, SH)
    E(x, y, w - 1, hh - 1, BA)
    E(x + 2, y + 1, w - 8, hh - 8, HI)
    E(x + 3, y + 2, w - 7, hh - 7, BA)
  end
  E(17, 65, 30, 6, SD)
  E(19, 65, 26, 4, SL)
  local fL, fR, aL, aR = o.footL, o.footR, o.armL, o.armR
  local wi = frame - 2                     -- walk index 1..6 (<= 0 idle)

  if view == "front" or view == "back" then
    local front = view == "front"
    local function M(x) return 63 - x end
    -- walking legs: middle pair = tripod-split (L mid with B, R mid with A), rear pair the other way
    local inL = fL < 0 and 1 or 0
    local inR = fR < 0 and 1 or 0
    leg(28, 48 + b, 23, 45 + b, 22 + inL, fL, -1)                  -- L rear (A)
    leg(M(28), 48 + b, M(23), 45 + b, M(22) - inL, fL, 1)          -- R rear mirrored, tripod A
    leg(28, 44 + b, 20, 38 + b, 17 + inR, fR, -1)                  -- L middle (B)
    leg(M(28), 44 + b, M(20), 38 + b, M(17) - inR, fR, 1)      -- R middle (B)
    -- body: thorax, then a long ringed abdomen
    for y = 30, 57 do
      local w = y < 43 and 8 or (y < 51 and 6 or (y < 55 and 4 or 2))
      local x0 = 32 - w // 2
      local yy = y + b
      R(x0, yy, w, 1, BA)
      P(x0, yy, HI)
      P(x0 + w - 1, yy, SH)
      if w > 4 then P(x0 + 1, yy, front and HI or BA); P(x0 + w - 2, yy, SH) end
      if y > 42 and (y - 43) % 4 == 0 and w > 2 then R(x0, yy, w, 1, DP) end
    end
    if front then
      for y = 32, 41 do P(31, y + b, HI); P(32, y + b, HI) end     -- chest plate
      P(31, 42 + b, BA); P(32, 42 + b, BA)
    else
      for y = 31, 42 do P(31, y + b, SH); P(32, y + b, DP) end     -- wing-case seam
      R(29, 33 + b, 2, 5, HI)
    end
    -- forelegs held like arms, swinging with the arms column
    local yl, yr = 42 + b - aL, 42 + b - aR
    arm(28, 33 + b, 24, 38 + b, 29, yl, false)
    arm(M(28), 33 + b, M(24), 38 + b, M(29) - 1, yr, false)
    -- antennae
    local function ant(x0, dir)
      line(x0, 16 + hd, x0 + 2 * dir, 12 + hd, BARK)
      line(x0 + 2 * dir, 12 + hd, x0 + 4 * dir, 9 + hd, BARK)
      P(x0 + 5 * dir, 8 + hd, BARK); P(x0 + 6 * dir, 8 + hd, BARK); P(x0 + 7 * dir, 9 + hd, BARK)
    end
    ant(27, -1); ant(36, 1)
    hood(22, 13 + hd, 20, 17)
    if front then
      E(25, 17 + hd, 14, 13, FACE)
      R(27, 17 + hd, 10, 1, DP); P(26, 18 + hd, DP); P(37, 18 + hd, DP)
      R(28, 18 + hd, 8, 1, BARK)
      for y = 21, 26 do P(37, y + hd, BARK) end
      P(36, 27 + hd, BARK); P(35, 28 + hd, BARK)
      rows(28, 21 + hd, {"gK", "KK", "KK"}, {K = K, g = HI})
      rows(34, 21 + hd, {"gK", "KK", "KK"}, {K = K, g = HI})
      P(31, 24 + hd, FACE); P(32, 24 + hd, FACE); P(31, 25 + hd, BARK); P(32, 25 + hd, BARK)
      P(30, 26 + hd, K); P(31, 27 + hd, K); P(32, 27 + hd, K); P(33, 26 + hd, K)
      R(27, 25 + hd, 2, 1, PINK); R(35, 25 + hd, 2, 1, PINK)
    else
      for y = 17, 28 do P(31, y + hd, SH) end
      R(25, 27 + hd, 14, 1, SH)
      R(27, 28 + hd, 10, 1, DP)
    end
    rows(27, 29 + b, {
      "dD....Dd",
      "dDDppDDd",
      "dD.pp.Dd",
    }, {d = PINKS, D = PINK, p = front and PINKS or PINK})
    twig(28, 9 + hd)

  else -- side, facing right
    -- stride: tripod A foot x shift (+ = forward); tripod B opposite
    local SA = {[1] = 2, [2] = 1, [3] = -1, [4] = -2, [5] = 0, [6] = 1}
    local sa = wi >= 1 and SA[wi] or 0
    local sb = -sa
    local function bx(y) return floor(33 - (y - 30) * 0.25 + 0.5) end
    -- far legs (bark): mid = A, rear = B
    leg(31, 41 + b, 36, 38 + b, 37 + sa, fL, 1, true)
    leg(28, 47 + b, 25, 43 + b, 23 + sb, fR, -1, true)
    arm(33, 33 + b, 37, 39 + b, 41 + aR, 36 + b, true)
    -- body
    for y = 30, 57 do
      local cx = bx(y)
      local w = y < 43 and 6 or (y < 51 and 5 or (y < 55 and 4 or 2))
      local x0 = cx - w // 2
      local yy = y + b
      R(x0, yy, w, 1, BA)
      P(x0, yy, HI)
      P(x0 + w - 1, yy, SH)
      if w > 4 then P(x0 + w - 2, yy, SH) end
      if y > 42 and (y - 43) % 4 == 0 and w > 2 then R(x0, yy, w, 1, DP) end
    end
    for y = 31, 41 do P(bx(y) - 2, y + b, HI); P(bx(y) - 1, y + b, HI) end
    -- near legs: mid = B, rear = A
    leg(32, 42 + b, 38, 38 + b, 40 + sb, fR, 1)
    leg(29, 48 + b, 23, 44 + b, 20 + sa, fL, -1)
    arm(34, 33 + b, 38, 40 + b, 43 + aL, 37 + b, false)
    -- antennae (far, then near), sweeping forward
    line(37, 14 + hd, 39, 10 + hd, BARK); P(40, 9 + hd, BARK); P(41, 9 + hd, BARK)
    line(41, 14 + hd, 44, 11 + hd, BARK); line(44, 11 + hd, 45, 9 + hd, BARK)
    P(46, 8 + hd, BARK); P(47, 8 + hd, BARK); P(48, 9 + hd, BARK)
    hood(28, 13 + hd, 18, 17)
    E(35, 17 + hd, 11, 13, FACE)
    R(36, 17 + hd, 8, 1, DP); P(35, 18 + hd, DP)
    R(37, 18 + hd, 6, 1, BARK)
    rows(41, 21 + hd, {"gK", "KK", "KK"}, {K = K, g = HI})
    P(46, 23 + hd, FACE); P(46, 24 + hd, BARK)         -- button nose
    P(43, 26 + hd, K); P(44, 27 + hd, K); P(45, 26 + hd, K)
    R(38, 25 + hd, 2, 1, PINK)
    P(36, 28 + hd, BARK); P(37, 29 + hd, BARK)
    rows(34, 29 + b, {"dDd", "dpD", "d.d"}, {d = PINKS, D = PINK, p = PINKS})
    twig(30, 9 + hd)
  end
  N.outline(img, K)
end
return S

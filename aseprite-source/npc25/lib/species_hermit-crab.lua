-- hermit-crab (crawler) tables from specs/hermit-crab.md. Opus: S.draw_figure is the stage-3 art.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local S = {name = "hermit-crab", feet_y = 71, outline = "#2b1c26", plan = "crawler", T = 10, W = 42}
S.ramps = {
  crab = {"#f2906a", "#d85a40", "#a63c3c", "#6e2a3a"},   -- hi, base, shade, deep
  shell = {"#f2dcb0", "#d8b07a", "#a87c56", "#6e4c4a"},
  hat = {"#7ea6d4", "#4a6ea8", "#2f4778"}, band = "#f5b83a",
  kerchief = {"#5ca24c", "#3f7a44"},
}
S.palette_list = {"#2b1c26", "#f2906a", "#d85a40", "#a63c3c", "#6e2a3a", "#f2dcb0", "#d8b07a", "#a87c56",
  "#6e4c4a", "#7ea6d4", "#4a6ea8", "#2f4778", "#f5b83a", "#5ca24c", "#3f7a44", "#f6ead0", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}; arms = claw lift (- = up)
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, 0, -1, 0, 0}, {-1, -1, -1, 0, -1, 1},
          {0, 0, -2, 0, -1, 1}, {-1, -1, -1, 0, 0, 0}, {-1, -1, 0, -1, 1, -1}}
local h = N.hex
S.c = {body = h"#d85a40", bshade = h"#a63c3c", bhi = h"#f2906a", deep = h"#6e2a3a",
  acc = h"#d8b07a", accs = h"#a87c56", q = h"#4a6ea8", qshade = h"#2f4778", qhi = h"#7ea6d4"}
S.quirk = {w = 9, h = 6, anchor = "shell apex", hex = "#4a6ea8"}

-- Stage 3 (Opus): red crab body in a tall sandy whelk shell, stalk eyes, one big and one small claw,
-- green kerchief, tiny blue hat on the shell tip (quirk).
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd, fL, fR, aL, aR = o.body, o.head, o.footL, o.footR, o.armL, o.armR
  local floor, abs, sqrt, max = math.floor, math.abs, math.sqrt, math.max
  local K = h(species.outline)
  local CR = {hi = h"#f2906a", base = h"#d85a40", shade = h"#a63c3c", deep = h"#6e2a3a"}
  local SH = {hi = h"#f2dcb0", base = h"#d8b07a", shade = h"#a87c56", deep = h"#6e4c4a"}
  local HT = {hi = h"#7ea6d4", base = h"#4a6ea8", shade = h"#2f4778", band = h"#f5b83a"}
  local GR, GRS, CREAM = h"#5ca24c", h"#3f7a44", h"#f6ead0"
  local SL, SD = h"#aaa9b8", h"#74758c"
  local walking = frame >= 3
  local wi = frame - 2
  local sway = (frame == 4 or frame == 5) and 1 or ((frame == 7 or frame == 8) and -1 or 0)
  local G = {}
  local function P(x, y, c)
    x, y = floor(x), floor(y)
    if c and x >= 0 and x <= 63 and y >= 0 and y <= 79 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[floor(y) * 64 + floor(x)] end
  local function ell(cx, cy, rx, ry, fn)
    for y = floor(cy - ry - 1), floor(cy + ry + 1) do
      for x = floor(cx - rx - 1), floor(cx + rx + 1) do
        local nx, ny = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, fn(x, y, nx, ny)) end
      end
    end
  end
  local function lit(nx, ny, r, hi_t, sh_t)
    local s = nx * 0.6 + ny * 0.8
    if s > (sh_t or 0.5) then return r.shade end
    if s < (hi_t or -0.6) then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r) ell(cx, cy, rx, ry, function(x, y, nx, ny) return lit(nx, ny, r) end) end
  local function line(x0, y0, x1, y1, c)
    local n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local function rows(x0, y0, t, map)
    for j, row in ipairs(t) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  local CM = {h = CR.hi, b = CR.base, s = CR.shade, d = CR.deep, k = K, c = CREAM}
  local FAR = {h = CR.base, b = CR.shade, s = CR.deep, d = CR.deep, k = K, c = CR.hi}

  -- one whorl of the whelk: slanted ellipse, lit upper left, dark suture along its top edge,
  -- a band of brown dashes round its middle
  local function whorl(cx, cy, rx, ry, slope, band)
    for y = floor(cy - ry - 3), floor(cy + ry + 3) do
      for x = floor(cx - rx - 1), floor(cx + rx + 1) do
        local yy = y + 0.5 - slope * (x + 0.5 - cx)
        local nx, ny = (x + 0.5 - cx) / rx, (yy - cy) / ry
        if nx * nx + ny * ny <= 1 then
          local c = lit(nx, ny, SH, -0.55, 0.45)
          if nx * 0.6 + ny * 0.8 > 0.82 then c = SH.deep end
          local nyu = (yy - 1 - cy) / ry
          if nx * nx + nyu * nyu > 1 and ny < 0 then c = SH.deep end          -- suture line (top edge)
          if band and ny > 0.1 and ny <= 0.1 + 1.05 / ry and c ~= SH.deep then
            c = (c == SH.hi) and SH.base or SH.shade
          end
          P(x, y, c)
        end
      end
    end
  end
  -- tiny blue cap on the shell tip (quirk): crown, gold band, brim
  local function hat(x, y, back, side)
    local t
    if side then
      t = {"..hbbs..", "..bbbs..", "..gggg..", ".hbbbbs.", "bbbbbbbbs", ".sssssss."}
    elseif back then
      t = {"..hbbbs..", "..bbbbs..", "..ggggg..", "..bbbbs..", "bbbbbbbbs", ".sssssss."}
    else
      t = {"..hbbbs..", "..hbbbs..", "..gggcg..", "..bbbbs..", "hbbbbbbbs", ".sssssss."}
    end
    rows(x, y, t, {h = HT.hi, b = HT.base, s = HT.shade, g = HT.band, c = CREAM})
  end
  -- thick jointed leg: root -> knee -> tip, near legs lit, far legs shaded
  local function leg(x0, y0, kx, ky, x1, y1, far)
    local a, c = far and CR.shade or CR.base, far and CR.deep or CR.shade
    line(x0, y0, kx, ky, a); line(x0, y0 + 1, kx, ky + 1, c)
    line(kx, ky + 1, x1, y1, a)
    P(kx, ky, far and CR.base or CR.hi)
    P(x1, y1, c)
  end
  local function eye(x, y)
    rows(x, y, {".kk.", "kckk", "kkkk", ".kk."}, CM)
  end
  local function stalk(x0, y0, x1, y1, far)
    line(x0, y0, x1, y1, far and CR.shade or CR.base)
    line(x0 + 1, y0, x1 + 1, y1, far and CR.deep or CR.shade)
  end
  local SX = 31.5
  if view == "front" or view == "back" then
    local front = view == "front"
    ell(SX, 67.5, 15.5, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    -- walking legs: three a side, alternate pairs lift (crab gait)
    local lift = {fL, fR, fL}
    local liftR = {fR, fL, fR}
    for i = 2, 1, -1 do
      local spread = (i - 1) * 5
      leg(25, 58 + b, 20 - spread, 55 + b + i, 17 - spread, 70 + lift[i], i == 2)
      leg(38, 58 + b, 43 + spread, 55 + b + i, 46 + spread, 70 + liftR[i], i == 2)
    end
    -- shell: whorls from the tip down, each lower whorl overlapping the one above
    local wh = {{18.5, 2.6, 1.8}, {22, 5, 3}, {27.5, 8, 4.5}, {35.5, 11.5, 6.5}, {46, 14.5, 9.5}}
    for i, w in ipairs(wh) do whorl(SX - (5 - i) * 0.3, w[1] + b, w[2], w[3], front and 0.12 or -0.12, i >= 3) end
    if front then
      -- aperture: dark mouth of the shell with a cream lip, the crab sits in it
      ell(SX, 52 + b, 11.5, 7.5, function(x, y, nx, ny) return (ny < -0.6 and nx < 0.3) and SH.hi or SH.deep end)
      E(SX, 53.5 + b, 9.5, 6.2, CR)
      -- kerchief knotted at the chest
      for j = 0, 4 do
        local w = 13 - j * 3
        if w < 2 then w = 2 end
        local x0 = floor(SX - w / 2 + 0.5)
        for x = x0, x0 + w - 1 do P(x, 57 + j + b, (x == x0 + w - 1 and w > 2) and GRS or GR) end
      end
      P(SX - 3, 57 + b, CREAM); P(SX + 2, 58 + b, CREAM)
      -- face: smile and cheeks on the carapace front
      P(SX - 2, 54 + hd, K); P(SX - 1, 55 + hd, K); P(SX, 55 + hd, K); P(SX + 1, 54 + hd, K)
      P(SX - 5, 53 + hd, CR.hi); P(SX - 4, 53 + hd, CR.hi); P(SX + 4, 53 + hd, CR.shade); P(SX + 5, 53 + hd, CR.shade)
      P(SX - 5, 50 + hd, CREAM)
      -- eyestalks
      stalk(SX - 4, 49 + hd, SX - 6 + sway, 36 + hd, false)
      stalk(SX + 3, 49 + hd, SX + 5 + sway, 36 + hd, false)
      eye(SX - 8 + sway, 33 + hd)
      eye(SX + 4 + sway, 33 + hd)
      -- claws: big on the viewer's left, small on the right
      line(SX - 9, 55 + b, 18, 57 + b + aL, CR.shade); line(SX - 9, 54 + b, 18, 56 + b + aL, CR.base)
      line(SX + 9, 55 + b, 45, 57 + b + aR, CR.shade); line(SX + 9, 54 + b, 45, 56 + b + aR, CR.base)
      rows(12, 46 + b + aL, {
        ".hhb..bbs..",
        "hbbbb.bbbs.",
        "hbbbb.bbbs.",
        "hbbbbdbbbs.",
        "hbbbbbbbbs.",
        ".bbbbbbbss.",
        "..bbbbbsss.",
        "...sssss...",
      }, CM)
      rows(43, 50 + b + aR, {
        ".hb.bs.",
        "hbb.bbs",
        "hbbdbbs",
        ".bbbbs.",
        "..sss..",
      }, CM)
      hat(SX - 4.5 + sway, 11 + b, false, false)
    else
      -- back: crab rump under the shell, claws poking out at the sides
      line(24, 56 + b, 15, 53 + b + aR, CR.shade); line(24, 55 + b, 15, 52 + b + aR, CR.base)
      line(39, 56 + b, 48, 52 + b + aL, CR.shade); line(39, 55 + b, 48, 51 + b + aL, CR.base)
      E(SX, 57 + b, 10, 5, CR)
      for x = SX - 3, SX + 2 do P(x, 57 + b, GR) end
      rows(SX - 2, 58 + b, {"gg.gg", "g...g"}, {g = GR})
      rows(12, 49 + b + aR, {
        "..bs.",
        ".bbbs",
        "hbbbs",
        "hbbbs",
        ".bss.",
      }, CM)
      rows(46, 47 + b + aL, {
        "..hb..",
        ".hbbs.",
        "hbbbbs",
        "hbbbbs",
        ".bbss.",
        "..ss..",
      }, CM)
      for i, w in ipairs(wh) do whorl(SX + (5 - i) * 0.3, w[1] + b, w[2], w[3], -0.12, i >= 3) end
      hat(SX - 4.5 + sway, 11 + b, true, false)
    end
  else -- side, facing right
    ell(33, 67.5, 15.5, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    -- far legs (shade), behind everything
    local farx = {34, 40}
    local liftF = {fR, fL}
    for i = 1, 2 do leg(farx[i], 58 + b, farx[i] - 3, 56 + b, farx[i] - 6, 69 + liftF[i], true) end
    -- far eyestalk
    stalk(40, 48 + hd, 41 + sway, 36 + hd, true)
    eye(39 + sway, 33 + hd)
    -- shell, tip up and back (left)
    local wh = {{18.5, 2.6, 1.8, 21}, {22, 5, 3, 22}, {27.5, 8, 4.5, 23.5}, {35.5, 11, 6.5, 25.5}, {46, 13.5, 9.5, 27}}
    for i, w in ipairs(wh) do whorl(w[4], w[1] + b, w[2], w[3], 0.18, i >= 3) end
    -- aperture at the lower right with the crab coming out of it
    ell(36, 52 + b, 5, 7, function(x, y, nx, ny) return (nx < -0.5) and SH.hi or SH.deep end)
    E(40.5, 53 + b, 7, 5.5, CR)
    -- near legs
    local nearx = {33, 38, 43}
    local liftN = {fL, fR, fL}
    for i = 1, 3 do leg(nearx[i], 58 + b, nearx[i] + 2, 55 + b, nearx[i] + 5, 70 + liftN[i], false) end
    -- kerchief at the neck
    for x = 37, 45 do P(x, 57 + b, GR) end
    rows(38, 58 + b, {"gggg", ".gg"}, {g = GR})
    rows(35 - (wi % 2), 58 + b, {"gg", "g."}, {g = GRS})
    -- face
    P(46, 53 + hd, K); P(45, 54 + hd, K)
    P(44, 52 + hd, CR.hi); P(43, 52 + hd, CR.hi)
    P(38, 50 + hd, CREAM)
    -- near eyestalk
    stalk(43, 48 + hd, 45 + sway, 36 + hd, false)
    eye(44 + sway, 33 + hd)
    -- big claw held forward
    line(43, 57 + b, 45, 58 + b + aL, CR.shade)
    rows(42, 51 + b + aL, {
      "..hhbb....",
      ".hbbbbbbh.",
      "hbbbbbbbbs",
      "hbbbbs....",
      "hbbbbbbb..",
      ".bbbbbbbbs",
      "..sssss...",
    }, CM)
    hat(14 + sway, 11 + b, false, true)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, K)
end
return S

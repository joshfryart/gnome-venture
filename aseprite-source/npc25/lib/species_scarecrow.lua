-- scarecrow (biped) tables from specs/scarecrow.md. Sir Barnaby: burlap sack head with a stitched face,
-- big battered felt hat, patched teal coat with a rope belt, straw poking from collar, cuffs and ankles,
-- a small crow perched on his right shoulder (quirk). Stiff-armed walk: arms and legs swing as rods.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local S = {name = "scarecrow", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 6, W = 40}
S.ramps = {
  burlap = {"#ecd3a0", "#d6b47c", "#a9845a", "#7a5a44"},
  coat = {"#6a9aa0", "#4f7a86", "#3a5668", "#2e3e50"},
  hat = {"#8a6a58", "#6e4e44", "#523840", "#3d2a34"},
  straw = {"#f6dc7a", "#e0b046", "#b07c34"},
  crow = {"#6a6080", "#4a4058", "#342c40"},
}
S.palette_list = {"#2b1c26", "#ecd3a0", "#d6b47c", "#a9845a", "#7a5a44", "#6a9aa0", "#4f7a86", "#3a5668", "#2e3e50",
  "#8a6a58", "#6e4e44", "#523840", "#3d2a34", "#f6dc7a", "#e0b046", "#b07c34", "#6a6080", "#4a4058", "#342c40",
  "#c2573c", "#8a3a46", "#e8a098", "#fff4d6", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
S.quirk = {name = "crow on the right shoulder", hex = "#4a4058"}

function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local CREAM, PINK, RUST, RUSTD = H"#fff4d6", H"#e8a098", H"#c2573c", H"#8a3a46"
  local L1, L2 = H"#aaa9b8", H"#74758c"
  local function ramp(t, hl) return {hl = H(hl or t[1]), hi = H(t[1]), base = H(t[2]), shade = H(t[3]), deep = H(t[4] or t[3])} end
  local R = species.ramps
  local BU = ramp(R.burlap)
  local CO = ramp(R.coat)
  local COF = {hl = CO.shade, hi = CO.base, base = CO.shade, shade = CO.deep, deep = CO.deep}
  local HA = ramp(R.hat)
  local TR = {hl = BU.base, hi = BU.base, base = BU.shade, shade = BU.deep, deep = BU.deep} -- trousers
  local TRF = {hl = BU.shade, hi = BU.shade, base = BU.deep, shade = HA.deep, deep = HA.deep}
  local ST = {hi = H(R.straw[1]), base = H(R.straw[2]), shade = H(R.straw[3])}
  local CR = {hl = H(R.crow[1]), hi = H(R.crow[1]), base = H(R.crow[2]), shade = H(R.crow[3]), deep = H(R.crow[3])}
  local b, hd = o.body, o.head
  local G = {}
  local function P(x, y, c)
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    if c and x >= 1 and x <= 62 and y >= 1 and y <= 70 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[math.floor(y + 0.5) * 64 + math.floor(x + 0.5)] end
  local function ell(cx, cy, rx, ry, fn)
    for y = math.floor(cy - ry - 1), math.ceil(cy + ry + 1) do
      for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, fn(x, y, nx, ny)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.5 + ny * 0.86
    if s > 0.93 then return r.deep end
    if s > 0.45 then return r.shade end
    if s < -0.8 then return r.hl end
    if s < -0.3 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r)
    ell(cx, cy, rx, ry, function(x, y, nx, ny) return type(r) == "table" and lit(nx, ny, r) or r end)
  end
  local function ring(cx, cy, rx, ry, c)
    ell(cx, cy, rx + 1, ry + 1, function(x, y) if get(x, y) then return c end end)
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
    for t = 0, n do P(x0 + (x1 - x0) * t / n, y0 + (y1 - y0) * t / n, c) end
  end
  -- rod (stiff limb) from (x0,y0) to (x1,y1), radius r, shaded by the offset from its axis
  local function rod(x0, y0, x1, y1, r, rp, seam)
    local dx, dy = x1 - x0, y1 - y0
    local L2_ = dx * dx + dy * dy
    for y = math.floor(math.min(y0, y1) - r - 1), math.ceil(math.max(y0, y1) + r + 1) do
      for x = math.floor(math.min(x0, x1) - r - 1), math.ceil(math.max(x0, x1) + r + 1) do
        local t = L2_ > 0 and math.max(0, math.min(1, ((x - x0) * dx + (y - y0) * dy) / L2_)) or 0
        local px, py = x - (x0 + dx * t), y - (y0 + dy * t)
        local d = math.sqrt(px * px + py * py)
        if seam then
          if d <= r + 1 and get(x, y) then P(x, y, seam) end
        elseif d <= r then
          P(x, y, type(rp) == "table" and lit(px / r, py / r * 0.6, rp) or rp)
        end
      end
    end
  end
  local function strand(x, y, sx, sy, n, c1, c2)
    for i = 0, n - 1 do P(x + sx * i, y + sy * i, i == n - 1 and (c2 or ST.shade) or (i % 2 == 0 and c1 or ST.base)) end
  end
  -- crow: body centre (bx,by), facing f (+1 right / -1 left); bob tips the head down a px
  local function crow(bx, by, f, bob, tailup)
    line(bx - f * 2.5, by + 0.5, bx - f * 5, by + 2.5 - tailup, CR.shade)
    line(bx - f * 2.5, by + 1.5, bx - f * 4.5, by + 3.5 - tailup, CR.shade)
    ell(bx, by, 3.2, 2.3, function(x, y, nx, ny) return lit(nx * f, ny, CR) end)
    ell(bx - f * 0.6, by + 0.4, 2, 1.2, function(x, y, nx, ny) return ny < -0.5 and CR.hi or CR.shade end)
    local hx, hy = bx + f * 2.6, by - 2.4 + bob
    E(hx, hy, 1.8, 1.7, CR)
    P(hx + f * 0.5, hy - 0.5, CREAM)
    P(hx + f * 2, hy + 0.3, ST.base); P(hx + f * 3, hy + 0.3, ST.shade)
    P(bx - 0.5, by + 2.5, ST.shade); P(bx + 0.5, by + 2.5, ST.shade)
  end
  local swap = frame >= 6 and 1 or 0
  local bob = (frame == 4 or frame == 7) and 1 or 0
  local tailup = (frame == 2 or frame == 5 or frame == 8) and 1 or 0
  local CX = 31.5

  -- ground shadow (as the gnome): keeps row 71 inked on every frame
  ell(31.5, 68, 13, 2.4, function() return L2 end)
  ell(30.5, 67.6, 9.5, 1.4, function() return L1 end)
  local function inkring_feet()
    -- ink contour where boots and trousers stand in the shadow
    local add = {}
    for k, c in pairs(G) do
      if c == L1 or c == L2 then
        for _, n in ipairs({k + 1, k - 1, k + 64, k - 64}) do
          local cn = G[n]
          if cn and cn ~= L1 and cn ~= L2 and cn ~= INK then add[#add + 1] = k; break end
        end
      end
    end
    for _, k in ipairs(add) do G[k] = INK end
  end

  -- battered felt hat: brim ellipse then crown with a dent, band and a patch
  local function hat(cx, by, top, x0, x1, lean, view_)
    ell(cx, by, 14, 2.5, function(x, y, nx, ny)
      if ny > 0.4 then return HA.shade end
      if ny < -0.5 and nx < -0.2 then return HA.hi end
      if nx > 0.75 then return HA.shade end
      return HA.base
    end)
    -- droop on the viewer's left (battered)
    for x = math.floor(cx - 13), math.floor(cx - 9) do P(x, by + 2, HA.shade) end
    P(cx - 13.5, by + 1, HA.shade)
    for yy = 0, 8 do
      local inset = yy == 0 and 2 or (yy == 1 and 1 or 0)
      local sh = yy <= 2 and lean or 0
      for x = x0 + inset + sh, x1 - inset + sh do
        local c = HA.base
        if x <= x0 + 1 + sh then c = HA.hi elseif x >= x1 - 2 + sh then c = HA.shade end
        if yy == 0 and x >= cx - 1 and x <= cx + 1 then c = nil end -- dent in the crown
        if yy == 1 and x >= cx - 1 and x <= cx + 1 then c = HA.shade end
        if yy == 6 then c = x >= x1 - 2 and RUSTD or RUST end
        if yy == 7 then c = x >= x1 - 2 and HA.deep or HA.shade end
        if yy == 8 then c = HA.shade end
        P(x, top + yy, c)
      end
    end
    if view_ == "front" then
      -- mustard patch with stitches on the crown
      for y = top + 2, top + 4 do for x = x0 + 3, x0 + 5 do P(x, y, ST.base) end end
      P(x0 + 3, top + 2, ST.hi); P(x0 + 6, top + 3, ST.shade); P(x0 + 4, top + 5, ST.shade)
    elseif view_ == "back" then
      for y = top + 2, top + 4 do for x = x1 - 6, x1 - 4 do P(x, y, CO.hi) end end
      P(x1 - 3, top + 3, CO.shade); P(x1 - 5, top + 5, CO.shade)
    end
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    -- viewer-left limb uses the figure's right in the front view
    local aVL, aVR, fVL, fVR = o.armR, o.armL, o.footR, o.footL
    if not front then aVL, aVR, fVL, fVR = o.armL, o.armR, o.footL, o.footR end
    -- legs + boots
    local function leg(cx, lift)
      local bot = 70 + lift
      for y = 55 + b, bot - 5 do
        for x = cx - 2, cx + 2 do
          local c = TR.base
          if x == cx - 2 then c = TR.hi elseif x == cx + 2 then c = TR.shade end
          P(x, y, c)
        end
      end
      -- straw at the ankle
      P(cx - 3, bot - 5, ST.hi); P(cx + 3, bot - 5, ST.base); P(cx - 1, bot - 4, ST.base); P(cx + 1, bot - 4, ST.hi)
      for y = bot - 4, bot do
        local w = (y == bot - 4) and 2 or 3
        for x = cx - w, cx + w do
          local c = HA.base
          if y == bot then c = HA.deep elseif x <= cx - 2 and y <= bot - 2 then c = HA.hi elseif x >= cx + 2 then c = HA.shade end
          P(x, y, c)
        end
      end
      if front then P(cx - 1, bot - 3, HA.hi) end
    end
    leg(27, fVL); leg(36, fVR)
    if front then for y = 60, 61 do for x = 26, 27 do P(x, y + (fVL < 0 and fVL or 0), CO.hi) end end end
    if not front then for y = 59, 60 do for x = 37, 38 do P(x, y + (fVR < 0 and fVR or 0), CO.hi) end end end
    inkring_feet()
    -- coat
    for y = 32, 57 do
      local hw = (y == 32 and 7.5) or (y == 33 and 8.5) or (y >= 53 and 10.5) or 9.5
      for x = math.ceil(CX - hw), math.floor(CX + hw) do
        local dx = x - CX
        local c = CO.base
        if dx < -hw + 2 then c = CO.hi elseif dx > hw - 3 then c = CO.shade end
        if y == 57 and x % 3 == 1 then c = nil end
        if y == 57 and c then c = CO.shade end
        if front then
          local vw = (37 - y) * 0.8 + 0.5
          if y <= 37 and math.abs(dx) <= vw then c = ((x + y) % 3 == 0) and ST.shade or (((x * 2 + y) % 5 == 0) and ST.hi or ST.base)
          elseif y <= 38 and math.abs(dx) <= vw + 1 then c = CO.deep end
          if y >= 38 and x == 32 then c = CO.deep end
        else
          if y >= 35 and x == 31 then c = CO.shade end
          if y == 32 then c = CO.hi end
        end
        if c then P(x, y + b, c) end
      end
    end
    -- rope belt with a knot
    for x = 22, 41 do P(x, 49 + b, (x % 2 == 0) and ST.base or ST.shade) end
    if front then
      P(30, 49 + b, ST.hi); P(31, 49 + b, ST.base); P(30, 50 + b, ST.base); P(29, 51 + b, ST.shade); P(31, 51 + b, ST.shade)
      -- odd buttons
      P(30, 41 + b, RUST); P(30, 45 + b, ST.hi)
      -- patches
      for y = 42, 45 do for x = 24, 27 do P(x, y + b, (x == 27 or y == 45) and RUSTD or RUST) end end
      P(24, 42 + b, CREAM); P(26, 41 + b, RUSTD); P(23, 44 + b, RUSTD)
      for y = 52, 55 do for x = 35, 38 do P(x, y + b, (x == 38 or y == 55) and ST.shade or ST.base) end end
      P(35, 52 + b, ST.hi); P(37, 51 + b, ST.shade); P(39, 53 + b, ST.shade)
    else
      for y = 38, 42 do for x = 33, 37 do P(x, y + b, (x == 37 or y == 42) and RUSTD or RUST) end end
      P(33, 38 + b, CREAM); P(35, 37 + b, RUSTD); P(38, 40 + b, RUSTD)
      for y = 51, 54 do for x = 25, 28 do P(x, y + b, (x == 28 or y == 54) and ST.shade or ST.base) end end
      P(25, 51 + b, ST.hi); P(27, 50 + b, ST.shade)
    end
    -- stiff arms, held out and down; straw bursts from the cuffs
    local function arm(side, a)
      local dy = front and -a or a
      local sx, sy = CX + side * 8, 35 + b
      local ex, ey = CX + side * 15, 46 + b + dy
      rod(sx, sy, ex, ey, 2.4, nil, CO.deep)
      rod(sx, sy, ex, ey, 2.4, side < 0 and CO or COF)
      -- cuff band
      ell(ex, ey, 2.6, 1.6, function(x, y, nx, ny) return ny < 0 and CO.deep or (side < 0 and CO.hi or CO.base) end)
      local cx_, cy_ = ex + side * 0.5, ey + 2
      strand(cx_, cy_, 0, 1, 3, ST.hi)
      strand(cx_ - 1.5, cy_, -0.6, 1, 3, ST.base)
      strand(cx_ + 1.5, cy_, 0.6, 1, 2, ST.hi)
      P(cx_ + side * 2.5, cy_ - 1, ST.base)
    end
    arm(-1, aVL); arm(1, aVR)
    -- head: burlap sack
    local hy = 23 + hd
    ring(CX, hy, 8.5, 8.5, BU.deep)
    ell(CX, hy, 8.5, 8.5, function(x, y, nx, ny)
      local c = lit(nx, ny, BU)
      if c == BU.base and (x + 2 * y) % 7 == 0 then c = BU.shade end
      if c == BU.hi and (x + 2 * y) % 7 == 0 then c = BU.base end
      return c
    end)
    -- gathered neck, twine tie, straw collar
    for x = 28, 35 do P(x, 31 + hd, BU.shade) end
    for x = 27, 36 do P(x, 32 + b, x % 2 == 0 and BU.base or BU.shade) end
    for x = 29, 34 do P(x, 31 + b, RUST) end
    P(34, 31 + b, RUSTD)
    for _, s in ipairs({{24, 33, -1, 0.5, 3}, {25, 33, -1, -0.4, 2}, {39, 33, 1, 0.5, 3}, {38, 33, 1, -0.4, 2}, {27, 34, 0, 1, 2}, {36, 34, 0, 1, 2}}) do
      strand(s[1], s[2] + b, s[3], s[4], s[5], ST.hi)
    end
    if front then
      -- stitched face
      P(26, 22 + hd, HA.deep); P(27, 22 + hd, HA.deep); P(26, 23 + hd, HA.deep); P(27, 23 + hd, HA.deep)
      P(26, 22 + hd, CREAM)
      for _, q in ipairs({{35, 21}, {37, 21}, {36, 22}, {35, 23}, {37, 23}}) do P(q[1], q[2] + hd, HA.deep) end
      P(31, 25 + hd, BU.shade); P(32, 25 + hd, BU.deep)
      for x = 29, 34 do P(x, 28 + hd, HA.deep) end
      P(28, 27 + hd, HA.deep); P(35, 27 + hd, HA.deep); P(27, 26 + hd, HA.shade); P(36, 26 + hd, HA.shade)
      for _, x in ipairs({30, 33}) do P(x, 27 + hd, BU.deep); P(x, 29 + hd, BU.deep) end
      P(25, 26 + hd, PINK); P(38, 26 + hd, PINK)
    else
      -- back: stitched seam and the tied gathers
      for y = 17, 29 do if y % 2 == 0 then P(31, y + hd, BU.deep) else P(32, y + hd, BU.shade) end end
      P(33, 32 + b, RUST); P(34, 33 + b, RUST); P(35, 34 + b, RUSTD); P(30, 33 + b, RUST); P(29, 34 + b, RUSTD)
    end
    -- hat (shadow band on the head under the brim)
    for x = 22, 41 do local g = get(x, 20 + hd); if g == BU.base or g == BU.hi then P(x, 20 + hd, BU.shade) end end
    hat(CX, 17 + hd, 7 + hd, 25, 38, front and 1 or -1, view)
    -- crow on the figure's right shoulder
    if front then crow(20.5, 29.5 + b, -1, bob, tailup) else crow(42.5, 29.5 + b, 1, bob, tailup) end
  else
    -- side view, facing right. near limbs = figure's right
    local legN, legF = math.floor(o.armL * 2 + 0.5), math.floor(o.armR * 2 + 0.5)
    local function leg(fx, lift, far)
      local bot = 70 + lift
      local r = far and TRF or TR
      rod(31, 55 + b, fx, bot - 5, 2.2, nil, far and nil or BU.deep)
      rod(31, 55 + b, fx, bot - 5, 2.2, r)
      local bc = far and HA.shade or HA.base
      for y = bot - 4, bot do
        local x0, x1 = fx - 2, fx + 4
        if y == bot - 4 then x0, x1 = fx - 2, fx + 1 elseif y == bot - 3 then x1 = fx + 3 end
        for x = x0, x1 do
          local c = bc
          if y == bot then c = HA.deep elseif not far and y <= bot - 3 and x <= fx then c = HA.hi elseif far then c = HA.shade end
          P(x, y, c)
        end
      end
      P(fx - 3, bot - 5, ST.base); P(fx + 2, bot - 5, far and ST.shade or ST.hi); P(fx + 3, bot - 6, ST.base)
    end
    leg(31 + legF, o.footL, true)
    leg(31 + legN, o.footR, false)
    -- far arm, behind the coat
    local fax = 32 + math.floor(o.armL * 2.5 + 0.5)
    rod(32, 36 + b, fax, 47 + b, 2.2, COF)
    strand(fax, 49 + b, 0, 1, 2, ST.shade)
    -- coat
    for y = 32, 57 do
      local x0, x1 = 25, 38
      if y == 32 then x0, x1 = 27, 36 elseif y == 33 then x0, x1 = 26, 37 elseif y >= 53 then x0, x1 = 24, 39 end
      for x = x0, x1 do
        local c = CO.base
        if x <= x0 + 1 then c = CO.hi elseif x >= x1 - 1 then c = CO.shade end
        if y == 57 and x % 3 == 1 then c = nil end
        if y == 57 and c then c = CO.shade end
        if y <= 36 and x >= 35 then c = ((x + y) % 3 == 0) and ST.shade or ST.base end
        if y == 37 and x >= 35 then c = CO.deep end
        if y >= 37 and y <= 56 and x == 36 then c = CO.deep end
        if c then P(x, y + b, c) end
      end
    end
    for x = 24, 39 do P(x, 49 + b, (x % 2 == 0) and ST.base or ST.shade) end
    P(37, 41 + b, RUST); P(37, 45 + b, ST.hi)
    for y = 39, 42 do for x = 26, 28 do P(x, y + b, (x == 28 or y == 42) and RUSTD or RUST) end end
    P(26, 39 + b, CREAM); P(27, 38 + b, RUSTD)
    for y = 52, 54 do for x = 26, 28 do P(x, y + b, (x == 28 or y == 54) and ST.shade or ST.base) end end
    inkring_feet()
    -- near arm: stiff rod from the shoulder
    local ax = 31 + math.floor(o.armR * 2.5 + 0.5)
    rod(31, 35 + b, ax, 47 + b, 2.4, nil, CO.deep)
    rod(31, 35 + b, ax, 47 + b, 2.4, CO)
    ell(ax, 47 + b, 2.6, 1.6, function(x, y, nx, ny) return ny < 0 and CO.deep or CO.hi end)
    strand(ax, 49 + b, 0, 1, 3, ST.hi)
    strand(ax - 1.5, 49 + b, -0.6, 1, 3, ST.base)
    strand(ax + 1.5, 49 + b, 0.6, 1, 2, ST.hi)
    -- head
    local hy = 23 + hd
    ring(32, hy, 7.5, 8.5, BU.deep)
    ell(32, hy, 7.5, 8.5, function(x, y, nx, ny)
      local c = lit(nx, ny, BU)
      if c == BU.base and (x + 2 * y) % 7 == 0 then c = BU.shade end
      if c == BU.hi and (x + 2 * y) % 7 == 0 then c = BU.base end
      return c
    end)
    -- stitched nose knob
    P(40, 24 + hd, BU.base); P(40, 25 + hd, BU.shade)
    for x = 29, 35 do P(x, 31 + hd, BU.shade) end
    for x = 28, 36 do P(x, 32 + b, x % 2 == 0 and BU.base or BU.shade) end
    for x = 29, 35 do P(x, 31 + b, RUST) end
    P(28, 32 + b, RUST); P(27, 33 + b, RUSTD)
    for _, s in ipairs({{26, 33, -1, 0.5, 3}, {37, 33, 1, 0.4, 3}, {38, 32, 1, -0.3, 2}, {35, 34, 0.3, 1, 2}}) do
      strand(s[1], s[2] + b, s[3], s[4], s[5], ST.hi)
    end
    -- face: button eye, stitched smile, cheek
    P(36, 21 + hd, HA.deep); P(37, 21 + hd, HA.deep); P(36, 22 + hd, HA.deep); P(37, 22 + hd, HA.deep)
    P(36, 21 + hd, CREAM)
    for x = 35, 38 do P(x, 28 + hd, HA.deep) end
    P(34, 27 + hd, HA.deep); P(39, 27 + hd, HA.deep)
    P(36, 27 + hd, HA.shade); P(36, 29 + hd, HA.shade); P(38, 29 + hd, HA.shade)
    P(35, 25 + hd, PINK)
    -- side seam on the back of the sack
    for y = 18, 29 do if y % 2 == 0 then P(26, y + hd, BU.deep) end end
    for x = 23, 41 do local g = get(x, 20 + hd); if g == BU.base or g == BU.hi then P(x, 20 + hd, BU.shade) end end
    hat(31.5, 17 + hd, 7 + hd, 25, 37, 1, "side")
    -- crow on the near (right) shoulder, toward the back
    crow(24.5, 30 + b, 1, bob, tailup)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S

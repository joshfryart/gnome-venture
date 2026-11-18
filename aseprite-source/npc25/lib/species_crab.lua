-- crab tables from specs/crab.md. Own body plan (eight legs, two raised claws); draw_figure by Opus.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local S = {name = "crab", feet_y = 71, outline = "#2b1c26", plan = "crab", T = 14, W = 46}
S.ramps = {
  shell = {"#ff8a5c", "#e8493b", "#b52e3f", "#6e2038"},
  claw = {"#ff8a5c", "#d98322", "#8f4a1f", "#6e2038"},
  cap = {"#6188bc", "#2f6a92", "#3a3e6e"}, band = "#fff4d6",
  flag = {"#f5b82e", "#d98322"}, pole = "#8f4a1f", knob = "#ffe38a",
}
S.palette_list = {"#2b1c26", "#ff8a5c", "#e8493b", "#b52e3f", "#6e2038", "#d98322", "#8f4a1f", "#ffe38a",
  "#fff4d6", "#f5809f", "#6188bc", "#2f6a92", "#3a3e6e", "#f5b82e", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0},
          {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
S.quirk = {item = "pennant flag", hex = "#f5b82e"}

-- Stage 3 (Opus): hand-built pixel art. Light from the upper left.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  -- ---------- paint kit (as frog): parts, contact rims, outline at the end ----------
  local G, ID = {}, {}
  local cur, rims, SHADOW = 0, {}, 1
  local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
  local function part(rim) cur = cur + 1; if rim then rims[#rims + 1] = {cur, rim} end end
  local function P(x, y, c)
    x, y = floor(x + 0.5), floor(y + 0.5)
    if c and x >= 1 and x <= 62 and y >= 1 and y <= 70 then G[y * 64 + x] = c; ID[y * 64 + x] = cur end
  end
  local function lit(nx, ny, R)
    local s = nx * 0.6 + ny * 0.8
    if s < -0.72 and R[1] then return R[1] end
    if s < -0.28 then return R[2] end
    if s > 0.86 then return R[5] or R[4] end
    if s > 0.36 then return R[4] end
    return R[3]
  end
  local function ell(cx, cy, rx, ry, R)
    for y = floor(cy - ry - 1), floor(cy + ry + 1) do
      for x = floor(cx - rx - 1), floor(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then
          local c = R
          if type(R) == "function" then c = R(x, y, nx, ny) elseif type(R) == "table" then c = lit(nx, ny, R) end
          if c then G[y * 64 + x] = nil end
          if x >= 1 and x <= 62 and y >= 1 and y <= 70 and c then G[y * 64 + x] = c; ID[y * 64 + x] = cur end
        end
      end
    end
  end
  local function cap(x0, y0, x1, y1, r0, R, r1)
    r1 = r1 or r0
    local r = max(r0, r1)
    local dx, dy = x1 - x0, y1 - y0
    local L2 = dx * dx + dy * dy
    for y = floor(min(y0, y1) - r - 1), floor(max(y0, y1) + r + 1) do
      for x = floor(min(x0, x1) - r - 1), floor(max(x0, x1) + r + 1) do
        local t = L2 > 0 and ((x - x0) * dx + (y - y0) * dy) / L2 or 0
        t = max(0, min(1, t))
        local ex, ey = x - (x0 + t * dx), y - (y0 + t * dy)
        local d = sqrt(ex * ex + ey * ey)
        local rr = r0 + (r1 - r0) * t
        if d <= rr then
          local c = R
          if type(R) == "table" then c = lit(ex / max(rr, 0.5), ey / max(rr, 0.5), R) elseif type(R) == "function" then c = R(x, y, t) end
          if x >= 1 and x <= 62 and y >= 1 and y <= 70 and c then G[y * 64 + x] = c; ID[y * 64 + x] = cur end
        end
      end
    end
  end
  local function finish()
    for _, rm in ipairs(rims) do
      local pid, col, set = rm[1], rm[2], {}
      for k, id in pairs(ID) do
        if id < pid and id ~= SHADOW then
          if ID[k + 1] == pid or ID[k - 1] == pid or ID[k + 64] == pid or ID[k - 64] == pid then set[#set + 1] = k end
        end
      end
      for _, k in ipairs(set) do G[k] = col end
    end
    for k, id in pairs(ID) do
      if id == SHADOW then
        for _, n in ipairs({k + 1, k - 1, k + 64, k - 64}) do if ID[n] and ID[n] ~= SHADOW then G[k] = INK; break end end
      end
    end
    for y = 0, 79 do for x = 0, 63 do
      local k = y * 64 + x
      if G[k] then img:putPixel(x, y, G[k])
      elseif (G[k + 1] and x < 63) or (G[k - 1] and x > 0) or G[k + 64] or G[k - 64] then img:putPixel(x, y, INK) end
    end end
  end
  -- ---------- palette ----------
  local SHI, SBA, SSH, SDP = H"#ff8a5c", H"#e8493b", H"#b52e3f", H"#6e2038"
  local SHELL = {nil, SHI, SBA, SSH, SDP}
  local SHELLF = {nil, SBA, SSH, SDP, SDP}          -- far legs
  local CHI, CBA, CSH = H"#ff8a5c", H"#d98322", H"#8f4a1f"
  local CLAW = {nil, CHI, CBA, CSH, SDP}
  local CREAM, PINK, KNOB = H"#fff4d6", H"#f5809f", H"#ffe38a"
  local NHI, NBA, NSH = H"#6188bc", H"#2f6a92", H"#3a3e6e"
  local FLAG, FLAGS, POLE = H"#f5b82e", H"#d98322", H"#8f4a1f"
  local L1, L2 = H"#aaa9b8", H"#74758c"
  -- ---------- pose ----------
  local b, hd = o.body, o.head
  local front, back, side = view == "front", view == "back", view == "side"
  local CX = 31.5
  local function X(s, d) return CX + s * d end
  local wi = frame >= 3 and frame - 2 or 0
  local flap = frame >= 3 and (wi % 3) or (frame - 1)   -- pennant tail phase

  part(); ell(31.5, 67.5, 16.5, 3, L2); ell(31, 67, 13.5, 2, L1)   -- shadow, id 1

  -- leg lift: left legs 1,3 with footL, leg 2 with footR; right side opposite
  local function lift(s, i)
    local odd = (i % 2 == 1)
    if s < 0 then return odd and o.footL or o.footR end
    return odd and o.footR or o.footL
  end
  -- side view (moving right): every shin leans toward the travel direction, trailing legs push,
  -- leading legs reach; reach alternates per walk frame (0 on idle so the width stays as front)
  local reach = side and ({0, 0, 1, 1, 0, -1, -1, 0})[frame] or 0
  local function legs(s)
    for i = 3, 1, -1 do
      local l = lift(s, i)
      local fsh, ksh = 0, 0
      if side then
        if s < 0 then fsh, ksh = 3 + reach, 1 else fsh, ksh = reach, 0 end
      end
      local hx, hy = X(s, 11), 56 - i + b
      local kx, ky = X(s, 15 + i * 1.8) + ksh, 58 - i * 4 + b + l * 0.5
      local fx, fy = X(s, 11 + i * 3) + fsh, 70 + l
      local R = ((i == 3) or (side and s < 0)) and SHELLF or SHELL
      part(SDP)
      cap(hx, hy, kx, ky, 1.9, R, 1.3)
      cap(kx, ky, fx, fy - 0.3, 1.3, R, 0.5)
      P(kx - s * 0.5, ky - 1, i == 3 and SBA or SHI)               -- knee glint
    end
  end
  -- one raised claw at side s; flag = holds the pennant; far = shaded, a little lower (side view)
  local function claw(s, flag, far)
    local a = (s < 0) and o.armL or o.armR
    local dip = (a < 0) and 1 or 0
    local open = (a > 0) and 1 or 0
    local cy = 28 + hd + dip + (far and 2 or 0)
    local cx = X(s, 16.5)
    local R = far and {nil, CBA, CBA, CSH, SDP} or CLAW
    local A = far and SHELLF or SHELL
    -- arm: shoulder -> elbow -> wrist
    part(SDP)
    cap(X(s, 12), 49 + b, X(s, 17.5), 42 + b, 2.1, A, 1.9)
    cap(X(s, 17.5), 42 + b, cx + s * 0.5, cy + 6, 1.9, A, 1.7)
    -- palm, then the thick outer finger curving in and the slimmer inner finger
    part(SDP)
    ell(cx, cy + 1, 4.6, 4.8, R)
    local tipc = function(x, y, t) if t > 0.78 then return SDP end; return (far or s > 0) and CBA or CHI end
    cap(cx + s * 2.3, cy - 1, cx + s * (1.2 + open), cy - 8, 2.0, tipc, 0.8)
    cap(cx - s * 2.5, cy - 1, cx - s * (2.4 + open), cy - 7 + dip, 1.5, function(x, y, t)
      if t > 0.75 then return SDP end
      return CBA
    end, 0.7)
    P(cx - s * 1.5, cy, CHI); P(cx - s * 2.5, cy + 1, CHI)          -- palm glint
    P(cx + s * 2, cy + 4, CSH); P(cx + s * 1, cy + 5, CSH)
    if flag then
      local px = floor(cx - s * 0.5 + 0.5)
      part()
      for y = cy - 12, cy + 1 do P(px, y, POLE) end
      P(px, cy - 13, KNOB)
      local dir = side and -1 or -s
      local wavs = {{7, 6, 4, 2}, {6, 6, 5, 2}, {7, 7, 4, 1}}
      local wav = wavs[flap + 1]
      for j = 1, 4 do
        local y = cy - 13 + j
        for k = 1, wav[j] do
          local c = FLAG
          if j == 4 or (k == wav[j] and j > 1) then c = FLAGS end
          if (j == 2 and (k == 2 or k == 3)) or (j == 3 and k == 2) then c = CREAM end   -- tiny shell badge
          local yy = y + ((k >= 5 and flap == 1) and 1 or 0) - ((k >= 6 and flap == 2) and 1 or 0)
          P(px + dir * k, yy, c)
        end
      end
    end
  end

  -- carapace: broad oval, light upper left; front rim in shade with face; back with grooves
  local function carapace(ox, rimshade)
    part(SDP)
    ell(CX + ox, 52 + b, 14.5, 9, function(x, y, nx, ny)
      local yy = y - b
      local c = lit(nx, ny, SHELL)
      if back then
        -- H-shaped grooves of a shore crab's back: two curved grooves and a short cross groove
        local gx = 0.3 + ny * ny * 0.25
        if abs(abs(nx) - gx) < 0.065 and ny > -0.6 and ny < 0.3 and c ~= SDP then c = SSH end
        if (x == 23 and yy == 47) or (x == 26 and yy == 45) or (x == 37 and yy == 46) or (x == 21 and yy == 50) or (x == 41 and yy == 49) then c = SHI end
      else
        if rimshade and ny > 0.5 and c ~= SDP then c = SSH end
        if (x == 22 + ox and yy == 47) or (x == 25 + ox and yy == 45) or (x == 20 + ox and yy == 50) then c = SHI end
      end
      return c
    end)
    -- front-edge teeth: three nicks per side on the upper shoulder of the shell
    for s = -1, 1, 2 do
      for t = 0, 2 do
        local tx, ty = X(s, 11.5 + t * 1.3) + ox, 45 + t * 1.5 + b
        P(tx + s, ty - 1, s < 0 and SHI or SBA)
      end
    end
  end
  local function sailorcap(ox, backv)
    part(NSH)
    ell(CX + ox, 41 + b, 5.3, 3, function(x, y, nx, ny)
      if ny > 0.4 then return CREAM end                            -- band
      return lit(nx, ny, {nil, NHI, NBA, NSH, NSH})
    end)
    ell(CX + ox + (side and 1 or 0), 44.5 + b, 7.5, 1.1, function(x, y, nx, ny) return (ny < 0 and nx < 0.5) and NHI or NBA end)  -- brim
    if backv then
      P(CX + ox - 2, 45 + b, NBA); P(CX + ox - 2.6, 46 + b, NSH)  -- ribbon tails
      P(CX + ox + 2, 45 + b, NBA); P(CX + ox + 2.6, 46 + b, NSH)
    else
      P(CX + ox + (side and 1 or 0), 39 + b, CREAM)                -- badge
    end
  end
  local function eyes(lean, look, backv)
    for s = -1, 1, 2 do
      local ex0 = X(s, 7.5) + lean
      part(SDP)
      cap(X(s, 5) + lean * 0.5, 45 + b, ex0, 37 + hd, 1.2, SHELL)
      part(SDP)
      ell(ex0, 34 + hd, 2.5, 2.5, function(x, y, nx, ny)
        if backv then return lit(nx, ny, SHELL) end
        return CREAM
      end)
      if not backv then
        local ex, ey = floor(ex0 + 0.5) + look, floor(34 + hd + 0.5)
        P(ex, ey, INK); P(ex - 1, ey, INK); P(ex, ey + 1, INK); P(ex - 1, ey + 1, INK)
        P(ex - 1, ey, CREAM)
      end
    end
  end

  if front or back then
    legs(-1); legs(1)
    carapace(0, front)
    if front then
      for x = 28, 35 do P(x, 57 + b, SDP) end
      P(27, 56 + b, SDP); P(36, 56 + b, SDP)
      P(23, 55 + b, PINK); P(24, 55 + b, PINK); P(39, 55 + b, PINK); P(40, 55 + b, PINK)
    end
    sailorcap(0, back)
    eyes(0, 0, back)
    local fs = front and 1 or -1
    claw(-fs, false); claw(fs, true)
  else
    legs(-1)
    legs(1)
    claw(-1, false, true)                                          -- far (trailing) claw
    carapace(1, true)
    for x = 32, 38 do P(x, 57 + b, SDP) end
    P(31, 56 + b, SDP); P(39, 56 + b, SDP)
    P(42, 55 + b, PINK); P(43, 55 + b, PINK); P(26, 55 + b, PINK)
    sailorcap(2, false)
    part(NSH)                                                      -- cap ribbon streams back (motion cue)
    local rw = (frame >= 3) and (wi % 2) or 0
    P(CX - 3, 43 + b, NBA); P(CX - 4, 43 + b + rw, NBA); P(CX - 5, 44 + b, NSH); P(CX - 6, 44 + b - rw, NSH)
    eyes(2, 1, false)
    claw(1, true)                                                  -- leading claw holds the flag
  end
  finish()
end
return S

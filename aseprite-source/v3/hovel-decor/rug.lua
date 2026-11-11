-- Hovel rug layers, 112x24, transparent: a flat lozenge seen at an angle, fringed ends, contact shadow lower right.
-- rush    quirk: one green rush stalk has worked loose and pokes up off the top edge
-- mossrug quirk: three tiny toadstools have sprouted at the right end
-- patch   quirk: a needle with red thread left stuck in one patch
local H = dofile("/home/user/gnome-venture/aseprite-source/v3/hovel-decor/hd.lua")
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local pick = H.pick
local W = 112
local RUSH = {"#4a3424", "#6e5430", "#967a3e", "#b89c50", "#d4bc6a", "#ece090"}
local ROOT = {"#3a2a24", "#5a4030", "#7a5a3c", "#9c7a4e", "#bc9a64", "#d8ba80"}

local function base(c, S, paint, fringe)
  local m = c:poly{ {14, 3}, {98, 3}, {106, 11}, {98, 20}, {14, 20}, {6, 11} }
  local cv, row = {}, {}
  m:each(function(x, y) cv[y * W + x] = true; local r = row[y] or { 99, -1 }; r[1] = min(r[1], x); r[2] = max(r[2], x); row[y] = r end)
  local function has(x, y) return cv[y * W + x] end
  local function dist(x, y)
    for d = 1, 5 do for dy = -d, d do for dx = -d, d do
      if max(abs(dx), abs(dy)) == d and not has(x + dx, y + dy) then return d - 1 end
    end end end
    return 5
  end
  for x = 16, 102 do c:put(x, 21, "#4a2c3c") end                 -- contact shadow on the floor
  for x = 99, 104 do c:put(x, 20 - (x - 99) // 2 + 1, "#4a2c3c") end
  m:each(function(x, y)
    local tl = not has(x, y - 2) or not has(x - 2, y)
    local br = not has(x, y + 2) or not has(x + 2, y)
    local col = paint(x, y, dist(x, y), tl, br)
    if col then c:put(x, y, col) end
  end)
  for y = 5, 17 do                                                  -- fringe off both ends
    local len = (y % 2 == 0) and 4 or 3
    for k = 1, len do
      local cl, cr = fringe(y, k, len)
      c:put(row[y][1] - k, y, cl); c:put(row[y][2] + k, y, cr)
    end
  end
  return m, row
end

---------------------------------------------------------------- rush mat
do
  local c, S = H.new("rug-rush", W, 24)
  base(c, S, function(x, y, d, tl, br)
    if d == 0 then return tl and RUSH[5] or (br and RUSH[1] or RUSH[3]) end
    if d == 1 or d == 2 then                                          -- twisted rush binding
      local tw = (x + (d == 1 and 0 or 1)) % 3
      return (tw == 0) and RUSH[2] or ((tw == 1) and (br and RUSH[3] or RUSH[4]) or (br and RUSH[4] or RUSH[5]))
    end
    if d == 3 then return br and RUSH[2] or RUSH[3] end
    -- basket weave: 6x4 blocks alternate horizontal and vertical strands
    local bx, by = floor((x - 1) / 6), floor((y - 1) / 4)
    local px, py = (x - 1) % 6, (y - 1) % 4
    local hor = (bx + by) % 2 == 0
    if hor then
      if py == 3 then return RUSH[3] end
      if px == 5 then return RUSH[3] end
      return (py == 0) and RUSH[6] or RUSH[5]
    else
      if py == 3 then return RUSH[3] end
      if px % 2 == 1 then return RUSH[4] end
      return (py == 0) and RUSH[5] or RUSH[4]
    end
  end, function(y, k, len)
    local col = (k == len) and RUSH[3] or ((y % 3 == 0) and RUSH[6] or RUSH[5])
    return col, (k == len) and RUSH[2] or RUSH[4]
  end)
  -- the loose stalk: green rush curling up off the top edge
  local st = { {76, 4}, {77, 3}, {78, 2}, {79, 1}, {80, 1}, {81, 0} }
  for i, p in ipairs(st) do c:put(p[1], p[2], (i < 3) and "#7a922e" or "#a4b444") end
  c:put(81, 1, "#557228"); c:put(80, 2, "#557228")
  H.save(c, "hovel-rug-rush")
end

---------------------------------------------------------------- moss rug
do
  local c, S = H.new("rug-moss", W, 24)
  local G, L = S.GREEN, S.LEAF
  base(c, S, function(x, y, d, tl, br)
    if d == 0 then return tl and L[4] or (br and G[1] or G[2]) end
    if d == 1 and br then return G[2] end
    -- moss clumps: 3x2 cushions with a lit top-left pixel and a dark lower edge
    local cx, cy = floor((x + (floor(y / 2) % 2) * 2) / 3), floor(y / 2)
    local h = S.hash(cx, cy, 7)
    local R = (h > .55) and L or G
    local t = 4 + ((h > .8 or h < .2) and 1 or 0)
    local px, py = (x + (floor(y / 2) % 2) * 2) % 3, y % 2
    if py == 1 and px == 2 then t = t - 2 elseif py == 1 then t = t - 1 elseif px == 0 then t = t + 1 end
    if br then t = t - 1 end
    if d == 1 then t = t - 1 end
    -- tiny star flowers
    if S.hash(x, y, 31) > .975 and d >= 2 then return (x % 2 == 0) and S.CREAM[6] or S.PINK[5] end
    return pick(R, t)
  end, function(y, k, len)                                           -- root tendrils instead of a fringe
    local cl = (k == len) and ROOT[2] or ((k == 1) and ROOT[3] or ROOT[4])
    if (y + k) % 3 == 0 then cl = ROOT[5] end
    return cl, (k == len) and ROOT[1] or ROOT[3]
  end)
  -- three toadstools at the right end (caps 4x2 / 3x2, stalks)
  local function stool(x, y, w)
    for i = 0, w - 1 do c:put(x + i, y, (i == 0) and S.BARN[6] or S.BARN[5]); c:put(x + i, y + 1, (i == w - 1) and S.BARN[2] or S.BARN[3]) end
    c:put(x + 1, y, S.CREAM[6])
    local sx = x + floor((w - 1) / 2)
    c:put(sx, y + 2, S.CREAM[5]); c:put(sx, y + 3, S.CREAM[4])
  end
  stool(86, 4, 4); stool(91, 6, 3); stool(83, 8, 3)
  H.save(c, "hovel-rug-mossrug")
end

---------------------------------------------------------------- patchwork
do
  local c, S = H.new("rug-patch", W, 24)
  local PAL = { S.ROSE, S.TEAL, S.GOLD, S.SBLUE, S.BARN, S.LEAF, S.VIOLET, S.CREAM }
  local cols = { 6, 18, 30, 42, 54, 66, 78, 90, 102 }
  local rows = { 3, 9, 14, 21 }
  local function cell(x, y)
    local ci = 1; for i = 1, #cols do if x >= cols[i] then ci = i end end
    local ri = 1; for i = 1, #rows - 1 do if y >= rows[i] then ri = i end end
    return ci, ri, x - cols[ci], y - rows[ri], ((ri < #rows) and rows[ri + 1] or 21) - rows[ri]
  end
  base(c, S, function(x, y, d, tl, br)
    if d <= 1 then                                                  -- madder binding
      if d == 0 then return tl and S.BARN[5] or (br and S.BARN[1] or S.BARN[3]) end
      return br and S.BARN[2] or S.BARN[4]
    end
    local ci, ri, px, py, ph = cell(x, y)
    local k = floor(S.hash(ci, ri, 4) * #PAL) + 1
    if ci == 5 and ri == 2 then k = 2 end
    local R = PAL[k]
    if px == 0 or py == 0 then                                     -- seams, with a cream running stitch on the long ones
      if py == 0 and px % 3 ~= 2 and ri == 2 then return S.CREAM[6] end
      return R[2]
    end
    local t = 4
    if py == 1 or px == 1 then t = 5 end
    if py == ph - 1 or px == 11 then t = 3 end
    local pat = floor(S.hash(ci, ri, 9) * 4)
    if pat == 1 and (px + py) % 4 == 0 and t == 4 then return R[6] end        -- dots
    if pat == 2 and px % 3 == 0 and t == 4 then return R[3] end               -- stripes
    if pat == 3 and (floor(px / 2) + floor(py / 2)) % 2 == 0 and t == 4 then return R[5] end  -- gingham
    if br then t = t - 1 end
    return pick(R, t)
  end, function(y, k, len)
    local cl = (k == len) and S.CREAM[3] or ((y % 4 == 1) and S.ROSE[5] or S.CREAM[5])
    return cl, (k == len) and S.CREAM[2] or S.CREAM[4]
  end)
  -- needle stuck in a patch, red thread trailing off it
  local nd = { {60, 7}, {61, 8}, {62, 9}, {63, 10}, {64, 11} }
  for i, p in ipairs(nd) do c:put(p[1], p[2], (i == 1) and S.IRON[6] or S.IRON[5]) end
  c:put(61, 7, S.IRON[3])
  local th = { {60, 6}, {59, 5}, {58, 5}, {57, 6}, {56, 7}, {55, 7}, {54, 6} }
  for _, p in ipairs(th) do c:put(p[1], p[2], "#d03a3a") end
  H.save(c, "hovel-rug-patch")
end

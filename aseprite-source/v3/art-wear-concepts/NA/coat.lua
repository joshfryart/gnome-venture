-- coat.lua: Maplewold (NA) coat concepts 1-5. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local N = dofile(DIR .. "/common.lua")
local W, HP, X, K, R, G = N.W, N.HP, N.X, N.K, N.R, N.G
local ink, cream = W.ink, W.cream
local only = app.params.only
local floor, max, min = math.floor, math.max, math.min

local function mirror(pts) local o = {} for i, p in ipairs(pts) do o[i] = { 64 - p[1], p[2] } end return o end
-- wool check over an already-lit part
local function check(c, m, idx, size, band)
  m:each(function(x, y)
    local vx, hy = (x % size < band), (y % size < band)
    if vx or hy then c:put(x, y, N.dkcheck[max(1, min(6, idx[K(x, y)] - ((vx and hy) and 2 or 0)))]) end
  end)
end

---------------------------------------------------------------- 1 lumber-check jacket
local function lumber()
  local c = N.canvas("coat-1-lumber-check-jacket")
  local SL = { {19,11}, {10,17}, {5,45}, {13,47}, {18,25} }
  local sl, sr = c:poly(SL), c:poly(mirror(SL))
  local torso = c:poly{ {18,11}, {46,11}, {48,55}, {16,55} }
  local cuffs = c:rect(4, 42, 14, 47):clip(sl):add(c:rect(50, 42, 60, 47):clip(sr))
  for _, s in ipairs({ sl, sr }) do
    local i = N.lay(c, s, N.maple, -1, { R = 3 })
    check(c, s, i, 8, 3)
  end
  c:fillMask(cuffs, N.dkcheck[2]) W.hline(c, 5, 13, 42, N.dkcheck[4]) W.hline(c, 51, 59, 42, N.dkcheck[3])
  W.sep(c, torso, sl:copy():add(sr), ink)
  local ti = N.lay(c, torso, N.maple, 0, { R = 5, hs = 0.7 })
  check(c, torso, ti, 8, 3)
  -- placket + horn buttons
  W.vline(c, 32, 20, 55, N.dkcheck[1]) W.vline(c, 33, 20, 55, N.maple[2])
  for y = 24, 50, 8 do
    local b = c:rect(34, y, 36, y + 2)
    W.lit(c, b, R.wood, { R = 1 }) c:put(34, y, R.wood[6])
  end
  -- hem band
  W.hline(c, 17, 47, 53, N.dkcheck[2]) W.hline(c, 16, 48, 54, N.dkcheck[1])
  -- flap chest pockets
  for _, px in ipairs({ 20, 38 }) do
    local pk = c:rect(px, 25, px + 7, 32)
    N.rim(c, pk, N.dkcheck[1])
    local fl = c:poly{ {px - 1,24}, {px + 8,24}, {px + 8,27}, {px + 3.5,29}, {px - 1,27} }
    local fi = N.lay(c, fl, N.maple, 1, { R = 1 })
    check(c, fl, fi, 8, 3)
    N.bottom(fl, function(x, y) c:put(x, y + 1, N.dkcheck[1]) end)
    c:put(px + 3, 27, R.wood[4])
  end
  -- big collar
  local CL = { {20,9}, {31,12}, {28,23}, {19,15} }
  local col = c:poly(CL):add(c:poly(mirror(CL)))
  local neck = c:poly{ {24,7}, {40,7}, {32,19} }
  c:fillMask(neck, R.felt[2])
  W.hline(c, 25, 39, 8, R.felt[1])
  W.sep(c, col, torso:copy():add(neck), ink)
  local ci = N.lay(c, col, N.dkcheck, 1, { R = 2 })
  W.retone(c, col, ci, N.dkcheck, function(x, y) if (x + y) % 2 == 0 then return -1 end end)
  -- quirk: a curled wood shaving poking out of the left pocket
  local sh = G.tube({ {22,25}, {20,19}, {27,17}, {25,22} }, function() return 1.3 end)
  W.sep(c, sh, torso:copy():add(col), ink)
  N.lay(c, sh, R.lining, 1, { R = 1 })
  c:put(21, 21, R.lining[6]) c:put(24, 21, R.lining[3])
  N.save(c, "coat-1-lumber-check-jacket")
end

---------------------------------------------------------------- 2 goldenrod down vest
local function vest()
  local c = N.canvas("coat-2-goldenrod-down-vest")
  local body = c:poly{ {13,25}, {16,16}, {22,11}, {42,11}, {48,16}, {51,25}, {51,55}, {13,55} }
  -- puffy baffles
  local y0 = 11
  while y0 < 56 do
    local band = body:copy():clip(c:rect(0, y0, 63, y0 + 6))
    N.lay(c, band, N.gold, 0, { R = 2.5, cuts = { .22, .4, .56, .72, .88 } })
    N.bottom(band, function(x, y) if body:has(x, y + 1) then c:put(x, y, N.gold[1]) end end)
    y0 = y0 + 7
  end
  -- armhole binding
  for _, p in ipairs({ {13,25}, {14,22}, {15,19}, {16,16} }) do c:put(p[1] + 1, p[2], N.gold[2]) c:put(64 - p[1] - 1, p[2], N.gold[1]) end
  -- zip
  W.vline(c, 32, 12, 55, N.dkcheck[2]) W.vline(c, 31, 12, 55, N.gold[2])
  -- hem binding
  W.hline(c, 13, 51, 55, N.gold[1])
  -- stand-up collar
  local col = c:rrect(22, 4, 42, 13, 3)
  local inner = c:ellipse(32, 6, 7, 2)
  W.sep(c, col, body, N.gold[1])
  N.lay(c, col, N.gold, 0, { R = 2 })
  c:fillMask(inner, R.felt[2]) W.hline(c, 27, 37, 5, R.felt[1])
  W.vline(c, 32, 8, 13, N.dkcheck[2])
  -- wooden zip pull
  local pull = c:rrect(33, 13, 35, 18, 1)
  W.lit(c, pull, R.wood, { R = 1 }) c:put(33, 13, R.wood[6])
  -- quirk: round patch with a pine tree on the left chest
  local patch = c:ellipse(21, 30, 4.5, 4.5)
  W.sep(c, patch, body, N.gold[1])
  c:fillMask(patch, N.snow[5])
  patch:edge():each(function(x, y) c:put(x, y, N.pine[2]) end)
  W.put(c, { {21,27}, {20,28}, {21,28}, {22,28}, {20,29}, {21,29}, {22,29}, {19,30}, {20,30}, {21,30}, {22,30}, {23,30}, {19,31}, {20,31}, {21,31}, {22,31}, {23,31} }, N.pine[4])
  W.put(c, { {20,28}, {19,30}, {20,29} }, N.pine[5])
  c:put(21, 32, R.wood[3]) c:put(21, 33, R.wood[2])
  -- gloss
  W.put(c, { {18,20}, {19,19}, {20,19} }, N.gold[6]) c:put(19, 19, cream)
  N.save(c, "coat-2-goldenrod-down-vest")
end

---------------------------------------------------------------- 3 prairie duster
local function duster()
  local c = N.canvas("coat-3-prairie-duster")
  local SL = { {21,13}, {12,18}, {7,48}, {15,49}, {19,26} }
  local sl, sr = c:poly(SL), c:poly(mirror(SL))
  local coat = c:poly{ {21,11}, {43,11}, {51,61}, {13,61} }
  coat:cut(c:poly{ {32,56}, {35,62}, {29,62} })
  N.lay(c, sl, N.wheat, -1, { R = 2.5 }) N.lay(c, sr, N.wheat, -1, { R = 2.5 })
  W.sep(c, coat, sl:copy():add(sr), ink)
  local ci = N.lay(c, coat, N.wheat, 0, { R = 6, hs = 0.7 })
  -- long fold lines and the front edge
  for _, fx in ipairs({ { 22, 14 }, { 42, 50 } }) do
    for y = 30, 59 do local x = floor(fx[1] + (fx[2] - fx[1]) * (y - 30) / 30 + 0.5) if coat:has(x, y) then c:put(x, y, N.wheat[2]) end end
  end
  W.vline(c, 32, 26, 57, N.wheat[1]) W.vline(c, 31, 26, 57, N.wheat[5])
  W.hline(c, 14, 50, 60, N.wheat[2])
  for y = 30, 46, 8 do local b = c:rect(34, y, 35, y + 1) c:fillMask(b, R.brass[4]) c:put(34, y, R.brass[6]) end
  -- shoulder cape
  local cape = c:poly{ {20,9}, {44,9}, {53,22}, {48,27}, {16,27}, {11,22} }
  W.sep(c, cape, coat:copy():add(sl):add(sr), ink)
  N.lay(c, cape, N.wheat, 1, { R = 3, cuts = { .2, .36, .52, .7, .86 } })
  N.bottom(cape, function(x, y) c:put(x, y, N.wheat[2]) end)
  W.hline(c, 18, 46, 28, N.wheat[1])
  -- leather collar
  local col = c:poly{ {24,5}, {40,5}, {38,12}, {32,15}, {26,12} }
  W.sep(c, col, cape, ink)
  N.lay(c, col, R.leather, 0, { R = 2 })
  c:fillMask(c:poly{ {28,6}, {36,6}, {32,11} }, R.felt[1])
  -- quirk: wheat stalk tucked in the buttonhole, poking up past the cape
  local stalk = c:line({ {36,31}, {39,24}, {43,14}, {46,8} }, 1)
  W.sep(c, stalk, cape:copy():add(coat):add(col), ink)
  stalk:each(function(x, y) c:put(x, y, R.brass[3]) end)
  for k, p in ipairs({ {46,8}, {47,6}, {48,4}, {49,2} }) do
    c:put(p[1] - 1, p[2], R.brass[5]) c:put(p[1] + 1, p[2] + 1, R.brass[4]) c:put(p[1], p[2], R.brass[4])
  end
  c:put(50, 0, R.brass[6]) c:put(50, 1, R.brass[5])
  W.put(c, { {51,0}, {52,1} }, R.brass[6])
  N.save(c, "coat-3-prairie-duster")
end

---------------------------------------------------------------- 4 lodge cardigan
local function cardigan()
  local c = N.canvas("coat-4-lodge-cardigan")
  local SL = { {18,13}, {9,19}, {5,45}, {14,47}, {17,26} }
  local sl, sr = c:poly(SL), c:poly(mirror(SL))
  local body = c:poly{ {17,11}, {47,11}, {49,55}, {15,55} }
  local gap = c:poly{ {28,13}, {36,13}, {34,55}, {30,55} }
  local knit = function(x, y, i) if x % 3 == 0 then return -1 end end
  for _, s in ipairs({ sl, sr }) do local i = N.lay(c, s, N.knit, -1, { R = 3 }) W.retone(c, s, i, N.knit, knit) end
  for _, s in ipairs({ sl, sr }) do s:copy():clip(c:rect(0, 41, 63, 47)):each(function(x, y) c:put(x, y, (x % 2 == 0) and N.knit[2] or N.knit[3]) end) end
  W.sep(c, body, sl:copy():add(sr), ink)
  local bi = N.lay(c, body, N.knit, 0, { R = 5, hs = 0.7 })
  W.retone(c, body, bi, N.knit, knit)
  -- pine-tree knit band near the hem
  body:each(function(x, y)
    if y >= 42 and y <= 50 then
      local u, v = (x - 15) % 8, y - 42
      local tree = (v >= 1 and v <= 6) and math.abs(u - 4) <= floor((v + 1) / 2)
      if v == 7 and u == 4 then tree = true end
      local i = bi[K(x, y)]
      c:put(x, y, tree and N.pine[max(2, min(5, i))] or N.knit[max(1, i - 2)])
    end
  end)
  W.hline(c, 16, 48, 41, N.knit[2]) W.hline(c, 16, 48, 51, N.knit[2])
  -- rib hem
  body:each(function(x, y) if y >= 52 then c:put(x, y, (x % 2 == 0) and N.knit[2] or N.knit[4]) end end)
  -- open front showing the tunic
  c:fillMask(gap, R.felt[2])
  gap:each(function(x, y) if not gap:has(x - 1, y) then c:put(x, y, R.felt[1]) end end)
  -- shawl collar: thick roll down both front edges
  local CL = { {18,10}, {29,10}, {31,30}, {28,31}, {22,20} }
  local col = c:poly(CL):add(c:poly(mirror(CL)))
  local back = c:rrect(22, 6, 42, 12, 3)
  N.lay(c, back, N.knit, -1, { R = 2 })
  W.sep(c, col, back:copy():add(body):add(gap), ink)
  local ci = N.lay(c, col, N.knit, 1, { R = 2.5 })
  W.retone(c, col, ci, N.knit, function(x, y) if (x + y) % 3 == 0 then return -1 end end)
  -- front bands below the collar
  W.vline(c, 29, 31, 55, N.knit[3]) W.vline(c, 35, 31, 55, N.knit[2])
  -- wooden toggles on the right band
  for y = 34, 46, 6 do
    local t = c:rrect(35, y, 39, y + 2, 1)
    W.lit(c, t, R.wood, { R = 1 }) c:put(35, y, R.wood[6])
    c:put(34, y + 1, R.strap[2])
  end
  -- quirk: a loose yarn end dangling from the hem
  W.put(c, { {44,56}, {45,57}, {45,58}, {44,59}, {44,60}, {45,61} }, N.knit[4])
  c:put(45, 62, N.knit[3])
  -- pop
  c:put(21, 14, N.knit[6])
  N.save(c, "coat-4-lodge-cardigan")
end

---------------------------------------------------------------- 5 frostline parka
local function parka()
  local c = N.canvas("coat-5-frostline-parka")
  local SL = { {20,22}, {11,26}, {6,48}, {14,50}, {18,33} }
  local sl, sr = c:poly(SL), c:poly(mirror(SL))
  local body = c:poly{ {18,20}, {46,20}, {48,56}, {16,56} }
  local hood = c:ellipse(32, 15, 14, 12)
  for _, s in ipairs({ sl, sr }) do
    N.lay(c, s, N.navy, -1, { R = 3 })
    s:each(function(x, y) if y % 6 == 0 and s:has(x, y + 1) then c:put(x, y, N.navy[1]) end end)
  end
  for _, s in ipairs({ sl, sr }) do s:copy():clip(c:rect(0, 45, 63, 50)):each(function(x, y) c:put(x, y, (x % 2 == 0) and N.snow[2] or N.snow[3]) end) end
  W.sep(c, body, sl:copy():add(sr), ink)
  N.lay(c, body, N.navy, 0, { R = 5, hs = 0.7 })
  -- kangaroo pocket
  local pk = c:poly{ {21,38}, {43,38}, {46,50}, {18,50} }
  N.lay(c, pk, N.navy, 1, { R = 2 })
  N.rim(c, pk, N.navy[2])
  W.vline(c, 21, 39, 49, N.navy[1]) W.vline(c, 43, 39, 49, N.navy[1])
  N.top(pk, function(x, y) c:put(x, y, N.navy[5]) end)
  -- hem drawcord channel
  W.hline(c, 17, 47, 53, N.navy[2]) W.hline(c, 16, 48, 56, N.navy[1])
  -- hood with a ruffled snow-white rim around a dark face opening
  W.sep(c, hood, body, ink)
  N.lay(c, hood, N.navy, 0, { R = 4 })
  local face = c:ellipse(32, 17, 7.5, 7)
  local ruff = c:ellipse(32, 17, 10.5, 10):cut(face)
  ruff:each(function(x, y) c:put(x, y, N.snow[4]) end)
  W.lit(c, ruff, N.snow, { R = 2, bias = (function() local b = {} ruff:each(function(x, y) b[K(x, y)] = (X.hash(x, y, 7) < 0.3) and -1 or 0 end) return b end)() })
  c:fillMask(face, N.navy[1])
  face:each(function(x, y) if not face:has(x, y - 1) then c:put(x, y, N.dkcheck[1]) c:put(x, y + 1, N.navy[1]) end end)
  W.put(c, { {28,24}, {29,24}, {32,25}, {35,24}, {36,24} }, N.navy[2])
  -- drawcord + quirk: snowflake toggle
  W.put(c, { {38,57}, {38,58}, {39,59} }, N.snow[3])
  W.put(c, { {26,57}, {26,58}, {25,59} }, N.snow[3])
  local cx, cy = 40, 61
  W.put(c, { {cx,cy-2}, {cx,cy-1}, {cx,cy}, {cx,cy+1}, {cx,cy+2}, {cx-2,cy}, {cx-1,cy}, {cx+1,cy}, {cx+2,cy}, {cx-1,cy-1}, {cx+1,cy+1}, {cx+1,cy-1}, {cx-1,cy+1} }, N.snow[5])
  c:put(cx, cy, N.snow[6]) c:put(cx - 2, cy, N.snow[3]) c:put(cx, cy + 2, N.snow[3])
  W.put(c, { {24,60}, {25,61}, {24,61} }, N.snow[3])
  -- gloss
  W.put(c, { {20,24}, {21,23}, {22,23} }, N.navy[6]) c:put(23, 7, N.navy[6]) c:put(24, 6, N.navy[6])
  N.save(c, "coat-5-frostline-parka")
end

local all = { lumber, vest, duster, cardigan, parka }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end

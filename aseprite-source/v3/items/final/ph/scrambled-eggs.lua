-- scrambled-eggs (Sonnet high, single pass). A slim cast-iron skillet (rim lip, curved wall, thin riveted handle with
-- a hang hole) heaped with soft buttery curds; chive, pepper and unset white wisps; two steam curls.
-- Material: iron 6-tone lip/wall with bevel + streak, per-blob lit curds (6-tone yellow) with contact lines where curds
-- overlap, buttery specular, cool-violet shade, hash-placed chive/pepper/white flecks, sunken dark pan floor, steam tubes.
-- quirk: a shard of eggshell stands upright in the curds like a little sail.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_4.lua")
local HP, X, K, H = G.HP, G.X, G.K, G.H
local floor, abs, max, min, sqrt, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.pi
local c = G.new2("scrambled-eggs")
local IR = { "#1e1c2b", "#2f2e44", "#44465f", "#5d6079", "#7b7e97", "#a9acc2" }
local YEL = { "#7d4616", "#b0721c", "#dca126", "#f5c93c", "#ffe068", "#fff4a8" }
local ST = { "#8ea6c8", "#b7cae0", "#dbe9f4", "#f2f9fd" }
local WH = { "#8c88a8", "#b0acc4", "#d6d2dc", "#f0ece4", "#fffaf0", "#fffbee" }
local PCX, PCY, PRX = 27.5, 38.5, 19
c:groundShadow(29, 52, 22, 2.5)

-- handle (behind pan)
local hm, hn = G.tube({ { 43, 41 }, { 47, 39.5 }, { 50, 37.5 }, { 54, 34.5 } }, function(t) return 1.9 - 0.4 * t end)
G.toneN(c, hm, hn, IR, { amb = .1, wrap = .3 })
local lug = c:ellipse(55.5, 33.5, 2.6, 2.6)
G.toneN(c, lug, X.sphere(55, 33, 2.6, lug), IR, { amb = .1, wrap = .3 })
c:px(55, 33, IR[1]) c:px(56, 33, IR[1])
-- handle seam line under neck
for _, p in ipairs{ { 46, 41 }, { 47, 41 }, { 49, 40 } } do c:px(p[1], p[2], IR[2]) end

-- wall (below rim)
local rimM = c:ellipse(PCX, PCY, PRX, 8.5)
local wallAll = c:ellipse(PCX, PCY + 4, PRX, 8.5)
local wall = wallAll:copy():cut(rimM)
local wn = {}
wall:each(function(x, y)
  local nx = G.clamp((x - PCX) / (PRX + .5), -.97, .97)
  wn[K(x, y)] = { nx, .25, sqrt(1 - nx * nx) }
end)
local wb = {}
wall:each(function(x, y) if not wallAll:copy():shift(0, -1):has(x, y) then wb[K(x, y)] = -1 end end)
G.toneN(c, wall, wn, IR, { amb = .1, wrap = .3, bias = wb })
-- wall streak + rivet
for y = 47, 49 do c:px(13, y, IR[5]) end c:px(13, 46, IR[6])
c:px(41, 47, IR[5]) c:px(41, 48, IR[1])

-- rim lip ring
local inner = c:ellipse(PCX, PCY, PRX - 2.6, 5.9)
local ring = rimM:copy():cut(inner)
ring:each(function(x, y)
  local ex, ey = (x - PCX) / PRX, (y - PCY) / 8.5
  local r = max(sqrt(ex * ex + ey * ey), .001)
  local v = .5 + .5 * (-.6 * ex - .8 * ey) / r
  local i = G.clamp(floor(v * 6) + 1, 1, 6)
  c:px(x, y, IR[i])
end)
-- lip highlight on the top-left
for _, p in ipairs{ { 17, 32 }, { 18, 32 }, { 19, 31 }, { 20, 31 }, { 21, 30 } } do c:px(p[1], p[2], IR[6]) end
-- pan floor
inner:each(function(x, y)
  local ey = (y - PCY) / 5.9
  c:px(x, y, ey < -.45 and IR[2] or IR[1])
end)
for x = 20, 34 do if inner:has(x, 43) then c:px(x, 43, IR[2]) end end

-- curds
local blobs = {
  { 31, 28, 4.8, 3.6, .2 }, { 27, 31.5, 6, 4.4, .15 }, { 35.5, 33, 5.8, 4.4, -.2 }, { 19.5, 35, 5.2, 4, -.3 },
  { 23.5, 39, 6, 4.4, .2 }, { 32.5, 38, 6.4, 4.6, -.1 }, { 14.5, 40, 4.2, 3.4, .3 }, { 40.5, 39, 4.4, 3.5, -.3 },
  { 20.5, 43, 5, 3.4, .1 }, { 28.5, 43.5, 5.6, 3.4, 0 }, { 36.5, 43, 4.8, 3.3, .2 },
}
table.sort(blobs, function(a, b) return a[2] < b[2] end)
local union = HP.mask()
local idxAll = {}
for i, b in ipairs(blobs) do
  local m, n = G.oval(b[1], b[2], b[3], b[4], b[5], 1.1)
  local ring0 = m:grow(1):cut(m)
  local add = HP.mask()
  ring0:each(function(x, y) if H(x, y, 40 + i) > .86 then add:set(x, y) end end)
  m:add(add)
  for _, p in ipairs{ { 1, 0 } } do end
  m:each(function(x, y) if not n[K(x, y)] then
    local nx, ny = (x - b[1]) / (b[3] + .6), (y - b[2]) / (b[4] + .6)
    n[K(x, y)] = { G.norm(nx, ny, .35) } end end)
  G.touch(c, m, union, YEL[2])
  local idx = G.toneN(c, m, n, YEL, { amb = .1, wrap = .3 })
  for k, v in pairs(idx) do idxAll[k] = v end
  local rim = X.rim(n)
  m:edge():each(function(x, y) if rim[K(x, y)] > .85 and y > b[2] then c:px(x, y, "#d49a54") end end)
  if b[3] > 4.5 then
    local sx, sy = floor(b[1] - b[3] * .45), floor(b[2] - b[4] * .5)
    c:px(sx, sy, "#fffbe0") c:px(sx + 1, sy, "#fffbe0") c:px(sx, sy + 1, YEL[6])
  end
  union:add(m)
end
-- flecks (hash placed, only on curds)
union:each(function(x, y)
  local i = idxAll[K(x, y)] or 3
  if H(x, y, 3) > .982 and i >= 3 then
    c:px(x, y, "#4b9650") if union:has(x + 1, y) then c:px(x + 1, y, "#7cc35a") end
  elseif H(x, y, 8) > .978 then c:px(x, y, "#3d2a30")
  elseif H(x, y, 12) > .982 and i >= 3 then
    c:px(x, y, "#fffaf0") if union:has(x + 1, y) then c:px(x + 1, y, "#f4e8c8") end
    if union:has(x, y + 1) then c:px(x, y + 1, "#e0cc98") end
  end
end)
-- eggshell shard (quirk)
local shard = {
  "..h..",
  ".hhb.",
  "hhbbs",
  "hbbsd",
}
local SC = { h = WH[6], b = WH[4], s = WH[3], d = WH[2] }
for yy, row in ipairs(shard) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if SC[ch] then c:px(37 + xx - 1, 25 + yy - 1, SC[ch]) end end end
c:px(38, 29, "#f5b82e") c:px(39, 29, "#d98a22")

-- steam
local function steam(p, w)
  local m, n = G.tube(p, function(t) return w * (1 - t * .45) end)
  G.toneN(c, m, n, ST, { amb = .1, wrap = .3 })
end
steam({ { 30, 24 }, { 24, 19 }, { 35, 14 }, { 29, 7 } }, 1.4)
steam({ { 21, 30 }, { 15, 25 }, { 23, 21 }, { 17, 15 } }, 1.2)
G.save2(c, "scrambled-eggs")

---------------------------------------------------------------- w2: ramps, overlays, props
local ORG = {"#4a2210","#7a3a1a","#b8561e","#e07a2a","#f4a64a","#fcd08a"}
local PNK = {"#4a1a3a","#7a2a5a","#b04880","#d868a0","#f090c0","#fcc4de"}
local YEL = {"#4a3410","#7a5a18","#b08a24","#e0b43a","#f4d060","#fce898"}
local SLT = {"#1e2434","#323c54","#4a5878","#6a7a9c","#8c9cbc","#b4c4dc"}
local PLM = {"#2a1430","#4a2450","#703474","#9a4c94","#bc70b4","#dca0d4"}
local TLW = {"#12303a","#1e4c58","#2e6e78","#44909a","#6cb4b8","#a0d8d4"}
local TAN = {"#5a3a24","#7a5436","#a07848","#c49a60","#e0bc80","#f4dca8"}
local SND = {"#6a5238","#8a6e4a","#a8895e","#c8aa7c","#e0c8a0","#f2e4c4"}
local DKS = {"#1c1c2c","#2e2e44","#44445e","#5e5e7c","#7c7c9a","#a0a0bc"}
local PEACH = {"#8a6050","#b48468","#d4a888","#ecc8a8","#f8e0c4","#fff0dc"}
local SAGEP = {"#6a7c5c","#8a9c7a","#a8bc96","#c4d4b0","#dce8c8","#f0f6e0"}
local OLV = {"#3a4a1e","#586a2c","#7a8c3c","#9aae52","#bccc74","#dce8a0"}
local AUTUMN = {"#5a2210","#8a3a14","#c25a1c","#e08030","#f2a64a","#fccc78"}
local BLOSS = {"#7a3a5a","#b05a80","#d878a0","#f098b8","#f8b8cc","#fcdce6"}
local function q(m, x, y, col) if m:has(x, y) then P(x, y, col) end end
local function qe(m, cx, cy, rx, ry, fn, rim)
  local e = c:ellipse(cx, cy, rx, ry)
  e:each(function(x, y)
    if m == nil or m:has(x, y) then
      local edge = rim and not (e:has(x + 1, y) and e:has(x - 1, y) and e:has(x, y + 1) and e:has(x, y - 1))
      P(x, y, edge and INK or fn(x, y))
    end
  end)
  return e
end
local function shadow(x, y, rx)
  c:ellipse(x, y, rx, 2):each(function(xx, yy) local cur = c:get(xx, yy); if cur then P(xx, yy, mixc(cur, "#2a1830", .3)) end end)
end
local function knob(kx, ky)
  c:fillMask(rect(kx - 2, ky - 2, kx + 2, ky + 2), INK)
  c:fillMask(rect(kx - 1, ky - 1, kx + 1, ky + 1), GOLD[4]); P(kx - 1, ky - 1, GOLD[6]); P(kx + 1, ky + 1, GOLD[2])
  P(kx, ky + 4, INK); P(kx, ky + 5, INK)
end
local function cxy(o) return (o.x0 + o.x1) // 2, (o.y0 + o.y1) // 2 end

-------- door overlays: OV[id](o, mask, args)
local OV = {}
OV.stripes = function(o, m)
  for y = o.y0, o.y1 do local r = (y - o.y0) % 14
    if r >= 7 then for x = o.x0, o.x1 do q(m, x, y, (r == 7) and "#8a5a20" or ((r == 13) and INK or "#4a2c14")) end end end
end
OV.plaid = function(o, m)
  for y = o.y0, o.y1 do for x = o.x0, o.x1 do if m:has(x, y) then
    local vx, hy = (x - o.x0) % 12 < 3, (y - o.y0) % 14 < 3
    local cur = c:get(x, y)
    if vx and hy then P(x, y, mixc(cur, "#7a2230", .7)) elseif vx then P(x, y, mixc(cur, "#e8493b", .6)) elseif hy then P(x, y, mixc(cur, "#3f9150", .6)) end
  end end end
end
local function lattice(o, m, lc, dots, st)
  for y = o.y0, o.y1 do for x = o.x0, o.x1 do if m:has(x, y) then
    local a, b = ((x - o.x0) + (y - o.y0) * .8) % st, ((x - o.x0) - (y - o.y0) * .8) % st
    if a < 1.3 and b < 1.3 then P(x, y, dots[(floor((x - o.x0) / st) + floor((y - o.y0) / st)) % #dots + 1])
    elseif a < 1.3 or b < 1.3 then P(x, y, lc) end
  end end end
end
OV.hex = function(o, m) lattice(o, m, o.wood[1], { o.wood[5], o.wood[6], o.wood[4] }, 14) end
OV.gems = function(o, m) lattice(o, m, o.wood[6], { "#ff5a8a", "#ffd24a", "#7af0e0", "#c8a8ff" }, 12) end
OV.leaf = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local W = o.wood
  for y = o.y0 + 3, o.y1 do q(m, cx, y, W[6]); q(m, cx + 1, y, W[2]) end
  for y = o.y0 + 10, o.y1 - 6, 8 do for k = 1, 9 do
    q(m, cx - k, y + k // 2 * 1 - 4 + k, W[5]); q(m, cx + 1 + k, y + k - 4, W[5]); q(m, cx - k, y + k - 3, W[2]); q(m, cx + 1 + k, y + k - 3, W[2])
  end end
end
OV.sun = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 26
  for k = 0, 11 do local a = k * .5236
    for r = 9, 13 do q(m, floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5), (r < 12) and "#ffd24a" or "#fff2a0") end end
  qe(m, cx, cy, 7, 7, function(x, y) local l = lit(x, y, cx, cy, 7); return l > .3 and "#fff2a0" or (l > -.4 and "#ffd24a" or "#e8a030") end, true)
end
OV.port = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 26
  qe(m, cx, cy, 11, 11, function(x, y) local l = lit(x, y, cx, cy, 11); return GOLD[l > .5 and 6 or (l > 0 and 5 or (l > -.5 and 4 or 3))] end, true)
  qe(m, cx, cy, 8, 8, function(x, y) return (y < cy) and SBLUE[5] or SBLUE[4] end, true)
  for k = 0, 5 do q(m, cx - 5 + k, cy - 2 - k + 2, SBLUE[6]) end
  for x = cx - 8, cx + 8 do q(m, x, cy, GOLD[2]) end
end
OV.window = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local y0 = o.y0 + 14
  for y = y0 - 1, y0 + 19 do for x = cx - 9, cx + 9 do
    local inside = (x >= cx - 7 and x <= cx + 7 and y >= y0 + 1 and y <= y0 + 17)
    local border = not inside
    if border then q(m, x, y, (x == cx - 9 or y == y0 - 1) and INK or TIMB[4]) else q(m, x, y, (y < y0 + 9) and SBLUE[5] or SBLUE[4]) end
  end end
  for y = y0 + 1, y0 + 17 do q(m, cx, y, TIMB[3]) end
  for x = cx - 7, cx + 7 do q(m, x, y0 + 9, TIMB[3]) end
  for k = 0, 4 do q(m, cx - 6 + k, y0 + 7 - k, SBLUE[6]) end
  for x = cx - 10, cx + 10 do q(m, x, y0 + 20, TIMB[2]) end
  for y = y0 + 1, y0 + 6 do q(m, cx - 7, y, "#f090c0"); q(m, cx + 7, y, "#f090c0"); q(m, cx - 6, y, "#fcc4de") end
end
OV.petals = function(o, m, a)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 30; local pc = a and a.pet or "#fff2dc"
  for k = 0, 7 do local an = k * .7854
    qe(m, floor(cx + cos(an) * 10 + .5), floor(cy + sin(an) * 10 + .5), 4, 4, function(x, y) return (x + y < cx + cy + 2) and "#ffffff" or pc end, true) end
  qe(m, cx, cy, 5, 5, function(x, y) return (x + y < cx + cy) and "#ffe38a" or "#e8a030" end, true)
end
OV.lily = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 44
  for k = 1, 3 do local rx = 6 + k * 5
    for t = 0, 6.28, .05 do q(m, floor(cx + cos(t) * rx + .5), floor(cy + 6 + sin(t) * rx * .28 + .5), SBLUE[6]) end end
  qe(m, cx, cy, 13, 6, function(x, y) return (y < cy) and "#5aa84a" or "#3f8c40" end, true)
  for x = cx, cx + 13 do q(m, x, cy, INK) end
  for k = 0, 7 do local an = k * .7854
    qe(m, floor(cx - 2 + cos(an) * 4 + .5), floor(cy - 4 + sin(an) * 3 + .5), 2, 2, function() return "#f8a0c8" end, false) end
  qe(m, cx - 2, cy - 4, 1, 1, function() return "#ffe38a" end, false)
end
OV.spots = function(o, m)
  local cx = (o.x0 + o.x1) // 2
  for _, s in ipairs{ { -11, 14, 3 }, { 9, 22, 2 }, { -4, 33, 3 }, { 11, 40, 3 }, { -12, 50, 2 }, { 3, 56, 2 }, { -1, 8, 2 } } do
    qe(m, cx + s[1], o.y0 + s[2], s[3], s[3], function(x, y) return (x + y > cx + s[1] + o.y0 + s[2] + 1) and "#e8cfa4" or "#fff8e8" end, false) end
end
OV.feather = function(o, m)
  local ax, ay, bx, by = o.x0 + 7, o.y0 + 52, o.x1 - 6, o.y0 + 8
  for t = 0, 1, .015 do
    local x, y = ax + (bx - ax) * t, ay + (by - ay) * t
    local w = sin(t * 3.14) * 6 + 1
    for k = 1, floor(w) do q(m, floor(x + k * .7), floor(y + k * .7), (k % 2 == 0) and "#f4e6c8" or "#fff6e0"); q(m, floor(x - k * .7), floor(y - k * .7), (k % 2 == 0) and "#c8a878" or "#e8d0a0") end
    q(m, floor(x), floor(y), INK)
  end
end
OV.notes = function(o, m)
  local cy = (o.y0 + o.y1) // 2 - 6
  for i = 0, 4 do for x = o.x0 + 2, o.x1 - 2 do q(m, x, cy - 8 + i * 4, o.wood[1]) end end
  for _, n in ipairs{ { 6, 1 }, { 14, 3 }, { 22, 0 }, { 30, 2 }, { 37, 4 } } do
    local x, y = o.x0 + n[1], cy - 8 + n[2] * 2 + 1
    for dx = 0, 3 do q(m, x + dx, y, "#fff2dc"); q(m, x + dx, y + 1, "#fff2dc") end
    q(m, x, y, "#fff2dc"); q(m, x + 3, y + 1, "#c8a878")
    for yy = y - 10, y do q(m, x + 3, yy, "#fff2dc") end
  end
end
OV.knit = function(o, m)
  for y = o.y0 + 2, o.y1, 4 do for x = o.x0 + ((y - o.y0) // 4 % 2) * 2, o.x1, 4 do
    q(m, x, y, o.wood[6]); q(m, x + 1, y + 1, o.wood[5]); q(m, x + 2, y, o.wood[6]); q(m, x + 1, y + 2, o.wood[3]); q(m, x, y + 1, o.wood[3])
  end end
end
OV.pebbles = function(o, m)
  local G = { STONE[3], STONE[4], STONE[5] }
  for i = 1, 18 do
    local px, py = o.x0 + 3 + floor(hash(i, 1, 4) * 38), o.y0 + 6 + floor(hash(i, 2, 4) * 56)
    if not (px > 248 and py > 180) then
      local r = 3 + floor(hash(i, 3, 4) * 2); local g = G[1 + floor(hash(i, 4, 4) * 3)]
      qe(m, px, py, r, r - 1, function(x, y) return (x + y < px + py) and STONE[6] or g end, false)
      c:ellipse(px, py, r, r - 1):each(function(x, y) if m:has(x, y) and not c:ellipse(px, py, r, r - 1):has(x, y + 1) then P(x, y, INK) end end)
    end
  end
end
OV.splat = function(o, m)
  local cols = { "#e8493b", "#3f6cb4", "#ffd24a", "#3fb0a0", "#f090c0", "#fff2dc" }
  for i = 1, 9 do
    local px, py = o.x0 + 4 + floor(hash(i, 5, 4) * 36), o.y0 + 6 + floor(hash(i, 6, 4) * 50)
    local col = cols[i % #cols + 1]
    qe(m, px, py, 3, 2 + i % 2, function(x, y) return col end, true)
    if i % 3 == 0 then for y = py + 3, py + 7 do q(m, px, y, col) end end
  end
end
OV.berries = function(o, m)
  local cx = (o.x0 + o.x1) // 2
  for _, g in ipairs{ { -9, 20 }, { 6, 32 }, { -4, 46 } } do
    for _, d in ipairs{ { 0, 0 }, { 5, 1 }, { 2, 5 }, { -3, 5 }, { 7, 6 }, { 3, 10 } } do
      qe(m, cx + g[1] + d[1], o.y0 + g[2] + d[2], 2, 2, function(x, y) return (x + y < cx + g[1] + d[1] + o.y0 + g[2] + d[2]) and "#8a5ac0" or "#3c2050" end, true) end
    q(m, cx + g[1] + 2, o.y0 + g[2] - 4, "#3f9150"); q(m, cx + g[1] + 3, o.y0 + g[2] - 4, "#3f9150"); q(m, cx + g[1] + 1, o.y0 + g[2] - 3, "#3f9150")
  end
end
OV.gear = function(o, m)
  local cx = (o.x0 + o.x1) // 2; local cy = o.y0 + 28
  for k = 0, 7 do local an = k * .7854; local tx, ty = floor(cx + cos(an) * 12 + .5), floor(cy + sin(an) * 12 + .5)
    for dx = -2, 2 do for dy = -2, 2 do q(m, tx + dx, ty + dy, (abs(dx) == 2 or abs(dy) == 2) and INK or GOLD[4]) end end end
  qe(m, cx, cy, 9, 9, function(x, y) local l = lit(x, y, cx, cy, 9); return GOLD[l > .4 and 6 or (l > -.2 and 5 or 3)] end, true)
  qe(m, cx, cy, 3, 3, function() return "#3a2030" end, true)
end
OV.scales = function(o, m)
  local W = o.wood
  for r = 0, 14 do local sy = o.y0 + 2 + r * 5
    for sx = o.x0 - 3 + (r % 2) * 3, o.x1 + 3, 6 do
      q(m, sx - 2, sy, W[2]); q(m, sx - 2, sy + 1, W[2]); q(m, sx - 1, sy + 2, W[2]); q(m, sx, sy + 2, W[2]); q(m, sx + 1, sy + 2, W[2]); q(m, sx + 2, sy + 1, W[2]); q(m, sx + 2, sy, W[2])
      q(m, sx - 1, sy + 1, W[6]); q(m, sx, sy, W[5])
    end end
end
OV.spiral = function(o, m) spiral((o.x0 + o.x1) // 2, o.y0 + 30, 12) end

---------------------------------------------------------------- props: PR[id](x, y, a, b); (x,y) = ground-centre unless noted
local PR = {}
PR.ladder = function(lx)
  local ax0, ax1 = lx - 8, lx + 8
  local peg = rect(ax0 - 2, 92, ax1 + 2, 95); c:rim(peg, INK); S.obj(peg, TIMB, { base = 4, lit = 1, shade = 1 })
  for y = 96, 202 do
    local xo = floor(sin(y / 26) * 1.4 + .5)
    for _, rx in ipairs{ lx - 7 + xo, lx + 7 + xo } do P(rx - 1, y, INK); P(rx, y, DIRT[5]); P(rx + 1, y, DIRT[2]) end
    if (y - 96) % 10 == 5 then for x = lx - 8 + xo, lx + 8 + xo do P(x, y, INK); P(x, y + 1, (x < lx + xo) and TIMB[5] or TIMB[3]); P(x, y + 2, INK) end end
  end
end
PR.shelf = function(x, y, a)
  for _, f in ipairs{ { x, y, 8 }, { x + 4, y + 12, 6 }, { x - 4, y + 22, 5 } } do
    local fm = c:ellipse(f[1], f[2], f[3], 3):clip(rect(f[1] - f[3] - 1, f[2] - 1, f[1] + f[3] + 1, f[2] + 3))
    c:rim(fm, INK); fm:each(function(xx, yy) P(xx, yy, (yy == f[2] - 1 or yy == f[2]) and "#f2a060" or ((yy >= f[2] + 2) and "#c4622c" or "#e08040")) end)
    P(f[1] - 2, f[2] - 1, "#ffd8a0"); P(f[1] + 2, f[2] + 1, "#ffd8a0")
  end
end
PR.skep = function(x, y)
  shadow(x, y, 12)
  for _, lx in ipairs{ x - 8, x + 7 } do c:fillMask(rect(lx, y - 5, lx + 1, y), INK) end
  local tb = rect(x - 11, y - 7, x + 11, y - 5); c:rim(tb, INK); S.obj(tb, TIMB, { base = 4, lit = 1, shade = 1 })
  local e = c:ellipse(x, y - 17, 9, 10):clip(rect(x - 10, y - 28, x + 10, y - 8)); c:rim(e, INK)
  e:each(function(xx, yy) local band = (yy - y) // 4; local t = (band % 2 == 0) and 5 or 4
    if (yy - y) % 4 == 0 then t = 3 end; if xx < x - 3 then t = t + 1 elseif xx > x + 4 then t = t - 1 end
    P(xx, yy, THATCH[max(1, min(6, t))]) end)
  c:fillMask(rect(x - 2, y - 12, x + 2, y - 9), INK); c:fillMask(rect(x - 1, y - 11, x + 1, y - 10), "#2a1a10")
  P(x, y - 29, INK); P(x - 1, y - 28, THATCH[3]); P(x + 1, y - 28, THATCH[3]); P(x, y - 28, THATCH[5])
  for k = 0, 2 do P(x + 8, y - 8 + k * 2, "#f4c030"); end
end
PR.rod = function(x, y)
  local rm = c:line({ { x, y }, { x + 10, y - 56 } }, 2); c:rim(rm, INK); rm:each(function(xx, yy) P(xx, yy, (xx + yy) % 7 == 0 and TIMB[3] or TIMB[5]) end)
  for yy = y - 55, y - 26 do P(x + 10 + (yy - y + 55) // 14, yy, "#e8e0d0") end
  qe(nil, x + 12, y - 22, 2, 3, function(xx, yy) return (yy < y - 22) and "#e8493b" or "#fff6e0" end, true)
  P(x + 12, y - 18, INK); P(x + 12, y - 17, INK)
  for k = 0, 3 do P(x - 1, y - 14 - k * 8, "#c8a060") end
end
PR.pail = function(x, y)
  shadow(x, y, 9)
  local m = HP.mask(); for yy = y - 14, y do local ins = (yy - (y - 14)) // 7; for xx = x - 7 + ins, x + 7 - ins do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) local t = (xx < x - 3) and 5 or ((xx > x + 3) and 3 or 4); if yy == y - 14 then t = 6 elseif yy >= y - 1 then t = 2 end; P(xx, yy, IRON[t]) end)
  for xx = x - 5, x + 5 do P(xx, y - 14, "#78bccc"); P(xx, y - 13, "#a8dce0") end
  for k = 0, 3 do P(x - 6 + k * 4, y - 8, IRON[2]) end
  local h = c:line({ { x - 7, y - 14 }, { x, y - 24 }, { x + 7, y - 14 } }, 1); c:fillMask(h, INK)
  P(x - 3, y - 11, "#e8f4f8")
end
PR.boots = function(x, y, a)
  local col = a or { "#e0b43a", "#b08a24", "#fce898" }
  for k, bx in ipairs{ x - 6, x + 6 } do
    local m = rect(bx - 3, y - 14, bx + 3, y - 3); m:add(rect(bx - 3 - (k == 1 and 4 or 0), y - 4, bx + 3 + (k == 2 and 4 or 0), y))
    c:rim(m, INK); m:each(function(xx, yy) local t = col[2]; if xx < bx - 1 then t = col[3] elseif yy >= y - 1 then t = INK end; P(xx, yy, t) end)
    for xx = bx - 3, bx + 3 do P(xx, y - 14, col[3]) end
    P(bx - 2, y - 11, "#fff8e0")
  end
end
PR.cattails = function(x, y)
  shadow(x, y, 12)
  for k, d in ipairs{ -8, -3, 2, 7 } do
    local h = 34 + (k * 7) % 14
    for yy = y, y - h, -1 do local xx = x + d + floor((y - yy) * (k % 2 == 0 and .08 or -.08)); P(xx, yy, GREEN[(k % 2) + 3]); if yy % 5 == 0 then P(xx + 1, yy, GREEN[2]) end end
    local hx, hy = x + d + floor(h * (k % 2 == 0 and .08 or -.08)), y - h
    local hm = rect(hx - 1, hy - 10, hx + 1, hy - 2); hm:add(rect(hx, hy - 12, hx, hy - 11)); c:rim(hm, INK)
    hm:each(function(xx, yy) P(xx, yy, (xx == hx - 1) and "#a8704a" or ((xx == hx + 1) and "#5a3420" or "#7a4a2c")) end)
  end
  for k = -1, 1, 2 do for t = 0, 18 do P(x + k * (3 + t // 2), y - t - floor(t * t / 40), GREEN[(t % 2) + 4]) end end
end
PR.barrel = function(x, y)
  shadow(x, y, 14)
  local m = S.rr(x - 11, y - 26, x + 11, y, 3); c:rim(m, INK); S.planks(m, TIMB, { w = 5, base = 4, seed = 3 })
  for _, hy in ipairs{ y - 20, y - 6 } do for xx = x - 11, x + 11 do if m:has(xx, hy) then P(xx, hy, IRON[4]); P(xx, hy + 1, IRON[2]) end end end
  local top = c:ellipse(x, y - 26, 11, 3); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, (xx + yy < x + y - 25) and "#a8dce0" or "#52a0b8") end)
  P(x - 4, y - 27, "#ffffff"); P(x - 3, y - 27, "#e8f4f8")
end
PR.pumpkin = function(x, y)
  shadow(x, y, 16)
  for _, p in ipairs{ { x + 6, y - 6, 8, 6 }, { x - 8, y - 5, 6, 5 } } do
    qe(nil, p[1], p[2], p[3], p[4], function(xx, yy) local l = lit(xx, yy, p[1], p[2], p[3]); local t = (l > .4) and ORG[5] or ((l > -.2) and ORG[4] or ORG[3]); if (xx - p[1]) % 4 == 0 then t = ORG[2] end; return t end, true)
    for yy = p[2] - p[4], p[2] + p[4] do if (yy % 3) ~= 0 then P(p[1], yy, ORG[3]) end end
    P(p[1], p[2] - p[4] - 1, "#5a3c1c"); P(p[1], p[2] - p[4] - 2, "#5a3c1c"); P(p[1] + 1, p[2] - p[4] - 2, "#3f9150")
  end
end
PR.planter = function(x, y)
  shadow(x, y, 14)
  local m = S.rr(x - 13, y - 10, x + 13, y, 2); c:rim(m, INK); S.planks(m, TIMB, { w = 6, base = 3, seed = 5 })
  local soil = rect(x - 12, y - 12, x + 12, y - 9); c:rim(soil, INK); c:fillMask(soil, DIRT[2]); for xx = x - 10, x + 10, 3 do P(xx, y - 11, DIRT[3]) end
  for _, sx in ipairs{ x - 7, x, x + 7 } do
    for yy = y - 12, y - 20, -1 do P(sx, yy, GREEN[4]) end
    qe(nil, sx - 3, y - 21, 3, 2, function() return LEAF[4] end, true); qe(nil, sx + 3, y - 22, 3, 2, function() return LEAF[5] end, true)
  end
end
PR.sproutpot = function(x, y)
  shadow(x, y, 10)
  local m = HP.mask(); for yy = y - 14, y do local ins = (yy - y + 14) // 5; for xx = x - 8 + ins, x + 8 - ins do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) local t = (xx < x - 3) and ORG[5] or ((xx > x + 3) and ORG[3] or ORG[4]); if yy <= y - 12 then t = ORG[5] elseif yy == y - 11 then t = ORG[2] end; P(xx, yy, t) end)
  for yy = y - 15, y - 28, -1 do P(x, yy, GREEN[4]) end
  qe(nil, x - 5, y - 28, 5, 3, function(xx, yy) return (yy < y - 28) and LEAF[5] or LEAF[4] end, true)
  qe(nil, x + 5, y - 31, 5, 3, function(xx, yy) return (yy < y - 31) and LEAF[6] or LEAF[4] end, true)
  P(x - 7, y - 28, LEAF[6])
end
PR.bookstack = function(x, y)
  shadow(x, y, 16)
  local bc = { { "#b0343a", "#ec7a58" }, { "#3f6cb4", "#82b4e4" }, { "#3f8c50", "#86b06a" }, { "#9a4c94", "#dca0d4" } }
  local yy = y
  for i, w in ipairs{ 24, 20, 22, 17 } do
    local bx = x - w // 2 + ((i % 2 == 0) and 1 or -1)
    local m = rect(bx, yy - 6, bx + w, yy); c:rim(m, INK)
    m:each(function(xx, y2) local t = bc[i][1]; if y2 == yy - 6 then t = bc[i][2] end; if xx > bx + w - 3 and y2 > yy - 5 and y2 < yy - 1 then t = "#f8ecd0" end; P(xx, y2, t) end)
    P(bx + 4, yy - 3, "#ffd24a"); P(bx + 5, yy - 3, "#ffd24a")
    yy = yy - 6
  end
  local ink = rect(x - 3, yy - 6, x + 3, yy); c:rim(ink, INK); c:fillMask(ink, "#2f4a8c"); c:fillMask(rect(x - 2, yy - 6, x + 2, yy - 5), "#82b4e4")
  local ql = c:line({ { x + 3, yy - 5 }, { x + 10, yy - 20 } }, 2); c:rim(ql, INK); c:fillMask(ql, "#fff6e0"); P(x + 10, yy - 20, "#e8cfa4")
end
PR.violin = function(x, y)
  local bm = c:ellipse(x, y - 14, 8, 11); c:rim(bm, INK)
  bm:each(function(xx, yy) local l = lit(xx, yy, x, y - 14, 10); P(xx, yy, ORG[l > .3 and 5 or (l > -.3 and 4 or 3)]) end)
  for yy = y - 16, y - 10 do P(x - 8, yy, INK); P(x + 8, yy, INK) end
  P(x - 4, y - 16, INK); P(x - 4, y - 15, INK); P(x - 4, y - 14, INK); P(x + 4, y - 16, INK); P(x + 4, y - 15, INK); P(x + 4, y - 14, INK)
  for yy = y - 25, y - 4 do P(x, yy, "#3a2030") end
  local nk = rect(x - 1, y - 40, x + 1, y - 24); c:rim(nk, INK); c:fillMask(nk, "#5a3420"); c:fillMask(rect(x - 3, y - 45, x + 3, y - 41), INK); c:fillMask(rect(x - 2, y - 44, x + 2, y - 42), ORG[4])
  c:fillMask(rect(x - 4, y - 5, x + 4, y - 4), "#3a2030")
  local bow = c:line({ { x + 13, y }, { x + 18, y - 38 } }, 1); c:fillMask(bow, INK); P(x + 14, y - 8, "#fff6e0"); P(x + 15, y - 20, "#fff6e0")
  shadow(x + 4, y, 12)
end
PR.washline = function(x0, x1, y)
  for _, px in ipairs{ x0, x1 } do local pm = rect(px, y, px + 2, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 }) end
  for x = x0 + 3, x1 - 1 do local sy = y + 2 + floor(sin((x - x0) / (x1 - x0) * 3.1416) * 6); P(x, sy, INK); P(x, sy + 1, "#e8e0d0") end
  for i, cx in ipairs{ x0 + 12, x0 + 28, x0 + 46 } do
    local sy = y + 2 + floor(sin((cx - x0) / (x1 - x0) * 3.1416) * 6) + 2
    local cols = { "#e8493b", "#ffd24a", "#8fc0f0" }; local col = cols[i]
    local m = rect(cx, sy, cx + 6, sy + 9); m:add(rect(cx, sy + 8, cx + 8, sy + 11)); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (xx < cx + 2) and mixc(col, "#ffffff", .3) or col) end)
    for xx = cx, cx + 6 do P(xx, sy + 3, "#fff2dc") end
  end
end
PR.wallclock = function(x, y)
  S.glow(x, y, 14, "#ffd070", .25)
  qe(nil, x, y, 9, 9, function(xx, yy) local l = lit(xx, yy, x, y, 9); return GOLD[l > .5 and 6 or (l > 0 and 5 or 3)] end, true)
  qe(nil, x, y, 6, 6, function() return "#fff6e0" end, true)
  for k = 0, 11 do local a = k * .5236; P(floor(x + cos(a) * 5 + .5), floor(y + sin(a) * 5 + .5), INK) end
  for t = 0, 4 do P(x, y - t, INK) end; for t = 0, 3 do P(x + t, y, "#b0343a") end
  P(x, y, INK)
  for yy = y + 10, y + 15 do P(x, yy, IRON[4]) end; c:fillMask(rect(x - 2, y + 16, x + 2, y + 18), INK); c:fillMask(rect(x - 1, y + 16, x + 1, y + 17), GOLD[4])
end
PR.sundial = function(x, y)
  shadow(x, y, 14)
  local pm = rect(x - 5, y - 18, x + 5, y); c:rim(pm, INK); S.obj(pm, STONE, { base = 4, lit = 1, shade = 1 })
  for xx = x - 6, x + 6 do P(xx, y - 1, INK) end
  local top = c:ellipse(x, y - 21, 13, 4); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, (xx + yy < x + y - 20) and STONE[6] or STONE[5]) end)
  for k = 0, 6 do local a = 3.4 + k * .4; P(floor(x + cos(a) * 10), floor(y - 21 + sin(a) * 2.6), STONE[2]) end
  local g = HP.mask(); for k = 0, 8 do g:set(x + 2 - k // 3, y - 22 - k); end
  c:rim(g, INK); g:each(function(xx, yy) P(xx, yy, GOLD[5]) end)
end
PR.cairn = function(x, y, a)
  shadow(x, y, 14)
  local yy = y
  for i, s in ipairs{ { 0, 12, 7 }, { 1, 9, 6 }, { -1, 7, 5 }, { 0, 4, 4 } } do
    local cy = yy - s[3]
    qe(nil, x + s[1], cy, s[2], s[3], function(xx, y2) local l = lit(xx, y2, x + s[1], cy, s[2]); return STONE[l > .4 and 6 or (l > -.2 and 5 or (l > -.6 and 4 or 3))] end, true)
    if i == 1 then P(x - 5, cy + 1, GREEN[4]); P(x - 4, cy + 2, GREEN[3]); P(x + 6, cy + 2, GREEN[4]) end
    yy = yy - s[3] * 2 + 1
  end
end
PR.birdhouse = function(x, y)   -- (x,y) = top of the rope
  for yy = y, y + 8 do P(x, yy, "#c8a060") end
  local b = rect(x - 7, y + 14, x + 7, y + 27); c:rim(b, INK); S.planks(b, TIMB, { w = 3, base = 5, seed = 2 })
  local r = HP.mask(); for yy = y + 8, y + 14 do local hw = 3 + (yy - y - 8) * 1.2; for xx = floor(x - hw), floor(x + hw) do r:set(xx, yy) end end
  c:rim(r, INK); r:each(function(xx, yy) P(xx, yy, (xx < x) and "#e8493b" or "#b0343a") end)
  qe(nil, x, y + 20, 2, 2, function() return "#2a1a10" end, true)
  c:fillMask(rect(x - 2, y + 25, x + 2, y + 26), "#a07848")
end
PR.bunting = function(x0, y0, x1, y1, cols)
  for x = x0, x1 do local t = (x - x0) / (x1 - x0); local y = floor(y0 + (y1 - y0) * t + sin(t * 3.1416) * 7); P(x, y, INK) end
  local i = 0
  for x = x0 + 5, x1 - 4, 9 do
    i = i + 1; local t = (x - x0) / (x1 - x0); local y = floor(y0 + (y1 - y0) * t + sin(t * 3.1416) * 7)
    local f = HP.mask(); for k = 0, 8 do for xx = x - 3 + k // 3, x + 3 - k // 3 do f:set(xx, y + 1 + k) end end
    c:rim(f, INK); local col = cols[i % #cols + 1]; f:each(function(xx, yy) P(xx, yy, (xx < x) and mixc(col, "#ffffff", .25) or col) end)
  end
end
PR.crate = function(x, y)
  shadow(x, y, 18)
  for _, b in ipairs{ { x - 14, y - 15, x + 4, y }, { x + 6, y - 11, x + 20, y }, { x - 9, y - 29, x + 7, y - 15 } } do
    local m = rect(b[1], b[2], b[3], b[4]); c:rim(m, INK); S.planks(m, TIMB, { w = 4, base = 4, seed = b[1] })
    for xx = b[1], b[3] do P(xx, b[2] + 1, TIMB[6]); P(xx, b[4] - 1, TIMB[2]) end
    for k = 0, 8 do local px = b[1] + 1 + k * (b[3] - b[1] - 2) // 8; local py = b[2] + 1 + k * (b[4] - b[2] - 2) // 8; P(px, py, TIMB[2]) end
  end
end
PR.bigflower = function(x, y, col)
  col = col or "#ffd24a"
  for yy = y, y - 44, -1 do P(x, yy, GREEN[3]); P(x + 1, yy, GREEN[4]) end
  qe(nil, x - 7, y - 16, 6, 2, function() return LEAF[4] end, true); qe(nil, x + 8, y - 26, 6, 2, function() return LEAF[5] end, true)
  for k = 0, 11 do local a = k * .5236; qe(nil, floor(x + cos(a) * 8 + .5), floor(y - 48 + sin(a) * 8 + .5), 2, 2, function(xx, yy) return (xx + yy < x + y - 48) and mixc(col, "#ffffff", .4) or col end, true) end
  qe(nil, x, y - 48, 6, 6, function(xx, yy) local l = lit(xx, yy, x, y - 48, 6); return (l > .2) and "#7a4a2c" or "#4a2c1a" end, true)
  P(x - 2, y - 50, "#a8704a"); P(x + 1, y - 46, "#2a1a10"); P(x - 1, y - 47, "#2a1a10")
end
PR.bush = function(x, y, bc)
  shadow(x, y, 22)
  for _, d in ipairs{ { -12, -9, 11 }, { 12, -9, 11 }, { 0, -14, 13 } } do discPaint(x + d[1], y + d[2], d[3], GREEN) end
  for i = 1, 14 do local bx, by = x - 18 + floor(hash(i, 1, 8) * 36), y - 24 + floor(hash(i, 2, 8) * 20)
    qe(nil, bx, by, 2, 2, function(xx, yy) return (xx + yy < bx + by) and "#8a5ac0" or (bc or "#3c2050") end, true) end
end
PR.pinwheel = function(x, y)
  for yy = y, y - 38, -1 do P(x, yy, INK); P(x + 1, yy, TIMB[4]) end
  local cols = { "#e8493b", "#ffd24a", "#3f9fd0", "#f090c0" }
  for k = 0, 3 do
    local a = k * 1.5708 + .3
    local tm = HP.mask()
    for t = 0, 10 do for w = 0, t // 2 do tm:set(floor(x + cos(a) * t + cos(a + 1.57) * w * .6), floor(y - 40 + sin(a) * t + sin(a + 1.57) * w * .6)) end end
    c:rim(tm, INK); c:fillMask(tm, cols[k + 1]); P(floor(x + cos(a) * 6), floor(y - 40 + sin(a) * 6), "#ffffff")
  end
  c:fillMask(rect(x - 1, y - 41, x + 1, y - 39), "#ffe38a"); P(x, y - 40, INK)
end
PR.easel = function(x, y)
  shadow(x, y, 16)
  for _, l in ipairs{ { x - 14, y, x - 2, y - 60 }, { x + 14, y, x + 2, y - 60 }, { x, y - 6, x, y - 56 } } do
    local m = c:line({ { l[1], l[2] }, { l[3], l[4] } }, 2); c:rim(m, INK); S.obj(m, TIMB, { base = 4, lit = 1, shade = 1 })
  end
  local cv = rect(x - 13, y - 52, x + 13, y - 20); c:rim(cv, INK); c:fillMask(cv, "#f8f0e0")
  for xx = x - 12, x + 12 do P(xx, y - 21, "#d8c8a8") end
  for yy = y - 51, y - 38 do for xx = x - 12, x + 12 do P(xx, yy, (yy < y - 46 + floor(sin(xx / 4) * 1.5)) and "#82b4e4" or "#98c8ec") end end
  for xx = x - 12, x + 12 do local gy = y - 38 + floor(sin(xx / 5) * 2); for yy = gy, y - 22 do P(xx, yy, (yy % 4 == 0) and "#5a9c4a" or "#7ab85a") end end
  for xx = x - 4, x + 1 do P(xx, y - 28, "#ffd24a"); P(xx, y - 29, "#e8493b") end; P(x + 6, y - 44, "#fff6e0"); P(x + 7, y - 44, "#fff6e0")
  local pm = rect(x + 15, y - 8, x + 24, y); c:rim(pm, INK); c:fillMask(pm, "#dcdce8"); c:fillMask(rect(x + 16, y - 8, x + 23, y - 7), "#e8493b"); P(x + 19, y - 8, "#3f6cb4")
  local br = c:line({ { x + 22, y - 9 }, { x + 26, y - 20 } }, 1); c:fillMask(br, INK); P(x + 26, y - 21, "#3f6cb4")
end
PR.crystals = function(x, y)
  shadow(x, y, 16)
  for _, s in ipairs{ { -9, 20, 4, "#c8a8ff" }, { 0, 32, 5, "#7af0e0" }, { 9, 24, 4, "#ff8ab8" }, { -3, 16, 3, "#ffd24a" } } do
    local m = HP.mask(); for yy = 0, s[2] do local hw = (yy < s[2] - 8) and s[3] or max(0, floor(s[3] * (s[2] - yy) / 8)); for xx = x + s[1] - hw, x + s[1] + hw do m:set(xx, y - yy) end end
    c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, (xx < x + s[1]) and mixc(s[4], "#ffffff", .5) or s[4]) end)
    P(x + s[1] - 1, y - s[2] + 8, "#ffffff")
  end
  S.glow(x, y - 16, 20, "#c8a8ff", .25)
end
PR.grapes = function(x, y)   -- (x,y) = top of the vine
  for yy = y - 6, y + 4 do P(x, yy, "#3f8c40") end
  qe(nil, x - 4, y + 1, 4, 2, function() return LEAF[4] end, true); qe(nil, x + 5, y + 2, 3, 2, function() return LEAF[5] end, true)
  for r = 0, 5 do for k = 0, 4 - r // 1 do
    local gx, gy = x - (4 - r) + k * 2 + (r % 2), y + 6 + r * 4
    qe(nil, gx, gy, 2, 2, function(xx, yy) return (xx + yy < gx + gy) and "#8a5ac0" or "#4a2468" end, true)
  end end
end
PR.leafbrella = function(x, y)
  shadow(x, y, 12)
  local st = c:line({ { x, y }, { x + 2, y - 36 } }, 1); c:fillMask(st, INK)
  local lm = HP.mask(); for t = 0, 1, .03 do local lx, ly = x + 2 + cos(3.3 + t * 2.2) * 20 * (0.5 + t), y - 38 + sin(3.3 + t * 2.2) * 9; GX.disc(lm, floor(lx), floor(ly), 3) end
  GX.disc(lm, x - 12, y - 34, 6); GX.disc(lm, x + 14, y - 34, 6); GX.disc(lm, x + 1, y - 40, 7)
  c:rim(lm, INK); lm:each(function(xx, yy) local l = lit(xx, yy, x, y - 36, 16); P(xx, yy, LEAF[l > .3 and 5 or (l > -.3 and 4 or 3)]) end)
  for xx = x - 14, x + 16, 1 do P(xx, y - 35 + floor(abs(xx - x) / 8), LEAF[2]) end
  for k = -2, 2 do for t = 0, 8 do P(x + 1 + k * t // 2, y - 36 - 4 + t // 2 + abs(k) * t // 3, LEAF[6]) end end
end
PR.fruitbowl = function(x, y)
  shadow(x, y, 16)
  local st = c:ellipse(x, y - 5, 11, 5):clip(rect(x - 12, y - 8, x + 12, y)); c:rim(st, INK); S.planks(st, TIMB, { w = 5, base = 4, seed = 7 })
  local bm = c:ellipse(x, y - 14, 11, 7):clip(rect(x - 12, y - 14, x + 12, y - 5)); c:rim(bm, INK); bm:each(function(xx, yy) P(xx, yy, (xx < x - 3) and "#a8e0d0" or ((xx > x + 5) and "#3f8c94" or "#58c4c0")) end)
  for i, f in ipairs{ { -6, "#e8493b" }, { 0, "#ffd24a" }, { 6, "#f08838" }, { -2, "#9a4c94" } } do
    local fx, fy = x + f[1], y - 17 - (i == 4 and 4 or 0)
    qe(nil, fx, fy, 4, 4, function(xx, yy) return (xx + yy < fx + fy) and mixc(f[2], "#ffffff", .35) or f[2] end, true)
    P(fx, fy - 5, "#5a3c1c"); P(fx + 1, fy - 5, "#3f9150")
  end
end
PR.stump = function(x, y)
  shadow(x, y, 16)
  local m = rect(x - 11, y - 13, x + 11, y); m:add(rect(x - 14, y - 4, x + 14, y)); c:rim(m, INK)
  m:each(function(xx, yy) local t = (xx < x - 4) and 5 or ((xx > x + 5) and 3 or 4); if (xx + yy // 2) % 5 == 0 then t = t - 1 end; P(xx, yy, OAK[t]) end)
  local top = c:ellipse(x, y - 13, 11, 4); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, ((abs(xx - x) + abs(yy - y + 13) * 2) % 5 == 0) and OAK[4] or OAK[5]) end)
  P(x, y - 13, OAK[3]); P(x + 1, y - 13, OAK[3])
  for xx = x - 10, x - 6 do P(xx, y - 10, GREEN[4]); P(xx, y - 9, GREEN[3]) end
end
PR.cheese = function(x, y)
  shadow(x, y, 14)
  local m = HP.mask(); for yy = y - 16, y do local hw = floor((yy - y + 16) * 1.2); for xx = x - hw, x + hw do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, (xx < x) and "#ffe070" or "#e8b030") end)
  for xx = x - 19, x + 19 do if m:has(xx, y - 1) then P(xx, y - 1, "#c88a20") end end
  for _, h in ipairs{ { -4, -4 }, { 5, -7 }, { 2, -2 }, { -9, -2 } } do c:fillMask(rect(x + h[1], y + h[2], x + h[1] + 2, y + h[2] + 1), "#b87a18") end
end
PR.scroll = function(x, y)
  for yy = y - 8, y do P(x, yy, "#c8a060") end
  local m = rect(x - 6, y, x + 6, y + 22); c:rim(m, INK); c:fillMask(m, "#f4e6c8")
  for xx = x - 6, x + 6 do P(xx, y + 21, "#c8a878") end
  for _, w in ipairs{ 4, 8, 12, 16 } do for xx = x - 4, x + 3 - (w % 8 == 0 and 2 or 0) do P(xx, y + w, "#7a5a30") end end
  for _, yy in ipairs{ y - 1, y + 23 } do c:fillMask(rect(x - 8, yy, x + 8, yy + 1), INK); c:fillMask(rect(x - 7, yy, x + 7, yy), TIMB[5]) end
  P(x + 4, y + 18, "#e8493b")
end
PR.cane = function(x, y)
  local m = c:line({ { x, y }, { x + 1, y - 40 }, { x + 7, y - 46 }, { x + 11, y - 40 } }, 2); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, ((xx + yy // 3) % 4 == 0) and TIMB[3] or TIMB[5]) end)
  c:fillMask(rect(x - 1, y - 30, x + 2, y - 28), "#c8a060")
  shadow(x, y, 6)
end
PR.mushroomset = function(x, y)
  mushroom(x, y, 4, "#e8493b"); mushroom(x + 14, y + 3, 2, "#e8493b"); mushroom(x - 10, y + 4, 2, "#f5809f")
end
PR.acorn = function(x, y) acorn(x, y) end
PR.herbs = function(x) herbs(x) end
PR.chimes = function(x) chimes(x) end
PR.can = function(x, y) can(x, y) end
PR.staff = function(x) staff(x) end
PR.trellis = function(x) trellis(x) end
PR.trail = function() trail() end

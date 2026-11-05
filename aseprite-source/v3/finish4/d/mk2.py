src=open('/home/user/gnome-venture/aseprite-source/v3/finish2/delve2/batch.lua').read()
def rep(a,b,cnt=1):
    global src
    assert src.count(a)>=1,a[:50]
    src=src.replace(a,b,cnt)
def between(a,b,new):
    global src
    i=src.index(a); j=src.index(b,i)
    src=src[:i]+new+src[j:]

# ---------- helpers inserted before "local S = {}"
helpers='''
local function leafmass(cx, cy, rw, rh, R, seed, ink)
  local m = mk()
  local n = floor(rw * rh / 40) + 5
  for i = 1, n do
    local a = H(i, seed, 1) * 6.283; local rr = sqrt(H(i, seed, 2))
    GX.disc(m, floor(cx + math.cos(a) * rw * rr * .92), floor(cy + math.sin(a) * rh * rr * .92), 5 + floor(H(i, seed, 3) * 7))
  end
  for i = 1, 5 do GX.disc(m, floor(cx - rw * .8 + H(i, seed, 8) * rw * 1.6), floor(cy + rh * .8 + H(i, seed, 9) * 5), 4 + floor(H(i, seed, 4) * 3), 4) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(R), { R = 9, tex = .6, sc = 3.2, seed = seed, amb = .28, rimlight = ink, ink = ink and GX.INK or false,
    fn = function(x, y) return (H(x // 3, y // 2, seed) - .5) * .28 end })
  return m
end
local function crystal(x, y, h, w, R)
  local m = c:poly({ { x - w, y }, { x - w, y - h }, { x - w // 2, y - h - w }, { x + w // 2, y - h - w }, { x + w, y - h }, { x + w, y } })
  c:rim(m, INK)
  m:each(function(xx, yy)
    local u = (xx - (x - w)) / (2 * w)
    local col = u < .28 and R[6] or (u < .6 and R[5] or (u < .85 and R[3] or R[2]))
    if yy < y - h and yy > y - h - w and u > .5 then col = R[4] end
    c:px(xx, yy, col)
  end)
  for yy = y - h - w + 1, y - h do c:px(x - w // 2 + 1, yy, R[6]) end
  c:px(x - w + 1, y - h + 2, "#ffffff")
end
local function cluster(x, y, s, R, seed)
  local specs = { { -9, 0, 20, 4 }, { 0, 2, 30, 5 }, { 9, 0, 16, 4 }, { -3, -2, 12, 3 }, { 14, 3, 10, 3 }, { -15, 3, 9, 3 } }
  for i, p in ipairs(specs) do crystal(x + floor(p[1] * s), y + floor(p[2] * s), floor(p[3] * s), max(2, floor(p[4] * s)), R) end
end
'''
rep('local S = {}',helpers+'\nlocal S = {}')

# ---------- rose windows
between('  -- carved windows','  -- bunting lantern strings','''  -- carved windows (arched, with lintel, sill and a warm lit interior)
  local function cwin(x, y, w, h)
    local m = mk(); for yy = y, y + h do for xx = x, x + w do
      if yy >= y + w // 2 or ((xx - (x + w / 2)) / (w / 2 + .5)) ^ 2 + ((yy - (y + w // 2)) / (w // 2 + .5)) ^ 2 <= 1 then m:set(xx, yy) end end end
    if not ((wl:has(x - 2, y - 2) and wl:has(x + w + 2, y + h + 4)) or (wr:has(x - 2, y - 2) and wr:has(x + w + 2, y + h + 4))) then return end
    local fr = c:rect(x - 2, y - 3, x + w + 2, y + h + 3)
    c:fillMask(c:rect(x - 2, y - 1, x + w + 2, y + h), ROSE.hi); c:rim(c:rect(x - 2, y - 1, x + w + 2, y + h), INK)
    c:fillMask(m, "#5e2c4c")
    m:each(function(xx, yy) local t = (yy - y) / h; c:px(xx, yy, t < .3 and "#7a3a58" or (t < .6 and "#c8784c" or (t < .85 and "#f0b858" or "#f8dc88"))) end)
    c:rim(m, INK)
    c:fillMask(c:rect(x + w // 2, y + 2, x + w // 2, y + h), "#7a3a58")
    c:fillMask(c:rect(x - 3, y + h + 1, x + w + 3, y + h + 2), "#f4b8a0"); c:fillMask(c:rect(x - 3, y + h + 3, x + w + 3, y + h + 3), "#7a3a58")
    c:px(x + 1, y + 3, "#fff0b0")
  end
  for _, w in ipairs{ { 36, 30, 8, 12 }, { 78, 66, 8, 12 }, { 30, 108, 8, 12 }, { 88, 122, 8, 12 }, { 56, 156, 8, 12 }, { 22, 186, 8, 12 }, { 402, 34, 8, 12 }, { 442, 78, 8, 12 }, { 410, 122, 8, 12 }, { 452, 150, 8, 12 }, { 428, 190, 8, 12 }, { 384, 84, 8, 12 } } do cwin(w[1], w[2], w[3], w[4]) end
''')

# ---------- salt: calmer rock + crystals
rep('local nz = vn(x, y, 4, 3) * .5 + vn(x, y, 9, 8) * .5','local nz = vn(x, y, 11, 3) * .35 + vn(x, y, 24, 8) * .65')
rep('local v = .55 - .08 * s + (nz - .5) * .5','local v = .55 - .08 * s + (nz - .5) * .3')
rep('local v = .78 - .07 * s + (nz - .5) * .55','local v = .78 - .07 * s + (nz - .5) * .3')
rep('if H(x, y, 9) > .985 then col = SALT[6] end','if H(x, y, 9) > .997 then col = SALT[6] end')
rep('  -- hanging lantern chandelier','''  local CR = { "#7a6a98", "#a890c0", "#d4c0e0", "#f0e0f0", "#fff6fc", "#ffffff" }
  cluster(34, 150, 1.5, CR, 1); cluster(92, 214, 1.2, CR, 2); cluster(448, 120, 1.4, CR, 3); cluster(420, 186, 1.0, CR, 4); cluster(26, 238, 1.0, CR, 5); cluster(168, 128, .8, CR, 6)
  -- hanging lantern chandelier''')

# ---------- canopy backdrop
between('  GX.bands(c, 0, 269, { "#2e6a5a"','  -- bridge deck in perspective, vanishing (240,126)','''  GX.bands(c, 0, 269, { "#4a9a80", "#6cb88a", "#98d098", "#c4e49c", "#eef4b0" }, 3, .25, function(x, y) return y > 30 and abs(x - 240 - (y - 100) * .3) < 30 end, "#fff8b8")
  local FAR = { hi = "#b8e0a4", base = "#8cc89a", shade = "#6aae90", deep = "#58987e" }
  local MID = { hi = "#8cd08c", base = "#5aaa78", shade = "#3e8a6c", deep = "#2e6e5e" }
  local NEAR = { hi = "#70b870", base = "#3e8a60", shade = "#2c6c58", deep = "#1e4c48" }
  for i = 0, 7 do local x = 30 + i * 64 + (H(i, 1, 3) - .5) * 20; c:fillMask(c:rect(floor(x), 70 + (i % 3) * 8, floor(x) + 4, 200), "#7ab496") end
  for i = 0, 13 do leafmass(floor(-10 + i * 40 + (H(i, 1, 4) - .5) * 20), 96 + floor((H(i, 2, 4) - .5) * 24), 34 + floor(H(i, 3, 4) * 12), 18 + floor(H(i, 4, 4) * 6), FAR, 100 + i, false) end
  mist(100, 160, "#d4ecb0", 6, 1.1)
  for i = 0, 11 do leafmass(floor(i * 46 + (H(i, 1, 5) - .5) * 30), 140 + floor((H(i, 2, 5) - .5) * 26), 38 + floor(H(i, 3, 5) * 14), 22 + floor(H(i, 4, 5) * 8), MID, 200 + i, false) end
  mist(160, 200, "#b8e0a0", 9, .8)
  for i = 0, 8 do leafmass(floor(i * 62 + (H(i, 1, 6) - .5) * 40), 186 + floor((H(i, 2, 6) - .5) * 22), 40 + floor(H(i, 3, 6) * 12), 20 + floor(H(i, 4, 6) * 8), NEAR, 300 + i, false) end
''')
# ---------- wall middle
rep('  c:fillMask(c:rect(0, 150, 479, 269), "#9a6068")\n','')
between('  -- walkway: vanishing point','  -- watch tower at the end','''  -- landscape beyond the parapets: perspective fields, hedges, stream, trees
  local vx, vy = 292, 148
  local FLD = { { "#8cc07a", "#a0cc88" }, { "#d8c070", "#e6d488" }, { "#6ca06a", "#80b476" }, { "#c8a060", "#d8b474" }, { "#a8b86a", "#bccc80" }, { "#c07a5c", "#d08e70" } }
  local hazeC = {}
  for y = vy, 269 do
    local dz = y - vy + 3; local row = floor(log(dz) * 3.6)
    local hz = floor(clamp(1 - dz / 50, 0, 1) * 4) / 4
    for x = 0, 479 do
      local u = (x - vx) / dz * 1.7; local ch = floor(u + 500)
      local f = FLD[1 + floor(H(row, ch, 5) * 6) % 6]
      local col = (((x - vx) / dz * 5 + 1000) % 2 < 1) and f[1] or f[2]
      local rowE = floor(log(dz - 1 > 0 and dz - 1 or 1) * 3.6)
      if row ~= rowE then col = "#3c7050" elseif floor((x - 1 - vx) / dz * 1.7 + 500) ~= ch then col = "#4c8058" end
      if hz > 0 then local k = col .. hz; hazeC[k] = hazeC[k] or mix(col, "#e8eee0", hz * .65); col = hazeC[k] end
      c:px(x, y, col)
    end
    local xr = floor(vx - 250 + 20 * sin(y * .09) - (y - vy) * 1.3); local wr = max(1, floor(dz * .12))
    for x = xr - wr, xr + wr do c:px(x, y, abs(x - xr) >= wr and "#cfeaf0" or ((x + y) % 7 == 0 and "#b8e0ec" or "#6cb8d8")) end
  end
  for i = 0, 70 do
    local y = vy + 8 + floor(H(i, 2, 6) * 112); local x = floor(H(i, 1, 6) * 480); local r = 2 + floor((y - vy) * .05)
    local tm = D(x, y, r, r - 1, i); GX.lit(c, tm, R6{ hi = "#8cd070", base = "#3c8a50", shade = "#2c6648", deep = "#1e4a3c" }, { R = r, ink = false, rimlight = false, tex = .2 })
  end
  for _, hs in ipairs{ { 40, 200, 1.3 }, { 120, 170, .8 }, { 440, 190, 1.1 } } do
    local x, y, s = hs[1], hs[2], hs[3]
    c:fillMask(c:rect(x - floor(7 * s), y - floor(6 * s), x + floor(7 * s), y), "#f4e4c4"); c:rim(c:rect(x - floor(7 * s), y - floor(6 * s), x + floor(7 * s), y), INK)
    c:fillMask(c:poly({ { x - floor(9 * s), y - floor(6 * s) }, { x, y - floor(14 * s) }, { x + floor(9 * s), y - floor(6 * s) } }), "#d0503c"); c:fillMask(c:rect(x - 1, y - floor(3 * s), x + 1, y), "#6a3c2c")
  end
  local ST = R6{ hi = "#eadfca", base = "#c4b2a0", shade = "#907f90", deep = "#5a4c6a" }
  local floorm = c:poly({ { ex_(vy, -1), vy }, { ex_(vy, 1), vy }, { ex_(270, 1), 270 }, { ex_(270, -1), 270 } })
  floorm:each(function(x, y)
    local t = (y - vy) / (270 - vy); local k = (x - vx) / (14 + t * 186)
    local row = log(1 + t * 14) * 5; local rr = row - floor(row)
    local col = floor((k + 1) * 5 + (floor(row) % 2) * .5)
    local v = .62 + t * .06 + (H(floor(row), col, 3) - .5) * .3 + (vn(x, y, 14, 4) - .5) * .12 - abs(k) * .06
    if rr < .09 or (((k + 1) * 5 + (floor(row) % 2) * .5) % 1) < .05 * (1 - t * .5) then v = v - .24 end
    if rr > .09 and rr < .17 and H(floor(row), col, 5) > .4 then v = v + .1 end
    c:px(x, y, pick(ST, v)) end)
  -- parapets: brick faces and merlons, built column by column in perspective
  local BRK = R6{ hi = "#ecb4a8", base = "#c07470", shade = "#8c5470", deep = "#563650" }
  local BRL = R6{ hi = "#d49890", base = "#a46068", shade = "#744a68", deep = "#4a3048" }
  for _, side in ipairs{ -1, 1 } do
    local B = side < 0 and BRL or BRK
    for x = 0, 479 do
      local ax = (x - vx) * side
      if ax >= 14 then
        local t = (ax - 14) / 186; local ye = vy + t * (270 - vy)
        local h = 6 + t * 46; local cp = max(2, floor(t * 5)); local u = log(1 + t * 14) * 5
        local ph = (u / 2) % 1; local mh = h * .5
        local rowh = h / 4
        for y = floor(ye - h), floor(ye) do
          if y >= vy - 12 and y <= 269 then
            local py = ye - y; local r = floor(py / rowh); local bu = u * 1.5 + (r % 2) * .5
            local hv = H(floor(bu), r, 7)
            local v = .62 + (hv - .5) * .3 - (side < 0 and .08 or 0) + (py < 2 and -.15 or 0)
            if py % rowh < 1 or (bu % 1) < .07 then v = .2 end
            c:px(x, y, pick(B, v))
          end
        end
        for y = floor(ye - h - cp), floor(ye - h) - 1 do if y <= 269 then c:px(x, y, y == floor(ye - h - cp) and B[6] or B[5]) end end
        local top = floor(ye - h - cp)
        if ph < .5 then
          for y = floor(top - mh), top - 1 do if y <= 269 then
            local py = top - y; local bu = u * 1.5; local v = .64 + (H(floor(bu), floor(py / 5), 9) - .5) * .25 - (side < 0 and .08 or 0)
            if py % 5 == 0 or (bu % 1) < .07 then v = .22 end
            if y == floor(top - mh) then v = 1.0 end
            c:px(x, y, pick(B, v)) end end
        elseif ph < .6 then
          for y = floor(top - mh), top - 1 do if y <= 269 then c:px(x, y, B[2]) end end
        end
        for y = floor(top - mh - 1), floor(top - mh - 1) do if ph < .5 and y <= 269 then c:px(x, y, INK) end end
      end
    end
  end
''')
rep("  local vx, vy = 292, 148\n  local function ex(y, side)","  local vx, vy = 292, 148\n  local function ex(y, side)") if False else None
open('batch2.lua','w').write(src)

src=open('/home/user/gnome-venture/aseprite-source/v3/finish2/wonder4/batch.lua').read()
def rep(a,b):
    global src
    assert a in src,a[:60]
    src=src.replace(a,b,1)
def between(a,b,new):
    global src
    i=src.index(a); j=src.index(b,i)
    src=src[:i]+new+src[j:]
# ---- stump
between('  body:each(function(x, y)\n    local nx = (x - 240) / 178','  for i = 1, 150 do local x, y = 70','''  body:each(function(x, y)
    local nx = (x - 240) / 178
    local ridge = sin(x * .62 + vn(x, y * .25, 14, 5) * 6 + vn(x, y, 40, 9) * 3)
    local v = .56 - nx * .3 + ridge * .17 + (vn(x * 1.0, y * .1, 1.8, 5) - .5) * .3 + (hash(x // 2, y // 6, 4) < .06 and -.2 or 0)
    if y > 200 then v = v - (y - 200) * .01 end
    local t = GX.idx(v, { .1, .3, .46, .64, .82 })
    if ridge < -.86 and y > 150 then t = 1 end
    if ridge > .9 and y > 150 and v > .45 then t = min(6, t + 1) end
    if y > 150 and hash(x // 5, y // 9, 11) < .05 and ridge < .2 then t = 1 end
    P(x, y, TIMB[t])
  end)
''')
rep("    if abs(nx * .25 + ny) < .03 and dd < .93 and nx > 0 then t = 1 end\n","")
rep("    if dd < .16 then t = 6 elseif dd < .24 then t = 5 end","    if dd < .05 then t = 2 elseif dd < .1 then t = 3 end")
between('  glow(240, 138, 40, "#ffe08a", .55)','  -- quirk: ladybug','')
rep("local ringn = dd * 46","local ringn = dd * 46 + (vn(x, y, 30, 8) - .5) * 1.6")
# ---- volcano
between('  -- the cone','  -- palms and foreground','''  -- the cone: tall, concave flanks
  local TOP = 50
  local hwf = function(y) return 16 + 204 * ((y - TOP) / (216 - TOP)) ^ 1.7 end
  local vm = HP.mask()
  for y = TOP, 216 do local hw = hwf(y); for x = floor(240 - hw), floor(240 + hw) do vm:set(x, y) end end
  vm = GX.rough(vm, 4, 1)
  solid(vm, VR, { R = 30, tex = .5, sc = 6, seed = 7, amb = .25, fn = function(x, y) return ((240 - x) / 250) * .28 + sin(x * .35 + (y * .05)) * .05 end })
  -- ridges down the flanks
  for k = -5, 5 do
    for y = TOP + 14, 214 do
      local hw = hwf(y); local x = floor(240 + k * hw / 5.6 + sin(y * .08 + k) * 3)
      if vm:has(x, y) and (y + k) % 4 < 3 then P(x, y, k < 0 and VR[5] or VR[2]) end
    end
  end
  -- curved terraces: each ring wraps the cone, front edge bows downward
  local crops = { { "#e8493b", "#ff9a8a" }, { "#a078d0", "#d8c0f4" }, { "#f0b020", "#ffe080" }, { "#4aa05a", "#9ce084" }, { "#f5803c", "#ffc080" } }
  local lv = { 110, 123, 136, 149, 162, 175, 188, 201 }
  local function arc(j, x) local y0 = lv[j]; local hw = hwf(y0) - 4; local dx = (x - 240) / hw; if abs(dx) >= 1 then return nil end; return y0 + hw * .17 * sqrt(1 - dx * dx) end
  for j = 1, #lv do
    local col = crops[j % #crops + 1]
    for x = 0, 479 do
      local ya = arc(j, x)
      if ya then
        ya = floor(ya)
        local yb = (j < #lv and arc(j + 1, x)) and floor(arc(j + 1, x)) or ya + 14
        for y = ya + 1, min(yb - 1, ya + 15) do
          if vm:has(x, y) then P(x, y, (y - ya) < 3 and "#8a5c3c" or (((x + y * 2) % 11 == 0) and "#5a3a2a" or ((x // 2 + j) % 7 == 0 and "#8a5c3c" or "#7a4e34"))) end
        end
        if vm:has(x, ya) then P(x, ya, STONE[5]) end
        if vm:has(x, ya - 1) then P(x, ya - 1, STONE[4]) end
        if vm:has(x, ya + 1) then P(x, ya + 1, STONE[2]) end
        if x % 6 == 0 and vm:has(x, ya + 1) then P(x, ya, STONE[3]) end
      end
    end
    for _, off in ipairs{ 6, 11 } do
      for x = floor(240 - hwf(lv[j])) + 6, floor(240 + hwf(lv[j])) - 6, 5 do
        local ya = arc(j, x)
        if ya and vm:has(x, floor(ya) + off) then
          local yy = floor(ya) + off + floor((x // 5 + off) % 2)
          c:fillMask(ell(x, yy, 3, 2), INK); c:fillMask(ell(x, yy, 2, 1), col[1]); P(x - 1, yy - 1, col[2])
        end
      end
    end
  end
  -- crater, lava streams and smoke
  c:fillMask(ell(240, TOP + 2, 22, 6), VR[2]); c:fillMask(ell(240, TOP + 1, 18, 4), "#f5803c"); c:fillMask(ell(240, TOP + 1, 11, 2), "#ffe05a")
  glow(240, TOP - 2, 52, "#ffa040", .5)
  local LAV = { { 232, 56, 10 }, { 262, 56, 8 }, { 250, 58, 9 } }
  local function stream(x0, y0, sway, w0, w1, y1, seed)
    local m = HP.mask()
    for y = y0, y1 do
      local t = (y - y0) / (y1 - y0)
      local x = x0 + sin(y * .09 + seed) * sway * (.4 + t) + (x0 - 240) * t * .9
      local w = floor(w0 + (w1 - w0) * t)
      for xx = floor(x - w), floor(x + w) do if vm:has(xx, y) then m:set(xx, y) end end
    end
    c:rim(m, "#5a1c20"); c:fillMask(m, "#e0502c")
    m:each(function(x, y) if m:has(x + 2, y) and m:has(x - 2, y) then P(x, y, "#f58a34") end if m:has(x + 4, y) and m:has(x - 4, y) and m:has(x, y - 2) and (x + y) % 3 ~= 0 then P(x, y, "#ffd45a") end end)
    for y = y0, y1, 9 do for xx = x0 - 30, x0 + 40 do end end
  end
  stream(236, TOP + 6, 5, 1, 4, 140, 0); stream(250, TOP + 8, 4, 1, 3, 112, 2.2); stream(228, TOP + 10, 6, 1, 3, 90, 4)
  for k, p in ipairs{ { 250, 36, 12 }, { 262, 22, 15 }, { 282, 10, 17 }, { 308, 4, 17 }, { 338, 2, 16 } } do
    local sm = ell(p[1], p[2], p[3], p[3] - 2); c:rim(sm, "#5a4a60"); c:fillMask(sm, mixc("#e8c8c0", "#6a5a78", k / 6)); P(p[1] - 3, p[2] - 3, "#f8e4dc"); P(p[1] - 4, p[2] - 2, "#f8e4dc")
  end
  for i = 1, 22 do local x, y = 240 + floor((hash(i, 1, 4) - .3) * 60), TOP - 4 - floor(hash(i, 2, 4) * 36); P(x, y, "#ffa040"); if i % 3 == 0 then P(x + 1, y, "#ffe05a") end end
''')
i=src.index('local ALL = {'); src=src[:i]+'''local ALL = { "wonder-thousand-rings-stump", "wonder-volcano-spice-gardens" }
if NAME == "all" then for _, n in ipairs(ALL) do build(n) end else build(NAME) end
'''
open('batch4.lua','w').write(src)

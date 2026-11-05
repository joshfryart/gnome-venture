---------------------------------------------------------------- finish4 gather art
local function cir(cx, cy, r) return HP.ellipse(cx, cy, r, r) end
local function lerp(a, b, t) return a + (b - a) * t end
-- shaded wood handle with leather grip bands
local function handle(p0, p1, wd)
  obj(ln({ p0, p1 }, wd), R.wood)
  local n = 5
  for i = 0, 3 do
    local t = .1 + i * .06
    local x, y = lerp(p0[1], p1[1], t), lerp(p0[2], p1[2], t)
    c:fillMask(ln({ { x - 1, y + 1 }, { x + 1, y - 1 } }, 1), R.leather.base)
  end
end

function S.forage()
  slotBase()
  -- knife: curved blade, gold bolster, wooden handle with rivets
  obj(ln({ {10, 42}, {19, 30} }, 6), R.wood)
  c:fillMask(HP.rect(14, 36, 14, 36), R.gold.hi); c:fillMask(HP.rect(12, 39, 12, 39), R.gold.hi)
  obj(HP.poly({ {16, 29}, {24, 26}, {26, 31}, {20, 35} }), R.gold)
  local blade = HP.poly({ {22, 27}, {26, 14}, {32, 6}, {40, 4}, {41, 12}, {37, 21}, {30, 30}, {26, 32} })
  obj(blade, R.iron)
  c:fillMask(ln({ {28, 24}, {33, 14}, {38, 8} }, 1), CREAM)      -- lit edge
  c:fillMask(ln({ {35, 24}, {39, 15} }, 1), R.iron.deep)        -- spine shade
  put(41, 5, CREAM)
  -- toadstool
  obj(HP.rect(31, 33, 36, 42), { hi = CREAM, base = "#f0dcb4", shade = "#c9b08a", deep = R.wood.deep })
  local cap = clipy(HP.ellipse(34, 34, 10, 8), 0, 34)
  obj(cap, R.ember)
  c:fillMask(HP.rect(25, 34, 43, 34), R.ember.deep)
  for _, p in ipairs({ {30, 29, 2}, {36, 27, 2}, {40, 31, 1}, {33, 32, 1} }) do c:fillMask(cir(p[1], p[2], p[3]), CREAM) end
  -- leaf + berry quirk
  obj(leafm(5, 14, -.5, 9, 3), R.moss)
  obj(cir(9, 18, 2), R.petal); put(8, 17, CREAM)
end

-- fish drawn in a local frame rotated by ang about (cx,cy); body length ~L
local function fish(cx, cy, ang, L)
  local function T(pts) local o = {} for i, p in ipairs(pts) do o[i] = { cx + (p[1] * cos(ang) - p[2] * sin(ang)) * L / 24, cy + (p[1] * sin(ang) + p[2] * cos(ang)) * L / 24 } end return o end
  local FR = { hi = "#ffd7a0", base = "#f48c4c", shade = "#c85a3c", deep = "#6e2038" }
  local FIN = { hi = "#ffb070", base = "#e0603c", shade = "#a8383c", deep = "#6e2038" }
  obj(HP.poly(T({ {-12, 0}, {-22, -8}, {-19, 0}, {-22, 8} })), FIN)                                -- tail
  obj(HP.poly(T({ {-2, -6}, {-6, -13}, {4, -8} })), FIN)                                            -- dorsal
  obj(HP.poly(T({ {14, 0}, {8, -6}, {-2, -7}, {-10, -3}, {-12, 0}, {-10, 3}, {-2, 6}, {8, 6} })), FR)  -- body
  local bel = HP.poly(T({ {12, 2}, {4, 5}, {-6, 4}, {-9, 1}, {4, 2} }))
  c:fillMask(bel, "#fff0cc")
  local px_, py_ = cx + (7 * cos(ang) + 1 * sin(ang)) * L / 24, cy + (7 * sin(ang) - 1 * cos(ang)) * L / 24
  put(floor(px_ + .5), floor(py_ + .5), INK); put(floor(px_ + .5) - 1, floor(py_ + .5) - 1, CREAM)
  for k = 0, 2 do local a = T({ {-1 - k * 3, -3} })[1]; put(floor(a[1] + .5), floor(a[2] + .5), FR.deep) end
  local g = T({ {4, 0}, {4, 3} })
  c:fillMask(ln({ { floor(g[1][1] + .5), floor(g[1][2] + .5) }, { floor(g[2][1] + .5), floor(g[2][2] + .5) } }, 1), FR.shade)
  obj(HP.poly(T({ {2, 4}, {-4, 9}, {-4, 4} })), FIN)                                                -- pectoral
end

function S.vigrod()
  sky({ "#f0a884", "#f8c896", "#fde4b0" }, { 18, 36 })
  c:fillMask(HP.ellipse(112, 30, 13, 13), R.gold.shade); c:fillMask(HP.ellipse(112, 30, 11, 11), R.gold.base); c:fillMask(HP.ellipse(110, 28, 7, 7), R.gold.hi)
  cloud(30, 14, 26)
  hill(46, 4, .05, 2, "#7aa88a", 64)
  hill(54, 3, .08, 1, "#4f8a6e", 66)
  for y = 62, 106 do for x = 0, 143 do
    local t = (y < 78) and R.sea.shade or R.sea.base
    if y % 6 == 0 and hs(x, y, 6) > .55 then t = (y < 78) and R.sea.base or R.sea.hi end
    if y > 96 and hs(x, y, 7) > .8 then t = R.sea.shade end
    put(x, y, t)
  end end
  for y = 64, 80, 2 do for x = 98, 128 do if hs(x, y, 3) > .55 then put(x, y, R.gold.hi) end end end   -- sun glints
  for _, p in ipairs({ {70, 98}, {96, 90}, {124, 100} }) do c:fillMask(ln({ {p[1], p[2]}, {p[1] + 8, p[2]} }, 1), R.sea.hi) end
  -- clean rounded bank
  local bank = HP.ellipse(-4, 98, 50, 28):add(HP.rect(0, 96, 40, 107))
  bank:clip(HP.rect(0, 62, 143, 107))
  c:rim(bank, INK)
  bank:each(function(x, y)
    local t = R.moss.base
    if hs(x, y, 5) > .93 then t = R.moss.hi elseif hs(x, y, 6) < .05 then t = R.moss.shade end
    put(x, y, t)
  end)
  bank:each(function(x, y) if not bank:has(x + 1, y + 1) then put(x, y, R.moss.shade) end if not bank:has(x, y + 1) or not bank:has(x + 1, y) then put(x, y, R.moss.deep) elseif not bank:has(x - 1, y - 1) then put(x, y, R.moss.hi) end end)
  bank:each(function(x, y) if not bank:has(x + 2, y + 2) and bank:has(x, y) and not bank:has(x + 1, y + 1) == false then put(x, y, R.moss.shade) end end)
  for _, p in ipairs({ {12, 80}, {30, 92}, {8, 100}, {26, 102} }) do put(p[1], p[2], R.moss.hi); put(p[1] + 1, p[2], R.moss.hi); put(p[1], p[2] - 1, R.moss.hi) end
  -- reeds at the shore
  for i, x in ipairs({ 44, 48, 52 }) do
    local top = 64 - i * 3
    c:fillMask(ln({ {x, 86}, {x + (i - 2) * 2, top} }, 1), R.moss.deep)
    obj(HP.rect(x + (i - 2) * 2 - 1, top - 3, x + (i - 2) * 2, top + 3), R.wood)
  end
  -- forked rest + rod
  obj(ln({ {20, 96}, {26, 76} }, 3), R.dirt); obj(ln({ {32, 96}, {26, 76} }, 3), R.dirt)
  obj(ln({ {10, 104}, {70, 20} }, 3), R.wood)
  obj(ln({ {12, 100}, {18, 92} }, 4), R.ember)
  obj(HP.ellipse(23, 83, 3, 3), R.iron); put(22, 82, CREAM)
  -- line: dark under-line + cream line, sagging from tip to bobber
  local tipx, tipy, bx, by = 70, 20, 96, 74
  local prev
  for i = 0, 60 do
    local t = i / 60
    local x = tipx + (bx - tipx) * t
    local y = tipy + (by - tipy) * t + 10 * sin(t * pi) * (1 - t * .3)
    x, y = floor(x + .5), floor(y + .5)
    put(x + 1, y + 1, "#7a4a52"); put(x, y, CREAM)
    prev = { x, y }
  end
  -- bobber + ripples
  obj(HP.ellipse(96, 75, 3, 3), R.ember); c:fillMask(HP.rect(94, 75, 98, 76), CREAM); put(95, 73, CREAM)
  for _, e in ipairs({ {96, 80, 8, 2}, {96, 82, 15, 3} }) do ring(e[1], e[2], e[3], e[4], 1):each(function(x, y) if (x + y) % 2 == 0 then put(x, y, R.sea.hi) end end) end
  -- whole jumping fish inside the frame
  fish(118, 46, -.75, 26)
  for _, p in ipairs({ {106, 62, 1}, {112, 66, 1}, {128, 64, 1}, {124, 58, 1}, {101, 52, 1} }) do obj(cir(p[1], p[2], p[3]), R.sea) end
  ring(116, 80, 10, 3, 1):each(function(x, y) if (x + y) % 2 == 0 then put(x, y, CREAM) end end)
  -- lily pad + dragonfly
  obj(HP.ellipse(64, 92, 12, 4), R.moss)
  c:fillMask(HP.poly({ {64, 92}, {76, 89}, {76, 94} }), R.sea.base)
  obj(HP.rect(80, 40, 90, 41), R.sea); put(76, 40, R.sea.deep); put(77, 40, R.sea.deep)
  c:fillMask(HP.ellipse(81, 37, 3, 1), R.sea.hi); c:fillMask(HP.ellipse(86, 37, 3, 1), R.sea.hi)
  frame()
end

function S.vigpick()
  sky({ "#c8c0e8", "#e4cce0", "#f6dcc8" }, { 20, 38 })
  cloud(28, 15, 24); cloud(112, 22, 18)
  hill(46, 5, .05, 4, "#9a90c0", 70)
  hill(56, 3, .08, 2, "#7c78a8", 72)
  grass(70, 106, "#7aa86a", "#4f8460", "#b6d484", 17)
  -- boulder with lit top-left and ore veins
  local rock = HP.poly({ {60, 100}, {58, 70}, {66, 52}, {82, 38}, {104, 32}, {124, 38}, {138, 54}, {140, 100} })
  c:rim(rock, INK)
  rock:each(function(x, y)
    local t = R.stone.base
    local lx = (x - 100) * .6 + (y - 60) * .8
    if lx < -22 then t = R.stone.hi elseif lx > 28 then t = R.stone.shade end
    if lx > 46 then t = R.stone.deep end
    if hs(x, y, 9) > .92 then t = (t == R.stone.hi) and R.stone.base or R.stone.shade end
    if not rock:has(x - 1, y - 1) or not rock:has(x, y - 1) then t = R.stone.hi end
    put(x, y, t)
  end)
  for _, ln_ in ipairs({ { {96, 38}, {100, 54}, {94, 66}, {98, 80} }, { {122, 54}, {114, 72}, {118, 90} }, { {72, 62}, {80, 74} } }) do c:fillMask(ln(ln_, 1), R.stone.deep) end
  -- crystal ore + gold flecks
  for _, p in ipairs({ {108, 70, 7}, {126, 84, 6}, {80, 86, 5} }) do obj(HP.poly({ {p[1], p[2] - p[3]}, {p[1] + 4, p[2]}, {p[1], p[2] + p[3] - 1}, {p[1] - 4, p[2]} }), R.sea); put(p[1] - 1, p[2] - 2, CREAM) end
  for _, p in ipairs({ {90, 52}, {114, 48}, {130, 66} }) do put(p[1], p[2], R.gold.base); put(p[1] + 1, p[2], R.gold.hi) end
  -- pick: long handle, curved double head biting the rock
  local d = { .87, .49 }
  local pv = { -.49, .87 }
  local C0 = { 90, 56 }
  handle({ 14, 12 }, C0, 4)
  obj(HP.rect(10, 8, 14, 12), R.leather)
  for i = -10, 10 do
    local t = i / 10
    local px_ = C0[1] + pv[1] * t * 26 + d[1] * (t * t * 11 + 2)
    local py_ = C0[2] + pv[2] * t * 26 + d[2] * (t * t * 11 + 2)
    local r = (abs(i) < 3) and 3 or ((abs(i) < 7) and 2 or 1)
    L[#L + 1] = { cir(floor(px_ + .5), floor(py_ + .5), r), R.iron }
  end
  flush()
  c:fillMask(ln({ {88, 48}, {82, 36} }, 1), CREAM)
  spark(100, 66, R.gold.hi); spark(112, 80, CREAM); put(96, 74, R.gold.base); put(106, 58, R.gold.base)
  -- chips flying
  obj(HP.poly({ {74, 62}, {79, 58}, {80, 64} }), R.stone); obj(HP.poly({ {108, 54}, {113, 52}, {112, 58} }), R.stone)
  -- rubble
  for _, p in ipairs({ {54, 97, 5}, {46, 101, 3}, {142, 99, 4}, {64, 103, 3} }) do obj(HP.ellipse(p[1], p[2], p[3], p[3] - 1), R.stone) end
  -- mole on mound, facing the rock
  obj(HP.ellipse(26, 98, 19, 7), R.dirt)
  obj(HP.ellipse(26, 87, 8, 7), { hi = "#8a84a0", base = "#5a566c", shade = "#3f3c55", deep = INK })
  obj(HP.ellipse(31, 91, 4, 3), R.petal)
  put(24, 85, CREAM); put(29, 85, CREAM); put(24, 86, INK); put(29, 86, INK)
  obj(HP.rect(15, 92, 19, 96), R.petal); obj(HP.rect(34, 92, 38, 96), R.petal)
  frame()
end

-- Treehouse milestone dressing layers (transparent): rug (5 pals), string lights (10), telescope (20), pennant (40). Sizes = here_layouts.json 'treehouse'.dress
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/tree-yard/out/")
local floor, sin = math.floor, math.sin
local function new(name, w, h)
  local c = HP.canvas{ w = w, h = h, scale = 1, name = name }
  return c, dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
end
local function save(c, n) c:finish{ outline = true }; c:save{ aseprite = OUT .. n .. ".aseprite", png = OUT .. n .. ".png" } end
local cols = {"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8", "#8a6fd0", "#f5809f"}

-- rug 72x24 (perspective: a flat lozenge, fringe at both ends)
do
  local c, S = new("rug", 72, 24)
  local m = S.poly{{6, 3}, {65, 3}, {71, 20}, {1, 20}}
  c:fillMask(m, S.BARN[4])
  S.tex(m, function(x, y)
    local t = (y - 3) / 17
    if y == 3 then return S.BARN[5] end
    if y == 20 or x < 3 + floor(t * 2) then return S.BARN[2] end
    if y >= 6 and y <= 7 then return S.GOLD[5] end
    if y >= 15 and y <= 16 then return S.GOLD[5] end
    if y >= 9 and y <= 13 and (floor(x / 6) % 2 == 0) then return S.TEAL[4] end
    if y >= 9 and y <= 13 then return S.CREAM[5] end
  end)
  for x = 3, 68, 3 do c:px(x, 21, "#e4d0a8"); c:px(x + 1, 21, "#e4d0a8"); c:px(x, 22, "#bca290") end
  save(c, "tree-dress-rug")
end
-- string lights 260x26 (a sagging cord with bulbs; each bulb is a little lantern diamond)
do
  local c, S = new("lights", 260, 26)
  local pts = {}
  for x = 0, 259 do local y = 3 + floor(9 * sin(x / 260 * math.pi * 2 * 1.5) ^ 2 * 0 + 8 * (1 - ((x % 86) / 43 - 1) ^ 2)); pts[#pts + 1] = {x, y} end
  for _, p in ipairs(pts) do c:px(p[1], p[2], "#2b1c26") end
  for i = 0, 15 do
    local x = 8 + i * 16; local y0 = 3 + floor(8 * (1 - (((x % 86) / 43) - 1) ^ 2))
    local d = S.diamond(x, y0 + 5, 3); c:fillMask(d, ({"#ffe38a", "#ff8a5c", "#c4e07a", "#b6f0e0"})[i % 4 + 1]); c:px(x, y0 + 4, "#fff4d6")
  end
  save(c, "tree-dress-lights")
end
-- telescope 40x48 (brass tube on a wooden tripod, angled up and to the right)
do
  local c, S = new("telescope", 40, 48)
  S.obj(S.poly{{12, 46}, {15, 46}, {20, 26}, {18, 25}}, S.TIMB, { base = 4 })
  S.obj(S.poly{{28, 46}, {31, 46}, {22, 26}, {20, 25}}, S.TIMB, { base = 4 })
  S.obj(S.poly{{19, 28}, {22, 28}, {22, 46}, {19, 46}}, S.TIMB, { base = 3 })
  local tube = S.poly{{8, 22}, {12, 16}, {32, 4}, {36, 10}, {16, 26}}
  S.obj(tube, S.GOLD, { base = 4 })
  S.obj(S.poly{{30, 3}, {35, 1}, {38, 8}, {33, 11}}, S.GOLD, { base = 5 })
  c:fillMask(S.poly{{32, 5}, {35, 4}, {36, 7}, {33, 8}}, "#8bc4ea")
  S.obj(S.rect(17, 24, 23, 29), S.IRON, { base = 3 })
  save(c, "tree-dress-telescope")
end
-- pennant 56x30 (a swallow-tail flag on a pole, with stitched edge)
do
  local c, S = new("banner", 56, 30)
  S.obj(S.rect(4, 2, 6, 29), S.TIMB, { base = 4 })
  local f = S.poly{{7, 4}, {52, 8}, {44, 14}, {52, 20}, {7, 24}}
  c:fillMask(f, S.BARN[4])
  S.tex(f, function(x, y) if y <= 6 + floor((x - 7) / 11) then return S.BARN[5] end if y >= 22 - floor((x - 7) / 14) then return S.BARN[3] end if x > 14 and x < 22 and y > 10 and y < 18 then return S.GOLD[5] end end)
  c:fillMask(S.diamond(18, 14, 4), S.GOLD[5]); c:fillMask(S.diamond(18, 14, 2), S.BARN[4])
  save(c, "tree-dress-banner")
end
print("ok")

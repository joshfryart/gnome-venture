-- welcome-basket-topdown FIRST DRAFT. Draw 190x165, save x2 = 380x330. TOP-DOWN round woven basket.
-- Wide twill-woven rim (rolled outer edge, dark inner edge), two handle stubs, large flat low-contrast
-- straw floor kept clear for a 3x2 grid of items. Transparent outside, hard-pixel cast shadow lower-right,
-- 1px ink outline. quirk: one stray straw end poking out of the rim at lower left.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "welcome-basket-topdown"
local c = HP.canvas{ w = 190, h = 165, scale = 2, name = NAME }
local atan, sqrt, floor, pi = math.atan, math.sqrt, math.floor, math.pi
local CX, CY, RX, RY = 91.5, 77.5, 82, 70
local IR = 0.79
local T = { "#f2cf94", "#e0aa6a", "#c98d52", "#a86a40" }

local outer = c:ellipse(CX, CY, RX, RY)
local stubs = c:rrect(2, 66, 179, 88, 5):cut(c:ellipse(CX, CY, RX - 2, RY - 2))
local whole = outer:copy():add(stubs)
local N, ROWS = 84, 4
outer:each(function(x, y)
  local nx, ny = (x - CX) / RX, (y - CY) / RY
  local r = sqrt(nx * nx + ny * ny)
  local a = atan(ny, nx) if a < 0 then a = a + 2 * pi end
  local lit = nx + ny
  if r >= IR then
    local rr = (r - IR) / (1 - IR)
    local col
    if r > 0.955 then
      col = lit > 0.3 and "#8d5436" or (lit < -0.5 and T[1] or T[2])           -- rolled outer edge
      if lit > 0.3 and r < 0.97 then col = "#a86a40" end
    elseif r < IR + 0.035 then
      col = "#51302b"                                                          -- inner dark edge
    elseif r < IR + 0.075 then
      col = "#864c33"
    else
      local u = floor(a / (2 * pi) * N)
      local v = floor(rr * ROWS)
      local lu = floor(a / (2 * pi) * N * 4) % 4
      local lv = floor(rr * ROWS * 4) % 4
      local over = (u + v) % 4 < 2
      if over then
        col = lv == 0 and T[1] or (lv == 3 and T[3] or T[2])
        if lu == 3 then col = T[3] end
      else
        col = (lu == 0 or lu == 3) and "#8d5436" or T[3]
        if lv == 0 then col = "#8d5436" end
      end
      if lit > 0.8 then col = (col == T[1]) and T[2] or ((col == T[2]) and T[3] or col) end
    end
    c:put(x, y, col, "basket")
  end
end)
-- floor: flat straw, very low contrast basket-weave
local fl = c:ellipse(CX, CY, RX * IR, RY * IR)
fl:each(function(x, y)
  local cell = ((x // 6) + (y // 6)) % 2
  local col = cell == 0 and "#e6bb7f" or "#e0b377"
  if x % 6 == 0 or y % 6 == 0 then col = "#d9aa6e" end
  local nx, ny = (x - CX) / (RX * IR), (y - CY) / (RY * IR)
  local rr = sqrt(nx * nx + ny * ny)
  if rr > 0.93 and nx + ny < 0 then col = "#cf9f63" end   -- soft shade under the far/left rim
  c:put(x, y, col, "basket")
end)
-- handle stubs (wood-wrapped, flat caps)
for _, s in ipairs{ { 2, 9 }, { 173, 179 } } do
  local m = c:rrect(s[1], 67, s[2], 87, 2)
  c:part(m, "wood", { band = 2, pop = { x = s[1] + 1, y = 69 } })
  c:fillMask(c:rect(s[1], 76, s[2], 78), P.wood.deep)
end
-- quirk: stray straw end poking out
c:line({ {20, 120}, {16, 126} }, 1):each(function(x, y) c:put(x, y, "#e6bb7f", "basket") end)
c:finish{ outline = true }
-- cast shadow lower-right (hard pixels, painted last so it is not outlined)
local sh = whole:shift(4, 5)
sh:each(function(x, y) if not c:get(x, y) then c:put(x, y, "#8d8497", "shadow") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 2 }

local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 100, h = 100, mode = "scene", out = 2 }
local W, H = 100, 100
local function cols(f) -- f(x) -> y0,y1 ; vertical span per column
  local m = c:mask()
  for x = 0, W - 1 do local a, b = f(x); if a then for y = math.max(0, math.floor(a)), math.min(H - 1, math.floor(b)) do m:set(x, y) end end end
  return m
end
local function rows(f) -- f(y) -> x0,x1
  local m = c:mask()
  for y = 0, H - 1 do local a, b = f(y); if a then for x = math.max(0, math.floor(a)), math.min(W - 1, math.floor(b)) do m:set(x, y) end end end
  return m
end
-- 1 water
c:fill(c:rect(0, 0, 99, 99), "#1b2e3b")
local bandC = { "#243c4a", "#2f4a58", "#3f5d69", "#4f6f78" }
for i, col in ipairs(bandC) do
  local rx, ry = 64 - i * 11, 50 - i * 9
  c:fill(rows(function(y) local d = (y - 56) / ry; if math.abs(d) > 1 then return nil end
    local w = rx * math.sqrt(1 - d * d) + 0.8 * math.sin(y / 6 + i); return 50 - w, 50 + w end), col)
end
-- 2/3 rocks
local top = cols(function(x) return 0, 20 + 3 * math.sin(x / 7) + 2 * math.sin(x / 3.1 + 1) end)
local left = rows(function(y) if y < 34 then return nil end
  local t = (y - 34) / 66; return 0, 6 + 24 * math.sin(math.min(1, t * 1.1) * math.pi * 0.62) + 1.5 * math.sin(y / 3) end)
local right = rows(function(y) if y < 28 then return nil end
  local t = (y - 28) / 72; return 99 - (6 + 22 * math.sin(math.min(1, t * 1.15) * math.pi * 0.6) + 1.5 * math.sin(y / 2.7 + 2)), 99 end)
local rock = top:copy(); rock:add(left); rock:add(right)
c:fill(top, "#1f3644"); c:fill(left, "#1a2d3a"); c:fill(right, "#1a2d3a")
-- lit rim (light from upper-left): 1px lighter on the lower/right edge of top rock and the right edge of left rock
local rim = c:mask()
rock:each(function(x, y)
  if not rock:has(x, y + 1) and y < 99 then rim:set(x, y) end
end)
left:each(function(x, y) if x < 99 and not left:has(x + 1, y) and not top:has(x, y) then rim:set(x, y) end end)
c:fill(rim, "#2f4b59")
-- dark crease inside rocks (a few cracks)
c:fill(c:line({ {8, 4}, {14, 10}, {12, 15} }, 1), "#152633")
c:fill(c:line({ {60, 3}, {66, 9}, {72, 11} }, 1), "#152633")
c:fill(c:line({ {4, 50}, {9, 58}, {7, 66} }, 1), "#132430")
c:fill(c:line({ {94, 40}, {89, 48}, {92, 56} }, 1), "#132430")
-- 4 bank (higher at the sides, dipping in the middle)
local function bankTop(x) local d = (x - 50) / 50; return 84 + 9 * (1 - d * d) + 1.2 * math.sin(x / 2.3) end
c:fill(c:ellipse(50, 88.5, 22, 2), "#3f6f80")
c:fill(c:ellipse(50, 88.5, 22, 2):cut(c:rect(0, 90, 99, 99)), "#5fa1b6")
c:fill(c:ellipse(47.5, 88, 9, 0.6), "#bfe6ee")
local bank = cols(function(x) return bankTop(x), 99 end)
local bankD = cols(function(x) return bankTop(x) + 6 + math.sin(x / 3.4), 99 end)
c:fill(bank, "#3a5a46"); c:fill(bankD, "#2c4636")
local bl = c:mask(); bank:each(function(x, y) if not bank:has(x, y - 1) then bl:set(x, y) end end)
c:fill(bl, "#4c7458")
-- 7 motes
for _, p in ipairs({ {32, 35}, {70, 46}, {18, 60}, {84, 65} }) do c:px(p[1], p[2], "#8fcbd8") end
-- 6 mushrooms with hard glow rings
local function shroom(x, y)
  local g1 = c:ellipse(x, y - 3, 11, 9):cut(c:ellipse(x, y - 3, 8, 6.5))
  local g2 = c:ellipse(x, y - 3, 8, 6.5)
  c:fill(g1, "#2f5c58"); c:fill(g2, "#3f7a6a")
  c:paint({
    "...hhhh...",
    ".hhcccchh.",
    "hccccccccc",
    "cccccccccs",
    ".ssussuss.",
    "....ws....",
    "....ws....",
    "....ws....",
    "...wwss...",
  }, x - 5, y - 8, { h = "#bff7d4", c = "#7fe0a8", s = "#4fb07f", u = "#3a8a66", w = "#bff7d4" })
  c:px(x - 2, y - 6, "#e8fff0")
end
shroom(11, 89); shroom(89, 87)
local t = c:save(D .. "img-redraw-hybrid/aseprite/gather/calm-bg.aseprite", D .. "img-redraw-hybrid/png/gather/calm-bg.png")
print(GV.report(t))

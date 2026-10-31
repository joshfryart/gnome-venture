-- ph/natto, redraw A (2.2.1 leftovers, Opus medium): same wara-zuto straw sheaf as before but taller and
-- bigger so it reads at 16 px; a wide split on top with fewer, larger glossy beans and two sticky threads.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "natto", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local straw = GV.ramp("#e8d27a", { shade = "#c9b060", deep = "#94803a", bounce = "#d8bc66", rim = "#f6e6a0", gloss = "#fff3c8", dot = "#fbf6e8", pale = false })
local bean = GV.ramp("#b0742a", { shade = "#7a4a1f", deep = "#5e2f1e", bounce = "#8a5a24", gloss = "#f0c080", dot = "#fbe6b8", rim = "#d0924a" })
local CY = 41
local wrap = c:mask()
for x = 9, 55 do
  local h
  if x >= 19 and x <= 45 then h = 11 elseif x >= 15 and x <= 49 then h = 10 else h = 8 - ((x * 5) % 3 == 0 and 1 or 0) end
  for y = CY - h, CY + h - 2 do wrap:set(x, y) end
end
c:part(wrap, straw, { gloss = { 12, 35 }, cres = 5, deep = 2 })
wrap:each(function(x, y)
  if (y - CY) % 3 == 0 and (x * 7 + y * 3) % 13 ~= 0 then
    local g = c:get(x, y)
    if g == straw.base or g == straw.rim then c:px(x, y, "#ccb05a")
    elseif g == straw.shade then c:px(x, y, "#a08a48") end
  end
end)
c:part(c:rect(14, 30, 17, 50), GV.ramp("#7a4a1f"), { gloss = false, contact = false, cres = 2, deep = 0 })
c:part(c:rect(47, 30, 50, 50), GV.ramp("#7a4a1f"), { gloss = false, contact = false, cres = 2, deep = 0 })
-- split on top with beans
c:part(c:ellipse(32, 34, 12, 5), "#4a2414", { flat = true, rim = false, contact = false, contour = "#2a1a10" })
for _, p in ipairs({ {24, 34}, {30, 35}, {36, 35}, {41, 33}, {27, 30}, {33, 30}, {38, 29} }) do
  c:part(c:ellipse(p[1], p[2], 3, 2.5), bean, { flat = true, contact = false, contour = false })
  c:px(p[1] + 1, p[2] + 2, bean.deep); c:px(p[1] + 2, p[2] + 1, bean.deep)
  c:px(p[1] - 1, p[2] - 1, bean.dot)
end
-- sticky threads, inside the silhouette
c:fill(c:line({ {25, 32}, {30, 28}, {35, 29}, {40, 31} }, 1), "#f6f0dc")
c:fill(c:line({ {31, 37}, {35, 41}, {40, 43}, {45, 42} }, 1), "#f6f0dc")
c:ground(32, 54, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

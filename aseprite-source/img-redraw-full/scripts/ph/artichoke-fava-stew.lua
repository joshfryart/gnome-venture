-- ph/artichoke-fava-stew (Gourmand P2 dish): terracotta cazuela of golden broth with a halved artichoke (cut face:
-- nested pointed leaves round a purple choke) and a whole baby artichoke (rows of pointed scales), bright green favas
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "artichoke-fava-stew"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local floor, abs = math.floor, math.abs
-- wide shallow cazuela with straight flared sides
local dish = c:poly({ {8, 40}, {56, 40}, {51, 52}, {13, 52} }):add(c:ellipse(31.5, 40, 24, 7))
dish:add(c:ellipse(31.5, 51, 19, 2.5))
c:part(dish, "#a5663a", { cres = 3, gloss = false })
c:fill(c:ellipse(31.5, 40, 24, 7):edge():clip(c:rect(0, 32, 63, 40)), "#d08c58")
c:fill(c:rect(10, 45, 53, 45):clip(dish), "#7e4428")                         -- glaze line
c:seam({ {12, 48}, {51, 48} }, { gap = "#7e4428" })
-- golden broth
local stew = c:ellipse(31.5, 40, 21, 5)
c:part(stew, "#d8a838", { contour = "#5e2f1e", cres = 2, gloss = false, contact = false })
for _, p in ipairs({ {14, 40}, {48, 41}, {33, 43}, {26, 37} }) do c:px(p[1], p[2], "#b07a20") end
-- pointed arch (teardrop pointing up): half width at row y between top and bot
local function arch(cx, top, bot, hw)
  local m = c:mask()
  for y = top, bot do
    local t = (y - top) / (bot - top)
    local w = hw * math.sin(math.min(1, t * 1.25) * math.pi / 2) * (t > 0.8 and math.sqrt(1 - ((t - 0.8) / 0.2) ^ 2 * 0.55) or 1)
    for x = floor(cx - w + 0.5), floor(cx + w + 0.5) do if abs(x - cx) <= w then m:set(x, y) end end
  end
  return m
end
-- 1) halved artichoke, cut face to us (left): broad crown of pointed leaf tips, narrowing to the stem;
--    nested leaf layers, a purple fuzzy choke and the pale heart cupped under it
local ax = 21
local half = c:mask()
for y = 20, 41 do
  local t = (y - 21) / 19
  local w = t < 0.4 and (7 + 2.5 * t / 0.4) or (9.5 * math.cos((t - 0.4) / 0.6 * math.pi / 2) ^ 0.7)
  w = math.max(w, 2.5)
  for x = ax - 10, ax + 10 do
    local tip = 20 + ({ 0, 1, 2, 1 })[(x - ax + 12) % 4 + 1] * 1.5        -- zigzag crown of leaf tips
    if abs(x - ax) <= w and y >= tip then half:set(x, y) end
  end
end
half:add(c:rect(ax - 2, 41, ax + 1, 44))                                   -- stem stub
c:part(half, "#5f9a35", { cres = 3, gloss = false, contact = true })
c:fill(half:shrink(2):cut(c:rect(0, 41, 63, 63)), "#b8d070")                -- paler inner leaves
c:fill(half:shrink(3):cut(c:rect(0, 40, 63, 63)), "#e4e6b0")
c:fill(half:shrink(5):edge():cut(c:rect(0, 39, 63, 63)), "#a8c060")        -- inner leaf layer line
for _, l in ipairs({ { {ax - 5, 33}, {ax - 3, 25} }, { {ax + 5, 33}, {ax + 3, 25} }, { {ax, 28}, {ax, 24} } }) do c:fill(c:line(l, 1), "#8aa850") end  -- inner leaves converging up
for _, x in ipairs({ ax - 6, ax - 2, ax + 2, ax + 6 }) do c:px(x, 24, "#8a5a8a") end                                -- purple leaf tips
-- choke: a fuzzy purple dome sitting on the heart (vertical fibres), heart cupped below it
local inner = half:shrink(3)
local choke = c:ellipse(ax, 34, 4, 5):clip(c:rect(0, 0, 63, 34)):clip(inner)
c:fill(choke, "#9a5a8a")
for x = ax - 3, ax + 3, 2 do c:fill(c:rect(x, 30, x, 34):clip(choke), "#6a3a6a") end
c:px(ax - 1, 30, "#c890b0")
local heart = c:rect(ax - 7, 35, ax + 7, 40):clip(inner)
c:fill(heart, "#f4f0c8")
c:fill(c:rect(ax - 4, 35, ax + 4, 35):clip(heart), "#d8c890")                -- shadow under the choke
c:fill(c:rect(ax - 1, 41, ax, 43), "#b8d070")                               -- stem core
-- 2) whole baby artichoke (right): rows of pointed scales, lower rows over upper ones
local bx = 41
local body = arch(bx, 20, 42, 8)
c:part(body, "#5a8a32", { cres = 3, gloss = false, contact = true })
local scale = {
  "..d..",
  ".dpd.",
  "dGGGd",
  "dGgGd",
  "dgggd",
}
local rows = { { 21, { 0 } }, { 25, { -3, 3 } }, { 29, { -6, 0, 6 } }, { 33, { -3, 3 } }, { 37, { -6, 0, 6 } } }
for _, r in ipairs(rows) do
  for _, dx in ipairs(r[2]) do
    for j, row in ipairs(scale) do for i = 1, #row do
      local ch = row:sub(i, i)
      local x, y = bx + dx - 3 + i, r[1] + j - 1
      if ch ~= "." and body.s[c:key(x, y)] then
        c:px(x, y, ({ d = "#2f5a2a", p = "#8a5a8a", G = "#9ac85a", g = "#6a9a3a" })[ch])
      end
    end end
  end
end
-- fava beans: plump bright green ovals with a dark seam
for _, p in ipairs({ {11, 39}, {28, 41}, {49, 39}, {30, 36}, {35, 43}, {45, 43}, {16, 43} }) do
  c:paint({ ".lbb.", "lbbbb", "bbbbd", ".ddd." }, p[1], p[2], { l = "#c8f08a", b = "#7ac648", d = "#3f8a2e" })
end
c:ground(31.5, 56, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tilted egg: wide top, narrowing to the lower right
local body = c:ellipse(30, 31, 17, 15)
body:add(c:ellipse(37, 42, 11, 11))
body:add(c:poly({ {16, 36}, {44, 24}, {48, 44}, {30, 50} }))

-- curved spines poking out along the outline
local spines = c:mask()
local cx, cy = 32, 36
for i = 0, 13 do
  local a = i / 14 * math.pi * 2 + 0.2
  local dx, dy = math.cos(a), math.sin(a)
  local r = 4
  while body:has(math.floor(cx + dx * r + 0.5), math.floor(cy + dy * r + 0.5)) do r = r + 1 end
  local x, y = math.floor(cx + dx * r + 0.5), math.floor(cy + dy * r + 0.5)
  -- 2x2 nub plus a one-pixel curl clockwise
  spines:add(c:rect(x - 1, y - 1, x, y))
  local tx, ty = -dy, dx
  spines:set(math.floor(x + dx * 1.5 + tx * 1.2 + 0.5), math.floor(y + dy * 1.5 + ty * 1.2 + 0.5))
  spines:add(c:rect(math.floor(x + dx * 1.2 + 0.5) - 1, math.floor(y + dy * 1.2 + 0.5) - 1,
                    math.floor(x + dx * 1.2 + 0.5), math.floor(y + dy * 1.2 + 0.5)))
end
spines:cut(c:rect(27, 0, 36, 17)) -- keep the stem area clean

local stem = c:rect(30, 8, 32, 18)
local leaf = c:poly({ {33, 13}, {38, 8}, {45, 8}, {42, 13}, {36, 15} })

c:build{
  { "spines", spines, GV.ramp("#4a8a3e"), { flat = true } },
  { "stem",   stem,   GV.ramp("#8a4f2a"), { flat = true } },
  { "leaf",   leaf,   "moss", { flat = true } },
  { "body",   body,   GV.ramp("#6a9a3a"), { gloss = { 22, 24 } } },
}
-- face bumps: small diamonds in staggered rows
local D = { ".a.", "aaa", ".a." }
for _, p in ipairs({ {27, 22}, {37, 23}, {20, 32}, {31, 31}, {41, 33}, {26, 41}, {37, 43} }) do
  c:paint(D, p[1], p[2], { a = "#a4b86a" })
end

local t = c:save(O .. "aseprite/ph/soursop.aseprite", O .. "png/ph/soursop.png")
print(GV.report(t))

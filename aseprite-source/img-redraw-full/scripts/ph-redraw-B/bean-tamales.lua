-- ph/bean-tamales, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: two crossed pale logs read as candy wrappers or crackers; the masa and beans (what makes it a bean tamal)
-- were a few px. Fix (one object, show the filling): a single fat tamal standing on a slant, husk peeled open in a V at
-- the top to show a big yellow masa face studded with black beans, tied at the bottom with a fanned husk tail.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "bean-tamales", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local husk = GV.ramp("#e6cc78", { gloss = "#fff3c8", dot = "#fbf6e8", rim = "#f6e2a0", pale = false })
local masa = GV.ramp("#f4c43a", { gloss = "#fff0a0", dot = "#fffbe0", rim = "#ffe07a" })
-- fanned tail at the bottom right
c:part(c:poly({ {40, 44}, {54, 50}, {53, 54}, {55, 57}, {46, 57}, {36, 50} }), husk, { flat = true, contact = false })
c:fill(c:line({ {42, 49}, {53, 54} }, 1), "#c9a050")
-- body: a fat slanted capsule
local body = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local t = ((x - 18) * 22 + (y - 16) * 28) / (22 * 22 + 28 * 28)
  local px, py = 18 + 22 * t, 16 + 28 * t
  if t >= 0 and t <= 1 and (x - px) ^ 2 + (y - py) ^ 2 <= (11 - t * 4) ^ 2 then body:set(x, y) end
end end
c:part(body, husk, { gloss = false, cres = 4 })
for _, o in ipairs({ -6, -2, 3 }) do c:fill(c:line({ {22 + o, 32 - o}, {34 + o, 47 - o} }, 1):clip(body:shrink(1)), "#c9a050") end
-- string tie at the neck of the tail
c:fill(c:line({ {34, 50}, {43, 43} }, 2), "#7a4a1f")
-- open top: husk flaps peeled back in a V, masa face with beans
c:part(c:poly({ {7, 20}, {14, 9}, {17, 20} }):add(c:poly({ {22, 6}, {33, 11}, {26, 16} })), husk, { flat = true, contact = false })
local face = c:ellipse(19, 18, 10, 8)
c:part(face, masa, { gloss = { 13, 14 }, contour = "#b8661a" })
for _, b in ipairs({ {16, 17}, {21, 15}, {24, 20}, {18, 22}, {13, 20} }) do
  c:fill(c:rect(b[1], b[2], b[1] + 1, b[2] + 1), "#2a1a24"); c:px(b[1], b[2], "#5a3a5a")
end
c:ground(34, 58, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

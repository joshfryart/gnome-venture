-- gnome.lua : the player's gnome as layered toy-miniature parts, 64x80 each, same layer order as game/assets/img/gnome/ (shadow, body, face, beard, hat, band, star).
-- beard and hat are neutral greys so the game's tint filter keeps working. The 1 px black border and the umber outline go into the `shadow` layer (they sit under everything).
-- Output: mini/mini-gnome-<layer>.png (+ one layered mini-gnome.aseprite). Run: GV_ROOT=... Aseprite -b --script gnome.lua
local L = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/minis/lib.lua")
local X, GV = L.X, L.GV
local c = X.canvas{ mode = "sticker", w = 64, h = 80 }
local cx, by = L.base(c, 64, 80, "party", L.flat("#7ab55c", "#4f9a45"))
local u = 1.12
local g = { cx = cx, by = by, u = u }
local P, E, Rc, Poly = L.P, L.E, L.Rc, L.Poly
local flat, part, OP = L.flat, L.part, L.OP
local layers, order, prev = {}, { "shadow", "body", "face", "beard", "hat", "band", "star" }, {}
local function snap(name)
  local cur = {}
  layers[name] = layers[name] or {}
  for k, v in pairs(c.pix) do if prev[k] ~= v then layers[name][k] = v end cur[k] = v end
  prev = cur
end
snap("shadow")
-- body: green tunic with a brown belt, boots, 2 px lavender arms
local tunic, belt = flat("#6b8f4e", "#5a6d3b"), flat("#5b4636", "#3d2a1c")
part(c, E(c, g, -5, 2, 4, 2), belt, { gloss = false, flat = true }); part(c, E(c, g, 6, 2, 4, 2), belt, { gloss = false, flat = true })
part(c, Poly(c, g, { { -10, 3 }, { -12, 19 }, { 12, 19 }, { 11, 3 } }), tunic, { gloss = false, cres = 3, deep = 0 })
part(c, Rc(c, g, -11, 10, 11, 12), belt, { gloss = false, flat = true }); c:button(math.floor((cx)) - 1, math.floor(select(2, P(g, 0, 12))) - 2)
c:limb({ { math.floor(P(g, -11, 17)), math.floor(select(2, P(g, -11, 17))) }, { math.floor(P(g, -15, 10)), math.floor(select(2, P(g, -15, 10))) } })
c:limb({ { math.floor(P(g, 12, 17)), math.floor(select(2, P(g, 12, 17))) }, { math.floor(P(g, 16, 11)), math.floor(select(2, P(g, 16, 11))) } })
snap("body")
-- face
local skin = flat("#f1c9a5", "#d9a07c")
part(c, E(c, g, 1, 27, 11, 10), skin, { gloss = false, cres = 3, deep = 0 })
local ex, ey = P(g, -3, 28); c:eye(math.floor(ex) - 2, math.floor(ey) - 2); ex, ey = P(g, 6, 28); c:eye(math.floor(ex) - 2, math.floor(ey) - 2)
local nx, ny = P(g, 2, 23); c:px(math.floor(nx), math.floor(ny), "#d9885a"); c:px(math.floor(nx) + 1, math.floor(ny), "#d9885a")
snap("face")
-- beard: neutral grey, long, tinted by the game
local grey = flat("#cbcbcb", "#8e8e8e")
part(c, Poly(c, g, { { -9, 24 }, { 11, 24 }, { 9, 8 }, { 1, 3 }, { -7, 9 } }), grey, { gloss = false, cres = 3, deep = 0 })
c:seam({ { P(g, 1, 20) }, { P(g, 1, 8) } }, { free = true })
snap("beard")
-- hat: tall pointed cap, neutral grey
part(c, Poly(c, g, { { -10, 34 }, { 2, 52 }, { 13, 34 } }), grey, { gloss = false, cres = 3, deep = 0 })
part(c, Rc(c, g, -12, 33, 15, 35), grey, { gloss = false, flat = true })
snap("hat")
-- band (calling tier 2): gold band round the hat base. star (tier 3): gold star on the hat
local gold = flat("#e8a317", "#d0862a")
part(c, Rc(c, g, -11, 35, 14, 37), gold, { gloss = false, flat = true })
snap("band")
local sx, sy = P(g, 2, 44); sx, sy = math.floor(sx), math.floor(sy)
c:paint({ "..x..", ".xxx.", "xxxxx", ".xxx.", ".x.x." }, sx - 2, sy - 2, { x = "#f5cf6a" })
snap("star")
-- outline and black border (finish) land in the shadow layer, under everything
c:finish()
for k, v in pairs(c.pix) do if prev[k] ~= v then layers.shadow[k] = v end end
local pc = app.pixelColor
local function hex(h) h = h:gsub("#", "") return pc.rgba(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16), 255) end
local root = X.ROOT .. "opus-test-run/"
app.fs.makeAllDirectories(root .. "game/assets/img/mini/"); app.fs.makeAllDirectories(root .. "aseprite/")
local spr = Sprite(64, 80, ColorMode.RGB)
spr.layers[1].name = order[1]
for i = 2, #order do spr:newLayer().name = order[i] end
local report = {}
for i, name in ipairs(order) do
  local img = Image(64, 80, ColorMode.RGB); img:clear(pc.rgba(0, 0, 0, 0))
  local ncol, seen = 0, {}
  for k, h in pairs(layers[name]) do local x, y = c:xy(k); if c:inside(x, y) then img:putPixel(x, y, hex(h)); if not seen[h] then seen[h] = true; ncol = ncol + 1 end end end
  spr:newCel(spr.layers[i], spr.frames[1], img, Point(0, 0))
  local one = Sprite(64, 80, ColorMode.RGB); one.cels[1].image = img
  one:saveCopyAs(root .. "game/assets/img/mini/mini-gnome-" .. name .. ".png"); one:close()
  report[#report + 1] = name .. "=" .. ncol
end
spr:saveAs(root .. "aseprite/mini-gnome.aseprite"); spr:close()
print("mini-gnome layers (colours per layer): " .. table.concat(report, " "))

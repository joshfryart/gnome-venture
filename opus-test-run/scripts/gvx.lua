-- gvx.lua : thin layer on top of gvlib for the scene-overhaul test run (Part E).
--  * named Aseprite layers (sky, far, ground, objects, detail, fx, border) tracked by snapshot diffs
--  * .aseprite saved at the drawing grid size (editable, layered); PNG exported at c.out (2x nearest for scenes)
--  * optional `holes` mask: cut-outs inside a sprite (e.g. the "?" of npc-unknown) that keep the black border
--  * Part E checks: size, alpha, colour cap, black only as the 4-adjacent sprite border, palette provenance
-- Usage:  local X = dofile(ROOT .. "opus-test-run/scripts/gvx.lua"); local GV = X.GV
--         local c = X.canvas{...};  X.layer(c, "sky") ... X.layer(c, "far") ...;  X.save(c, "stage-grassland", "scenes", {cap=32})
local ROOT = os.getenv("GV_ROOT") or error("set GV_ROOT to the repo root (trailing slash)")
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local X = { GV = GV, ROOT = ROOT, OUT = ROOT .. "opus-test-run/" }
local ORDER = { "sky", "far", "ground", "objects", "detail", "fx", "border" } -- bottom to top

-- palette provenance: every colour must come from Part A, the Part D/brief table, GV.C/GV.R or a GV.ramp() call
local ALLOWED = {}
local function allow(h) if type(h) == "string" and h:sub(1,1) == "#" then ALLOWED[h:lower()] = true end end
for _, v in pairs(GV.C) do allow(v) end
for _, r in pairs(GV.R) do for _, v in pairs(r) do allow(v) end end
for _, v in ipairs({ -- Part A families + brief table extras
  "#3d2a1c","#7a4a1f","#9a6b3f","#c9a96e","#f1ece0","#2f5a2a","#4f9a45","#7ab55c","#a4b86a","#b07a10","#e8a317","#f5cf6a",
  "#a8241f","#d6322b","#e0501f","#f08a24","#e46a9b","#f6b8cf","#25637d","#3f8fb0","#a9d6ea","#4e3a8a","#7a5cc0","#c3b2ea",
  "#5b6470","#8b8f96","#c9c5bc","#f2e4c0","#fff3c8","#ffffff","#f5b860","#000000" }) do allow(v) end
local ramp0 = GV.ramp
GV.ramp = function(...) local r = ramp0(...) for _, v in pairs(r) do allow(v) end return r end
function X.ramp(...) return GV.ramp(...) end

function X.canvas(o)
  local c = GV.canvas(o)
  c._layers, c._snap, c._cur = {}, {}, "sky"
  for _, n in ipairs(ORDER) do c._layers[n] = {} end
  return c
end
local function flush(c, into)
  local L = c._layers[into or c._cur]
  for k, v in pairs(c.pix) do if c._snap[k] ~= v then L[k] = v; c._snap[k] = v end end
end
-- X.layer(c, name): everything drawn since the last call goes to the previous layer; new drawing goes to `name`
function X.layer(c, name)
  assert(c._layers[name], "gvx: unknown layer " .. tostring(name))
  flush(c); c._cur = name
end

local pc = app.pixelColor
local function hex2px(h) h = h:gsub("#", "") return pc.rgba(tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16), 255) end

-- border pass (same rule as gvlib finish): transparent px 4-adjacent to art -> #000000
local function border(c)
  local add = {}
  for y = 0, c.H-1 do for x = 0, c.W-1 do
    local k = c:key(x, y)
    if not c.pix[k] then
      for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
        local v = c.pix[c:key(x+d[1], y+d[2])]
        if v and v ~= "#000000" and c:inside(x+d[1], y+d[2]) then add[k] = true break end
      end
    end
  end end
  for k in pairs(add) do c.pix[k] = "#000000" end
end

-- checks on the exported PNG image (Part E "Checks before a scene file ships")
function X.check(img, o)
  local W, H = img.width, img.height
  local t = { w = W, h = H, semi = 0, clear = 0, cols = {}, n = 0, black = 0, badBlack = 0, white = 0, foreign = {} }
  local A = {}
  for it in img:pixels() do
    local v = it(); local a = pc.rgbaA(v)
    if a > 0 and a < 255 then t.semi = t.semi + 1 end
    if a == 0 then t.clear = t.clear + 1 end
    if a > 0 then
      local h = string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
      if not t.cols[h] then t.cols[h] = true; t.n = t.n + 1; if not ALLOWED[h] then t.foreign[#t.foreign+1] = h end end
      if h == "#000000" then t.black = t.black + 1 end
      if h == "#ffffff" then t.white = t.white + 1 end
      A[it.y * W + it.x] = (h == "#000000") and 2 or 1
    end
  end
  -- a black px is legal only if it is a border px: it touches art (non-black) 4-adjacently and touches
  -- transparent / another border px / the frame (it lies outside the art). Scenes: no black at all.
  local s = o.out or 1
  for k, v in pairs(A) do
    if v == 2 then
      local x, y = k % W, k // W
      local art, out = false, false
      for _, d in ipairs({{s,0},{-s,0},{0,s},{0,-s}}) do
        local nx, ny = x + d[1], y + d[2]
        if nx < 0 or ny < 0 or nx >= W or ny >= H then out = true
        else local q = A[ny * W + nx]; if q == 1 then art = true elseif q == nil or q == 2 then out = true end end
      end
      if o.scene or not (art and out) then t.badBlack = t.badBlack + 1 end
    end
  end
  t.ok = (W == o.w and H == o.h) and t.semi == 0 and t.n <= o.cap and t.badBlack == 0 and #t.foreign == 0
     and (not o.scene or (t.clear == 0 and t.black == 0)) and (o.scene or t.black > 0) and t.white <= (o.white or 0)
  return t
end

-- X.save(c, name, sub, {cap=, w=, h=, holes=mask, white=n})
function X.save(c, name, sub, o)
  local scene = c.mode == "scene"
  flush(c)
  if not scene then
    -- outline (finish) without border first: let gvlib build the outline, then strip its black border so we
    -- can cut holes and redo the border once on the final sprite
    c:finish()
    for k, v in pairs(c.pix) do if v == "#000000" then c.pix[k] = nil end end
    if o.holes then o.holes:each(function(x, y) c.pix[c:key(x, y)] = nil end) end
    flush(c, "objects")
    for _, L in pairs(c._layers) do for k in pairs(L) do if c.pix[k] == nil then L[k] = nil end end end
    border(c)
    flush(c, "border")
  else
    c:finish(); flush(c)
  end
  -- layered .aseprite at grid size
  local spr = Sprite(c.W, c.H, ColorMode.RGB)
  local names = {}
  for _, n in ipairs(ORDER) do if not (scene and n == "border") then names[#names+1] = n end end
  spr.layers[1].name = names[1]
  for i = 2, #names do local l = spr:newLayer(); l.name = names[i] end
  for i, n in ipairs(names) do
    local img = Image(c.W, c.H, ColorMode.RGB)
    img:clear(pc.rgba(0, 0, 0, 0))
    for k, h in pairs(c._layers[n]) do local x, y = c:xy(k) if c:inside(x, y) then img:putPixel(x, y, hex2px(h)) end end
    spr:newCel(spr.layers[i], spr.frames[1], img, Point(0, 0))
  end
  local ase = X.OUT .. "aseprite/" .. name .. ".aseprite"
  local png = X.OUT .. "game/assets/img/" .. sub .. "/" .. name .. ".png"
  app.fs.makeAllDirectories(app.fs.filePath(ase)); app.fs.makeAllDirectories(app.fs.filePath(png))
  spr:saveAs(ase)
  -- PNG: flatten, scale by c.out with nearest neighbour, export
  local flat = Image(spr.spec); flat:clear(pc.rgba(0, 0, 0, 0))
  for i = 1, #names do flat:drawImage(spr.layers[i].cels[1].image, spr.layers[i].cels[1].position) end
  spr:close()
  local f = c.out
  local big = Image(c.W * f, c.H * f, ColorMode.RGB)
  for it in flat:pixels() do local v = it() for j = 0, f-1 do for i = 0, f-1 do big:putPixel(it.x*f+i, it.y*f+j, v) end end end
  -- the layered file must flatten to exactly what gvlib drew
  local ref, diff = c:image(), 0
  for it in big:pixels() do if it() ~= ref:getPixel(it.x, it.y) and (pc.rgbaA(it()) > 0 or pc.rgbaA(ref:getPixel(it.x, it.y)) > 0) then diff = diff + 1 end end
  local out = Sprite(big.width, big.height, ColorMode.RGB)
  out.cels[1].image = big
  out:saveCopyAs(png); out:close()
  local t = X.check(big, { w = o.w, h = o.h, cap = o.cap, scene = scene, out = f, white = o.white })
  local fl = #t.foreign > 0 and (" foreign=" .. table.concat(t.foreign, ",")) or ""
  print(string.format("%-18s %dx%d colours=%d/%d semi=%d clear=%d black=%d badBlack=%d white=%d layerDiff=%d %s%s",
    name, t.w, t.h, t.n, o.cap, t.semi, t.clear, t.black, t.badBlack, t.white, diff, t.ok and "OK" or "FAIL", fl))
  return t
end

return X

-- col.lua: grey collar template, 64x64 per frame (idleA pounce catch nap), aligned to the new cats
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = dofile(DIR .. "/sm.lua")
local H, L = S.H, S.L
local NEW = "/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase2/final2/"
local INKV = 0x2b1c26
local function catMask(f)
  local img = Image { fromFile = NEW .. "cf-cat-grey-" .. f .. ".png" }
  local m, ink = L.mask(), L.mask()
  for y = 0, 63 do for x = 0, 63 do
    local p = img:getPixel(x, y)
    if app.pixelColor.rgbaA(p) > 0 then
      local v = app.pixelColor.rgbaR(p) * 65536 + app.pixelColor.rgbaG(p) * 256 + app.pixelColor.rgbaB(p)
      if v == INKV then ink:set(x, y) else m:set(x, y) end
    end
  end end
  return m, ink
end
local GB = { "#f5cf6a", "#e8a317", "#4a2c1a" }   -- fixed gold bell accents
local function frame(f, pts, r, bell, o)
  o = o or {}
  local c = L.canvas(64, 64, true)
  local cat = catMask(f)
  local band = L.tube(pts, function() return r end):clip(cat)
  if o.cut then band:cut(o.cut(cat)) end
  band:each(function(x, y)
    local top = not band:has(x, y - 1)
    local bot = not band:has(x, y + 1)
    local t = 'm'
    if top then t = 'L' elseif bot then t = 's' end
    if o.vert then
      local lft = not band:has(x - 1, y) local rgt = not band:has(x + 1, y)
      t = lft and 'L' or (rgt and 's' or 'm')
    end
    c:put(x, y, t, "band")
  end)
  -- thread highlights
  local n = 0
  band:each(function(x, y) if not band:has(x, y - 1) and (x % 6 == 0) then c:put(x, y, 'g', "band") end end)
  if bell then
    local bx, by = bell[1], bell[2]
    c:put(bx, by, GB[1], "bell") c:put(bx + 1, by, GB[2], "bell") c:put(bx, by + 1, GB[2], "bell") c:put(bx + 1, by + 1, GB[2], "bell")
    c:put(bx, by + 2, GB[3], "bell") c:put(bx + 1, by + 2, GB[3], "bell")
    c:put(bx - 1, by, GB[3], "bell") c:put(bx + 2, by, GB[3], "bell") c:put(bx - 1, by + 1, GB[3], "bell") c:put(bx + 2, by + 1, GB[3], "bell") c:put(bx, by - 1, GB[3], "bell") c:put(bx + 1, by - 1, GB[3], "bell")
    c:put(bx, by, "#f5cf6a", "bell")
  end
  c:save(H.OUT, "cf-collar-" .. f)
  print("collar", f, band:count(), c:colours())
end
local P = dofile(DIR .. "/colpos.lua")
for _, f in ipairs({ "idleA", "pounce", "catch", "nap" }) do frame(f, P[f].pts, P[f].r, P[f].bell, P[f].o) end

-- gen.lua : draws every creature in the 2.5D style from the spec tables (opus-test-run/scripts/minis/enemies.lua + the 7 crew in villagers.lua)
-- and writes, per creature: the fight rig sheet rig-<slug>.png (one column per part, row 0 paint, row 1 its 1 px ink) and the still mini-<slug>.png
-- (the same parts put together, on a ground shadow), plus fightrigs.js (bones per creature for game/assets/fightengine.js).
--   GV_ROOT=$PWD/ RIG=1 aseprite -b --script-param out=<dir>/ --script aseprite-source/v3/creature25/gen.lua
--   --script-param only=slug,slug   limit to some creatures (fightrigs.js then lists only those)
--   C25NPC=1 in the environment also draws the still of every villager (mini-npc-<slug>.png)
--   --script-param game=1           write into game/assets/img/fight, game/assets/img/mini and game/assets/fightrigs.js
-- One body type = one file in types/ (it returns function(g) -> bones). See c25lib.lua for the drawing API and types/frog.lua for the pattern.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local ROOT = os.getenv("GV_ROOT") or error("set GV_ROOT to the repo root (trailing slash)")
assert(os.getenv("RIG"), "run with RIG=1 (so the mini scripts only hand over their lists)")
local L = dofile(DIR .. "/c25lib.lua")
local HP, P = L.HP, L.P
local list = dofile(ROOT .. "opus-test-run/scripts/minis/enemies.lua")
for _, s in ipairs(dofile(ROOT .. "opus-test-run/scripts/minis/villagers.lua")) do list[#list + 1] = s end
local QUIRK = dofile(DIR .. "/quirks.lua")
local game = app.params.game
local out = app.params.out or (DIR .. "/out/")
local dirRig, dirMini, jsPath = out, out, out .. "fightrigs.js"
if game then dirRig, dirMini, jsPath = ROOT .. "game/assets/img/fight/", ROOT .. "game/assets/img/mini/", ROOT .. "game/assets/fightrigs.js" end
local want; if app.params.only then want = {}; for k in app.params.only:gmatch("[^,]+") do want[k] = true end end

local U = { small = 1.0, medium = 1.2, large = 1.5, boss = 2.0, party = 1.2 }   -- canvas px per figure unit
local TY = {}
local function typeOf(arch)
  if TY[arch] == nil then local f = io.open(DIR .. "/types/" .. arch .. ".lua"); if f then f:close(); TY[arch] = dofile(DIR .. "/types/" .. arch .. ".lua")(L) else TY[arch] = false end end
  return TY[arch]
end
-- which motion set (game/assets/fightarch.js) a creature uses: the same rule as the old rigs
local function archKey(s)
  local f, ar = s.feat or {}, s.arch
  if ar == "quad" then return "quad." .. (f.kind or "bear") end
  if ar == "bird" then return f.longlegs and "bird.long" or "bird" end
  if ar == "bug" then return "bug." .. (f.kind or ((f.shell and "beetle") or ((f.stripes and f.wings) and "wasp") or (f.wings and "moth") or "plain")) end
  if ar == "worm" then return "worm" .. (f.segs or 5) end
  return ar
end
local function seedOf(slug) local h = 5381; for i = 1, #slug do h = (h * 33 + slug:byte(i)) % 1000003 end return h end
local function num(v) local t = string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", ""); return t end
local pc = app.pixelColor
local cache = {}
local function rgba(hex) local v = cache[hex]; if not v then v = pc.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255); cache[hex] = v end return v end
local function savePng(img, path) local spr = Sprite(img.width, img.height, ColorMode.RGB); spr.cels[1].image = img; app.fs.makeAllDirectories(app.fs.filePath(path)); spr:saveCopyAs(path); spr:close() end

local CW, CH, OX, GY = 400, 320, 200, 290
local skel, rigs, done, skipped = {}, {}, 0, {}
for _, s in ipairs(list) do
  local ty = (not want or want[s.slug]) and typeOf(s.arch)
  if (not want or want[s.slug]) and not ty then skipped[#skipped + 1] = s.slug end
  if ty then
    local c = HP.canvas{ w = CW, h = CH, name = s.slug }
    local st, order, stray = {}, {}, {}
    c.pix, c.own = stray, {}
    local function tag(n) if not st[n] then st[n] = { pix = {}, own = {} }; order[#order + 1] = n end c.pix, c.own = st[n].pix, st[n].own end
    local u = U[s.size] * (s.scale or 1)
    local g = L.figure{ c = c, u = u, ox = OX, gy = GY, spec = s, quirk = QUIRK[s.slug], tag = tag, seed = seedOf(s.slug) }
    local bones = ty(g)
    assert(next(stray) == nil, s.slug .. ": draws before its first tag")
    -- per part: paint, and the 1 px ink ring around it (the eyes have none)
    local ids, ink = {}, {}
    local x0, y0, x1, y1 = CW, CH, 0, 0
    for _, n in ipairs(order) do if n ~= "_sh" then
      ids[#ids + 1] = n; local pix, ring = st[n].pix, {}
      for k in pairs(pix) do
        local x, y = k % CW, k // CW
        if n ~= "eyes" then for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do local kk = (y + d[2]) * CW + x + d[1]; if not pix[kk] then ring[kk] = true end end end
        if x < x0 then x0 = x end if x > x1 then x1 = x end if y < y0 then y0 = y end if y > y1 then y1 = y end
      end
      ink[n] = ring
    end end
    assert(y1 <= GY + 1, s.slug .. ": draws below the ground (row " .. y1 .. ")")
    local h = math.max(OX - x0, x1 - OX) + 2
    local fw, top = 2 * h + 1, y0 - 2
    local fh = GY - top + 5
    local ox = OX - h
    -- the rig sheet
    local img = Image(fw * #ids, fh * 2, ColorMode.RGB); img:clear(pc.rgba(0, 0, 0, 0))
    local still = Image(fw, fh, ColorMode.RGB); still:clear(pc.rgba(0, 0, 0, 0))
    local function inFrame(x, y) return x >= 0 and x < fw and y >= 0 and y < fh end
    if st._sh then for k, v in pairs(st._sh.pix) do local x, y = k % CW - ox, k // CW - top; if inFrame(x, y) then still:putPixel(x, y, rgba(v)) end end end
    for i, n in ipairs(ids) do for k in pairs(ink[n]) do local x, y = k % CW - ox, k // CW - top; if inFrame(x, y) then img:putPixel((i - 1) * fw + x, fh + y, rgba(P.ink)); still:putPixel(x, y, rgba(P.ink)) end end end
    for i, n in ipairs(ids) do for k, v in pairs(st[n].pix) do local x, y = k % CW - ox, k // CW - top; if inFrame(x, y) then img:putPixel((i - 1) * fw + x, y, rgba(v)); still:putPixel(x, y, rgba(v)) end end end
    local npc = s.slug:sub(1, 4) == "npc-"   -- villagers are stills only (they do not fight)
    if not npc then savePng(img, dirRig .. "rig-" .. s.slug .. ".png") end
    savePng(still, dirMini .. "mini-" .. s.slug .. ".png")
    -- bones: only the parts that were drawn; every part needs one
    local have, sk = {}, {}
    for _, n in ipairs(ids) do have[n] = true end
    for _, b in ipairs(bones) do if have[b[1]] then
      assert(not b[2] or st[b[2]], s.slug .. ": " .. b[1] .. " hangs from " .. tostring(b[2]) .. ", which is not drawn")
      sk[#sk + 1] = string.format('%s:[%s,%s,%s,%d]', b[1], b[2] and ('"' .. b[2] .. '"') or "0", num(b[3]), num(b[4]), b[5] and 1 or 0); have[b[1]] = nil
    end end
    assert(next(have) == nil, s.slug .. ": part without a bone: " .. tostring(next(have)))
    if not npc then skel[#skel + 1] = '"' .. s.slug .. '":{' .. table.concat(sk, ",") .. "}"
    rigs[#rigs + 1] = string.format('"%s":["%s",%d,%d,%s,"%s","%s"]', s.slug, s.slug, fw, fh, num(u), table.concat(ids, ","), archKey(s)) end
    done = done + 1
    print(string.format("%-24s %-14s %3dx%-3d u=%s parts=%d", s.slug, archKey(s), fw, fh, num(u), #ids))
  end
end
table.sort(skel); table.sort(rigs)
local js = { "/* GENERATED by aseprite-source/v3/creature25/gen.lua: do not edit. Creature rigs for assets/fightengine.js:", " * skel: bones per creature { part: [parent, a, b, under] }; rigs: { slug: [skeleton, frame w, frame h, scale u, \"part,part,...\", motion set (assets/fightarch.js)] }. */", "window.FE_RIGS={skel:{" }
js[#js + 1] = table.concat(skel, ",\n"); js[#js + 1] = "},rigs:{"; js[#js + 1] = table.concat(rigs, ",\n"); js[#js + 1] = "}};"
local fo = assert(io.open(jsPath, "w")); fo:write(table.concat(js, "\n") .. "\n"); fo:close()
print(done .. " creatures -> " .. jsPath .. (#skipped > 0 and ("   (no body type yet: " .. #skipped .. ")") or ""))

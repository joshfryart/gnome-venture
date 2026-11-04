/* recolor.js : gnome-player rig recolour by palette mapping. Plain JS, no dependencies.
 * Same maths as recolor.py (ramp recipe, preset resolution, marker mapping).
 *
 *   const rig = await (await fetch('rig.json')).json();
 *   const layers = rig.layers.map(L => ({ ...L, image: imageDataOf(L.file) })); // ImageData | canvas | {width,height,data}
 *   const out = GnomeRecolor.compose(rig, layers, { hat: 'ember red', tunic: '#3a86b0', skin: 'skinB' });
 *   ctx.putImageData(new ImageData(out.data, out.width, out.height), 0, 0);   // 384x80 strip
 *
 * Roles: hat tunic scarf beard boots skin trim. Value = preset name from rig.json, hex, or omitted (as drawn).
 */
(function (root) {
  'use strict';
  var TONES = ['hi', 'base', 'shade', 'deep'];

  function hexRgb(h) {
    h = h.replace('#', '');
    return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
  }
  function rgb2hsl(r, g, b) {
    r /= 255; g /= 255; b /= 255;
    var mx = Math.max(r, g, b), mn = Math.min(r, g, b), l = (mx + mn) / 2;
    if (mx === mn) return [0, 0, l];
    var d = mx - mn, s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn), h;
    if (mx === r) h = (g - b) / d + (g < b ? 6 : 0);
    else if (mx === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    return [h * 60, s, l];
  }
  function h2c(p, q, t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }
  function hsl2hex(h, s, l) {
    var r, g, b;
    if (s === 0) { r = g = b = l; } else {
      var q = l < 0.5 ? l * (1 + s) : l + s - l * s, p = 2 * l - q, hh = h / 360;
      r = h2c(p, q, hh + 1 / 3); g = h2c(p, q, hh); b = h2c(p, q, hh - 1 / 3);
    }
    return '#' + [r, g, b].map(function (v) {
      var n = Math.floor(v * 255 + 0.5);
      return (n < 16 ? '0' : '') + n.toString(16);
    }).join('');
  }
  function toward(h, target, amt) {
    var d = ((target - h + 540) % 360) - 180;
    var step = Math.min(Math.abs(d), amt) * (d >= 0 ? 1 : -1);
    return (h + step + 360) % 360;
  }
  function clampL(l) { return Math.min(0.97, Math.max(0.03, l)); }

  /** base hex -> [hi, base, shade, deep] (recipe in rig.json "recipe") */
  function rampFromBase(base) {
    var c = rgb2hsl.apply(null, hexRgb(base)), h = c[0], s = c[1], l = c[2];
    return [
      hsl2hex(toward(h, 45, 10), s, clampL(l + (1 - l) * 0.30)),
      hsl2hex(h, s, l),
      hsl2hex(toward(h, 270, 8), s * 0.80, clampL(l * 0.80)),
      hsl2hex(toward(h, 270, 20), s * 0.60, clampL(l * 0.55)),
    ];
  }

  /** role + (preset name | hex | undefined) -> ramp */
  function resolve(rig, role, spec) {
    var pre = rig.presets[role];
    if (spec == null) spec = 'default';
    if (pre[spec]) {
      var p = pre[spec];
      return p.ramp ? p.ramp.map(function (x) { return x.toLowerCase(); }) : rampFromBase(p.base);
    }
    if (/^#?[0-9a-fA-F]{6}$/.test(spec)) return rampFromBase('#' + spec.replace('#', ''));
    throw new Error('recolor: "' + spec + '" is not a ' + role + ' preset or hex colour');
  }

  function pixels(img) {
    if (img.data) return img; // ImageData-like
    var ctx = img.getContext('2d'); // canvas
    return ctx.getImageData(0, 0, img.width, img.height);
  }

  /** layers: [{name, role, tint, image}] in rig order. Returns {width, height, data: Uint8ClampedArray}. */
  function compose(rig, layers, colours) {
    colours = colours || {};
    var mk = {};
    TONES.forEach(function (t) { mk[hexRgb(rig.markers[t]).join(',')] = t; });
    var first = pixels(layers[0].image), W = first.width, H = first.height;
    var out = new Uint8ClampedArray(W * H * 4);
    layers.forEach(function (L) {
      var src = pixels(L.image).data, map = null;
      if (L.tint) {
        var r = resolve(rig, L.role, colours[L.role]);
        map = {};
        TONES.forEach(function (t, i) { map[t] = hexRgb(r[i]); });
      }
      for (var i = 0; i < src.length; i += 4) {
        if (src[i + 3] === 0) continue; // hard pixels: alpha is 0 or 255
        var c = [src[i], src[i + 1], src[i + 2]];
        if (map) { var t = mk[c.join(',')]; if (t) c = map[t]; }
        out[i] = c[0]; out[i + 1] = c[1]; out[i + 2] = c[2]; out[i + 3] = 255;
      }
    });
    return { width: W, height: H, data: out };
  }

  var api = { rampFromBase: rampFromBase, resolve: resolve, compose: compose, TONES: TONES };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.GnomeRecolor = api;
})(this);

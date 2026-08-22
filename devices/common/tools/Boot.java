import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import javax.imageio.ImageIO;

/**
 * Renders the BrinaOS boot and shutdown animations as PNG frame sequences.
 *
 * ColorOS's bootanimation reads a band rather than a full screen - the stock
 * desc.txt is "g 1440 777 0 688 60", i.e. a 1440x777 strip drawn 688px down a
 * 1440-wide framebuffer - so the frames here are that strip, not the display.
 * Keeping the stock geometry means the animation lands where the stock one did
 * whatever resolution the panel happens to be running at.
 *
 * The crest artwork is gold on black with no alpha channel, so it is unmatted
 * on load: alpha = max(r,g,b) and the colour is divided back out by it. Drawn
 * over black that is pixel-for-pixel the original, but it also gives a real
 * alpha channel to scale, blur and mask with.
 *
 * Frames are written as 256-colour PNGs. The whole animation is one gold ramp
 * over black, so a palette costs nothing visually and is what keeps the zip in
 * the same size class as the stock one - truecolour frames come to 28MB.
 *
 *   java Boot.java boot     <crest.png> <wordmark.png> <outDir> <w> <h> <n0> <n1>
 *   java Boot.java shutdown <wordmark.png> <outDir> <w> <h> <n0> <n1>
 *
 * outDir gets part0/ and part1/ full of brina_NNN.png, ready to zip -0.
 */
public class Boot {

    // Warm highlight the sheen tints towards, sampled off the crest's brightest ink.
    static final int SHEEN_R = 255, SHEEN_G = 246, SHEEN_B = 200;

    static int W, H;

    /** One part of the animation, rendered on demand so nothing is held in memory. */
    interface Seq { int count(); int[] frame(int i); }

    public static void main(String[] a) throws Exception {
        String mode = a[0];
        int i = 1;
        Img crest = unmatte(ImageIO.read(new File(a[i++])));
        Img word = load(ImageIO.read(new File(a[i++])));
        File out = new File(a[i++]);
        W = Integer.parseInt(a[i++]);
        H = Integer.parseInt(a[i++]);
        int n0 = Integer.parseInt(a[i++]), n1 = Integer.parseInt(a[i++]);

        Lockup l = new Lockup(crest, word);
        Seq[] parts = mode.equals("boot") ? boot(l, n0, n1) : shutdown(l, n0, n1);
        int[] palette = quantise(parts, 256);
        int[] lut = lut(palette);
        for (int p = 0; p < 2; p++) {
            File dir = new File(out, "part" + p);
            dir.mkdirs();
            for (int f = 0; f < parts[p].count(); f++)
                write(parts[p].frame(f), palette, lut, new File(dir, name(f)));
        }
        System.out.println(mode + ": " + n0 + " + " + n1 + " frames of " + W + "x" + H
                + ", " + palette.length + " colours");
    }

    // -------------------------------------------------------------- lockup

    /**
     * The crest over the wordmark, laid out once. Boot and shutdown draw the
     * same thing and differ only in the curves they drive it with, which is
     * what makes the power-off read as the boot animation running backwards.
     */
    static class Lockup {
        final Img crest, halo, word;
        final int crestX, crestY, crestW, crestH, wordX, wordY;

        Lockup(Img crestArt, Img wordArt) {
            Img trimmed = trim(crestArt);
            crestH = Math.round(H * 0.77f);                     // 598 of 777 — commands the band
            crestW = Math.round(crestH * (float) trimmed.w / trimmed.h);
            crest = scale(trimmed, crestW, crestH);
            halo = blur(crest, Math.max(6, crestH / 24));       // a touch softer for the size

            int wordH = Math.round(H * 0.090f);                 // 70 of 777 — larger wordmark
            word = scale(wordArt, Math.round(wordH * (float) wordArt.w / wordArt.h), wordH);

            int gap = Math.round(H * 0.036f);                   // tighter gap for the bigger art
            int top = (H - (crestH + gap + wordH)) / 2 - Math.round(H * 0.012f);
            crestX = (W - crestW) / 2;                          // crest stays centred
            crestY = top;
            wordX = (W - word.w) / 2 + Math.round(W * 0.014f);  // nudge text right
            wordY = top + crestH + gap;
        }

        int[] draw(double scale, double alpha, double glow, double sheen,
                   double wordAlpha, double wipe) {
            int[] px = black();
            drawCrest(px, crest, halo, crestX, crestY, crestW, crestH, scale, alpha, glow, sheen);
            drawWord(px, word, wordX, wordY, wordAlpha, wipe);
            return px;
        }
    }

    // ---------------------------------------------------------------- boot

    static Seq[] boot(final Lockup l, int n0, int n1) {
        Seq part0 = new Seq() {
            public int count() { return n0; }
            public int[] frame(int f) {
                double t = (double) f / (count() - 1);
                double enter = clamp01(t / 0.46);               // crest rises and settles
                double in = ease(enter);
                // Grow from 0.84 with a soft overshoot so the crest lands rather
                // than just cross-fades - the settle is what makes it a welcome.
                double scale = 0.84 + 0.16 * easeOutBack(enter);
                return l.draw(scale, in,
                        0.82 * bump(t / 0.52) + 0.26 * in,      // luminous bloom at arrival
                        window(t, 0.24, 0.82),                   // one slow, wide sheen
                        ease(clamp01((t - 0.46) / 0.34)),        // word fades up once crest lands
                        ease(clamp01((t - 0.44) / 0.40)));       // then wipes on
            }
        };
        Seq part1 = new Seq() {
            public int count() { return n1; }
            public int[] frame(int f) {
                double t = (double) f / count();                // loops, so no -1
                return l.draw(1.0, 1.0,
                        0.20 + 0.13 * (1 - Math.cos(2 * Math.PI * t)) / 2,  // gentle breathing
                        window(t, 0.08, 0.50), 1.0, 1.0);        // one sheen shimmer per loop
            }
        };
        return new Seq[] { part0, part1 };
    }

    // ------------------------------------------------------------ shutdown

    /**
     * Picks up where the boot loop rests - same lockup, same 0.18 glow - and
     * lets go of it: one last sheen, a bloom, then everything fades and settles
     * back a fraction. The wordmark leaves first so the crest is the last thing
     * on screen. part1 is black, so a slow power-off just holds there.
     */
    static Seq[] shutdown(final Lockup l, int n0, int n1) {
        Seq part0 = new Seq() {
            public int count() { return n0; }
            public int[] frame(int f) {
                double t = (double) f / (count() - 1);
                double out = 1 - ease(clamp01((t - 0.42) / 0.58));
                return l.draw(1.0 - 0.045 * ease(t), out,
                        (0.18 + 0.34 * bump(t / 0.5)) * out,
                        window(t, 0.02, 0.44),
                        1 - ease(clamp01((t - 0.30) / 0.50)), 1.0);
            }
        };
        Seq part1 = new Seq() {
            public int count() { return n1; }
            public int[] frame(int f) { return black(); }
        };
        return new Seq[] { part0, part1 };
    }

    /** Halo under, crest over, then a highlight band swept across it. */
    static void drawCrest(int[] px, Img big, Img halo, int x, int y, int w, int h,
                          double scale, double alpha, double glow, double sheen) {
        if (alpha <= 0) return;
        int sw = (int) Math.round(w * scale), sh = (int) Math.round(h * scale);
        int sx = x + (w - sw) / 2, sy = y + (h - sh) / 2;
        if (glow > 0) blit(px, scale(halo, sw, sh), sx, sy, alpha * glow);
        Img s = scale(big, sw, sh);
        blit(px, s, sx, sy, alpha);
        if (sheen > 0) blit(px, band(s, sheen), sx, sy, alpha);
    }

    /** A diagonal highlight band, alpha-masked by the crest itself. */
    static Img band(Img s, double pos) {
        Img o = new Img(s.w, s.h);
        double span = s.w + s.h;
        double c = -0.35 * span + pos * 1.7 * span;      // travels off-edge to off-edge
        double half = span * 0.11;
        for (int y = 0; y < s.h; y++)
            for (int x = 0; x < s.w; x++) {
                int sa = s.px[y * s.w + x] >>> 24;
                if (sa == 0) continue;
                double d = Math.abs((x + y) - c);
                if (d > half) continue;
                double k = Math.cos(d / half * Math.PI / 2);
                k = k * k * 0.85;
                o.px[y * s.w + x] = ((int) (sa * k) << 24)
                        | (SHEEN_R << 16) | (SHEEN_G << 8) | SHEEN_B;
            }
        return o;
    }

    static void drawWord(int[] px, Img wm, int x, int y, double alpha, double wipe) {
        if (alpha <= 0) return;
        if (wipe >= 1.0) { blit(px, wm, x, y, alpha); return; }
        double edge = wm.w * 0.18;
        double cut = -edge + wipe * (wm.w + edge);
        Img o = new Img(wm.w, wm.h);
        for (int j = 0; j < wm.h; j++)
            for (int k = 0; k < wm.w; k++) {
                int p = wm.px[j * wm.w + k];
                int sa = p >>> 24;
                if (sa == 0) continue;
                o.px[j * wm.w + k] = ((int) (sa * clamp01((cut - k) / edge)) << 24) | (p & 0xFFFFFF);
            }
        blit(px, o, x, y, alpha);
    }

    // ----------------------------------------------------------- quantising

    /**
     * Median cut over a sample of the frames. Everything here is one hue ramp,
     * so a handful of frames spread across both parts covers the whole gamut.
     */
    static int[] quantise(Seq[] parts, int want) {
        List<Integer> sample = new ArrayList<>();
        for (Seq s : parts) {
            int stepF = Math.max(1, s.count() / 6);
            for (int f = 0; f < s.count(); f += stepF) {
                int[] px = s.frame(f);
                for (int i = 0; i < px.length; i += 11) sample.add(px[i] & 0xFFFFFF);
            }
        }
        int[] all = new int[sample.size()];
        for (int i = 0; i < all.length; i++) all[i] = sample.get(i);

        List<int[]> boxes = new ArrayList<>();
        boxes.add(new int[] { 0, all.length });
        java.util.Arrays.sort(all);                       // start sorted on the packed value
        while (boxes.size() < want) {
            int best = -1, bestRange = -1, bestCh = 0;
            for (int i = 0; i < boxes.size(); i++) {
                int[] b = boxes.get(i);
                if (b[1] - b[0] < 2) continue;
                for (int ch = 0; ch < 3; ch++) {
                    int lo = 255, hi = 0;
                    for (int k = b[0]; k < b[1]; k++) {
                        int v = (all[k] >> (16 - ch * 8)) & 255;
                        if (v < lo) lo = v;
                        if (v > hi) hi = v;
                    }
                    if (hi - lo > bestRange) { bestRange = hi - lo; best = i; bestCh = ch; }
                }
            }
            if (best < 0 || bestRange <= 0) break;
            int[] b = boxes.get(best);
            final int ch = bestCh;
            Integer[] slice = new Integer[b[1] - b[0]];
            for (int k = 0; k < slice.length; k++) slice[k] = all[b[0] + k];
            java.util.Arrays.sort(slice, (p, q) ->
                    Integer.compare((p >> (16 - ch * 8)) & 255, (q >> (16 - ch * 8)) & 255));
            for (int k = 0; k < slice.length; k++) all[b[0] + k] = slice[k];
            int mid = b[0] + slice.length / 2;
            boxes.set(best, new int[] { b[0], mid });
            boxes.add(new int[] { mid, b[1] });
        }

        int[] palette = new int[boxes.size()];
        for (int i = 0; i < boxes.size(); i++) {
            int[] b = boxes.get(i);
            long r = 0, g = 0, bl = 0;
            for (int k = b[0]; k < b[1]; k++) {
                r += (all[k] >> 16) & 255; g += (all[k] >> 8) & 255; bl += all[k] & 255;
            }
            int n = Math.max(1, b[1] - b[0]);
            palette[i] = (int) (r / n) << 16 | (int) (g / n) << 8 | (int) (bl / n);
        }
        return palette;
    }

    /** Nearest palette entry for every 5:5:5 colour, so mapping a frame is a lookup. */
    static int[] lut(int[] palette) {
        int[] lut = new int[32768];
        for (int i = 0; i < 32768; i++) {
            int r = (i >> 10 & 31) * 255 / 31, g = (i >> 5 & 31) * 255 / 31, b = (i & 31) * 255 / 31;
            int best = 0, bestD = Integer.MAX_VALUE;
            for (int p = 0; p < palette.length; p++) {
                int dr = ((palette[p] >> 16) & 255) - r;
                int dg = ((palette[p] >> 8) & 255) - g;
                int db = (palette[p] & 255) - b;
                int d = dr * dr * 3 + dg * dg * 6 + db * db;
                if (d < bestD) { bestD = d; best = p; }
            }
            lut[i] = best;
        }
        return lut;
    }

    static void write(int[] px, int[] palette, int[] lut, File f) throws IOException {
        byte[] r = new byte[palette.length], g = new byte[palette.length], b = new byte[palette.length];
        for (int i = 0; i < palette.length; i++) {
            r[i] = (byte) (palette[i] >> 16); g[i] = (byte) (palette[i] >> 8); b[i] = (byte) palette[i];
        }
        IndexColorModel icm = new IndexColorModel(8, palette.length, r, g, b);
        BufferedImage img = new BufferedImage(icm, icm.createCompatibleWritableRaster(W, H), false, null);
        WritableRaster ras = img.getRaster();
        for (int y = 0; y < H; y++)
            for (int x = 0; x < W; x++) {
                int p = px[y * W + x];
                ras.setSample(x, y, 0,
                        lut[(p >> 19 & 31) << 10 | (p >> 11 & 31) << 5 | (p >> 3 & 31)]);
            }
        ImageIO.write(img, "png", f);
    }

    // --------------------------------------------------------------- pixels

    static class Img {
        final int w, h; final int[] px;
        Img(int w, int h) { this.w = w; this.h = h; this.px = new int[w * h]; }
    }

    static Img load(BufferedImage b) {
        Img o = new Img(b.getWidth(), b.getHeight());
        b.getRGB(0, 0, o.w, o.h, o.px, 0, o.w);
        return o;
    }

    /** Gold on black with no alpha channel -> a real alpha channel. */
    static Img unmatte(BufferedImage b) {
        Img s = load(b);
        Img o = new Img(s.w, s.h);
        for (int i = 0; i < s.px.length; i++) {
            int p = s.px[i];
            int r = (p >> 16) & 255, g = (p >> 8) & 255, bl = p & 255;
            int a = Math.max(r, Math.max(g, bl));
            if (a == 0) continue;
            o.px[i] = (a << 24) | (r * 255 / a << 16) | (g * 255 / a << 8) | (bl * 255 / a);
        }
        return o;
    }

    static Img trim(Img s) {
        int x0 = s.w, y0 = s.h, x1 = -1, y1 = -1;
        for (int y = 0; y < s.h; y++)
            for (int x = 0; x < s.w; x++)
                if ((s.px[y * s.w + x] >>> 24) > 8) {
                    if (x < x0) x0 = x;
                    if (x > x1) x1 = x;
                    if (y < y0) y0 = y;
                    if (y > y1) y1 = y;
                }
        if (x1 < 0) return s;
        Img o = new Img(x1 - x0 + 1, y1 - y0 + 1);
        for (int y = 0; y < o.h; y++)
            System.arraycopy(s.px, (y + y0) * s.w + x0, o.px, y * o.w, o.w);
        return o;
    }

    /** Halved repeatedly before the final step so downscales stay clean. */
    static Img scale(Img s, int w, int h) {
        if (s.w == w && s.h == h) return s;
        BufferedImage b = toBuf(s);
        while (b.getWidth() / 2 > w && b.getHeight() / 2 > h)
            b = step(b, b.getWidth() / 2, b.getHeight() / 2);
        return load(step(b, w, h));
    }

    static BufferedImage step(BufferedImage in, int w, int h) {
        BufferedImage o = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = o.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.drawImage(in, 0, 0, w, h, null);
        g.dispose();
        return o;
    }

    static BufferedImage toBuf(Img s) {
        BufferedImage b = new BufferedImage(s.w, s.h, BufferedImage.TYPE_INT_ARGB);
        b.setRGB(0, 0, s.w, s.h, s.px, 0, s.w);
        return b;
    }

    /** Three box passes - close enough to a gaussian for a halo. */
    static Img blur(Img s, int r) {
        Img o = s;
        for (int i = 0; i < 3; i++) o = box(o, r);
        return o;
    }

    static Img box(Img s, int r) {
        Img t = new Img(s.w, s.h), o = new Img(s.w, s.h);
        for (int y = 0; y < s.h; y++)
            for (int x = 0; x < s.w; x++) {
                long a = 0, rr = 0, gg = 0, bb = 0; int n = 0;
                for (int k = -r; k <= r; k++) {
                    int xx = x + k;
                    if (xx < 0 || xx >= s.w) continue;
                    int p = s.px[y * s.w + xx], pa = p >>> 24;
                    a += pa; rr += ((p >> 16) & 255) * pa; gg += ((p >> 8) & 255) * pa; bb += (p & 255) * pa;
                    n++;
                }
                t.px[y * s.w + x] = pack(a, rr, gg, bb, n);
            }
        for (int y = 0; y < s.h; y++)
            for (int x = 0; x < s.w; x++) {
                long a = 0, rr = 0, gg = 0, bb = 0; int n = 0;
                for (int k = -r; k <= r; k++) {
                    int yy = y + k;
                    if (yy < 0 || yy >= s.h) continue;
                    int p = t.px[yy * s.w + x], pa = p >>> 24;
                    a += pa; rr += ((p >> 16) & 255) * pa; gg += ((p >> 8) & 255) * pa; bb += (p & 255) * pa;
                    n++;
                }
                o.px[y * s.w + x] = pack(a, rr, gg, bb, n);
            }
        return o;
    }

    static int pack(long a, long r, long g, long b, int n) {
        if (a == 0 || n == 0) return 0;
        return (int) (a / n) << 24 | (int) (r / a) << 16 | (int) (g / a) << 8 | (int) (b / a);
    }

    static int[] black() { return new int[W * H]; }

    static void blit(int[] dst, Img s, int x, int y, double alpha) {
        if (alpha <= 0) return;
        for (int j = 0; j < s.h; j++) {
            int dy = y + j;
            if (dy < 0 || dy >= H) continue;
            for (int i = 0; i < s.w; i++) {
                int dx = x + i;
                if (dx < 0 || dx >= W) continue;
                int p = s.px[j * s.w + i];
                int sa = p >>> 24;
                if (sa == 0) continue;
                double a = sa / 255.0 * alpha;
                int d = dst[dy * W + dx];
                int dr = (d >> 16) & 255, dg = (d >> 8) & 255, db = d & 255;
                dst[dy * W + dx] = (clamp(dr + (((p >> 16) & 255) - dr) * a) << 16)
                                 | (clamp(dg + (((p >> 8) & 255) - dg) * a) << 8)
                                 |  clamp(db + ((p & 255) - db) * a);
            }
        }
    }

    // ---------------------------------------------------------------- curves

    static String name(int f) { return String.format("brina_%03d.png", f); }
    static double clamp01(double v) { return v < 0 ? 0 : v > 1 ? 1 : v; }
    static int clamp(double v) { return v < 0 ? 0 : v > 255 ? 255 : (int) (v + 0.5); }
    static double ease(double t) { return 1 - Math.pow(1 - t, 3); }

    /** Ease-out with a gentle overshoot past 1 before it settles - the "pop". */
    static double easeOutBack(double t) {
        double c1 = 1.20158, c3 = c1 + 1, u = t - 1;
        return 1 + c3 * u * u * u + c1 * u * u;
    }

    /** 0 -> 1 -> 0 over [0,1], flat outside. */
    static double bump(double t) { return t <= 0 || t >= 1 ? 0 : Math.sin(Math.PI * t); }

    /** 0 outside [a,b], the sweep's 0..1 progress inside. */
    static double window(double t, double a, double b) {
        return t < a || t > b ? 0 : (t - a) / (b - a);
    }
}

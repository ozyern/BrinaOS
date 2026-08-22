import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.util.*;
import java.util.List;
import javax.imageio.ImageIO;

/**
 * Builds the big version key-visual in the Software update card - the giant
 * "16" / "16.1" that r5/f.L0 drops into iv_version_logo (@drawable/kv_16 and
 * kv_16_1). Stock renders it in the ColorOS pink/lavender gradient, so at
 * "up to date" the card reads ColorOS however BrinaOS the wordmark under it is;
 * this is the piece BrinaOSUpdateApp never overrode.
 *
 * The numerals are taken straight from the stock kv_16.png so the typeface and
 * soft edges match exactly: its alpha is the ink coverage, the two glyphs are
 * segmented on the transparent column between them, and the wanted string is
 * recomposed from those glyphs (with a drawn dot for '.') and refilled with the
 * BrinaOS champagne-to-gold gradient. Only the colour changes.
 *
 *   java KvNum.java <stock_kv_16.png> <string> <canvasW> <canvasH> <out.png>
 */
public class KvNum {
    // BrinaOS gold: pale champagne at the top of the ink, deep gold at the foot.
    static final Color TOP = new Color(0xFC, 0xEF, 0xD2);
    static final Color MID = new Color(0xEB, 0xC7, 0x82);
    static final Color BOT = new Color(0xC9, 0x8F, 0x2E);

    public static void main(String[] a) throws Exception {
        BufferedImage src = ImageIO.read(new File(a[0]));
        String want = a[1];
        int W = Integer.parseInt(a[2]), H = Integer.parseInt(a[3]);
        String out = a[4];

        int sw = src.getWidth(), sh = src.getHeight();
        int[][] alpha = new int[sh][sw];
        for (int y = 0; y < sh; y++)
            for (int x = 0; x < sw; x++)
                alpha[y][x] = (src.getRGB(x, y) >>> 24) & 0xff;

        // Segment the source "16" into ordered glyph boxes on transparent columns.
        List<int[]> cols = new ArrayList<>();   // [x0,x1) runs that carry ink
        int start = -1;
        for (int x = 0; x < sw; x++) {
            int cmax = 0;
            for (int y = 0; y < sh; y++) cmax = Math.max(cmax, alpha[y][x]);
            boolean ink = cmax > 8;
            if (ink && start < 0) start = x;
            if (!ink && start >= 0) { cols.add(new int[]{start, x}); start = -1; }
        }
        if (start >= 0) cols.add(new int[]{start, sw});
        if (cols.size() < 2)
            throw new RuntimeException("expected two glyphs in " + a[0] + ", found " + cols.size());

        // Tighten each run vertically and record its box.
        List<Glyph> src16 = new ArrayList<>();
        for (int[] c : cols) src16.add(box(alpha, c[0], c[1]));
        // The '1' is the narrower of the two; keep them in reading order (already).
        Glyph one = src16.get(0), six = src16.get(1);
        Map<Character, Glyph> lib = new HashMap<>();
        lib.put('1', one);
        lib.put('6', six);

        // Common ink band and gap, taken from the source so proportions match.
        int inkTop = Math.min(one.y0, six.y0), inkBot = Math.max(one.y1, six.y1);
        int gap = Math.max(0, six.x0 - one.x1);
        int inkH = inkBot - inkTop;

        // Lay the wanted glyphs out left to right at 1:1 with the source into a
        // tight buffer; it is scaled to the canvas afterwards so 4-glyph strings
        // like "16.1" cannot overflow the way 1:1 placement would.
        List<Placed> placed = new ArrayList<>();
        int penW = 0;
        char prev = 0;
        for (char ch : want.toCharArray()) {
            if (penW > 0) penW += (ch == '.' || prev == '.') ? Math.round(gap * 0.55f) : gap;
            if (ch == '.') {
                int d = Math.round(inkH * 0.165f);            // dot diameter ~ stroke
                placed.add(new Placed('.', null, penW, inkH - d, d, d));
                penW += d;
            } else {
                Glyph g = lib.get(ch);
                if (g == null) throw new RuntimeException("no source glyph for '" + ch + "'");
                placed.add(new Placed(ch, g, penW, g.y0 - inkTop, g.w(), g.h()));
                penW += g.w();
            }
            prev = ch;
        }
        int totalW = Math.max(1, penW);

        // Tight cluster, ink band mapped to [0,inkH); gradient runs top to foot.
        BufferedImage tight = new BufferedImage(totalW, inkH, BufferedImage.TYPE_INT_ARGB);
        for (Placed p : placed) {
            if (p.ch == '.') {
                paintDot(tight, p.x, p.y, p.w, inkH);
            } else {
                for (int y = p.g.y0; y < p.g.y1; y++)
                    for (int x = p.g.x0; x < p.g.x1; x++) {
                        int cov = alpha[y][x];
                        if (cov == 0) continue;
                        int dx = p.x + (x - p.g.x0);
                        int dy = (y - inkTop);
                        blend(tight, dx, dy, gold(dy, 0, inkH), cov);
                    }
            }
        }

        // Scale the cluster to fit the canvas with stock-like breathing room,
        // then centre it. Bicubic keeps the soft edges soft.
        double s = Math.min(W * 0.94 / totalW, H * 0.90 / inkH);
        int dw = (int) Math.round(totalW * s), dh = (int) Math.round(inkH * s);
        BufferedImage dst = new BufferedImage(W, H, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = dst.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.drawImage(tight, (W - dw) / 2, (H - dh) / 2, dw, dh, null);
        g.dispose();

        ImageIO.write(dst, "png", new File(out));
        System.out.printf("wrote %s  %dx%d  \"%s\"  cluster %dx%d -> %dx%d%n",
                out, W, H, want, totalW, inkH, dw, dh);
    }

    static void paintDot(BufferedImage dst, int cx0, int top, int d, int inkH) {
        double r = d / 2.0, cx = cx0 + r, cy = top + r;
        int x0 = (int) Math.floor(cx - r) - 1, x1 = (int) Math.ceil(cx + r) + 1;
        int y0 = (int) Math.floor(cy - r) - 1, y1 = (int) Math.ceil(cy + r) + 1;
        for (int y = y0; y <= y1; y++)
            for (int x = x0; x <= x1; x++) {
                double dist = Math.hypot(x + 0.5 - cx, y + 0.5 - cy);
                double cov = Math.max(0, Math.min(1, r + 0.5 - dist));
                if (cov <= 0) continue;
                blend(dst, x, y, gold(y, 0, inkH), (int) Math.round(cov * 255));
            }
    }

    /** Vertical champagne-to-gold ramp over the ink band [inkTop,inkBot]. */
    static int gold(int y, int inkTop, int inkBot) {
        double t = inkBot == inkTop ? 0 : (y - inkTop) / (double) (inkBot - inkTop);
        t = Math.max(0, Math.min(1, t));
        t = t * t * (3 - 2 * t);                              // smoothstep
        Color c = t < 0.5 ? lerp(TOP, MID, t / 0.5) : lerp(MID, BOT, (t - 0.5) / 0.5);
        return (c.getRed() << 16) | (c.getGreen() << 8) | c.getBlue();
    }

    static Color lerp(Color a, Color b, double t) {
        return new Color(
            (int) Math.round(a.getRed()   + (b.getRed()   - a.getRed())   * t),
            (int) Math.round(a.getGreen() + (b.getGreen() - a.getGreen()) * t),
            (int) Math.round(a.getBlue()  + (b.getBlue()  - a.getBlue())  * t));
    }

    static void blend(BufferedImage im, int x, int y, int rgb, int cov) {
        if (x < 0 || y < 0 || x >= im.getWidth() || y >= im.getHeight() || cov <= 0) return;
        int prev = im.getRGB(x, y);
        int pa = (prev >>> 24) & 0xff;
        if (cov >= pa) im.setRGB(x, y, (cov << 24) | (rgb & 0xffffff));  // opaque-over-empty is the norm
    }

    static Glyph box(int[][] alpha, int x0, int x1) {
        int h = alpha.length;
        int top = h, bot = -1, left = x1, right = x0;
        for (int y = 0; y < h; y++)
            for (int x = x0; x < x1; x++)
                if (alpha[y][x] > 8) {
                    if (y < top) top = y;
                    if (y > bot) bot = y;
                    if (x < left) left = x;
                    if (x > right) right = x;
                }
        return new Glyph(left, top, right + 1, bot + 1);
    }

    static class Glyph {
        int x0, y0, x1, y1;
        Glyph(int x0, int y0, int x1, int y1) { this.x0 = x0; this.y0 = y0; this.x1 = x1; this.y1 = y1; }
        int w() { return x1 - x0; } int h() { return y1 - y0; }
    }
    static class Placed {
        char ch; Glyph g; int x, y, w, h;
        Placed(char ch, Glyph g, int x, int y, int w, int h) { this.ch = ch; this.g = g; this.x = x; this.y = y; this.w = w; this.h = h; }
    }
}

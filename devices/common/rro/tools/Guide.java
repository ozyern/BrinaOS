import java.awt.*;
import java.awt.image.*;
import java.io.*;
import javax.imageio.ImageIO;

/**
 * Draws the setup wizard's welcome background.
 *
 * com.coloros.bootreg puts ic_bg_guide_page behind the whole first page and
 * writes "Hello" over it in @color/Black, so whatever goes here has to stay
 * light: the page has no scrim and no text shadow. This keeps a champagne
 * gradient as the base, washes the photo in across the top at low opacity and
 * fades it out well above the text, and sets the crest underneath as a
 * watermark.
 *
 *   java Guide.java <photo.jpg> <crest.png> <out.png> <w> <h>
 */
public class Guide {

    static final int TOP = 0xFDF7ED, MID = 0xF8ECD9, BOT = 0xEFDCBE;
    static final double PHOTO_ALPHA = 0.34;   // at the very top, ramping to 0
    static final double PHOTO_FADE = 0.50;    // fully gone by here, above the text
    static final double CREST_ALPHA = 0.13;

    // The photo's backdrop is a cool grey, and a low-opacity wash of it over
    // cream just reads as dirt. Lifting it towards the paper colour first keeps
    // the wash warm, so it looks like the page is printed on her rather than
    // like the render went wrong.
    static final int PAPER = 0xFFF6E6;
    static final double LIFT = 0.46;

    public static void main(String[] a) throws Exception {
        BufferedImage photo = ImageIO.read(new File(a[0]));
        BufferedImage crest = ImageIO.read(new File(a[1]));
        String out = a[2];
        int W = Integer.parseInt(a[3]), H = Integer.parseInt(a[4]);

        BufferedImage img = new BufferedImage(W, H, BufferedImage.TYPE_INT_RGB);
        for (int y = 0; y < H; y++) {
            double t = (double) y / (H - 1);
            int c = t < 0.5 ? mix(TOP, MID, t / 0.5) : mix(MID, BOT, (t - 0.5) / 0.5);
            for (int x = 0; x < W; x++) img.setRGB(x, y, c);
        }

        // Photo across the top, cover-cropped, faded out before the copy starts.
        int band = (int) (H * PHOTO_FADE) + 1;
        BufferedImage cover = cover(photo, W, band);
        for (int y = 0; y < band; y++) {
            double k = PHOTO_ALPHA * smooth(1 - (double) y / band);
            for (int x = 0; x < W; x++)
                img.setRGB(x, y, blend(img.getRGB(x, y), mix(cover.getRGB(x, y), PAPER, LIFT), k));
        }

        // Crest watermark. The artwork is gold on black with no alpha, so its own
        // brightness is the mask.
        int cw = (int) (W * 0.56);
        int ch = (int) (cw * (double) crest.getHeight() / crest.getWidth());
        BufferedImage cr = scale(crest, cw, ch);
        int cx = (W - cw) / 2, cy = (int) (H * 0.63);
        for (int y = 0; y < ch; y++) {
            int dy = cy + y;
            if (dy < 0 || dy >= H) continue;
            for (int x = 0; x < cw; x++) {
                int p = cr.getRGB(x, y);
                int m = Math.max((p >> 16) & 255, Math.max((p >> 8) & 255, p & 255));
                if (m == 0) continue;
                int lit = (((p >> 16) & 255) * 255 / m) << 16
                        | (((p >> 8) & 255) * 255 / m) << 8
                        | ((p & 255) * 255 / m);
                img.setRGB(cx + x, dy, blend(img.getRGB(cx + x, dy), lit, CREST_ALPHA * m / 255.0));
            }
        }

        ImageIO.write(img, "png", new File(out));
        System.out.println("wrote " + out + "  " + W + "x" + H);
    }

    static int mix(int a, int b, double t) {
        return chan(a, 16, b, t) << 16 | chan(a, 8, b, t) << 8 | chan(a, 0, b, t);
    }

    static int chan(int a, int sh, int b, double t) {
        int x = (a >> sh) & 255, y = (b >> sh) & 255;
        return (int) (x + (y - x) * t + 0.5);
    }

    static int blend(int dst, int src, double k) {
        if (k <= 0) return dst;
        if (k > 1) k = 1;
        return mix(dst, src, k);
    }

    static double smooth(double t) {
        t = t < 0 ? 0 : t > 1 ? 1 : t;
        return t * t * (3 - 2 * t);
    }

    /** Centre-cropped fill, so the photo keeps its aspect inside the band. */
    static BufferedImage cover(BufferedImage src, int w, int h) {
        double s = Math.max(w / (double) src.getWidth(), h / (double) src.getHeight());
        int sw = (int) Math.ceil(src.getWidth() * s), sh = (int) Math.ceil(src.getHeight() * s);
        BufferedImage big = scale(src, sw, sh);
        return big.getSubimage(Math.max(0, (sw - w) / 2), Math.max(0, (sh - h) / 2), w, h);
    }

    static BufferedImage scale(BufferedImage in, int w, int h) {
        while (in.getWidth() / 2 > w && in.getHeight() / 2 > h)
            in = step(in, in.getWidth() / 2, in.getHeight() / 2);
        return step(in, w, h);
    }

    static BufferedImage step(BufferedImage in, int w, int h) {
        BufferedImage o = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = o.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.drawImage(in, 0, 0, w, h, null);
        g.dispose();
        return o;
    }
}

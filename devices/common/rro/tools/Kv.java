import javax.imageio.*;
import javax.imageio.stream.*;
import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.util.Iterator;

/**
 * Builds the Software update key visual.
 *
 * The KV ImageView in res/layout/logo_area.xml is a fixed 600dp x 503dp with
 * scaleType centerCrop, sitting in a COUICardView that the parent squeezes down
 * to the card width - 312dp on a phone. The ImageView keeps its 600dp and the
 * card clips it, so only the middle 312/600 = 52% of the artwork is ever on
 * screen. Stock is 1800x1509, exactly 600x503dp at 3x, which is why stock looks
 * 1:1 with its middle half showing.
 *
 * A replacement that is only as wide as the visible window is therefore wrong:
 * centerCrop blows it up to 600dp first, and the card then shows the middle half
 * of that - a ~1.9x zoom. So the canvas has to be the full 1800x1509 with the
 * photo framed inside the middle `window` pixels, and the margins filled with a
 * blurred, darkened continuation for the wider layouts where more of it shows.
 *
 *   java Kv.java <src> <out> <canvasW> <canvasH> <windowW> <bias> [quality] [scrim]
 *
 * bias is the horizontal focus of the crop, 0 = left edge, 1 = right edge; the
 * photo is taller than the window is, so its full height is always kept.
 */
public class Kv {
    public static void main(String[] a) throws Exception {
        BufferedImage src = ImageIO.read(new File(a[0]));
        String out = a[1];
        int W = Integer.parseInt(a[2]), H = Integer.parseInt(a[3]);
        int win = Integer.parseInt(a[4]);
        double bias = Double.parseDouble(a[5]);
        double q = a.length > 6 ? Double.parseDouble(a[6]) : 0.86;
        String scrim = a.length > 7 ? a[7] : "none";

        System.out.printf("src %dx%d -> canvas %dx%d, visible window %d wide%n",
                src.getWidth(), src.getHeight(), W, H, win);

        BufferedImage dst = new BufferedImage(W, H, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = dst.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);

        // Margins first: the photo covering the whole canvas, blurred and pulled
        // down, so the parts the card clips away are a soft continuation rather
        // than a hard edge on a layout that shows more of them.
        drawCover(g, blur(darken(src, 0.55), 24), 0, 0, W, H, 0.5);

        // Then the photo itself, covering only the window the card actually shows.
        int wx = (W - win) / 2;
        drawCover(g, src, wx, 0, win, H, bias);
        g.dispose();

        if (!scrim.equalsIgnoreCase("none")) {
            applyScrim(dst, scrim);
            System.out.println("scrim " + scrim);
        }

        Iterator<ImageWriter> it = ImageIO.getImageWritersByFormatName("jpeg");
        ImageWriter w = it.next();
        ImageWriteParam p = w.getDefaultWriteParam();
        p.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
        p.setCompressionQuality((float) q);
        try (ImageOutputStream os = ImageIO.createImageOutputStream(new File(out))) {
            w.setOutput(os);
            w.write(null, new IIOImage(dst, null, null), p);
        }
        w.dispose();
        System.out.println("wrote " + out + " " + new File(out).length() + " bytes");
    }

    /** centerCrop, with the crop biased along whichever axis has slack. */
    static void drawCover(Graphics2D g, BufferedImage im, int x, int y, int w, int h, double bias) {
        double s = Math.max(w / (double) im.getWidth(), h / (double) im.getHeight());
        int sw = (int) Math.ceil(im.getWidth() * s), sh = (int) Math.ceil(im.getHeight() * s);
        int dx = (int) Math.round((sw - w) * bias), dy = (int) Math.round((sh - h) * bias);
        Shape clip = g.getClip();
        g.setClip(x, y, w, h);
        g.drawImage(im, x - dx, y - dy, sw, sh, null);
        g.setClip(clip);
    }

    static BufferedImage darken(BufferedImage im, double k) {
        BufferedImage o = new BufferedImage(im.getWidth(), im.getHeight(), BufferedImage.TYPE_INT_RGB);
        for (int y = 0; y < im.getHeight(); y++)
            for (int x = 0; x < im.getWidth(); x++) {
                int c = im.getRGB(x, y);
                o.setRGB(x, y, ((int) (((c >> 16) & 0xff) * k) << 16)
                             | ((int) (((c >> 8) & 0xff) * k) << 8)
                             |  (int) ((c & 0xff) * k));
            }
        return o;
    }

    /** Box blur, done on a downscaled copy - the margins only ever show soft. */
    static BufferedImage blur(BufferedImage im, int radius) {
        int w = Math.max(1, im.getWidth() / 8), h = Math.max(1, im.getHeight() / 8);
        BufferedImage small = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = small.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.drawImage(im, 0, 0, w, h, null);
        g.dispose();
        int r = Math.max(1, radius / 8);
        for (int pass = 0; pass < 3; pass++) small = box(small, r);
        return small;
    }

    static BufferedImage box(BufferedImage im, int r) {
        int w = im.getWidth(), h = im.getHeight();
        BufferedImage o = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++) {
                int sr = 0, sg = 0, sb = 0, n = 0;
                for (int j = Math.max(0, y - r); j <= Math.min(h - 1, y + r); j++)
                    for (int i = Math.max(0, x - r); i <= Math.min(w - 1, x + r); i++) {
                        int c = im.getRGB(i, j);
                        sr += (c >> 16) & 0xff; sg += (c >> 8) & 0xff; sb += c & 0xff; n++;
                    }
                o.setRGB(x, y, ((sr / n) << 16) | ((sg / n) << 8) | (sb / n));
            }
        return o;
    }

    /** Multiplies each row towards black by the alpha interpolated from the stops. */
    static void applyScrim(BufferedImage im, String spec) {
        String[] parts = spec.split(",");
        double[] ys = new double[parts.length], as = new double[parts.length];
        for (int i = 0; i < parts.length; i++) {
            String[] kv = parts[i].split(":");
            ys[i] = Double.parseDouble(kv[0]);
            as[i] = Double.parseDouble(kv[1]);
        }
        int h = im.getHeight(), w = im.getWidth();
        for (int row = 0; row < h; row++) {
            double t = h == 1 ? 0 : (double) row / (h - 1);
            double k = 1 - interp(ys, as, t);
            for (int col = 0; col < w; col++) {
                int c = im.getRGB(col, row);
                im.setRGB(col, row, ((int) (((c >> 16) & 0xff) * k) << 16)
                                  | ((int) (((c >> 8) & 0xff) * k) << 8)
                                  |  (int) ((c & 0xff) * k));
            }
        }
    }

    static double interp(double[] ys, double[] as, double t) {
        if (t <= ys[0]) return as[0];
        if (t >= ys[ys.length - 1]) return as[as.length - 1];
        for (int i = 0; i + 1 < ys.length; i++) {
            if (t >= ys[i] && t <= ys[i + 1]) {
                double span = ys[i + 1] - ys[i];
                double f = span == 0 ? 0 : (t - ys[i]) / span;
                f = f * f * (3 - 2 * f);            // smoothstep, no banding edge
                return as[i] + (as[i + 1] - as[i]) * f;
            }
        }
        return as[as.length - 1];
    }
}

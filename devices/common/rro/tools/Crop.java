import javax.imageio.*;
import javax.imageio.stream.*;
import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.util.Iterator;

/**
 * Crops a photo to the aspect the About device / OTA card wants and, optionally,
 * lays a vertical scrim over it.
 *
 * Settings draws the card art edge to edge and puts the device name, the OS
 * logotype, the version and the update button straight on top of it with no
 * shadow, so a bright photo leaves that text unreadable. The scrim is a black
 * gradient described by "y:alpha" stops, e.g.
 *
 *     0:0.42,0.62:0.16,0.80:0.10,1:0.34
 *
 * meaning 42% black at the top of the card, easing to 16% at 62% of its height,
 * 10% at 80% and back up to 34% at the bottom - dark enough behind the text at
 * the top and the button at the bottom, near enough to nothing across the middle
 * that the picture still reads. Pass "none" to leave the photo alone.
 *
 * Usage:
 *   java Crop.java <src>
 *   java Crop.java <src> <out> <W> <H> <bias> [quality] [scrim]
 *
 * bias is the vertical focus of the crop, 0 = top edge, 1 = bottom edge.
 */
public class Crop {
    public static void main(String[] a) throws Exception {
        BufferedImage src = ImageIO.read(new File(a[0]));
        System.out.println("src " + src.getWidth() + "x" + src.getHeight());
        if (a.length == 1) return;
        String out = a[1];
        int W = Integer.parseInt(a[2]), H = Integer.parseInt(a[3]);
        double bias = Double.parseDouble(a[4]);           // vertical focus 0..1
        double q = a.length > 5 ? Double.parseDouble(a[5]) : 0.92;
        String scrim = a.length > 6 ? a[6] : "none";

        double want = (double) W / H;
        int cw = src.getWidth(), ch = (int) Math.round(cw / want);
        if (ch > src.getHeight()) { ch = src.getHeight(); cw = (int) Math.round(ch * want); }
        int x = (src.getWidth() - cw) / 2;
        int y = (int) Math.round(src.getHeight() * bias - ch / 2.0);
        y = Math.max(0, Math.min(src.getHeight() - ch, y));
        System.out.println("crop " + cw + "x" + ch + " @ " + x + "," + y);

        BufferedImage dst = new BufferedImage(W, H, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = dst.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.drawImage(src.getSubimage(x, y, cw, ch), 0, 0, W, H, null);
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
            double alpha = interp(ys, as, t);
            double k = 1 - alpha;
            for (int col = 0; col < w; col++) {
                int c = im.getRGB(col, row);
                int r  = (int) (((c >> 16) & 0xff) * k);
                int gg = (int) (((c >> 8) & 0xff) * k);
                int b  = (int) ((c & 0xff) * k);
                im.setRGB(col, row, (r << 16) | (gg << 8) | b);
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

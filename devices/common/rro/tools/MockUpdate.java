import java.awt.*;
import java.awt.image.*;
import java.io.*;
import javax.imageio.ImageIO;

/**
 * Composites the Software update card the way com.oplus.ota lays it out, so a
 * new background can be judged before flashing.
 *
 * Geometry is read off res/layout/logo_area.xml: the KV ImageView is a fixed
 * 600dp x 503dp centerCrop inside a card the parent squeezes to 312dp, so the
 * card clips the artwork to its middle 312/600 = 52%. The block of version
 * number + wordmark + device name starts 106dp down, the version image is 100dp
 * tall, the wordmark 23dp with an 8dp gap, the device name 13dp with a 7dp gap,
 * and the status line sits 32dp off the bottom. At 3px per dp that is a
 * 936x1509 window onto 1800x1509 of artwork.
 *
 *   java MockUpdate.java <card.jpg> <wordmark.png> <out.png> [windowW]
 */
public class MockUpdate {
    static final double PX = 3.0;

    public static void main(String[] a) throws Exception {
        BufferedImage art = ImageIO.read(new File(a[0]));
        BufferedImage logo = ImageIO.read(new File(a[1]));
        String out = a[2];
        int win = a.length > 3 ? Integer.parseInt(a[3]) : art.getWidth();
        win = Math.min(win, art.getWidth());

        // what the card actually shows: the middle `win` columns of the artwork
        BufferedImage card = art.getSubimage((art.getWidth() - win) / 2, 0, win, art.getHeight());

        BufferedImage img = new BufferedImage(card.getWidth(), card.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.drawImage(card, 0, 0, null);

        Font f = Font.createFont(Font.TRUETYPE_FONT,
                new File("build/portrom/images/system/system/fonts/OPSans-En-Regular.ttf"));
        int W = img.getWidth();

        // iv_version_logo: the "16" artwork, 100dp tall, centreInside. Stock kv_16_1
        // is 441x396, so it lands 111dp wide. Drawn here as the number itself.
        double y = 106;
        g.setFont(f.deriveFont(Font.BOLD, (float) (118 * PX)));
        g.setColor(new Color(0xF5DFA8));
        FontMetrics fm = g.getFontMetrics();
        g.drawString("16", (W - fm.stringWidth("16")) / 2, (int) ((y + 88) * PX));
        y += 100;

        // card_logo: the OS wordmark, 23dp tall with an 8dp gap above.
        y += 8;
        double lh = 23 * PX, lw = logo.getWidth() * lh / logo.getHeight();
        g.drawImage(logo, (int) ((W - lw) / 2), (int) (y * PX), (int) lw, (int) lh, null);
        y += 23;

        // the device name, 13dp with a 7dp gap.
        y += 7;
        g.setColor(new Color(255, 255, 255, 230));
        drawCentred(g, f.deriveFont((float) (13 * PX)), "OnePlus 9 Pro", W, y);

        // the status line, 18dp, sitting 32dp off the bottom of the card.
        g.setColor(Color.WHITE);
        drawCentred(g, f.deriveFont((float) (18 * PX)), "Version up to date", W,
                    img.getHeight() / PX - 32 - 26);

        g.dispose();
        ImageIO.write(img, "png", new File(out));
        System.out.printf("wrote %s  (%dx%d window onto %dx%d of artwork)%n",
                out, card.getWidth(), card.getHeight(), art.getWidth(), art.getHeight());
    }

    static void drawCentred(Graphics2D g, Font f, String s, int w, double topDp) {
        g.setFont(f);
        FontMetrics fm = g.getFontMetrics();
        g.drawString(s, (w - fm.stringWidth(s)) / 2, (int) (topDp * PX) + fm.getAscent());
    }
}

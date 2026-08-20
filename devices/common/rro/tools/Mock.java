import java.awt.*;
import java.awt.geom.*;
import java.awt.image.*;
import java.io.*;
import java.nio.file.*;
import javax.imageio.ImageIO;

/**
 * Composites the About device card the way Settings lays it out, so the artwork
 * and the text colours can be judged before flashing anything.
 *
 * Geometry comes straight out of res/layout/about_device_ota_item.xml and the
 * dimens it references: the card is about_device_ota_item_height = 280dp tall and
 * the 984x840 asset is therefore 3px per dp.
 *
 *   java Mock.java <card.jpg> <logo.xml-pathdata-width> <textColor> <out.png>
 */
public class Mock {
    static final double PX = 3.0;             // px per dp in the 984x840 asset
    static final String FONT =                // whatever Settings would use for the labels
            "build/portrom/images/system/system/fonts/OPSans-En-Regular.ttf";

    public static void main(String[] a) throws Exception {
        BufferedImage card = ImageIO.read(new File(a[0]));
        String logoXml = a[1];
        Color textColor = Color.decode(a[2]);
        String out = a[3];

        BufferedImage img = new BufferedImage(card.getWidth(), card.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        g.drawImage(card, 0, 0, null);

        Font f = Font.createFont(Font.TRUETYPE_FONT,
                new File(FONT));
        g.setColor(textColor);

        // outer LinearLayout marginTop 42dp, device name 16dp
        double y = 42;
        drawCentred(g, f.deriveFont((float) (16 * PX)), "OnePlus 9 Pro", img.getWidth(), y);
        y += 19;                                   // one 16dp line

        // inner LinearLayout marginTop @about_device_logo_margin_top = 30dp
        y += 30;
        drawLogo(g, logoXml, img.getWidth(), y);
        y += 34;                                   // logo ImageView height

        // version row: LinearLayout marginTop 4dp, TextView marginTop 4dp, 16dp
        y += 8;
        drawCentred(g, f.deriveFont((float) (16 * PX)), "16.0.9", img.getWidth(), y);
        y += 19;

        // "Version up to date": marginTop 47dp, height 44dp, 18dp text
        y += 47;
        drawCentred(g, f.deriveFont((float) (18 * PX)), "Version up to date", img.getWidth(), y + 12);

        g.dispose();
        ImageIO.write(img, "png", new File(out));
        System.out.println("wrote " + out);
    }

    static void drawCentred(Graphics2D g, Font f, String s, int w, double topDp) {
        g.setFont(f);
        FontMetrics fm = g.getFontMetrics();
        int x = (w - fm.stringWidth(s)) / 2;
        g.drawString(s, x, (int) (topDp * PX) + fm.getAscent());
    }

    /** Pulls the single pathData out of a generated vector and draws it at 34dp. */
    static void drawLogo(Graphics2D g, String xml, int w, double topDp) throws Exception {
        String src = new String(Files.readAllBytes(Paths.get(xml)), "UTF-8");
        String vw = between(src, "android:viewportWidth=\"", "\"");
        String d = between(src, "android:pathData=\"", "\"");
        Path2D.Double p = parse(d);
        double scale = 34 * PX / 34.0;
        double width = Double.parseDouble(vw) * scale;
        AffineTransform t = AffineTransform.getTranslateInstance((w - width) / 2, topDp * PX);
        t.scale(scale, scale);
        Shape s = t.createTransformedShape(p);
        g.fill(s);
    }

    static String between(String s, String a, String b) {
        int i = s.indexOf(a) + a.length();
        return s.substring(i, s.indexOf(b, i));
    }

    static class P {
        int i = 0; String s;
        P(String s){ this.s = s; }
        void ws(){ while (i < s.length() && (s.charAt(i)==' '||s.charAt(i)==','||s.charAt(i)=='\t'||s.charAt(i)=='\n')) i++; }
        boolean more(){ ws(); return i < s.length(); }
        boolean cmd(){ ws(); return i < s.length() && Character.isLetter(s.charAt(i)); }
        double num(){
            ws();
            int st = i;
            if (i < s.length() && (s.charAt(i)=='-'||s.charAt(i)=='+')) i++;
            while (i < s.length() && (Character.isDigit(s.charAt(i))||s.charAt(i)=='.')) i++;
            if (i < s.length() && (s.charAt(i)=='e'||s.charAt(i)=='E')) { i++; if (s.charAt(i)=='-'||s.charAt(i)=='+') i++;
                while (i < s.length() && Character.isDigit(s.charAt(i))) i++; }
            return Double.parseDouble(s.substring(st, i));
        }
    }

    static Path2D.Double parse(String d) {
        Path2D.Double p = new Path2D.Double();
        P t = new P(d);
        double cx = 0, cy = 0, sx = 0, sy = 0, px = 0, py = 0;
        char last = 0;
        while (t.more()) {
            char c;
            if (t.cmd()) { c = t.s.charAt(t.i++); } else { c = (last=='M') ? 'L' : (last=='m' ? 'l' : last); }
            boolean rel = Character.isLowerCase(c);
            char C = Character.toUpperCase(c);
            switch (C) {
                case 'M': { double x=t.num(), y=t.num(); if(rel){x+=cx;y+=cy;} p.moveTo(x,y); cx=sx=x; cy=sy=y; px=x; py=y; break; }
                case 'L': { double x=t.num(), y=t.num(); if(rel){x+=cx;y+=cy;} p.lineTo(x,y); cx=x; cy=y; px=x; py=y; break; }
                case 'H': { double x=t.num(); if(rel)x+=cx; p.lineTo(x,cy); cx=x; px=cx; py=cy; break; }
                case 'V': { double y=t.num(); if(rel)y+=cy; p.lineTo(cx,y); cy=y; px=cx; py=cy; break; }
                case 'C': { double x1=t.num(),y1=t.num(),x2=t.num(),y2=t.num(),x=t.num(),y=t.num();
                            if(rel){x1+=cx;y1+=cy;x2+=cx;y2+=cy;x+=cx;y+=cy;}
                            p.curveTo(x1,y1,x2,y2,x,y); px=x2; py=y2; cx=x; cy=y; break; }
                case 'S': { double x2=t.num(),y2=t.num(),x=t.num(),y=t.num();
                            if(rel){x2+=cx;y2+=cy;x+=cx;y+=cy;}
                            double x1=2*cx-px, y1=2*cy-py;
                            p.curveTo(x1,y1,x2,y2,x,y); px=x2; py=y2; cx=x; cy=y; break; }
                case 'Q': { double x1=t.num(),y1=t.num(),x=t.num(),y=t.num();
                            if(rel){x1+=cx;y1+=cy;x+=cx;y+=cy;}
                            p.quadTo(x1,y1,x,y); px=x1; py=y1; cx=x; cy=y; break; }
                case 'T': { double x=t.num(),y=t.num(); if(rel){x+=cx;y+=cy;}
                            double x1=2*cx-px, y1=2*cy-py;
                            p.quadTo(x1,y1,x,y); px=x1; py=y1; cx=x; cy=y; break; }
                case 'Z': { p.closePath(); cx=sx; cy=sy; px=cx; py=cy; break; }
                default: throw new RuntimeException("cmd " + c);
            }
            last = c;
        }
        p.setWindingRule(Path2D.WIND_EVEN_ODD);
        return p;
    }

}

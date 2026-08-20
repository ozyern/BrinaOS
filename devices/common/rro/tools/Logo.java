import java.awt.*;
import java.awt.geom.*;
import java.awt.image.*;
import java.io.*;
import java.nio.file.*;
import javax.imageio.ImageIO;

/**
 * Renders a wordmark vector produced by Brand.java into a transparent PNG.
 *
 * The Software update app keeps its OS logotype as a bitmap rather than a
 * vector, so the About-page wordmark has to be rasterised to replace it. Canvas
 * size and ink height are given explicitly so the replacement keeps the stock
 * intrinsic size - the ImageView is wrap_content with centerInside, so changing
 * the intrinsic size changes the layout around it.
 *
 *   java Logo.java <wordmark.xml> <canvasW> <canvasH> <inkH> <#RRGGBB> <out.png>
 */
public class Logo {
    public static void main(String[] a) throws Exception {
        String xml = a[0];
        int cw = Integer.parseInt(a[1]), ch = Integer.parseInt(a[2]);
        double inkH = Double.parseDouble(a[3]);
        Color color = Color.decode(a[4]);
        String out = a[5];

        String src = new String(Files.readAllBytes(Paths.get(xml)), "UTF-8");
        double vw = Double.parseDouble(between(src, "android:viewportWidth=\"", "\""));
        double vh = Double.parseDouble(between(src, "android:viewportHeight=\"", "\""));
        Path2D.Double p = parse(between(src, "android:pathData=\"", "\""));

        // The vector viewport is the wordmark box; scale it so the ink is inkH tall.
        double scale = inkH / vh;
        double w = vw * scale;
        BufferedImage img = new BufferedImage(cw, ch, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        AffineTransform t = AffineTransform.getTranslateInstance((cw - w) / 2, (ch - inkH) / 2);
        t.scale(scale, scale);
        g.setColor(color);
        g.fill(t.createTransformedShape(p));
        g.dispose();
        ImageIO.write(img, "png", new File(out));
        System.out.printf("wrote %s  %dx%d, ink %.0fx%.0f%n", out, cw, ch, w, inkH);
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

import java.awt.*;
import java.awt.geom.*;
import java.awt.image.*;
import java.io.*;
import java.nio.file.*;
import javax.imageio.ImageIO;

/**
 * Draws the mobile status bar cluster the way SystemUI stacks it, so the fixed
 * data-type inset can be checked without flashing.
 *
 * mobile_signal and mobile_type share one FrameLayout, both wrap_content and
 * both layout_gravity="end|center_vertical", so each drawable is right-aligned
 * inside a container as wide as the widest of them.
 *
 *   java Compose.java <bars.txt> <type.txt> <out.png>
 *
 * where each .txt is: viewportW viewportH widthDp heightDp insetRightDp pathData
 */
public class Compose {
    static final int SCALE = 14;

    public static void main(String[] a) throws Exception {
        String[] bars = Files.readAllLines(Paths.get(a[0])).toArray(new String[0]);
        String[] type = Files.readAllLines(Paths.get(a[1])).toArray(new String[0]);

        double barsTotal = Double.parseDouble(bars[2]) + Double.parseDouble(bars[4]);
        double typeTotal = Double.parseDouble(type[2]) + Double.parseDouble(type[4]);
        double container = Math.max(barsTotal, typeTotal);
        double height = 18;                       // status_bar_mobile_container_height

        System.out.printf("bars %.2fdp, type %.2fdp, container %.2fdp%n", barsTotal, typeTotal, container);

        BufferedImage img = new BufferedImage((int) (container * SCALE), (int) (height * SCALE),
                                              BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setColor(new Color(18, 18, 22));
        g.fillRect(0, 0, img.getWidth(), img.getHeight());

        draw(g, type, container, height, new Color(0xFF6E6E));   // red so a collision is obvious
        draw(g, bars, container, height, Color.WHITE);

        g.dispose();
        ImageIO.write(img, "png", new File(a[2]));
        System.out.println("wrote " + a[2]);
    }

    static void draw(Graphics2D g, String[] d, double container, double height, Color c) {
        double vw = Double.parseDouble(d[0]), vh = Double.parseDouble(d[1]);
        double w = Double.parseDouble(d[2]), h = Double.parseDouble(d[3]);
        double inset = Double.parseDouble(d[4]);
        double total = w + inset;
        double x = container - total;             // end gravity
        double y = (height - h) / 2;              // center_vertical
        AffineTransform t = AffineTransform.getScaleInstance(SCALE, SCALE);
        t.translate(x, y);
        t.scale(w / vw, h / vh);
        g.setColor(c);
        g.fill(t.createTransformedShape(parse(d[5])));
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

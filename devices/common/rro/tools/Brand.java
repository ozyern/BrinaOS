import java.awt.*;
import java.awt.geom.*;
import java.awt.image.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.List;
import javax.imageio.ImageIO;

/**
 * Draws the "BrinaOS" logotype in the ColorOS letterforms.
 *
 * The ColorOS wordmark inside Settings is a vector drawable, so its outlines are
 * the font, exactly as the type designer drew them. r, O and S are lifted from it
 * unchanged; B, i, n and a do not appear in "ColorOS" and are constructed here out
 * of the same primitives - the stem width, ring weight, circle radii, x-height,
 * cap height and baseline are all measured off the stock paths (see MEASURED).
 */
public class Brand {

    // MEASURED off res/drawable/brand_logo_16_1.xml, 165x34 viewport
    static final double BASELINE   = 32.21;   // flat feet of l and r
    static final double CAP_TOP    = 1.03;    // flat top of l
    static final double ROUND_TOP  = 9.20;    // top of o: x-height plus overshoot
    static final double O_W        = 23.69;   // o outer width
    static final double O_IN_W     = 14.30;   // o counter width
    static final double RING       = (O_W - O_IN_W) / 2;   // 4.695
    static final double STEM       = 4.98;    // width of l
    static final double O_MID      = 21.135;  // vertical centre of o

    // Flat x-height: the round letters overshoot it, so it sits a touch below
    // the top of o rather than on it.
    static final double X_TOP      = 9.65;

    public static void main(String[] args) throws Exception {
        List<Path2D.Double> paths = new ArrayList<>();
        for (String l : Files.readAllLines(Paths.get(args[0]))) {
            l = l.trim();
            if (l.startsWith("\"")) l = l.substring(1);
            if (l.endsWith("\"")) l = l.substring(0, l.length() - 1);
            if (!l.isEmpty()) paths.add(parse(l));
        }
        paths.sort(Comparator.comparingDouble(p -> p.getBounds2D().getMinX()));
        // C o l o r O S
        Area o = new Area(paths.get(1));
        Area r = new Area(paths.get(4));
        Area O = new Area(paths.get(5));
        Area S = new Area(paths.get(6));

        String text   = args.length > 1 ? args[1] : "BrinaOS";
        String color  = args.length > 2 ? args[2] : "#FFFFFFFF";
        String outXml = args.length > 3 ? args[3] : null;
        String outPng = args.length > 4 ? args[4] : null;

        Map<Character, Area> glyphs = new HashMap<>();
        glyphs.put('r', at0(r));
        glyphs.put('O', at0(O));
        glyphs.put('S', at0(S));
        glyphs.put('o', at0(o));
        glyphs.put('B', buildB());
        glyphs.put('i', buildI());
        glyphs.put('n', buildN());
        glyphs.put('a', buildA(at0(o)));

        // Side bearings, keyed on what meets what. The stock gaps are
        // round-round 1.71..2.31 and stem-round 3.43..3.45.
        Map<String, Double> gap = new HashMap<>();
        gap.put("Br", 3.20); gap.put("ri", 2.80); gap.put("in", 4.00);
        gap.put("na", 3.40); gap.put("aO", 3.40); gap.put("OS", 1.71);

        Area all = new Area();
        double x = 0;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            Area g = glyphs.get(c);
            if (g == null) throw new RuntimeException("no glyph for " + c);
            all.add(g.createTransformedArea(AffineTransform.getTranslateInstance(x, 0)));
            x += g.getBounds2D().getWidth();
            if (i + 1 < text.length()) {
                x += gap.getOrDefault("" + c + text.charAt(i + 1), 3.0);
            }
        }
        double vw = Math.ceil(x * 100) / 100.0;
        System.out.printf("natural width = %.2f%n", x);

        if (outXml != null) writeVector(all, vw, color, outXml);
        if (outPng != null) preview(all, vw, outPng);
    }

    static Area at0(Area a) {
        Rectangle2D b = a.getBounds2D();
        return a.createTransformedArea(AffineTransform.getTranslateInstance(-b.getMinX(), 0));
    }

    /** Top half of an ellipse, i.e. an arch. */
    static Area arch(double x, double y, double w, double h) {
        Area a = new Area(new Ellipse2D.Double(x, y, w, h));
        a.intersect(new Area(new Rectangle2D.Double(x, y, w, h / 2)));
        return a;
    }

    /** A "D": flat on the left, semicircular on the right. */
    static Area dee(double x, double y, double right, double h) {
        double rx = h / 2;
        Area a = new Area(new Rectangle2D.Double(x, y, right - rx - x, h));
        a.add(new Area(new Ellipse2D.Double(right - 2 * rx, y, 2 * rx, h)));
        return a;
    }

    /** B: the l stem carrying two bowls, the lower one slightly wider as usual. */
    static Area buildB() {
        double top = CAP_TOP, bot = BASELINE;
        double joinLo = 15.60, joinHi = 16.90;          // the bowls overlap at the waist
        Area a = new Area(new Rectangle2D.Double(0, top, STEM, bot - top));
        a.add(dee(0, top, 19.40, joinHi - top));
        a.add(dee(0, joinLo, 21.00, bot - joinLo));
        Area counters = new Area(dee(STEM, top + RING, 19.40 - RING, (joinHi - top) - 2 * RING));
        counters.add(dee(STEM, joinLo + RING, 21.00 - RING, (bot - joinLo) - 2 * RING));
        a.subtract(counters);
        return a;
    }

    /** i: the l stem cut to the x-height, with a round dot on top. */
    static Area buildI() {
        Area a = new Area(new Rectangle2D.Double(0, X_TOP, STEM, BASELINE - X_TOP));
        double d = 5.60;
        a.add(new Area(new Ellipse2D.Double((STEM - d) / 2, 1.60, d, d)));
        return a;
    }

    /** n: the o arch standing on two stems. */
    static Area buildN() {
        double w = O_W;
        Area outer = arch(0, ROUND_TOP, w, 2 * (O_MID - ROUND_TOP));
        outer.add(new Area(new Rectangle2D.Double(0, O_MID, w, BASELINE - O_MID)));
        double s = 4.85;                                  // between RING and STEM
        Area inner = arch(s, ROUND_TOP + RING, w - 2 * s, 2 * (O_MID - ROUND_TOP - RING));
        inner.add(new Area(new Rectangle2D.Double(s, O_MID, w - 2 * s, BASELINE - O_MID)));
        outer.subtract(inner);
        return outer;
    }

    /** a: o with a straight stem down its right side, the geometric single-storey a. */
    static Area buildA(Area o) {
        Area a = new Area(o);
        a.add(new Area(new Rectangle2D.Double(O_W - STEM, X_TOP, STEM, BASELINE - X_TOP)));
        return a;
    }

    static String fmt(double d) {
        if (Math.abs(d - Math.rint(d)) < 1e-6) return String.valueOf((long) Math.rint(d));
        return String.format(Locale.ROOT, "%.2f", d);
    }

    static void writeVector(Area a, double vw, String color, String out) throws IOException {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");
        sb.append("<!-- Generated by devices/common/rro/tools/Brand.java - do not hand edit. -->\n");
        sb.append("<vector xmlns:android=\"http://schemas.android.com/apk/res/android\"\n");
        sb.append("    android:width=\"").append(fmt(vw)).append("dp\"\n");
        sb.append("    android:height=\"34dp\"\n");
        sb.append("    android:viewportWidth=\"").append(fmt(vw)).append("\"\n");
        sb.append("    android:viewportHeight=\"34\">\n");
        sb.append("    <path\n");
        sb.append("        android:fillColor=\"").append(color).append("\"\n");
        sb.append("        android:fillType=\"evenOdd\"\n");
        sb.append("        android:pathData=\"").append(pathData(a)).append("\" />\n");
        sb.append("</vector>\n");
        Files.write(Paths.get(out), sb.toString().getBytes("UTF-8"));
        System.out.println("wrote " + out);
    }

    static String pathData(Shape s) {
        StringBuilder sb = new StringBuilder();
        double[] c = new double[6];
        for (PathIterator it = s.getPathIterator(null, 0.02); !it.isDone(); it.next()) {
            switch (it.currentSegment(c)) {
                case PathIterator.SEG_MOVETO: sb.append("M").append(n(c[0])).append(",").append(n(c[1])); break;
                case PathIterator.SEG_LINETO: sb.append("L").append(n(c[0])).append(",").append(n(c[1])); break;
                case PathIterator.SEG_CLOSE:  sb.append("Z"); break;
            }
        }
        return sb.toString();
    }

    static String n(double d) { return String.format(Locale.ROOT, "%.2f", d); }

    static void preview(Area a, double vw, String out) throws IOException {
        int sc = 10;
        BufferedImage img = new BufferedImage((int) (vw * sc), 34 * sc, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setColor(new Color(18, 18, 22));
        g.fillRect(0, 0, img.getWidth(), img.getHeight());
        g.scale(sc, sc);
        g.setColor(Color.WHITE);
        g.fill(a);
        g.dispose();
        ImageIO.write(img, "png", new File(out));
        System.out.println("wrote " + out);
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

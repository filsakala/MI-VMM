/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package semestralka;

import com.stromberglabs.jopensurf.SURFInterestPoint;
import com.stromberglabs.jopensurf.Surf;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import javax.imageio.ImageIO;

/**
 *
 * @author phil
 */
public class Semestralka {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        System.out.println("Surf Interest Points Finder:");
        if (args.length != 0) {
            for (String arg : args) {
                Surf sm = new Surf(ImageIO.read(new FileInputStream(arg)));
                List<SURFInterestPoint> pts = sm.getFreeOrientedInterestPoints();
                for (Iterator<SURFInterestPoint> surfInterestPointIterator = pts.iterator(); surfInterestPointIterator.hasNext();) {
                    SURFInterestPoint pt = surfInterestPointIterator.next();
                    System.out.println(pt.getX() + " " + pt.getY());
                }
            }
        } else {
            System.out.println("Nothing to do here.");
            System.out.println("Usage: java -jar semestralka.jar filename1.png filename2.png ...");
        }

    }

}

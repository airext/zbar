package com.github.airext.zbar.functions;

import android.app.Activity;
import android.graphics.Bitmap;
import android.util.Log;
import com.adobe.fre.*;
import com.github.airext.bridge.Bridge;
import com.github.airext.bridge.Call;
import com.github.airext.zbar.vo.ScanResultsVO;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Symbol;

import java.util.ArrayList;

/**
 * Created by max on 9/7/17.
 */
public class ScanFunction implements FREFunction {
    @Override
    public FREObject call(FREContext context, FREObject[] args) {
        Log.d("ANXZBar", "ScanFunction");

        final Call call = Bridge.call(context);

        final Activity activity = context.getActivity();

        FREBitmapData bmd = (FREBitmapData)args[0];

        try {
            bmd.acquire();

            final int width  = bmd.getWidth();
            final int height = bmd.getHeight();
            int stride = bmd.getLineStride32();

            final Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            bmp.copyPixelsFromBuffer(bmd.getBits());

            bmd.release();

            stride = width;

            Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {

                    int[] pixels = new int[width * height];
                    bmp.getPixels(pixels, 0, width, 0, 0, width, height);

                    Image image = new Image(width, height, "RGB4");
                    image.setData(pixels);

                    ImageScanner scanner = new ImageScanner();
                    final int resultCount = scanner.scanImage(image.convert("Y800"));

                    final ArrayList<String> results = new ArrayList<>();
                    if (resultCount > 0) {
                        for (Symbol symbol : scanner.getResults()) {
                            results.add(symbol.getData());
                        }
                    }

                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            call.result(new ScanResultsVO(results));
                        }
                    });
                }
            });
            thread.setPriority(Thread.NORM_PRIORITY);
            thread.start();

        } catch (FREInvalidObjectException e) {
            e.printStackTrace();
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }

        try {
            return call.toFREObject();
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
            return null;
        }
    }
}

package com.github.airext.zbar.functions;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

/**
 * Created by max on 9/7/17.
 */
public class IsSupportedFunction implements FREFunction {

    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        try {
            Log.d("ANXZBar", "IsSupportedFunction");
            return FREObject.newObject(true);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return null;
    }
}

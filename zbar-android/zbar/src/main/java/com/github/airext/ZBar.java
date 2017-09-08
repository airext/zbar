package com.github.airext;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.github.airext.zbar.ExtensionContext;

/**
 * Created by max on 9/7/17.
 */
public class ZBar implements FREExtension {

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    public static boolean debug = false;

    public static FREContext context;

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    public static void dispatch(String code, String level) {
        if (context != null) {
            context.dispatchStatusEventAsync(code, level);
        }
    }

    public static void dispatchStatus(String code) {
        dispatch(code, "status");
    }

    public static void dispatchError(String code) {
        dispatch(code, "error");
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    @Override
    public void initialize() {
        Log.d("ANXZBar", "initialize()");
    }

    @Override
    public FREContext createContext(String s) {
        Log.d("ANXZBar", "createContext()");
        context = new ExtensionContext();
        return context;
    }

    @Override
    public void dispose() {
        Log.d("ANXZBar", "dispose()");
    }
}

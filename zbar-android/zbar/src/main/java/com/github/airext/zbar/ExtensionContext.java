package com.github.airext.zbar;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.github.airext.bridge.Bridge;
import com.github.airext.bridge.exceptions.BridgeInstantiationException;
import com.github.airext.bridge.exceptions.BridgeNotFoundException;
import com.github.airext.zbar.functions.IsSupportedFunction;
import com.github.airext.zbar.functions.ScanFunction;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by max on 9/7/17.
 */
public class ExtensionContext extends FREContext {

    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
        functions.put("isSupported", new IsSupportedFunction());
        functions.put("scan", new ScanFunction());

        try {
            Bridge.setup(functions);
        } catch (BridgeNotFoundException e) {
            e.printStackTrace();
        } catch (BridgeInstantiationException e) {
            e.printStackTrace();
        }

        return functions;
    }

    @Override
    public void dispose() {

    }
}

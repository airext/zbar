package com.github.airext.zbar.vo;

import com.adobe.fre.*;
import com.github.airext.bridge.CallResultValue;

import java.util.List;

/**
 * Created by max on 9/7/17.
 */
public class ScanResultsVO implements CallResultValue {

    public ScanResultsVO(List<String> results) {
        super();
        this.results = results;
    }

    private List<String> results;

    @Override
    public FREObject toFREObject() throws FRETypeMismatchException, FREInvalidObjectException, FREWrongThreadException, IllegalStateException {
        try {
            int count = results != null ? results.size() : 0;
            FREArray result = FREArray.newArray(count);
            for (int i = 0; i < count; i++) {
                result.setObjectAt(i, FREObject.newObject(this.results.get(i)));
            }
            return  result;
        } catch (FREASErrorException e) {
            e.printStackTrace();
        }
        return null;
    }
}

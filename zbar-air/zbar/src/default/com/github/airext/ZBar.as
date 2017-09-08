/**
 * Created by max.rozdobudko@gmail.com on 9/5/17.
 */
package com.github.airext {
import com.github.airext.core.zbar;

import flash.display.BitmapData;
import flash.external.ExtensionContext;

use namespace zbar;

public class ZBar {

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    zbar static const EXTENSION_ID:String = "com.github.airext.ZBar";

    //--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------

    //-------------------------------------
    //  context
    //-------------------------------------

    zbar static function get context():ExtensionContext {
        return null;
    }

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    //-------------------------------------
    //  isSupported
    //-------------------------------------

    public static function isSupported():Boolean {
        trace("[airext] zbar extension is not supported on this platform.");
        return false;
    }

    //-------------------------------------
    //  sharedInstance
    //-------------------------------------

    private static var instance:ZBar;
    public static function sharedInstance():ZBar {
        if (instance == null) {
            new ZBar();
        }
        return instance;
    }

    //-------------------------------------
    //  extensionVersion
    //-------------------------------------

    public static function extensionVersion():String {
        return null;
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function ZBar() {
        super();
        instance = this;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    public function scan(bitmapData: BitmapData, completion: Function): void {
        trace("[airext] zbar extension is not supported on this platform.");
    }
}
}

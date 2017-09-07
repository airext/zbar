/**
 * Created by max.rozdobudko@gmail.com on 9/5/17.
 */
package com.github.airext {
import com.github.airext.bridge.bridge;
import com.github.airext.core.zbar;

import flash.display.BitmapData;

import flash.external.ExtensionContext;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

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

    private static var _context:ExtensionContext;
    zbar static function get context():ExtensionContext {
        if (_context == null) {
            _context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
        }
        return _context;
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
        return context != null && context.call("isSupported");
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

    private static var _extensionVersion:String = null;

    /**
     * Returns version of extension
     * @return extension version
     */
    public static function extensionVersion():String
    {
        if (_extensionVersion == null) {
            try {
                var extension_xml:File = ExtensionContext.getExtensionDirectory(EXTENSION_ID).resolvePath("META-INF/ANE/extension.xml");
                if (extension_xml.exists) {
                    var stream:FileStream = new FileStream();
                    stream.open(extension_xml, FileMode.READ);

                    var extension:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));
                    stream.close();

                    var ns:Namespace = extension.namespace();

                    _extensionVersion = extension.ns::versionNumber;
                }
            } catch (error:Error) {
                // ignore
            }
        }

        return _extensionVersion;
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
        bridge(context).call("scan", bitmapData).callback(completion);
    }

    public function scanSync(bitmapData: BitmapData): Object {
        return context.call("scanSync", bitmapData);
    }

    public function testScan(bitmapData: BitmapData): Object {
        var callback: Function = function (error, result) {

        };
        return bridge(context).call("testScan", bitmapData).callback(callback).returnValue;
    }
}
}

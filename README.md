# zbar
AIR Native Extension for ZBar Bar Code Reader library

This ANE allows to *asynchronously* scan `BitmapData` for barcodes, under hood it uses [ZBar](https://github.com/ZBar/ZBar) a well known Bar Code reader.

## Dependencies

* [ANXBridge](https://github.com/airext/anx-bridge)

It uses `ANXBridge` extension for asynchronous calls.

## Installation 

1. Download [zbar.ane]() and [anx-bridge.ane](https://github.com/airext/anx-bridge/blob/master/bin/anx-bridge.ane) ANEs and [add them as dependencies](http://bit.ly/2xTSJry) to your project. 
2. Edit your [Application Descriptor](http://help.adobe.com/en_US/air/build/WS5b3ccc516d4fbf351e63e3d118666ade46-7ff1.html) file with registering two native extensions like this:
```xml
<extensions>
    <extensionID>com.github.airext.ZBar</extensionID>
    <extensionID>com.github.airext.Bridge</extensionID>
</extensions>
```
3. You probably want to use it to scan barcodes using Camera, if so let Android to understand that by registering Camera permission in Android Manifest additoins, like this:
```xml
<android>
  <manifestAdditions>
    <![CDATA[
    <manifest android:installLocation="auto">
      <uses-permission android:name="android.permission.INTERNET"/>
      <uses-permission android:name="android.permission.CAMERA"/>
    </manifest>
    ]]>
  </manifestAdditions>
</android>
```
it seems to be final step, but before to use it you check if ZBar extension is available on the current platform:
```as3
if (ZBar.isSupported() {
  // we're set
}
```

## Usage example

The interface is prety straightforward, it contains one `scan(bmd: BitmapData, callback: Function):void` method that performs scan and notify about result in callback:
```as3
if (ZBar.isSupported()) {
  var bmd: BitmapData = drawCameraToBitmapData();
  ZBar.sharedInstance().scan(bmd, function(error: Error, results: Array):void {
    if (error) {
      trace("Error:", error);
    } else if (results.lenght > 0) {
      trace("Barcodes found:", results);
    }
  });
}
```

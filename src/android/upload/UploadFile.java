package org.apache.cordova.upload;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.download.Image;
import org.json.JSONArray;
import org.json.JSONException;

public class UploadFile extends CordovaPlugin {
	
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if ("upload".equals(action)) {
            BlockingQueue<Image> queue = new LinkedBlockingQueue<Image>();
            UploadConsumer dc = new UploadConsumer(queue, args, this.webView, this.cordova);
            dc.start();
            UploadProducer dp = new UploadProducer(queue, args, this.webView, this.cordova);
            dp.start();
            return true;
        }else{
            return false;
        }
	}
	
}

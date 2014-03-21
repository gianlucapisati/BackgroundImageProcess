package org.apache.cordova.download;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public class DownloadFile extends CordovaPlugin {
	
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if ("download".equals(action)) {
			BlockingQueue<Image> queue = new LinkedBlockingQueue<Image>();
			DownloadConsumer dc = new DownloadConsumer(queue, args, this.webView, this.cordova);
			dc.start();
			DownloadProducer dp = new DownloadProducer(queue);
			dp.start();
			return true;
		}
		return false;
	}
	
}

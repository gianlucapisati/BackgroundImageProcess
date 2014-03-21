package org.apache.cordova.download;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.concurrent.BlockingQueue;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreProtocolPNames;
import org.json.JSONArray;
import org.pgsqlite.SQLitePlugin;

import android.os.Environment;

public class DownloadConsumer extends Thread {
    
	BlockingQueue<Image> queue;
	JSONArray args;
	CordovaInterface cordova;
	CordovaWebView webView;
    
	public DownloadConsumer(BlockingQueue<Image> queue, JSONArray args, CordovaWebView webView,CordovaInterface cordova) {
		this.queue = queue;
		this.args = args;
		this.webView = webView;
		this.cordova = cordova;
	}
	
	public void run() {
		final DownloadConsumer myself = this;
		this.cordova.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				myself.webView.sendJavascript("javascript:SW.Renderer.handleProgress(100,0,'download')");
			}
		});
		try {
			HttpClient httpClient = new DefaultHttpClient();
	        httpClient.getParams().setParameter(CoreProtocolPNames.PROTOCOL_VERSION, HttpVersion.HTTP_1_1);
            
			while(true) {
				Image img = this.queue.take();
				File file = new File(Environment.getExternalStorageDirectory()+"/sw/www/img/"+img.getPath()+".jpg");
				if (!file.exists()) {
					String url = this.args.getString(2)+"services/ps/download/"+img.getPath();
					HttpGet httpGet = new HttpGet(url);
					httpGet.setHeader("Authorization", args.getString(0)+":"+args.getString(1));
			        HttpResponse response = httpClient.execute(httpGet);
			        InputStream is = response.getEntity().getContent();
			        FileOutputStream fos = new FileOutputStream(file);
			        byte[] buffer = new byte[4096];
			        int ln;
			        while((ln=is.read(buffer)) > 0) {
			        	fos.write(buffer, 0, ln);
			        }
			        fos.close();
			        is.close();
				}
				
				final Image myImg = img;
				this.cordova.getActivity().runOnUiThread(new Runnable() {
					public void run() {
						myself.webView.sendJavascript("javascript:SW.Renderer.handleProgress("+myImg.getTotal()+","+myImg.getCount()+",'download')");
					}
				});
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
    
}

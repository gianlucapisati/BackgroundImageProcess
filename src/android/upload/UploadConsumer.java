package org.apache.cordova.upload;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.BlockingQueue;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.download.DownloadConsumer;
import org.apache.cordova.download.Image;
import org.json.JSONArray;

import android.database.sqlite.SQLiteDatabase;
import android.os.Environment;

public class UploadConsumer extends Thread {
    
	BlockingQueue<Image> queue;
	JSONArray args;
	CordovaInterface cordova;
	CordovaWebView webView;
    
	public UploadConsumer(BlockingQueue<Image> queue, JSONArray args,
                          CordovaWebView webView, CordovaInterface cordova
                          ) {
		this.queue = queue;
		this.args = args;
		this.webView = webView;
		this.cordova = cordova;
	}
    
	public void run() {
		HttpURLConnection conn = null;
		DataOutputStream dos = null;
		String lineEnd = "\r\n";
		String twoHyphens = "--";
		String boundary = "*****";
		byte[] buffer;
		int bytesRead, bytesAvailable, bufferSize;
		int serverResponseCode = 0;
		int maxBufferSize = 1 * 1024 * 1024;
		
		final UploadConsumer myself = this;
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                myself.webView.sendJavascript("javascript:SW.Renderer.handleProgress(100,0,'upload')");
            }
        });
		try {
			while(true) {
				Image img = this.queue.take();
				String filename = img.getPath();
				filename = filename.substring(7);
				File sourceFile = new File(filename);
				FileInputStream fileInputStream = new FileInputStream(sourceFile);
				URL url = new URL(this.args.getString(2)+"services/ps/upload/"+img.getIdPhoto());
				conn = (HttpURLConnection) url.openConnection();
				conn.setDoInput(true);
				conn.setDoOutput(true);
				conn.setUseCaches(false);
				conn.setRequestMethod("POST");
				conn.setRequestProperty("Connection", "Keep-Alive");
				conn.setRequestProperty("ENCTYPE", "multipart/form-data");
				conn.setRequestProperty("Content-Type","multipart/form-data;boundary=" + boundary);
				conn.setRequestProperty("uploaded_file", filename);
				conn.setRequestProperty("Authorization", args.getString(0)+":"+args.getString(1));
                
				dos = new DataOutputStream(conn.getOutputStream());
				dos.writeBytes(twoHyphens + boundary + lineEnd);
				dos.writeBytes("Content-Disposition: form-data; name=\"photo\"; filename=\"image\"" + lineEnd);
				dos.writeBytes(lineEnd);
                
				bytesAvailable = fileInputStream.available();
                
				bufferSize = Math.min(bytesAvailable, maxBufferSize);
				buffer = new byte[bufferSize];
                
				bytesRead = fileInputStream.read(buffer, 0, bufferSize);
                
				while (bytesRead > 0) {
					dos.write(buffer, 0, bufferSize);
					bytesAvailable = fileInputStream.available();
					bufferSize = Math.min(bytesAvailable, maxBufferSize);
					bytesRead = fileInputStream.read(buffer, 0, bufferSize);
				}
                
				dos.writeBytes(lineEnd);
				dos.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);
				
				serverResponseCode = conn.getResponseCode();
				String serverResponseMessage = conn.getResponseMessage();
                
				System.out.println("uploadFile - HTTP Response is : "+ serverResponseMessage + ": " + serverResponseCode);
                
				fileInputStream.close();
				dos.flush();
				dos.close();
                
                File dbfile = new File(Environment.getExternalStorageDirectory()+File.separator+"sw/wsw_db.db");
                SQLiteDatabase mydb = SQLiteDatabase.openOrCreateDatabase(dbfile, null);
                mydb.delete("photo_to_send", "id_photo = ?", new String[]{img.getIdPhoto()});
				
				final Image myImg = img;
				this.cordova.getActivity().runOnUiThread(new Runnable() {
					public void run() {
						myself.webView.sendJavascript("javascript:SW.Renderer.handleProgress("+myImg.getTotal()+","+myImg.getCount()+",'upload')");
					}
				});
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
    
}
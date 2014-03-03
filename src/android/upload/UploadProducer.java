package org.apache.cordova.upload;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;

import org.apache.cordova.download.Image;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Environment;

public class UploadProducer extends Thread {
	
	BlockingQueue<Image> queue;
    CordovaWebView webView;
    
	public UploadProducer(BlockingQueue<Image> queue,CordovaWebView webView) {
		this.queue = queue;
        this.webView = webView;
	}
    
	public void run() {
        try {
            File dbfile = new File(Environment.getExternalStorageDirectory()+File.separator+"sw/wsw_db.db");
            SQLiteDatabase mydb = SQLiteDatabase.openOrCreateDatabase(dbfile, null);
            Cursor cursor = mydb.rawQuery("SELECT id_photo, path FROM photo_to_send", null);
            List<PhotoToSend> str = new ArrayList<PhotoToSend>();
            while (cursor.moveToNext()) {
                PhotoToSend pts = new PhotoToSend();
                pts.setIdPhoto(cursor.getString(0));
                pts.setPath(cursor.getString(1));
                str.add(pts);
            }
            for(int i=0; i<str.size();i++) {
                Image img = new Image();
                img.setTotal(str.size());
                img.setCount(i+1);
                img.setPath(str.get(i).getPath());
                img.setIdPhoto(str.get(i).getIdPhoto());
                queue.put(img);
            }
            if(str.size()>0){
                final UploadProducer myself = this;
                this.cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        myself.webView.sendJavascript("javascript:SW.Renderer.handleProgress(100,0,'upload')");
                    }
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class PhotoToSend {
	
	private String idPhoto;
	private String path;
	public String getIdPhoto() {
		return idPhoto;
	}
	public void setIdPhoto(String idPhoto) {
		this.idPhoto = idPhoto;
	}
	public String getPath() {
		return path;
	}
	public void setPath(String path) {
		this.path = path;
	}
	
}
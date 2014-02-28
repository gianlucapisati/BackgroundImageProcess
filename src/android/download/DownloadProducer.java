package org.apache.cordova.download;

import java.io.File;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteStatement;
import android.os.Environment;


public class DownloadProducer extends Thread {
	
	BlockingQueue<Image> queue;
    
	public DownloadProducer(BlockingQueue<Image> queue) {
		this.queue = queue;
	}
    
	public void run() {
        try {
            File dbfile = new File(Environment.getExternalStorageDirectory()+File.separator+"sw/wsw_db.db");
            SQLiteDatabase mydb = SQLiteDatabase.openOrCreateDatabase(dbfile, null);
            Cursor cursor = mydb.rawQuery("SELECT question_path FROM qualitative_survey_questions UNION SELECT guid FROM pos_logo", null);
            List<String> str = new ArrayList<String>();
            while(cursor.moveToNext()) {
                str.add(cursor.getString(0));
            }
            cursor.close();
            for(int i=0; i<str.size();i++) {
                Image img = new Image();
                img.setTotal(str.size());
                img.setCount(i+1);
                img.setPath(str.get(i));
                queue.put(img);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

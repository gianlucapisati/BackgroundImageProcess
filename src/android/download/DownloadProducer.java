package org.apache.cordova.download;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Environment;


public class DownloadProducer extends Thread {
	
	BlockingQueue<Document> queue;
    
	public DownloadProducer(BlockingQueue<Document> queue) {
		this.queue = queue;
	}
    
	public void run() {
        try {
            File dbfile = new File(Environment.getExternalStorageDirectory()+File.separator+"sw/wsw_db.db");
            SQLiteDatabase mydb = SQLiteDatabase.openOrCreateDatabase(dbfile, null);
            Cursor cursor = mydb.rawQuery("SELECT question_path, 'jpg' FROM qualitative_survey_questions UNION SELECT guid, 'jpg' FROM pos_logo UNION SELECT path, original_extension FROM documents UNION SELECT photo_hash, 'jpg' FROM end_of_visit_photos", null);
            List<String> paths = new ArrayList<String>();
            List<String> extensions = new ArrayList<String>();
            while(cursor.moveToNext()) {
            	paths.add(cursor.getString(0));
            	extensions.add(cursor.getString(1));
            }
            cursor.close();
            for(int i=0; i<paths.size();i++) {
            	Document document = new Document();
            	document.setTotal(paths.size());
            	document.setCount(i+1);
            	document.setPath(paths.get(i));
            	document.setExtension(extensions.get(i));
                queue.put(document);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

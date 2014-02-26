package org.apache.cordova.upload;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.BlockingQueue;

import org.apache.cordova.download.Image;

public class UploadProducer extends Thread {
	
	BlockingQueue<Image> queue;

	public UploadProducer(BlockingQueue<Image> queue) {
		this.queue = queue;
	}

	public void run() {
		Connection connection = null;
		try {
			Class.forName("org.sqlite.JDBC");			
			connection = DriverManager.getConnection("jdbc:sqlite:sw/wsw_db.db");
			Statement statement = connection.createStatement();
			statement.setQueryTimeout(30);
			ResultSet rs = statement.executeQuery("SELECT id_photo, path FROM photo_to_send");
			List<PhotoToSend> str = new ArrayList<PhotoToSend>();
			while (rs.next()) {
				PhotoToSend pts = new PhotoToSend();
				pts.setIdPhoto(rs.getString("id_photo"));
				pts.setPath(rs.getString("path"));
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
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (connection != null) connection.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
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
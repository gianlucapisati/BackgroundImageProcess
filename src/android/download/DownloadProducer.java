package org.apache.cordova.download;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;

public class DownloadProducer extends Thread {
	
	BlockingQueue<Image> queue;

	public DownloadProducer(BlockingQueue<Image> queue) {
		this.queue = queue;
	}

	public void run() {
		Connection connection = null;
		try {
			Class.forName("org.sqlite.JDBC");			
			connection = DriverManager.getConnection("jdbc:sqlite:sw/wsw_db.db");
			Statement statement = connection.createStatement();
			statement.setQueryTimeout(30);
			ResultSet rs = statement.executeQuery("SELECT question_path FROM qualitative_survey_questions UNION SELECT guid FROM pos_logo");
			List<String> str = new ArrayList<String>();
			while (rs.next()) {
				str.add(rs.getString(0));
			}
			for(int i=0; i<str.size();i++) {
				Image img = new Image();
				img.setTotal(str.size());
				img.setCount(i+1);
				img.setPath(str.get(i));
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

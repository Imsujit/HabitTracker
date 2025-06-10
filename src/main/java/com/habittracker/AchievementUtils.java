package com.habittracker;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

public class AchievementUtils {

	public static void checkAchievements(Connection conn, int userId, int habitId) throws SQLException {
		// Check total marks
		String countSql = "SELECT COUNT(*) FROM habit_status WHERE user_id = ? AND habit_id = ?";
		PreparedStatement ps = conn.prepareStatement(countSql);
		ps.setInt(1, userId);
		ps.setInt(2, habitId);
		ResultSet rs = ps.executeQuery();
		int total = 0;
		if (rs.next()) {
			total = rs.getInt(1);
		}
		rs.close();
		ps.close();

		// First Habit Done
		if (total == 1) {
			insertAchievement(conn, userId, "First Habit Done");
		}

		// 20 times = Consistency Champion
		if (total >= 20) {
			insertAchievement(conn, userId, "Consistency Champion");
		}

		// 30 times = 30-Day Commitment
		if (total >= 30) {
			insertAchievement(conn, userId, "30-Day Commitment");
		}

		// Check for 3-day or 7-day streak
		String streakSql = """
				    SELECT COUNT(*) AS streak FROM (
				        SELECT status_date
				        FROM habit_status
				        WHERE user_id = ? AND habit_id = ?
				        AND status_date >= CURDATE() - INTERVAL 6 DAY
				        GROUP BY status_date
				    ) AS last_seven
				""";
		ps = conn.prepareStatement(streakSql);
		ps.setInt(1, userId);
		ps.setInt(2, habitId);
		rs = ps.executeQuery();
		int days = 0;
		if (rs.next()) {
			days = rs.getInt("streak");
		}
		rs.close();
		ps.close();

		if (days >= 3)
			insertAchievement(conn, userId, "Habit Streak Beginner");
		if (days >= 7)
			insertAchievement(conn, userId, "7-Day Streak");
	}

	private static void insertAchievement(Connection conn, int userId, String name) throws SQLException {
		String checkSql = "SELECT COUNT(*) FROM user_achievements WHERE user_id = ? AND achievement_name = ?";
		PreparedStatement checkPs = conn.prepareStatement(checkSql);
		checkPs.setInt(1, userId);
		checkPs.setString(2, name);
		ResultSet checkRs = checkPs.executeQuery();
		boolean alreadyExists = false;
		if (checkRs.next()) {
			alreadyExists = checkRs.getInt(1) > 0;
		}
		checkRs.close();
		checkPs.close();

		if (!alreadyExists) {
			String insertSql = "INSERT INTO user_achievements (user_id, achievement_name, date_earned) VALUES (?, ?, ?)";
			PreparedStatement insertPs = conn.prepareStatement(insertSql);
			insertPs.setInt(1, userId);
			insertPs.setString(2, name);
			insertPs.setDate(3, Date.valueOf(LocalDate.now()));
			insertPs.executeUpdate();
			insertPs.close();
		}
	}
}

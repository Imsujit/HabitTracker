package com.habittracker;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

public class HabitUtils {

	// Count consecutive days backward from today
	public static int getCurrentStreak(Connection conn, int userId, int habitId) throws SQLException {
		int streak = 0;
		LocalDate day = LocalDate.now();
		try (PreparedStatement ps = conn
				.prepareStatement("SELECT 1 FROM habit_status WHERE user_id=? AND habit_id=? AND status_date=?")) {
			while (true) {
				ps.setInt(1, userId);
				ps.setInt(2, habitId);
				ps.setDate(3, Date.valueOf(day));
				try (ResultSet rs = ps.executeQuery()) {
					if (rs.next()) {
						streak++;
						day = day.minusDays(1);
					} else {
						break;
					}
				}
			}
		}
		return streak;
	}

	// Find longest run of consecutive days
	public static int getLongestStreak(Connection conn, int userId, int habitId) throws SQLException {
		int longest = 0, current = 0;
		LocalDate prev = null;
		try (PreparedStatement ps = conn.prepareStatement(
				"SELECT status_date FROM habit_status WHERE user_id=? AND habit_id=? ORDER BY status_date")) {
			ps.setInt(1, userId);
			ps.setInt(2, habitId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					LocalDate d = rs.getDate(1).toLocalDate();
					if (prev != null && prev.plusDays(1).equals(d)) {
						current++;
					} else {
						current = 1;
					}
					if (current > longest)
						longest = current;
					prev = d;
				}
			}
		}
		return longest;
	}
}

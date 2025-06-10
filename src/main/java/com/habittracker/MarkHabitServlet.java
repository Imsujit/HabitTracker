package com.habittracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/MarkHabitServlet")
public class MarkHabitServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int habitId = Integer.parseInt(request.getParameter("habit_id"));
		HttpSession session = request.getSession();
		String username = (String) session.getAttribute("username");

		try (Connection conn = DBConnection.getConnection()) {
			// Get user ID from username
			String userQuery = "SELECT id FROM users WHERE username = ?";
			PreparedStatement userStmt = conn.prepareStatement(userQuery);
			userStmt.setString(1, username);
			ResultSet userRs = userStmt.executeQuery();

			if (userRs.next()) {
				int userId = userRs.getInt("id");

				// Check if already marked as done for today
				String checkQuery = "SELECT * FROM habit_status WHERE user_id = ? AND habit_id = ? AND status_date = CURDATE()";
				PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
				checkStmt.setInt(1, userId);
				checkStmt.setInt(2, habitId);
				ResultSet checkRs = checkStmt.executeQuery();

				if (!checkRs.next()) {
					// Only insert if not already marked today
					String insertQuery = "INSERT INTO habit_status (user_id, habit_id, status_date) VALUES (?, ?, CURDATE())";
					PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
					insertStmt.setInt(1, userId);
					insertStmt.setInt(2, habitId);
					insertStmt.executeUpdate();

					// after inserting into habit_status table
					AchievementUtils.checkAchievements(conn, userId, habitId);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		response.sendRedirect("jsp/viewHabits.jsp");
	}
}

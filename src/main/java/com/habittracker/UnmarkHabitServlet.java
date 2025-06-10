package com.habittracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UnmarkHabitServlet")
public class UnmarkHabitServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int habitId = Integer.parseInt(request.getParameter("habit_id"));
		HttpSession session = request.getSession();
		String username = (String) session.getAttribute("username");

		try (Connection conn = DBConnection.getConnection()) {
			// Get user ID from session
			String getUserSql = "SELECT id FROM users WHERE username = ?";
			PreparedStatement psUser = conn.prepareStatement(getUserSql);
			psUser.setString(1, username);
			var rsUser = psUser.executeQuery();

			if (rsUser.next()) {
				int userId = rsUser.getInt("id");

				String deleteSql = "DELETE FROM habit_status WHERE user_id = ? AND habit_id = ? AND status_date = CURDATE()";
				PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
				deleteStmt.setInt(1, userId);
				deleteStmt.setInt(2, habitId);
				deleteStmt.executeUpdate();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		response.sendRedirect("jsp/viewHabits.jsp");
	}
}

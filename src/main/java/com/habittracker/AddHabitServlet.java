package com.habittracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddHabitServlet")
public class AddHabitServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String username = (String) session.getAttribute("username");

		if (username == null) {
			response.sendRedirect("jsp/login.jsp");
			return;
		}

		String habitName = request.getParameter("habit_name");
		String description = request.getParameter("description");

		try (Connection conn = DBConnection.getConnection()) {
			// Get user ID based on username
			String getUserIdQuery = "SELECT id FROM users WHERE username = ?";
			PreparedStatement getUserStmt = conn.prepareStatement(getUserIdQuery);
			getUserStmt.setString(1, username);
			ResultSet rs = getUserStmt.executeQuery();

			int userId = -1;
			if (rs.next()) {
				userId = rs.getInt("id");
			}

			if (userId != -1) {
				String insertHabit = "INSERT INTO habits (user_id, habit_name, description) VALUES (?, ?, ?)";
				PreparedStatement insertStmt = conn.prepareStatement(insertHabit);
				insertStmt.setInt(1, userId);
				insertStmt.setString(2, habitName);
				insertStmt.setString(3, description);
				insertStmt.executeUpdate();
			}

			response.sendRedirect("jsp/dashboard.jsp");

		} catch (Exception e) {
			e.printStackTrace();
			response.getWriter().println("Error adding habit: " + e.getMessage());
		}
	}
}

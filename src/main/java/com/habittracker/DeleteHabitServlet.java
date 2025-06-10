package com.habittracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteHabitServlet")
public class DeleteHabitServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String habitIdStr = request.getParameter("habit_id");
		if (habitIdStr == null) {
			response.sendRedirect("jsp/viewHabits.jsp");
			return;
		}

		int habitId = Integer.parseInt(habitIdStr);

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("user_id") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		int userId = (Integer) session.getAttribute("user_id");

		try (Connection conn = DBConnection.getConnection()) {
			String sql = "DELETE FROM habits WHERE id = ? AND user_id = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setInt(1, habitId);
			ps.setInt(2, userId);

			// System.out.println("Trying to delete habit ID: " + habitId + " for user ID: "
			// + userId);

			int rowsDeleted = ps.executeUpdate();
			// if (rowsDeleted > 0) {
			// System.out.println("Habit deleted successfully.");
			// } else {
			// System.out.println("No habit found or permission denied.");
			// }
		} catch (

		Exception e) {
			e.printStackTrace();
		}

		response.sendRedirect("jsp/viewHabits.jsp");
	}
}

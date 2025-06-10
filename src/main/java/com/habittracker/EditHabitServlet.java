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

@WebServlet("/EditHabitServlet")
public class EditHabitServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int habitId = Integer.parseInt(request.getParameter("habit_id"));
		String habitName = request.getParameter("habit_name");
		String description = request.getParameter("description");

		HttpSession session = request.getSession();
		Integer userId = (Integer) session.getAttribute("user_id");

		try (Connection conn = DBConnection.getConnection()) {
			String sql = "UPDATE habits SET habit_name = ?, description = ?, created_date = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, habitName);
			ps.setString(2, description);
			ps.setInt(3, habitId);
			ps.setInt(4, userId);
			ps.executeUpdate();

			// Remove today's 'done' entry if habit was edited
			String deleteStatusSql = "DELETE FROM habit_status WHERE user_id = ? AND habit_id = ? AND status_date = CURDATE()";
			PreparedStatement deleteStatusPs = conn.prepareStatement(deleteStatusSql);
			deleteStatusPs.setInt(1, userId);
			deleteStatusPs.setInt(2, habitId);
			deleteStatusPs.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}

		response.sendRedirect("jsp/viewHabits.jsp");
	}
}

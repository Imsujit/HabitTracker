package com.habittracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/HabitHistoryServlet")
public class HabitHistoryServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Integer userId = (Integer) session.getAttribute("user_id");

		if (userId == null) {
			response.sendRedirect("jsp/login.jsp");
			return;
		}

		String startDate = request.getParameter("start_date");
		String endDate = request.getParameter("end_date");

		List<Map<String, String>> history = new ArrayList<>();

		try (Connection conn = DBConnection.getConnection()) {
			String sql = "SELECT h.habit_name, hs.status_date FROM habit_status hs "
					+ "JOIN habits h ON hs.habit_id = h.id "
					+ "WHERE hs.user_id = ? AND hs.status_date BETWEEN ? AND ? ORDER BY hs.status_date DESC";

			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setInt(1, userId);
			ps.setString(2, startDate);
			ps.setString(3, endDate);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				Map<String, String> row = new HashMap<>();
				row.put("habit_name", rs.getString("habit_name"));
				row.put("status_date", rs.getString("status_date"));
				history.add(row);
			}

			request.setAttribute("history", history);
			request.getRequestDispatcher("jsp/habitHistoryResult.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.getWriter().println("Error retrieving habit history.");
		}
	}
}

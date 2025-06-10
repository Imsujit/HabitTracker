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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String username = request.getParameter("username");
		String password = request.getParameter("password");

		try (Connection conn = DBConnection.getConnection()) {
			String hashedPassword = PasswordHasher.hashPassword(password);

			String sql = "SELECT id FROM users WHERE username = ? AND password = ?";
			PreparedStatement stmt = conn.prepareStatement(sql);
			stmt.setString(1, username);
			stmt.setString(2, hashedPassword);

			ResultSet rs = stmt.executeQuery();

			if (rs.next()) {
				int userId = rs.getInt("id");

				HttpSession session = request.getSession();
				session.setAttribute("username", username);
				session.setAttribute("user_id", userId); // ✅ Important

				response.sendRedirect("jsp/dashboard.jsp");
			} else {
				request.setAttribute("errorMessage", "Invalid username or password");
				request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
			}

		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("errorMessage", "Server error: " + e.getMessage());
			request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
		}
	}
}

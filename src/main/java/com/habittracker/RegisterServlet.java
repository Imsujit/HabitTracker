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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String username = request.getParameter("username");
		String password = request.getParameter("password");

		try (Connection conn = DBConnection.getConnection()) {
			String hashedPassword = PasswordHasher.hashPassword(password);

			String sql = "INSERT INTO users (username, password) VALUES (?, ?)";
			PreparedStatement stmt = conn.prepareStatement(sql);
			stmt.setString(1, username);
			stmt.setString(2, hashedPassword);

			int result = stmt.executeUpdate();

			if (result > 0) {
				response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
			} else {
				HttpSession session = request.getSession();
				session.setAttribute("registerError", "Registration failed.");
				response.sendRedirect("jsp/register.jsp");
			}
		} catch (SQLException e) {
			e.printStackTrace();
			HttpSession session = request.getSession();
			session.setAttribute("registerError", "Registration error: Username may already exist.");
			response.sendRedirect("jsp/register.jsp");
		} catch (Exception e) {
			e.printStackTrace();
			response.getWriter().println("Hashing Error: " + e.getMessage());
		}
	}
}

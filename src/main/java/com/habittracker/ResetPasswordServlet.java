package com.habittracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String username = request.getParameter("username");
		String newPassword = request.getParameter("newPassword");

		if (username == null || newPassword == null || username.trim().isEmpty() || newPassword.trim().isEmpty()) {
			response.sendRedirect("jsp/resetPassword.jsp?message=failure");
			return;
		}

		String hashedPassword = PasswordUtil.hashPassword(newPassword);

		try (Connection conn = DBConnection.getConnection()) {
			String sql = "UPDATE users SET password = ? WHERE username = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, hashedPassword);
			ps.setString(2, username);

			int rowsUpdated = ps.executeUpdate();
			ps.close();

			if (rowsUpdated > 0) {
				response.sendRedirect("jsp/resetPassword.jsp?message=success");
			} else {
				response.sendRedirect("jsp/resetPassword.jsp?message=failure");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("jsp/resetPassword.jsp?message=failure");
		}
	}
}

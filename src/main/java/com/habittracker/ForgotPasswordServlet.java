package com.habittracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String username = request.getParameter("username");

		try (Connection conn = DBConnection.getConnection()) {
			String sql = "SELECT * FROM users WHERE username = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, username);
			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				// Username exists, redirect to reset password page
				request.setAttribute("username", username);
				request.setAttribute("message", null);
				RequestDispatcher rd = request.getRequestDispatcher("jsp/resetPassword.jsp");
				rd.forward(request, response);
			} else {
				// Username doesn't exist
				response.sendRedirect("jsp/forgotPassword.jsp?error=notfound");
			}

			rs.close();
			ps.close();
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("jsp/forgotPassword.jsp?error=exception");
		}
	}
}

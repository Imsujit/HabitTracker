<%@ page import="java.sql.*, com.habittracker.DBConnection" %>
<%@ page session="true" %>

<%
String message = "";
String messageType = "";

if (request.getMethod().equals("POST")) {
    String username = request.getParameter("username");
    
    if (username != null && !username.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement("SELECT id FROM users WHERE username = ?");
            ps.setString(1, username.trim());
            rs = ps.executeQuery();
            
            if (rs.next()) {
                // Username exists, redirect to reset password page
                session.setAttribute("reset_username", username.trim());
                response.sendRedirect("resetPassword.jsp");
                return;
            } else {
                message = "Username not found. Please check your username and try again.";
                messageType = "error";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "An error occurred. Please try again later.";
            messageType = "error";
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        message = "Please enter your username.";
        messageType = "error";
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Habit Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        theme: {
                            50: '#f0fdfa',
                            100: '#ccfbf1',
                            200: '#99f6e4',
                            300: '#5eead4',
                            400: '#2dd4bf',
                            500: '#14b8a6',
                            600: '#0d9488',
                            700: '#0f766e',
                            800: '#115e59',
                            900: '#134e4a'
                        }
                    }
                }
            }
        }
    </script>
</head>
<body class="min-h-screen bg-gray-50">
    <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8">
            <!-- Header -->
            <div class="text-center">
                <div class="mx-auto h-16 w-16 bg-theme-600 rounded-full flex items-center justify-center mb-6">
                    <span class="text-white font-bold text-2xl">H</span>
                </div>
                <h2 class="text-3xl font-bold text-gray-900">Forgot Password</h2>
                <p class="mt-2 text-gray-600">Enter your username to reset your password</p>
            </div>

            <!-- Form Card -->
            <div class="bg-white rounded-lg shadow-md p-8">
                <form method="POST" action="forgotPassword.jsp" class="space-y-6">
                    <!-- Username Field -->
                    <div>
                        <label for="username" class="block text-sm font-medium text-gray-700 mb-2">
                            Username
                        </label>
                        <input 
                            type="text" 
                            id="username" 
                            name="username" 
                            required
                            value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"
                            class="w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-theme-500 focus:border-theme-500"
                            placeholder="Enter your username"
                        >
                    </div>

                    <!-- Error Message -->
                    <% if (!message.isEmpty()) { %>
                        <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                            <span class="text-sm"><%= message %></span>
                        </div>
                    <% } %>

                    <!-- Submit Button -->
                    <button 
                        type="submit"
                        class="w-full py-3 px-4 border border-transparent rounded-lg text-sm font-medium text-white bg-theme-600 hover:bg-theme-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-theme-500 transition-colors"
                    >
                        Continue to Reset Password
                    </button>
                </form>

                <!-- Back to Login -->
                <div class="mt-6 text-center">
                    <a href="<%= request.getContextPath() %>/jsp/login.jsp" 
                       class="text-sm text-theme-600 hover:text-theme-700 font-medium">
                        Back to Login
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
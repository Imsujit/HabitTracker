<%@ page import="java.sql.*, com.habittracker.DBConnection,com.habittracker.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page session="true" %>

<%
String resetUsername = (String) session.getAttribute("reset_username");
if (resetUsername == null) {
    response.sendRedirect("forgotPassword.jsp");
    return;
}

String message = "";
String messageType = "";

if (request.getMethod().equals("POST")) {
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");

    if (newPassword != null && confirmPassword != null) {
        if (newPassword.length() < 6) {
            message = "Password must be at least 6 characters long.";
            messageType = "error";
        } else if (!newPassword.equals(confirmPassword)) {
            message = "Passwords do not match. Please try again.";
            messageType = "error";
        } else {
            try (Connection conn = DBConnection.getConnection()) {
                String hashedPassword = PasswordHasher.hashPassword(newPassword); // ✅ Hash the password always

                PreparedStatement ps = conn.prepareStatement("UPDATE users SET password = ? WHERE username = ?");
                ps.setString(1, hashedPassword);
                ps.setString(2, resetUsername);

                int rowsUpdated = ps.executeUpdate();

                if (rowsUpdated > 0) {
                    session.removeAttribute("reset_username");
                    message = "Password updated successfully! Redirecting to login...";
                    messageType = "success";
                    response.setHeader("refresh", "3;url=" + request.getContextPath() + "/jsp/login.jsp");
                } else {
                    message = "Failed to update password. Please try again.";
                    messageType = "error";
                }
            } catch (Exception e) {
                message = "An error occurred: " + e.getMessage();
                messageType = "error";
                e.printStackTrace();
            }
        }
    } else {
        message = "Please fill in all fields.";
        messageType = "error";
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Habit Tracker</title>
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

        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const icon = document.getElementById(fieldId + 'Icon');
            
            if (field.type === 'password') {
                field.type = 'text';
                icon.textContent = 'Hide';
            } else {
                field.type = 'password';
                icon.textContent = 'Show';
            }
        }

        function validatePasswords() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const submitBtn = document.getElementById('submitBtn');
            const matchIndicator = document.getElementById('matchIndicator');
            
            if (newPassword.length > 0 && confirmPassword.length > 0) {
                if (newPassword === confirmPassword) {
                    matchIndicator.innerHTML = '<span class="text-green-600 text-sm">Passwords match</span>';
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('opacity-50');
                } else {
                    matchIndicator.innerHTML = '<span class="text-red-600 text-sm">Passwords do not match</span>';
                    submitBtn.disabled = true;
                    submitBtn.classList.add('opacity-50');
                }
            } else {
                matchIndicator.innerHTML = '';
                submitBtn.disabled = false;
                submitBtn.classList.remove('opacity-50');
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
                <h2 class="text-3xl font-bold text-gray-900">Reset Password</h2>
                <p class="mt-2 text-gray-600">Create a new password for <strong><%= resetUsername %></strong></p>
            </div>

            <!-- Form Card -->
            <div class="bg-white rounded-lg shadow-md p-8">
                <form method="POST" action="resetPassword.jsp" class="space-y-6">
                    <!-- New Password Field -->
                    <div>
                        <label for="newPassword" class="block text-sm font-medium text-gray-700 mb-2">
                            New Password
                        </label>
                        <div class="relative">
                            <input 
                                type="password" 
                                id="newPassword" 
                                name="newPassword" 
                                required
                                minlength="6"
                                oninput="validatePasswords()"
                                class="w-full px-3 py-3 pr-20 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-theme-500 focus:border-theme-500"
                                placeholder="Enter new password (min 6 characters)"
                            >
                            <button 
                                type="button" 
                                onclick="togglePassword('newPassword')"
                                class="absolute inset-y-0 right-0 pr-3 flex items-center text-sm text-gray-600 hover:text-gray-800"
                            >
                                <span id="newPasswordIcon">Show</span>
                            </button>
                        </div>
                    </div>

                    <!-- Confirm Password Field -->
                    <div>
                        <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
                            Confirm New Password
                        </label>
                        <div class="relative">
                            <input 
                                type="password" 
                                id="confirmPassword" 
                                name="confirmPassword" 
                                required
                                minlength="6"
                                oninput="validatePasswords()"
                                class="w-full px-3 py-3 pr-20 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-theme-500 focus:border-theme-500"
                                placeholder="Confirm your new password"
                            >
                            <button 
                                type="button" 
                                onclick="togglePassword('confirmPassword')"
                                class="absolute inset-y-0 right-0 pr-3 flex items-center text-sm text-gray-600 hover:text-gray-800"
                            >
                                <span id="confirmPasswordIcon">Show</span>
                            </button>
                        </div>
                        <div id="matchIndicator" class="mt-2"></div>
                    </div>

                    <!-- Error/Success Message -->
                    <% if (!message.isEmpty()) { %>
                        <div class="<%= messageType.equals("error") ? "bg-red-50 border border-red-200 text-red-700" : "bg-green-50 border border-green-200 text-green-700" %> px-4 py-3 rounded-lg">
                            <span class="text-sm"><%= message %></span>
                        </div>
                    <% } %>

                    <!-- Submit Button -->
                    <button 
                        type="submit"
                        id="submitBtn"
                        class="w-full py-3 px-4 border border-transparent rounded-lg text-sm font-medium text-white bg-theme-600 hover:bg-theme-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-theme-500 transition-colors"
                    >
                        Update Password
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

            <!-- Security Note -->
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <p class="text-sm text-blue-800">
                    <strong>Security Tip:</strong> Choose a strong password with at least 6 characters for better security.
                </p>
            </div>
        </div>
    </div>
</body>
</html>
<%@ page import="java.sql.*, com.habittracker.DBConnection" %>
<%@ page session="true" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String username = (String) session.getAttribute("username");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String habitId = request.getParameter("habit_id");
    String habitName = "";
    String habitDesc = "";
    
    if (habitId != null && !habitId.isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT habit_name, description FROM habits WHERE id = ? AND user_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, habitId);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                habitName = rs.getString("habit_name");
                habitDesc = rs.getString("description");
                if (habitDesc == null) habitDesc = "";
            } else {
                // Habit not found or doesn't belong to user
                response.sendRedirect("viewHabits.jsp");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        // No habit_id provided
        response.sendRedirect("viewHabits.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Habit - Habit Tracker</title>
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
    <!-- Sticky Header -->
    <header class="bg-white shadow-md border-b border-gray-200 sticky top-0 z-10">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-16">
                <!-- Logo and Brand -->
                <div class="flex items-center">
                    <div class="flex items-center justify-center w-10 h-10 bg-theme-600 rounded-lg mr-3">
                        <span class="text-white font-bold text-lg">H</span>
                    </div>
                    <div>
                        <h1 class="text-xl font-bold text-gray-900">Habit Tracker</h1>
                        <p class="text-sm text-gray-500">Build better habits daily</p>
                    </div>
                </div>

                <!-- Navigation and User Info -->
                <div class="flex items-center space-x-4">
                    <a href="<%= request.getContextPath() %>/jsp/dashboard.jsp" 
                       class="text-gray-600 hover:text-theme-600 font-medium transition-colors">
                        Dashboard
                    </a>
                    <div class="h-6 w-px bg-gray-300"></div>
                    <div class="text-right">
                        <p class="text-sm font-medium text-gray-900">Welcome,</p>
                        <p class="text-sm text-theme-600 font-semibold"><%= username != null ? username : "User" %></p>
                    </div>
                    <div class="h-8 w-px bg-gray-300"></div>
                    <a href="<%= request.getContextPath() %>/LogoutServlet" 
                       class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors">
                        Logout
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Breadcrumb -->
        <nav class="flex mb-6" aria-label="Breadcrumb">
            <ol class="inline-flex items-center space-x-1 md:space-x-3">
                <li class="inline-flex items-center">
                    <a href="<%= request.getContextPath() %>/jsp/dashboard.jsp" 
                       class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-theme-600">
                        Dashboard
                    </a>
                </li>
                <li>
                    <div class="flex items-center">
                        <span class="text-gray-400 mx-2">/</span>
                        <a href="<%= request.getContextPath() %>/jsp/viewHabits.jsp" 
                           class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-theme-600">
                            Your Habits
                        </a>
                    </div>
                </li>
                <li>
                    <div class="flex items-center">
                        <span class="text-gray-400 mx-2">/</span>
                        <span class="text-sm font-medium text-gray-500">Edit Habit</span>
                    </div>
                </li>
            </ol>
        </nav>

        <!-- Page Header -->
        <div class="flex items-center justify-between mb-8">
            <div class="flex items-center">
                <div class="flex items-center justify-center w-12 h-12 bg-theme-100 rounded-lg mr-4">
                    <span class="text-theme-600 font-bold text-xl">E</span>
                </div>
                <div>
                    <h2 class="text-3xl font-bold text-gray-900">Edit Habit</h2>
                    <p class="text-gray-600 mt-1">Update your habit details</p>
                </div>
            </div>
        </div>

        <!-- Edit Form -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 max-w-2xl mx-auto">
            <% 
                String error = request.getParameter("error");
                String success = request.getParameter("success");
                if (error != null) {
            %>
                <div class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                    <p class="text-sm">
                        <% if (error.equals("invalid_data")) { %>
                            Please provide valid habit information.
                        <% } else if (error.equals("not_found")) { %>
                            Habit not found or you don't have permission to edit it.
                        <% } else { %>
                            An error occurred while updating the habit. Please try again.
                        <% } %>
                    </p>
                </div>
            <% } else if (success != null) { %>
                <div class="mb-4 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg">
                    <p class="text-sm">Habit updated successfully!</p>
                </div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/EditHabitServlet">
                <input type="hidden" name="habit_id" value="<%= habitId %>" />
                
                <!-- Habit Name -->
                <div class="mb-6">
                    <label for="habit_name" class="block text-sm font-medium text-gray-700 mb-2">Habit Name</label>
                    <input type="text" 
                           id="habit_name" 
                           name="habit_name" 
                           value="<%= habitName %>"
                           required
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-theme-500 focus:border-theme-500 transition-colors" 
                           placeholder="Enter habit name" />
                </div>
                
                <!-- Description -->
                <div class="mb-6">
                    <label for="description" class="block text-sm font-medium text-gray-700 mb-2">Description (Optional)</label>
                    <textarea id="description" 
                              name="description" 
                              rows="4"
                              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-theme-500 focus:border-theme-500 transition-colors" 
                              placeholder="Enter habit description"><%= habitDesc %></textarea>
                </div>
                
                <!-- Action Buttons -->
                <div class="flex items-center justify-between pt-4 border-t border-gray-100">
                    <a href="<%= request.getContextPath() %>/jsp/viewHabits.jsp" 
                       class="px-6 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors">
                        Cancel
                    </a>
                    <div class="flex space-x-3">
                        <button type="submit" 
                                class="px-6 py-2 bg-theme-600 hover:bg-theme-700 text-white font-medium rounded-lg transition-colors">
                            Save Changes
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-gray-200 mt-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div class="text-center">
                <p class="text-gray-500 text-sm">
                    &copy; 2025 Habit Tracker. Build better habits daily.
                </p>
            </div>
        </div>
    </footer>
</body>
</html>
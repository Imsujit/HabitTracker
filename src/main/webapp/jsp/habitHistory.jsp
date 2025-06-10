<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.*,java.util.Date ,com.habittracker.DBConnection" %>
<%@ page session="true" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String username = (String) session.getAttribute("username");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get habit ID from request parameter
    String habitIdStr = request.getParameter("habit_id");
    int habitId = 0;
    String habitName = "All Habits";
    boolean filterByHabit = false;
    
    if (habitIdStr != null && !habitIdStr.isEmpty()) {
        try {
            habitId = Integer.parseInt(habitIdStr);
            filterByHabit = true;
        } catch (NumberFormatException e) {
            // Invalid habit ID, ignore filter
        }
    }
    
    // Get all user's habits for the filter dropdown
    List<Map<String, Object>> userHabits = new ArrayList<>();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        ps = conn.prepareStatement("SELECT id, habit_name FROM habits WHERE user_id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> habit = new HashMap<>();
            habit.put("id", rs.getInt("id"));
            habit.put("name", rs.getString("habit_name"));
            userHabits.add(habit);
        }
        
        // Get habit name if filtering by habit
        if (filterByHabit) {
            for (Map<String, Object> habit : userHabits) {
                if ((Integer)habit.get("id") == habitId) {
                    habitName = (String)habit.get("name");
                    break;
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    SimpleDateFormat displayDateFormat = new SimpleDateFormat("MMM d, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Habit History - Habit Tracker</title>
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
<body class="min-h-screen bg-gray-50 flex flex-col">
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
    <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
        <!-- Page Header -->
        <div class="flex items-center justify-between mb-6">
            <div class="flex items-center">
                <div class="flex items-center justify-center w-10 h-10 bg-theme-100 rounded-lg mr-3">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-theme-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div>
                    <h2 class="text-2xl font-bold text-gray-900">Habit History</h2>
                    <p class="text-gray-600 text-sm">
                        <%= filterByHabit ? "Viewing: " + habitName : "All habits" %>
                    </p>
                </div>
            </div>
            <a href="<%= request.getContextPath() %>/jsp/viewHabits.jsp" 
               class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors">
                Back to Habits
            </a>
        </div>

        <!-- Simple Filter -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
            <form action="<%= request.getContextPath() %>/jsp/habitHistory.jsp" method="GET" class="flex flex-wrap gap-4">
                <div class="flex-grow min-w-[200px]">
                    <select id="habit_id" name="habit_id" 
                            class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-theme-500 focus:border-theme-500 sm:text-sm">
                        <option value="">All Habits</option>
                        <% for (Map<String, Object> habit : userHabits) { %>
                            <option value="<%= habit.get("id") %>" <%= (filterByHabit && habitId == (Integer)habit.get("id")) ? "selected" : "" %>>
                                <%= habit.get("name") %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <button type="submit" 
                        class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-theme-600 hover:bg-theme-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-theme-500 transition-colors">
                    Filter
                </button>
            </form>
        </div>

        <!-- History Table -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Habit</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <%
                        try {
                            conn = DBConnection.getConnection();
                            
                            String query;
                            if (filterByHabit) {
                                query = "SELECT habit_id, status_date FROM habit_status WHERE user_id = ? AND habit_id = ? ORDER BY status_date DESC LIMIT 50";
                            } else {
                                query = "SELECT habit_id, status_date FROM habit_status WHERE user_id = ? ORDER BY status_date DESC LIMIT 50";
                            }
                            
                            ps = conn.prepareStatement(query);
                            ps.setInt(1, userId);
                            
                            if (filterByHabit) {
                                ps.setInt(2, habitId);
                            }
                            
                            rs = ps.executeQuery();
                            
                            boolean hasData = false;
                            
                            while (rs.next()) {
                                hasData = true;
                                Date statusDate = rs.getDate("status_date");
                                String formattedDate = displayDateFormat.format(statusDate);
                                int currentHabitId = rs.getInt("habit_id");
                                
                                // Get habit name from the list we already loaded
                                String currentHabitName = "Unknown Habit";
                                for (Map<String, Object> habit : userHabits) {
                                    if ((Integer)habit.get("id") == currentHabitId) {
                                        currentHabitName = (String)habit.get("name");
                                        break;
                                    }
                                }
                    %>
                                <tr class="hover:bg-gray-50">
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm font-medium text-gray-900"><%= formattedDate %></div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm text-gray-900"><%= currentHabitName %></div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                            Completed
                                        </span>
                                    </td>
                                </tr>
                    <%
                            }
                            
                            if (!hasData) {
                    %>
                                <tr>
                                    <td colspan="3" class="px-6 py-10 text-center">
                                        <p class="text-gray-500 font-medium">No habit history found</p>
                                        <p class="text-sm text-gray-400 mt-1">
                                            <%= filterByHabit ? "Try selecting a different habit" : "Start marking habits as complete to see your history" %>
                                        </p>
                                    </td>
                                </tr>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                    %>
                            <tr>
                                <td colspan="3" class="px-6 py-10 text-center">
                                    <p class="text-red-500 font-medium">Error: <%= e.getMessage() %></p>
                                    <p class="text-sm text-gray-500 mt-1">Please contact support if this continues</p>
                                </td>
                            </tr>
                    <%
                        } finally {
                            if (rs != null) try { rs.close(); } catch (Exception e) {}
                            if (ps != null) try { ps.close(); } catch (Exception e) {}
                            if (conn != null) try { conn.close(); } catch (Exception e) {}
                        }
                    %>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-gray-200 mt-auto">
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
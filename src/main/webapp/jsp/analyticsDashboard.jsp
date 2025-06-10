<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat,java.util.Date,com.habittracker.DBConnection" %>
<%@ page session="true" %>

<%
Integer userId = (Integer) session.getAttribute("user_id");
String username = (String) session.getAttribute("username");
if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Initialize stats
int totalHabits = 0;
int totalCompletions = 0;
int thisWeekCompletions = 0;
int bestStreak = 0;

// Initialize data for last 7 days activity
Map<String, Integer> last7DaysActivity = new LinkedHashMap<>();
SimpleDateFormat dayFormat = new SimpleDateFormat("EEE"); // Day of week (Mon, Tue, etc.)
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
Calendar cal = Calendar.getInstance();

// Get the actual dates for the last 7 days
for (int i = 6; i >= 0; i--) {
    cal.setTime(new Date());
    cal.add(Calendar.DAY_OF_YEAR, -i);
    String dayName = dayFormat.format(cal.getTime());
    String dateStr = dateFormat.format(cal.getTime());
    last7DaysActivity.put(dateStr + " (" + dayName + ")", 0);
}

// Get habit performance data
List<Map<String, Object>> habitPerformance = new ArrayList<>();

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = DBConnection.getConnection();
    
    // Get total habits
    ps = conn.prepareStatement("SELECT COUNT(*) FROM habits WHERE user_id = ?");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    if (rs.next()) {
        totalHabits = rs.getInt(1);
    }
    rs.close();
    ps.close();
    
    // Get total completions
    ps = conn.prepareStatement("SELECT COUNT(*) FROM habit_status WHERE user_id = ?");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    if (rs.next()) {
        totalCompletions = rs.getInt(1);
    }
    rs.close();
    ps.close();
    
    // Get this week completions
    ps = conn.prepareStatement("SELECT COUNT(*) FROM habit_status WHERE user_id = ? AND status_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    if (rs.next()) {
        thisWeekCompletions = rs.getInt(1);
    }
    rs.close();
    ps.close();
    
    // Get last 7 days activity
    ps = conn.prepareStatement("SELECT DATE_FORMAT(status_date, '%Y-%m-%d') as date, COUNT(*) as count FROM habit_status WHERE user_id = ? AND status_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) GROUP BY date ORDER BY date");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    
    while (rs.next()) {
        String dbDate = rs.getString("date");
        int count = rs.getInt("count");
        
        // Find the matching date in our map and update the count
        for (Map.Entry<String, Integer> entry : last7DaysActivity.entrySet()) {
            if (entry.getKey().startsWith(dbDate)) {
                last7DaysActivity.put(entry.getKey(), count);
                break;
            }
        }
    }
    rs.close();
    ps.close();
    
    // Get habit performance
    ps = conn.prepareStatement(
        "SELECT h.habit_name, " +
        "COUNT(hs.id) as completions, " +
        "MIN(hs.status_date) as first_completion, " +
        "MAX(hs.status_date) as last_completion, " +
        "DATEDIFF(MAX(hs.status_date), MIN(hs.status_date)) + 1 as day_span " +
        "FROM habits h " +
        "LEFT JOIN habit_status hs ON h.id = hs.habit_id AND hs.user_id = ? " +
        "WHERE h.user_id = ? " +
        "GROUP BY h.id " +
        "ORDER BY completions DESC"
    );
    ps.setInt(1, userId);
    ps.setInt(2, userId);
    rs = ps.executeQuery();
    
    SimpleDateFormat displayDateFormat = new SimpleDateFormat("MMM d, yyyy");
    
    while (rs.next()) {
        Map<String, Object> habit = new HashMap<>();
        habit.put("name", rs.getString("habit_name"));
        habit.put("completions", rs.getInt("completions"));
        
        Date firstDate = rs.getDate("first_completion");
        Date lastDate = rs.getDate("last_completion");
        
        if (firstDate != null && lastDate != null) {
            habit.put("first_completion", displayDateFormat.format(firstDate));
            habit.put("last_completion", displayDateFormat.format(lastDate));
            
            int daySpan = rs.getInt("day_span");
            int completions = rs.getInt("completions");
            
            // Calculate consistency (completions / days)
            double consistency = 0;
            if (daySpan > 0) {
                consistency = (double) completions / daySpan * 100;
            }
            habit.put("consistency", String.format("%.1f%%", consistency));
        } else {
            habit.put("first_completion", "Never");
            habit.put("last_completion", "Never");
            habit.put("consistency", "0.0%");
        }
        
        habitPerformance.add(habit);
    }
    
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Dashboard - Habit Tracker</title>
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
        <!-- Page Header -->
        <div class="flex items-center justify-between mb-8">
            <div class="flex items-center">
                <div class="flex items-center justify-center w-12 h-12 bg-theme-100 rounded-lg mr-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-theme-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                </div>
                <div>
                    <h2 class="text-3xl font-bold text-gray-900">Analytics Dashboard</h2>
                    <p class="text-gray-600">Track your habit performance and progress</p>
                </div>
            </div>
            <a href="<%= request.getContextPath() %>/jsp/dashboard.jsp" 
               class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors">
                Back to Dashboard
            </a>
        </div>

        <!-- Stats Overview -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 transition-all duration-200 hover:shadow-md hover:border-theme-200">
                <div class="flex items-center">
                    <div class="flex items-center justify-center w-12 h-12 bg-blue-100 rounded-lg mr-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                        </svg>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-600">Total Habits</p>
                        <p class="text-2xl font-bold text-gray-900"><%= totalHabits %></p>
                    </div>
                </div>
            </div>
            
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 transition-all duration-200 hover:shadow-md hover:border-theme-200">
                <div class="flex items-center">
                    <div class="flex items-center justify-center w-12 h-12 bg-green-100 rounded-lg mr-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-600">Total Completions</p>
                        <p class="text-2xl font-bold text-gray-900"><%= totalCompletions %></p>
                    </div>
                </div>
            </div>
            
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 transition-all duration-200 hover:shadow-md hover:border-theme-200">
                <div class="flex items-center">
                    <div class="flex items-center justify-center w-12 h-12 bg-purple-100 rounded-lg mr-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                        </svg>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-600">This Week</p>
                        <p class="text-2xl font-bold text-gray-900"><%= thisWeekCompletions %></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Last 7 Days Activity -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Last 7 Days Activity</h3>
            
            <div class="grid grid-cols-7 gap-2">
                <% for (Map.Entry<String, Integer> entry : last7DaysActivity.entrySet()) { %>
                    <div class="flex flex-col items-center">
                        <div class="text-xs text-gray-500 mb-2"><%= entry.getKey().split(" ")[1].replace("(", "").replace(")", "") %></div>
                        <div class="w-full bg-gray-100 rounded-lg overflow-hidden">
                            <div class="bg-theme-500 h-24 rounded-lg" style="height: <%= Math.min(entry.getValue() * 12, 96) %>px;"></div>
                        </div>
                        <div class="text-xs font-medium mt-2 <%= entry.getValue() > 0 ? "text-theme-600" : "text-gray-400" %>">
                            <%= entry.getValue() %>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Habit Performance -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Habit Performance</h3>
            
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Habit</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Completions</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">First Completion</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Completion</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Consistency</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <% if (habitPerformance.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="px-6 py-10 text-center text-gray-500">
                                    No habit data available yet. Start tracking your habits to see performance metrics.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Map<String, Object> habit : habitPerformance) { %>
                                <tr class="hover:bg-gray-50">
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm font-medium text-gray-900"><%= habit.get("name") %></div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm text-gray-900"><%= habit.get("completions") %></div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm text-gray-500"><%= habit.get("first_completion") %></div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm text-gray-500"><%= habit.get("last_completion") %></div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm text-gray-900"><%= habit.get("consistency") %></div>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
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
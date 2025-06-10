<%@ page import="java.sql.*, com.habittracker.DBConnection, com.habittracker.HabitUtils" %>
<%@ page session="true" %>

<%
Integer userId = (Integer) session.getAttribute("user_id");
String username = (String) session.getAttribute("username");
if (userId == null) {
    response.sendRedirect("../jsp/login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Your Habits - Habit Tracker</title>
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
                    <span class="text-sm font-medium text-gray-500">Your Habits</span>
                </div>
            </li>
        </ol>
    </nav>

    <!-- Page Header with Action Buttons -->
    <div class="flex items-center justify-between mb-8">
        <div class="flex items-center">
            <div class="flex items-center justify-center w-12 h-12 bg-theme-100 rounded-lg mr-4">
                <span class="text-theme-600 font-bold text-xl">H</span>
            </div>
            <div>
                <h2 class="text-3xl font-bold text-gray-900">Your Habits</h2>
                <p class="text-gray-600 mt-1">Track and manage your daily habits</p>
            </div>
        </div>
        <div class="flex items-center space-x-3">
            <a href="<%= request.getContextPath() %>/jsp/addHabit.jsp" 
               class="inline-flex items-center px-4 py-2 bg-theme-600 hover:bg-theme-700 text-white font-semibold rounded-lg transition-colors shadow-sm">
                <span class="mr-2">+</span>
                Add New Habit
            </a>
        </div>
    </div>

    <!-- Habits Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
<%
try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
         "SELECT id, habit_name, description, created_date FROM habits WHERE user_id = ?"
     )) {
    ps.setInt(1, userId);
    try (ResultSet rs = ps.executeQuery()) {
        boolean hasHabits = false;
        while (rs.next()) {
            hasHabits = true;
            int habitId    = rs.getInt("id");
            String name    = rs.getString("habit_name");
            String desc    = rs.getString("description");
            Timestamp cd   = rs.getTimestamp("created_date");

            // Progress last 7 days
            int doneCount = 0;
            try (PreparedStatement p2 = conn.prepareStatement(
                    "SELECT COUNT(*) FROM habit_status WHERE user_id=? AND habit_id=? AND status_date>=CURDATE()-INTERVAL 6 DAY"
                 )) {
                p2.setInt(1, userId);
                p2.setInt(2, habitId);
                try (ResultSet r2 = p2.executeQuery()) {
                    if (r2.next()) doneCount = r2.getInt(1);
                }
            }
            int percent = (int)(doneCount/7.0*100);

            // Check if marked today
            boolean isMarked = false;
            try (PreparedStatement p3 = conn.prepareStatement(
                    "SELECT 1 FROM habit_status WHERE user_id=? AND habit_id=? AND status_date=CURDATE()"
                 )) {
                p3.setInt(1, userId);
                p3.setInt(2, habitId);
                try (ResultSet r3 = p3.executeQuery()) {
                    isMarked = r3.next();
                }
            }

            // Streaks
            int currentStreak = HabitUtils.getCurrentStreak(conn, userId, habitId);
            int longestStreak = HabitUtils.getLongestStreak(conn, userId, habitId);
%>
        <!-- Habit Card -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-all duration-200">
            <!-- Card Header -->
            <div class="flex items-start justify-between mb-4">
                <div class="flex-1">
                    <h3 class="text-lg font-semibold text-gray-900 mb-1"><%= name %></h3>
                    <p class="text-sm text-gray-500">ID: <%= habitId %></p>
                </div>
                <div class="ml-4">
                    <form method="post" action="<%= request.getContextPath() %>/<%= isMarked ? "UnmarkHabitServlet" : "MarkHabitServlet" %>" class="inline">
                        <input type="hidden" name="habit_id" value="<%= habitId %>"/>
                        <button type="submit" class="px-4 py-2 rounded-lg font-medium text-sm transition-colors <%= isMarked ? "bg-orange-100 text-orange-700 hover:bg-orange-200" : "bg-green-100 text-green-700 hover:bg-green-200" %>">
                            <%= isMarked ? "Unmark" : "Mark Done" %>
                        </button>
                    </form>
                </div>
            </div>

            <!-- Description -->
            <div class="mb-4">
                <p class="text-sm text-gray-600">
                    <%= desc != null && !desc.trim().isEmpty() ? desc : "No description provided" %>
                </p>
            </div>

            <!-- Progress Section -->
            <div class="mb-4">
                <div class="flex items-center justify-between mb-2">
                    <span class="text-sm font-medium text-gray-700">7-Day Progress</span>
                    <span class="text-sm font-bold text-theme-600"><%= percent %>%</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                    <div class="bg-theme-600 h-2 rounded-full transition-all duration-300" style="width: <%= percent %>%"></div>
                </div>
            </div>

            <!-- Stats Row -->
            <div class="grid grid-cols-3 gap-4 mb-4">
                <div class="text-center">
                    <div class="text-lg font-bold text-theme-600"><%= currentStreak %></div>
                    <div class="text-xs text-gray-500">Current Streak</div>
                </div>
                <div class="text-center">
                    <div class="text-lg font-bold text-yellow-600"><%= longestStreak %></div>
                    <div class="text-xs text-gray-500">Best Streak</div>
                </div>
                <div class="text-center">
                    <div class="text-lg font-bold text-gray-600"><%= doneCount %>/7</div>
                    <div class="text-xs text-gray-500">This Week</div>
                </div>
            </div>

            <!-- Actions -->
            <div class="pt-4 border-t border-gray-100 flex justify-between items-center">
                <p class="text-xs text-gray-500">Created: <%= cd %></p>
                <div class="flex space-x-2">
                    <form method="post" action="<%= request.getContextPath() %>/jsp/editHabit.jsp" class="inline">
                        <input type="hidden" name="habit_id" value="<%= habitId %>"/>
                        <button type="submit" class="inline-flex items-center px-2 py-1 border border-blue-300 text-xs font-medium rounded text-blue-700 bg-blue-50 hover:bg-blue-100 transition-colors">
                            Edit
                        </button>
                    </form>
                    <form method="post" action="<%= request.getContextPath() %>/DeleteHabitServlet" onsubmit="return confirm('Are you sure you want to delete this habit?');" class="inline">
                        <input type="hidden" name="habit_id" value="<%= habitId %>"/>
                        <button type="submit" class="inline-flex items-center px-2 py-1 border border-red-300 text-xs font-medium rounded text-red-700 bg-red-50 hover:bg-red-100 transition-colors">
                            Delete
                        </button>
                    </form>
                </div>
            </div>
        </div>
<%
        }
        if (!hasHabits) {
%>
        <!-- Empty State -->
        <div class="col-span-full">
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-12 text-center">
                <div class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-gray-400 text-3xl font-bold">H</span>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 mb-2">No habits yet</h3>
                <p class="text-gray-500 mb-6 max-w-md mx-auto">Start building better habits by creating your first one. Small daily actions lead to big changes over time.</p>
                <a href="<%= request.getContextPath() %>/jsp/addHabit.jsp" 
                   class="inline-flex items-center px-6 py-3 bg-theme-600 hover:bg-theme-700 text-white font-semibold rounded-lg transition-colors shadow-sm">
                    <span class="mr-2">+</span>
                    Create Your First Habit
                </a>
            </div>
        </div>
<%
        }
    }
} catch (Exception e) {
%>
        <!-- Error State -->
        <div class="col-span-full">
            <div class="bg-white rounded-xl shadow-sm border border-red-200 p-12 text-center">
                <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-red-500 text-3xl font-bold">!</span>
                </div>
                <h3 class="text-xl font-semibold text-red-900 mb-2">Error Loading Habits</h3>
                <p class="text-red-600 mb-6">There was a problem loading your habits. Please try refreshing the page.</p>
                <button onclick="window.location.reload()" 
                        class="inline-flex items-center px-6 py-3 bg-red-600 hover:bg-red-700 text-white font-semibold rounded-lg transition-colors shadow-sm">
                    Refresh Page
                </button>
            </div>
        </div>
<%
}
%>
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
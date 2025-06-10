<%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Habit Tracker</title>
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
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                    </div>
                    <div>
                        <h1 class="text-xl font-bold text-gray-900">Habit Tracker</h1>
                        <p class="text-sm text-gray-500">Build better habits daily</p>
                    </div>
                </div>

                <!-- User Info and Logout -->
                <div class="flex items-center space-x-4">
                    <div class="text-right">
                        <p class="text-sm font-medium text-gray-900">Welcome back,</p>
                        <p class="text-sm text-theme-600 font-semibold"><%= username %></p>
                    </div>
                    <div class="h-8 w-px bg-gray-300"></div>
                    <a href="<%= request.getContextPath() %>/LogoutServlet" 
                       class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                        </svg>
                        Logout
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Welcome Section -->
        <div class="mb-8">
            <h2 class="text-3xl font-bold text-gray-900 mb-2">Dashboard</h2>
            <p class="text-gray-600">Manage your habits and track your progress towards a better you.</p>
        </div>

        <!-- Navigation Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Add New Habit -->
            <a href="<%= request.getContextPath() %>/jsp/addHabit.jsp" 
               class="group bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-all duration-200 hover:scale-[1.02]">
                <div class="flex items-center mb-4">
                    <div class="flex items-center justify-center w-12 h-12 bg-theme-100 rounded-lg group-hover:bg-theme-200 transition-colors">
                        <svg class="w-6 h-6 text-theme-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">Add New Habit</h3>
                <p class="text-gray-600 text-sm">Create a new habit to start tracking your daily progress and build consistency.</p>
                <div class="mt-4 flex items-center text-theme-600 text-sm font-medium">
                    Get started
                    <svg class="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                </div>
            </a>

            <!-- View My Habits -->
            <a href="<%= request.getContextPath() %>/jsp/viewHabits.jsp" 
               class="group bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-all duration-200 hover:scale-[1.02]">
                <div class="flex items-center mb-4">
                    <div class="flex items-center justify-center w-12 h-12 bg-green-100 rounded-lg group-hover:bg-green-200 transition-colors">
                        <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">View My Habits</h3>
                <p class="text-gray-600 text-sm">Check off today's habits and see your current progress across all your goals.</p>
                <div class="mt-4 flex items-center text-theme-600 text-sm font-medium">
                    View habits
                    <svg class="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                </div>
            </a>

            <!-- Habit History -->
            <a href="<%= request.getContextPath() %>/jsp/habitHistory.jsp" 
               class="group bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-all duration-200 hover:scale-[1.02]">
                <div class="flex items-center mb-4">
                    <div class="flex items-center justify-center w-12 h-12 bg-purple-100 rounded-lg group-hover:bg-purple-200 transition-colors">
                        <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">Habit History</h3>
                <p class="text-gray-600 text-sm">Review your past performance and see how you've progressed over time.</p>
                <div class="mt-4 flex items-center text-theme-600 text-sm font-medium">
                    View history
                    <svg class="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                </div>
            </a>

            <!-- Achievements -->
            <a href="<%= request.getContextPath() %>/jsp/achievements.jsp" 
               class="group bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-all duration-200 hover:scale-[1.02]">
                <div class="flex items-center mb-4">
                    <div class="flex items-center justify-center w-12 h-12 bg-yellow-100 rounded-lg group-hover:bg-yellow-200 transition-colors">
                        <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">Achievements</h3>
                <p class="text-gray-600 text-sm">Celebrate your milestones and unlock badges for your dedication and consistency.</p>
                <div class="mt-4 flex items-center text-theme-600 text-sm font-medium">
                    View achievements
                    <svg class="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                </div>
            </a>

            <!-- Analytics Dashboard -->
            <a href="<%= request.getContextPath() %>/jsp/analyticsDashboard.jsp" 
               class="group bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-all duration-200 hover:scale-[1.02]">
                <div class="flex items-center mb-4">
                    <div class="flex items-center justify-center w-12 h-12 bg-indigo-100 rounded-lg group-hover:bg-indigo-200 transition-colors">
                        <svg class="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">Analytics Dashboard</h3>
                <p class="text-gray-600 text-sm">Dive deep into your habit data with detailed charts and insights about your progress.</p>
                <div class="mt-4 flex items-center text-theme-600 text-sm font-medium">
                    View analytics
                    <svg class="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                </div>
            </a>

            <!-- Quick Action Card -->
            <div class="bg-gradient-to-br from-theme-500 to-theme-600 rounded-xl shadow-sm p-6 text-white">
                <div class="flex items-center mb-4">
                    <div class="flex items-center justify-center w-12 h-12 bg-white bg-opacity-20 rounded-lg">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                        </svg>
                    </div>
                </div>
                <h3 class="text-lg font-semibold mb-2">Quick Tip</h3>
                <p class="text-teal-100 text-sm mb-4">Start small! Focus on building one habit at a time for better success rates.</p>
                <div class="text-white text-sm font-medium">
                    #  Pro tip of the day
                </div>
            </div>
        </div>

        <!-- Recent Activity Section -->

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
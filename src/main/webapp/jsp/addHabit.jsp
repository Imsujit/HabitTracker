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
    <title>Add Habit - Habit Tracker</title>
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
                        <p class="text-sm text-theme-600 font-semibold"><%= username %></p>
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
    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
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
                        <span class="text-sm font-medium text-gray-500">Add Habit</span>
                    </div>
                </li>
            </ol>
        </nav>

        <!-- Page Header -->
        <div class="mb-8">
            <div class="flex items-center mb-4">
                <div class="flex items-center justify-center w-12 h-12 bg-theme-100 rounded-lg mr-4">
                    <span class="text-theme-600 font-bold text-xl">+</span>
                </div>
                <div>
                    <h2 class="text-3xl font-bold text-gray-900">Add New Habit</h2>
                    <p class="text-gray-600 mt-1">Create a new habit to start tracking your daily progress</p>
                </div>
            </div>
        </div>

        <!-- Add Habit Form -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-8">
            <form action="<%= request.getContextPath() %>/AddHabitServlet" method="post" class="space-y-6">
                <!-- Habit Name -->
                <div>
                    <label for="habit_name" class="block text-sm font-medium text-gray-700 mb-2">
                        Habit Name <span class="text-red-500">*</span>
                    </label>
                    <input 
                        type="text" 
                        id="habit_name"
                        name="habit_name" 
                        required 
                        maxlength="100"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-theme-500 focus:border-theme-500 transition-colors"
                        placeholder="e.g., Drink 8 glasses of water, Read for 30 minutes"
                    />
                    <p class="text-xs text-gray-500 mt-1">Choose a clear, specific name for your habit</p>
                </div>

                <!-- Description -->
                <div>
                    <label for="description" class="block text-sm font-medium text-gray-700 mb-2">
                        Description
                    </label>
                    <textarea 
                        id="description"
                        name="description" 
                        rows="4"
                        maxlength="500"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-theme-500 focus:border-theme-500 transition-colors resize-none"
                        placeholder="Describe your habit, why it's important to you, or any specific details..."
                    ></textarea>
                    <p class="text-xs text-gray-500 mt-1">Optional: Add more details about your habit (max 500 characters)</p>
                </div>

                <!-- Action Buttons -->
                <div class="flex items-center justify-between pt-6 border-t border-gray-200">
                    <a href="<%= request.getContextPath() %>/jsp/dashboard.jsp" 
                       class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors">
                        Back to Dashboard
                    </a>
                    <button 
                        type="submit" 
                        class="inline-flex items-center px-6 py-3 bg-theme-600 hover:bg-theme-700 text-white font-semibold rounded-lg transition-all duration-200 transform hover:scale-[1.02] focus:outline-none focus:ring-2 focus:ring-theme-500 focus:ring-offset-2 shadow-sm"
                    >
                        Create Habit
                    </button>
                </div>
            </form>
        </div>

        <!-- Tips Section -->
        <div class="mt-8 bg-theme-50 border border-theme-200 rounded-xl p-6">
            <div class="flex items-start">
                <div class="flex items-center justify-center w-8 h-8 bg-theme-100 rounded-lg mr-3 mt-0.5">
                    <span class="text-theme-600 font-bold">!</span>
                </div>
                <div>
                    <h3 class="text-lg font-semibold text-theme-900 mb-2">Tips for Creating Effective Habits</h3>
                    <ul class="text-sm text-theme-800 space-y-1">
                        <li>- Start small: Begin with habits that take less than 2 minutes</li>
                        <li>- Be specific: "Read 10 pages" is better than "Read more"</li>
                        <li>- Stack habits: Link new habits to existing routines</li>
                        <li>- Focus on consistency: Daily habits are easier to maintain than sporadic ones</li>
                    </ul>
                </div>
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
<%@ page import="java.sql.*, java.util.*,java.util.Date, com.habittracker.DBConnection" %>
<%@ page session="true" %>

<%
Integer userId = (Integer) session.getAttribute("user_id");
String username = (String) session.getAttribute("username");
if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Simple achievement data structure
class Achievement {
    String title;
    String description;
    String icon;
    boolean unlocked;
    String progress;
    String requirement;
    String category;
    
    Achievement(String title, String description, String icon, boolean unlocked, String progress, String requirement, String category) {
        this.title = title;
        this.description = description;
        this.icon = icon;
        this.unlocked = unlocked;
        this.progress = progress;
        this.requirement = requirement;
        this.category = category;
    }
}

List<Achievement> achievements = new ArrayList<Achievement>();
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

// Initialize counters
int totalCompletions = 0;
int totalHabits = 0;
int uniqueCompletionDays = 0;
int longestStreak = 0;
int currentStreak = 0;

try {
    conn = DBConnection.getConnection();
    
    // Get total completions
    ps = conn.prepareStatement("SELECT COUNT(*) as total FROM habit_status WHERE user_id = ?");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    if (rs.next()) {
        totalCompletions = rs.getInt("total");
    }
    rs.close();
    ps.close();
    
    // Get total habits
    ps = conn.prepareStatement("SELECT COUNT(*) as total FROM habits WHERE user_id = ?");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    if (rs.next()) {
        totalHabits = rs.getInt("total");
    }
    rs.close();
    ps.close();
    
    // Get unique completion days
    ps = conn.prepareStatement("SELECT COUNT(DISTINCT status_date) as unique_days FROM habit_status WHERE user_id = ?");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    if (rs.next()) {
        uniqueCompletionDays = rs.getInt("unique_days");
    }
    rs.close();
    ps.close();
    
    // Calculate streak (simplified - consecutive days with any habit completion)
    ps = conn.prepareStatement("SELECT DISTINCT status_date FROM habit_status WHERE user_id = ? ORDER BY status_date DESC LIMIT 30");
    ps.setInt(1, userId);
    rs = ps.executeQuery();
    
    List<Date> completionDates = new ArrayList<Date>();
    while (rs.next()) {
        completionDates.add(rs.getDate("status_date"));
    }
    
    // Calculate current and longest streak
    if (!completionDates.isEmpty()) {
        currentStreak = 1;
        longestStreak = 1;
        int tempStreak = 1;
        
        for (int i = 1; i < completionDates.size(); i++) {
            Date current = completionDates.get(i);
            Date previous = completionDates.get(i-1);
            
            long diffInMillies = previous.getTime() - current.getTime();
            long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
            
            if (diffInDays == 1) {
                tempStreak++;
                if (i == 1) currentStreak = tempStreak;
            } else {
                longestStreak = Math.max(longestStreak, tempStreak);
                tempStreak = 1;
                if (i == 1) currentStreak = 1;
            }
        }
        longestStreak = Math.max(longestStreak, tempStreak);
    }
    
    rs.close();
    ps.close();
    
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}

// Create achievements with simple text icons that will work in Eclipse
achievements.add(new Achievement(
    "First Step",
    "Complete your very first habit",
    "1ST",
    totalCompletions >= 1,
    totalCompletions + "/1",
    "Complete 1 habit",
    "Beginner"
));

achievements.add(new Achievement(
    "Getting Started", 
    "Complete 10 habits in total",
    "10+",
    totalCompletions >= 10,
    totalCompletions + "/10",
    "Complete 10 habits",
    "Beginner"
));

achievements.add(new Achievement(
    "Habit Builder",
    "Create 3 different habits",
    "3H",
    totalHabits >= 3,
    totalHabits + "/3",
    "Create 3 habits",
    "Builder"
));

achievements.add(new Achievement(
    "Week Warrior",
    "Complete habits on 7 different days",
    "7D",
    uniqueCompletionDays >= 7,
    uniqueCompletionDays + "/7",
    "7 active days",
    "Consistency"
));

achievements.add(new Achievement(
    "Consistency Champion",
    "Maintain a 7-day streak",
    "S7",
    longestStreak >= 7,
    longestStreak + "/7",
    "7-day streak",
    "Consistency"
));

achievements.add(new Achievement(
    "Habit Collector",
    "Create 5 different habits",
    "5H",
    totalHabits >= 5,
    totalHabits + "/5",
    "Create 5 habits",
    "Builder"
));

achievements.add(new Achievement(
    "Milestone Master",
    "Complete 50 habits in total",
    "50+",
    totalCompletions >= 50,
    totalCompletions + "/50",
    "Complete 50 habits",
    "Milestone"
));

achievements.add(new Achievement(
    "Streak Legend",
    "Maintain a 30-day streak",
    "S30",
    longestStreak >= 30,
    longestStreak + "/30",
    "30-day streak",
    "Legendary"
));

achievements.add(new Achievement(
    "Century Club",
    "Complete 100 habits in total",
    "100",
    totalCompletions >= 100,
    totalCompletions + "/100",
    "Complete 100 habits",
    "Milestone"
));

// Count unlocked achievements
int unlockedCount = 0;
for (Achievement achievement : achievements) {
    if (achievement.unlocked) {
        unlockedCount++;
    }
}

int progressPercentage = achievements.size() > 0 ? (unlockedCount * 100) / achievements.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Achievements - Habit Tracker</title>
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
                    },
                    animation: {
                        'bounce-slow': 'bounce 2s infinite',
                        'pulse-slow': 'pulse 3s infinite',
                        'wiggle': 'wiggle 1s ease-in-out infinite',
                        'glow': 'glow 2s ease-in-out infinite alternate',
                        'float': 'float 3s ease-in-out infinite',
                    },
                    keyframes: {
                        wiggle: {
                            '0%, 100%': { transform: 'rotate(-3deg)' },
                            '50%': { transform: 'rotate(3deg)' },
                        },
                        glow: {
                            '0%': { boxShadow: '0 0 5px rgba(20, 184, 166, 0.5)' },
                            '100%': { boxShadow: '0 0 20px rgba(20, 184, 166, 0.8)' },
                        },
                        float: {
                            '0%, 100%': { transform: 'translateY(0px)' },
                            '50%': { transform: 'translateY(-10px)' },
                        }
                    }
                }
            }
        }
    </script>
    <style>
        .achievement-card {
            transition: all 0.3s ease;
        }
        .achievement-card:hover {
            transform: translateY(-5px);
        }
        .unlocked-card {
            background: linear-gradient(135deg, #f0fdfa 0%, #ccfbf1 100%);
        }
        .locked-card {
            background: linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%);
        }
        .progress-bar {
            transition: width 0.5s ease-in-out;
        }
        .icon-text {
            font-family: 'Courier New', monospace;
            font-weight: bold;
            font-size: 1.2rem;
            letter-spacing: 1px;
        }
    </style>
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
                <div class="flex items-center justify-center w-12 h-12 bg-yellow-100 rounded-lg mr-4 animate-float">
                    <span class="text-2xl font-bold">A</span>
                </div>
                <div>
                    <h2 class="text-3xl font-bold text-gray-900">Achievements</h2>
                    <p class="text-gray-600">Unlock rewards as you build better habits</p>
                </div>
            </div>
            <a href="<%= request.getContextPath() %>/jsp/dashboard.jsp" 
               class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors">
                Back to Dashboard
            </a>
        </div>

        <!-- Achievement Stats -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white rounded-xl shadow-lg border border-gray-200 p-6 achievement-card">
                <div class="flex items-center">
                    <div class="flex items-center justify-center w-12 h-12 bg-green-100 rounded-lg mr-4 animate-pulse-slow">
                        <span class="text-xl font-bold text-green-600">OK</span>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-600">Unlocked</p>
                        <p class="text-3xl font-bold text-green-600"><%= unlockedCount %></p>
                    </div>
                </div>
            </div>
            
            <div class="bg-white rounded-xl shadow-lg border border-gray-200 p-6 achievement-card">
                <div class="flex items-center">
                    <div class="flex items-center justify-center w-12 h-12 bg-blue-100 rounded-lg mr-4">
                        <span class="text-xl font-bold text-blue-600">ALL</span>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-600">Total</p>
                        <p class="text-3xl font-bold text-blue-600"><%= achievements.size() %></p>
                    </div>
                </div>
            </div>
            
            <div class="bg-white rounded-xl shadow-lg border border-gray-200 p-6 achievement-card">
                <div class="flex items-center">
                    <div class="flex items-center justify-center w-12 h-12 bg-purple-100 rounded-lg mr-4">
                        <span class="text-xl font-bold text-purple-600">%</span>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-600">Progress</p>
                        <p class="text-3xl font-bold text-purple-600"><%= progressPercentage %>%</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Achievements Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <% for (Achievement achievement : achievements) { %>
                <div class="achievement-card rounded-xl shadow-lg border-2 overflow-hidden <%= achievement.unlocked ? "unlocked-card border-green-200 animate-glow" : "locked-card border-gray-200" %>">
                    <div class="p-6">
                        <!-- Category Badge -->
                        <div class="flex justify-between items-start mb-4">
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <%= achievement.unlocked ? "bg-green-100 text-green-800" : "bg-gray-100 text-gray-600" %>">
                                <%= achievement.category %>
                            </span>
                            <% if (achievement.unlocked) { %>
                                <div class="flex items-center justify-center w-8 h-8 bg-green-500 rounded-full animate-bounce-slow">
                                    <span class="text-white font-bold text-sm">OK</span>
                                </div>
                            <% } else { %>
                                <div class="flex items-center justify-center w-8 h-8 bg-gray-300 rounded-full">
                                    <span class="text-gray-500 font-bold text-sm">X</span>
                                </div>
                            <% } %>
                        </div>

                        <!-- Achievement Icon and Title -->
                        <div class="flex items-center mb-4">
                            <div class="flex items-center justify-center w-16 h-16 <%= achievement.unlocked ? "bg-green-100" : "bg-gray-100" %> rounded-xl mr-4 <%= achievement.unlocked ? "animate-wiggle" : "" %>">
                                <span class="icon-text <%= achievement.unlocked ? "text-green-600" : "text-gray-400" %>">
                                    <%= achievement.icon %>
                                </span>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold <%= achievement.unlocked ? "text-gray-900" : "text-gray-500" %>">
                                    <%= achievement.title %>
                                </h3>
                                <p class="text-sm <%= achievement.unlocked ? "text-gray-600" : "text-gray-400" %>">
                                    <%= achievement.description %>
                                </p>
                            </div>
                        </div>

                        <!-- Progress Bar -->
                        <div class="mb-4">
                            <div class="flex justify-between text-sm mb-2">
                                <span class="<%= achievement.unlocked ? "text-gray-600" : "text-gray-400" %>">Progress</span>
                                <span class="<%= achievement.unlocked ? "text-green-600 font-semibold" : "text-gray-500" %>">
                                    <%= achievement.progress %>
                                </span>
                            </div>
                            <div class="w-full bg-gray-200 rounded-full h-2">
                                <%
                                    String[] progressParts = achievement.progress.split("/");
                                    int current = 0;
                                    int total = 1;
                                    try {
                                        current = Integer.parseInt(progressParts[0]);
                                        total = Integer.parseInt(progressParts[1]);
                                    } catch (Exception e) {}
                                    int progressPercent = total > 0 ? Math.min((current * 100) / total, 100) : 0;
                                %>
                                <div class="progress-bar <%= achievement.unlocked ? "bg-green-500" : "bg-theme-500" %> h-2 rounded-full" style="width: <%= progressPercent %>%"></div>
                            </div>
                        </div>

                        <!-- Requirement -->
                        <div class="text-center">
                            <p class="text-xs <%= achievement.unlocked ? "text-gray-500" : "text-gray-400" %>">
                                Requirement: <%= achievement.requirement %>
                            </p>
                        </div>

                        <!-- Status -->
                        <div class="mt-4 pt-4 border-t <%= achievement.unlocked ? "border-green-200" : "border-gray-200" %>">
                            <% if (achievement.unlocked) { %>
                                <div class="flex items-center justify-center text-green-600">
                                    <span class="text-green-600 font-bold mr-2">#</span>
                                    <span class="text-sm font-semibold">Achievement Unlocked!</span>
                                </div>
                            <% } else { %>
                                <div class="flex items-center justify-center text-gray-400">
                                    <span class="text-gray-400 font-bold mr-2">-</span>
                                    <span class="text-sm">Keep going to unlock!</span>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } %>
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
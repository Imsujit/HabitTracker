<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Habit Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: {
                            50: '#eff6ff',
                            500: '#3b82f6',
                            600: '#2563eb',
                            700: '#1d4ed8'
                        }
                    }
                }
            }
        }
    </script>
</head>
<body class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 flex items-center justify-center p-6">
    <div class="w-full max-w-sm">
        <!-- Brand Header -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-14 h-14 bg-primary-600 rounded-xl mb-4 shadow-lg">
                <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
            </div>
            <h1 class="text-2xl font-bold text-gray-900 mb-2">Habit Tracker</h1>
            <p class="text-gray-600">Create your account to get started</p>
        </div>

        <!-- Register Card -->
        <div class="bg-white rounded-xl shadow-lg border border-gray-100 p-6">
            <!-- Error Message -->
            <%
                String registerError = (String) session.getAttribute("registerError");
                if (registerError != null) {
            %>
                <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                    <div class="flex items-start">
                        <svg class="w-5 h-5 text-red-500 mt-0.5 mr-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
                        </svg>
                        <p class="text-red-800 text-sm font-medium">
                            Username already exists. Please choose a different username.
                        </p>
                    </div>
                </div>
            <%
                    session.removeAttribute("registerError");
                }
            %>

            <!-- Form -->
            <form action="<%= request.getContextPath() %>/RegisterServlet" method="post" class="space-y-4" onsubmit="return validateForm()">
                <!-- Username -->
                <div>
                    <label for="username" class="block text-sm font-medium text-gray-700 mb-2">
                        Username
                    </label>
                    <div class="relative">
                        <input 
                            type="text" 
                            id="username"
                            name="username" 
                            required 
                            minlength="3"
                            maxlength="20"
                            class="w-full px-4 py-3 pl-11 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
                            placeholder="Choose a username"
                        />
                        <svg class="w-5 h-5 text-gray-400 absolute left-3 top-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                    </div>
                    <p class="text-xs text-gray-500 mt-1">3-20 characters</p>
                </div>

                <!-- Password -->
                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                        Password
                    </label>
                    <div class="relative">
                        <input 
                            type="password" 
                            id="password"
                            name="password" 
                            required 
                            minlength="6"
                            class="w-full px-4 py-3 pl-11 pr-11 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
                            placeholder="Create a password"
                            oninput="checkPasswordStrength()"
                        />
                        <svg class="w-5 h-5 text-gray-400 absolute left-3 top-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                        </svg>
                        <button 
                            type="button" 
                            onclick="togglePassword()"
                            class="absolute right-3 top-3.5 text-gray-400 hover:text-gray-600 transition-colors"
                        >
                            <svg id="eye-open" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                            </svg>
                            <svg id="eye-closed" class="w-5 h-5 hidden" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21"></path>
                            </svg>
                        </button>
                    </div>
                    
                    <!-- Password Strength -->
                    <div class="mt-2">
                        <div class="flex space-x-1">
                            <div id="strength-1" class="h-1 w-1/4 bg-gray-200 rounded transition-colors"></div>
                            <div id="strength-2" class="h-1 w-1/4 bg-gray-200 rounded transition-colors"></div>
                            <div id="strength-3" class="h-1 w-1/4 bg-gray-200 rounded transition-colors"></div>
                            <div id="strength-4" class="h-1 w-1/4 bg-gray-200 rounded transition-colors"></div>
                        </div>
                        <p id="strength-text" class="text-xs text-gray-500 mt-1">Minimum 6 characters</p>
                    </div>
                </div>

                <!-- Confirm Password -->
                <div>
                    <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
                        Confirm Password
                    </label>
                    <div class="relative">
                        <input 
                            type="password" 
                            id="confirmPassword"
                            name="confirmPassword" 
                            required 
                            class="w-full px-4 py-3 pl-11 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
                            placeholder="Confirm your password"
                            oninput="checkPasswordMatch()"
                        />
                        <svg class="w-5 h-5 text-gray-400 absolute left-3 top-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                    </div>
                    <p id="password-match" class="text-xs mt-1 hidden"></p>
                </div>

                <!-- Terms -->
                <div class="flex items-start pt-2">
                    <input 
                        type="checkbox" 
                        id="terms" 
                        required
                        class="mt-1 h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                    />
                    <label for="terms" class="ml-3 text-sm text-gray-600">
                        I agree to the 
                        <a href="#" class="text-primary-600 hover:text-primary-700 font-medium">Terms of Service</a> 
                        and 
                        <a href="#" class="text-primary-600 hover:text-primary-700 font-medium">Privacy Policy</a>
                    </label>
                </div>

                <!-- Submit Button -->
                <button 
                    type="submit" 
                    class="w-full bg-primary-600 hover:bg-primary-700 text-white font-semibold py-3 px-4 rounded-lg transition-all duration-200 transform hover:scale-[1.02] focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 shadow-sm"
                >
                    Create Account
                </button>
            </form>

            <!-- Login Link -->
            <div class="mt-6 text-center pt-4 border-t border-gray-100">
                <p class="text-gray-600">
                    Already have an account? 
                    <a href="<%= request.getContextPath() %>/jsp/login.jsp" 
                       class="text-primary-600 hover:text-primary-700 font-semibold transition-colors">
                        Sign in
                    </a>
                </p>
            </div>
        </div>

        <!-- Footer -->
        <div class="text-center mt-6">
            <p class="text-gray-500 text-sm">
                © 2025 Habit Tracker. Build better habits daily.
            </p>
        </div>
    </div>

    <script>
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const eyeOpen = document.getElementById('eye-open');
            const eyeClosed = document.getElementById('eye-closed');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeOpen.classList.add('hidden');
                eyeClosed.classList.remove('hidden');
            } else {
                passwordInput.type = 'password';
                eyeOpen.classList.remove('hidden');
                eyeClosed.classList.add('hidden');
            }
        }

        function checkPasswordStrength() {
            const password = document.getElementById('password').value;
            const strengthBars = [
                document.getElementById('strength-1'),
                document.getElementById('strength-2'),
                document.getElementById('strength-3'),
                document.getElementById('strength-4')
            ];
            const strengthText = document.getElementById('strength-text');

            strengthBars.forEach(bar => {
                bar.className = 'h-1 w-1/4 bg-gray-200 rounded transition-colors';
            });

            if (password.length === 0) {
                strengthText.textContent = 'Minimum 6 characters';
                strengthText.className = 'text-xs text-gray-500 mt-1';
                return;
            }

            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.length >= 8) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;

            strength = Math.min(strength, 4);

            const colors = ['bg-red-400', 'bg-yellow-400', 'bg-blue-400', 'bg-green-400'];
            const texts = ['Weak', 'Fair', 'Good', 'Strong'];
            const textColors = ['text-red-600', 'text-yellow-600', 'text-blue-600', 'text-green-600'];

            for (let i = 0; i < strength; i++) {
                strengthBars[i].className = `h-1 w-1/4 ${colors[i]} rounded transition-colors`;
            }

            if (strength > 0) {
                strengthText.textContent = texts[strength - 1];
                strengthText.className = `text-xs ${textColors[strength - 1]} mt-1`;
            }
        }

        function checkPasswordMatch() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const matchText = document.getElementById('password-match');

            if (confirmPassword.length === 0) {
                matchText.classList.add('hidden');
                return;
            }

            matchText.classList.remove('hidden');

            if (password === confirmPassword) {
                matchText.textContent = 'Passwords match';
                matchText.className = 'text-xs text-green-600 mt-1';
            } else {
                matchText.textContent = 'Passwords do not match';
                matchText.className = 'text-xs text-red-600 mt-1';
            }
        }

        function validateForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const username = document.getElementById('username').value;

            if (username.length < 3 || username.length > 20) {
                alert('Username must be between 3 and 20 characters long.');
                return false;
            }

            if (password.length < 6) {
                alert('Password must be at least 6 characters long.');
                return false;
            }

            if (password !== confirmPassword) {
                alert('Passwords do not match.');
                return false;
            }

            return true;
        }
    </script>
</body>
</html>

package com.habittracker;

import java.security.MessageDigest;

public class PasswordHasher {
	public static String hashPassword(String password) throws Exception {
		MessageDigest md = MessageDigest.getInstance("SHA-256");
		byte[] hash = md.digest(password.getBytes("UTF-8"));

		// Convert byte array to hexadecimal string
		StringBuilder hexString = new StringBuilder();
		for (byte b : hash) {
			String hex = Integer.toHexString(0xff & b);
			if (hex.length() == 1)
				hexString.append('0');
			hexString.append(hex);
		}
		return hexString.toString();
	}
}

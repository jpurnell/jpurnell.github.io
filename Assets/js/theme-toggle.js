	//
	//  theme-toggle.js
	//  IgniteStarter
	//
	//  Created by Justin Purnell on 10/2/25.
	//

	// Dark mode toggle functionality
(function() {
	'use strict';
	
		// Get stored theme or default to 'light'
	const getStoredTheme = () => localStorage.getItem('theme');
	const setStoredTheme = theme => localStorage.setItem('theme', theme);
	
	const getPreferredTheme = () => {
		const storedTheme = getStoredTheme();
		if (storedTheme) {
			return storedTheme;
		}
		return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
	};
	
	const setTheme = theme => {
		document.documentElement.setAttribute('data-bs-theme', theme);
		updateToggleButton(theme);
	};
	
	const updateToggleButton = theme => {
		const toggleBtn = document.getElementById('theme-toggle');
		if (toggleBtn) {
			toggleBtn.innerHTML = theme === 'dark'
				? '<i class="bi bi-sun-fill"></i>'
				: '<i class="bi bi-moon-stars-fill"></i>';
			toggleBtn.setAttribute('aria-label', theme === 'dark'
				? 'Switch to light mode' : 'Switch to dark mode');
		}
	};
	
		// Set theme on page load
	setTheme(getPreferredTheme());
	
		// Listen for system theme changes
	window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
		const storedTheme = getStoredTheme();
		if (!storedTheme) {
			setTheme(getPreferredTheme());
		}
	});

	// Toggle theme when button is clicked
	window.addEventListener('DOMContentLoaded', () => {
		const toggleBtn = document.getElementById('theme-toggle');
		if (toggleBtn) {
			toggleBtn.addEventListener('click', () => {
				const currentTheme = document.documentElement.getAttribute('data-bs-theme');
				const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
				setStoredTheme(newTheme);
				setTheme(newTheme);
			});
		}
	});
})();

// blog-filter.js - Client-side filtering and sorting for blog posts

(function() {
    'use strict';

    // State management
    let currentFilter = {
        tag: null,
        month: null,
        sort: 'desc' // 'desc' for newest first, 'asc' for oldest first
    };

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        initializeFilters();
        initializeSortToggle();
        initializeMonthFilters();
        initializeResetButton();

        // Apply any filters from URL hash
        applyFiltersFromHash();

        // Show initial count
        applyFilters();
    });

    function initializeFilters() {
        // Tag filter dropdown items
        const tagItems = document.querySelectorAll('.filter-tag');
        tagItems.forEach(item => {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                const tag = this.dataset.tag;
                currentFilter.tag = tag;
                updateDropdownLabel('tag-dropdown', `Tag: ${tag}`);
                applyFilters();
                updateURL();
            });
        });
    }

    function initializeSortToggle() {
        const sortButton = document.getElementById('sort-toggle');
        if (sortButton) {
            sortButton.addEventListener('click', function() {
                currentFilter.sort = currentFilter.sort === 'desc' ? 'asc' : 'desc';
                updateSortButton();
                applyFilters();
                updateURL();
            });
        }
    }

    function initializeMonthFilters() {
        const monthButtons = document.querySelectorAll('.month-filter');
        monthButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const month = this.dataset.month;

                // Toggle month filter
                if (currentFilter.month === month) {
                    currentFilter.month = null;
                    this.classList.remove('active');
                    this.style.fontWeight = '';
                    this.style.backgroundColor = '';
                } else {
                    // Remove active from all month buttons
                    monthButtons.forEach(b => {
                        b.classList.remove('active');
                        b.style.fontWeight = '';
                        b.style.backgroundColor = '';
                    });
                    currentFilter.month = month;
                    this.classList.add('active');
                    this.style.fontWeight = 'bold';
                    this.style.backgroundColor = '#e9ecef';
                }

                applyFilters();
                updateURL();
            });
        });
    }

    function initializeResetButton() {
        const resetButton = document.getElementById('reset-filters');
        if (resetButton) {
            resetButton.addEventListener('click', function() {
                currentFilter = { tag: null, month: null, sort: 'desc' };

                // Reset UI
                updateDropdownLabel('tag-dropdown', 'Filter by Tag');
                updateSortButton();
                document.querySelectorAll('.month-filter').forEach(b => {
                    b.classList.remove('active');
                    b.style.fontWeight = '';
                    b.style.backgroundColor = '';
                });

                applyFilters();
                window.location.hash = '';
            });
        }
    }

    function applyFilters() {
        const posts = document.querySelectorAll('.blog-post-item');
        let visiblePosts = [];

        // Filter posts
        posts.forEach(post => {
            let show = true;

            // Tag filter
            if (currentFilter.tag) {
                const postTags = post.dataset.tags ? post.dataset.tags.split(',') : [];
                if (!postTags.includes(currentFilter.tag)) {
                    show = false;
                }
            }

            // Month filter
            if (currentFilter.month) {
                if (post.dataset.month !== currentFilter.month) {
                    show = false;
                }
            }

            if (show) {
                post.style.display = '';
                visiblePosts.push(post);
            } else {
                post.style.display = 'none';
            }
        });

        // Sort visible posts
        sortPosts(visiblePosts);

        // Update count
        updatePostCount(visiblePosts.length, posts.length);
    }

    function sortPosts(posts) {
        const container = document.getElementById('blog-posts-list');
        if (!container) return;

        // Sort by date
        posts.sort((a, b) => {
            const dateA = new Date(a.dataset.date);
            const dateB = new Date(b.dataset.date);

            if (currentFilter.sort === 'desc') {
                return dateB - dateA; // Newest first
            } else {
                return dateA - dateB; // Oldest first
            }
        });

        // Reorder DOM elements
        const list = container.querySelector('ul');
        if (list) {
            posts.forEach(post => {
                list.appendChild(post);
            });
        }
    }

    function updateSortButton() {
        const button = document.getElementById('sort-toggle');
        if (button) {
            if (currentFilter.sort === 'desc') {
                button.textContent = '↓ Newest First';
            } else {
                button.textContent = '↑ Oldest First';
            }
        }
    }

    function updateDropdownLabel(dropdownId, label) {
        const dropdown = document.getElementById(dropdownId);
        if (dropdown) {
            const button = dropdown.querySelector('button');
            if (button) {
                button.textContent = label;
            }
        }
    }

    function updatePostCount(visible, total) {
        let countElement = document.getElementById('post-count');
        if (!countElement) {
            // Create count element if it doesn't exist
            const container = document.getElementById('blog-posts-list');
            if (container) {
                countElement = document.createElement('p');
                countElement.id = 'post-count';
                countElement.className = 'text-muted';
                countElement.style.marginBottom = '1rem';
                countElement.style.fontSize = '0.9rem';
                container.insertBefore(countElement, container.firstChild);
            }
        }

        if (countElement) {
            if (visible === total) {
                countElement.textContent = `Showing all ${total} post${total !== 1 ? 's' : ''}`;
            } else {
                countElement.textContent = `Showing ${visible} of ${total} post${total !== 1 ? 's' : ''}`;
            }
        }
    }

    function updateURL() {
        const params = [];
        if (currentFilter.tag) params.push(`tag=${encodeURIComponent(currentFilter.tag)}`);
        if (currentFilter.month) params.push(`month=${encodeURIComponent(currentFilter.month)}`);
        if (currentFilter.sort !== 'desc') params.push(`sort=${currentFilter.sort}`);

        const hash = params.length > 0 ? '#' + params.join('&') : '';
        window.history.replaceState(null, '', window.location.pathname + hash);
    }

    function applyFiltersFromHash() {
        const hash = window.location.hash.substring(1);
        if (!hash) return;

        const params = new URLSearchParams(hash);

        if (params.has('tag')) {
            currentFilter.tag = params.get('tag');
            updateDropdownLabel('tag-dropdown', `Tag: ${currentFilter.tag}`);
        }

        if (params.has('month')) {
            currentFilter.month = params.get('month');
            const monthButton = document.querySelector(`.month-filter[data-month="${currentFilter.month}"]`);
            if (monthButton) {
                monthButton.classList.add('active');
                monthButton.style.fontWeight = 'bold';
                monthButton.style.backgroundColor = '#e9ecef';
            }
        }

        if (params.has('sort')) {
            currentFilter.sort = params.get('sort');
            updateSortButton();
        }
    }
})();

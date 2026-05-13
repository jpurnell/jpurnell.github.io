// card-filter.js — Shared client-side filtering for card grids
// Works with: .card-filter-btn[data-group][data-value], .filterable-card, .card-grid
// Optional: #card-sort-toggle for date-based sorting

(function() {
  'use strict';

  var activeFilters = {};
  var sortOrder = 'desc';

  document.addEventListener('DOMContentLoaded', function() {
    initFilterButtons();
    initSortToggle();
    applyFiltersFromHash();
    updateCards();
  });

  function initFilterButtons() {
    var buttons = document.querySelectorAll('.card-filter-btn');
    buttons.forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        var group = this.dataset.group;
        var value = this.dataset.value || null;

        if (!value) {
          delete activeFilters[group];
        } else {
          activeFilters[group] = value;
        }

        var groupBtns = document.querySelectorAll(
          '.card-filter-btn[data-group="' + group + '"]'
        );
        groupBtns.forEach(function(b) {
          if (b === btn) {
            b.classList.add('active');
          } else {
            b.classList.remove('active');
          }
        });

        updateCards();
        updateHash();
      });
    });
  }

  function initSortToggle() {
    var btn = document.getElementById('card-sort-toggle');
    if (!btn) return;
    btn.addEventListener('click', function() {
      sortOrder = sortOrder === 'desc' ? 'asc' : 'desc';
      this.textContent = sortOrder === 'desc'
        ? '↓ Newest First'
        : '↑ Oldest First';
      updateCards();
      updateHash();
    });
  }

  function updateCards() {
    var cards = document.querySelectorAll('.filterable-card');
    var visibleCards = [];

    cards.forEach(function(card) {
      var show = true;

      for (var group in activeFilters) {
        var filterValue = activeFilters[group];
        var cardAttr = card.dataset[group] || '';
        var cardValues = cardAttr.split(',').map(function(v) {
          return v.trim();
        });
        if (cardValues.indexOf(filterValue) === -1) {
          show = false;
          break;
        }
      }

      var wrapper = card.closest('.col') || card;
      wrapper.style.display = show ? '' : 'none';
      if (show) visibleCards.push(card);
    });

    if (document.getElementById('card-sort-toggle') && visibleCards.length > 1) {
      sortCards(visibleCards);
    }

    updateCount(visibleCards.length, cards.length);
  }

  function sortCards(cards) {
    var first = cards[0];
    var container = first.closest('.row') || first.parentElement;
    if (!container) return;

    var wrappers = cards.map(function(c) {
      return c.closest('.col') || c;
    });
    wrappers.sort(function(a, b) {
      var cardA = a.querySelector('.filterable-card') || a;
      var cardB = b.querySelector('.filterable-card') || b;
      var dateA = new Date(cardA.dataset.date || 0);
      var dateB = new Date(cardB.dataset.date || 0);
      return sortOrder === 'desc' ? dateB - dateA : dateA - dateB;
    });

    wrappers.forEach(function(w) {
      container.appendChild(w);
    });
  }

  function updateCount(visible, total) {
    var el = document.getElementById('card-count');
    if (!el) {
      var grid = document.querySelector('.card-grid');
      if (grid) {
        el = document.createElement('p');
        el.id = 'card-count';
        el.className = 'card-count-label';
        grid.parentNode.insertBefore(el, grid);
      }
    }
    if (!el) return;
    if (visible === total) {
      el.textContent = 'Showing all ' + total +
        ' item' + (total !== 1 ? 's' : '');
    } else {
      el.textContent = 'Showing ' + visible + ' of ' + total +
        ' item' + (total !== 1 ? 's' : '');
    }
  }

  function updateHash() {
    var params = [];
    for (var k in activeFilters) {
      params.push(k + '=' + encodeURIComponent(activeFilters[k]));
    }
    if (sortOrder !== 'desc') params.push('sort=' + sortOrder);
    var hash = params.length > 0 ? '#' + params.join('&') : '';
    window.history.replaceState(null, '', window.location.pathname + hash);
  }

  function applyFiltersFromHash() {
    var hash = window.location.hash.substring(1);
    if (!hash) return;
    var params = new URLSearchParams(hash);

    params.forEach(function(value, key) {
      if (key === 'sort') {
        sortOrder = value;
        var btn = document.getElementById('card-sort-toggle');
        if (btn) {
          btn.textContent = sortOrder === 'desc'
            ? '↓ Newest First'
            : '↑ Oldest First';
        }
      } else {
        activeFilters[key] = value;
        var selector = '.card-filter-btn[data-group="' + key +
          '"][data-value="' + value + '"]';
        var filterBtn = document.querySelector(selector);
        if (filterBtn) {
          var groupBtns = document.querySelectorAll(
            '.card-filter-btn[data-group="' + key + '"]'
          );
          groupBtns.forEach(function(b) {
            b.classList.remove('active');
          });
          filterBtn.classList.add('active');
        }
      }
    });
  }
})();

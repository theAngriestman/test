(function (_, $) {
  var REQUEST_DELAY = 1000;
  var ajaxPromise = $.Deferred();

  ajaxPromise.abort = function () {};

  ajaxPromise.resolve();
  var isOpenedSavedSearchPopup = false; // Update search results as you select filters by ajax

  $(_.doc).on('change input', 'input:not([data-ca-search-filters-update="ignore"]), textarea, select', updateSearchResultsByAjax); // Add a filter button when it is selected in the menu

  $(_.doc).on('change', '[data-ca-search-filters-add-filter-id]', function () {
    addFilter($(this));
  }); // Clean the filter by clicking the filter clean button

  $(_.doc).on('click', '[data-ca-search-filters="clearFilterBtn"]', clearFilter); // Close the popup of the filter item

  $(_.doc).on('click', '[data-ca-search-filters="closePopup"]', closeFilterItemPopup); // Restore the state of the filters on page load, and attach an event to submit the search form,
  // which saves the state of the filters and loads the search results

  $.ceEvent('on', 'ce.commoninit', function (context) {
    var $searchFiltersForms = $('[data-ca-search-filters="form"]', context);

    if (!$searchFiltersForms.length) {
      return;
    }

    $searchFiltersForms.each(function () {
      state.restore($(this));
      bindOnLoadEvents($(this));
    });
  }); // Bind submit search form event

  function bindOnLoadEvents($searchFilters) {
    $.ceEvent('on', "ce.formpost_".concat($searchFilters.prop('name')), submitFormPostProcess);
  } // Debounce submit the search form if there is no popup


  var submitSearchFiltersIfPossibleDebounce = $.debounce(submitSearchFiltersIfPossible, REQUEST_DELAY); // Submit the search form if there is no popup

  function submitSearchFiltersIfPossible($searchFilters) {
    if (!$searchFilters.length || $searchFilters.length && !$searchFilters[0].isConnected) {
      return;
    }

    prepareSubmitSearchFilters($searchFilters);
    $searchFilters.trigger('submit');
  } // Prepare submit search filters: disable save search name and add filter fields


  function prepareSubmitSearchFilters($searchFilters) {
    $('[data-ca-search-filters-update="ignore"]', $searchFilters).prop('disabled', true);
  } // Update search results


  function updateSearchResultsByAjax() {
    var $elem = $(this);
    var $searchFilters = $();

    if ($elem.length && $elem.attr('form') === $('[data-ca-search-filters="form"]').prop('id')) {
      $searchFilters = $($elem.prop('form'));
    } else if ($elem.length && $elem.closest('[data-ca-search-filters="form"]').length) {
      $searchFilters = $elem.closest('[data-ca-search-filters="form"]');
    } else {
      return;
    }

    abortRequest();
    submitSearchFiltersIfPossibleDebounce($searchFilters);
  } // Abort ajax request


  function abortRequest() {
    ajaxPromise.abort();
  } // There is a sent request


  function isPendingRequest() {
    return ajaxPromise.state() === 'pending';
  } // Submit form post process


  function submitFormPostProcess($searchFilters, $submitButton) {
    return processSubmitSaveView($submitButton) ? true : saveStateAndLoadSearchResults($searchFilters, $submitButton);
  } // Process submit save view


  function processSubmitSaveView($submitButton) {
    if ($.ceDialog('get_last').attr('id') !== 'content_search_save' && $submitButton.prop('name') !== 'dispatch[products.manage.save_view]') {
      return false;
    }

    $.ceAdvancedSearch('check_views', 'view_name', 'views');
    return true;
  } // Save state and load search results


  function saveStateAndLoadSearchResults($searchFilters, $submitButton) {
    state.save($searchFilters);
    loadSearchResultsByAjax($searchFilters);
    return false;
  } // Prepare search data for ajax request


  function prepareSearchData($searchFilters) {
    var dispatchPrefix = 'dispatch[';
    var searchFiltersData = $searchFilters.serializeObject();
    var dispatch = '';
    var resultIds = '';
    var submitName = $('[type="submit"][name]', $searchFilters).first().prop('name');

    if (searchFiltersData.dispatch) {
      dispatch = searchFiltersData.dispatch;
    } else if (submitName.startsWith(dispatchPrefix)) {
      dispatch = submitName.slice(dispatchPrefix.length).slice(0, -1);
    } else if (submitName) {
      dispatch = submitName;
    }

    if ($searchFilters.closest('[data-ca-search-filters="advSearch"]').length) {
      resultIds = $searchFilters.closest('[data-ca-search-filters="advSearch"]').attr('id');
    }

    if (searchFiltersData.result_ids) {
      resultIds = "".concat(resultIds, ",").concat(searchFiltersData.result_ids);
    } else if ($searchFilters.data('caTargetId')) {
      resultIds = "".concat(resultIds, ",").concat($searchFilters.data('caTargetId'));
    }

    return {
      data: searchFiltersData,
      dispatch: dispatch,
      resultIds: resultIds
    };
  } // Load search results using Ajax


  function loadSearchResultsByAjax($searchFilters) {
    var searchData = prepareSearchData($searchFilters);
    ajaxPromise = $.ceAjax('request', fn_url(searchData.dispatch), {
      result_ids: searchData.resultIds,
      save_history: true,
      get_promise: true,
      show_overlay: false,
      caching: false,
      data: searchData.data
    });
  } // Add filter button from dropdown menu and hide dropdown item


  function addFilter($addFilterCheckbox) {
    if (isPendingRequest()) {
      abortRequest();
      submitSearchFiltersIfPossibleDebounce($addFilterCheckbox.closest('[data-ca-search-filters="form"]'));
    }

    var $addFilter = $addFilterCheckbox.closest('[data-ca-search-filters="addFilter"]');
    var $searchFiltersItem = $("[data-ca-search-filters-id=\"".concat($addFilterCheckbox.data('caSearchFiltersAddFilterId'), "\"]"), $addFilterCheckbox.closest('[data-ca-search-filters="main"]'));
    var $searchFiltersButton = $('.cm-search-filters-button', $searchFiltersItem);
    var isShowFilter = $addFilterCheckbox.is(':checked'); // Hide variant item. Reverse add filter checkbox value

    $addFilterCheckbox.closest('[data-ca-search-filters="addFilterVariantItem"]').toggleClass('hidden', isShowFilter);
    $addFilterCheckbox.val(isShowFilter ? 'Y' : 'N'); // Hide empty add filter button

    var isEmptyAddFilterDropdownMenu = $('[data-ca-search-filters="addFilterVariantItem"]:not(.hidden)', $addFilterCheckbox.closest('[data-ca-search-filters="addFilterDropdownMenu"]')).length === 0;
    $addFilter.toggleClass('hidden', isEmptyAddFilterDropdownMenu); // Show filter and open filter popup or dropdown

    $searchFiltersItem.toggleClass('hidden', !isShowFilter);

    if ($searchFiltersButton.hasClass('cm-dialog-opener')) {
      $(document.getElementById($searchFiltersButton.data('caTargetId'))).ceDialog('open', $.ceDialog('get_params', $searchFiltersButton));
    } else if ($searchFiltersButton.hasClass('dropdown-toggle')) {
      $searchFiltersButton.dropdown('toggle');
    }
  } // Reset filter and reload page


  function clearFilter() {
    var $clearFilterBtn = $(this);
    disableClearedFilterFields($clearFilterBtn);
    updateSearchResultsByAjax.apply($clearFilterBtn);
  } // Disable fields for cleared filters to exclude them from the search query


  function disableClearedFilterFields($clearFilterBtn) {
    var $searchFields = $('[data-ca-search-filters="field"]', $clearFilterBtn.closest('[data-ca-search-filters="item"]'));

    if (!$searchFields.length) {
      return;
    }

    $searchFields.each(function () {
      $(this).prop('disabled', true);
    });
  }

  function closeFilterItemPopup() {
    abortRequest();
    submitSearchFiltersIfPossibleDebounce($(this).closest('[data-ca-search-filters="form"]'));
  } // Save and restore search state


  var state = {
    _searchFiltersItemState: {},
    _addFilterVariantItemState: {},
    _dropdownsState: {},
    _requestVarsState: {},
    _cursorState: {},
    save: function save($searchFilters) {
      this._saveSearchFiltersItemState($searchFilters);

      this._saveAddFilterVariantItemState($searchFilters);

      this._saveDropdownsState($searchFilters);

      this._saveRequestVarsState($searchFilters);

      this._saveCursorState();
    },
    restore: function restore($searchFilters) {
      this._restoreSearchFiltersItemState($searchFilters);

      this._restoreAddFilterVariantItemState($searchFilters);

      this._restoreDropdownsState($searchFilters);

      this._restoreRequestVarsState($searchFilters);

      this._restoreCursorState();
    },
    _saveSearchFiltersItemState: function _saveSearchFiltersItemState($searchFilters) {
      var self = this;
      self._searchFiltersItemState = {};
      $('[data-ca-search-filters-add-filter-id]', $('[data-ca-search-filters="addFilterDropdownMenu"]', $searchFilters)).each(function () {
        var $addFilterCheckbox = $(this);
        self._searchFiltersItemState[$addFilterCheckbox.data('caSearchFiltersAddFilterId')] = {
          show: $addFilterCheckbox.is(':checked')
        };
      });
    },
    _restoreSearchFiltersItemState: function _restoreSearchFiltersItemState($searchFilters) {
      var self = this;

      if ($.isEmptyObject(self._searchFiltersItemState)) {
        return;
      }

      $('[data-ca-search-filters-add-filter-id]', $('[data-ca-search-filters="addFilterDropdownMenu"]', $searchFilters)).each(function () {
        var $addFilterCheckbox = $(this);

        if ($addFilterCheckbox.data('caSearchFiltersAddFilterType') === 'popup') {
          $addFilterCheckbox.prop('checked', self._searchFiltersItemState[$addFilterCheckbox.data('caSearchFiltersAddFilterId')].show);
        }
      });
      $('[data-ca-search-filters="item"]', $searchFilters).each(function () {
        var $searchItem = $(this);
        var searchFiltersId = $searchItem.data('caSearchFiltersId');

        if (self._searchFiltersItemState[searchFiltersId] && self._searchFiltersItemState[searchFiltersId].show) {
          if ($searchItem.data('caSearchFiltersItemType') === 'popup') {
            $searchItem.removeClass('hidden');
          }

          delete self._searchFiltersItemState[searchFiltersId];
        }
      });
    },
    _saveAddFilterVariantItemState: function _saveAddFilterVariantItemState($searchFilters) {
      var self = this;
      self._addFilterVariantItemState = {};
      $('[data-ca-search-filters-add-filter-id]', $('[data-ca-search-filters="addFilterDropdownMenu"]', $searchFilters)).each(function () {
        var $addFilterCheckbox = $(this);
        self._addFilterVariantItemState[$addFilterCheckbox.data('caSearchFiltersAddFilterId')] = {
          show: !$addFilterCheckbox.is(':checked')
        };
      });
    },
    _restoreAddFilterVariantItemState: function _restoreAddFilterVariantItemState($searchFilters) {
      var self = this;

      if ($.isEmptyObject(self._addFilterVariantItemState)) {
        return;
      }

      $('[data-ca-search-filters-add-filter-id]', $('[data-ca-search-filters="addFilterDropdownMenu"]', $searchFilters)).each(function () {
        var $addFilterCheckbox = $(this);
        var addFilterId = $addFilterCheckbox.data('caSearchFiltersAddFilterId');

        if (self._addFilterVariantItemState[addFilterId] && !self._addFilterVariantItemState[addFilterId].show) {
          if ($addFilterCheckbox.data('caSearchFiltersAddFilterType') === 'popup') {
            $addFilterCheckbox.closest('[data-ca-search-filters="addFilterVariantItem"]').addClass('hidden');
          }

          delete self._addFilterVariantItemState[addFilterId];
        }
      });
    },
    _saveDropdownsState: function _saveDropdownsState($searchFilters) {
      var self = this;
      self._dropdownsState = {};
      $('[data-ca-search-filters="item"]', $searchFilters).each(function () {
        var $searchItem = $(this);
        self._dropdownsState[$searchItem.data('caSearchFiltersId')] = {
          open: $searchItem.hasClass('open')
        };
      });
    },
    _restoreDropdownsState: function _restoreDropdownsState($searchFilters) {
      var self = this;
      $('[data-ca-search-filters="item"]', $searchFilters).each(function () {
        var $searchItem = $(this);
        var searchFiltersId = $searchItem.data('caSearchFiltersId');

        if (self._dropdownsState[searchFiltersId] && self._dropdownsState[searchFiltersId].open) {
          $('[data-toggle="dropdown"]', $searchItem).dropdown('toggle');
          delete self._dropdownsState[searchFiltersId];
        }
      });
    },
    _saveRequestVarsState: function _saveRequestVarsState($searchFilters) {
      var self = this;
      self._requestVarsState = {};
      self._requestVarsState.html = $('[data-ca-search-filters="requestVars"]', $searchFilters).html();
    },
    _restoreRequestVarsState: function _restoreRequestVarsState($searchFilters) {
      var self = this;
      $('[data-ca-search-filters="requestVars"]', $searchFilters).html(self._requestVarsState.html);
      delete self._requestVarsState.html;
    },
    _saveCursorState: function _saveCursorState() {
      this._cursorState = {};
      var $focused = $(':focus');

      if (!$focused.length) {
        return;
      }

      this._cursorState.id = $focused.attr('id');
      this._cursorState.type = $focused.attr('type');
      this._cursorState.searchFiltersId = $focused.closest('[data-ca-search-filters-id]');

      if (this._cursorState.type === 'text') {
        this._cursorState.val = $focused.val();
        this._cursorState.selectionStart = $focused[0].selectionStart;
        this._cursorState.selectionEnd = $focused[0].selectionEnd;
      }
    },
    _restoreCursorState: function _restoreCursorState() {
      if (!this._cursorState.id) {
        return;
      }

      var $activeElem = $('#' + this._cursorState.id);
      $activeElem.focus();

      if (this._cursorState.type !== 'text') {
        return;
      }

      var activeElem = $activeElem[0];

      if ($activeElem.val() === this._cursorState.val) {
        activeElem.setSelectionRange(this._cursorState.selectionStart, this._cursorState.selectionEnd);
      } else {
        activeElem.selectionStart = activeElem.selectionEnd = activeElem.value.length;
      }
    }
  };
})(Tygh, Tygh.$);
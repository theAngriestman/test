(function (_, $) {
  var url_prefix = 'http://';
  var methods = {
    dispatch_quick_menu_event: function dispatch_quick_menu_event(e) {
      var jelm = $(e.target);

      if (e.type == 'click' && $.browser.mozilla && e.which != 1) {
        return true;
      }

      if (e.type == 'click') {
        if (jelm.closest('.cm-delete-section').length && jelm.parents('#quick_menu').length) {
          var root = jelm.parents('tr:first');
          $.ceAjax('request', fn_url('tools.remove_quick_menu_item'), {
            data: {
              id: root.data('caQmItem'),
              parent_id: root.data('caQmParentId')
            },
            result_ids: 'quick_menu'
          });
        } else if (jelm.closest('.cm-add-link').length && jelm.parents('#quick_menu').length) {
          methods.show_quick_box('', jelm.parents('tr:first').data('caQmItem'), '', url_prefix, '', 'new_link');
          return false;
        } else if (jelm.hasClass('cm-add-section') && jelm.parents('#quick_menu').length) {
          methods.show_quick_box('', 0, '', '', '', 'new_section');
          return false;
        } else if (jelm.hasClass('cm-update-item') && jelm.parents('#quick_menu').length) {
          var root = jelm.parents('tr:first');
          var name_holder = $('.cm-qm-name:first', root);
          var title = "editing_quick_menu_section";

          if (Number(root.data('caQmParentId'))) {
            title = "editing_quick_menu_link";
          }

          methods.show_quick_box(root.data('caQmItem'), Number(root.data('caQmParentId')), name_holder.text(), name_holder.data('href') ? name_holder.data('href') : '', root.data('caQmPosition'), title);
          return false;
        } else if (jelm.prop('id') == 'qm_current_link') {
          $('#qm_item_link').val(location.href);
          return false;
        } else if (jelm.hasClass('cm-lang-link') && jelm.parents('.cm-select-list').length) {
          methods.change_language(jelm.prop('name'));
          $.ceAjax('request', jelm.prop('href'), {
            data: {
              id: $('#qm_item_id').val()
            },
            caching: false,
            callback: methods.change_quick_box
          });
          jelm.parents('.cm-popup-box:first').hide();
          return false;
        } else if (jelm.hasClass('cm-qm-show-hide')) {
          $.ceAjax('request', fn_url('tools.update_quick_menu_handler?enable=') + (jelm.prop('checked') ? 'Y' : 'N'), {
            cache: false,
            result_ids: 'quick_menu'
          });
        }
      }
    },
    change_language: function change_language(lang_code) {
      var sl = $('#quick_menu_language_selector');

      if (sl.children().length) {
        var jelm = $('a[name=' + lang_code + ']', sl);
        $('a.dropdown-toggle', sl).html('<span class="ty-icon flag flag-' + lang_code + '"></span> ' + jelm.text() + ' <span class="caret"></span>'); // set new text

        $('#qm_descr_sl').val(lang_code); // change descriptions language
      }
    },
    change_quick_box: function change_quick_box(data) {
      $('#qm_item_name').val(data.description);
    },
    update_main_menu: function update_main_menu() {
      $.ceAjax('request', _.current_url, {
        result_ids: 'header_navbar',
        full_render: true
      });
    },
    show_quick_box: function show_quick_box(id, parent_id, name, url, pos, title) {
      var quick_box = $('#quick_box');
      title = _.tr(title);
      $('#qm_item_id').val(id);
      $('#qm_item_parent').val(parent_id);
      $('#qm_item_name').val(name);
      $('#qm_item_link').val(url);
      $('#qm_item_position').val(pos);
      methods.change_language(_.cart_language);
      var sl = $('#quick_menu_language_selector');

      if (sl.children().length) {
        $('ul.cm-select-list a', sl).addClass('cm-lang-link');
      }

      var link_holder = $('#qm_item_link').parents('.control-group:first');

      if (parent_id) {
        link_holder.show();
        $('label', link_holder).addClass('cm-required');
        $('#qm_current_link').parents('.control-group:first').show();
      } else {
        link_holder.hide();
        $('label', link_holder).removeClass('cm-required');
        $('#qm_current_link').parents('.control-group:first').hide();
      }

      quick_box.ceDialog('open', {
        title: title,
        height: 'auto',
        width: '700px'
      });
    }
  };
  $(_.doc).on('click', function (e) {
    return methods.dispatch_quick_menu_event(e);
  });
  $.ceEvent('on', 'ce.formpost_quick_menu_form', function () {
    $('#quick_box').ceDialog('close');
  });
  $.ceEvent('on', 'ce.formajaxpost_quick_menu_form', function () {
    methods.update_main_menu();
  });
})(Tygh, Tygh.$);
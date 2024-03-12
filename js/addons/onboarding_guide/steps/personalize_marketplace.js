(function (_, $) {
  $.ceEvent('on', 'ce.commoninit', function (context) {
    var $context = $(context);

    if (!$context.find('#og-design').length && $context.attr('id') !== 'og-design') {
      return;
    }

    var _activeTheme = $('.og-theme-activator:checked', context);

    var _activeStyle = _activeTheme.closest('.og-theme').find('.og-theme-style:checked');

    var activeTheme = _activeTheme.val();

    var activeStyle = _activeStyle.val();

    $('[data-og-tab="button"]').click(function () {
      var $this = $(this);
      $('[data-og-tab="item"]').hide();
      $('[data-og-tab="button"]').not($this).removeClass('active');
      $('[data-og-tab="item"]').eq($this.index()).show();
      $this.addClass('active');
    });
    $('.tab-navigation-scroll').click(function () {
      var element = document.querySelector('.onboarding_accordion__item--active');
      element.scrollIntoView({
        behavior: 'smooth'
      });
    });
    $('[data-og-tab-navigation]').click(function () {
      $('[data-og-tab="item"]').hide();
      $('[data-og-tab="button"]').removeClass('active');
      var tabIndex = $(this).data('og-tab-navigation') - 1;
      $('[data-og-tab="item"]').eq(tabIndex).show();
      $('[data-og-tab="button"]').eq(tabIndex).addClass('active');
    });
    $('#og-logo-file').on('change', function (e) {
      if (!e.target.files.length) {
        return;
      }

      var file = e.target.files[0];
      var fileUrl = window.URL.createObjectURL(file);
      $('#og-logo-img').attr('src', fileUrl);
      var logoAlt = $('#og-logo-alt').val(); // Theme logo and mail logo must the same
      // Therefore we duplicate theme logo and create a new file field for mail logo

      fetch(fileUrl).then(function (response) {
        response.blob().then(function (file) {
          var formData = new FormData($('#og-design-form')[0]);
          formData.append('file_logo_image_icon[mail]', file);
          formData.append('logo_image_data[mail][image_alt]', logoAlt);
          formData.append('is_ajax', 1);
          $.toggleStatusBox('show');
          $.ajax({
            url: fn_url('onboarding_guide.update_logos'),
            type: 'post',
            data: formData,
            processData: false,
            contentType: false,
            cache: true,
            success: function success() {
              $.ceNotification('show', {
                type: 'N',
                title: _.tr('notice'),
                message: _.tr('onboarding_guide.logos_updated'),
                message_state: 'I'
              });
            },
            complete: function complete(response) {
              $.toggleStatusBox('hide');
            }
          });
        });
      });
    });
    var altTypingBufferTimer = 0;
    $('#og-logo-alt').on('input', function () {
      var $this = $(this);
      var $inputs = $('#og-design-form :input');
      var requestData = {
        'logo_image_data[mail][image_alt]': $this.val()
      };
      $inputs.each(function () {
        requestData[this.name] = $(this).val();
      });
      clearTimeout(altTypingBufferTimer);
      altTypingBufferTimer = setTimeout(function () {
        $.ceAjax('request', fn_url('onboarding_guide.update_logos_alt'), {
          method: 'post',
          data: requestData
        });
      }, 300);
    });
    var images = $('.og-theme-image');
    images.each(function () {
      var image = $(this);
      var encodedURI = encodeURI(image.attr('href'));
      image.css('background-image', "url(".concat(encodedURI, ")"));
    });
    $('.og_cover').on('click', function (event) {
      event.preventDefault();

      if (!$(event.target).hasClass('og_cover')) {
        var link = $(this).closest('.og_theme_image');
        link.trigger('click');
      }
    });
    $('input[type="radio"].og-theme-style:checked').each(function () {
      var item = $(this);
      var hasColor = !!item.data('og-theme-color');

      if (!hasColor) {
        var themeId = item.data('og-theme-id');
        var mark = $("[data-og-theme-id=\"".concat(themeId, "\"]")).find('.og-theme-custom');
        mark.addClass('og-theme-custom--active');
      }
    });
    $('.og-theme-style').on('change', function () {
      var $this = $(this);
      var style = $this.val();
      var parent = $this.closest('.og-theme');
      var styleName = parent.find('.og-style-name');
      styleName.text(style);
      var themeImage = parent.find('.og-theme-image');
      var styleImageUrl = encodeURI($this.data('og-style-image'));
      themeImage.css('background-image', 'url(' + styleImageUrl + ')');
      themeImage.attr('href', styleImageUrl);
      var themeActivator = parent.find('.og-theme-activator');

      if (themeActivator.val() === activeTheme) {
        parent.find('.og-theme-activator').prop('checked', style === activeStyle);
      }

      var hasColor = !!$this.data('og-theme-color');
      var themeId = $this.data('og-theme-id');
      var mark = $("[data-og-theme-id=\"".concat(themeId, "\"]")).find('.og-theme-custom');
      mark[hasColor ? 'removeClass' : 'addClass']('og-theme-custom--active');
    });
    $('.og-theme-activator').on('change', function (e) {
      e.stopPropagation();
      var $this = $(this),
          parent = $this.closest('.og-theme'),
          newTheme = $this.val(),
          style = parent.find('.og-theme-style:checked').val();
      var oldTheme = $('#og-current-theme').data('ogThemeId');
      $.ceAjax('request', fn_url('onboarding_guide.update_theme'), {
        method: 'post',
        data: {
          old_theme_name: oldTheme,
          new_theme_name: newTheme,
          style: style,
          result_ids: 'og-design'
        }
      });
    });
  });
})(Tygh, Tygh.$);
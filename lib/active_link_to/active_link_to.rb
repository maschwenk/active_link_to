module ActiveLinkTo
  # Wrapper around link_to. Accepts following params:
  #   :active         => Boolean | Symbol | Regex | Controller/Action Pair
  #   :class_active   => String
  #   :class_inactive => String
  # Example usage:
  #   active_link_to('/users', class_active: 'enabled')
  #   active_link_to(users_path, active: :exclusive, wrap_tag: :li)
  def active_link_to(*args, &block)
    name = block_given? ? capture(&block) : args.shift
    options = args.shift || {}
    html_options = args.shift || {}

    url = url_for(options)

    active_options  = {}
    link_options    = {}
    html_options.each do |k, v|
      if %i[active class_active class_inactive].member?(k)
        active_options[k] = v
      else
        link_options[k] = v
      end
    end

    css_class = link_options.delete(:class).to_s + ' '

    css_class << active_link_to_class(url, active_options)
    css_class.strip!

    link_options[:class] = css_class if css_class.present?
    link_options['aria-current'] = 'page' if active_link?(url, active_options[:active])

    link_to(name, url, link_options)
  end

  # Returns css class name. Takes the link's URL and its params
  # Example usage:
  #   active_link_to_class('/root', class_active: 'on', class_inactive: 'off')
  #
  def active_link_to_class(url, options = {})
    if active_link?(url, options[:active])
      options[:class_active] || 'active'
    else
      options[:class_inactive] || ''
    end
  end

  # Returns true or false based on the provided path and condition
  # Possible condition values are:
  #                   Symbol -> :exclusive | :inclusive
  #                   Regex -> /regex/
  #
  # Example usage:
  #
  #   active_link?('/root', :exclusive)
  #   active_link?('/root', /^\/root/)
  #
  def active_link?(url, condition = nil)
    @is_active_link ||= {}
    @is_active_link[[url, condition]] ||= begin
      url = Addressable::URI.parse(url).path
      path = request.original_fullpath
      case condition
      when :inclusive, nil
        path.match(%r{^#{Regexp.escape(url).chomp('/')}(/.*|\?.*)?$}).present?
      when :exclusive
        path.match(%r{^#{Regexp.escape(url)}/?(\?.*)?$}).present?
      when Regexp
        path.match(condition).present?
      end
    end
  end
end

ActiveSupport.on_load :action_view do
  include ActiveLinkTo
end

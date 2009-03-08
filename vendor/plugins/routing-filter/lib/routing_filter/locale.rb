require 'i18n'
require 'routing_filter/base'

# Kieran Pilkington - 2009/03/09
# Adding changes from a forked version of svenfuchs/routing-filter
# which only takes the langauge out of the url if it exists in the available languages
# This prevents urls that contain 2 letter basket names from being mistaken as a language

module RoutingFilter
  class Locale < Base
    @@default_locale = :en
    cattr_reader :default_locale
    
    @@locale_match = %r(^/(#{I18n.available_locales.map{|l|l.to_s}.join('|')})(?=/|$))
    cattr_reader :locale_match

    class << self
      def default_locale=(locale)
        @@default_locale = locale.to_sym
      end
    end
    
    # remove the locale from the beginning of the path, pass the path
    # to the given block and set it to the resulting params hash
    def around_recognize(path, env, &block)
      locale = nil
      path.sub! @@locale_match do locale = $1; '' end
      returning yield do |params|
        params[:locale] = locale if locale
      end
    end

    def around_generate(*args, &block)
      locale = args.extract_options!.delete(:locale) || I18n.locale
      returning yield do |result|
        result.sub!(%r(^(http.?://[^/]*)?(.*))){ "#{$1}/#{locale}#{$2}" }
      end
    end
  end
end
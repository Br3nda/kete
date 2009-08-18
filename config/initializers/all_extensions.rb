#
# CAUTION
#
# This intializer must be run before all others!!!
# (name it accordingly so it is sorted alphabetically before all others)
#

# Include extensions into Ruby components here

class String
  # Add a quick escape method to all string instances
  # (for xml displays)
  def escape
    require 'htmlentities'
    entities = HTMLEntities.new
    # decode special chars (like multi language chars)
    # escape xml special chars &, <, and >
    CGI::escapeHTML(entities.decode(self))
  end

  # In Rails 2.3, strip_tags and sanitize are not accessible in their short form outside of
  # helpers and view, so lets add a method on String that we can call in controllers/models/libs etc
  def strip_tags
    ActionController::Base.helpers.strip_tags(self)
  end
  def sanitize
    ActionController::Base.helpers.sanitize(self)
  end

  # Add a quick escpe for url and decode from url methods to string instances
  # (escapes anything that causes issues with route parsing, like forward slashes and periods)
  def escape_for_url
    URI.escape(self, /\W/)
  end
  def decode_from_url
    URI.decode(self)
  end

  # converts "true", "false", and "nil" into their appropriate boolean/NilClass values
  def to_bool
    return true if self == "true"
    return false if self == "false"
    return nil if self == "nil"
    return self
  end
end

# Include extensions into Rails components here

# Kieran Pilkington, 2009-07-09
# Adding a class_as_key method which returns a key for a model as used in params
module ActiveRecord
  class Base
    def class_as_key
      # self. is necessary in this case because class is a reserved word
      self.class.name.tableize.singularize.to_sym
    end
  end
end

# Kieran Pilkington, 2009-07-09
# Getting around issue within Rails that causes a hash to be stringified, but
# no take options into account later because the values require symbols
# Alias the old method, redefine and symbolize keys before continuing
module ActionController
  class UrlRewriter
    private
      alias :rewrite_url_orig :rewrite_url
      def rewrite_url(options)
        rewrite_url_orig options.symbolize_keys
      end
  end
end

module I18n
  module Backend
    class Simple
      protected
        # Kieran Pilkington, 2009-07-09
        # Adding very simple translation fallback support to I18n module
        # Calls the original lookup method. If the value is empty, call it again with default locale
        alias :lookup_orig :lookup
        def lookup(locale, key, scope = [])
          return unless key
          entry = lookup_orig(locale, key, scope)
          if (entry.nil? || (entry.is_a?(String) && entry.empty?)) && I18n.default_locale
            entry = lookup_orig(I18n.default_locale, key, scope)
          end
          entry
        end

        # Kieran Pilkington, 2009-07-09
        # Allows us to use keys in translations "Change {{t.base.password}}"
        # Replace all the {{t.}} values before handing the resulting string
        # to the original interpolate method
        alias :interpolate_orig :interpolate
        def interpolate(locale, string, values = {})
          return string unless string.is_a?(String)

          string = string.gsub(MATCH) do
            escaped, pattern, key = $1, $2, $2.to_sym

            if !escaped && pattern.match(/^t\./)
              # a list of acceptable string methods to call
              string_methods = ['downcase', 'upcase', 'capitalize', 'singularize', 'pluralize']

              # remove string methods and t. from the key, then turn to a symbol
              # and run it through the translate method
              key = pattern.gsub(/^t\./, '').gsub(/\.(#{string_methods.join('|')})/, '').to_sym
              value = translate(locale, key, values)

              # for each string method in the patern, in order, execute that
              # method on the returned value, and overwrite value
              pattern.gsub(/\.(#{string_methods.join('|')})/) do
                value = value.respond_to?($1) ? value.send($1) : value
              end

              # return the translated, and string method executed value
              value
            else
              "{{#{pattern}}}"
            end
          end

          interpolate_orig(locale, string, values)
        end
    end
  end
end

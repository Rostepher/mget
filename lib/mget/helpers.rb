require_relative '../string'

module MangaGet
    module Helpers
        SANITIZE_CHARS = /[\ |\.|\_|\-]/

        # Sanitizes num so that the integral part (part in front of decimal) is
        # always at least three chars long, with preceding 0's if needed. This
        # method returns a string of the padded number.
        #
        # @param n [String, Float, Integer] number to be padded
        # @param pad_char [String] character or string to pad n with
        # @param pad_len [Integer] number of places to pad
        # @returns [String] padded string of n
        module_function
        def pad(n, pad_char='0', pad_len=3)
            n = n.to_s unless n.is_a? String
            parts = n.split('.')
            parts[0] = parts[0].rjust(pad_len, pad_char)
            parts.join('.')
        end
       
        # Sanitizes name so that all space characters are _ and downcases the
        # entire string. Makes a string URL ready.
        #
        # @params str [String] string to sanitize
        # @params delim [String] delimeter string, default '_'
        # @returns [String] sanitized string
        module_function
        def sanitize_str(str, delim='_')
            str.downcase.gsub(SANITIZE_CHARS, delim)
        end

        # Sanitizes and titlecases a given title.
        #
        # @param title [String] title to process
        # @returns [String] properly formatted title
        module_function
        def fmt_title(title)
            sanitize_str(title, ' ').titlecase
        end
    end
end

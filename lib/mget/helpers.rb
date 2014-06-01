require_relative 'string'

module MangaGet
    module Helpers
        SANITIZE_CHARS = /[\ |\.|\_|\-]/

        # Sanitizes num so that the integral part (part in front of decimal) is
        # always at least three chars long, with preceding 0's if needed. This
        # method returns a string of the padded number.
        #
        # @param n [String, Float, Integer] number to be padded
        module_function
        def pad(n, pad_len=3)
            n.to_s unless n.is_a? String
            parts = n.split('.')
            parts[0] = parts[0].rjust(pad_len, '0')
            parts.join('.')
        end
       
        # Sanitizes name so that all space characters are _ and downcases the
        # entire string. Makes a string URL ready.
        module_function
        def sanitize_str(str, delim='_')
            raise TypeError, "expected String" unless str.is_a? String
            str.downcase.gsub(SANITIZE_CHARS, delim)
        end
    end
end

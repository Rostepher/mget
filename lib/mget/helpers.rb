module MangaGet
    module Helpers
        SANITIZE_CHARS = /[\ |\.|\_|\-]/
        NUMBER_REGEX = /^\d+\.{0,1}\d*$/
        
        #
        # Returns if num is a float.
        #
        module_function
        def float?(num)
            # ensure input is a string
            num = num.to_s

            return false if NUMBER_REGEX.match(num).nil?
            num.split('.').length > 1
        end

        #
        # Converts a given string to float or int if the string is a number. If
        # the given string is not a number the string is returned.
        #
        def to_num(s)
            # ensure argument is string
            s = s.to_s

            return s if NUMBER_REGEX.match(s).nil?
            return s.to_f if float?(s)
            s.to_i
        end

        #
        # Sanitizes num so that the integral part (part in front of decimal) is
        # always at least three chars long, with preceding 0's if needed. This
        # method returns a string of the padded number.
        #
        module_function
        def pad_num(num)
            parts = num.to_s.split('.')
            num = parts.first.rjust(3, '0')

            # returns a float if there is a fractional part
            return "#{num}.#{parts.last}" if parts.length > 1
            
            # otherwise return int
            num
        end
       
        #
        # Sanitizes name so that all space characters are _ and downcases the
        # entire string. Makes a string URL ready.
        #
        module_function
        def sanitize_name(name)
            name.to_s.downcase.gsub(SANITIZE_CHARS, '_')
        end

        #
        # Capitalizes each word in name
        #
        module_function
        def capitalize_name(name)
            name.split(SANITIZE_CHARS).map(&:capitalize).join(' ')
        end
    end
end

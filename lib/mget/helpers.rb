module MangaGet
    module Helpers
        SANITIZE_CHARS = /[\ |\.|\_|\-]/
        #
        # Returns if num is a float.
        #
        module_function
        def float?(num)
            num.to_s.split('.').length > 1
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

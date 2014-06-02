class String
    NUMERIC_REGEX = /^\d*\.{0,1}\d+$/
    SMALL_WORDS = %w{a an and as at but by en for if in of on or the to v. via vs.}

    # Returns true for a str that contains only a representation of a floating
    # point number.
    #
    # @returns [true, false] if self is a float type in string format
    def float?
        return false if !self.numeric?
        self.split('.').length > 1
    end

    # Returns true for a str that contains only a representation of a floating
    # point number or an integer.
    #
    # @returns [true, false] if self is a numeric type in string format
    def numeric?
        !NUMERIC_REGEX.match(self).nil?
    end

    # Returns the result of interpreting the characters in str as a floating
    # point number or integer. Str can only contain a numeric representation.
    # If there is not a valid numeric type in str, then Float::NAN is returned.
    #
    # @returns [Float::NAN, Float, Integer] casted numeric of self or
    #   Float::NAN
    def to_n
        return Float::NAN if !self.numeric?
        return self.to_f if self.float?
        self.to_i
    end

    # Returns a copy of str with the first character of every word converted to
    # uppercase and the remainder to lowercase. Does not capitalize "small
    # words" as defined by the "New York Time Manual of Style".
    #
    # @returns [String] titlecased str
    def titlecase
        return if self.empty?

        # traverse each word and upcase all non-small words
        title = self.split(' ').map! do |word|
            if SMALL_WORDS.include?(word.downcase.gsub(/\W/,''))
                word.downcase!
            else
                word.capitalize!
            end
            word
        end

        # capitalize first and last words
        title.first.capitalize!
        title.last.capitalize!

        # join parts together
        title = title.join(' ')

        # find any small word after a semi-colon and upcase it

        if /:\s?(#{SMALL_WORDS.join('|').gsub('.', '\.')})\s+/ =~ title
            i = title.index($1)
            title[i] = title[i].upcase
        end

        # return title
        title
    end

    # Destructive form of {#titlecase}
    def titlecase!
        replace(titlecase)
    end
end

RSpec::Matchers.define :be_unique do
    match do |collection|
        items = Set.new
        collection.each do |item|
            if items.include? item
                return false
            else
                items << item
            end
        end

        true
    end

    failure_message do |collection|
        "expected collection #{collection} to have unique elements"
    end

    failure_message_when_negated do |collection|
        "expected collection #{collection} to not have unique elements"
    end

    description do
        "checks if a collection has unique elements"
    end
end

class String
  # Convert string from format <this_is_the_string> or
  # <this-is-the-string> to format <ThisIsTheString>
  #
  # @return   [String]    New string, converted to camel-case format
  def camelize
    split(/_|-/).map(&:capitalize).join('')
  end
end
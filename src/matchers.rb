class Matchers
  attr_accessor :matcher

  def initialize(object)
    self.matcher = object
  end

  def call(object)
  end

end

##################################################################

class VariableMatcher < Matchers
  def call(object)
    self.matcher == object
  end
end

##################################################################

class TypeMatcher < Matchers
  def call(object)
    object.class.ancestors.to_a.include?(self.matcher)
  end
end

##################################################################

class ListMatcher < Matchers
  def initialize(object, sizeMatch = true)
    self.matcher = object
  end

  def call(object)

  end
end

##################################################################

class DuckMatcher < Matchers
  def initialize(*methods)
    self.matcher = *methods
  end
  def call(object)
      self.matcher.to_a.all? {
        |x|  object.methods.to_a.include? x
      }
  end
end
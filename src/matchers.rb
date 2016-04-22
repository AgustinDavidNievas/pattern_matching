class Matchers
  attr_accessor :matcher, :collection

  def initialize(object)
    self.matcher = object
  end

  def call(object)
  end

  def armarMatchCollection(*matchers,&bloque)
    self.collection = MatchCollection.new &bloque
    self.collection.add([self])
    self.collection.add(matchers)
    self.collection
  end
  def and(*matchers)
    armarMatchCollection(*matchers){|coll,obj| coll.all? {|matcher| matcher.call(obj)}}
  end

  def or(*matchers)
    armarMatchCollection(*matchers){|coll,obj| coll.any? {|matcher| matcher.call(obj)}}
  end

  def not
    NotMatcher.new self
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

##################################################################

class MatchCollection < Matchers
  attr_accessor :bloque
  def initialize(&bloq)
    self.matcher = []
    self.bloque = bloq
  end

  def add(matchers)
    matchers.to_a.each {|matcher| self.matcher << matcher}
  end

  def call(object)
    bloque.call(self.matcher,object)
  end
end

class NotMatcher < Matchers
  def initialize(matcher)
    self.matcher = matcher
  end

  def call(object)
    !self.matcher.call object
  end

  def not
    self
  end
end
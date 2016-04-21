class Matchers
  def initialize object
    @Matcher = object
  end
  def call object
  end
end


class VariableMatcher < Matchers
  def call object
    @Matcher == object
  end
end
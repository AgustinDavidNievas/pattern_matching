class Matcher
  attr_accessor :objAMatchear, :bloqueDeMatcheo

  def initialize(objAMatchear,&bloque)
    self.objAMatchear = objAMatchear
    self.bloqueDeMatcheo = bloque
  end

  def call(objetoAComparar)
    self.bloqueDeMatcheo.call(self.objAMatchear,objetoAComparar)
  end

  def and(*matchers)
    arrayDeMatchers = [self] + matchers
    Combinators.new(arrayDeMatchers) {|listaDeMatchers,objectoAComparar|
      listaDeMatchers.all? {|matcher|
        matcher.call(objectoAComparar)
      }
    }
  end

  def or(*matchers)
    arrayDeMatchers = [self] + matchers
    Combinators.new(arrayDeMatchers) {|listaDeMatchers,objectoAComparar|
      listaDeMatchers.any? {|matcher|
        matcher.call(objectoAComparar)
      }
    }
  end

  def not
    Matcher.new(self) {|matcher,objectoAComparar|
      !matcher.call(objectoAComparar)
    }
  end
end

################################################################

class Combinators < Matcher
end
module Combinators

  def and(*matchers)
    arrayDeMatchers = [self] + matchers
    Matcher.new(arrayDeMatchers) {|listaDeMatchers,objectoAComparar|
      coleccion = listaDeMatchers.collect {|matcher|
        matcher.call(objectoAComparar)
      }
      coleccion.all? {|valor| valor}
    }
  end

  def or(*matchers)
    arrayDeMatchers = [self] + matchers
    Matcher.new(arrayDeMatchers) {|listaDeMatchers,objectoAComparar|
      coleccion = listaDeMatchers.collect {|matcher|
        matcher.call(objectoAComparar)
      }
      coleccion.any? {|valor| valor}
    }
  end

  def not
    Matcher.new(self) {|matcher,objectoAComparar|
      !matcher.call(objectoAComparar)
    }
  end
end

################################################################

class Matcher
  include Combinators
  attr_accessor :objAMatchear, :bloqueDeMatcheo

  def initialize(objAMatchear,&bloque)
    self.objAMatchear = objAMatchear
    self.bloqueDeMatcheo = bloque
  end

  def call(objetoAComparar)
    self.bloqueDeMatcheo.call(self.objAMatchear,objetoAComparar)
  end
end

################################################################

class Pattern
  attr_accessor :matchers, :bloque

  def initialize(matchers,bloque)
    self.matchers = matchers
    self.bloque = bloque
  end

  def call(comparar)
    self.matchers.all? {|matcher| matcher.call(comparar)}
  end

  def exec
    self.instance_eval {self.bloque.call}
  end
end
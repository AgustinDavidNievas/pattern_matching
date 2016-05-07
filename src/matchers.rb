module Combinators

  def negar(&bloque)
      a = self.collect &bloque
      !a.first
  end

  def and(*matchers)
    arrayDeMatchers = [self] + matchers
    Matcher.new(arrayDeMatchers,&self.generarBloque(:all?))
  end

  def or(*matchers)
    arrayDeMatchers = [self] + matchers
    Matcher.new(arrayDeMatchers,&self.generarBloque(:any?))
  end

  def not
    arrayDeMatchers = [self]
    Matcher.new(arrayDeMatchers,&self.generarBloque(:negar))
    # Matcher.new(self) {|matcher,objectoAComparar,&contexto|
    #   !matcher.call(objectoAComparar,&contexto)
    # }
  end

  #private
  def generarBloque(sym)
    Proc.new {|listaDeMatchers,objectoAComparar,&contexto|
      listaDeMatchers.send(sym) {|matcher|
        matcher.call(objectoAComparar,&contexto)
      }
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

  def call(objetoAComparar, &contexto)
    self.bloqueDeMatcheo.call(self.objAMatchear,objetoAComparar,&contexto)
  end
end

################################################################

class Pattern
  attr_accessor :matchers, :bloque

  def initialize(matchers,&bloque)
    self.matchers = matchers
    self.bloque = bloque
  end

  def call(comparar)
    self.matchers.all? {|matcher| matcher.call(comparar) {self}}
  end

  def exec_block
    self.instance_eval &(self.bloque)
  end
end


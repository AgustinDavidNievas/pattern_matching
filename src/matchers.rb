module Combinators

  def negar(&bloque)
      !bloque.call(self)
  end

  def and(*matchers)
    armarNuevoMatcher([self] + matchers,:all?)
  end

  def or(*matchers)
    armarNuevoMatcher([self] + matchers,:any?)
  end

  def not
    armarNuevoMatcher(self,:negar)
  end

  private
  def armarNuevoMatcher(arrayDeMatchers,sym)
    Matcher.new(arrayDeMatchers) {|listaDeMatchers,objectoAComparar,&contexto|
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
  attr_accessor :matchers, :contexto, :sym, :bloque

  def initialize(matchers,contexto,sym,&bloque)
    self.matchers = matchers
    self.bloque = bloque
    self.contexto = contexto
    self.sym = sym
  end

  def call(comparar)
    self.matchers.send(sym) {|matcher| matcher.call(comparar) {@contexto}}
  end

  def get_block
    self.bloque
  end
end


require_relative '../src/matchers'

############################################################################
module Caller
  def self.default(claseMain)
    @@default = claseMain
    restoreDefault
  end

  def self.restoreDefault
    @@quienLlama = @@default
  end

  def self.caller(quienLlama)
    @@quienLlama = quienLlama
  end

  def call(otroObjeto)
    @@quienLlama.singleton_class.send(:define_method, self) {otroObjeto}
    true
  end
end

############################################################################
module Patter_Matching

    def val(param)
      Matcher.new(param) {|x,y| x == y}
    end

    def type(clase)
      unless clase.class == Class || clase.class == Module
        raise 'El parametro de type debe ser una Clase o Modulo'
      end
      Matcher.new(clase) {|x,y| y.class.ancestors.to_a.include?(x) }
    end

    def duck(*methods)
      Matcher.new(methods) {|x,y| x.all? {|method| y.methods.to_a.include?(method)}}
    end

    def list(array, cond = true)
      raise 'Debe ser un array'  unless type(Array).call(array)
      Matcher.new(array) {
          |x,y|

        if x.size <= y.size && (!cond || x.size == y.size)
          respuestas = []
          x.size.times {|time|
            if type(Matcher).call(x[time]) || x[time].class == Symbol
              respuestas << x[time].call(y[time])
            else
              respuestas << val(x[time]).call(y[time])
            end
          }
          respuestas.all? {|respuesta| respuesta}
        else
          false
        end
      }
    end

    def with(*matchers,&bloque)
      patron = Pattern.new(matchers,bloque)
      if instance_variable_defined? :@_patrones_
        @_patrones_ << patron
      end
      patron
    end

    def otherwise(&bloque)
      patron = Pattern.new(nil,bloque)
      patron.instance_eval {
        def call(x)
          true
        end
      }
      if instance_variable_defined? :@_patrones_
        @_patrones_ << patron
      end
      patron
    end
end

############################################################################

class Matches
  include Patter_Matching
  def call(objAMatchear,lanzarExcepcion = true,&bloque)
    Caller.caller self
    @_patrones_ = []
    instance_eval &bloque
    verdaderos = @_patrones_.select {|patron| patron.call(objAMatchear)}
    if verdaderos.empty?
      raise NoMacheaConNingunPatron if lanzarExcepcion
      return nil
    end
    Caller.restoreDefault
    verdaderos[0].exec_block
  end
end

############################################################################

module Match

  def matches(objAMatchear,lanzarExcepcion = true,&bloque)
    Matches.new.call(objAMatchear,lanzarExcepcion = true,&bloque)
  end
end

############################################################################

class NoMacheaConNingunPatron < StandardError
  #Esto tendria que estar en el lugar del string en el rise de arriba
end

class Object

  def iniciarFramework
    include Match
    Symbol.include Combinators
    Symbol.include Caller
    Caller.default self
  end
end

#self.iniciarFramework


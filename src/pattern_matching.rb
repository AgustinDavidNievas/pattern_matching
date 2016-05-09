require_relative '../src/matchers'

############################################################################

module Caller

  def call(otroObjeto, &contexto)
    if block_given?
      contexto.call.singleton_class.send(:define_method, self) { otroObjeto }
    end
    true
  end
end

############################################################################

module Pattern_Matching

  def val(param)
    Matcher.new(param) {|x,y| x == y}
  end

  def type(clase)
    unless clase.class.is_a?(Module)
      raise 'El parametro de type debe ser una Clase o Modulo'
    end
    Matcher.new(clase) {|x,y| y.is_a?(x) }
  end

  def duck(*methods)
    Matcher.new(methods) {|x,y| x.all? {|method| y.methods.include?(method)}}
  end

  def list(array, cond = true)
    raise 'Debe ser un array'  unless type(Array).call(array)
    Matcher.new(array) {
        |x,y,&contexto|
      if type(Array).call(y) && x.size <= y.size && (!cond || x.size == y.size)
        respuestas = []
        x.zip(y).each {|x,y|
          if type(Matcher).call(x) || x.class == Symbol
            respuestas << x.call(y,&contexto)
          else
            respuestas << val(x).call(y)
          end
        }
        respuestas.all?
      else
        false
      end
    }
  end
end

############################################################################

class Matches
  include Pattern_Matching
  attr :patrones, :contexto

  def with(*matchers,&bloque)
    crearPatron(matchers,:all?,&bloque)
  end

  def otherwise(&bloque)
    crearPatron(nil,:nil?,&bloque)
  end

  def call(objAMatchear,lanzarExcepcion = true,&bloque)
    @patrones = []
    @contexto = Object.new
    instance_eval &bloque
    verdaderos = @patrones.select {|patron| patron.call(objAMatchear)}
    if verdaderos.empty?
      raise NoMacheaConNingunPatron if lanzarExcepcion
      return nil
    end
    @contexto.instance_eval &verdaderos[0].get_block
  end

  def crearPatron(matchers,sym,&bloque)
    patron = Pattern.new(matchers,@contexto,sym,&bloque)
    if instance_variable_defined? :@patrones
      patrones << patron
    end
    patron
  end
end

############################################################################

module Match

  def matches(objAMatchear,lanzarExcepcion = true,&bloque)
    Matches.new.call(objAMatchear,lanzarExcepcion,&bloque)
  end
end

############################################################################

class NoMacheaConNingunPatron < StandardError
  #Esto tendria que estar en el lugar del string en el rise de arriba
end

############################################################################

class Object

  def self.iniciarFramework
    include Match
    Symbol.include Combinators
    Symbol.include Caller
  end
end

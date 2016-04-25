require_relative '../src/matchers'

class Symbol
  def call(otroObjeto)
    Object.send(:define_method, self) {otroObjeto}
    true
  end
end

############################################################################
#self.instance_eval do
class Object
  def val(param)
    if(param.class == Symbol)
      return param
    end
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
          if type(Matcher).call(x[time]) || x[time].class == Symbol #cambiar por type
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
    Pattern.new(matchers,bloque)
  end

  def otherwise(&bloque)
    patron = Pattern.new(nil,bloque)
    patron.instance_eval {
      def call(x)
        true
      end
    }
    patron
  end
end
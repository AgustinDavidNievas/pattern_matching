require_relative '../src/matchers'

class Symbol
  def call(otroObjeto)
    Object.send(:define_method, self) {otroObjeto}
    true
  end
end

############################################################################
class Object

  def iniciarFramework
    self.instance_eval do

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
        if instance_variable_defined? :@patrones
          @patrones << patron
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
        if instance_variable_defined? :@patrones
          @patrones << patron
        end
        patron
      end

      def matches(objAMatchear,lanzarExcepcion = true,&bloque)
        @patrones = []
        instance_eval &bloque
        verdaderos = @patrones.select {|patron| patron.call(objAMatchear)}
        if verdaderos.empty?
          raise 'El parametro no matchea con ningun patron ' if lanzarExcepcion
          return nil
        end
        verdaderos[0].exec
      end
    end
  end
end
"
self.iniciarFramework
matches('f') do
  with(type(Integer).and(:a)) {puts a + 100}
  with(val(4),type(Integer)) {puts 'este si anda'}
  with(val('ac'),type(String)) {puts 'este no anda'}
  with(val(39439439).or(duck(:nil?).and(:t))) {puts t.to_s + ' tiene el metodo nil?' }
 # otherwise {puts 'no anduvo nada'}
end
"


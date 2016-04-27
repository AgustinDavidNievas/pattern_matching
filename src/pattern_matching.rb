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
    #Object.class_variable_get(:@@clase_main).singleton_class.
    @@quienLlama.singleton_class.send(:define_method, self) {otroObjeto}

    true
  end
end
############################################################################
module Patter_Matching

  private

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
      Caller.caller self
      @patrones = []
      instance_eval &bloque
      verdaderos = @patrones.select {|patron| patron.call(objAMatchear)}
      if verdaderos.empty?
        raise 'El parametro no matchea con ningun patron ' if lanzarExcepcion
        return nil
      end
      Caller.restoreDefault
      verdaderos[0].exec_block
    end
  end

class Object

  def iniciarFramework
    include Patter_Matching
    Symbol.include Combinators
    Symbol.include Caller
    Caller.default self
  end
end



self.iniciarFramework


"
1.times {|x|
metodo = Patter_Matching.instance_methods(false).to_a[x]

parametros = []
puts metodo.to_s + ' tiene '+ Patter_Matching.instance_method(metodo).parameters().to_s
puts  Patter_Matching.instance_method(metodo).class
puts  Patter_Matching.instance_method(metodo).parameters[0].class
  metodo.each { |x|
    parametros << x[1]
  }

  puts parametros.to_s
#puts UnboundMethod.new.parameters
}

#a = Patter_Matching.instance_method(:list)
#algo = Object.new
#a.bind(algo).call([1,2,3])
#algo.list([1,2,3])


matches(7,0) do
  with(type(Integer).and(:a)) {puts a + 100}
  with(val(4),type(Integer)) {puts 'este si anda'}
  with(val('ac'),type(String)) {puts 'este no anda'}
  with(val(39439439).or(duck(:nil?).and(:t))) {puts t.to_s + ' tiene el metodo nil?' }
 otherwise {puts 'no anduvo nada'}
end


puts ObjectSpace.each_object(Matcher).count
matches('6.9',nil) do
  with(type(Integer).and(:t)) {puts 'es un integer'}
  with(type(String)) {puts t.to_s + ' es un string'}
end



a = with(list([duck(:+).and(type(Fixnum), :x),:y.or(val(4)), duck(:+).not.not])) { x + y }
puts a.call([1,2,3])

if a.call([1,2,3])
  puts a.exec_block
end

#Caller.called(algo=Object.new)
algo = Object.new
algo.iniciarFramework
b= with(list([:y.and(type(Numeric),duck(:+)),:x.and(type(Integer),duck(:-))])) {y**x}

if b.call([5,4532])
 puts b.exec_block
end


puts self.x
puts algo.x
"
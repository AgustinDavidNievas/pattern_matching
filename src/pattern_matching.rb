##############################
require '../src/matchers'

class Symbol
  def call(otroObjeto)
    #aca deberia bindearse
  end
end

class Object
  def val(param)
    if(param.class == Symbol)
      return param
    end
    VariableMatcher.new param
  end

  def type(clase)
    unless clase.class == Class || clase.class == Module
      raise 'El parametro de type debe ser una Clase o Modulo'
    end
    TypeMatcher.new clase
  end

  def duck(*methods)
    DuckMatcher.new *methods
  end
end


#puts val(4).call(34534)
puts val(4).and(type(Integer), type(Comparable)).call(4)
puts val(4).and(type(Integer), type(String)).not.call(4)

puts val(4).or(type(Integer), type(Comparable)).call(4)
puts val(4).or(type(Integer), type(String)).call(4)
"
objeto = Matchers.new 'sddsd'
ob = self
ob.instance_variable_set(:@xsdf,'asdasdasdas')
#puts @xsdf.context
puts :ada.call(objeto)


puts duck(:val,:type,:duck).call(Object.new)

puts type(Integer).call(4)
puts type(Comparable).call('sdfsdfsdf')
puts type(Comparable).call(4.4545)
puts type(Numeric).call(4.4545)
puts type(BasicObject).call(4.4545)
puts type(Kernel).call(4.4545)

class Persona
  def initialize obj
    @var = obj
  end
  def algo
    @var.to_s
  end
end


puts val(5).call(5)
puts val(5).call('5')
puts val(5).call(4)
puts val('23').call('23')
puts val(4).call(4.0000)

@persona = Persona.new 'Pedro'

puts val(@persona).call(@persona)
puts val(@persona).call(Persona.new 'Pedro')
puts val('Peddo').call(@persona.algo)"
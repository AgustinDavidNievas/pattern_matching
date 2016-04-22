require_relative '../src/matchers'

class Symbol
  def call(otroObjeto)
    #aca deberia bindearse
  end
end

############################################################################

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


puts val(4).not.call(34534)
puts val(4).and(type(Integer), type(Comparable)).call(4)
puts val(4).and(type(Integer), type(String)).not.call(4)

puts val(4).or(type(Integer), type(Comparable)).call(4)
puts val(4).or(type(Integer), type(String)).call(4)

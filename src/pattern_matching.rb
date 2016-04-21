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
      raise 'El parametro de type debe ser una Clase o Mudulo'
    end
    TypeMatcher.new clase
  end

  def duck(*methods)
    DuckMatcher.new *methods
  end
end
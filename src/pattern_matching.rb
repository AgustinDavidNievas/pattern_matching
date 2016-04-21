##############################
require '../src/matchers'

class Object
  def val(param)
    VariableMatcher.new param
  end

  def type(clase)
    Matching.new clase
  end
end

"
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
require 'rspec'
require_relative '../src/matchers'
require_relative '../src/pattern_matching'

class Persona
  def initialize(nombre)
    @nombre = nombre
  end
  def algo
    @nombre.to_s
  end
end

describe 'pattern_matching Test' do

  it 'de variable: ​se cumple ​siempre​. Vendría a ser el matcher ​identidad . ​
      Su verdadera utilidad es ​bindear las variables' do

      #TODO, ver mensaje call en Symbol, preguntar a los ayudantes

  end

  it 'de valor​: se cumple si el valor del objeto es idéntico al indicado' do

    pedro = Persona.new 'Pedro'

    expect(val(5).call(5))
    expect(val(4).call(4.0000))
    !expect(val(5).call('5'))
    !expect(val(5).call(4))
    expect(val('23').call('23'))
    !expect(val('yo que se estoy re loco').call('yo que se estoy re loca'))
    expect(val(pedro).call(pedro))
    expect(val(pedro).call(Persona.new 'Pedro'))

  end

  it 'de tipo​: se cumple si el objeto es del tipo indicado' do

    pedro = Persona.new 'Pedro'

    expect(type(Integer).call(4))
    expect(type(Comparable).call('hola soy un string comparable :B'))
    expect(type(Comparable).call(4.4545))
    expect(type(Numeric).call(4.4545))
    expect(type(Persona).call(pedro))

    #Estos de abajo funcionan por transitividad, ya que BasicObject y Kernel son ancestros#
    expect(type(BasicObject).call(4.4545))
    expect(type(Kernel).call(4.4545))
    expect(type(Object).call(pedro))
    #######################################################################################

    !expect(type(String).call(9))
    !expect(type(Persona).call(9))
  end

  it 'de listas​: se cumple si el objeto es una lista, cuyos primeros N elementos coinciden
      con los indicados; puede además requerir que el tamaño de la lista sea N. ' do
    #TODO test de listas,
    #tenemos una idea de como hacerlo, pero esta el detalle de que se
    #puede combinar con el matcher de variables
  end


  it 'duck typing​: se cumple si el objeto entiende una serie de mensajes determinados' do


    expect(duck(:nombre).call(Persona))
    !expect(duck(:nombre,:edad).call(Persona))
    #Ya que extendimos el comportamiento de Object...
    expect(duck(:val,:type,:duck).call(Object.new))

  end

  ########Combinators#########################################################################

  it 'and​: se cumple si se cumplen todos los matchers de la composición' do

    expect(val(4).and(type(Integer), type(Comparable)).call(4))
    expect(type(Integer).and(type(Integer), type(Object)).call(9))
    expect(type(Integer).and(type(Integer)).call(9))
    expect(type(Integer).and(type(Integer), type(Object), type(Comparable),type(BasicObject)).call(9))
    expect(duck(:+).and(type(Integer), val(5)).call(5))
    !expect(val(4).and(type(Integer), type(String)).call(4))
    !expect(type(Integer).and(type(Integer), type(Object)).call('soy un string'))
    !expect(type(String).and(type(Integer), type(Numeric)).call('soy un string'))

  end

  it 'or​: se cumple si se cumple al menos uno de los matchers de la composición' do

    expect(val(1).or(type(Integer), type(Comparable)).call(1))
    expect(type(Object).or(type(Integer), type(String)).call(4))
    expect(duck(:-).or(type(Integer)).call(4))
    !expect(type(Numeric).or(type(SignalException)).call(2))

  end

  it 'not​: genera el matcher opuesto' do

    bob = Persona.new('Bob')

    expect(val(4).not.call(34534))
    expect(type(Persona).not.call('Allahu Akbar!'))
    expect(duck(:kill_em_all).not.call(bob))
    !expect(type(String).not.call('Allahu Akbar!'))
    !expect(duck(:nombre).not.call(bob))

    expect(val(4).and(type(Integer), type(String)).not.call(4))
    !expect(duck(:-).or(type(Integer)).not.call(4))

  end

end

"
objeto = Matchers.new 'sddsd'
ob = self
ob.instance_variable_set(:@xsdf,'asdasdasdas')
#puts @xsdf.context
puts :ada.call(objeto)
"
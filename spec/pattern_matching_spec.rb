require 'rspec'
require_relative '../src/matchers'
require_relative '../src/pattern_matching'

class Comida
  #Soy comida :3
end

class Persona

  attr_accessor :nombre, :mensaje

  def initialize(nombre)
    @nombre = nombre
  end

  def algo
    @nombre.to_s
  end

  def come(comida)
    matches(comida, TRUE) do
      with(type(Integer)) {self.mensaje = 'estoy comiendo integers!'}
      with(type(String)) {self.mensaje = 'estoy comiendo string'}
      with(type(Comida)) {self.mensaje = 'estoy comiendo comida'}
      otherwise {self.mensaje = 'no hay comida :(!'}
    end
  end

end

class Perro
  attr_accessor :nombre, :mensaje

  def initialize(nombre)
    @nombre = nombre
  end

  def come(comida)
    matches(comida, TRUE) do
      with(type(Integer)) {self.mensaje = 'estoy comiendo integers!'}
      with(type(String)) {self.mensaje = 'estoy comiendo string'}
      with(type(Comida)) {self.mensaje = 'estoy comiendo comida'}
    end
  end
end


describe 'pattern_matching Test' do


  before(:each) do
    self.iniciarFramework
  end

  it 'de variable: ​se cumple ​siempre​. Vendría a ser el matcher ​identidad . ​
      Su verdadera utilidad es ​bindear las variables' do

    tony = Persona.new 'tony'

    expect(:a_variable_name.call(tony)).to eq(TRUE)
    expect(tony.methods.include?(:a_variable_name)).to eq(FALSE)


  end

  it 'de valor​: se cumple si el valor del objeto es idéntico al indicado' do

    pedro = Persona.new 'Pedro'

    expect(val(5).call(5)).to eq(TRUE)
    expect(val(4).call(4.0000)).to eq(TRUE)
    expect(val(5).call('5')).to eq(FALSE)
    expect(val(5).call(4)).to eq(FALSE)
    expect(val('23').call('23')).to eq(TRUE)
    expect(val('yo que se estoy re loco').call('yo que se estoy re loca')).to eq(FALSE)
    expect(val(pedro).call(pedro)).to eq(TRUE)
    expect(val(pedro).call(Persona.new 'Pedro')).to eq(FALSE)

  end

  it 'de tipo​: se cumple si el objeto es del tipo indicado' do

    pedro = Persona.new 'Pedro'

    expect(type(Integer).call(4)).to eq(TRUE)
    expect(type(Comparable).call('hola soy un string comparable :B')).to eq(TRUE)
    expect(type(Comparable).call(4.4545)).to eq(TRUE)
    expect(type(Numeric).call(4.4545)).to eq(TRUE)
    expect(type(Persona).call(pedro)).to eq(TRUE)

    #Estos de abajo funcionan por transitividad, ya que BasicObject y Kernel son ancestros#
    expect(type(BasicObject).call(4.4545)).to eq(TRUE)
    expect(type(Kernel).call(4.4545)).to eq(TRUE)
    expect(type(Object).call(pedro)).to eq(TRUE)
    #######################################################################################

    expect(type(String).call(9)).to eq(FALSE)
    expect(type(Persona).call(9)).to eq(FALSE)
  end

  it 'de listas​: se cumple si el objeto es una lista, cuyos primeros N elementos coinciden
      con los indicados; puede además requerir que el tamaño de la lista sea N. ' do
    lista = [1, 2, 3, 4]

    expect(list([1, 2, 3, 4],TRUE).call(lista)).to eq(TRUE)
    expect(list([1, 2, 3, 4],FALSE).call(lista)).to eq(TRUE)
    expect(list([2, 1, 3, 4],FALSE).call(lista)).to eq(FALSE)
    expect(list([2, 1, 3, 4],TRUE).call(lista)).to eq(FALSE)
    expect(list([1, 2, 3],TRUE).call(lista)).to eq(FALSE)
    expect(list([1, 2, 3]).call(lista)).to eq(FALSE)
    expect(list([1, 2, 3],FALSE).call(lista)).to eq(TRUE)

  end


  it 'duck typing​: se cumple si el objeto entiende una serie de mensajes determinados' do


    expect(duck(:nombre).call(Persona.new('Sabrina'))).to eq(TRUE)
    expect(duck(:nombre,:edad).call(Persona.new('Julian'))).to eq(FALSE)
    #Ya que extendimos el comportamiento de Object...
    expect(duck(:val,:type,:duck).call(Object.new)).to eq(FALSE)

  end

  ########Combinators#########################################################################

  it 'and​: se cumple si se cumplen todos los matchers de la composición' do

    expect(val(4).and(type(Integer), type(Comparable)).call(4)).to eq(TRUE)
    expect(type(Integer).and(type(Integer), type(Object)).call(9)).to eq(TRUE)
    expect(type(Integer).and(type(Integer)).call(9)).to eq(TRUE)
    expect(type(Integer).and(type(Integer), type(Object), type(Comparable),type(BasicObject)).call(9)).to eq(TRUE)
    expect(duck(:+).and(type(Integer), val(5)).call(5)).to eq(TRUE)
    expect(val(4).and(type(Integer), type(String)).call(4)).to eq(FALSE)
    expect(type(Integer).and(type(Integer), type(Object)).call('soy un string')).to eq(FALSE)
    expect(type(String).and(type(Integer), type(Numeric)).call('soy un string')).to eq(FALSE)

  end

  it 'or​: se cumple si se cumple al menos uno de los matchers de la composición' do

    expect(val(1).or(type(Integer), type(Comparable)).call(1)).to eq(TRUE)
    expect(type(Object).or(type(Integer), type(String)).call(4)).to eq(TRUE)
    expect(duck(:-).or(type(Integer)).call(4)).to eq(TRUE)
    expect(type(Persona).or(type(SignalException)).call(2)).to eq(FALSE)

  end

  it 'not​: genera el matcher opuesto' do

    bob = Persona.new('Bob')

    expect(val(4).not.call(34534)).to eq(TRUE)
    expect(type(Persona).not.call('Allahu Akbar!')).to eq(TRUE)
    expect(duck(:kill_em_all).not.call(bob)).to eq(TRUE)
    expect(type(String).not.call('Allahu Akbar!')).to eq(FALSE)
    expect(duck(:nombre).not.call(bob)).to eq(FALSE)

    expect(val(4).and(type(Integer), type(String)).not.call(4)).to eq(TRUE)
    expect(duck(:-).or(type(Integer)).not.call(4)).to eq(FALSE)

  end

  ###########Test punto 3 y punto 4##########################################################

  it 'Pattern y Matches' do

    x = [1, 2, 3]
    @resultado

    matches(x,TRUE) do
      with(list([:a, val(2), duck(:+)])) {@resultado = a + 2}
      with(list([1, 2, 3])) {'aca no llego'}
      otherwise {'aca tampoco llego'}
    end

    expect(a).to eq(1)
    expect(@resultado).to eq(3)
   ####################################################

    unObjeto = Object.new
    unObjeto.send(:define_singleton_method, :hola) {'hola'}
    @unString

    matches(unObjeto, TRUE) do
      with(duck(:hola)) {@unString = 'chau'}
      with(type(Object)) {'aca no llego'}
    end

    expect(@unString).to eq('chau')
    ##################################################

    unaNumero = 2
    @otroNumero

    matches(unaNumero, TRUE) do
      with(type(String)) {a + 2}
      with(list([1,2,3])) {'aca no llego'}
      otherwise {@otroNumero = 9} #Aca si llego
    end

    expect(@otroNumero).to eq(9)

    ###################################################

    sabrina = Persona.new 'Sabri'
    gaby = Persona.new 'Gaby'
    nico = Persona.new 'Nico'

    sabrina.come('soy un string re loco')
    gaby.come(Comida.new)
    nico.come(Object.new)

    expect(sabrina.mensaje).to eq('estoy comiendo string')
    expect(gaby.mensaje).to eq('estoy comiendo comida')
    expect(nico.mensaje).to eq('no hay comida :(!')




  end

  it 'Matches se espera Error' do
    rocky = Perro.new 'Rocky'

    expect{rocky.come(5.3)}.to raise_error(NoMacheaConNingunPatron)
  end

end

"
objeto = Matchers.new 'sddsd'
ob = self
ob.instance_variable_set(:@xsdf,'asdasdasdas')
#puts @xsdf.context
puts :ada.call(objeto)
"
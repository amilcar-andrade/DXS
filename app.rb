require "rubygems"
require "bundler/setup"
require "sinatra"
require "sequel"
require "date"

DB = Sequel.connect(:adapter => "mysql", :host=>"localhost", :user=>"root", :database=>"DXRS")

DB.create_table?(:contacto) do
  primary_key :id
  String :name
  String :compania
  String :mail
  String :telefono
  String :estado
  String :pregunta
  DateTime :fecha

end

def llenaestados
  estados = ['', 'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas', 'Chihuahua', 'Coahuila', 'Colima', 'Distrito Federal', 'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'Mexico', 'Michoacan', 'Morelos', 'Nayarit', 'Nuevo Leon', 'Oaxaca', 'Puebla', 'Queretaro', 'Quintana Roo', 'San Luis Potosi', 'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatan', 'Zacatecas']
  for i in 0...estados.length do
    DB[:estado].insert(:name => estados[i])
  end
end


DB.create_table?(:estado) do
  primary_key :id
  String :name

end

#llenaestados()


get '/inicio' do
  @titulo = "Inicio | Dexter Suasor"
  erb :inicio
end

get '/empresa' do
  @titulo = "Nuestras Certificaciones | Dexter Suasor"
  erb :empresa
end

get '/contacto' do
  @titulo = "Contacto | Dexter Suasor"
  @estados = DB[:estado].all
  erb :contacto
end

get '/valores' do
  @titulo = "Nuestra Empresa | Dexter Suasor"
  erb :valores
end

get '/valida' do
  DB.from(:contacto).insert(:fecha => DateTime.now, :name => params[:nombre], :compania => params[:compania], :mail => params[:mail],
                            :telefono => params[:telefono], :estado => params[:estado], :pregunta => params[:pregunta])


end
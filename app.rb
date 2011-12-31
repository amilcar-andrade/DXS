# encoding: utf-8
require "rubygems"
require "bundler/setup"
require "sinatra"
require "sequel"
require "date"
require "pony"
require "mysql2"
require "iconv"

Pony.options= {
  :via => :smtp,
  :via_options => {
    :address => 'smtp.gmail.com',
    :port => '587',
    :enable_starttls_auto => true,
    :user_name => 'amilcar.andrade.g',
    :password => 'strokes15',
    :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain => "localhost.localdomain" # the HELO domain provided by the client to the server
  }
}

DB = Sequel.connect(:adapter => "mysql2", :host=>"localhost", :user=>"root", :database=>"DXRS")


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

DB.create_table?(:wps) do
  String :id, :primary_key=>true
  String :nombre
  String :pqr
  String :empresa
  String :fecha
  String :revision
  String :fecharevision
  String :codigo
  String :proceso
  String :posicion
  String :f
  String :weldmetal
  String :mop
  String :grupo
  String :diametro

end


DB.create_table?(:wpq) do
  String :id, :primary_key=>true
  String :nombre
  String :empresa
  String :fecha
  String :emision
  String :vigencia
  String :codigo
  String :proceso
  String :posicion
  String :f
  String :weldmetal
  String :mop
  String :grupo
  String :diametro
  String :elaborado
  String :autorizado
  String :certificado

end

DB.create_table?(:wis) do
  String :id, :primary_key=>true
  String :nombre
  String :empresa
  String :fecha
  String :emision
  String :vigencia
  String :codigo
  String :seccion
  String :autorizado
  String :certificado

end

DB.create_table?(:pqr) do
  String :id, :primary_key=>true
  String :nombre
  String :fecha
  String :codigo
  String :proceso
  String :posicion
  String :f
  String :weldmetal
  String :mop
  String :grupo
  String :diametro
  String :elaborado
  String :acreditdado
  String :certificado

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

get '/excel' do
  contenido = File.open("archivos/base.csv").read
  fix_invalid = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  contenido = fix_invalid.iconv(contenido)
  contenido.split(/\r\n?/).each_with_index do |renglon, i|
    next if i == 0 # se salta los titulos de las columnas
    @arreglo = renglon.split(',')
    @arreglo.map! do |valor_columna|
      "'" + valor_columna.strip + "'"
    end
    @cadena= @arreglo.join(',')
    DB << "INSERT INTO wps VALUES(#{@cadena})"
  end
  redirect "/inicio"
end

get '/inicio' do
  @titulo = " Inicio | Dexter Suasor "
  @banner = false
  erb :inicio
end

get '/wpq' do
  @titulo = " Validacion WPQ | Dexter Suasor "
  @renglon = {}
  @comienzo = false
  @header = " Validaci&oacute;n Documentos WPQ "
  @banner = true
  erb :wpq
end

get '/wps' do
  @titulo = " Validacion WPS | Dexter Suasor "
  @renglon = {}
  @comienzo = false
  @header = " Validaci&oacute;n Documentos WPS "
  @banner = true
  erb :wps
end

get '/pqr' do
  @titulo = " Validacion PQR | Dexter Suasor "
  @renglon = {}
  @comienzo = false
  @header = " Validaci&oacute;n Documentos PQR "
  @banner = true
  erb :pqr
end

get '/wis' do
  @titulo = " Validacion WIS | Dexter Suasor "
  @renglon = {}
  @comienzo = false
  @header = " Validaci&oacute;n Documentos WIS "
  @banner = true
  erb :wis
end

get '/certificaciones' do
  @titulo = " Certificaciones | Dexter Suasor "
  @banner = true
  @header = " Certificaciones "
  @banner = true
  erb :certificaciones
end

get '/estados' do
  llenaestados()
  return " listo "
end

get '/empresa' do
  @titulo = " Nuestras Certificaciones | Dexter Suasor "
  @header = " Nuestras Certificaciones "
  @banner = true
  erb :empresa
end

get '/contacto' do
  @titulo = " Contacto | Dexter Suasor "
  @estados = DB[:estado].all
  @header = " Cont&aacute;ctanos "
  @banner = true
  erb :contacto
end

get '/valores' do
  @titulo = " Nuestra Empresa | Dexter Suasor "
  @header = " Nuestra Empresa "
  @banner = true
  erb :valores
end

get '/validawps' do
  DB.from(:wps)
  dataset = DB[" SELECT * FROM wps WHERE id = ?", params[:id]]
  @renglon = dataset.first
  @comienzo = true
  @header = "Validaci&oacute;n Documentos WPS"
  @banner = true
  erb :wps
end

get '/validawpq' do
  dataset = DB["SELECT * FROM wpq WHERE id = ?", params[:id]]
  @renglon = dataset.first
  @comienzo = true
  @header = "Validaci&oacute;n Documentos WPQ"
  @banner = true
  erb :wpq
end

get '/validawis' do
  DB.from(:wis)
  dataset = DB["SELECT * FROM wis WHERE id = ?", params[:id]]
  @renglon = dataset.first
  @comienzo = true
  @header = "Validaci&oacute;n Documentos WIS"
  @banner = true
  erb :wis
end

get '/validapqr' do
  DB.from(:pqr)
  dataset = DB["SELECT * FROM pqr WHERE id = ?", params[:id]]
  @renglon = dataset.first
  @comienzo = true
  @header = "Validaci&oacute;n Documentos PQR"
  @banner = true
  erb :pqr
end


post '/valida' do
  DB.from(:contacto).insert(:fecha => DateTime.now, :name => params[:nombre], :compania => params[:compania], :mail => params[:mail],
                            :telefono => params[:telefono], :estado => params[:estado], :pregunta => params[:pregunta])

  htmlcuerpo = <<Fin
<p><strong>Nombre del prospecto:</strong> #{params[:nombre]}   </p>
<p><strong>Compania: </strong>#{params[:compania]}</p>
<p><strong>E-mail: </strong>#{params[:mail]}</p>
<p><strong>Telefono: </strong> #{params[:telefono]}</p>
<p><strong>Estado: </strong>#{params[:estado]} </p>
<p><strong>Pregunta: </strong>#{params[:pregunta]}</p>

Fin

  Pony.mail(:to => 'amilcar.andrade.g@gmail.com', :html_body => htmlcuerpo, :subject => 'Un nuevo Prospecto ha llegado ', :body => ' Nombre de prospecto ' + params[:nombre] + ' Compania ' + params[:compania] + ' Fecha '+ DateTime.now.to_s + ' E-mail' + params[:mail] + ' Numero de telefono ' + params[:telefono] + ' Estado ' + params[:estado] + ' Pregunta ' + params[:pregunta])
  @titulo = "Contacto | Dexter Suasor"
  @confirmacion = true
  @estados = DB[:estado].all
  @header = "Cont&aacute;ctanos"
  @banner = true
  erb :contacto
end

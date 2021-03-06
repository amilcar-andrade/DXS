# encoding: utf-8
require "rubygems"
require "bundler/setup"
require "sinatra"
require "sequel"
require "date"
require "pony"
require "mysql2"
require "iconv"

if ENV['DATABASE_URL'] == nil
  HEROKU = false
  Pony.options= {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.gmail.com',
      :port => '587',
      :enable_starttls_auto => true,
      :user_name => 'xxxx',
      :password => 'XXXXX',
      :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain => "localhost.localdomain" # the HELO domain provided by the client to the server
    }
  }

  DB = Sequel.connect(:adapter => "mysql2", :host=>"localhost", :user=>"root", :database=>"DXRS")

else
  HEROKU = true
  Pony.options = {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }

  DB = Sequel.connect(ENV['DATABASE_URL'])


end


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

DB.create_table?(:soldador) do
  primary_key :id
  String :name
  String :mail
  String :telefono
  String :cel
  String :edad
  String :estado
  String :proceso_soldadura
  String :tipo_materiales
  String :experiencia
  String :proyectos
  String :swap
  DateTime :fecha
end


DB.create_table?(:inspector) do
  primary_key :id
  String :name
  String :mail
  String :telefono
  String :cel
  String :edad
  String :estado
  String :estudios
  String :certificaciones
  String :tecnicas_inspeccion
  String :proceso_soldadura
  String :experiencia
  String :proyectos
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
  String :fecha_emision
  String :vigencia
  String :codigo
  String :proceso
  String :posicion
  String :f
  String :weldmetal
  String :mop
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
  DB.run("DELETE FROM wpq")
  contenido = File.open("archivos/base2.csv").read
  contenido = Iconv.new('UTF-8//IGNORE', 'UTF-8').iconv(contenido)
  contenido.split(/\r\n?/).each_with_index do |renglon, i|
    next if i == 0 # se salta los titulos de las columnas
    @arreglo = renglon.split(',')
    @arreglo.map! do |valor_columna|
      "'" + valor_columna.strip + "'"
    end
    @cadena= @arreglo.join(',')
    DB << "INSERT INTO wpq VALUES(#{@cadena})"
  end
  DB.run("DELETE FROM wps")
  contenido = File.open("archivos/base.csv").read
  contenido = Iconv.new('UTF-8//IGNORE', 'UTF-8').iconv(contenido)
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
  @titulo = " Servicios Certificaci&oacute;n | Dexter Suasor "
  @banner = true
  @header = " Servicios de Certificaci&oacute;n "
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

get '/capacitacion' do
  @titulo = " Capacitaci&oacute;n | Dexter Suasor "
  @header = " Capacitaci&oacute;n "
  @banner = true
  erb :capacitacion
end

get '/cursos' do
  @titulo = " Lista Cursos | Dexter Suasor "
  @header = " Lista de Cursos "
  @banner = true
  erb :cursos
end

get '/contacto' do
  @titulo = " Contacto | Dexter Suasor "
  @estados = DB[:estado].all
  @confirmacion = false
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

get '/mision' do
  @titulo = " Nuestra Empresa | Dexter Suasor "
  @header = " Nuestra Empresa "
  @banner = true
  erb :mision
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


get '/bolsa' do
  @titulo = "Bolsa Trabajo | Dexter Suasor"
  @estados = DB[:estado].all
  @confirmacion = false
  @header = "Bolsa de Trabajo"
  @banner = true
  erb :bolsa
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

  Pony.mail(:to => 'miguel.andrade@dextersuasor.com', :html_body => htmlcuerpo, :subject => 'Un nuevo Prospecto ha llegado ', :body => ' Nombre de prospecto ' + params[:nombre] + ' Compania ' + params[:compania] + ' Fecha '+ DateTime.now.to_s + ' E-mail' + params[:mail] + ' Numero de telefono ' + params[:telefono] + ' Estado ' + params[:estado] + ' Pregunta ' + params[:pregunta])
  @titulo = "Contacto | Dexter Suasor"
  @confirmacion = true
  @estados = DB[:estado].all
  @header = "Cont&aacute;ctanos"
  @banner = true
  erb :contacto
end

post '/valida_soldador' do
  DB.from(:soldador).insert(:fecha => DateTime.now, :name => params[:nombre], :mail => params[:mail], :telefono => params[:telefono],
                            :cel => params[:cel], :edad => params[:edad], :estado => params[:estado], :proceso_soldadura => params[:proceso_soldadura], :tipo_materiales => params[:materiales], :experiencia => params[:experiencia], :proyectos => params[:proyectos], :swap => params[:dispuesto])

  htmlcuerpo = <<Fin
<p><strong>Nombre del soldador:</strong> #{params[:nombre]}   </p>
<p><strong>E-mail: </strong>#{params[:mail]}</p>
<p><strong>Telefono: </strong> #{params[:telefono]}</p>
<p><strong>Telefono Cel: </strong> #{params[:cel]}</p>
<p><strong>Edad: </strong> #{params[:edad]}</p>
<p><strong>Estado: </strong>#{params[:estado]} </p>
<p><strong>Proceso soldadura: </strong>#{params[:proceso_soldadura]}</p>
<p><strong>Materiales: </strong> #{params[:materiales]}</p>
<p><strong>Experiencia: </strong> #{params[:experiencia]}</p>
<p><strong>Proyectos: </strong> #{params[:proyectos]}</p>
<p><strong>Dispuesto a cambiar: </strong> #{params[:dispuesto]}</p>

Fin

  Pony.mail(:to => 'miguel.andrade@dextersuasor.com', :html_body => htmlcuerpo, :subject => 'Bolsa de Trabajo Soldador')
  @titulo = "Bolsa Trabajo | Dexter Suasor"
  @confirmacion = true
  @estados = DB[:estado].all
  @header = "Bolsa de Trabajo"
  @banner = true
  erb :bolsa
end

post '/valida_inspector' do
  DB.from(:inspector).insert(:fecha => DateTime.now, :name => params[:nombre], :mail => params[:mail], :telefono => params[:telefono],
                             :cel => params[:cel], :edad => params[:edad], :estado => params[:estado], :estudios => params[:grado], :certificaciones => params[:certificaciones], :tecnicas_inspeccion => params[:tecnicas], :proceso_soldadura => params[:proceso_soldadura], :experiencia => params[:experiencia], :proyectos => params[:empresas])

  htmlcuerpo = <<Fin
<p><strong>Nombre del soldador:</strong> #{params[:nombre]}   </p>
<p><strong>E-mail: </strong>#{params[:mail]}</p>
<p><strong>Telefono: </strong> #{params[:telefono]}</p>
<p><strong>Telefono Cel: </strong> #{params[:cel]}</p>
<p><strong>Edad: </strong> #{params[:edad]}</p>
<p><strong>Estado: </strong>#{params[:estado]} </p>
<p><strong>Escolaridad: </strong>#{params[:grado]} </p>
<p><strong>Proceso soldadura: </strong>#{params[:proceso_soldadura]}</p>
<p><strong>Certificaciones: </strong> #{params[:certificaciones]}</p>
<p><strong>Tecnincas: </strong> #{params[:tecnicas]}</p>
<p><strong>Proyectos o Experiencia: </strong> #{params[:experiencia]}</p>
<p><strong>Empresas anteriores: </strong> #{params[:empresas]}</p>

Fin

  Pony.mail(:to => 'miguel.andrade@dextersuasor.com', :html_body => htmlcuerpo, :subject => 'Bolsa de Trabajo Inspector')
  @titulo = "Bolsa Trabajo | Dexter Suasor"
  @confirmacion = true
  @estados = DB[:estado].all
  @header = "Bolsa de Trabajo"
  @banner = true
  erb :bolsa
end



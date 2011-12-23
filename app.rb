require "rubygems"
require "bundler/setup"
require "sinatra"


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
  erb :contacto
end

get '/valores' do
  @titulo = "Nuestra Empresa | Dexter Suasor"
  erb:valores
end
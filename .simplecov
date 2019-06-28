SimpleCov.start do
  add_filter 'version'
  add_filter '/spec/'

  track_files '{lib}/**/*.rb'
end
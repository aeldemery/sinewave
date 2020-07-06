sinewave_sources = [
  'main.vala',
  'window.vala',
  'SineWaveWidget.vala',
]

sinewave_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.24'),
  #dependency('gtk4'),
  meson.get_compiler('c').find_library('m', required: false),
]

gnome = import('gnome')

sinewave_sources += gnome.compile_resources('sinewave-resources',
  'sinewave.gresource.xml',
  c_name: 'sinewave'
)

executable('sinewave', sinewave_sources,
  vala_args: '--target-glib=2.50',  dependencies: sinewave_deps,
  install: true,
)

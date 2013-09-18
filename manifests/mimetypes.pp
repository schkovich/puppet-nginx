class nginx::mimetypes ($mime_types) {

  $file = "${nginx::params::nx_conf_dir}/mime.types"

  Exec {
    path => [
      '/bin/',
      '/sbin/' ,
      '/usr/bin/',
      '/usr/sbin/',
      '/usr/local/bin/'
    ]
  }

# Remove blank lines from the end of mime.types
  exec {'blank':
    command => "sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' ${file} > ${file}.tmp"
  }
# Remove the last line of mime.types having closing curly bracket
  exec {'last':
    command => "sed '$d' ${file}.tmp > ${file}"
  }
# Add new types
  file { 'tmp-one':
    path => "${file}.tmp",
    ensure => 'file',
    content => template('nginx/conf.d/mime.types.erb')
  }
# Concatenate files
  exec {'concat':
    command => "cat ${file}.tmp >> ${file}"
  }
# Clean up
  exec { 'tmp-two':
    command => "rm ${file}.tmp",
    notify => Service['nginx']
  }

  Exec['blank'] -> Exec['last'] -> File['tmp-one'] -> Exec['concat']
    -> Exec['tmp-two']

}
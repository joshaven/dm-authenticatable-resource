desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload]

namespace :website do
  web_dir = File.expand_path File.join(File.dirname(__FILE__), '..', 'website')
  web_src = File.expand_path File.join(File.dirname(__FILE__), '..', 'web_src')
  
  desc 'Generate website files'
  task :generate do
    require 'markdown'
    sh "mkdir -p #{web_dir}"
    Dir[File.join(web_src,'**','*.md')].each do |file|
      # file name without extention... /path/my.file.ext => my.file
      file_name = File.basename(file).split(Regexp.new("(#{File.extname(file)})"))[0..-2].join 
      File.open(File.join(web_dir, file_name + '.html'), 'w') do |f|
        f.write [ '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"',
                  '  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
                  '',
                  '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">',
                  '  <head>',
                  '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />',
                  "    <title>#{File.basename(file).split('.md').join.capitalize}</title>",
                  '<style type="text/css">',
                  '  body {',
                  '    background: white;',
                  '    color: black;',
                  '    margin-left: 25px;',
                  '  }',
                  '  h1 {',
                  '    color: rgb(51,51,51);',
                  '    text-shadow: rgb(221, 221, 221) 3px 3px 5px;',
                  '    font-size: 2em;',
                  '  }',
                  '  h2 {',
                  '    color: rgb(34, 34, 34);',
                  '    text-shadow: rgb(221, 221, 221) 3px 3px 5px;',
                  '    font-size: 1.5em;',
                  '  }',
                  '  h3 {',
                  '    color: rgb(34, 34, 34);',
                  '    text-shadow: rgb(221, 221, 221) 3px 3px 5px;',
                  '    font-size: 1.17em;',
                  '  }',
                  '  pre {',
                  '  background-color: rgb(240, 240, 240);',
                  '  border: 1px solid rgb(204, 203, 186);',
                  '  padding: 10px 10px 10px 20px;',
                  '}',
                  '  code {',
                  '    color: rgb(28,54,12);',
                  '    white-space pre-wrap;',
                  '    word-wrap: break-word;',
                  '    font-size: 95%;',
                  '  }',
                  '</style>',
                  '  </head>',
                  '  <body>',
                  ''].join("\n")
        f.write Markdown.new(File.read(file)).to_html
        f.write "  </body>\n</html>"
      end
    end
  end

  desc 'Upload website files to rubyforge'
  task :upload do
    rubyforge_username = YAML::load_file(File.join ENV['HOME'], '.rubyforge', 'user-config.yml')['username']
    host = "#{rubyforge_username}@rubyforge.org"
    remote_dir = "/var/www/gforge-projects/auth-resource/"
    local_dir = website
    # sh %{rsync -aCv #{local_dir}/ #{host}:#{remote_dir}}
    echo %{rsync -aCv #{local_dir}/ #{host}:#{remote_dir}}
  end

  desc 'Remove the website folder'
  task :clean do
    puts "Attempting to remove: #{website}"
    rm_r website if File.exists?(website)
  end
end
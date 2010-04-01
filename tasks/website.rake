desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload, :publish_docs]

namespace :website do
  website = File.expand_path File.join(File.dirname(__FILE__), '..', 'website')
  
  desc 'Generate website files'
  task :generate do
    require 'markdown'
    sh "mkdir -p #{website}"
    Dir['web_src/**/*.md'].each do |file| 
      File.open(file.gsub(/md$/,'html'), 'w') do |f|
        f.write [
          '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"',
          '  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
          '',
          '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">',
          '  <head>',
          '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />',
          "    <title>#{File.basename(file).split('.md').join.capitalize}</title>".
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
# -----------------------------------------------------------------------------
# Libraries
# -----------------------------------------------------------------------------
require 'yaml'
require 'erb'

# -----------------------------------------------------------------------------
# Global constants
# -----------------------------------------------------------------------------
THEME          = ENV.fetch('THEME', 'tutorial')
ORIG_DIR       = Rake.original_dir
WORK_DIR       = File.dirname(__FILE__)
PDF_DIR        = File.join(WORK_DIR, 'PDF', THEME)
HTML_DIR       = File.join(WORK_DIR, 'HTML', THEME)
THEMES_DIR     = File.join(WORK_DIR, '_themes')
SOURCE_DIR     = File.join(WORK_DIR, '_src')
IMAGES_DIR     = File.join(WORK_DIR, '_images')
ADOC_FILES     = Rake::FileList.new("#{SOURCE_DIR}/*.adoc")
PDF_FILES      = ADOC_FILES.pathmap("#{PDF_DIR}/%n.pdf")
HTML_FILES     = ADOC_FILES.pathmap("#{HTML_DIR}/%n.html")
STYLESHEETS    = Rake::FileList.new("#{THEMES_DIR}/*/*.css")
PDF_STYLESDIR  = Rake::FileList.new("#{THEMES_DIR}/#{THEME}")
FONTS          = Rake::FileList.new("#{PDF_STYLESDIR}/fonts")
ICONS          = Rake::FileList.new("#{PDF_STYLESDIR}/icons")
MODULE_FILES   = Rake::FileList.new("#{SOURCE_DIR}/modules/*adoc")
GRAPHICS_FILES = Rake::FileList.new("#{WORK_DIR}/_diagrams/*.gv").
                 include("#{WORK_DIR}/_diagrams/*.puml")
IMAGES         = Rake::FileList.new(IMAGES_DIR)
SVG_FILES      = GRAPHICS_FILES.pathmap("#{IMAGES_DIR}/%n.svg")
DOCKER_IMAGE   = 'uroesch/docker-asciidoctor:latest'

# -----------------------------------------------------------------------------
# Methods
# -----------------------------------------------------------------------------
def inside_docker?
  File.exist?('/.dockerenv')
end

def docker_asciidoctor(program = 'asciidoctor')
  return program if inside_docker?
  docker_options = [
    '--rm',
    '--tty',
    "--mount type=bind,src=#{WORK_DIR},target=#{WORK_DIR}",
    " --workdir=#{WORK_DIR}",
    " --user=#{Process.uid}:#{Process.gid}",
    DOCKER_IMAGE,
    program
  ]
  docker_command = "docker run " << docker_options.join(' ')
  p docker_command
end

def asciidoctor_pdf
   docker_asciidoctor('asciidoctor-pdf')
end

def asciidoctor_revealjs
   docker_asciidoctor('asciidoctor-revealjs')
end

def asciidoctor
   docker_asciidoctor
end

def add_meta(data)
  data['meta'] = []
  ['level', 'role'].each do |key|
    value = data.fetch(key, []).sort.join(', ')
    data['meta'].push("*#{key.capitalize}*: #{value}") unless value.empty?
  end
  data
end

def find_graphics(target)
  GRAPHICS_FILES.detect { |f| f.pathmap('%n') == target.pathmap('%n') }
end

def find_adoc(target)
  ADOC_FILES.detect { |f| f.pathmap('%n') == target.pathmap('%n') }
end

def stylesheets
  STYLESHEETS.map{ |s| " -a stylesheet=#{s} " }
end

def pdf_style
  " -a pdf-style=#{THEME}.yml "
end

def pdf_stylesdir
  " -a pdf-stylesdir=#{PDF_STYLESDIR} "
end

def pdf_fontsdir
  FONTS.map{ |s| " -a pdf-fontsdir=#{s} " }
end

def imagesdir
  IMAGES.map{ |s| " -a imagesdir=#{s} " }
end

def iconsdir
  ICONS.map{ |s| " -a iconsdir=#{s} " }
end

def html_options
  imagesdir <<
  iconsdir
end

def pdf_options
  stylesheets <<
  imagesdir <<
  iconsdir <<
  pdf_stylesdir <<
  pdf_style <<
  pdf_fontsdir
end

# -----------------------------------------------------------------------------
# Files and directories
# -----------------------------------------------------------------------------
directory PDF_DIR
directory HTML_DIR
directory IMAGES_DIR

# -----------------------------------------------------------------------------
# Tasks
# -----------------------------------------------------------------------------
task :default => :yaml

task :svg  => [IMAGES_DIR, *SVG_FILES]
task :pdf  => [PDF_DIR, *PDF_FILES]
task :html => [HTML_DIR, *HTML_FILES]
task :yaml => [:update_master, :svg, :pdf, :html]

desc "Generate document from yaml files"
task :generate do
  generate_master
end

desc "Update Master file if modules changes"
task :update_master do
  MODULE_FILES.each do |file|
    mod_mtime = File.stat(file).mtime
    ADOC_FILES.each do |master|
      if File.stat(master).mtime < mod_mtime
        touch master, mtime: mod_mtime
      end
    end
  end
end

desc "List all target files possible"
task :list_targets do
  puts '# PDF'
  puts PDF_FILES
  puts
  puts '# HTML'
  puts HTML_FILES
end

desc "List all source asciidoctor files"
task :list_adoc do
  puts ADOC_FILES
end

desc 'Clean the generated files in current directory'
task :clean do
  rm_rf PDF_DIR
  rm_rf HTML_DIR
end

desc 'Force recreation of all files'
task :force => :revealjs do
  touch ADOC_FILES
  Rake::Task[:default].invoke
end

desc "Build the reveal.js slides"
task :revealjs do
  ADOC_FILES.each do |adoc|
    sh %(#{asciidoctor_revealjs} ) +
       %(-a revealjsdir="." ) +
       %(-a revealjs_theme="70s" ) +
       %(-a revealjs_plugin_highlight="enabled" ) +
       %(#{imagesdir} ) +
       %(-o #{WORK_DIR}/SLIDES/#{adoc.pathmap('%n.html')} ) +
       %("#{adoc}" )
  end
end

desc "Update submodules"
task :sync_modules do
  sh %(git submodule update --recursive --remote)
end

# -----------------------------------------------------------------------------
# Rules
# -----------------------------------------------------------------------------
rule ".html" => ->(f){find_adoc(f)} do |t|
  # questions only
  sh %(#{asciidoctor} #{stylesheets} #{html_options} ) +
     %("#{t.source}" -o "#{t.name}")
  # with subversion
  sh %(#{asciidoctor} #{stylesheets} #{html_options} ) +
     %(-a with-subversion ) +
     %("#{t.source}" -o "#{t.name.pathmap("%X-with-subversion.html")}")
end

rule ".pdf" => ->(f){find_adoc(f)} do |t|
  # questions only
  sh %(#{asciidoctor_pdf} --trace #{stylesheets} #{pdf_options} ) +
     %("#{t.source}" -o "#{t.name}")
  # with subversion
  sh %(#{asciidoctor_pdf} --trace #{stylesheets} #{pdf_options} ) +
     %(-a with-subversion ) +
     %("#{t.source}" -o "#{t.name.pathmap("%X-with-subversion.pdf")}")
end

rule ".svg" => ->(f){find_graphics(f)} do |t|
  case t.source.pathmap('%x')
  when '.gv'
    sh %(dot -Tsvg -o #{t.name} #{t.source} )
  when '.puml'
    sh %(plantuml -tsvg -o #{t.name.pathmap("%d")} #{t.source} )
  else
    true
  end
end

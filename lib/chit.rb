$:.unshift File.dirname(__FILE__)
%w(rubygems git tempfile fileutils yaml wrap).each {|f| require f}

module Chit
  extend self
  VERSION = '0.0.5'
  
  defaults = {
    'root'  => "#{ENV['HOME']}/.chit"
  }
  
  CHITRC = "#{ENV['HOME']}/.chitrc"
  
  FileUtils.cp(File.join(File.dirname(__FILE__), "../resources/chitrc"), CHITRC) unless File.exist?(CHITRC)
  
  CONFIG = defaults.merge(YAML.load_file(CHITRC))
  
  def run(args)
    unless File.exist?(main_path) && File.exist?(private_path)
      return unless init_chit
    end
    args = args.dup
    
    return unless parse_args(args)

    if %w[sheets all].include? @sheet
      return list_all()
    end
    
    unless File.exist?(sheet_file)
      update
    end

    unless File.exist?(sheet_file)
      add(sheet_file)
    else
      show(sheet_file)
    end
  end
  
  def parse_args(args)
    init_chit and return if args.delete('--init')
    update and return if args.delete('--update')
    config(args) and return if args.delete('--config')
    
    @sheet = args.shift || 'chit'
    is_private = (@sheet =~ /^@(.*)/)
    if is_private
      @curr_repos = $1
      @sheet = args.length > 0 ? args.shift : 'chit'
    end

    working_dir = is_private ? repos_path(@curr_repos) : main_path
    @git = Git.open(working_dir)

    @fullpath = File.join(working_dir, "#{@sheet}.yml")
    
    add(sheet_file) and return if (args.delete('--add')||args.delete('-a'))
    edit(sheet_file) and return if (args.delete('--edit')||args.delete('-e'))
    rm(sheet_file) and return if (args.delete('--delete')||args.delete('-d'))
    search and return if (args.delete('--search')||args.delete('-s'))
    true
  end
  
  def list_all
    puts all_sheets.sort.join("\n")
  end
  
  def search
    reg = Regexp.compile("^#{@sheet}")
    files = all_sheets.select {|sheet| sheet =~ reg }
    puts files.sort.join("\n")
    true
  end
  
  def sheet_file
    @fullpath
  end
  
  def init_chit
    FileUtils.mkdir_p(CONFIG['root'])
    if CONFIG['repos']['main']['clone-from']
      if File.exist?(main_path)
        puts "Main chit has already been initialized."
      else
        puts "Initialize main chit from #{CONFIG['repos']['main']['clone-from']} to #{CONFIG['root']}/main"
        Git.clone(CONFIG['repos']['main']['clone-from'], 'main', :path => CONFIG['root'])
        puts "Main chit initialized."        
      end
    else
      puts "ERROR: configuration for main chit repository is missing!"
      return
    end
    
    unless File.exist?(private_path)
      if CONFIG['repos']['private'] && CONFIG['repos']['private']['clone-from']
        puts "Initialize private chit from #{CONFIG['repos']['private']['clone-from']} to #{CONFIG['root']}/private"
        Git.clone(CONFIG['repos']['private']['clone-from'], 'private', :path => CONFIG['root'])
        puts "Private chit initialized."
      else
        puts "Initialize private chit from scratch to #{CONFIG['root']}/private"
        Git.init(private_path)
        puts "Private chit initialized."
      end
    else
      puts "Private chit has already been initialized."
    end
    puts "Chit init done."
    true
  end
  
  def update
    if CONFIG['repos']['main']['clone-from']
      g = Git.open(main_path)
      g.pull
    end
  rescue
    puts "ERROR: can not update main chit."
    puts $!
  end
  
  def config(args)
    handle_repos(args) if args.delete('repos')
    
    open(CHITRC,'w') {|f| f << CONFIG.to_yaml}
    true
  end
  
  def handle_repos(args)
    rm_repos(args) and return if args.delete('rm')
    
    args.each{ |arg|
      expr = (arg =~ /([\w\-]+)\.([\w\-]+)\=(.+)/)
      puts "#{expr}"
      if expr
        CONFIG['repos'][$1] ||= {}
        CONFIG['repos'][$1][$2] = $3
        unless File.exist?(repos_path($1))
          puts "Initialize chit repository #{$1} to #{CONFIG['root']}/#{$1}"
          Git.init(repos_path($1))
          puts "Private chit initialized."
        end
      end
    }
  end
  
  def rm_repos(args)
    args.each{ |arg|
      CONFIG['repos'].delete(arg)
    }
  end
  
  def repos_path(repos)
    File.join(CONFIG['root'], repos)
  end
  
  def main_path
    File.join(CONFIG['root'], 'main')
  end
  
  def private_path
    File.join(CONFIG['root'], 'private')
  end
  
  def show(sheet_file)
    sheet = YAML.load(IO.read(sheet_file)).to_a.first
    sheet[-1] = sheet.last.join("\n") if sheet[-1].is_a?(Array)
    puts sheet.first + ':'
    puts '  ' + sheet.last.gsub("\r",'').gsub("\n", "\n  ").wrap
  end
  
  def rm(sheet_file)
    @git.remove(sheet_file)
    @git.commit_all("-")
  rescue Git::GitExecuteError
    FileUtils.rm_rf(sheet_file)
  end
  
  def add(sheet_file)
    unless File.exist?(sheet_file)
      breaker = sheet_file.rindex('/')+1
      path = sheet_file[0,breaker]
      title = @sheet.gsub(/\//,'::')
      FileUtils.mkdir_p(path)
      yml = {"#{title}" => ''}.to_yaml
      open(sheet_file, 'w') {|f| f << yml}
    end
    edit(sheet_file)
  end
  
  def edit(sheet_file)
    sheet = YAML.load(IO.read(sheet_file)).to_a.first
    sheet[-1] = sheet.last.gsub("\r", '')
    body, title = write_to_tempfile(*sheet), sheet.first
    if body.strip.empty?
      rm(sheet_file)
    else
      begin
        open(sheet_file,'w') {|f| f << {title => body}.to_yaml}
        @git.add
        @git.commit_all("-")
      rescue Git::GitExecuteError
        puts "ERROR: can not commit #{@curr_repos} chit."
        puts $!
      end
    end
    true
  end
  
  private
  
    def editor
      ENV['VISUAL'] || ENV['EDITOR'] || "vim"
    end
  
    def write_to_tempfile(title, body = nil)
      title = title.gsub(/\/|::/, '-')
      # god dammit i hate tempfile, this is so messy but i think it's
      # the only way.
      tempfile = Tempfile.new(title + '.cheat')
      tempfile.write(body) if body
      tempfile.close
      system "#{editor} #{tempfile.path}"
      tempfile.open
      body = tempfile.read
      tempfile.close
      body
    end
  
    def all_sheets
      @git.ls_files.to_a.map {|f| 
        f[0][0..((f[0].rindex('.')||0) - 1)]}
    end
  
end
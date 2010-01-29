#!/usr/bin/ruby
# vim: fileencoding=utf-8
require 'rubygems'
require 'zipruby'
require 'openssl'
require 'digest/sha1'
require 'fileutils'
require 'find'
require 'pathname'

class CrxMake < Object
  VERSION = '2.0.2'
  # thx masover
  MAGIC = 'Cr24'

  # this is chromium extension version
  EXT_VERSION = [2].pack('L')

  # CERT_PUBLIC_KEY_INFO struct
  KEY = %w(30 81 9F 30 0D 06 09 2A 86 48 86 F7 0D 01 01 01 05 00 03 81 8D 00).map{|s| s.hex}.pack('C*')
  KEY_SIZE = 1024

  def initialize opt
    @opt = opt
  end

  def make
    check_valid_option @opt
    if @pkey
      read_key
    else
      generate_key
    end
    create_zip
    sign_zip
    write_crx
  ensure
    final
  end

  def zip
    check_valid_option_zip @opt
    unless @pkey
      generate_key
      @pkey = @pkey_o
    end
    create_zip do |zip|
      puts "include pem key: \"#{@pkey}\"" if @verbose
      zip.add_file('key.pem', @pkey)
    end
  end

  private
  def check_valid_option o
    @exdir, @pkey, @pkey_o, @crx, @verbose, @ignorefile, @ignoredir = o[:ex_dir], o[:pkey], o[:pkey_output], o[:crx_output], o[:verbose], o[:ignorefile], o[:ignoredir]
    @exdir = File.expand_path(@exdir) if @exdir
    raise "extension dir not exist" if !@exdir || !File.exist?(@exdir) || !File.directory?(@exdir)
    @pkey = File.expand_path(@pkey) if @pkey
    raise "private key not exist" if @pkey && (!File.exist?(@pkey) || !File.file?(@pkey))
    if @pkey_o
      @pkey_o = File.expand_path(@pkey_o)
      raise "private key output path is directory" if File.directory?(@pkey_o)
    else
      count = 0
      loop do
        if count.zero?
          @pkey_o = File.expand_path("./#{File.basename(@exdir)}.pem")
        else
          @pkey_o = File.expand_path("./#{File.basename(@exdir)}-#{count+=1}.pem")
        end
        break unless File.directory?(@pkey_o)
      end
    end
    if @crx
      @crx = File.expand_path(@crx)
      raise "crx path is directory" if File.directory?(@crx)
    else
      count = 0
      loop do
        if count.zero?
          @crx = File.expand_path("./#{File.basename(@exdir)}.crx")
        else
          @crx = File.expand_path("./#{File.basename(@exdir)}-#{count+=1}.crx")
        end
        break unless File.directory?(@crx)
      end
    end
    puts <<-EOS if @verbose
crx output dir: \"#{@crx}\"
ext dir: \"#{@exdir}\"
    EOS
    @zip = File.join(File.dirname(@crx), 'extension.zip')
  end

  def check_valid_option_zip o
    @exdir, @pkey, @pkey_o, @zip, @verbose, @ignorefile, @ignoredir = o[:ex_dir], o[:pkey], o[:pkey_output], o[:zip_output], o[:verbose], o[:ignorefile], o[:ignoredir]
    @exdir = File.expand_path(@exdir) if @exdir
    raise "extension dir not exist" if !@exdir || !File.exist?(@exdir) || !File.directory?(@exdir)
    @pkey = File.expand_path(@pkey) if @pkey
    raise "private key not exist" if @pkey && (!File.exist?(@pkey) || !File.file?(@pkey))
    if @pkey_o
      @pkey_o = File.expand_path(@pkey_o)
      raise "private key output path is directory" if File.directory?(@pkey_o)
    else
      count = 0
      loop do
        if count.zero?
          @pkey_o = File.expand_path("./#{File.basename(@exdir)}.pem")
        else
          @pkey_o = File.expand_path("./#{File.basename(@exdir)}-#{count+=1}.pem")
        end
        break unless File.directory?(@pkey_o)
      end
    end
    if @zip
      @zip = File.expand_path(@zip)
      raise "crx path is directory" if File.directory?(@zip)
    else
      count = 0
      loop do
        if count.zero?
          @zip = File.expand_path("./#{File.basename(@exdir)}.zip")
        else
          @zip = File.expand_path("./#{File.basename(@exdir)}-#{count+=1}.zip")
        end
        break unless File.directory?(@zip)
      end
    end
    puts <<-EOS if @verbose
zip output dir: \"#{@zip}\"
ext dir: \"#{@exdir}\"
    EOS
  end

  def read_key
    puts "read pemkey: \"#{@pkey}\"" if @verbose
    File.open(@pkey, 'rb') do |io|
      @key = OpenSSL::PKey::RSA.new(io)
    end
  end

  def generate_key
    puts "generate pemkey to  \"#{@pkey_o}\"" if @verbose
    @key = OpenSSL::PKey::RSA.generate(KEY_SIZE)
    # save key
    File.open(@pkey_o, 'wb') do |file|
      file << @key.export()
    end
  end

  def create_zip
    puts "create zip" if @verbose
    Zip::Archive.open(@zip, Zip::CREATE | Zip::TRUNC) do |zip|
      Find.find(@exdir) do |path|
        unless path == @exdir
          if File.directory?(path)
            if @ignoredir && File.basename(path) =~ @ignoredir
              puts "ignore dir: \"#{path}\"" if @verbose
              Find.prune
            else
              puts "include dir: \"#{path}\"" if @verbose
              zip.add_dir(get_relative(@exdir, path))
            end
          else
            if @ignorefile && File.basename(path) =~ @ignorefile
              puts "ignore file: \"#{path}\"" if @verbose
            else
              puts "include file: \"#{path}\"" if @verbose
              zip.add_file(get_relative(@exdir, path), path)
            end
          end
        end
      end
      yield zip if block_given?
    end
    puts <<-EOS if @verbose
create zip...done
zip file at \"#{@zip}\"
    EOS
  end

  def get_relative base, target
    Pathname.new(target.to_s).relative_path_from(Pathname.new(base.to_s)).to_s
  end

  def sign_zip
    puts "sign zip" if @verbose
    plain = nil
    File.open(@zip, 'rb') do |file|
      plain = file.read
    end
    @sig = @key.sign(OpenSSL::Digest::SHA1.new, plain)
  end

  def write_crx
    print "write crx..." if @verbose
    key = KEY+@key.public_key.to_der
    File.open(@crx, 'wb') do |file|
      file << MAGIC
      file << EXT_VERSION
      file << to_sizet(key.size)
      file << to_sizet(@sig.size)
      file << key
      file << @sig
      File.open(@zip, 'rb') do |zip|
        file << zip.read
      end
    end
    puts "done at \"#{@crx}\"" if @verbose
  end

  def to_sizet num
    return [num].pack('L')
  end

  def final
    FileUtils.rm_rf(@zip) if @zip && File.exist?(@zip)
  end

  class << self
    def make opt
      new(opt).make
    end

    def zip opt
      new(opt).zip
    end
  end
end



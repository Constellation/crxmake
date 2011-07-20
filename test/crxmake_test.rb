require 'test/unit'
require File.dirname(__FILE__) + '/../lib/crxmake'
require 'fileutils'
require 'pp'
require 'open-uri'

class CrxMakeTest < Test::Unit::TestCase
  def setup
    @dir = File.expand_path(__name__)
    FileUtils.mkdir @dir
    puts @dir
    # chromefullfeed compile
    open("http://chromefullfeed.googlecode.com/files/package.tar") do |file|
      File.open(File.join(@dir, 'package.tar'), 'wb') do |f|
        f << file.read
      end
    end
    system("tar -xf #{File.join(@dir, "package.tar")} -C #{@dir}")
    @command = File.expand_path(File.dirname(__FILE__) + '/../bin/crxmake')
  end
  def teardown
    FileUtils.rm_rf @dir
  end
  def test_create_crx
    CrxMake.make(
      :ex_dir => File.join(@dir, 'src'),
      :pkey_output => File.join(@dir, 'test_crx.pem'),
      :crx_output => File.join(@dir, 'test_crx.crx'),
      :verbose => true,
      :ignorefile => /\.swp$/,
      :ignoredir => /^\.(?:svn|git|cvs)$/
    )
    assert(File.exist?(File.join(@dir, 'test_crx.crx')))
    assert(File.exist?(File.join(@dir, 'test_crx.pem')))
  end
  def test_create_zip
    CrxMake.zip(
      :ex_dir => File.join(@dir, 'src'),
      :pkey_output => File.join(@dir, 'test_zip.pem'),
      :zip_output => File.join(@dir, 'test_zip.zip'),
      :verbose => true,
      :ignorefile => /\.swp$/,
      :ignoredir => /^\.(?:svn|git|cvs)$/
    )
    assert(File.exist?(File.join(@dir, 'test_zip.zip')))
    assert(File.exist?(File.join(@dir, 'test_zip.pem')))
  end
  def test_create_crx_command
    puts `pwd`
    system("ruby #{@command} --pack-extension='#{File.join(@dir, 'src')}' --extension-output='#{File.join(@dir, 'test_crx.crx')}' --key-output='#{File.join(@dir, 'test_crx.pem')}' --verbose")
    assert(File.exist?(File.join(@dir, 'test_crx.crx')))
    assert(File.exist?(File.join(@dir, 'test_crx.pem')))
  end
  def test_create_zip_command
    system("ruby #{@command} --pack-extension='#{File.join(@dir, 'src')}' --zip-output='#{File.join(@dir, 'test_zip.zip')}' --key-output='#{File.join(@dir, 'test_zip.pem')}' --verbose")
    assert(File.exist?(File.join(@dir, 'test_zip.zip')))
    assert(File.exist?(File.join(@dir, 'test_zip.pem')))
  end
end


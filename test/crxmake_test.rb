require 'test/unit'
require File.dirname(__FILE__) + '/../lib/crxmake'
require 'fileutils'
require 'pp'
require 'open-uri'

class CrxMakeTest < Test::Unit::TestCase
  def setup
    @dir = File.expand_path('tmp')
    FileUtils.mkdir @dir
    # chromefullfeed compile
    open("http://chromefullfeed.googlecode.com/files/package.tar") do |file|
      File.open(File.join(@dir, 'package.tar'), 'wb') do |f|
        f << file.read
      end
    end
    system("tar -xf #{File.join(@dir, "package.tar")} -C #{@dir}")
  end
  def teardown
    FileUtils.rm_rf @dir
  end
  def test_create_crx
    CrxMake.make(
      :ex_dir => File.join(@dir, 'src'),
      :pkey_output => File.join(@dir, 'test.pem'),
      :crx_output => File.join(@dir, 'test.crx'),
      :verbose => true,
      :ignorefile => /\.swp$/,
      :ignoredir => /^\.(?:svn|git|cvs)$/
    )
    assert(File.exist?(File.join(@dir, 'test.crx')))
    assert(File.exist?(File.join(@dir, 'test.pem')))
  end
end


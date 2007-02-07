#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'test_helper')

class TestEXIF < Test::Unit::TestCase
  def test_initialize
    [[f('canon-g3.exif'), 'Canon PowerShot G3']].each do |fname,model|
      assert_equal EXIF.new(File.read(fname)).model, model
    end
    
    assert_raise RuntimeError, 'no II or MM marker found' do
      EXIF.new('X' * 100)
    end
  end
  
  def test_dates
    (all_test_exifs - [f('weird_date.exif')]).each do |fname|
      assert_kind_of Time, EXIF.new(File.read(fname)).date_time
    end
    assert_nil EXIF.new(File.read(f('weird_date.exif'))).date_time
  end
  
  def test_orientation
    all_test_exifs.each do |fname|
      orientation = EXIF.new(File.read(fname)).orientation
      assert_kind_of Module, orientation
      assert orientation.respond_to?(:to_i)
      assert orientation.respond_to?(:transform_rmagick)
    end
  end
  
  def test_thumbnail
    assert_not_nil JPEG.new(f('exif.jpg')).exif.thumbnail
    
    all_test_exifs.each do |fname|
      thumbnail = EXIF.new(File.read(fname)).thumbnail
      assert_nothing_raised do
        JPEG.new(StringIO.new(thumbnail))
      end
    end
  end
  
  def test_exif_offset
    assert JPEG.new(f('exif.jpg')).exif.include?(:exif_version)
  end
  
  def test_gps
    exif = EXIF.new(File.read(f('gps.exif')))
    assert exif.include?(:gps_version_id)
    assert_equal "\2\2\0\0", exif.gps_version_id
    assert_equal 'N', exif.gps_latitude_ref
    assert_equal 'W', exif.gps_longitude_ref
    assert_equal [5355537.quo(100000), 0.quo(1), 0.quo(1)], exif.gps_latitude
    assert_equal [678886.quo(100000), 0.quo(1), 0.quo(1)], exif.gps_longitude
    assert_equal 'WGS84', exif.gps_map_datum
    
    (all_test_exifs - [f('gps.exif')]).each do |fname|
      assert EXIF.new(File.read(fname)).keys.map{|k|k.to_s}.grep(/gps/).empty?
    end
  end
end
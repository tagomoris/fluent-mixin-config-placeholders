require 'helper'

class ConfigPlaceholdersTest < Test::Unit::TestCase
  def create_plugin_instances(conf)
    [
      Fluent::ConfigPlaceholdersTest0Input, Fluent::ConfigPlaceholdersTest1Input, Fluent::ConfigPlaceholdersTest2Input
    ].map{|klass| Fluent::Test::InputTestDriver.new(klass).configure(conf).instance }
  end

  def test_unused
    conf = %[
tag HOGE
path POSPOSPOS
]
    p = Fluent::Test::InputTestDriver.new(Fluent::ConfigPlaceholdersTest2Input).configure(conf).instance
    assert_equal ['tag','path'], p.conf.used

    conf = %[
tag HOGE
path POSPOSPOS
]
    p = Fluent::Test::InputTestDriver.new(Fluent::ConfigPlaceholdersTestXInput).configure(conf).instance
    assert_equal [], p.conf.used

    conf = %[
tag HOGE
path POSPOSPOS ${hostname} MOGEMOGE
]
    p = Fluent::Test::InputTestDriver.new(Fluent::ConfigPlaceholdersTestXInput).configure(conf).instance
    assert_equal [], p.conf.used
  end

  def test_default
    conf = %[
hostname testing
tag ${hostname}.%{hostname}.__HOSTNAME__
path /${hostname}/%{hostname}/__HOSTNAME__.log
]
    p = Fluent::Test::InputTestDriver.new(Fluent::ConfigPlaceholdersTestDefaultInput).configure(conf).instance
    assert_equal 'testing.%{hostname}.testing', p.tag
    assert_equal '/testing/%{hostname}/testing.log', p.path
  end

  def test_hostname
    conf1 = %[
hostname testing.local
tag out.${hostname}
path /path/to/file.__HOSTNAME__.txt
]
    p1, p2, p3 = create_plugin_instances(conf1)

    assert_equal 'out.${hostname}', p1.tag
    assert_equal 'out.testing.local', p2.tag
    assert_equal 'out.testing.local', p3.tag

    assert_equal '/path/to/file.__HOSTNAME__.txt', p1.path
    assert_equal '/path/to/file.testing.local.txt', p2.path
    assert_equal '/PATH/TO/FILE.TESTING.LOCAL.TXT', p3.path

    conf2 = %[
hostname testing.local
tag out.%{hostname}
path /path/to/file.%{hostname}.txt
]
    p1, p2, p3 = create_plugin_instances(conf2)

    assert_equal 'out.%{hostname}', p1.tag
    assert_equal 'out.testing.local', p2.tag
    assert_equal 'out.testing.local', p3.tag

    assert_equal '/path/to/file.%{hostname}.txt', p1.path
    assert_equal '/path/to/file.testing.local.txt', p2.path
    assert_equal '/PATH/TO/FILE.TESTING.LOCAL.TXT', p3.path
  end

  PATH_CHECK_REGEXP = Regexp.compile('^/path/to/file\.[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}.txt$')
  PATH_CHECK_REGEXP2 = Regexp.compile('^/PATH/TO/FILE\.[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}.TXT$')

  def test_uuid_random
    conf1 = %[
tag test.out
path /path/to/file.${uuid}.txt
]
    p1, p2, p3 = create_plugin_instances(conf1)
    assert_match PATH_CHECK_REGEXP, p2.path
    assert_match PATH_CHECK_REGEXP2, p3.path

    conf2 = %[
tag test.out
path /path/to/file.${uuid:random}.txt
]
    p1, p2, p3 = create_plugin_instances(conf2)
    assert_match PATH_CHECK_REGEXP, p2.path
    assert_match PATH_CHECK_REGEXP2, p3.path

    conf3 = %[
tag test.out
path /path/to/file.__UUID__.txt
]
    p1, p2, p3 = create_plugin_instances(conf3)
    assert_match PATH_CHECK_REGEXP, p2.path
    assert_match PATH_CHECK_REGEXP2, p3.path

    conf4 = %[
tag test.out
path /path/to/file.__UUID__.txt
]
    p1, p2, p3 = create_plugin_instances(conf4)
    assert_match PATH_CHECK_REGEXP, p2.path
    assert_match PATH_CHECK_REGEXP2, p3.path

    conf5 = %[
tag test.out
path /path/to/file.%{uuid}.txt
]
    p1, p2, p3 = create_plugin_instances(conf5)
    assert_match PATH_CHECK_REGEXP, p2.path
    assert_match PATH_CHECK_REGEXP2, p3.path

    conf6 = %[
tag test.out
path /path/to/file.%{uuid:random}.txt
]
    p1, p2, p3 = create_plugin_instances(conf6)
    assert_match PATH_CHECK_REGEXP, p2.path
    assert_match PATH_CHECK_REGEXP2, p3.path
  end

  PATH_CHECK_H_REGEXP = Regexp.compile('^/path/to/file\.[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}.log$')
  PATH_CHECK_H_REGEXP2 = Regexp.compile('^/PATH/TO/FILE\.[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}.LOG$')


  def test_uuid_hostname
    conf1 = %[
hostname testing.local
tag test.out
path /path/to/file.${uuid:hostname}.log
]
    p1, p2, p3 = create_plugin_instances(conf1)
    assert_match PATH_CHECK_H_REGEXP, p2.path
    assert_equal '/path/to/file.acc701f6-9be5-578b-9580-85ec8a505600.log', p2.path
    assert_match PATH_CHECK_H_REGEXP2, p3.path
    assert_equal '/PATH/TO/FILE.ACC701F6-9BE5-578B-9580-85EC8A505600.LOG', p3.path

    conf2 = %[
hostname testing.local
tag test.out
path /path/to/file.__UUID_HOSTNAME__.log
]
    p1, p2, p3 = create_plugin_instances(conf2)
    assert_match PATH_CHECK_H_REGEXP, p2.path
    assert_equal '/path/to/file.acc701f6-9be5-578b-9580-85ec8a505600.log', p2.path
    assert_match PATH_CHECK_H_REGEXP2, p3.path
    assert_equal '/PATH/TO/FILE.ACC701F6-9BE5-578B-9580-85EC8A505600.LOG', p3.path

    conf3 = %[
hostname testing.local
tag test.out
path /path/to/file.%{uuid:hostname}.log
]
    p1, p2, p3 = create_plugin_instances(conf3)
    assert_match PATH_CHECK_H_REGEXP, p2.path
    assert_equal '/path/to/file.acc701f6-9be5-578b-9580-85ec8a505600.log', p2.path
    assert_match PATH_CHECK_H_REGEXP2, p3.path
    assert_equal '/PATH/TO/FILE.ACC701F6-9BE5-578B-9580-85EC8A505600.LOG', p3.path
  end

  PATH_CHECK_T_REGEXP = Regexp.compile('^/path/to/file\.[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}.out$')
  PATH_CHECK_T_REGEXP2 = Regexp.compile('^/PATH/TO/FILE\.[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}.OUT$')

  def test_uuid_timestamp
    conf1 = %[
tag test.out
path /path/to/file.${uuid:timestamp}.out
]
    p1, p2, p3 = create_plugin_instances(conf1)
    assert_match PATH_CHECK_T_REGEXP, p2.path
    assert_match PATH_CHECK_T_REGEXP2, p3.path

    conf2 = %[
tag test.out
path /path/to/file.__UUID_TIMESTAMP__.out
]
    p1, p2, p3 = create_plugin_instances(conf2)
    assert_match PATH_CHECK_T_REGEXP, p2.path
    assert_match PATH_CHECK_T_REGEXP2, p3.path

    conf3 = %[
tag test.out
path /path/to/file.%{uuid:timestamp}.out
]
    p1, p2, p3 = create_plugin_instances(conf3)
    assert_match PATH_CHECK_T_REGEXP, p2.path
    assert_match PATH_CHECK_T_REGEXP2, p3.path
  end

  def test_nested
    conf = %[
hostname test.host.local
tag test.out
path /path/to/file.log
<config ${hostname}>
  var val1.${uuid:hostname}
  <group>
    field value.1.${uuid:hostname}
  </group>
  <group>
    field value.2.__UUID_HOSTNAME__
  </group>
</config>
]
    require 'uuidtools'
    uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, "test.host.local").to_s

    p1, p2, p3 = create_plugin_instances(conf)
    assert_equal "config", p3.conf.elements.first.name
    assert_equal "test.host.local", p3.conf.elements.first.arg
    assert_equal "val1." + uuid, p3.conf.elements.first['var']
    assert_equal "group", p3.conf.elements.first.elements[0].name
    assert_equal "value.1." + uuid, p3.conf.elements.first.elements[0]['field']
    assert_equal "value.2." + uuid, p3.conf.elements.first.elements[1]['field']
  end
end
